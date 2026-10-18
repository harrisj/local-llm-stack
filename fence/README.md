# Fence

There are many different approaches for LLM guardrails that will prevent your
agents from nuking your system or hacking other sites. For myself, I wanted
something that was external to my coding harness and also deterministic. For my
needs, I chose [fence](https://github.com/fencesandbox/fence)

This is my fence config. It extends fence's existing `code` configuration with
some additional rules and restrictions based on my needs.
