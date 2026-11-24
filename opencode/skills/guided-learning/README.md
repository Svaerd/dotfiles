# guided-learning-skill

> **Bring Gemini-level guided learning to your AI assistant** — A Socratic-style problem-solving skill that guides students to discover solutions through questioning, dynamic scaffolding, and cognitive conflict resolution.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![npm](https://img.shields.io/npm/v/guided-learning-skill.svg)](https://www.npmjs.com/package/guided-learning-skill)
[![OpenCode](https://img.shields.io/badge/OpenCode-Compatible-green.svg)]()

**[中文文档](README-zh.md)** | **English**

---

## Why This Skill?

Traditional AI tutors often give direct answers, which doesn't help students truly learn. This skill implements the **Gemini Guided Learning methodology**:

1. **Affirm & Locate** — Validate the correct parts of student's thinking
2. **Create Cognitive Conflict** — Guide students to self-correct, not direct correction
3. **Provide Micro-Scaffolds** — Dynamically adjust hint intensity based on stuck level
4. **Probing Questions** — Guide the next step of thinking

**Result:** Students discover solutions themselves, building deeper understanding.

---

## Quick Start

### Install

**Method 1: One-line Install (Recommended)**

```bash
# OpenCode / Claude Code
curl -fsSL https://raw.githubusercontent.com/GlacierXiaowei/guided-learning-skill/main/install.sh | bash
```

**Method 2: Manual Install**

```bash
# Clone the repository
git clone https://github.com/GlacierXiaowei/guided-learning-skill.git

# Copy to skills directory
cp -r guided-learning-skill ~/.config/opencode/skills/
```

**Method 3: npm**

```bash
npm install -g guided-learning-skill
```

### Usage

Just send a math problem, and the AI will guide you step by step:

```
Find the extrema of f(x) = x³ - 3x
```

**AI Response (Socratic):**
> Let's work through this together. To find function extrema, we typically follow three steps: differentiate, find critical points, and classify.
>
> 💡 **Core Concept**: Extrema occur where the derivative equals zero (horizontal tangent).
>
> 🔍 **Step 1**: First, can you find the derivative f'(x)?

---

## Features

| Feature | Description |
|---------|-------------|
| **Socratic Questioning** | Guide students to discover solutions through questions, not direct answers |
| **Dynamic Scaffolding** | 4-level hint intensity based on student understanding |
| **Cognitive Conflict** | Help students self-correct misconceptions |
| **Smart Degradation** | Provide more direct hints when student is stuck (3+ errors) |
| **MCP Integration** | Auto-invoke MCP tools for complex problems (multi-solution, competition) |
| **Mode Switching** | Seamlessly switch to structured-learning for concept review |

---

## Demo

### Scenario: Finding Function Extrema

**Student:** Find the extrema of f(x) = x³ - 3x

**AI (Guided Learning):**
> This problem involves finding function extrema. Let's think step by step.
>
> First, can you recall the general steps for finding function extrema?

**Student:** Differentiate, set derivative equal to 0

**AI:**
> Exactly right! What is f'(x)?

**Student:** 3x² - 3

**AI:**
> Great! Now set f'(x) = 0 and solve for x. What do you get?

*(Conversation continues, AI guides each step...)*

---

## Difference from structured-learning

| | guided-learning | structured-learning |
|---|---|---|
| **Purpose** | Guided problem-solving | Knowledge learning |
| **Trigger** | Send a problem | Say "use structured learning" |
| **Style** | Socratic questioning | Systematic teaching |
| **Use Case** | Solving problems | Concept understanding, exam review |

**Switch modes:**
```
Use structured learning
```

---

## Architecture

```
guided-learning-skill/
├── SKILL.md           # Core skill instructions
├── README.md          # English documentation
├── README-zh.md       # Chinese documentation
├── LICENSE            # Apache 2.0
├── install.sh         # One-line install script
├── package.json       # npm configuration
└── assets/            # Screenshots and demos
```

### Core Methodology

Based on **Gemini Guided Learning** benchmark:

```
┌─────────────────────────────────────────────────────┐
│  1. Affirm & Locate                                  │
│     ↓ Validate what student did correctly           │
│  2. Create Cognitive Conflict                        │
│     ↓ Point out inconsistency, let student self-correct │
│  3. Provide Micro-Scaffold                           │
│     ↓ Dynamically adjust hint intensity              │
│  4. Probing Question                                 │
│     → Guide next step of thinking                    │
└─────────────────────────────────────────────────────┘
```

### MCP Usage Decision

Built-in MCP usage criteria to avoid over-engineering:

| Scenario | Use MCP? |
|----------|----------|
| Standard calculation (differentiation, integration) | ❌ No |
| Standard problems (extrema, monotonicity, tangents) | ❌ No |
| Multi-solution exploration | ✅ Yes |
| Cross-chapter synthesis | ✅ Yes |
| Competition/challenge problems | ✅ Yes |
| Student stuck 5+ times | ✅ Yes |

---

## Installation Verification

After installation, test with:

```
Find the minimum of f(x) = x² - 4x + 3
```

If AI guides with questions instead of giving direct answers, installation successful!

---

## About the Author

**Xiaowei Glacier**

- 🎓 **Tianjin University**, Class of 2025
- 📍 From Sichuan, China
- 💻 Major in **Computer Science & Technology**
- 🌟 Curious about everything interesting!

**Why I made this Skill:**

I've been using complex prompts to have AI tutor my learning. AI performing this kind of standardized and mechanical behavior is perfect for making into a Skill. There are also few such Skills on the web, so I created it with great anticipation! Thanks for your support!

**Contact:** glacier_xiaowei@163.com

---

## Contributing

Contributions welcome! Please follow these rules:

### How to Contribute

1. **Fork this repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Make changes**
4. **Submit Pull Request**

### Important Rules

- ❌ **Do NOT commit directly to `main` branch**
- ✅ **All changes must go through Pull Request**
- ✅ **PR requires at least 1 approval to merge**
- ❌ **Force pushes are disabled**

### Development Environment

```bash
git clone https://github.com/GlacierXiaowei/guided-learning-skill.git
cd guided-learning-skill
# Make changes
# Local test: copy to ~/.config/opencode/skills/
```

---

## Roadmap

- [ ] npm package publish
- [ ] More language translations (Japanese, Korean, etc.)
- [ ] Integration with more AI platforms
- [ ] SuperAcademicStudy skill (combine guided-learning + structured-learning)
- [ ] Graph problem support (geometry, images)

---

## Acknowledgments

- Methodology design references **Google Gemini Guided Learning**
- Compatible with **Anthropic Agent Skills** specification
- Inspired by **OpenCode** community

---

## License

Apache License 2.0 — See [LICENSE](LICENSE)

---

<p align="center">
  <b>Made with ❤️ by Xiaowei Glacier</b>
</p>