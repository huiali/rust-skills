# Rust Skill Rules

> Cursor 项目规则配置

## 技能触发规则

当遇到 Rust 编程问题时，AI 应自动匹配对应技能：

| 问题类型 | 触发技能 |
|---------|---------|
| 所有权/生命周期错误 | `rust-ownership` |
| Cell/RefCell/Mutex | `rust-mutability` |
| 并发/异步/线程 | `rust-concurrency` |
| Result/Option/错误处理 | `rust-error` |
| unsafe/FFI/原始指针 | `rust-unsafe` |
| 性能优化/基准测试 | `rust-performance` |
| Web/axum/HTTP | `rust-web` |
| Redis 缓存管理 | `rust-cache` |
| JWT/API Key 认证 | `rust-auth` |
| 中间件/CORS/限流 | `rust-middleware` |
| RBAC/策略引擎 | `rust-xacml` |
| no_std/嵌入式/WASM | `rust-embedded` |
| 跨语言调用/C++ | `rust-ffi` |

## 参考文件

技能定义文件位于 `skills/*/SKILL.md`，参考目录：
- `skills/` - 核心技能
- `references/best-practices/` - 最佳实践
- `references/core-concepts/` - 核心概念

## 技能优先级

1. **Core Skills** - 优先使用（日常开发）
2. **Advanced Skills** - 深入理解时参考
3. **Expert Skills** - 疑难杂症时查阅

## 使用方式

直接在对话中描述问题，或明确指定技能：

```
请使用 rust-ownership 回答：
"Rc 和 Arc 有什么区别？"
```

