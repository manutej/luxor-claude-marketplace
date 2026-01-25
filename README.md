# LUXOR Claude Code Marketplace

> Professional Claude Code plugins covering the complete software development lifecycle

[![Plugins](https://img.shields.io/badge/plugins-10-blue)](https://github.com/luxor/luxor-claude-marketplace)
[![Skills](https://img.shields.io/badge/skills-67-green)](https://github.com/luxor/luxor-claude-marketplace)
[![License](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

## 🌩️ LUXOR: Cheat Codes for Claude Code

> **"Don't just chat with code. Equip it."**

We've all been there. You ask Claude to scaffold a backend, and it gives you a generic Express server from 2021. You ask for a "modern" frontend, and it hallucinates a library that doesn't exist anymore.

**Claude is a genius, but it's a generalist.** It lacks the *domain-specific context*—the "muscle memory"—of a Senior Engineer who has spent 10 years in the trenches.

**We built this LUXOR plugin to fix that.**

Think of this repository as a curated collection of "Cheat Codes" (Plugins, Skills, Agents) that force Claude to adhere to **production-grade standards** across every part of the stack.

When you install these plugins, you aren't just adding tools. You are unlocking **God Mode** for specific domains.

---


## 🚀 Quick Start

### Install Entire Marketplace

```bash
# Clone marketplace
git clone https://github.com/luxor/luxor-claude-marketplace.git
cd luxor-claude-marketplace

# Install all plugins (one-liner)
for plugin in plugins/*/; do (cd "$plugin" && ./install.sh); done
```

### Install Individual Plugin

```bash
# Install just frontend skills
cd luxor-claude-marketplace/plugins/luxor-frontend-essentials
./install.sh

# Restart Claude Code
```

### Install Featured Bundle

```bash
# Install top 4 featured plugins
cd luxor-claude-marketplace/plugins
for plugin in luxor-frontend-essentials luxor-backend-toolkit luxor-devops-suite luxor-skill-builder; do
    (cd "$plugin" && ./install.sh)
done
```

---
## 🎮 Choose Your Skill Tree

I've organized the marketplace into specialized "cartridges" you can load into Claude. Install them all to become a full-stack army, or pick the specific cheat codes you need right now.

### 🎨 The Frontend Master

*Unlock the ability to ship pixel-perfect UIs without fighting the CSS.*

> **The Problem:** Claude struggles with consistent design systems and modern frameworks.
> **The Cheat Code:** `luxor-frontend-essentials`
> **Powers Unlocked:**
> * ⚡ **Next.js & React Patterns** that actually scale.
> * 📱 **Mobile-First Mental Models** injected directly into the agent.
> * 🎨 **Tailwind Wizardry** that avoids clutter.
> 
> 

### ⚙️ The Backend Architect

*Build systems that survive the "Hacker News Hug of Death".*

> **The Problem:** AI code is often insecure or unoptimized.
> **The Cheat Code:** `luxor-backend-toolkit`
> **Powers Unlocked:**
> * 🛡️ **Rust & Go** systems programming expertise.
> * 🕸️ **Microservices Architecture** (gRPC, GraphQL) best practices.
> * 🔐 **OAuth2 & Auth** flows that are actually secure.
> 
> 

### 🚀 The DevOps Commander

*Infrastructure as Code, minus the headache.*

> **The Problem:** Asking an LLM to write Terraform is usually a recipe for a broken state file.
> **The Cheat Code:** `luxor-devops-suite`
> **Powers Unlocked:**
> * 🐳 **Docker & K8s Orchestration** that works on the first try.
> * ☁️ **AWS Architecture** patterns (Standardized).
> * 🔄 **CI/CD Pipelines** that don't fail silently.
> 
> 

---

## ⚡ Quick Start: Activate Cheat Codes

You don't need to configure complex files. Just run the install script for the powers you want.

**1. Clone the Cartridge Library**

```bash
git clone https://github.com/luxor/luxor-claude-marketplace.git
cd luxor-claude-marketplace

```

**2. Load a Specific Cheat Code (e.g., Frontend)**

```bash
cd plugins/luxor-frontend-essentials
./install.sh

```

**3. Or... Unlock Everything (Full Stack God Mode)**

```bash
# Warning: This turns Claude into a beast.
for plugin in plugins/*/; do (cd "$plugin" && ./install.sh); done

```

---

## 🧠 The Meta-Layer: Build Your Own Cheats

The crown jewel of this repo is the **`luxor-skill-builder`**.

I realized that eventually, you'll want to teach Claude your *own* secret techniques. This plugin includes **30+ Agents** and **15 Workflows** designed specifically to help you author new skills.

* **The Architect Agent:** Helps you design the folder structure.
* **The Code Craftsman:** Writes the implementation.
* **The Doc Reviewer:** Ensures your new skill is readable by the AI.

It's meta-prompting, perfected.

---

## 🌟 Why This Matters

We are entering an era where the "Senior Engineer" isn't just the person who knows the syntax—it's the person who curates the best **context**.

LUXOR is our attempt to open-source that context. It's the result of hundreds of hours of prompt engineering, distilled into installable packages.

**Stop fighting the prompt. Load the cheat code. Ship the product.**

---

### 🤝 Join the Party

Found a glitch in the matrix? Have a better cheat code?

* [Open an Issue](https://www.google.com/search?q=issues)
* [Submit a PR](https://www.google.com/search?q=pulls)

*Built with 💜 and too much caffeine by ManuTej.*

---
## 🌟 Overview

The **LUXOR Claude Code Marketplace** is a curated collection of 10 professional plugins containing **67+ production-grade skills**, **28 commands**, **30 agents**, and **15 workflows** covering every aspect of modern software development.

Built from real-world development experience, these plugins provide Claude Code with expert-level knowledge across:

- 🎨 **Frontend Development** (React, Next.js, Angular, Vue, Svelte)
- ⚙️ **Backend Development** (FastAPI, Express, Node.js, Go, Rust)
- 🗄️ **Database Engineering** (PostgreSQL, SQLAlchemy, Redis)
- 🚀 **DevOps & Cloud** (Docker, Kubernetes, AWS, Terraform)
- 📊 **Data Engineering** (Airflow, Spark, Kafka, dbt)
- ✅ **Testing & QA** (pytest, test automation)
- 🤖 **AI Integration** (LangChain, Claude SDK)
- 🎨 **Design & UX** (Figma, wireframing)
- 🛠️ **Specialized Tools** (Playwright, Linear, asyncio)
- ⚡ **Meta Tools** (Skill building, plugin creation)

---


## 📦 Available Plugins

### 🎨 Frontend Development

#### **luxor-frontend-essentials** ⭐ Featured
**13 Skills** | React, Next.js, Angular, Vue, Svelte, Tailwind CSS

Complete frontend development toolkit covering all major frameworks, JavaScript fundamentals, responsive design, UI patterns, and Jest testing.

```bash
cd plugins/luxor-frontend-essentials && ./install.sh
```

**Includes**:
- react-development, react-patterns
- nextjs-development
- angular-development, svelte-development, vuejs-development
- tailwind-css, javascript-fundamentals
- frontend-architecture, responsive-design
- ui-design-patterns, mobile-design
- jest-react-testing

---

### ⚙️ Backend Development

#### **luxor-backend-toolkit** ⭐ Featured
**14 Skills** | FastAPI, Express, Node.js, Go, Rust, GraphQL

Comprehensive backend development covering Python, JavaScript, Go, Java, and Rust with REST, GraphQL, gRPC, and OAuth2.

```bash
cd plugins/luxor-backend-toolkit && ./install.sh
```

**Includes**:
- fastapi, fastapi-development, fastapi-microservices-development
- expressjs-development, express-microservices-architecture
- nodejs-development, golang-backend-development
- spring-boot-development, axum-web-framework, rust-systems-programming
- graphql-api-development, rest-api-design-patterns
- grpc-microservices, oauth2-authentication

---

### 🗄️ Database & Data

#### **luxor-database-pro**
**9 Skills** | PostgreSQL, SQLAlchemy, Alembic, pandas, Redis

Professional database engineering and data management skills.

```bash
cd plugins/luxor-database-pro && ./install.sh
```

**Includes**:
- postgresql, postgresql-database-engineering
- psycopg, sqlalchemy, alembic
- pandas, redis-state-management
- vector-database-management, database-management-patterns

---

### 🚀 DevOps & Infrastructure

#### **luxor-devops-suite** ⭐ Featured
**12 Skills** | Docker, Kubernetes, AWS, Terraform, CI/CD

Complete DevOps lifecycle from containerization to monitoring.

```bash
cd plugins/luxor-devops-suite && ./install.sh
```

**Includes**:
- docker-compose-orchestration, kubernetes-orchestration
- aws-cloud-architecture, aws-cloud-services
- terraform-infrastructure, terraform-infrastructure-as-code
- ci-cd-pipeline-patterns, observability-monitoring
- microservices-patterns, enterprise-architecture-patterns
- api-gateway-patterns, hasura-graphql-engine

---

### 📊 Data Engineering & ML

#### **luxor-data-engineering**
**5 Skills** | Airflow, Spark, Kafka, dbt, MLOps

Data pipeline and ML workflow orchestration.

```bash
cd plugins/luxor-data-engineering && ./install.sh
```

**Includes**:
- apache-airflow-orchestration, apache-spark-data-processing
- kafka-stream-processing, dbt-data-transformation
- mlops-workflows

---

### ✅ Testing & QA

#### **luxor-testing-essentials**
**3 Skills** | pytest, pytest patterns, shell testing

Comprehensive testing frameworks and patterns.

```bash
cd plugins/luxor-testing-essentials && ./install.sh
```

**Includes**:
- pytest, pytest-patterns
- shell-testing-framework

---

### 🤖 AI & Integration

#### **luxor-ai-integration**
**2 Skills** | LangChain, Claude SDK

AI and LLM application development.

```bash
cd plugins/luxor-ai-integration && ./install.sh
```

**Includes**:
- langchain-orchestration
- claude-sdk-integration-patterns

---

### 🎨 Design & UX

#### **luxor-design-toolkit**
**4 Skills** | Figma, UX, wireframing, performance

Design tools and user experience patterns.

```bash
cd plugins/luxor-design-toolkit && ./install.sh
```

**Includes**:
- figma-design, wireframing
- ux-principles, performance-benchmark-specialist

---

### 🛠️ Specialized Tools

#### **luxor-specialized-tools**
**5 Skills** | Playwright, Linear, asyncio, Pydantic

Specialized developer tools and utilities.

```bash
cd plugins/luxor-specialized-tools && ./install.sh
```

**Includes**:
- playwright-visual-testing, linear-dev-accelerator
- asyncio-concurrency-patterns, unix-goto-development
- pydantic

---

### ⚡ Meta & Builder Tools

#### **luxor-skill-builder** ⭐ Featured
**28 Commands** | **30 Agents** | **15 Workflows**

Complete meta tools for creating and managing Claude Code skills, commands, agents, and workflows - essential for plugin creators.

```bash
cd plugins/luxor-skill-builder && ./install.sh
```

**Includes**:
- **28 Commands**: agent, agentinfo, aprof, call-claude, context-budget, coord, create-command, crew, ctx7, current, deep, diagram-coordinator, diagram-from-file, diagram-from-url, docrag, educational-flowchart, foreach, inherit, learn, meta-agent, orch, research, sdk, summarize, tax, wflw, workflows, yt
- **30 Agents**: api-architect, astro-data-manager, claude-sdk-expert, code-craftsman, code-trimmer, context7-doc-reviewer, coverage-analyzer, debug-detective, deep-researcher, deployment-orchestrator, devops-github-expert, doc-rag-builder, docs-generator, flutter-app-builder, frontend-architect, git-genius, github-workflow-expert, linear-mcp-orchestrator, mcp-integration-wizard, mercurio-orchestrator, practical-programmer, project-orchestrator, tax-analyst, test-engineer, test-runner, unix-bash-expert, unix-command-master, voice-mode-orchestrator, wikijs-graphql-orchestrator, youtube-summarizer
- **15 Workflows**: api-development, app-developer, bug-investigation-fix, claude-sdk-integration, code-refactoring-pipeline, flutter-firebase-app, frontend-feature-complete, github-workflow-setup, linear-project-development, mcp-integration-complete, project-status-review, research-to-documentation, unix-command-mastery, unix-goto-skill-development, youtube-content-analysis

---



## 📊 Statistics

- **Total Plugins**: 10
- **Total Skills**: 67
- **Total Commands**: 28
- **Total Agents**: 30
- **Total Workflows**: 15
- **Categories**: 10
- **Featured Plugins**: 4
- **Total Items**: 140 professional development tools

### Coverage by Domain

| Domain | Skills | Plugin |
|--------|--------|--------|
| Frontend | 13 | luxor-frontend-essentials |
| Backend | 14 | luxor-backend-toolkit |
| Database | 9 | luxor-database-pro |
| DevOps | 12 | luxor-devops-suite |
| Data Engineering | 5 | luxor-data-engineering |
| Testing | 3 | luxor-testing-essentials |
| AI | 2 | luxor-ai-integration |
| Design | 4 | luxor-design-toolkit |
| Tools | 5 | luxor-specialized-tools |
| Meta | 28 commands + 30 agents + 15 workflows | luxor-skill-builder |

---

## 🎯 Use Cases

### Full-Stack Web Developer
```bash
# Install frontend + backend + database
luxor-frontend-essentials + luxor-backend-toolkit + luxor-database-pro
```

### DevOps Engineer
```bash
# Install DevOps + database + testing
luxor-devops-suite + luxor-database-pro + luxor-testing-essentials
```

### Data Engineer
```bash
# Install data engineering + database
luxor-data-engineering + luxor-database-pro
```

### Plugin Creator
```bash
# Install skill builder tools
luxor-skill-builder
```

### Complete Professional Setup
```bash
# Install everything
All 10 plugins for comprehensive coverage
```

---

## 📚 Documentation

### Plugin Documentation
Each plugin includes:
- `README.md` - Plugin overview and usage
- `.claude-plugin/plugin.json` - Plugin manifest
- `install.sh` - Installation script
- `uninstall.sh` - Removal script

### Skill Documentation
Each skill includes:
- `SKILL.md` - Main skill definition with YAML frontmatter
- `README.md` - Skill overview and examples
- `EXAMPLES.md` - Detailed code examples (when applicable)

### Marketplace Documentation
- [MARKETPLACE_DESIGN.md](/MARKETPLACE_DESIGN.md) - Design and architecture
- [INSTALL.md](/INSTALL.md) - Installation guide
- [CONTRIBUTING.md](/CONTRIBUTING.md) - Contribution guidelines

---

## 🔄 Updating

### Update All Plugins

```bash
cd luxor-claude-marketplace
git pull origin main
for plugin in plugins/*/; do (cd "$plugin" && ./install.sh); done
```

### Update Individual Plugin

```bash
cd luxor-claude-marketplace/plugins/luxor-frontend-essentials
git pull
./install.sh
```

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute

1. **Report Issues** - Found a bug? Open an issue
2. **Suggest Skills** - Have ideas for new skills? Let us know
3. **Submit PRs** - Improve existing skills or add new ones
4. **Share Feedback** - Help us improve the marketplace

---

## 📝 License

MIT © LUXOR

All plugins and skills are released under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🌟 Featured Plugins

### Why These Are Featured

1. **luxor-frontend-essentials** - Most comprehensive frontend coverage (13 skills)
2. **luxor-backend-toolkit** - Largest backend toolkit (14 skills)
3. **luxor-devops-suite** - Complete DevOps lifecycle (12 skills)
4. **luxor-skill-builder** - Essential for plugin creators

---

## 🎓 Learning Path

### Beginner Path
1. Start with `luxor-frontend-essentials` or `luxor-backend-toolkit`
2. Add `luxor-database-pro` for data skills
3. Expand with `luxor-testing-essentials`

### Intermediate Path
1. Install featured bundle (4 plugins)
2. Add specialized plugins based on your stack
3. Use `luxor-skill-builder` to create custom skills

### Advanced Path
1. Install all 10 plugins
2. Master `luxor-skill-builder` for plugin creation
3. Contribute back to the marketplace

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/luxor/luxor-claude-marketplace/issues)
- **Discussions**: [GitHub Discussions](https://github.com/luxor/luxor-claude-marketplace/discussions)
- **Email**: manu@luxor.dev

---

## 🚦 Status

✅ **Production Ready** - All plugins tested and stable

| Plugin | Status | Version |
|--------|--------|---------|
| luxor-frontend-essentials | ✅ Stable | 1.0.0 |
| luxor-backend-toolkit | ✅ Stable | 1.0.0 |
| luxor-database-pro | ✅ Stable | 1.0.0 |
| luxor-devops-suite | ✅ Stable | 1.0.0 |
| luxor-data-engineering | ✅ Stable | 1.0.0 |
| luxor-testing-essentials | ✅ Stable | 1.0.0 |
| luxor-ai-integration | ✅ Stable | 1.0.0 |
| luxor-design-toolkit | ✅ Stable | 1.0.0 |
| luxor-specialized-tools | ✅ Stable | 1.0.0 |
| luxor-skill-builder | ✅ Stable | 1.0.0 |

---

## 🎉 Acknowledgments

Built with:
- [Claude Code](https://claude.com/claude-code) - Official Anthropic CLI
- `/meta-skill-builder` - Parallel skill building with Context7
- Context7 MCP - Library documentation research
- Linear MCP - Project tracking integration

---

**LUXOR Claude Code Marketplace - Empowering developers with professional-grade skills** 🚀

Last Updated: 2025-10-18
