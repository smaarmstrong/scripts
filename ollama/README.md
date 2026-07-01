# ollama

Run a local LLM on a console-only box and use it as an offline **language tutor** —
reading texts, drilling grammar, quick usage questions. Built for Rocky Linux
(RHEL 9 family), but the scripts work on any systemd distro (Fedora, RHEL, etc.).

Nothing leaves the machine, so it's fine for a headless ThinkPad with no cloud account.

## 1. Install (run on the Rocky box)

```bash
./ollama_install.sh            # install Ollama + enable the systemd service
./ollama_install.sh models     # pull the model (default: qwen2.5:7b)
./ollama_install.sh gpu        # check for an NVIDIA GPU / CUDA driver
./ollama_install.sh status     # service state + installed models
```

`install` is idempotent — safe to re-run. It uses the official Ollama installer,
which creates an `ollama` systemd service and an `ollama` user.

## 2. Use it

```bash
export TARGET_LANG="German"    # the language you're learning
export NATIVE_LANG="English"   # your language

./tutor.sh tutor              # interactive tutor (persona + remembers the session)
./tutor.sh ask "when do I use dative vs accusative?"
./tutor.sh read article.txt   # translation + vocab gloss + grammar notes for a text file
./tutor.sh drill "dative case"  # generate a grammar drill with answers
./tutor.sh chat               # plain chat with the base model, no persona
```

## Choosing a model

Set `OLLAMA_MODEL` before running either script. Rough guide by hardware:

| Model              | ~RAM/VRAM | Notes                                             |
|--------------------|-----------|---------------------------------------------------|
| `qwen2.5:3b`       | ~3 GB     | CPU-only / low-RAM ThinkPad; fast, decent         |
| `qwen2.5:7b`       | ~6 GB     | **Default.** Strong multilingual, good grammar    |
| `aya-expanse:8b`   | ~6 GB     | Cohere's explicitly multilingual model            |
| `gemma2:9b`        | ~7 GB     | Good multilingual alternative                     |

Quantized (Q4) sizes. The bottleneck is RAM/VRAM, not the OS. On a CPU-only
laptop, stick to 3B–7B and expect a few tokens/sec — fine for reading/grammar,
sluggish for long back-and-forth.

## Notes

- The `tutor` command builds a small per-language custom model (`tutor-<lang>`)
  from a Modelfile with a tutor system prompt — that's what gives it its persona
  and session memory. Re-running it rebuilds it (cheap).
- GPU is auto-detected. Without the NVIDIA driver installed, Ollama runs on CPU;
  `./ollama_install.sh gpu` prints the CUDA driver install steps for Rocky 9.
- Requires internet **only** for the install and the first model pull. After that
  it's fully offline.
