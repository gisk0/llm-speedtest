# ⚡ llm-speedtest

> **Compare real API latency across major LLM providers in seconds.**

An [OpenClaw](https://github.com/openclaw/openclaw) skill that pings LLM APIs in parallel and ranks them by response time — so you can switch to whichever model is fastest right now.

## Why?

LLM latency varies wildly throughout the day. Sometimes Sonnet responds in under a second, sometimes it takes 8. This skill gives you a live leaderboard so you can pick the fastest option.

## Install

```bash
clawhub install llm-speedtest
```

Or clone manually into your OpenClaw skills directory:

```bash
git clone https://github.com/gisk0/llm-speedtest.git
cp -r llm-speedtest/skill/ ~/.openclaw/workspace/skills/llm-speedtest/
```

## Usage

Type `/ping` in your OpenClaw chat. Results appear in ~3 seconds:

```
⚡ Model Latency — 14:32

🟢 Gemini        412ms
🟢 GPT-4o        623ms
🟢 Sonnet        891ms
🟡 Grok         2104ms
🟡 MiniMax      3210ms
🟡 Opus         4102ms

real API latency (TTFT)
```

### What the badges mean

| Badge | Latency | Meaning |
|-------|---------|---------|
| 🟢 | < 2s | Fast — go for it |
| 🟡 | 2–5s | Normal — usable |
| 🔴 | 5–30s | Slow — consider switching |
| ⚫ | 30s+ | Timeout — provider may be down |

## How it works

1. Fetches your API keys from `pass` (or env vars — see [Configuration](#configuration))
2. Fires **parallel** curl requests to each provider with a minimal prompt (`"hi"`, `max_tokens: 1`)
3. Measures total round-trip time per request
4. Sorts results fastest → slowest and displays with color badges

All requests run in parallel, so total wait time = slowest provider (typically 2–4s).

## Providers & Models

| Provider | Model | Why this model? |
|----------|-------|-----------------|
| Anthropic | Claude Sonnet 4 | Most popular Claude model |
| Anthropic | Claude Opus 4 | Flagship, often slower |
| OpenAI | GPT-4o-mini | Cheapest & fastest OpenAI |
| Google | Gemini 2.5 Flash | Fastest Gemini variant |
| MiniMax | MiniMax-M1 | Fast alternative provider |
| xAI | Grok 3 Mini Fast | Fastest Grok variant |

All providers are **optional** — the script skips any provider where no API key is found.

## Configuration

### Option A: Using `pass` (default)

The script reads keys from [`pass`](https://www.passwordstore.org/):

```
pass shared/anthropic/api-key
pass shared/openai/api-key
pass shared/gemini/api-key
pass shared/minimax/api-key
pass shared/xai/api-key
```

### Option B: Using environment variables

Edit `skill/scripts/ping.sh` and replace the `pass` lines with:

```bash
ANTHROPIC_KEY="${ANTHROPIC_API_KEY:-}"
GEMINI_KEY="${GEMINI_API_KEY:-}"
MINIMAX_KEY="${MINIMAX_API_KEY:-}"
XAI_KEY="${XAI_API_KEY:-}"
OPENAI_KEY="${OPENAI_API_KEY:-}"
```

Then export your keys in your shell or `.env` file.

## Cost

**~$0.0001 per run** (one hundredth of a cent).

Each request sends 1 input token and requests 1 output token. Even Opus (the most expensive model tested) costs less than $0.0001 per ping. You could run `/ping` 10,000 times for a dollar.

## Requirements

- [OpenClaw](https://github.com/openclaw/openclaw) (any version)
- `bash`, `curl`, `bc` (available on virtually all Unix systems)
- API keys for at least one provider (all optional)

## License

MIT
