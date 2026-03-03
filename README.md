# ⚡ llm-speedtest

Ping major LLM providers in parallel and compare real API latency. An [OpenClaw](https://openclaw.dev) skill.

## Quick Start

```bash
clawhub install llm-speedtest
```

Then type `/ping` in your OpenClaw chat.

## What It Does

Fires parallel API requests to 6 major LLM providers with a minimal prompt (`"hi"`, `max_tokens=1`) and measures the real round-trip time (TTFT). Results are sorted by latency with color-coded badges.

### Output Example

```
⚡ Model Latency — 14:32

🟢 Gemini       412ms
🟢 GPT-4o       623ms
🟢 Sonnet       891ms
🟡 Grok        2104ms
🟡 MiniMax     3210ms
🟡 Opus        4102ms

real API latency (TTFT)
```

### Badges

| Badge | Latency | Status |
|-------|---------|--------|
| 🟢 | < 2s | Fast |
| 🟡 | 2–5s | Normal |
| 🔴 | 5–30s | Slow |
| ⚫ | 30s+ | Timeout |

## Models Tested

- **Anthropic** — Claude Sonnet 4, Claude Opus 4
- **OpenAI** — GPT-4o-mini
- **Google** — Gemini 2.5 Flash
- **MiniMax** — MiniMax-M1
- **xAI** — Grok 3 Mini Fast

## Configuration

The script retrieves API keys from `pass shared/`. You'll need keys for whichever providers you want to test:

| Key path | Provider |
|----------|----------|
| `pass shared/anthropic/api-key` | Anthropic |
| `pass shared/openai/api-key` | OpenAI |
| `pass shared/gemini/api-key` | Google |
| `pass shared/minimax/api-key` | MiniMax |
| `pass shared/xai/api-key` | xAI |

All keys are optional — the script skips providers with missing keys.

> **Note:** If you don't use `pass`, edit `skill/scripts/ping.sh` to source keys from environment variables or your preferred secret manager.

## Cost

~$0.0001 per run. Each request sends a single token and requests 1 token back.

## License

MIT
