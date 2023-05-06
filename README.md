# Generate Voice via ChatGPT and ElevenLabs API
A simple program that generates an audio output through the combination of ChatGPT and ElevenLabs functionalities.

## Requirements
- A paid account on OpenAI platform
- Optional: You must subscribe to $5/mo (currently, might change in the future) or any tier account that includes "Access to Instant Voice Cloning" if you want to use your own voice clone.

## Setup
1. Create .env file and add the following variables:

```.env
OPENAI_API_KEY=<YOUR OPENAI API KEY>
ELEVENLABS_API_KEY=<YOU ELEVENLABS API KEY>
```
2. Run Julia REPL and add the following packages below.

```julia
using Pkg
Pkg.add("HTTP")
Pkg.add("JSON")
Pkg.add("Random")
Pkg.add("Printf")
Pkg.add("FileIO")
Pkg.add("DotEnv")
```

3. In the main.jl file, change the value of the following variables to match to configure based on your needs:

```julia
	target_name = "desired voice name"
  chatgpt_model = "gpt model version"
  chatgpt_system = "role of chatgpt"
	"voice_settings" => Dict(
    "stability" => 0.5,
    "similarity_boost" => 1.0
  )
```

