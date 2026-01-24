---
name: unsafe-rules
description: "Unsafe 代码安全规则"
category: code-safety
triggers: ["unsafe", "safety", "SAFETY", "raw pointer", "FFI"]
related_skills:
  - rust-unsafe
  - rust-ffi
  - rust-ownership
---

# Unsafe 代码规则

> 本规则集定义了 unsafe 代码的安全检查标准。

---

## 高危规则（红色 - 必须遵守）

### U-001: Raw Pointer 解引用必须包裹在 unsafe 块中

```rust
// ✅ 正确
let ptr = &data as *const Data;
unsafe {
    println!("{}", (*ptr).value);
}

// ❌ 错误
let ptr = &data as *const Data;
println!("{}", (*ptr).value); // 直接解引用 raw pointer
```

### U-002: 必须为所有 unsafe 函数添加 SAFETY 注释

```rust
/// 设置原始内存区域的值
///
/// # Safety
///
/// - `ptr` 必须指向一个已分配的有效内存块
/// - `size` 必须等于实际分配的字节数
/// - 调用者必须确保在函数返回前不会释放该内存
unsafe fn set_memory(ptr: *mut u8, size: usize, value: u8) {
    // ...
}
```

### U-003: FFI 调用必须使用 extern 块声明

```rust
// ✅ 正确
extern "C" {
    fn c_strlen(s: *const c_char) -> usize;
}

// ❌ 错误
fn c_strlen(s: *const c_char) -> usize; // 缺少 extern 声明
```

### U-004: 跨 FFI 边界的类型必须具有 #[repr(C)]

```rust
// ✅ 正确
#[repr(C)]
pub struct FfiHeader {
    pub magic: u32,
    pub version: u16,
    pub flags: u8,
}

// ❌ 错误 - 内存布局不确定
pub struct Header {
    pub magic: u32,
    pub version: u16,
}
```

### U-005: union 字段访问必须在 unsafe 块中

```rust
// ✅ 正确
union IntOrFloat {
    as_i32: i32,
    as_f32: f32,
}

let value = unsafe { int_or_float.as_i32 };

// ❌ 错误
let value = int_or_float.as_i32;
```

### U-006: 指针算术运算后必须验证边界

```rust
// ✅ 正确
let ptr = buffer.as_ptr().offset(10);
if ptr < buffer.as_ptr().add(buffer.len()) {
    unsafe { *ptr = 0xFF; }
}

// ❌ 错误 - 可能越界
let ptr = buffer.as_ptr().offset(1000);
unsafe { *ptr = 0xFF; }
```

### U-007: 实现 Send/Sync 必须保证协变

```rust
// ✅ 正确 - 线程安全
unsafe impl Send for ThreadSafeContainer {}

// ❌ 错误 - Rc 不是线程安全的
unsafe impl Send for NotThreadSafe {} // Rc<T> 不能跨线程发送
```

### U-008: 展宽类型（#[repr(u*)]）转换必须安全

```rust
// ✅ 正确
fn to_u32(val: u8) -> u32 {
    val as u32  // 小类型到大类型，安全
}

// ❌ 危险 - 大类型到小类型，可能丢失数据
fn to_u8(val: u32) -> u8 {
    val as u8  // 需要额外检查
}
```

### U-009: 嵌入式的 ISR 中禁止动态分配

```rust
// ✅ 正确 - 静态分配
static mut BUFFER: [u8; 256] = [0; 256];

// ❌ 错误 - 堆分配可能在 ISR 中失败
fn interrupt_handler() {
    let mut vec = Vec::new(); // 禁止！
}
```

### U-010: 禁止返回指向局部变量的指针

```rust
// ❌ 错误 - 悬垂指针
fn bad_function() -> *const i32 {
    let x = 42;
    &x as *const i32  // x 被释放后指针无效
}

// ✅ 正确 - 返回静态数据
fn good_function() -> *const i32 {
    static X: i32 = 42;
    &X as *const i32
}
```

### U-011: 指针类型转换必须保证对齐

```rust
// ✅ 正确 - 正确对齐
#[repr(align(8))]
struct AlignedData {
    value: u64,
}

// ❌ 错误 - 可能对齐不当
let unaligned_ptr = 1 as *const u64;
unsafe { *unaligned_ptr = 42; } // 可能崩溃
```

### U-012: 手动实现的 drop 必须处理所有字段

```rust
// ✅ 正确
impl Drop for ManualResource {
    fn drop(&mut self) {
        unsafe {
            libc::free(self.ptr as *mut libc::c_void);
        }
        self.is_dropped = true;
    }
}

// ❌ 错误 - 遗漏某些资源的释放
impl Drop for ManualResource {
    fn drop(&mut self) {
        if self.ptr.is_valid() {
            libc::free(self.ptr as *mut libc::c_void);
        }
        // 遗漏了 handle 的关闭
    }
}
```

---

## 中危规则（橙色 - 建议遵守）

### U-013: 避免在 unsafe 中调用其他 unsafe 函数

```rust
// ✅ 推荐 - 将复杂 unsafe 操作封装
unsafe fn safe_wrapper(ptr: *mut T) -> Result<(), Error> {
    check_ptr_validity(ptr)?;  // 先检查
    complex_operation(ptr)      // 再操作
}

unsafe fn complex_operation(ptr: *mut T) {
    // 假设已验证的指针操作
    (*ptr).do_something();
}
```

### U-014: 使用 MaybeUninit 代替未初始化的 union 字段

```rust
// ✅ 推荐
let mut buffer = MaybeUninit::<[u8; 1024]>::uninit();
let ptr = buffer.as_mut_ptr();
unsafe {
    ptr.write_bytes(0, 1024);
}
let buffer = unsafe { buffer.assume_init() };
```

### U-015: FFI 字符串必须处理编码和长度

```rust
// ✅ 推荐
unsafe fn c_string_to_rust(s: *const c_char) -> Result<String, Utf8Error> {
    if s.is_null() {
        return Ok(String::new());
    }
    let c_str = std::ffi::CStr::from_ptr(s);
    c_str.to_str()?.to_string()
}
```

### U-016: 跨线程传递裸指针必须使用 Send

```rust
// ✅ 推荐 - 使用 Arc 包装
struct ThreadSafePtr {
    ptr: *mut T,
    _marker: std::marker::PhantomData<*mut ()>,
}

unsafe impl Send for ThreadSafePtr {}
unsafe impl Sync for ThreadSafePtr {}
```

### U-017: 避免在热点代码中频繁创建原始指针

```rust
// ✅ 推荐 - 缓存指针
fn process_buffer(buffer: &mut [u8]) {
    let ptr = buffer.as_mut_ptr();
    let len = buffer.len();
    for i in 0..len {
        unsafe { ptr.add(i).write(compute(i)); }
    }
}
```

### U-018: 实现 Drop 的类型不应包含借用字段

```rust
// ✅ 推荐
struct Container {
    data: Vec<u8>,     // 拥有所有权
    capacity: usize,
}

// ❌ 问题 - 借用字段可能导致 drop 问题
struct ProblemContainer<'a> {
    data: &'a [u8],    // 借用
}
```

### U-019: 使用 ptr::read/write 时注意 provenance

```rust
// ✅ 推荐
let val = unsafe { ptr.read() };
ptr.write(val + 1);

// ❌ 注意 - 避免混用不同来源的指针
let val = ptr1.read();
ptr2.write(val);  // 可能违反 provenance 规则
```

### U-020: 跨 FFI 边界传递 Option 指针必须约定语义

```rust
// ✅ 推荐 - 明确 null 指针语义
extern "C" {
    /// 返回下一个元素，如果到达末尾返回 null
    fn get_next(ptr: *mut Context) -> *mut Element;
}
```

### U-021: 避免在循环中重复 unsafe 转换

```rust
// ✅ 推荐
let base = data.as_ptr() as *const ComplexType;
for i in 0..len {
    unsafe { process(&*base.add(i)); }
}
```

### U-022: 内存对齐检查应使用 align_of 和 align_to

```rust
// ✅ 推荐
use std::ptr;

let misalignment = ptr::align_of::<u64>();
if addr % misalignment != 0 {
    // 需要对齐调整
}
```

### U-023: 使用 #[track_caller] 追踪 unsafe 调用位置

```rust
// ✅ 推荐
#[inline]
#[track_caller]
pub unsafe fn unchecked_get_unchecked<T>(index: usize) -> &T {
    // ...
}
```

---

## 低危规则（黄色 - 参考建议）

### U-024: 优先使用引用而非裸指针

```rust
// ✅ 推荐
fn process_data(data: &[u8]) { ... }

// 仅在需要别名时使用裸指针
```

### U-025: 避免将同一个指针转换为多种类型

```rust
// ✅ 推荐 - 统一类型转换
let ptr: *const Header = buffer.as_ptr().cast();
// 保持 ptr 为 Header 类型使用
```

### U-026: 使用 NonNull 代替 null 检查的 *const/*mut

```rust
// ✅ 推荐
use std::ptr::NonNull;

let ptr = NonNull::dangling();  // 总是有效
if let Some(data) = NonNull::new(ptr) {
    // ...
}
```

### U-027: 考虑使用 Pin 固定自引用结构

```rust
// ✅ 推荐
use std::pin::Pin;

struct SelfRef {
    data: u32,
    ptr: *const u32,
}

impl SelfRef {
    fn new(data: u32) -> Pin<Box<Self>> {
        let mut this = Box::pin(SelfRef {
            data,
            ptr: std::ptr::null(),
        });
        // 安全地设置自引用
        let self_ptr: *const u32 = &this.data;
        unsafe { Pin::get_unchecked_mut(&mut *this).ptr = self_ptr; }
        this
    }
}
```

### U-028: FFI 错误处理使用 Result 类型

```rust
// ✅ 推荐
extern "C" {
    fn risky_operation() -> c_int;
}

fn safe_risky_operation() -> Result<(), FfiError> {
    let result = unsafe { risky_operation() };
    if result == 0 {
        Ok(())
    } else {
        Err(FfiError::from_raw_error(result))
    }
}
```

### U-029: 避免在库 API 中暴露 unsafe

```rust
// ✅ 推荐 - 内部 unsafe，外部安全抽象
pub fn safe_process(data: &[u8]) -> Result<Output, Error> {
    // 内部可以使用 unsafe，但对外提供安全接口
    unsafe { self.inner.process_unsafe(data) }
}
```

### U-030: 使用 addr_of! 获取字段地址

```rust
// ✅ 推荐 - 避免创建临时引用
let field_addr = unsafe { std::ptr::addr_of!(structure.field) };
```

### U-031: 考虑使用地址不变性（address innocence）

```rust
// ✅ 推荐
fn compare_ptrs<T>(p1: *const T, p2: *const T) -> bool {
    p1 == p2
}
```

### U-032: 为复杂的 unsafe 操作创建安全包装器

```rust
// ✅ 推荐
pub struct SafeBuffer {
    ptr: NonNull<u8>,
    size: usize,
}

impl SafeBuffer {
    pub fn new(size: usize) -> Result<Self, AllocError> {
        let ptr = NonNull::new(unsafe {
            libc::malloc(size) as *mut u8
        }).ok_or(AllocError)?;
        Ok(SafeBuffer { ptr, size })
    }

    pub fn as_slice(&self) -> &[u8] {
        unsafe { std::slice::from_raw_parts(self.ptr.as_ptr(), self.size) }
    }

    // 自动释放内存
    impl Drop for SafeBuffer {
        fn drop(&mut self) {
            unsafe { libc::free(self.ptr.as_ptr() as *mut libc::c_void); }
        }
    }
}
```

### U-033: 避免使用 transmute 进行类型转换

```rust
// ✅ 推荐 - 使用更安全的替代方案
let bytes: [u8; 4] = u32::to_ne_bytes(value);

// 仅在必要时使用 transmute，并记录原因
unsafe {
    std::mem::transmute::<u32, [u8; 4]>(value)
}
```

### U-034: 考虑使用 ManuallyDrop 处理特殊释放顺序

```rust
// ✅ 推荐
use std::mem::ManuallyDrop;

struct SpecialResource {
    handle: ResourceHandle,
    metadata: Metadata,
}

impl Drop for SpecialResource {
    fn drop(&mut self) {
        // 确保 metadata 先释放
        let metadata = ManuallyDrop::take(&mut self.metadata);
        drop(metadata);

        // 然后释放 handle
        unsafe { self.handle.release(); }
    }
}
```

### U-035: 使用 copy_nonoverlapping 时的重叠检查

```rust
// ✅ 推荐
use std::ptr::{copy_nonoverlapping, copy};

let dest = target.as_mut_ptr();
let src = source.as_ptr();

if dest as usize >= src as usize + source.len() {
    // 无重叠，可以安全使用 copy_nonoverlapping
    unsafe { copy_nonoverlapping(src, dest, source.len()); }
} else {
    // 有重叠风险，使用 copy
    unsafe { copy(src, dest, source.len()); }
}
```

### U-036: 为 unsafe 代码编写集成测试

```rust
// ✅ 推荐
#[cfg(test)]
mod unsafe_api_tests {
    use super::*;

    #[test]
    fn test_unsafe_pointer_operations() {
        let mut value = 42i32;
        let ptr = &mut value as *mut i32;

        unsafe {
            assert_eq!(read_ptr(ptr), 42);
            write_ptr(ptr, 100);
        }
        assert_eq!(value, 100);
    }
}
```

### U-037: 考虑使用地址混淆保护安全关键数据

```rust
// ✅ 推荐 - 简单 XOR 混淆
fn obfuscate<T>(value: &mut T, key: u64) {
    let bytes = unsafe {
        std::slice::from_raw_parts_mut(
            value as *mut T as *mut u8,
            std::mem::size_of::<T>()
        )
    };
    for byte in bytes {
        *byte ^= key as u8;
    }
}
```

### U-038: 避免在泛型代码中产生过多 monomorphization

```rust
// ✅ 推荐 - 抽象到单一实现
fn generic_process<T: Processable>(data: &mut [T]) {
    let ptr = data.as_mut_ptr();
    for i in 0..data.len() {
        unsafe { ptr.add(i).process(); }
    }
}
```

### U-039: 使用地址比较时考虑 provenance

```rust
// ✅ 推荐
fn is_same_object<T>(a: &T, b: &T) -> bool {
    std::ptr::eq(a as *const T, b as *const T)
}
```

### U-040: 考虑使用地址空间布局随机化（ASLR）

```rust
// ✅ 推荐
fn random_offset(base: usize, range: usize) -> usize {
    let random = fastrand::u32(0..1000) as usize;
    base + (random % range)
}
```

### U-041: 避免使用全局可变状态

```rust
// ✅ 推荐 - 使用线程局部存储
thread_local! {
    static THREAD_BUFFER: RefCell<Vec<u8>> = RefCell::new(Vec::new());
}
```

### U-042: 使用 zeroed() 后必须初始化

```rust
// ✅ 推荐
let mut value: MaybeUninit<ComplexType> = MaybeUninit::uninit();
// ... 初始化所有字段
let value = unsafe { value.assume_init() };
```

### U-043: 考虑内存对齐对性能的影响

```rust
// ✅ 推荐 - 结构体按大小排序
#[repr(C)]
struct OptimizedLayout {
    a: u64,    // 8 字节
    b: u32,    // 4 字节
    c: u8,     // 1 字节
    _pad: [u8; 3],  // 填充到 16 字节对齐
}
```

### U-044: 避免在 unsafe 中调用 drop

```rust
// ✅ 推荐 - 使用 ManuallyDrop
use std::mem::ManuallyDrop;

let mut resource = ManuallyDrop::new(Resource::new());
// ... 使用资源
ManuallyDrop::drop(&mut resource);  // 显式调用
```

### U-045: 使用地址标记检测 use-after-free

```rust
// ✅ 推荐 - 简单哨兵值
const FREED_MARKER: usize = 0xDEADBEEF;

fn deallocate(ptr: &mut usize) {
    unsafe { libc::free(*ptr as *mut libc::c_void); }
    *ptr = FREED_MARKER;
}

fn access(ptr: &mut usize) -> bool {
    if *ptr == FREED_MARKER {
        return false;  // 已释放
    }
    // 安全访问
    true
}
```

### U-046: 考虑使用 miri 检测 undefined behavior

```cargo
[profile.dev]
debug = 1

[dev-dependencies]
miri = "0.1"
```

```bash
cargo +nightly miri test
```

### U-047: 定期审查 unsafe 代码覆盖率

```rust
// 使用 coverage 工具分析
#[unsafe_code_analysis::covered]
unsafe fn complex_operation() {
    // ...
}
```

---

## 规则速查表

| 级别 | 规则数 | 说明 |
|-----|-------|------|
| 🔴 高危 | 12 | 必须遵守，违反会导致 UB |
| 🟠 中危 | 15 | 建议遵守，提高代码安全性 |
| 🟡 低危 | 20 | 参考建议，代码质量优化 |

---

## 关联技能
- `rust-unsafe` - Unsafe 代码基础
- `rust-ffi` - 跨语言调用
- `rust-ownership` - 所有权与借用

