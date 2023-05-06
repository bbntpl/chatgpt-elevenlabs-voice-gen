# Install packages
# Note: Run this once in the Julia REPL
# using Pkg
# Pkg.add("HTTP")
# Pkg.add("JSON")
# Pkg.add("Random")
# Pkg.add("Printf")
# Pkg.add("FileIO")
# Pkg.add("DotEnv")

# Import packages
using HTTP
using JSON
using Random
using Printf
using FileIO
using DotEnv

cfg = DotEnv.config()

# Type the name of the voice you that you cloned in Eleven Labs
target_name = "desired voice name"

# Set API keys
openai_api_key = ENV["OPENAI_API_KEY"]
elevenlabs_api_key = ENV["ELEVENLABS_API_KEY"]

# Get voice list from eleven labs
function get_voice_list()
  headers = Dict("xi-api-key" => elevenlabs_api_key)
  url = "https://api.elevenlabs.io/v1/voices"
  response = HTTP.get(url, headers=headers)
  voices = JSON.parse(String(response.body))
  return voices
end

function find_voice_by_name(voice_list, target_name)
  for voice in voice_list["voices"]
    if voice["name"] == target_name
      return voice
    end
  end
  return nothing
end


selected_voice = find_voice_by_name(get_voice_list(), target_name)

# if success initialize the id of the selected voice
if selected_voice !== nothing
  selected_voice_id = selected_voice["voice_id"]
else # otherwise print not found and end the script
  println("Voice not found")
	exit()
end

function interact_with_gpt(prompt)
  chatgpt_model = "gpt-3.5-turbo"
  chatgpt_system = "You are a helpful assistant on a conversation. Answer should be not too long. Be ironic and acid"

  headers = Dict(
    "Content-Type" => "application/json",
    "Authorization" => "Bearer $openai_api_key"
  )

  data = Dict(
    "model" => chatgpt_model,
    "messages" => [
      Dict("role" => "system", "content" => chatgpt_system),
      Dict("role" => "user", "content" => prompt)
    ]
  )

  url = "https://api.openai.com/v1/chat/completions"
  response = HTTP.request("POST", url, headers, JSON.json(data))
  json_data = JSON.parse(String(response.body))
  return json_data["choices"][1]["message"]["content"]
end

function generate_unique_filename()
	return @sprintf("audio_%s.mp3", randstring(8))
end

# Text-to-speech function
function text_to_speech(text)
  CHUNK_SIZE = 1024
  url = "https://api.elevenlabs.io/v1/text-to-speech/$selected_voice_id"

  headers = Dict(
    "Accept" => "audio/mpeg",
    "Content-Type" => "application/json",
    "xi-api-key" => elevenlabs_api_key
  )

  data = Dict(
    "text" => text,
    "model_id" => "eleven_multilingual_v1",
    "voice_settings" => Dict(
      "stability" => 0.4,
      "similarity_boost" => 1.0
    )
  )

  response = HTTP.request("POST", url, headers, JSON.json(data))

	 # Save audio data to a file in the audio folder
	 filename = generate_unique_filename()
	 filepath = joinpath("audio", filename)

  # Save audio data to the audio folder
  open(filepath, "w") do f
    write(f, response.body)
  end

  return filepath
end

# To continuously interact with ChatGPT 3.5 or 4
while true
  println("Enter your prompt (type 'exit' to stop): ")
  prompt = readline()

	if lowercase(prompt) == "exit"
    break
  end

  response_text = interact_with_gpt(prompt)
  audio_file = text_to_speech(response_text)
end