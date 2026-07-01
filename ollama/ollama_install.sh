#!/usr/bin/env bash
#
# ollama_install.sh — install Ollama on Rocky Linux (RHEL 9 family) and run it as a service.
#
# Meant to be run on a fresh, console-only Rocky box. Steps are idempotent — safe to re-run.
#
#   ./ollama_install.sh            # install Ollama + enable the service (default)
#   ./ollama_install.sh models     # pull the language-learning model(s)
#   ./ollama_install.sh status     # show service state + installed models
#   ./ollama_install.sh gpu        # check for an NVIDIA GPU / CUDA driver
#   ./ollama_install.sh remove     # stop + disable the service (leaves models on disk)
#
# The model to pull is configurable:
#   export OLLAMA_MODEL="qwen2.5:7b"   # default; see README for alternatives
#
set -euo pipefail

OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:7b}"

need_sudo() { [ "$(id -u)" -ne 0 ] && echo "sudo" || echo ""; }
SUDO="$(need_sudo)"

gpu_check() {
  echo "== GPU check =="
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi -L
    echo "NVIDIA driver present — Ollama will use the GPU automatically."
    return 0
  fi
  if lspci 2>/dev/null | grep -iq nvidia; then
    cat <<'EOF'
An NVIDIA GPU is present but the driver (nvidia-smi) is NOT installed.
Ollama will fall back to CPU until you install the CUDA driver:

  sudo dnf config-manager --add-repo \
    https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
  sudo dnf install -y cuda-drivers
  sudo reboot        # then re-run: ./ollama_install.sh gpu

(This is optional — CPU-only works fine for small models, just slower.)
EOF
    return 0
  fi
  echo "No NVIDIA GPU detected — running CPU-only. Stick to <=8B models."
}

do_install() {
  echo "== Installing Ollama on $(. /etc/os-release; echo "$PRETTY_NAME") =="

  if ! command -v curl >/dev/null 2>&1; then
    echo "Installing curl..."
    $SUDO dnf install -y curl
  fi

  if command -v ollama >/dev/null 2>&1; then
    echo "Ollama already installed: $(ollama --version 2>/dev/null || true)"
  else
    # Official installer — sets up the systemd 'ollama' service and an 'ollama' user.
    curl -fsSL https://ollama.com/install.sh | sh
  fi

  # Make sure the service is enabled + running (installer usually does this).
  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl enable --now ollama 2>/dev/null || true
  fi

  echo
  gpu_check
  echo
  echo "Ollama version: $(ollama --version 2>/dev/null || echo '??')"
  echo "Next: ./ollama_install.sh models   (pulls $OLLAMA_MODEL)"
}

do_models() {
  command -v ollama >/dev/null 2>&1 || { echo "Ollama not installed — run: ./ollama_install.sh" >&2; exit 1; }
  echo "== Pulling $OLLAMA_MODEL (this can take a while) =="
  ollama pull "$OLLAMA_MODEL"
  echo
  echo "Installed models:"
  ollama list
}

do_status() {
  echo "== Service =="
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --no-pager --full status ollama 2>/dev/null | head -n 5 || echo "service not found"
  fi
  echo
  echo "== Installed models =="
  command -v ollama >/dev/null 2>&1 && ollama list || echo "ollama not installed"
}

do_remove() {
  echo "Stopping and disabling the Ollama service (models stay on disk under ~/.ollama)..."
  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl disable --now ollama 2>/dev/null || true
  fi
  echo "Done. To fully remove: sudo rm /usr/local/bin/ollama && sudo userdel ollama"
}

case "${1:-install}" in
  install) do_install ;;
  models)  do_models ;;
  status)  do_status ;;
  gpu)     gpu_check ;;
  remove)  do_remove ;;
  *) echo "Usage: $0 {install|models|status|gpu|remove}" >&2; exit 1 ;;
esac
