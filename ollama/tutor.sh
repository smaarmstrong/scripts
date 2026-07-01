#!/usr/bin/env bash
#
# tutor.sh — a local language-learning helper on top of Ollama.
#
# Reading texts, drilling grammar, and quick usage questions — all offline, all on your box.
#
# Configure your language (defaults: learning German, native English):
#   export TARGET_LANG="German"
#   export NATIVE_LANG="English"
#   export OLLAMA_MODEL="qwen2.5:7b"   # base model (see README for alternatives)
#
# Commands:
#   ./tutor.sh tutor              # interactive tutor session (persona + remembers the chat)
#   ./tutor.sh ask "question"     # one-off question about grammar / vocab / usage
#   ./tutor.sh read FILE          # reading support for a text file: translation + vocab + grammar
#   ./tutor.sh drill [TOPIC]      # generate a grammar drill (e.g. "dative case"); omit for a mix
#   ./tutor.sh chat               # plain interactive chat with the base model (no persona)
#
set -euo pipefail

TARGET_LANG="${TARGET_LANG:-German}"
NATIVE_LANG="${NATIVE_LANG:-English}"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:7b}"

command -v ollama >/dev/null 2>&1 || { echo "Ollama not installed — run ./ollama_install.sh first." >&2; exit 1; }

# A stable, per-language custom model name, e.g. tutor-german.
tutor_model() { echo "tutor-$(echo "$TARGET_LANG" | tr '[:upper:] ' '[:lower:]-')"; }

# One-shot completion: prompt on stdin, keeps big texts off the command line (ARG_MAX-safe).
run_once() { printf '%s' "$1" | ollama run "$OLLAMA_MODEL"; }

# System prompt shared by the interactive tutor persona.
system_prompt() {
  cat <<EOF
You are a patient, encouraging $TARGET_LANG tutor for a $NATIVE_LANG speaker.
- When the student shares a text, give: (1) a natural $NATIVE_LANG translation,
  (2) a short gloss of the trickier/less-common words, (3) brief grammar notes.
- When drilling grammar, ask ONE question at a time, wait for the answer, then
  correct gently and state the rule with a clear example.
- Speak mostly in $TARGET_LANG at a level just above the student's, but explain
  hard points in $NATIVE_LANG. Keep replies concise.
EOF
}

# (Re)build the per-language tutor model from a Modelfile, then drop into an interactive session.
do_tutor() {
  local model tmp
  model="$(tutor_model)"
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN
  {
    echo "FROM $OLLAMA_MODEL"
    echo 'SYSTEM """'
    system_prompt
    echo '"""'
  } > "$tmp"
  echo "Building $model from $OLLAMA_MODEL..." >&2
  ollama create "$model" -f "$tmp" >/dev/null
  echo "Starting $TARGET_LANG tutor. Type /bye to quit." >&2
  ollama run "$model"
}

do_ask() {
  [ -n "${1:-}" ] || { echo "Usage: $0 ask \"your question\"" >&2; exit 1; }
  run_once "You are a $TARGET_LANG tutor for a $NATIVE_LANG speaker. Answer concisely, with an example. Question: $1"
}

do_read() {
  local file="${1:-}"
  [ -n "$file" ] && [ -f "$file" ] || { echo "Usage: $0 read FILE   (a $TARGET_LANG text file)" >&2; exit 1; }
  local text; text="$(cat "$file")"
  run_once "The following is a text in $TARGET_LANG. Provide, in this order:
1. A natural $NATIVE_LANG translation.
2. A vocabulary gloss of the key or less-common words (word — meaning).
3. Notable grammar points a learner should notice.

TEXT:
$text"
}

do_drill() {
  local topic="${1:-a mix of core topics}"
  run_once "Create a short $TARGET_LANG grammar drill on: $topic.
Give 5 fill-in-the-blank or translation questions (numbered), suitable for a $NATIVE_LANG speaker.
After the questions, add an 'Answers' section with the solutions and a one-line explanation each."
}

case "${1:-tutor}" in
  tutor) do_tutor ;;
  ask)   shift; do_ask "${1:-}" ;;
  read)  shift; do_read "${1:-}" ;;
  drill) shift; do_drill "${1:-}" ;;
  chat)  ollama run "$OLLAMA_MODEL" ;;
  *) echo "Usage: $0 {tutor|ask \"q\"|read FILE|drill [TOPIC]|chat}" >&2; exit 1 ;;
esac
