#!/bin/bash
# Model latency checker - real API TTFT (parallel)
# shellcheck disable=SC2312

ANTHROPIC_KEY=$(pass shared/anthropic/api-key 2>/dev/null)
GEMINI_KEY=$(pass shared/gemini/api-key 2>/dev/null)
MINIMAX_KEY=$(pass shared/minimax/api-key 2>/dev/null)
XAI_KEY=$(pass shared/xai/api-key 2>/dev/null)
OPENAI_KEY=$(pass shared/openai/api-key 2>/dev/null)

TMPDIR=$(mktemp -d)

if [[ -n ${ANTHROPIC_KEY} ]]; then
	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://api.anthropic.com/v1/messages" \
			-H "x-api-key: ${ANTHROPIC_KEY}" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
			-d '{"model":"claude-sonnet-4-20250514","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|Sonnet" >"${TMPDIR}/sonnet"
	) &

	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://api.anthropic.com/v1/messages" \
			-H "x-api-key: ${ANTHROPIC_KEY}" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
			-d '{"model":"claude-opus-4-20250514","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|Opus" >"${TMPDIR}/opus"
	) &
fi

if [[ -n ${GEMINI_KEY} ]]; then
	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=${GEMINI_KEY}" \
			-H "Content-Type: application/json" \
			-d '{"contents":[{"parts":[{"text":"hi"}]}],"generationConfig":{"maxOutputTokens":1}}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|Gemini" >"${TMPDIR}/gemini"
	) &
fi

if [[ -n ${MINIMAX_KEY} ]]; then
	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://api.minimax.chat/v1/text/chatcompletion_v2" \
			-H "Authorization: Bearer ${MINIMAX_KEY}" -H "Content-Type: application/json" \
			-d '{"model":"MiniMax-M2.5","messages":[{"role":"user","content":"hi"}],"max_tokens":1}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|MiniMax" >"${TMPDIR}/minimax"
	) &
fi

if [[ -n ${XAI_KEY} ]]; then
	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://api.x.ai/v1/chat/completions" \
			-H "Authorization: Bearer ${XAI_KEY}" -H "Content-Type: application/json" \
			-d '{"model":"grok-4-fast-non-reasoning","messages":[{"role":"user","content":"hi"}],"max_tokens":1}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|Grok" >"${TMPDIR}/grok"
	) &
fi

if [[ -n ${OPENAI_KEY} ]]; then
	(
		ms=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 \
			-X POST "https://api.openai.com/v1/chat/completions" \
			-H "Authorization: Bearer ${OPENAI_KEY}" -H "Content-Type: application/json" \
			-d '{"model":"gpt-5-mini","messages":[{"role":"user","content":"hi"}],"max_tokens":1}')
		echo "$(echo "${ms} * 1000" | bc -l | cut -d. -f1)|GPT-5" >"${TMPDIR}/gpt5"
	) &
fi

wait

results=()
for f in "${TMPDIR}"/*; do
	[[ -f ${f} ]] && results+=("$(cat "${f}")")
done
rm -rf "${TMPDIR}"

output="⚡ Model Latency — $(date +%H:%M)\n\n"

while IFS='|' read -r ms name; do
	if [[ ${ms} -lt 2000 ]]; then
		badge="🟢"
	elif [[ ${ms} -lt 5000 ]]; then
		badge="🟡"
	elif [[ ${ms} -lt 30000 ]]; then
		badge="🔴"
	else
		badge="⚫"
	fi
	padded=$(printf "%-10s %6sms" "${name}" "${ms}")
	output+="${badge} \`${padded}\`\n"
done < <(printf '%s\n' "${results[@]}" | sort -t'|' -n)

output+="\n_real API latency (TTFT)_"
# shellcheck disable=SC2059
printf "${output}"
