# Lilia Documentation

This repository contains the source files for the official Lilia Wiki documentation.

> **Note:**

> The documentation lives in the `documentation/` directory of the main Lilia repo:

> https://github.com/LiliaFramework/Lilia/tree/main/documentation

> Please do **not** open pull requests or push directly to this repo.

---

## 📖 Overview

Lilia is a lightweight, modular framework for building Garry’s Mod addons in GLua. Its documentation covers:

- **Getting Started:** installation, setup, and core concepts

- **API Reference:** detailed descriptions of modules, functions, and hooks

- **Guides & Tutorials:** step-by-step walkthroughs for common tasks

- **Best Practices:** patterns for secure, optimized, and maintainable code

---

## 🚀 Local Preview

1. **Clone** this repo:

   ```bash
   git clone https://github.com/LiliaFramework/Lilia.wiki.git
   cd Lilia.wiki
2. **Create** and **activate** a Python virtual environment (recommended):

   ```bash
   python3 -m venv .venv

   source .venv/bin/activate

   ```
3. **Install** the documentation dependencies:

   ```bash
   pip install mkdocs mkdocs-material mkdocs-awesome-pages-plugin

   ```
4. **Serve** locally on `http://127.0.0.1:8000` (auto-reloads on changes):

   ```bash
   mkdocs serve

   ```
5. Open your browser at [http://127.0.0.1:8000](http://127.0.0.1:8000) to preview the documentation.

---

## 🤝 Contributing

All documentation changes live in the main Lilia repo:

1. Fork & clone **LiliaFramework/Lilia**.
2. Edit files under `documentation/`.
3. Commit, push to your fork, and open a PR against `main`.
4. Tag your PR with **documentation**.

> **Tip:** Use markdown linting and spell-check before opening a PR.
