---
name: llm-speedtest
version: 1.0.0
description: "Ping major LLM providers in parallel and compare real API latency. Run with /ping"
metadata:
  category: utility
  capabilities:
    - api
  dependencies: []
  interface: shell
openclaw:
  emoji: "⚡"
  requires:
    env:
      - ANTHROPIC_API_KEY (optional)
      - OPENAI_API_KEY (optional)
      - GEMINI_API_KEY (optional)
      - MINIMAX_API_KEY (optional)
      - XAI_API_KEY (optional)
      - SPEEDTEST_PROVIDERS (optional, default: all)
author:
  name: chapati23
---

# LLM Speedtest

Ping major LLM providers in parallel and compare real API latency (TTFT).

## When to Use

- User types `/ping` or asks about model latency/speed
- Comparing provider response times
- Checking if a specific provider is slow or down

## How It Works

Runs `scripts/ping.sh` which:

1. Retrieves API keys from `pass shared/` (users may need to adapt key sourcing for their setup)
2. Fires parallel `curl` requests to each provider with a minimal prompt ("hi", `max_tokens=1`)
3. Measures total round-trip time per provider
4. Sorts results by latency and displays with color badges

## Output Format

Results are sorted fastest-to-slowest with color badges:

- 🟢 **< 2s** — Fast
- 🟡 **2–5s** — Normal
- 🔴 **5–30s** — Slow
- ⚫ **30s** — Timeout

Example:

```text
⚡ Model Latency — 14:32

🟢 `Gemini       412ms`
🟢 `GPT-5 Mini       623ms`
🟢 `Sonnet       891ms`
🟡 `Grok        2104ms`
🟡 `MiniMax     3210ms`
🟡 `Opus        4102ms`

_real API latency (TTFT)_
```

## Models Tested

| Provider | Model |
|----------|-------|
| Anthropic | Claude Sonnet 4.6 |
| Anthropic | Claude Opus 4.6 |
| OpenAI | GPT-5 Mini |
| Google | Gemini 3.1 Pro |
| MiniMax | MiniMax-M2.5 |
| xAI | Grok 4 Fast |

## Cost

~$0.0001 per run (1 token per model, cheapest tiers).

## Configuration

Set `SPEEDTEST_PROVIDERS` (env var or exported in your shell) to control which providers are pinged:

```bash
# Anthropic only
export SPEEDTEST_PROVIDERS=anthropic

# Anthropic + OpenAI
export SPEEDTEST_PROVIDERS=anthropic,openai
```

Valid values: `anthropic`, `openai`, `gemini`, `minimax`, `xai`. Defaults to all providers.

## Note

This skill uses `pass shared/` for API key retrieval. If you don't use `pass`, you'll need to adapt `scripts/ping.sh` to source keys from environment variables or another secret manager.
