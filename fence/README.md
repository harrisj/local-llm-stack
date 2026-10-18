# Fence

There are many different approaches for LLM guardrails that will prevent your
agents from nuking your system or hacking other sites. For myself, I wanted
something that was external to my coding harness and also deterministic. For my
needs, I chose [fence](https://github.com/fencesandbox/fence)

This is my fence config. It extends fence's existing `code` configuration with
some additional rules and restrictions based on my needs.

The most important of these are the rules that limit what the pi instance (and
by extension, tools running within it) is able to see. Right now, it blocks all
access except to the files within the current directory and subdirectories
(usually the project root), /tmp and a few places where I need to pull in config
settings.

I also stop the Pi instance from running Docker at all or merging to git. The
full code config that mine extends can be seen if you run `fence config show`
