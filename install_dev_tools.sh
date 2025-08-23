#!/bin/bash

set -e

echo "====================================="
echo " Починаємо встановлення Dev інструментів"
echo "====================================="

# --- Docker ---
if ! command -v docker &>/dev/null; then
    echo "Docker не знайдено. Ставимо..."
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "✅ Docker встановлено!"
else
    echo "✅ Docker вже є, нічого не робимо."
fi

# --- Docker Compose ---
if ! command -v docker-compose &>/dev/null; then
    echo "Docker Compose (стара команда) не знайдено. Ставимо..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose встановлено!"
else
    echo "✅ Docker Compose вже є."
fi

# --- Python ---
if ! command -v python3 &>/dev/null; then
    echo "Python3 не знайдено. Ставимо..."
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip python3-venv
    echo "✅ Python3 встановлено!"
else
    PY_VER=$(python3 -V | awk '{print $2}')
    echo "✅ Python3 вже є (версія $PY_VER)."
fi

# --- Django ---
if ! python3 -m django --version &>/dev/null; then
    echo "Django не знайдено. Ставимо..."
    pip3 install --user django
    echo "✅ Django встановлено!"
else
    DJANGO_VER=$(python3 -m django --version)
    echo "✅ Django вже є (версія $DJANGO_VER)."
fi

echo "====================================="
echo " ВСЕ ГОТОВО! 🎉"
echo "====================================="
