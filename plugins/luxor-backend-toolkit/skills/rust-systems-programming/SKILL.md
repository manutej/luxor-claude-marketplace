---
name: rust-systems-programming
description: Complete guide for Rust systems programming including ownership, borrowing, concurrency, async programming, unsafe code, and performance optimization
tags: [rust, systems-programming, ownership, concurrency, async, memory-safety, performance]
tier: tier-1
---

# Rust Systems Programming

A comprehensive skill for building high-performance, memory-safe systems software using Rust. This skill covers ownership, borrowing, concurrency, async programming, unsafe code, FFI, and performance optimization for systems-level development.

## When to Use This Skill

Use this skill when:

- Building systems software requiring memory safety without garbage collection
- Developing high-performance applications with zero-cost abstractions
- Writing concurrent or parallel programs with data race prevention
- Creating async/await applications for I/O-bound workloads (web servers, databases)
- Working with low-level code, FFI, or hardware interfaces
- Replacing C/C++ code with safer alternatives
- Building command-line tools, network services, or embedded systems
- Optimizing performance-critical sections of applications
- Creating libraries that guarantee memory safety at compile time
- Developing WebAssembly modules for near-native performance

## Core Concepts

### The Ownership Model

Rust's ownership system is the foundation of its memory safety guarantees:

**Ownership Rules:**
1. Each value in Rust has exactly one owner
2. When the owner goes out of scope, the value is dropped
3. Ownership can be transferred (moved) to new owners

**Move Semantics:**

```rust
struct MyStruct { s: u32 }

fn main() {
    let mut x = MyStruct{ s: 5u32 };
    let y = x;  // Ownership moved from x to y
    // x.s = 6;  // ERROR: x is no longer valid
    // println!("{}", x.s);  // ERROR: cannot use x after move
}
```

When a type doesn't implement `Copy`, assignment moves ownership rather than copying. This prevents double-free errors and use-after-move bugs at compile time.

**For Copy Types:**

```rust
let x = 5;  // i32 implements Copy
let y = x;  // x is copied, not moved
println!("{}", x);  // OK: x is still valid
```

### Borrowing and References

Borrowing allows temporary access to data without taking ownership:

**Immutable Borrowing:**

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);  // Borrow s1 immutably

    println!("The length of '{}' is {}.", s1, len);  // s1 still valid
}

fn calculate_length(s: &String) -> usize {
    s.len()  // Can read but not modify
}
```

**Mutable Borrowing:**

Rust enforces exclusive mutable access to prevent data races:

```rust
fn main() {
    let mut value = 3;
    let borrow = &mut value;  // Mutable borrow
    *borrow += 1;
    println!("{}", borrow);  // 4

    // value is accessible again after borrow ends
}
```

**Borrowing Rules:**
- You can have either one mutable reference OR any number of immutable references
- References must always be valid (no dangling pointers)
- Mutable and immutable borrows cannot coexist

**Common Borrowing Error:**

```rust
fn main() {
    let mut value = 3;
    // Create a mutable borrow of `value`.
    let borrow = &mut value;
    let _sum = value + 1; // ERROR: cannot use `value` because
                          //        it was mutably borrowed
    println!("{}", borrow);
}
```

### Lifetimes

Lifetimes ensure references are always valid:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

The `'a` lifetime parameter tells the compiler that the returned reference will be valid as long as both input references are valid.

### Ownership Patterns for Sharing

**Rc (Reference Counted) for Single-threaded Shared Ownership:**

```rust
use std::cell::RefCell;
use std::rc::Rc;

struct MyStruct { s: u32 }

fn main() {
    let mut x = Rc::new(RefCell::new(MyStruct{ s: 5u32 }));
    let y = x.clone();  // Increment reference count
    x.borrow_mut().s = 6;  // Interior mutability via RefCell
    println!("{}", x.borrow().s);
}
```

`Rc<T>` provides shared ownership with reference counting. `RefCell<T>` enables interior mutability, enforcing borrow rules at runtime rather than compile time.

**Arc (Atomic Reference Counted) for Thread-safe Sharing:**

```rust
use std::sync::Arc;
use std::thread;

struct FancyNum {
    num: u8,
}

fn main() {
    let fancy_ref1 = Arc::new(FancyNum { num: 5 });
    let fancy_ref2 = fancy_ref1.clone();

    let x = thread::spawn(move || {
        // `fancy_ref1` can be moved and has a `'static` lifetime
        println!("child thread: {}", fancy_ref1.num);
    });

    x.join().expect("child thread should finish");
    println!("main thread: {}", fancy_ref2.num);
}
```

`Arc<T>` is the thread-safe version of `Rc<T>`, using atomic operations for reference counting.

### Box for Heap Allocation

```rust
Box<T>
```

`Box<T>` is an owning pointer that allocates `T` on the heap. Useful for:
- Recursive types with known size
- Large values that should not be copied on the stack
- Trait objects with dynamic dispatch

## Concurrency Patterns

### Threads and Message Passing

Rust prevents data races at compile time through its ownership system:

```rust
use std::thread;
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        tx.send("Hello from thread").unwrap();
    });

    let message = rx.recv().unwrap();
    println!("{}", message);
}
```

### Shared State with Mutex

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

**Key Concurrency Types:**
- `Mutex<T>`: Mutual exclusion lock for shared mutable state
- `RwLock<T>`: Reader-writer lock allowing multiple readers or one writer
- `Arc<T>`: Atomic reference counting for thread-safe sharing
- `mpsc`: Multi-producer, single-consumer channels

### Data Race Prevention

**ThreadSanitizer Example:**

```rust
static mut A: usize = 0;

fn main() {
    let t = std::thread::spawn(|| {
        unsafe { A += 1 };
    });
    unsafe { A += 1 };

    t.join().unwrap();
}
```

This code has a data race. ThreadSanitizer (enabled with `RUSTFLAGS=-Zsanitizer=thread`) detects concurrent access to static mutable data:

```
WARNING: ThreadSanitizer: data race (pid=10574)
  Read of size 8 at 0x5632dfe3d030 by thread T1:
  Previous write of size 8 at 0x5632dfe3d030 by main thread:
```

## Async Programming

### Async/Await Basics

Async programming in Rust allows concurrent I/O without blocking threads:

```rust
async fn foo(n: usize) {
    if n > 0 {
        Box::pin(foo(n - 1)).await;
    }
}
```

Recursive async functions require `Box::pin()` to give the future a known size.

### Async Closures

**Async Closure with Move Semantics:**

```rust
fn force_fnonce<T: async FnOnce()>(t: T) -> T { t }

let x = String::new();
let c = force_fnonce(async move || {
    println!("{x}");
});
```

When constrained to `AsyncFnOnce`, the closure captures by move to ensure proper ownership.

**Async Closure Borrowing:**

```rust
let x = &1i32; // Lifetime '1
let c = async move || {
    println!("{:?}", *x);
    // Even though the closure moves x, we're only capturing *x,
    // so the inner coroutine can reborrow the data for its original lifetime.
};
```

**Mutable Borrowing in Async Closures:**

```rust
let mut x = 1i32;
let c = async || {
    x = 1;
    // The parent borrows `x` mutably.
    // When we call `c()`, we implicitly autoref for `AsyncFnMut::async_call_mut`.
    // The inner coroutine captures with the lifetime of the coroutine-closure.
};
```

### Common Async Errors

**E0373: Async block capturing short-lived variable:**

```rust
use std::future::Future;

async fn f() {
    let v = vec![1, 2, 3i32];
    spawn(async { //~ ERROR E0373
        println!("{:?}", v)  // v might go out of scope before async block runs
    });
}

fn spawn<F: Future + Send + 'static>(future: F) {
    unimplemented!()
}
```

Solution: Move the variable into the async block:

```rust
spawn(async move {
    println!("{:?}", v)
})
```

## Unsafe Code and FFI

### When to Use Unsafe

Rust's `unsafe` keyword allows operations that the compiler cannot verify:

1. Dereferencing raw pointers
2. Calling unsafe functions or methods
3. Accessing or modifying mutable static variables
4. Implementing unsafe traits
5. Accessing fields of unions

**Unsafe Dereference Example:**

```rust
macro_rules! unsafe_deref {
    () => {
        *(&() as *const ())
    };
}
```

### Memory Safety with Unsafe

**Unsafe Sync Implementation:**

```rust
use std::cell::Cell;

struct NotThreadSafe<T> {
    value: Cell<T>,
}

unsafe impl<T> Sync for NotThreadSafe<T> {}

static A: NotThreadSafe<usize> = NotThreadSafe { value : Cell::new(1) };
static B: &'static NotThreadSafe<usize> = &A; // ok!
```

This is `unsafe` because you must manually ensure thread safety. `Cell` is not `Sync` by default, so this implementation requires careful reasoning.

### FFI (Foreign Function Interface)

**Calling C Functions from Rust:**

```rust
use std::mem;

#[link(name = "foo")]
extern "C" {
    fn do_twice(f: unsafe extern "C" fn(i32) -> i32, arg: i32) -> i32;
}

unsafe extern "C" fn add_one(x: i32) -> i32 {
    x + 1
}

unsafe extern "C" fn add_two(x: i64) -> i64 {
    x + 2
}

fn main() {
    let answer = unsafe { do_twice(add_one, 5) };
    println!("The answer is: {}", answer);

    // Type-mismatched call (unsafe):
    println!("With CFI enabled, you should not see the next answer");
    let f: unsafe extern "C" fn(i32) -> i32 = unsafe {
        mem::transmute::<*const u8, unsafe extern "C" fn(i32) -> i32>(add_two as *const u8)
    };
    let next_answer = unsafe { do_twice(f, 5) };
    println!("The next answer is: {}", next_answer);
}
```

**Control Flow Integrity (CFI):**
With CFI enabled, the type-mismatched transmute causes program termination, preventing control flow hijacking.

**Inline Assembly for System Calls:**

```rust
static UNMAP_BASE: usize;
const MEM_RELEASE: usize;
static VirtualFree: usize;
const OffPtr: usize;
const OffFn: usize;

core::arch::asm!("
    push {free_type}
    push {free_size}
    push {base}

    mov eax, fs:[30h]
    mov eax, [eax+8h]
    add eax, {off_fn}
    mov [eax-{off_fn}+{off_ptr}], eax

    push eax

    jmp {virtual_free}
    ",
    off_ptr = const OffPtr,
    off_fn  = const OffFn,

    free_size = const 0,
    free_type = const MEM_RELEASE,

    virtual_free = sym VirtualFree,

    base = sym UNMAP_BASE,
    options(noreturn),
);
```

This demonstrates direct system calls using inline assembly for Windows memory deallocation.

## Error Handling

### Result and Option Types

Rust uses `Result<T, E>` and `Option<T>` for error handling:

```rust
fn divide(a: i32, b: i32) -> Result<i32, String> {
    if b == 0 {
        Err("Division by zero".to_string())
    } else {
        Ok(a / b)
    }
}

fn main() {
    match divide(10, 2) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }
}
```

### The ? Operator

```rust
fn process_file(path: &str) -> Result<String, std::io::Error> {
    let content = std::fs::read_to_string(path)?;
    Ok(content.to_uppercase())
}
```

The `?` operator propagates errors up the call stack, similar to exceptions but explicit in the type signature.

### Custom Error Types

```rust
use std::fmt;

#[derive(Debug)]
enum AppError {
    IoError(std::io::Error),
    ParseError(std::num::ParseIntError),
    Custom(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::IoError(e) => write!(f, "IO error: {}", e),
            AppError::ParseError(e) => write!(f, "Parse error: {}", e),
            AppError::Custom(msg) => write!(f, "Error: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}
```

## Memory Safety and Sanitizers

### AddressSanitizer

**Detecting Stack Buffer Overflow:**

```rust
fn main() {
    let xs = [0, 1, 2, 3];
    let _y = unsafe { *xs.as_ptr().offset(4) };
}
```

Build with AddressSanitizer:
```shell
$ export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
$ cargo run -Zbuild-std --target x86_64-unknown-linux-gnu
```

Output:
```
==37882==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffe400e6250
READ of size 4 at 0x7ffe400e6250 thread T0
    #0 0x5609a841fb1f in example::main::h628ffc6626ed85b2 /.../src/main.rs:3:23

Address 0x7ffe400e6250 is located in stack of thread T0 at offset 48 in frame
  This frame has 1 object(s):
    [32, 48) 'xs' (line 2) <== Memory access at offset 48 overflows this variable
```

**Detecting Heap Buffer Overflow:**

```rust
fn main() {
    let xs = vec![0, 1, 2, 3];
    let _y = unsafe { *xs.as_ptr().offset(4) };
}
```

**Detecting Use-After-Scope:**

```rust
static mut P: *mut usize = std::ptr::null_mut();

fn main() {
    unsafe {
        {
            let mut x = 0;
            P = &mut x;
        }
        std::ptr::write_volatile(P, 123);  // P points to dropped variable
    }
}
```

AddressSanitizer output:
```
==39249==ERROR: AddressSanitizer: stack-use-after-scope on address 0x7ffc7ed3e1a0
WRITE of size 8 at 0x7ffc7ed3e1a0 thread T0
```

## Performance Optimization

### Zero-Cost Abstractions

Rust provides high-level abstractions without runtime overhead:

```rust
// Iterator chains are optimized to simple loops
let sum: i32 = (1..100)
    .filter(|x| x % 2 == 0)
    .map(|x| x * x)
    .sum();
```

The compiler optimizes this to a tight loop equivalent to manual iteration.

### Inlining and Monomorphization

Generic functions are monomorphized (specialized) for each concrete type:

```rust
#[inline]
fn add<T: std::ops::Add<Output = T>>(a: T, b: T) -> T {
    a + b
}

let x = add(5, 3);      // Specialized for i32
let y = add(5.0, 3.0);  // Specialized for f64
```

### Smart Pointer Overhead

Different smart pointers have different costs:
- `Box<T>`: Single heap allocation, no overhead
- `Rc<T>`: Reference counting, small overhead per clone/drop
- `Arc<T>`: Atomic reference counting, higher overhead for thread safety
- `Mutex<T>`: Lock acquisition overhead
- `RefCell<T>`: Runtime borrow checking overhead

### Avoiding Allocations

```rust
// Bad: Allocates a new String
fn greet_bad(name: &str) -> String {
    format!("Hello, {}", name)
}

// Good: Returns a reference, no allocation
fn greet_good(name: &str) -> impl std::fmt::Display + '_ {
    format_args!("Hello, {}", name)
}
```

## Common Patterns and Idioms

### Builder Pattern

```rust
struct Config {
    host: String,
    port: u16,
    timeout: u64,
}

impl Config {
    fn builder() -> ConfigBuilder {
        ConfigBuilder::default()
    }
}

#[derive(Default)]
struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<u64>,
}

impl ConfigBuilder {
    fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    fn build(self) -> Config {
        Config {
            host: self.host.unwrap_or_else(|| "localhost".to_string()),
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(30),
        }
    }
}
```

### Newtype Pattern

```rust
struct UserId(u64);
struct PostId(u64);

fn get_user(id: UserId) -> User { /* ... */ }

// This won't compile: type safety!
// get_user(PostId(42));
```

### RAII (Resource Acquisition Is Initialization)

```rust
struct FileGuard {
    file: std::fs::File,
}

impl FileGuard {
    fn new(path: &str) -> std::io::Result<Self> {
        Ok(FileGuard {
            file: std::fs::File::create(path)?,
        })
    }
}

impl Drop for FileGuard {
    fn drop(&mut self) {
        println!("File closed automatically");
    }
}
```

## Closure Patterns and Errors

### E0500: Closure Borrowing Conflict

**Problem:**

```rust
fn you_know_nothing(jon_snow: &mut i32) {
    let nights_watch = &jon_snow;
    let starks = || {
        *jon_snow = 3; // error: closure requires unique access to `jon_snow`
                       //        but it is already borrowed
    };
    println!("{}", nights_watch);
}
```

**Solution:**

```rust
fn you_know_nothing(jon_snow: &mut i32) {
    let nights_watch = &jon_snow;
    println!("{}", nights_watch);  // Use the borrow first
    // Borrow ends here (non-lexical lifetimes)
    let starks = || {
        *jon_snow = 3;  // Now OK
    };
}
```

### E0502: Mutable and Immutable Borrows

**Problem:**

```rust
fn bar(x: &mut i32) {}
fn foo(a: &mut i32) {
    let y = &a;
    bar(a);  // Error: cannot borrow as mutable while borrowed as immutable
    println!("{}", y);
}
```

**Solution:**

```rust
fn bar(x: &mut i32) {}
fn foo(a: &mut i32) {
    bar(a);  // Mutable borrow first
    let y = &a; // Immutable borrow after mutable borrow ends
    println!("{}", y);
}
```

### E0505: Move of Borrowed Value

**Problem:**

```rust
struct Value {}

fn borrow(val: &Value) {}
fn eat(val: Value) {}

fn main() {
    let x = Value{};
    let _ref_to_val: &Value = &x;
    eat(x);  // Error: cannot move x while borrowed
    borrow(_ref_to_val);
}
```

### E0524: Concurrent Mutable Borrows in Closures

**Problem:**

```rust
fn set(x: &mut isize) {
    *x += 4;
}

fn dragoooon(x: &mut isize) {
    let mut c1 = || set(x);
    let mut c2 = || set(x); // error: two closures trying to borrow mutably
    c2();
    c1();
}
```

**Solution 1: Sequential Execution (Non-Lexical Lifetimes)**

```rust
fn set(x: &mut isize) {
    *x += 4;
}

fn dragoooon(x: &mut isize) {
    {
        let mut c1 = || set(&mut *x);
        c1();
    } // `c1` has been dropped here so we're free to use `x` again!
    let mut c2 = || set(&mut *x);
    c2();
}
```

**Solution 2: Rc + RefCell for Shared Mutable Access**

```rust
use std::rc::Rc;
use std::cell::RefCell;

fn set(x: &mut isize) {
    *x += 4;
}

fn dragoooon(x: &mut isize) {
    let x = Rc::new(RefCell::new(x));
    let y = Rc::clone(&x);
    let mut c1 = || { let mut x2 = x.borrow_mut(); set(&mut x2); };
    let mut c2 = || { let mut x2 = y.borrow_mut(); set(&mut x2); };

    c2();
    c1();
}
```

### E0507: Moving Borrowed Content

**Problem:**

```rust
use std::cell::RefCell;

struct TheDarkKnight;

impl TheDarkKnight {
    fn nothing_is_true(self) {}
}

fn main() {
    let x = RefCell::new(TheDarkKnight);
    x.borrow().nothing_is_true(); // Error: cannot move out of borrowed content
}
```

**Solution 1: Take a Reference**

```rust
impl TheDarkKnight {
    fn nothing_is_true(&self) {}  // Change to &self
}

fn main() {
    let x = RefCell::new(TheDarkKnight);
    x.borrow().nothing_is_true(); // OK
}
```

**Solution 2: Reclaim Ownership**

```rust
fn main() {
    let x = RefCell::new(TheDarkKnight);
    let x = x.into_inner(); // Reclaim ownership
    x.nothing_is_true(); // OK
}
```

## Production Patterns

### Structured Logging

```rust
use tracing::{info, warn, error, instrument};

#[instrument]
async fn process_request(id: u64) -> Result<(), Error> {
    info!(request_id = id, "Processing request");

    match do_work(id).await {
        Ok(_) => {
            info!("Request completed successfully");
            Ok(())
        }
        Err(e) => {
            error!(error = ?e, "Request failed");
            Err(e)
        }
    }
}
```

### Configuration Management

```rust
use serde::Deserialize;

#[derive(Deserialize)]
struct AppConfig {
    database_url: String,
    server_port: u16,
    log_level: String,
}

fn load_config() -> Result<AppConfig, config::ConfigError> {
    config::Config::builder()
        .add_source(config::File::with_name("config"))
        .add_source(config::Environment::with_prefix("APP"))
        .build()?
        .try_deserialize()
}
```

### Graceful Shutdown

```rust
use tokio::signal;

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }

    println!("Shutdown signal received, starting graceful shutdown");
}
```

### Connection Pooling

```rust
use deadpool_postgres::{Config, Pool, Runtime};
use tokio_postgres::NoTls;

async fn create_pool() -> Pool {
    let mut cfg = Config::new();
    cfg.host = Some("localhost".to_string());
    cfg.dbname = Some("mydb".to_string());

    cfg.create_pool(Some(Runtime::Tokio1), NoTls)
        .expect("Failed to create pool")
}

async fn query_user(pool: &Pool, id: i64) -> Result<User, Error> {
    let client = pool.get().await?;
    let row = client
        .query_one("SELECT * FROM users WHERE id = $1", &[&id])
        .await?;
    Ok(User::from_row(row))
}
```

## Best Practices

### API Design

1. **Use References by Default**: Accept `&T` instead of `T` unless you need ownership
2. **Return Owned Types**: Return `String` instead of `&str` for simpler APIs
3. **Implement Standard Traits**: `Debug`, `Clone`, `PartialEq`, `Send`, `Sync`
4. **Use `Into<T>` for Flexibility**: `fn set_name(&mut self, name: impl Into<String>)`
5. **Leverage the Type System**: Use newtypes, enums, and Result for correctness

### Testing Patterns

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_addition() {
        assert_eq!(add(2, 2), 4);
    }

    #[test]
    #[should_panic(expected = "division by zero")]
    fn test_divide_by_zero() {
        divide(10, 0);
    }

    #[tokio::test]
    async fn test_async_function() {
        let result = fetch_data().await;
        assert!(result.is_ok());
    }
}
```

### Documentation

```rust
/// Calculates the sum of two numbers.
///
/// # Examples
///
/// ```
/// let result = add(2, 2);
/// assert_eq!(result, 4);
/// ```
///
/// # Panics
///
/// This function will panic if the result overflows.
pub fn add(a: i32, b: i32) -> i32 {
    a.checked_add(b).expect("overflow in add")
}
```

### Dependency Management

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
tracing = "0.1"

[dev-dependencies]
criterion = "0.5"

[profile.release]
lto = true
codegen-units = 1
```

## Troubleshooting

### Common Borrow Checker Issues

**Issue**: "Cannot borrow as mutable because it is also borrowed as immutable"
**Solution**: Ensure mutable and immutable borrows don't overlap in scope

**Issue**: "Cannot move out of borrowed content"
**Solution**: Clone the value, take a reference, or use `Rc<RefCell<T>>`

**Issue**: "Lifetime issues with references"
**Solution**: Add explicit lifetime annotations or restructure code to avoid complex lifetimes

### Performance Issues

**Issue**: Slow compilation times
**Solution**: Use incremental compilation, reduce generic instantiations, use `cargo check`

**Issue**: Runtime performance slower than expected
**Solution**: Profile with `perf`, enable LTO, check for unnecessary allocations/clones

**Issue**: High memory usage
**Solution**: Use references instead of clones, consider streaming data, profile with Valgrind

### Concurrency Issues

**Issue**: Deadlocks with multiple mutexes
**Solution**: Always acquire locks in the same order, use `try_lock` with timeout

**Issue**: Data races in unsafe code
**Solution**: Run with ThreadSanitizer, carefully review unsafe blocks

**Issue**: Async tasks not making progress
**Solution**: Check for blocking operations in async code, use `spawn_blocking` for CPU-bound work

## Quick Reference

### Smart Pointer Cheat Sheet

```
Box<T>     - Heap allocation, single owner
Rc<T>      - Reference counted, single-threaded
Arc<T>     - Atomic reference counted, thread-safe
Mutex<T>   - Mutual exclusion lock
RwLock<T>  - Reader-writer lock
RefCell<T> - Runtime borrow checking
Cell<T>    - Interior mutability for Copy types
```

### Common Trait Implementations

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct MyStruct {
    field: String,
}

impl Default for MyStruct {
    fn default() -> Self {
        Self {
            field: String::new(),
        }
    }
}

impl std::fmt::Display for MyStruct {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "MyStruct({})", self.field)
    }
}
```

### Async Runtime Comparison

```
Tokio:    Full-featured, most popular, excellent ecosystem
async-std: Mirrors std library API, simpler for beginners
smol:     Lightweight, minimal dependencies
```

## Resources

- The Rust Book: https://doc.rust-lang.org/book/
- Rust by Example: https://doc.rust-lang.org/rust-by-example/
- The Rustonomicon (unsafe Rust): https://doc.rust-lang.org/nomicon/
- Async Book: https://rust-lang.github.io/async-book/
- Rust Performance Book: https://nnethercote.github.io/perf-book/
- Crate Documentation: https://docs.rs/

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Systems Programming, Performance, Memory Safety
**Context7 Integration**: Rust documentation and error code examples
