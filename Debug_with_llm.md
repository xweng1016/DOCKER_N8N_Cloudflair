# Debug_with_llm — minimal LLM context and prompts

Purpose
- Give an LLM the exact minimal context and commands to diagnose Docker + n8n + cloudflared issues.
- Students paste logs + outputs and use the suggested prompts to get precise fixes.

How to collect diagnostic info (copy outputs into the LLM):
1. docker ps --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
2. docker compose logs --no-color --timestamps --tail=200 n8n > n8n.logs && head -n 200 n8n.logs
3. docker compose logs --no-color --timestamps --tail=200 cloudflared > cloudflared.logs && head -n 200 cloudflared.logs
4. docker inspect -f '{{json .State}}' n8n
5. docker inspect -f '{{json .State}}' cloudflared
6. If present: ls -la ./cloudflared && head -n 5 ./cloudflared/cert.pem

System prompt (paste to LLM as system message)
"You are a concise Docker and Cloudflare tunnel troubleshooting assistant. Keep answers short and give explicit commands to run and exact file edits. When asking for more info, list the single next command to run."

User prompt templates (pick one and paste with collected outputs)

A) "Analyze DIAGNOSTIC block below and give: 1) single root cause statement (1 line), 2) one exact command to run next, 3) file edits (if any) with exact YAML/lines. DIAGNOSTIC:
--- begin diagnostic ---
{paste outputs from steps 1..5 here}
--- end diagnostic ---"

B) "I see cloudflared logs (paste cloudflared.logs). Why does it say 'Cannot determine default origin certificate path' and how to fix it for a named tunnel using MACCARD_ID from .env? Provide exact host commands to run and docker-compose lines to change."

C) "n8n is not reachable. Here are docker ps and n8n.logs (paste). Give 3 possible causes (one-line each) and the one command to gather more info."

Expected vs Incorrect outputs quick table
- Expected: "postgres -> healthy" ; Incorrect: "postgres -> starting" => ask LLM: 'show postgres logs' (command: docker compose logs postgres)
- Expected: "n8n -> healthy and listening on 0.0.0.0:5678" ; Incorrect: "curl: (7) Failed to connect" => check n8n logs and DB connection string
- Expected: "cloudflared logs show 'Tunnel <MACCARD_ID> started' or DNS mapping" ; Incorrect: "Cannot find cert.pem" => run cloudflared login on host and copy ./cloudflared/cert.pem

Quick commands to ask the LLM for (students paste this with outputs)
- docker ps
- docker compose ps
- docker compose logs cloudflared --tail 200
- docker compose logs n8n --tail 200
- ls -la ./cloudflared

Privacy/safety note
- Mask secrets before pasting (.env values like passwords). Replace with <MASKED>.
- For file contents, only paste relevant excerpted lines (errors, stack traces).

Example minimal prompt (paste into LLM with collected logs)
"I ran the diagnostics. Here are the cloudflared logs and docker ps output: {paste}. Suggest one exact fix and the single command to run next."

Use this file as the LLM context to get targeted, actionable help.
