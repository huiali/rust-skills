# Rust Skill 使用指南（Codex）

> 本文档说明如何在 Codex 中使用 `rust-skills`，以及当前仓库的技能文件约定。

---

## 1. 当前约定（重要）

本仓库技能文件采用以下规则：

- 默认技能文件：`skills/<skill-name>/SKILL.md`（中文）
- 英文技能文件：`skills/<skill-name>/SKILL_EN.md`（英文）
- 历史中文备份（如存在）：`skills/<skill-name>/SKILL_ZH.md`

Codex 默认读取并触发 `SKILL.md`。

---

## 2. 在 Codex 中安装技能

### 方式 A：本地开发（推荐）

如果你正在这个仓库里直接使用 Codex，不需要额外安装。只要目录结构完整，Codex 就可以按技能描述自动触发。

### 方式 B：从 GitHub 安装到 Codex

将技能安装到 `~/.codex/skills`（Windows 下通常是 `C:\Users\<你>\.codex\skills`）：

```powershell
python C:\Users\Administrator\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py --repo <your-user-or-org>/rust-skills --path skills/rust-skill
```

安装后重启 Codex。

---

## 3. Codex 中如何触发技能

Codex 根据 `SKILL.md` frontmatter 的 `name` 与 `description` 自动判断是否触发。

你可以用两种方式：

### 自动触发（推荐）

直接描述问题：

- “帮我修复 Rust 的 E0382” -> 常触发 `rust-ownership`
- “tokio::spawn 里生命周期不满足” -> 常触发 `rust-concurrency` / `rust-async`
- “JWT 默认 EdDSA 怎么做” -> 常触发 `rust-auth`

### 显式指定技能

在提问里明确写：

- “使用 `rust-web` 帮我设计按领域聚合的项目结构”
- “请按 `rust-performance` 给这个函数做优化方案”

---

## 4. 技能组织建议（给维护者）

为了让 Codex 更稳定触发：

- `description` 要写清“做什么 + 什么时候用”
- 一个技能只解决一个主问题域
- 大量细节放在同目录补充文件，`SKILL.md` 保持可扫描
- 示例尽量可复制运行（含 `cargo check/test/clippy`）

---

## 5. 常见问题

### Q1：为什么技能没有触发？

优先检查：

1. `SKILL.md` frontmatter 是否有合法 `name/description`
2. 你的提问是否包含该技能的语义关键词
3. 是否被更匹配的技能抢占触发

可在提问中显式写技能名来强制路由。

### Q2：中文/英文版本怎么切换？

当前默认是中文 `SKILL.md`。

- 给人看英文：打开 `SKILL_EN.md`
- 给 Codex 默认触发：保持 `SKILL.md` 为你希望的主语言

### Q3：改完技能后不生效？

- 本地仓库模式：通常立即生效
- 安装到 `~/.codex/skills` 模式：更新后建议重启 Codex

---

## 6. 推荐提问模板

```text
请使用 rust-auth。
场景：Axum API，JWT 作为访问令牌，默认 EdDSA。
目标：给出签发、验签、中间件校验与密钥轮换策略。
约束：生产可用，包含错误处理和测试建议。
```

---

## 7. 仓库参考

- 主入口技能：`skills/rust-skill/SKILL.md`
- 技能索引：`skills/rust-skill-index/SKILL.md`
- Web 结构示例：`skills/rust-web/SKILL.md`
- 认证实践：`skills/rust-auth/SKILL.md`

---

MIT License
