# 引导式学习技能

> **对标 Google Gemini 引导式学习** — 苏格拉底式问题引导，帮助学生通过提问发现答案，而非直接给出解答。

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![OpenCode](https://img.shields.io/badge/OpenCode-Compatible-green.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)]()

**中文文档** | **[English](README.md)**

---

## 为什么选择这个 Skill？

传统的 AI 辅导往往直接给出答案，这不利于学生真正学习。本技能实现了 **Gemini 引导式学习方法论**：

1. **肯定与定位** — 先验证学生思路的正确部分
2. **创造认知冲突** — 引导学生自我纠正，而非直接纠错
3. **提供微型脚手架** — 根据卡住程度动态调整提示强度
4. **尝试性提问** — 引导下一步思考

**结果：** 学生自己发现解决方案，建立更深刻的理解。

---

## 快速开始

### 安装

**方式一：一键安装（推荐）**

```bash
# OpenCode / Claude Code
curl -fsSL https://raw.githubusercontent.com/GlacierXiaowei/guided-learning-skill/main/install.sh | bash
```

**方式二：手动安装**

```bash
# 克隆仓库
git clone https://github.com/GlacierXiaowei/guided-learning-skill.git

# 复制到 skills 目录
cp -r guided-learning-skill ~/.config/opencode/skills/
```

**方式三：npm（即将推出）**

```bash
npm install -g @glacierxiaowei/guided-learning-skill
```

### 使用

直接发送数学题目，AI 会自动使用苏格拉底式引导：

```
求函数 f(x) = x³ - 3x 的极值
```

**AI 响应示例：**
> 让我一步步引导你解决这个问题。
>
> 首先，你能回忆一下求函数极值的一般方法吗？

---

## 功能特点

| 特性 | 描述 |
|------|------|
| **苏格拉底式提问** | 通过引导性问题发现解决方案，而非直接给答案 |
| **动态脚手架** | 根据学生理解程度调整提示强度 |
| **认知冲突引导** | 帮助学生自我纠正错误认知 |
| **智能降级** | 连续卡住时提供更直接的提示 |
| **MCP 集成** | 复杂问题自动调用 MCP 工具（多解法、竞赛题） |
| **模式切换** | 无缝切换到结构化学习模式进行概念复习 |

---

## 演示

### 场景：求函数极值

**学生：** 求函数 f(x) = x³ - 3x 的极值

**AI（引导式学习）：**
> 这个题目涉及求函数极值的问题。让我们一步步思考。
>
> 首先，你能回忆一下求函数极值的一般步骤是什么吗？

**学生：** 求导，令导数等于 0

**AI：**
> 完全正确！那 f'(x) 等于什么？

**学生：** 3x² - 3

**AI：**
> 很好！现在令 f'(x) = 0，解出 x，你得到什么？

*(对话继续，AI 引导每一步...)*

---

## 与 structured-learning 的区别

| | guided-learning | structured-learning |
|---|---|---|
| **用途** | 引导做题 | 知识点学习 |
| **触发** | 发送题目 | 说"使用结构化学习" |
| **风格** | 苏格拉底式提问 | 系统讲解 |
| **场景** | 解题过程 | 概念理解、考试复习 |

**切换模式：**
```
使用结构化学习
```

---

## 架构设计

```
guided-learning-skill/
├── SKILL.md           # 核心技能指令
├── README.md          # 英文文档
├── README-zh.md       # 中文文档（本文件）
├── LICENSE            # Apache 2.0
├── install.sh         # 一键安装脚本
└── assets/            # 截图和演示
```

### 核心方法论

基于 **Gemini 引导式学习** 对标设计：

```
┌─────────────────────────────────────────────────────┐
│  1. 肯定与定位                                       │
│     ↓ 验证学生做对的部分                              │
│  2. 创造认知冲突                                      │
│     ↓ 指出不一致，让学生自我纠正                        │
│  3. 提供微型脚手架                                    │
│     ↓ 动态调整提示强度                                 │
│  4. 尝试性提问                                       │
│     → 引导下一步思考                                  │
└─────────────────────────────────────────────────────┘
```

### MCP 使用判断

技能内置 MCP 使用判断标准，避免过度工程化：

| 场景 | 是否使用 MCP |
|------|-------------|
| 常规计算题 | ❌ 否 |
| 标准题型（求极值、单调区间） | ❌ 否 |
| 多解法探索题 | ✅ 是 |
| 跨章节综合题 | ✅ 是 |
| 竞赛/压轴题 | ✅ 是 |
| 学生连续卡住 5 次以上 | ✅ 是 |

---

## 安装验证

安装后，发送以下消息测试：

```
求函数 f(x) = x² - 4x + 3 的最小值
```

如果 AI 以提问方式引导而非直接给答案，说明安装成功！

---

## 关于作者

**冰川小未 (Xiaowei Glacier)**

- 🎓 **天津大学** 2025 级本科生
- 📍 来自中国四川
- 💻 主修 **计算机科学与技术**
- 🌟 对一切有趣的事物感到好奇！

**为什么制作这个 Skill：**

我一直在用复杂的提示词让 AI 辅导我学习。AI 进行这种规范化且机械的行为正好可以做成 Skill。同时网络上也很少有这类 Skill，因此我满怀期待地孕育了它！感谢你们的支持！

**联系方式：** glacier_xiaowei@163.com

---

## 贡献指南

欢迎贡献！请遵循以下规则：

### 如何贡献

1. **Fork 本仓库**
2. **创建功能分支**：`git checkout -b feature/amazing-feature`
3. **进行修改**
4. **提交 Pull Request**

### 重要规则

- ❌ **禁止直接提交到 `main` 分支**
- ✅ **所有更改必须通过 Pull Request**
- ✅ **PR 需要至少 1 人审批才能合并**
- ❌ **强制推送已被禁用**

> 如果你有新颖的想法，我们可以一起构建一个分支，来支持更棒的创意！

### 开发环境

```bash
git clone https://github.com/GlacierXiaowei/guided-learning-skill.git
cd guided-learning-skill
# 进行修改
# 本地测试：复制到 ~/.config/opencode/skills/
```

---

## 路线图

- [ ] npm 包发布
- [ ] 更多语言翻译（日语、韩语等）
- [ ] 集成更多 AI 平台
- [ ] SuperAcademicStudy 技能（整合 guided-learning + structured-learning）
- [ ] 图形题目支持（几何、图像）

---

## 致谢

- 方法论设计参考 **Google Gemini 引导式学习**
- 兼容 **Anthropic Agent Skills** 规范
- 受 **OpenCode** 社区启发

---

## 许可证

Apache License 2.0 — 详见 [LICENSE](LICENSE)

---

<p align="center">
  <b>由冰川小未用 ❤️ 制作</b>
</p>