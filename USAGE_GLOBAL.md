# Rust Skills 全局安装使用指南

> 适用于个人开发者，所有 Rust 项目共享一套技能系统

---

## 目录

- [安装步骤](#安装步骤)
- [在项目中配置](#在项目中配置)
- [路径索引详解](#路径索引详解)
- [使用方法](#使用方法)
- [常见问题](#常见问题)
- [实战示例](#实战示例)

---

## 安装步骤

### 1. 选择全局安装位置

选择一个固定的位置存放 rust-skills，推荐以下位置：

**Linux/macOS:**
```bash
# 方式 1: 放在用户主目录
~/rust-skills

# 方式 2: 放在工具目录
~/tools/rust-skills

# 方式 3: 放在开发目录
~/dev/rust-skills
```

**Windows:**
```bash
# 方式 1: 放在用户目录
C:\Users\YourName\rust-skills

# 方式 2: 放在开发工具目录
D:\tools\rust-skills

# 方式 3: 放在 GitHub 目录（如你当前的位置）
D:\github\rust-skills
```

### 2. 克隆仓库

```bash
# Linux/macOS 示例
cd ~
git clone https://github.com/huiali/rust-skills.git

# Windows 示例（假设安装到 D:\tools）
cd D:\tools
git clone https://github.com/huiali/rust-skills.git

# 你当前的位置（已经克隆了）
# D:\github\rust-skills
```

### 3. 验证安装

```bash
# 检查目录结构
cd rust-skills
ls -la

# 应该看到：
# - skills/          # 40+ 个技能定义
# - references/      # 参考资料
# - SKILL.md         # 主入口
# - README.md        # 项目说明
```

---

## 在项目中配置

### 配置 moshu 项目

假设：
- rust-skills 安装在：`D:\github\rust-skills`
- moshu 项目在：`D:\projects\moshu`

#### 步骤 1: 创建配置目录

```bash
cd D:\projects\moshu
mkdir -p .claude
```

#### 步骤 2: 创建配置文件

创建 `.claude/settings.local.json`：

```json
{
  "skillDirectories": [
    "D:/github/rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
```

**重要提示：**
- Windows 路径使用 `/` 而不是 `\`
- 使用绝对路径，不要使用相对路径
- 路径中不要有中文或空格

#### 步骤 3: 添加到 .gitignore

因为每个开发者的路径可能不同，不要提交配置到 Git：

```bash
# 添加到 .gitignore
echo ".claude/settings.local.json" >> .gitignore
```

#### 步骤 4: 创建配置模板（供团队参考）

创建 `.claude/settings.local.json.example`：

```json
{
  "skillDirectories": [
    "<请替换为你的 rust-skills 路径>/skills"
  ],
  "enableAllProjectMcpServers": true,
  "_comment": "示例路径：",
  "_linux": "~/rust-skills/skills",
  "_macos": "~/rust-skills/skills",
  "_windows": "D:/github/rust-skills/skills"
}
```

提交模板到 Git：

```bash
git add .claude/settings.local.json.example
git commit -m "Add Claude Code configuration template"
```

---

## 路径索引详解

### 路径类型说明

Claude Code 支持三种路径格式：

#### 1. 绝对路径（推荐）

**Linux/macOS:**
```json
{
  "skillDirectories": [
    "/home/username/rust-skills/skills",
    "/Users/username/rust-skills/skills"
  ]
}
```

**Windows:**
```json
{
  "skillDirectories": [
    "D:/github/rust-skills/skills",
    "C:/Users/YourName/rust-skills/skills"
  ]
}
```

**注意：**
- Windows 路径盘符后用 `/` 不用 `\`
- 不要用双反斜杠 `\\`

#### 2. 波浪号主目录（推荐 Linux/macOS）

```json
{
  "skillDirectories": [
    "~/rust-skills/skills"
  ]
}
```

**展开为：**
- Linux: `/home/username/rust-skills/skills`
- macOS: `/Users/username/rust-skills/skills`
- Windows: `C:\Users\YourName\rust-skills\skills`

#### 3. 环境变量（高级用法）

设置环境变量：

```bash
# Linux/macOS - 添加到 ~/.bashrc 或 ~/.zshrc
export RUST_SKILLS_PATH="$HOME/rust-skills"

# Windows - 系统环境变量
setx RUST_SKILLS_PATH "D:\github\rust-skills"
```

配置文件：

```json
{
  "skillDirectories": [
    "${RUST_SKILLS_PATH}/skills"
  ]
}
```

### 多路径配置

可以同时索引多个技能目录：

```json
{
  "skillDirectories": [
    "D:/github/rust-skills/skills",
    "D:/my-custom-skills/skills",
    "~/company-skills/skills"
  ]
}
```

### 路径验证

创建验证脚本 `verify-skills.sh`：

```bash
#!/bin/bash

SKILLS_PATH="D:/github/rust-skills/skills"

echo "验证 Rust Skills 路径..."
echo "配置路径: $SKILLS_PATH"

if [ -d "$SKILLS_PATH" ]; then
    echo "✅ 路径存在"

    # 检查技能数量
    SKILL_COUNT=$(find "$SKILLS_PATH" -name "SKILL.md" | wc -l)
    echo "✅ 找到 $SKILL_COUNT 个技能"

    # 列出部分技能
    echo ""
    echo "可用技能示例："
    find "$SKILLS_PATH" -name "SKILL.md" | head -5 | while read file; do
        skill_name=$(basename $(dirname "$file"))
        echo "  - $skill_name"
    done
else
    echo "❌ 路径不存在，请检查配置"
    exit 1
fi
```

运行验证：

```bash
chmod +x verify-skills.sh
./verify-skills.sh
```

---

## 使用方法

### 基本用法

```bash
# 进入你的项目
cd D:\projects\moshu

# 直接提问，自动调用相关技能
claude "如何修复 E0382 错误？"

# 查看可用技能
claude "列出所有 Rust 技能"

# 针对具体文件
claude "分析 src/main.rs 的所有权问题"
```

### 结合开发流程

#### 1. 编译错误修复

```bash
# 捕获编译错误并请求修复
cargo check 2>&1 | claude "修复这些 Rust 编译错误"

# 或者保存到文件
cargo check 2>&1 > errors.txt
claude "分析 errors.txt 中的编译错误并给出修复方案"
```

#### 2. 代码审查

```bash
# 审查未提交的更改
git diff | claude "审查这些 Rust 代码更改"

# 审查特定提交
git show HEAD | claude "审查这个提交的 Rust 代码"

# 审查 PR
git diff main..feature-branch | claude "审查这个 PR 的 Rust 代码"
```

#### 3. 性能优化

```bash
# 运行基准测试
cargo bench > bench.txt
claude "分析 bench.txt 的基准测试结果并提供优化建议"

# 性能分析
claude "分析 src/parser.rs 的性能瓶颈，关注内存分配"
```

#### 4. 测试相关

```bash
# 测试失败分析
cargo test 2>&1 | claude "分析这些测试失败的原因"

# 生成测试
claude "为 src/utils.rs 中的 parse_config 函数生成单元测试"
```

### 高级用法

#### 显式指定技能

```bash
# 使用特定技能
claude --context "使用 rust-ownership 技能" "解释 Rc 和 Arc 的区别"

# 链接多个技能
claude "使用 rust-web 和 rust-auth 技能构建 JWT 认证的 REST API"
```

#### 上下文感知

```bash
# 提供代码上下文
cat src/main.rs | claude "这段代码有什么所有权问题？"

# 多文件上下文
claude "分析 src/lib.rs 和 src/error.rs 的错误处理设计"
```

---

## 常见问题

### Q1: Claude Code 找不到技能？

**检查步骤：**

1. 验证路径是否正确：
```bash
# Linux/macOS
ls ~/rust-skills/skills/rust-ownership/SKILL.md

# Windows
ls D:/github/rust-skills/skills/rust-ownership/SKILL.md
```

2. 检查配置文件：
```bash
cat .claude/settings.local.json
```

3. 路径格式正确吗？
```json
// ✅ 正确
"D:/github/rust-skills/skills"

// ❌ 错误
"D:\\github\\rust-skills\\skills"
"D:\github\rust-skills\skills"
```

4. 重启 Claude Code：
```bash
# 如果有重启命令
claude --restart

# 或者重启终端
```

### Q2: Windows 路径问题

**常见错误：**

```json
// ❌ 使用反斜杠
"skillDirectories": ["D:\github\rust-skills\skills"]

// ❌ 使用双反斜杠
"skillDirectories": ["D:\\github\\rust-skills\\skills"]

// ✅ 正确 - 使用正斜杠
"skillDirectories": ["D:/github/rust-skills/skills"]
```

### Q3: 如何更新技能？

```bash
cd D:\github\rust-skills
git pull origin main
```

更新后无需重新配置，直接生效。

### Q4: 多个项目共享配置？

创建全局配置脚本 `setup-claude.sh`：

```bash
#!/bin/bash

# 配置脚本 - 在任意 Rust 项目中运行

PROJECT_DIR=$(pwd)
SKILLS_PATH="D:/github/rust-skills/skills"

echo "为项目配置 Rust Skills: $PROJECT_DIR"

# 创建配置目录
mkdir -p .claude

# 生成配置文件
cat > .claude/settings.local.json << EOF
{
  "skillDirectories": [
    "$SKILLS_PATH"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 添加到 .gitignore
if ! grep -q ".claude/settings.local.json" .gitignore 2>/dev/null; then
    echo ".claude/settings.local.json" >> .gitignore
    echo "✅ 已添加到 .gitignore"
fi

echo "✅ 配置完成！"
echo "路径: $SKILLS_PATH"
```

在任意项目中运行：

```bash
cd ~/projects/new-rust-project
bash ~/rust-skills/setup-claude.sh
```

### Q5: 如何禁用某些技能？

```json
{
  "skillDirectories": [
    "D:/github/rust-skills/skills"
  ],
  "disabledSkills": [
    "rust-ebpf",
    "rust-gpu",
    "rust-embedded"
  ]
}
```

---

## 实战示例

### 示例 1: moshu 项目完整配置

```bash
# 1. 确认 rust-skills 位置
ls D:/github/rust-skills/skills

# 2. 进入 moshu 项目
cd D:/projects/moshu

# 3. 创建配置
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "skillDirectories": [
    "D:/github/rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 4. 添加到 .gitignore
echo ".claude/settings.local.json" >> .gitignore

# 5. 创建团队配置模板
cat > .claude/settings.local.json.example << 'EOF'
{
  "skillDirectories": [
    "<替换为你的路径>/skills"
  ],
  "enableAllProjectMcpServers": true
}
EOF

# 6. 提交配置模板
git add .claude/settings.local.json.example .gitignore
git commit -m "Add Claude Code configuration template"

# 7. 测试
claude "列出可用的 Rust 技能"
```

### 示例 2: 多项目统一配置脚本

创建 `D:\github\rust-skills\install-to-project.ps1`（Windows PowerShell）：

```powershell
# Rust Skills 项目配置脚本
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$SkillsPath = "D:/github/rust-skills/skills"
$ClaudeDir = Join-Path $ProjectPath ".claude"
$ConfigFile = Join-Path $ClaudeDir "settings.local.json"

# 创建目录
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

# 生成配置
$config = @{
    skillDirectories = @($SkillsPath)
    enableAllProjectMcpServers = $true
} | ConvertTo-Json

Set-Content -Path $ConfigFile -Value $config

# 更新 .gitignore
$gitignore = Join-Path $ProjectPath ".gitignore"
if (Test-Path $gitignore) {
    Add-Content -Path $gitignore -Value ".claude/settings.local.json"
}

Write-Host "✅ 配置完成！"
Write-Host "项目: $ProjectPath"
Write-Host "技能路径: $SkillsPath"
```

使用：

```powershell
.\install-to-project.ps1 -ProjectPath "D:\projects\moshu"
```

### 示例 3: 验证配置脚本

创建 `verify-config.sh`：

```bash
#!/bin/bash

# 验证 Claude Code 配置

CONFIG_FILE=".claude/settings.local.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "检查配置文件: $CONFIG_FILE"
cat "$CONFIG_FILE"
echo ""

# 提取技能路径
SKILLS_PATH=$(jq -r '.skillDirectories[0]' "$CONFIG_FILE")

echo "技能路径: $SKILLS_PATH"

if [ -d "$SKILLS_PATH" ]; then
    SKILL_COUNT=$(find "$SKILLS_PATH" -name "SKILL.md" | wc -l)
    echo "✅ 找到 $SKILL_COUNT 个技能"

    echo ""
    echo "技能列表（前 10 个）："
    find "$SKILLS_PATH" -name "SKILL.md" | head -10 | while read file; do
        skill=$(basename $(dirname "$file"))
        echo "  - $skill"
    done
else
    echo "❌ 技能路径不存在"
    exit 1
fi
```

---

## 团队协作建议

### README 中添加说明

在 moshu 项目的 `README.md` 中添加：

```markdown
## 开发环境配置

### Claude Code Rust Skills

本项目使用 Rust Skills 增强 Claude Code 的 Rust 开发能力。

#### 安装步骤

1. 克隆 Rust Skills 到本地：
   ```bash
   git clone https://github.com/huiali/rust-skills.git ~/rust-skills
   ```

2. 复制配置模板：
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```

3. 编辑 `.claude/settings.local.json`，将路径替换为你的实际路径：
   ```json
   {
     "skillDirectories": [
       "/your/path/to/rust-skills/skills"
     ]
   }
   ```

4. 验证配置：
   ```bash
   claude "测试 Rust Skills 配置"
   ```
```

---

## 总结

**全局安装的优势：**
- ✅ 一次安装，所有项目共享
- ✅ 更新方便，统一管理
- ✅ 不占用项目空间
- ✅ 适合个人开发

**配置要点：**
1. 选择固定的安装位置
2. 使用绝对路径（Windows 用 `/`）
3. 配置文件添加到 `.gitignore`
4. 提供配置模板供团队参考

**推荐你的配置：**

```json
{
  "skillDirectories": [
    "D:/github/rust-skills/skills"
  ],
  "enableAllProjectMcpServers": true
}
```

现在可以在 moshu 项目中愉快地使用 Claude Code + Rust Skills 了！🚀
