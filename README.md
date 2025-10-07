---
title: Ollama + Qwen2.5 (3B) — Baseline
emoji: 🧠
colorFrom: blue
colorTo: green
sdk: docker
sdk_version: '1.0'
app_file: start.sh
pinned: false
license: apache-2.0
---

# 🧩 Ollama + Qwen2.5 (3B) — Baseline Space

This Space provides a minimal working setup of **Ollama** running locally inside a Hugging Face Space container and serving the **Qwen 2.5 (3B)** model through its REST API.

It’s designed as **Version 1 – Baseline Validation** before extending into multimodal (VL) or image-to-video workflows.

---

## 🚀 What This Space Does

1. 🧱 Installs **Ollama** inside the container (`curl -fsSL https://ollama.com/install.sh | bash`)
2. ⚙️ Launches the **Ollama server** on port 11434
3. ⏳ Waits for the API to become ready
4. 📥 Pulls the **Qwen 2.5 (3B)** model
5. 🧪 Runs a small Python test to verify that generation works via REST API

Example log on successful startup: