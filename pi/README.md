# Pi Coding Framework Config

## 

## Extensions

Pi famously comes with very few options included. Currently, I am using the following extensions:

- npm:@ollama/pi-web-search
- npm:@alexanderfortin/pi-loaded-tools
- npm:pi-plan
- npm:pi-show
- npm:pi-powerline-footer
- npm:pi-output-styles
- npm:pi-context-view
- npm:pi-tool-missing-guard
- npm:@sting8k/pi-utils
- npm:@nicknisi/pi-ast-grep
- npm:@henryqw/pi-ask-question
- npm:pi-ponytail
- npm:@jamesjfoong/pi-ollama
- npm:@99percentpeople/pi-thinking-fold
- git:github.com/code-yeongyu/pi-nested-agents-md
- npm:@narumitw/pi-btw
- npm:pi-blackhole
- npm:@kdejaeger/pi-model-router
- npm:pi-goal-x
- npm:pi-mcp-adapter
- npm:model-debugger

## System Prompt

Let me first say that most prompting advice is more folklore than science, since
it's hard to know what is really effective. All these prompts are is what the
model is told first, in the hopes that it will guide the LLM pachinko down
better pathways. Never rely solely on system prompts to prevent things you
absolutely need to NEVER happen. For that, I recommend external deterministic
gates like fence.
