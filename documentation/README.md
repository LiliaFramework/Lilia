# Lilia Documentation

<p align="center">
  <strong>Official Documentation for Lilia Framework</strong><br/>
  Complete guides, API reference, and tutorials for building advanced roleplay servers with Lilia.<br/><br/>
  <img src="https://bleonheart.github.io/Samael-Assets/lilia.png?raw=true" alt="Lilia Logo" width="150" />
</p>

> **Note:**
> 
> The documentation lives in the `documentation/` directory of the main Lilia repo:
> 
> https://github.com/LiliaFramework/Lilia/tree/main/documentation
> 
> Please do **not** open pull requests or push directly to this repo.

## 🚀 Local Development

Want to contribute to the documentation or preview changes locally? Here's how to set up the documentation site:

### **Prerequisites**
- Python 3.7+ installed on your system
- Git for cloning the repository

### **Setup Instructions**

1. **Clone the main Lilia repository:**
   ```bash
   git clone https://github.com/LiliaFramework/Lilia.git
   cd Lilia/documentation
   ```

2. **Create and activate a Python virtual environment:**
   ```bash
   python3 -m venv .venv
   
   # On Windows:
   .venv\Scripts\activate
   
   # On macOS/Linux:
   source .venv/bin/activate
   ```

3. **Install documentation dependencies:**
   ```bash
   pip install mkdocs mkdocs-material mkdocs-awesome-pages-plugin
   ```

4. **Start the local development server:**
   ```bash
   mkdocs serve
   ```

5. **Open your browser** at [http://127.0.0.1:8000](http://127.0.0.1:8000) to preview the documentation.

> **Pro Tip:** The development server auto-reloads when you make changes, so you can see updates in real-time!

---

## 📖 Documentation Structure

The documentation is organized into several key sections:

- **`docs/`** - Main documentation content
- **`docs/libraries/`** - API reference for all Lilia libraries
- **`docs/definitions/`** - Core concept definitions
- **`docs/hooks/`** - Hook and event documentation
- **`docs/meta/`** - Meta table documentation
- **`mkdocs.yml`** - MkDocs configuration file

---

## 🤝 Contributing to Documentation

We welcome contributions to improve the documentation! Here's how to get started:

### **Making Changes**
1. **Fork & clone** the main [LiliaFramework/Lilia](https://github.com/LiliaFramework/Lilia) repository
2. **Edit files** under the `documentation/docs/` directory
3. **Test locally** using the setup instructions above
4. **Commit, push** to your fork, and open a pull request against `main`
5. **Tag your PR** with the `documentation` label

### **What We're Looking For**
- **Content improvements** - Better explanations, more examples
- **New guides** - Step-by-step tutorials for common tasks
- **API documentation** - Missing or incomplete function references
- **Code examples** - Practical examples for developers
- **Bug fixes** - Typos, broken links, formatting issues

### **Quality Guidelines**
- Use clear, concise language
- Include code examples where helpful
- Test all code snippets before submitting
- Follow the existing documentation style
- Use markdown linting and spell-check before opening a PR

---

## 🌐 Live Documentation

The documentation is automatically deployed and available at:
**https://liliaframework.github.io**

---

<p align="center">
  <strong>Ready to contribute to Lilia's documentation?</strong><br/>
  <a href="https://github.com/LiliaFramework/Lilia">Start contributing today!</a>
</p>
