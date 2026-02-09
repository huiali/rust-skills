# Rust Skills 使用指南

> 如何在你的 Rust 项目中使用 Rust Skills

---

## 选择安装方式

根据你的使用场景选择合适的安装方式：

| 场景 | 推荐方式 | 文档 |
|-----|---------|------|
| 个人开发，多个 Rust 项目 | **全局安装** | [USAGE_GLOBAL.md](./USAGE_GLOBAL.md) |
| 团队协作，需要统一配置 | **Git Submodule** | [USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md) |
| 专门为 Claude Code 使用 | **Claude Code 集成** | [CLAUDE_CODE_GUIDE.md](./CLAUDE_CODE_GUIDE.md) |

---

## 快速决策树

```
你是否在团队中协作？
├─ 是 → 使用 Git Submodule 方式
│        📖 查看：USAGE_SUBMODULE.md
│
└─ 否 → 你有多个 Rust 项目吗？
         ├─ 是 → 使用全局安装方式
         │        📖 查看：USAGE_GLOBAL.md
         │
         └─ 否 → 使用 Git Submodule 或全局安装
                  📖 查看：USAGE_GLOBAL.md 或 USAGE_SUBMODULE.md
```

---

## 方式对比

### 1. 全局安装方式

**适合：** 个人开发者，多项目场景

```bash
# 安装一次
~/rust-skills/

# 所有项目配置
moshu/.claude/settings.local.json → 指向 ~/rust-skills/skills
project2/.claude/settings.local.json → 指向 ~/rust-skills/skills
project3/.claude/settings.local.json → 指向 ~/rust-skills/skills
```

**优势：**
- ✅ 一次安装，所有项目受益
- ✅ 节省磁盘空间
- ✅ 统一更新，版本一致
- ✅ 配置简单

**劣势：**
- ❌ 每个项目需要单独配置
- ❌ 团队成员需要手动安装
- ❌ 路径可能因人而异

📖 **详细文档：** [USAGE_GLOBAL.md](./USAGE_GLOBAL.md)

---

### 2. Git Submodule 方式

**适合：** 团队协作，需要版本控制

```bash
# 作为项目的一部分
moshu/
├── .rust-skills/          # Git submodule
├── .claude/
│   └── settings.local.json  # 相对路径 ".rust-skills/skills"
└── src/
```

**优势：**
- ✅ 团队自动同步
- ✅ 版本锁定，稳定可靠
- ✅ 新成员克隆即用
- ✅ CI/CD 友好

**劣势：**
- ❌ 每个项目占用磁盘空间
- ❌ Submodule 管理稍复杂
- ❌ 更新需要额外步骤

📖 **详细文档：** [USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md)

---

## 快速开始

### 全局安装（5 分钟）

```bash
# 1. 克隆到全局位置
cd ~
git clone https://github.com/huiali/rust-skills.git

# 2. 进入你的项目
cd /path/to/your-project

# 3. 创建配置
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    "~/rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 4. 测试
claude "列出所有 Rust 技能"
```

---

### Git Submodule（5 分钟）

```bash
# 1. 在项目中添加 submodule
cd /path/to/your-project
git submodule add https://github.com/huiali/rust-skills.git .rust-skills

# 2. 创建配置
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 3. 提交
git add .gitmodules .rust-skills .claude
git commit -m "Add rust-skills submodule"

# 4. 测试
claude "列出所有 Rust 技能"
```

---

## 常见使用场景

### 场景 1: 个人开发，有 3 个 Rust 项目

**推荐：** 全局安装

```bash
# 安装一次
~/rust-skills/

# 每个项目配置一次
cd ~/projects/moshu && <配置>
cd ~/projects/blog && <配置>
cd ~/projects/tools && <配置>
```

📖 详见：[USAGE_GLOBAL.md](./USAGE_GLOBAL.md)

---

### 场景 2: 公司团队项目，5 个开发者

**推荐：** Git Submodule

```bash
# 你（维护者）添加 submodule
git submodule add ... .rust-skills
git commit && git push

# 团队成员
git clone --recurse-submodules <repo>
# 自动获得配置
```

📖 详见：[USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md)

---

### 场景 3: 开源项目，希望贡献者使用

**推荐：** Git Submodule + 文档说明

在 `README.md` 中说明：

```markdown
## 开发环境

本项目使用 Rust Skills 增强 AI 辅助开发。

克隆项目时使用：
\```bash
git clone --recurse-submodules <repo-url>
\```

或手动初始化：
\```bash
git submodule update --init --recursive
\```
```

📖 详见：[USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md)

---

## 针对 moshu 项目的建议

根据你的情况：

### 如果 moshu 是个人项目

**推荐全局安装：**

```bash
# rust-skills 已在 D:\github\rust-skills

# 在 moshu 项目配置
cd D:\projects\moshu
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    "D:/github/rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 添加到 .gitignore
echo ".claude/settings.local.json" >> .gitignore
```

### 如果 moshu 是团队项目

**推荐 Git Submodule：**

```bash
cd D:\projects\moshu

# 添加 submodule
git submodule add https://github.com/huiali/rust-skills.git .rust-skills

# 配置（使用相对路径）
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 提交
git add .gitmodules .rust-skills .claude
git commit -m "Add rust-skills submodule and Claude Code configuration"
```

---

## 文档索引

### 基础文档
- [README.md](./README.md) - 项目概述
- [SKILL.md](./SKILL.md) - 主技能入口
- [USER_GUIDE.md](./USER_GUIDE.md) - 通用用户指南

### 使用文档（⭐ 重点）
- [USAGE_GLOBAL.md](./USAGE_GLOBAL.md) - **全局安装详细指南**
- [USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md) - **Git Submodule 详细指南**
- [CLAUDE_CODE_GUIDE.md](./CLAUDE_CODE_GUIDE.md) - Claude Code 专用指南

### 语言版本
- 中文版：USAGE_GLOBAL.md, USAGE_SUBMODULE.md
- English: CLAUDE_CODE_GUIDE.md

---

## 快速问答

### Q: 我应该选哪种方式？

**A:**
- 个人开发 → 全局安装（简单方便）
- 团队协作 → Git Submodule（统一管理）

### Q: 两种方式可以共存吗？

**A:** 可以。你可以：
- 全局安装用于个人项目
- 某些团队项目用 Submodule

### Q: 如何从一种方式切换到另一种？

**A:**
- 全局 → Submodule：添加 submodule，修改配置路径
- Submodule → 全局：删除 submodule，克隆到全局位置，修改配置路径

详细步骤见各自的文档。

### Q: Windows 路径如何写？

**A:**
- 全局安装：使用 `/` 替代 `\`
  ```json
  "D:/github/rust-skills/skills"  // ✅
  "D:\\github\\rust-skills\\skills"  // ❌
  ```
- Submodule：使用相对路径
  ```json
  ".rust-skills/skills"  // ✅
  ```

### Q: 配置文件应该提交到 Git 吗？

**A:**
- 全局安装：**不提交**（路径因人而异），添加到 `.gitignore`
- Submodule：**提交**（路径相对，所有人一样）

---

## 获取帮助

- **GitHub Issues**: https://github.com/huiali/rust-skills/issues
- **Discussions**: https://github.com/huiali/rust-skills/discussions
- **文档问题**: 在相应文档下提 Issue

---

## 下一步

1. 根据场景选择安装方式
2. 阅读对应的详细文档
3. 完成配置并测试
4. 在项目中使用 Claude Code + Rust Skills

**祝你编码愉快！** 🚀
