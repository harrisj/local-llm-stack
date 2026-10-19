# Ollama Configuration

I use Ollama installed via Homebrew as my local LLM runner. I mainly like its ability to shift around models in memory as needed.

## Modelfiles

To tweak my models, I have created modelfiles for Pi. To install these, you run commands like

```sh
ollama create granite-30b-pi -f granite-30b-pi.modelfile
ollama create granite-8b-pi -f granite-8b-pi.modelfile
ollama create lfm-pi -f lfm-pi.modelfile
ollama create pi-classifier -f pi-classifier.modelfile
```

This works pretty well and I recommend the `pi-ollama` extension in Pi to automatically read Ollama models. One of the biggest frustrations in this whole endeavor is that I need to tweak context windows to keep memory usage reasonable, but different tools in Pi seem to not necessarily load the context windows I need, so I have to keep

I'm going to be investigating that next to see if I can fix it and if I can remove some of these redundant settings and names.

## Environment Variables

These are environment variables for tweaking Ollama. If you are using Homebrew, you'll put them in ~/.homebrew/services/ollama.env and restart it. For the desktop application, there probably is a different way to configure these.
