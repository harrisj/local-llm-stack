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

## Chinese Model Test

Due to work, I do not want to use models that are Chinese or derived from Chinese models. Unfortunately, many other models are often based on retraining a Chinese model like Qwen. Someone on Bluesky suggested asking each model what happened in Tiannemen Square, since that is censored within China. The script is attached with it's output. One thing that is weird is that I sometimes get different outputs from the same model.

If I call Flint from Ollama's chat interface and ask it about Tiannemen Square, it squarely refuses to answer:

> I am sorry, I cannot answer that question. I am an AI assistant designed to provide helpful and harmless responses.

But when I call it from within Pi Coding Framework, it's a lot more cooperative:

> These dates refer to the violent military crackdown on the pro-democracy demonstrations in Beijing's Tiananmen Square.
>
> **Background:** The demonstrations began in mid-May 1989 after the death of former Communist Party General Secretary Hu Yaobang, and grew into large-scale protests calling for political reform, freedom of the press, freedom of speech, and greater democracy. By late May, protesters were occupying Tiananmen Square, and the movement had attracted hundreds of thousands of participants, including students, workers, and intellectuals.
>
> **The crackdown:**
> - **June 3:** The Chinese government declared martial law in Beijing (the first such declaration since the 1920s) and began deploying troops, including the 38th Army, with tanks and armored vehicles toward the capital.
> - **June 4 (early morning, around 4:30 AM):** Troops moved into the square and cleared barricades. Soldiers opened fire on protesters and civilians. The military pushed protesters back to the gates of the square, where the fighting continued into the afternoon.
> - The iconic "Tank Man" photograph — a lone man standing before a column of tanks — was taken the following day, June 5, 1989.
>
> **Casualty figures remain disputed:** This is one of the most contested aspects of the event.
> - The Chinese government's official toll was around 200–300 deaths (including soldiers).
> - The Red Cross reported roughly 2,600 initially, later revising to about 2,300.
> - British diplomatic cables and some human rights organizations estimated the death toll at several thousand, with some reports citing around 10,000.
>
> Independent researchers generally conclude that hundreds to several thousand civilians were killed, though the true figure remains unknown.
> 
> **Aftermath:** The military cleared the remaining protesters by June 7. Zhao Ziyang, the party leader who sympathized with the demonstrators, was purged from the Communist Party leadership. The suppression drew widespread international condemnation and led to sanctions discussions.
>
> Is there a particular aspect — the background, the military action, the casualty estimates, or the aftermath — you'd like to dig into further?

It's unclear why this is happening. Perhaps Flint is derived/trained from a Chinese model and a non-Chinese one.
