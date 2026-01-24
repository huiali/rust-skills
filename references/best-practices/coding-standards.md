---
name: coding-standards
description: "Rust 编码规范（80条）"
category: coding-style
triggers: ["coding", "standard", "style", "naming", "convention"]
related_skills:
  - rust-coding
  - rust-anti-pattern
  - rust-learner
---

# Rust 编码规范

> 本规范定义了 Rust 编码标准，涵盖命名、格式、文档、错误处理等方面。

---

## 命名规范（N-001 到 N-020）

### N-001: 变量使用 snake_case

```rust
// ✅ 正确
let max_connections = 100;
let user_name = String::new();
let is_valid = true;

// ❌ 错误
let MaxConnections = 100;
let userName = String::new();
```

### N-002: 常量使用 SCREAMING_SNAKE_CASE

```rust
// ✅ 正确
const MAX_BUFFER_SIZE: usize = 1024;
const DEFAULT_TIMEOUT_MS: u64 = 3000;

// ❌ 错误
const MaxBufferSize: usize = 1024;
```

### N-003: 函数使用 snake_case

```rust
// ✅ 正确
fn calculate_total_price() -> f64 { ... }
fn process_user_data(user: &User) -> Result<(), Error> { ... }

// ❌ 错误
fn CalculateTotalPrice() -> f64 { ... }
```

### N-004: 类型和 trait 使用 PascalCase

```rust
// ✅ 正确
struct UserSession;
enum ProcessingState;
trait Serializable;

// ❌ 错误
struct user_session;
enum processing_state;
```

### N-005: 避免前缀 Get

```rust
// ✅ 正确 - 直接描述属性
fn name(&self) -> &str { &self.name }
fn len(&self) -> usize { self.items.len() }

// ❌ 错误
fn get_name(&self) -> &str { &self.name }
```

### N-006: 布尔值使用 is_/has_/can_ 前缀

```rust
// ✅ 正确
let is_active = true;
let has_permission = false;
let can_connect = true;

// ❌ 错误
let active = true;
```

### N-007: 类型命名避免重复

```rust
// ✅ 正确
struct User;
struct UserRepository;

// ❌ 错误
struct UserUser;
```

### N-008: 模块使用 snake_case

```rust
// ✅ 正确
pub mod network_config;
pub mod data_processing;
```

### N-009: Crate 名称使用 kebab-case

```toml
[package]
name = "my-awesome-crate"
```

### N-010: 泛型参数使用简短描述性名称

```rust
// ✅ 正确
fn process_items<T: Processable>(items: &[T]) { ... }
struct Cache<K, V> { ... }
```

### N-011: 生命周期参数使用简短名称

```rust
// ✅ 正确
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str { ... }
```

### N-012: 错误类型以 Error 结尾

```rust
// ✅ 正确
struct ParseError;
enum ValidationError;
```

### N-013: Result 和 Option 变量避免冗余命名

```rust
// ✅ 正确
match some_result {
    Ok(value) => process(value),
    Err(e) => handle_error(e),
}
```

### N-014: 集合命名使用复数形式

```rust
// ✅ 正确
let users: Vec<User> = vec![];
let items: HashSet<String> = HashSet::new();
```

### N-015: 临时变量使用简短名称

```rust
// ✅ 正确 - 短作用域可接受
for i in 0..10 {
    println!("{}", i);
}
```

### N-016: 公开 API 命名要清晰明确

```rust
// ✅ 正确
pub fn calculate_tax(income: f64, rate: f64) -> f64 { ... }
```

### N-017: 避免魔法数字，使用命名常量

```rust
// ✅ 正确
const HTTP_PORT: u16 = 80;
const MAX_RETRY_ATTEMPTS: u32 = 3;
```

### N-018: 配置字段命名保持一致性

```rust
// ✅ 正确
struct Config {
    host: String,
    port: u16,
    timeout_secs: u64,
}
```

### N-019: 避免使用下划线开头的命名

```rust
// ✅ 正确
let value = 42;
let _ = compute_side_effect();
```

### N-020: 关联函数命名要反映语义

```rust
// ✅ 正确
impl Vec<u32> {
    fn with_capacity(capacity: usize) -> Self { ... }
    fn from_elem(elem: u32, n: usize) -> Self { ... }
}
```

---

## 代码格式（F-021 到 F-035）

### F-021: 使用 rustfmt 进行格式化

```bash
cargo fmt
cargo fmt --check
```

### F-022: 行宽不超过 100 字符

```rust
// ✅ 正确 - 合理换行
fn complex_function(
    arg1: Type1,
    arg2: Type2,
    arg3: Type3,
) -> Result<Output, Error> {
    // ...
}
```

### F-023: 大括号风格统一

```rust
fn foo() {
    // ...
}

if condition {
    // ...
} else {
    // ...
}
```

### F-024: match 分支对齐

```rust
match value {
    Pattern1 => { ... }
    Pattern2 => { ... }
    _ => { ... }
}
```

### F-025: 链式调用换行

```rust
let result = items
    .iter()
    .filter(|x| x.is_valid())
    .map(|x| x.value())
    .collect::<Vec<_>>();
```

### F-026: 泛型参数换行

```rust
fn generic_function<T, U, V>(
    arg1: T,
    arg2: U,
    arg3: V,
) -> Result<Output, Error>
where
    T: Trait1,
    U: Trait2,
    V: Trait3,
{
    // ...
}
```

### F-027: 结构体字段对齐

```rust
struct Config {
    host:        String,
    port:        u16,
    timeout:     Duration,
    max_retries: u32,
}
```

### F-028: 注释与代码同行时使用双斜杠

```rust
let value = 42; // 这是单行注释
```

### F-029: 文档注释使用 ///

```rust
/// 处理用户请求
///
/// # Arguments
///
/// * `request` - 用户请求数据
pub fn handle_request(request: &Request) -> Response {
    // ...
}
```

### F-030: 模块级注释使用 //!

```rust
//! 网络通信模块
//!
//! 提供 TCP/UDP 协议支持和连接管理功能。
```

### F-031: 复杂表达式添加括号

```rust
let result = (a + b) * (c - d) / e;
```

### F-032: match 表达式避免过度嵌套

```rust
match data {
    Ok(ref data) if data.is_empty() => return Ok(Default::default()),
    Ok(data) => process(data),
    Err(e) => return Err(e),
}
```

### F-033: 闭包参数换行

```rust
let result = items
    .iter()
    .filter(|item| item.is_valid())
    .map(|item| item.value())
    .collect::<Vec<_>>();
```

### F-034: 属性格式化

```rust
#[derive(Debug, Clone, PartialEq)]
#[cfg(test)]
pub struct Config {
    // ...
}
```

### F-035: import 分组排序

```rust
use std::collections::HashMap;
use std::io::{Read, Write};

use serde::{Deserialize, Serialize};

use crate::config::Config;
use crate::error::AppError;
```

---

## 错误处理（E-036 到 E-050）

### E-036: 库代码使用自定义错误类型

```rust
#[derive(Error, Debug)]
pub enum ParseError {
    #[error("invalid format: {0}")]
    InvalidFormat(String),

    #[error("missing field: {0}")]
    MissingField(&'static str),

    #[error(transparent)]
    Io(#[from] std::io::Error),
}
```

### E-037: 应用程序使用 anyhow

```rust
use anyhow::{Context, Result};

fn main() -> Result<()> {
    let config = load_config()
        .context("Failed to load configuration")?;
    Ok(())
}
```

### E-038: 错误传播使用 ?

```rust
fn read_and_parse(path: &Path) -> Result<Data, ParseError> {
    let content = std::fs::read_to_string(path)
        .map_err(ParseError::from_io)?;
    let data = serde_json::from_str(&content)
        .map_err(ParseError::from_json)?;
    Ok(data)
}
```

### E-039: 提供有意义的错误上下文

```rust
let file = std::fs::File::open(path)
    .with_context(|| format!("Failed to open: {}", path.display()))?;
```

### E-040: 避免在库中使用 panic 处理错误

```rust
// ✅ 正确
fn parse_number(input: &str) -> Result<u32, ParseNumberError> {
    input.parse().ok_or(ParseNumberError::InvalidFormat)
}

// ❌ 错误
fn parse_number(input: &str) -> u32 {
    input.parse().expect("Invalid number format")
}
```

### E-041: 错误类型实现 std::error::Error

```rust
impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl std::error::Error for MyError {}
```

### E-042: 使用 ? 进行错误转换

```rust
impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> Self {
        AppError::Io(e)
    }
}
```

### E-043: 避免 unwrap 和 expect 的滥用

```rust
// ✅ 正确 - 只在确信不会失败时使用
fn get_version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}

// ❌ 错误
let value = map.get(&key).unwrap();
```

### E-044: 使用合适的方法处理 Option

```rust
let value = config.get("key").unwrap_or(&DEFAULT_VALUE);
let value = config.get("key").ok_or(KeyNotFoundError)?;
```

### E-045: 错误日志记录要平衡信息与噪声

```rust
tracing::error!(error = %error, "Operation failed");
```

### E-046: 定义错误变体时考虑未来扩展

```rust
#[derive(Error, Debug)]
pub enum AppError {
    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("validation error: {0}")]
    Validation(String),

    #[error("unknown error occurred")]
    Unknown,
}
```

### E-047: 批量操作返回部分成功信息

```rust
struct BatchResult<T> {
    succeeded: Vec<T>,
    failed: Vec<(T, Error)>,
    skipped: Vec<T>,
}
```

### E-048: 区分可恢复和不可恢复错误

```rust
fn validate_input(input: &str) -> Result<(), ValidationError> {
    if input.is_empty() {
        return Err(ValidationError::Empty);
    }
    Ok(())
}

fn invariant_violated() -> ! {
    panic!("Internal invariant violated");
}
```

### E-049: 错误传播链保持信息

```rust
fn level2() -> Result<(), Error> {
    level3().context("Failed at level2")?;
    Ok(())
}
```

### E-050: 测试错误类型

```rust
#[cfg(test)]
mod error_tests {
    #[test]
    fn error_display_format() {
        let error = ParseError::InvalidFormat("test".to_string());
        assert_eq!(error.to_string(), "invalid format: test");
    }
}
```

---

## 文档规范（D-051 到 D-065）

### D-051: 公共 API 必须有文档注释

```rust
/// 解析 JSON 字符串为结构体
///
/// # Arguments
///
/// * `input` - JSON 格式的输入字符串
///
/// # Returns
///
/// 解析后的结构体实例
///
/// # Errors
///
/// 当 JSON 格式不正确时返回 [`ParseError`]
///
/// # Examples
///
/// ```
/// use my_crate::parse_json;
/// let json = r#"{"name": "Alice"}"#;
/// let value = parse_json(json).unwrap();
/// ```
pub fn parse_json(input: &str) -> Result<Value, ParseError> {
    // ...
}
```

### D-052: 文档包含 Examples 章节

```rust
/// 计算两个数的最大公约数
///
/// # Examples
///
/// ```
/// assert_eq!(gcd(12, 18), 6);
/// ```
pub fn gcd(a: u64, b: u64) -> u64 {
    if b == 0 { a } else { gcd(b, a % b) }
}
```

### D-053: 文档链接使用反引号和方括号

```rust
/// 有关错误处理的详细信息，请参见 [`std::io::Error`] 和 [`std::fmt::Display`]。
```

### D-054: 文档中的代码块标记语言

```rust
/// ```rust
/// let result = process_request(request);
/// assert!(result.is_ok());
/// ```
///
/// ```json
/// {"status": "ok", "data": 42}
/// ```
```

### D-055: 模块文档说明模块职责

```rust
//! 错误处理模块
//!
//! 提供统一的错误类型定义和错误处理实用函数。
//!
//! ## 主要类型
//!
//! - [`AppError`] - 应用程序主错误类型
```

### D-056: 复杂算法提供算法说明

```rust
/// 使用冒泡排序对切片进行原地排序
///
/// # Algorithm
///
/// 冒泡排序重复遍历列表，比较相邻元素。
///
/// # Time Complexity
///
/// O(n²)
///
/// # Space Complexity
///
/// O(1)
pub fn bubble_sort<T: Ord>(slice: &mut [T]) {
    // ...
}
```

### D-057: 文档说明 panic 情况

```rust
/// 获取数组的第一个元素
///
/// # Panics
///
/// 当数组为空时 panic。
pub fn first<T>(slice: &[T]) -> &T {
    slice.get(0).expect("slice is empty")
}
```

### D-058: 文档说明线程安全性

```rust
/// 线程安全的配置管理器
///
/// # Thread Safety
///
/// 此类型实现了 [`Send`] 和 [`Sync`]，可以在多线程间安全共享。
```

### D-059: Cargo.toml 包含完整描述

```toml
[package]
name = "my-crate"
version = "1.0.0"
description = "A short description of the crate"
authors = ["Author Name <author@example.com>"]
edition = "2024"
repository = "https://github.com/username/repo"
license = "MIT OR Apache-2.0"
keywords = ["tag1", "tag2"]
categories = ["development-tools", "database"]
```

### D-060: 文档注释保持一致性

```rust
/// 成功返回处理后的数据
///
/// # Arguments
///
/// * `data` - 输入数据
///
/// # Returns
///
/// 处理后的数据
///
/// # Errors
///
/// 当输入数据无效时返回错误
```

### D-061: 弃用使用 #[deprecated]

```rust
#[deprecated(
    since = "2.0.0",
    note = "Use `parse_config_v2` instead"
)]
pub fn parse_config(path: &Path) -> Result<Config, ConfigError> {
    // ...
}
```

### D-062: 内部实现细节用 // 注释

```rust
// 使用快速路径处理常见情况
if let Some(result) = try_fast_path() {
    return result;
}

// 慢速路径：处理边界情况
slow_path_algorithm()
```

### D-063: 复杂逻辑添加解释注释

```rust
// 使用位运算将状态压缩到单个字节
// bit 0-2: 状态码 (0-7)
// bit 3-5: 标志位 (3 个标志)
const STATUS_MASK: u8 = 0x07;
```

### D-064: TODO 和 FIXME 使用标准格式

```rust
// TODO: 优化算法复杂度
// FIXME: 在边界条件下可能 panic
```

### D-065: 避免显而易见的注释

```rust
// ✅ 正确 - 解释为什么，不是做什么
std::thread::sleep(Duration::from_secs(5));

// ❌ 错误
let x = 5;  // 将 x 设为 5
```

---

## 代码质量（Q-066 到 Q-080）

### Q-066: 避免不必要的 clone

```rust
// ✅ 正确
fn process_name(name: &str) {
    println!("{}", name);
}

// ❌ 错误
fn process_name(name: &String) {
    let n = name.clone();
    println!("{}", n);
}
```

### Q-067: 优先使用迭代器而非索引

```rust
let result: Vec<_> = items.iter().filter(|x| x.is_valid()).collect();
```

### Q-068: 避免在热点循环中分配内存

```rust
let mut buffer = String::with_capacity(1024);
for _ in 0..1000 {
    buffer.push_str("data");
}
```

### Q-069: 使用 Result/Option 的组合器

```rust
let value = config
    .get("feature")
    .and_then(|v| v.parse::<bool>().ok())
    .unwrap_or(true);
```

### Q-070: 保持函数短小单一职责

```rust
fn validate_email(email: &str) -> Result<(), ValidationError> {
    if !email.contains('@') {
        return Err(ValidationError::InvalidEmail);
    }
    Ok(())
}
```

### Q-071: 避免类型膨胀

```rust
fn process_items<T: Processable>(items: &[T]) {
    for item in items {
        item.process();
    }
}
```

### Q-072: 优先使用组合而非继承

```rust
struct Calculator {
    logger: Logger,
    validator: Validator,
}
```

### Q-073: 使用 #[cfg(test)] 隔离测试代码

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_basic_functionality() {
        // 测试代码
    }
}
```

### Q-074: 使用 match 的完整性

```rust
enum Status {
    Pending,
    Running,
    Completed,
    Failed(String),
}

fn describe(status: Status) -> String {
    match status {
        Status::Pending => "pending".to_string(),
        Status::Running => "running".to_string(),
        Status::Completed => "completed".to_string(),
        Status::Failed(msg) => format!("failed: {}", msg),
    }
}
```

### Q-075: 避免在公开 API 中暴露内部类型

```rust
mod internal {
    pub struct InternalState { /* ... */ }
}

pub struct PublicHandle(internal::InternalState);
```

### Q-076: 使用恰当的数据结构

```rust
let mut unique_items = std::collections::HashSet::new();
let mut ordered_items = std::collections::BTreeSet::new();
```

### Q-077: 避免过度使用 Rc/RefCell

```rust
use std::sync::{Arc, Mutex};

let shared = Arc::new(Mutex::new(0));
```

### Q-078: 使用 cargo clippy 检查代码质量

```bash
cargo clippy
cargo clippy --fix
```

### Q-079: 编写属性测试

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_reverse_twice(s: String) {
        let reversed: String = s.chars().rev().collect();
        let double_reversed: String = reversed.chars().rev().collect();
        assert_eq!(s, double_reversed);
    }
}
```

### Q-080: 定期审查和重构

```rust
// 定期检查：
// 1. 函数是否过长？
// 2. 类型是否承担过多职责？
// 3. 是否有重复代码？
// 4. 命名是否清晰？
// 5. 错误处理是否一致？
// 6. 文档是否完整？

// 使用工具分析：
// cargo tarpaulin  # 代码覆盖率
// cargo bench      # 性能分析
```

---

## 规范速查表

| 类别 | 规则数 | 说明 |
|-----|-------|------|
| N-命名规范 | 20 | 变量、常量、函数、类型命名 |
| F-代码格式 | 15 | 格式化、注释、import 排序 |
| E-错误处理 | 15 | 错误类型、传播、日志记录 |
| D-文档规范 | 15 | API 文档、模块文档、示例 |
| Q-代码质量 | 15 | 性能、可读性、可维护性 |

---

## 关联技能
- `rust-coding` - 编码规范基础
- `rust-anti-pattern` - 反模式识别
- `rust-learner` - Rust 学习路径

