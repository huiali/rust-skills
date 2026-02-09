# Rust Skills Git Submodule 使用指南

> 适用于团队协作，将 rust-skills 作为项目依赖管理

---

## 目录

- [什么是 Git Submodule](#什么是-git-submodule)
- [安装步骤](#安装步骤)
- [团队成员使用](#团队成员使用)
- [更新和维护](#更新和维护)
- [配置详解](#配置详解)
- [常见问题](#常见问题)
- [实战示例](#实战示例)

---

## 什么是 Git Submodule

Git Submodule 允许你将一个 Git 仓库作为另一个仓库的子目录，同时保持两者的提交历史独立。

**适用场景：**
- ✅ 团队协作项目
- ✅ 需要版本锁定
- ✅ 希望其他开发者自动获得技能
- ✅ 需要统一团队配置

**与全局安装的对比：**

| 特性 | Git Submodule | 全局安装 |
|-----|---------------|---------|
| 团队共享 | ✅ 自动同步 | ❌ 需手动配置 |
| 版本控制 | ✅ 锁定版本 | ❌ 各自更新 |
| 磁盘占用 | 每个项目一份 | 所有项目共享 |
| 配置复杂度 | 稍复杂 | 简单 |
| 适用场景 | 团队开发 | 个人开发 |

---

## 安装步骤

### 方式 1: 添加 Submodule 到现有项目

假设你的项目是 `moshu`，在项目根目录执行：

```bash
cd /path/to/moshu

# 添加 rust-skills 作为 submodule
git submodule add https://github.com/huiali/rust-skills.git .rust-skills

# 查看状态
git status
# 应该看到：
#   new file:   .gitmodules
#   new file:   .rust-skills
```

**目录结构：**

```
moshu/
├── .rust-skills/          # submodule 目录
│   ├── skills/
│   ├── references/
│   └── SKILL.md
├── .gitmodules            # submodule 配置
├── .claude/
│   └── settings.local.json
├── src/
├── Cargo.toml
└── README.md
```

### 方式 2: 自定义 Submodule 位置

```bash
# 放在 tools 目录下
git submodule add https://github.com/huiali/rust-skills.git tools/rust-skills

# 或放在隐藏目录
git submodule add https://github.com/huiali/rust-skills.git .skills/rust
```

### 配置 Claude Code

创建 `.claude/settings.local.json`：

```json
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
```

**重要：** 使用相对路径，因为 submodule 在项目内部。

### 提交到仓库

```bash
# 添加所有更改
git add .gitmodules .rust-skills .claude/settings.local.json

# 提交
git commit -m "Add rust-skills as submodule and configure Claude Code"

# 推送到远程
git push origin main
```

---

## 团队成员使用

### 新克隆项目

团队成员克隆你的项目时，需要初始化 submodule：

```bash
# 方式 1: 克隆时自动初始化 submodule（推荐）
git clone --recurse-submodules https://github.com/your-org/moshu.git

# 方式 2: 先克隆，再初始化
git clone https://github.com/your-org/moshu.git
cd moshu
git submodule update --init --recursive
```

### 验证安装

```bash
# 检查 submodule 状态
git submodule status

# 应该看到类似输出：
# a1b2c3d4 .rust-skills (v1.0.0)

# 验证技能目录
ls .rust-skills/skills/

# 测试 Claude Code
claude "列出所有 Rust 技能"
```

---

## 更新和维护

### 更新 Submodule

#### 1. 更新到最新版本

```bash
# 进入 submodule 目录
cd .rust-skills

# 拉取最新更改
git pull origin main

# 返回主项目
cd ..

# 提交 submodule 更新
git add .rust-skills
git commit -m "Update rust-skills to latest version"
git push
```

#### 2. 团队成员同步更新

```bash
# 拉取主项目更新
git pull

# 更新 submodule
git submodule update --remote --merge
```

#### 3. 锁定特定版本

```bash
# 进入 submodule
cd .rust-skills

# 切换到特定标签或提交
git checkout v1.2.0  # 或 git checkout a1b2c3d4

# 返回主项目并提交
cd ..
git add .rust-skills
git commit -m "Lock rust-skills to v1.2.0"
```

### 自动化更新脚本

创建 `scripts/update-skills.sh`：

```bash
#!/bin/bash

echo "🔄 更新 Rust Skills..."

# 进入 submodule
cd .rust-skills || exit 1

# 保存当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 切换到 main 并拉取
git checkout main
git pull origin main

# 显示更新内容
echo ""
echo "📝 最近更新："
git log --oneline -5

# 返回主项目
cd ..

# 提交更新
git add .rust-skills
echo ""
echo "✅ Rust Skills 已更新到最新版本"
echo "请运行: git commit -m 'Update rust-skills' && git push"
```

使用：

```bash
chmod +x scripts/update-skills.sh
./scripts/update-skills.sh
```

---

## 配置详解

### 基本配置

`.claude/settings.local.json`：

```json
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
```

### 高级配置

```json
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true,

  "mcpServers": {
    "rust-skill": {
      "command": "builtin",
      "description": "Rust programming expert system"
    }
  },

  "disabledSkills": [
    "rust-ebpf",
    "rust-gpu"
  ],

  "skillSettings": {
    "rust-ownership": {
      "verbosity": "detailed"
    },
    "rust-async": {
      "defaultRuntime": "tokio"
    }
  }
}
```

### 多环境配置

**开发环境** (`.claude/settings.dev.json`)：

```json
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true,
  "debugMode": true
}
```

**生产环境** (`.claude/settings.prod.json`)：

```json
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true,
  "disabledSkills": [
    "rust-learner",
    "rust-skill-index"
  ]
}
```

---

## 常见问题

### Q1: Submodule 目录是空的？

**原因：** 克隆时没有初始化 submodule。

**解决：**

```bash
git submodule update --init --recursive
```

### Q2: 如何删除 Submodule？

```bash
# 1. 删除 submodule 配置
git submodule deinit -f .rust-skills

# 2. 删除 .git/modules 中的内容
rm -rf .git/modules/.rust-skills

# 3. 删除工作目录
git rm -f .rust-skills

# 4. 提交更改
git commit -m "Remove rust-skills submodule"
```

### Q3: Submodule 显示 "modified" 但没修改？

**原因：** Submodule 的 HEAD 指向不同的提交。

**解决：**

```bash
# 重置 submodule
git submodule update --init

# 或者提交当前状态
git add .rust-skills
git commit -m "Update submodule reference"
```

### Q4: 团队成员无法更新 Submodule？

**检查步骤：**

1. 验证 .gitmodules 配置：
```bash
cat .gitmodules
```

应该包含：
```
[submodule ".rust-skills"]
    path = .rust-skills
    url = https://github.com/huiali/rust-skills.git
```

2. 更新配置：
```bash
git submodule sync
git submodule update --init --recursive
```

### Q5: 如何切换 Submodule 到 Fork 版本？

如果你 fork 了 rust-skills 并做了自定义修改：

```bash
# 1. 编辑 .gitmodules
nano .gitmodules

# 修改 url 为你的 fork
[submodule ".rust-skills"]
    path = .rust-skills
    url = https://github.com/your-username/rust-skills.git

# 2. 同步配置
git submodule sync

# 3. 更新
git submodule update --remote
```

---

## 实战示例

### 示例 1: moshu 项目完整配置

```bash
# 1. 进入项目
cd /path/to/moshu

# 2. 添加 submodule
git submodule add https://github.com/huiali/rust-skills.git .rust-skills

# 3. 创建配置目录
mkdir -p .claude

# 4. 创建配置文件
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    ".rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 5. 创建 README 说明
cat > .claude/README.md << 'EOF'
# Claude Code 配置

本项目使用 Rust Skills 作为 Git Submodule。

## 初始化

克隆项目后运行：
```bash
git submodule update --init --recursive
```

## 更新技能

```bash
./scripts/update-skills.sh
```
EOF

# 6. 提交所有更改
git add .gitmodules .rust-skills .claude
git commit -m "Add rust-skills submodule and Claude Code configuration"
git push
```

### 示例 2: 团队工作流

**项目维护者（你）：**

```bash
# 定期更新技能
cd .rust-skills
git pull origin main
cd ..
git add .rust-skills
git commit -m "Update rust-skills to latest version"
git push
```

**团队成员：**

```bash
# 克隆项目
git clone --recurse-submodules https://github.com/your-org/moshu.git
cd moshu

# 验证配置
claude "测试 Rust Skills"

# 日常更新
git pull
git submodule update --remote
```

### 示例 3: CI/CD 集成

`.github/workflows/ci.yml`：

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          submodules: recursive  # 重要：初始化 submodule

      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Verify Rust Skills
        run: |
          ls .rust-skills/skills
          echo "Found $(find .rust-skills/skills -name 'SKILL.md' | wc -l) skills"

      - name: Build
        run: cargo build --release

      - name: Test
        run: cargo test
```

### 示例 4: 自定义技能覆盖

如果你想在项目中添加自定义技能，同时保留 submodule：

```bash
# 创建项目专属技能目录
mkdir -p .local-skills

# 创建自定义技能
mkdir -p .local-skills/moshu-specific
cat > .local-skills/moshu-specific/SKILL.md << 'EOF'
---
name: moshu-specific
description: moshu 项目专属技能
---

# Moshu 专属技能

处理 moshu 项目特定的业务逻辑和架构问题。
EOF

# 配置多个技能目录
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    ".rust-skills/skills",
    ".local-skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 提交自定义技能（但不提交 submodule 内部修改）
git add .local-skills .claude/settings.local.json
git commit -m "Add project-specific skills"
```

---

## 最佳实践

### 1. 版本管理策略

**稳定项目：** 锁定 submodule 到特定版本

```bash
cd .rust-skills
git checkout v1.0.0  # 使用稳定版本标签
cd ..
git add .rust-skills
git commit -m "Lock rust-skills to v1.0.0"
```

**活跃项目：** 定期更新到最新版

```bash
# 每周更新
cd .rust-skills
git pull origin main
cd ..
git add .rust-skills
git commit -m "Update rust-skills (weekly update)"
```

### 2. README 文档模板

在项目 `README.md` 中添加：

```markdown
## 开发环境设置

### 1. 克隆项目

```bash
git clone --recurse-submodules https://github.com/your-org/moshu.git
cd moshu
```

如果已经克隆但没有 submodule：
```bash
git submodule update --init --recursive
```

### 2. 验证 Rust Skills

```bash
ls .rust-skills/skills
claude "测试 Rust Skills 配置"
```

### 3. 更新技能（可选）

```bash
./scripts/update-skills.sh
```
```

### 3. 忽略配置

`.gitignore`：

```gitignore
# Claude Code 个人配置（如果有）
.claude/settings.personal.json

# 不要忽略 settings.local.json，因为它对所有团队成员都一样
# .claude/settings.local.json  # 不要加这行
```

### 4. Makefile 快捷命令

`Makefile`：

```makefile
.PHONY: update-skills verify-skills

update-skills:
	@echo "Updating Rust Skills..."
	cd .rust-skills && git pull origin main
	git add .rust-skills
	@echo "Done. Run 'git commit' to save the update."

verify-skills:
	@echo "Verifying Rust Skills..."
	@test -d .rust-skills/skills || (echo "❌ Skills not found" && exit 1)
	@echo "✅ Found $$(find .rust-skills/skills -name 'SKILL.md' | wc -l) skills"
	@find .rust-skills/skills -name 'SKILL.md' | head -5 | while read f; do \
		echo "  - $$(basename $$(dirname $$f))"; \
	done
```

使用：

```bash
make verify-skills
make update-skills
```

---

## 总结

### Submodule 方式的优势

✅ **团队协作**
- 自动同步配置
- 统一技能版本
- 新成员开箱即用

✅ **版本控制**
- 可锁定特定版本
- 回滚方便
- 变更可追踪

✅ **项目自包含**
- 技能随项目分发
- 不依赖外部配置
- CI/CD 友好

### 关键配置要点

1. **添加 submodule**：
   ```bash
   git submodule add https://github.com/huiali/rust-skills.git .rust-skills
   ```

2. **配置使用相对路径**：
   ```json
   {
     "skillDirectories": [".rust-skills/skills"]
   }
   ```

3. **团队克隆使用**：
   ```bash
   git clone --recurse-submodules <repo-url>
   ```

4. **定期更新**：
   ```bash
   git submodule update --remote --merge
   ```

### 推荐项目结构

```
moshu/
├── .rust-skills/              # Git submodule
│   ├── skills/
│   └── references/
├── .claude/
│   ├── settings.local.json    # 提交到 Git
│   └── README.md              # 使用说明
├── scripts/
│   └── update-skills.sh       # 更新脚本
├── src/
├── Cargo.toml
├── .gitmodules                # Submodule 配置
└── README.md                  # 包含使用说明
```

现在你的团队可以统一使用 Rust Skills 了！🚀
