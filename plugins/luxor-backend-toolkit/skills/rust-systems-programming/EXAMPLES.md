# Rust Systems Programming Examples

Comprehensive examples for real-world Rust development, covering ownership, concurrency, async programming, unsafe code, and production patterns.

## Table of Contents

1. [Ownership and Borrowing](#ownership-and-borrowing)
2. [Concurrency Patterns](#concurrency-patterns)
3. [Async Programming](#async-programming)
4. [Error Handling](#error-handling)
5. [Unsafe Code and FFI](#unsafe-code-and-ffi)
6. [Memory Safety and Sanitizers](#memory-safety-and-sanitizers)
7. [Performance Optimization](#performance-optimization)
8. [Production Web Server](#production-web-server)
9. [CLI Application](#cli-application)
10. [Database Connection Pool](#database-connection-pool)

---

## Ownership and Borrowing

### Example 1: Basic Ownership and Move Semantics

**Scenario**: Understanding move semantics for non-Copy types

```rust
struct UserData {
    username: String,
    email: String,
    age: u32,
}

fn main() {
    // Create a user
    let user1 = UserData {
        username: String::from("alice"),
        email: String::from("alice@example.com"),
        age: 30,
    };

    // Move ownership to user2
    let user2 = user1;

    // Error: user1 is no longer valid
    // println!("User1: {}", user1.username);

    // user2 owns the data now
    println!("User2: {}", user2.username);
}
```

**Key Points**:
- `UserData` doesn't implement `Copy`, so assignment moves ownership
- After the move, `user1` is invalid and cannot be used
- This prevents double-free errors at compile time

### Example 2: Immutable and Mutable Borrowing

**Scenario**: Reading and modifying data without transferring ownership

```rust
struct BankAccount {
    balance: f64,
}

impl BankAccount {
    fn new(initial: f64) -> Self {
        BankAccount { balance: initial }
    }

    fn deposit(&mut self, amount: f64) {
        self.balance += amount;
    }

    fn get_balance(&self) -> f64 {
        self.balance
    }
}

fn apply_interest(account: &mut BankAccount, rate: f64) {
    let interest = account.get_balance() * rate;
    account.deposit(interest);
}

fn display_balance(account: &BankAccount) {
    println!("Balance: ${:.2}", account.get_balance());
}

fn main() {
    let mut account = BankAccount::new(1000.0);

    // Immutable borrow for reading
    display_balance(&account);

    // Mutable borrow for modification
    apply_interest(&mut account, 0.05);

    // Can borrow again after previous borrow ends
    display_balance(&account);
}
```

**Key Points**:
- Immutable borrows (`&T`) allow reading but not modifying
- Mutable borrows (`&mut T`) allow modification but must be exclusive
- Original owner retains ownership and can use the value after borrows end

### Example 3: Shared Ownership with Rc and RefCell

**Scenario**: Multiple ownership with interior mutability (single-threaded)

```rust
use std::cell::RefCell;
use std::rc::Rc;

struct Document {
    title: String,
    content: String,
    view_count: u32,
}

impl Document {
    fn new(title: String) -> Self {
        Document {
            title,
            content: String::new(),
            view_count: 0,
        }
    }

    fn increment_views(&mut self) {
        self.view_count += 1;
    }

    fn add_content(&mut self, text: &str) {
        self.content.push_str(text);
    }
}

struct Editor {
    doc: Rc<RefCell<Document>>,
}

impl Editor {
    fn edit(&self, text: &str) {
        self.doc.borrow_mut().add_content(text);
    }
}

struct Viewer {
    doc: Rc<RefCell<Document>>,
}

impl Viewer {
    fn view(&self) {
        let mut doc = self.doc.borrow_mut();
        doc.increment_views();
        println!("Viewing: {} (Views: {})", doc.title, doc.view_count);
        println!("Content: {}", doc.content);
    }
}

fn main() {
    let doc = Rc::new(RefCell::new(Document::new("My Document".to_string())));

    let editor = Editor {
        doc: Rc::clone(&doc),
    };

    let viewer = Viewer {
        doc: Rc::clone(&doc),
    };

    editor.edit("Hello, ");
    editor.edit("world!");

    viewer.view();
    viewer.view();

    println!("Reference count: {}", Rc::strong_count(&doc));
}
```

**Key Points**:
- `Rc<T>` provides shared ownership with reference counting
- `RefCell<T>` enables interior mutability with runtime borrow checking
- Use for single-threaded scenarios requiring shared mutable state

### Example 4: Closure Borrowing Patterns

**Scenario**: Understanding closure capture modes and borrowing conflicts

```rust
fn closure_immutable_borrow() {
    let data = vec![1, 2, 3, 4, 5];

    // Closure borrows data immutably
    let print_sum = || {
        let sum: i32 = data.iter().sum();
        println!("Sum: {}", sum);
    };

    print_sum();
    print_sum();

    // data is still accessible
    println!("Original data: {:?}", data);
}

fn closure_mutable_borrow() {
    let mut counter = 0;

    // Closure borrows counter mutably
    let mut increment = || {
        counter += 1;
    };

    increment();
    increment();

    // Cannot access counter here while increment holds mutable borrow
    // println!("{}", counter);  // ERROR

    drop(increment);  // Explicitly drop to end borrow

    // Now we can access counter
    println!("Final count: {}", counter);
}

fn closure_move_semantics() {
    let data = vec![1, 2, 3];

    // Move data into closure
    let process = move || {
        println!("Processing: {:?}", data);
        data.len()
    };

    let len = process();
    println!("Length: {}", len);

    // Cannot access data here - it was moved
    // println!("{:?}", data);  // ERROR
}

fn main() {
    closure_immutable_borrow();
    closure_mutable_borrow();
    closure_move_semantics();
}
```

**Key Points**:
- Closures automatically borrow variables from their environment
- Use `move` keyword to transfer ownership into closure
- Mutable borrows in closures must be exclusive

---

## Concurrency Patterns

### Example 5: Thread-Safe Shared State with Arc and Mutex

**Scenario**: Multiple threads incrementing a shared counter safely

```rust
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

struct Metrics {
    requests: u64,
    errors: u64,
}

impl Metrics {
    fn new() -> Self {
        Metrics {
            requests: 0,
            errors: 0,
        }
    }

    fn record_request(&mut self, is_error: bool) {
        self.requests += 1;
        if is_error {
            self.errors += 1;
        }
    }

    fn error_rate(&self) -> f64 {
        if self.requests == 0 {
            0.0
        } else {
            (self.errors as f64 / self.requests as f64) * 100.0
        }
    }
}

fn main() {
    let metrics = Arc::new(Mutex::new(Metrics::new()));
    let mut handles = vec![];

    // Spawn 10 worker threads
    for i in 0..10 {
        let metrics = Arc::clone(&metrics);

        let handle = thread::spawn(move || {
            for j in 0..100 {
                // Simulate work
                thread::sleep(Duration::from_millis(1));

                // Record metric (10% error rate)
                let is_error = (i + j) % 10 == 0;

                let mut m = metrics.lock().unwrap();
                m.record_request(is_error);
            }
        });

        handles.push(handle);
    }

    // Wait for all threads to complete
    for handle in handles {
        handle.join().unwrap();
    }

    // Print final metrics
    let m = metrics.lock().unwrap();
    println!("Total requests: {}", m.requests);
    println!("Total errors: {}", m.errors);
    println!("Error rate: {:.2}%", m.error_rate());
}
```

**Key Points**:
- `Arc<T>` enables thread-safe shared ownership with atomic reference counting
- `Mutex<T>` provides mutual exclusion for safe mutable access
- Lock guard automatically releases the lock when dropped

### Example 6: Message Passing with Channels

**Scenario**: Producer-consumer pattern with multiple workers

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

enum Task {
    Process(String),
    Shutdown,
}

struct Worker {
    id: usize,
    thread: thread::JoinHandle<()>,
}

impl Worker {
    fn new(id: usize, receiver: std::sync::Arc<std::sync::Mutex<mpsc::Receiver<Task>>>) -> Self {
        let thread = thread::spawn(move || {
            loop {
                let task = receiver.lock().unwrap().recv().unwrap();

                match task {
                    Task::Process(data) => {
                        println!("Worker {} processing: {}", id, data);
                        thread::sleep(Duration::from_millis(100));
                        println!("Worker {} finished: {}", id, data);
                    }
                    Task::Shutdown => {
                        println!("Worker {} shutting down", id);
                        break;
                    }
                }
            }
        });

        Worker { id, thread }
    }
}

struct ThreadPool {
    workers: Vec<Worker>,
    sender: mpsc::Sender<Task>,
}

impl ThreadPool {
    fn new(size: usize) -> Self {
        let (sender, receiver) = mpsc::channel();
        let receiver = std::sync::Arc::new(std::sync::Mutex::new(receiver));

        let mut workers = Vec::with_capacity(size);
        for id in 0..size {
            workers.push(Worker::new(id, std::sync::Arc::clone(&receiver)));
        }

        ThreadPool { workers, sender }
    }

    fn execute(&self, data: String) {
        self.sender.send(Task::Process(data)).unwrap();
    }

    fn shutdown(self) {
        for _ in &self.workers {
            self.sender.send(Task::Shutdown).unwrap();
        }

        for worker in self.workers {
            worker.thread.join().unwrap();
        }
    }
}

fn main() {
    let pool = ThreadPool::new(4);

    for i in 0..20 {
        pool.execute(format!("Task {}", i));
    }

    println!("All tasks submitted, shutting down...");
    pool.shutdown();
    println!("All workers finished");
}
```

**Key Points**:
- Channels enable safe message passing between threads
- Multiple producers can send to a single receiver
- Shared receiver wrapped in `Arc<Mutex<>>` for multiple consumers

### Example 7: Reader-Writer Lock Pattern

**Scenario**: Multiple readers, single writer with RwLock

```rust
use std::sync::{Arc, RwLock};
use std::thread;
use std::time::Duration;

struct Cache {
    data: RwLock<std::collections::HashMap<String, String>>,
}

impl Cache {
    fn new() -> Self {
        Cache {
            data: RwLock::new(std::collections::HashMap::new()),
        }
    }

    fn get(&self, key: &str) -> Option<String> {
        // Read lock allows multiple concurrent readers
        let data = self.data.read().unwrap();
        data.get(key).cloned()
    }

    fn set(&self, key: String, value: String) {
        // Write lock ensures exclusive access
        let mut data = self.data.write().unwrap();
        data.insert(key, value);
    }
}

fn main() {
    let cache = Arc::new(Cache::new());

    // Pre-populate cache
    cache.set("user:1".to_string(), "Alice".to_string());
    cache.set("user:2".to_string(), "Bob".to_string());

    let mut handles = vec![];

    // Spawn 10 reader threads
    for i in 0..10 {
        let cache = Arc::clone(&cache);
        let handle = thread::spawn(move || {
            for _ in 0..5 {
                let key = format!("user:{}", (i % 2) + 1);
                if let Some(value) = cache.get(&key) {
                    println!("Reader {} got: {} = {}", i, key, value);
                }
                thread::sleep(Duration::from_millis(10));
            }
        });
        handles.push(handle);
    }

    // Spawn 2 writer threads
    for i in 0..2 {
        let cache = Arc::clone(&cache);
        let handle = thread::spawn(move || {
            for j in 0..3 {
                let key = format!("user:{}", i + 3);
                let value = format!("Writer{}Value{}", i, j);
                cache.set(key.clone(), value.clone());
                println!("Writer {} set: {} = {}", i, key, value);
                thread::sleep(Duration::from_millis(50));
            }
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Final cache size: {}", cache.data.read().unwrap().len());
}
```

**Key Points**:
- `RwLock` allows multiple concurrent readers or one exclusive writer
- Better performance than `Mutex` for read-heavy workloads
- Readers don't block each other, only writers

---

## Async Programming

### Example 8: Async HTTP Client with Tokio

**Scenario**: Fetching multiple URLs concurrently

```rust
use tokio;
use std::time::Duration;

#[derive(Debug)]
struct FetchResult {
    url: String,
    status: String,
    elapsed: Duration,
}

async fn fetch_url(url: &str) -> Result<FetchResult, Box<dyn std::error::Error>> {
    let start = std::time::Instant::now();

    // Simulate HTTP fetch
    tokio::time::sleep(Duration::from_millis(100)).await;

    let result = FetchResult {
        url: url.to_string(),
        status: "200 OK".to_string(),
        elapsed: start.elapsed(),
    };

    Ok(result)
}

async fn fetch_all(urls: Vec<&str>) -> Vec<FetchResult> {
    let mut tasks = vec![];

    for url in urls {
        tasks.push(tokio::spawn(async move {
            fetch_url(url).await
        }));
    }

    let mut results = vec![];
    for task in tasks {
        match task.await {
            Ok(Ok(result)) => results.push(result),
            Ok(Err(e)) => eprintln!("Fetch error: {}", e),
            Err(e) => eprintln!("Task error: {}", e),
        }
    }

    results
}

#[tokio::main]
async fn main() {
    let urls = vec![
        "https://example.com/api/users",
        "https://example.com/api/posts",
        "https://example.com/api/comments",
        "https://example.com/api/profile",
        "https://example.com/api/settings",
    ];

    println!("Fetching {} URLs...", urls.len());
    let start = std::time::Instant::now();

    let results = fetch_all(urls).await;

    println!("\nCompleted {} fetches in {:?}", results.len(), start.elapsed());
    for result in results {
        println!("  {} - {} ({:?})", result.url, result.status, result.elapsed);
    }
}
```

**Key Points**:
- `tokio::spawn` creates concurrent async tasks
- Tasks run concurrently on the async runtime
- Total time is roughly the slowest individual fetch, not the sum

### Example 9: Async Stream Processing

**Scenario**: Processing items from an async stream

```rust
use tokio;
use tokio::time::{sleep, Duration};
use futures::stream::{self, StreamExt};

async fn process_item(item: i32) -> i32 {
    // Simulate async processing
    sleep(Duration::from_millis(100)).await;
    item * 2
}

async fn stream_example() {
    let items = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // Create stream from iterator
    let stream = stream::iter(items);

    // Process items concurrently (buffer up to 4 at a time)
    let results: Vec<i32> = stream
        .map(|item| async move {
            process_item(item).await
        })
        .buffer_unordered(4)
        .collect()
        .await;

    println!("Processed results: {:?}", results);
}

#[tokio::main]
async fn main() {
    let start = std::time::Instant::now();
    stream_example().await;
    println!("Completed in {:?}", start.elapsed());
}
```

**Key Points**:
- Streams enable async iteration over sequences
- `buffer_unordered` processes multiple items concurrently
- Preserves async efficiency while processing collections

### Example 10: Async Closure Patterns

**Scenario**: Using async closures with different capture modes

```rust
use tokio;

async fn async_closure_examples() {
    // Immutable capture
    let data = vec![1, 2, 3, 4, 5];
    let process_immut = async || {
        let sum: i32 = data.iter().sum();
        println!("Sum: {}", sum);
        sum
    };
    let result = process_immut.await;
    println!("Result: {}", result);

    // Move capture
    let owned_data = String::from("Hello, async world!");
    let process_move = async move || {
        println!("Message: {}", owned_data);
        owned_data.len()
    };
    let len = process_move.await;
    println!("Length: {}", len);
    // owned_data is no longer accessible

    // Mutable capture (requires AsyncFnMut)
    let mut counter = 0;
    let mut increment = async || {
        counter += 1;
        println!("Counter: {}", counter);
    };
    increment.await;
    increment.await;
    increment.await;
}

#[tokio::main]
async fn main() {
    async_closure_examples().await;
}
```

**Key Points**:
- Async closures work similarly to regular closures
- Use `move` to transfer ownership into async closure
- Mutable captures require special handling

---

## Error Handling

### Example 11: Custom Error Types with thiserror

**Scenario**: Building a robust error handling system

```rust
use std::fmt;

#[derive(Debug)]
enum AppError {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
    NotFound(String),
    Invalid(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::Io(e) => write!(f, "IO error: {}", e),
            AppError::Parse(e) => write!(f, "Parse error: {}", e),
            AppError::NotFound(msg) => write!(f, "Not found: {}", msg),
            AppError::Invalid(msg) => write!(f, "Invalid: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}

impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError::Io(err)
    }
}

impl From<std::num::ParseIntError> for AppError {
    fn from(err: std::num::ParseIntError) -> Self {
        AppError::Parse(err)
    }
}

fn read_config(path: &str) -> Result<Config, AppError> {
    let content = std::fs::read_to_string(path)?;

    if content.is_empty() {
        return Err(AppError::Invalid("Config file is empty".to_string()));
    }

    parse_config(&content)
}

fn parse_config(content: &str) -> Result<Config, AppError> {
    let parts: Vec<&str> = content.split('=').collect();

    if parts.len() != 2 {
        return Err(AppError::Invalid("Invalid config format".to_string()));
    }

    let port: u16 = parts[1].trim().parse()?;

    Ok(Config { port })
}

struct Config {
    port: u16,
}

fn main() {
    match read_config("config.txt") {
        Ok(config) => println!("Loaded config: port={}", config.port),
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

**Key Points**:
- Custom error types centralize error handling
- `From` implementations enable `?` operator
- `Display` and `Error` traits make errors user-friendly

### Example 12: Error Propagation with Context

**Scenario**: Adding context to errors as they propagate

```rust
type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn process_user_data(user_id: u64) -> Result<String> {
    let raw_data = fetch_user(user_id)
        .map_err(|e| format!("Failed to fetch user {}: {}", user_id, e))?;

    let parsed = parse_data(&raw_data)
        .map_err(|e| format!("Failed to parse data for user {}: {}", user_id, e))?;

    let validated = validate_data(&parsed)
        .map_err(|e| format!("Validation failed for user {}: {}", user_id, e))?;

    Ok(validated)
}

fn fetch_user(user_id: u64) -> Result<String> {
    if user_id == 0 {
        Err("Invalid user ID".into())
    } else {
        Ok(format!("user_data_{}", user_id))
    }
}

fn parse_data(data: &str) -> Result<String> {
    if data.is_empty() {
        Err("Empty data".into())
    } else {
        Ok(data.to_uppercase())
    }
}

fn validate_data(data: &str) -> Result<String> {
    if data.len() < 5 {
        Err("Data too short".into())
    } else {
        Ok(data.to_string())
    }
}

fn main() {
    match process_user_data(42) {
        Ok(data) => println!("Processed: {}", data),
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

**Key Points**:
- `map_err` adds context to errors
- Error messages form a trace of what went wrong
- Makes debugging much easier in production

---

## Unsafe Code and FFI

### Example 13: Raw Pointer Manipulation

**Scenario**: Working with raw pointers for performance-critical code

```rust
fn unsafe_pointer_example() {
    let mut value = 42;

    // Create raw pointers
    let r1: *const i32 = &value;
    let r2: *mut i32 = &mut value;

    unsafe {
        // Dereference raw pointers
        println!("r1 points to: {}", *r1);

        // Modify through mutable pointer
        *r2 = 100;
        println!("r1 now points to: {}", *r1);
    }

    println!("value is now: {}", value);
}

fn main() {
    unsafe_pointer_example();
}
```

**Key Points**:
- Raw pointers (`*const T` and `*mut T`) don't enforce borrowing rules
- Dereferencing requires `unsafe` block
- Use only when necessary for performance or FFI

### Example 14: FFI with C Functions

**Scenario**: Calling C library functions from Rust

```rust
use std::mem;

// External C function declarations
extern "C" {
    fn abs(input: i32) -> i32;
}

// Rust function that can be called from C
#[no_mangle]
pub extern "C" fn rust_add(a: i32, b: i32) -> i32 {
    a + b
}

// Example with function pointers
#[link(name = "foo")]
extern "C" {
    fn do_twice(f: unsafe extern "C" fn(i32) -> i32, arg: i32) -> i32;
}

unsafe extern "C" fn add_one(x: i32) -> i32 {
    x + 1
}

fn main() {
    // Call C standard library function
    let result = unsafe { abs(-42) };
    println!("abs(-42) = {}", result);

    // Call custom C function (if linked)
    // let answer = unsafe { do_twice(add_one, 5) };
    // println!("The answer is: {}", answer);
}
```

**Key Points**:
- `extern "C"` declares C-compatible functions
- `#[no_mangle]` prevents Rust name mangling for exports
- All FFI calls must be in `unsafe` blocks

### Example 15: Implementing Unsafe Sync Trait

**Scenario**: Manual Sync implementation for types that aren't automatically Sync

```rust
use std::cell::Cell;

struct NotThreadSafe<T> {
    value: Cell<T>,
}

// SAFETY: We must ensure all access to the Cell is properly synchronized
unsafe impl<T> Sync for NotThreadSafe<T> {}

static A: NotThreadSafe<usize> = NotThreadSafe {
    value: Cell::new(1),
};

static B: &'static NotThreadSafe<usize> = &A;

fn main() {
    println!("Value: {}", B.value.get());
    B.value.set(42);
    println!("Value: {}", B.value.get());
}
```

**Key Points**:
- `unsafe impl` requires manual safety guarantees
- Document safety invariants in comments
- Only use when you fully understand the implications

---

## Memory Safety and Sanitizers

### Example 16: Detecting Buffer Overflows with AddressSanitizer

**Scenario**: Finding memory bugs with sanitizers

```rust
// Stack buffer overflow example
fn stack_overflow_example() {
    let xs = [0, 1, 2, 3];
    let _y = unsafe { *xs.as_ptr().offset(4) };  // Out of bounds!
}

// Heap buffer overflow example
fn heap_overflow_example() {
    let xs = vec![0, 1, 2, 3];
    let _y = unsafe { *xs.as_ptr().offset(4) };  // Out of bounds!
}

// Use-after-scope example
static mut P: *mut usize = std::ptr::null_mut();

fn use_after_scope_example() {
    unsafe {
        {
            let mut x = 0;
            P = &mut x;
        }
        // x is now out of scope
        std::ptr::write_volatile(P, 123);  // Use after scope!
    }
}

fn main() {
    // Uncomment to test each scenario
    // stack_overflow_example();
    // heap_overflow_example();
    // use_after_scope_example();
}

// Build and run with AddressSanitizer:
// export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
// cargo run -Zbuild-std --target x86_64-unknown-linux-gnu
```

**Key Points**:
- AddressSanitizer detects memory safety violations
- Enable with `RUSTFLAGS=-Zsanitizer=address`
- Provides detailed error reports with stack traces

### Example 17: Detecting Data Races with ThreadSanitizer

**Scenario**: Finding race conditions in concurrent code

```rust
static mut A: usize = 0;

fn data_race_example() {
    let t = std::thread::spawn(|| {
        unsafe { A += 1 };  // Concurrent write
    });

    unsafe { A += 1 };  // Concurrent write

    t.join().unwrap();
}

fn main() {
    // Uncomment to trigger data race
    // data_race_example();
}

// Build and run with ThreadSanitizer:
// export RUSTFLAGS=-Zsanitizer=thread RUSTDOCFLAGS=-Zsanitizer=thread
// cargo run -Zbuild-std --target x86_64-unknown-linux-gnu
```

**Key Points**:
- ThreadSanitizer detects data races at runtime
- Enable with `RUSTFLAGS=-Zsanitizer=thread`
- Catches races that type system can't prevent in unsafe code

---

## Performance Optimization

### Example 18: Zero-Cost Abstractions and Iterators

**Scenario**: Comparing imperative vs functional approaches

```rust
fn imperative_sum(data: &[i32]) -> i32 {
    let mut sum = 0;
    for i in 0..data.len() {
        if data[i] % 2 == 0 {
            sum += data[i] * data[i];
        }
    }
    sum
}

fn functional_sum(data: &[i32]) -> i32 {
    data.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .sum()
}

fn main() {
    let data: Vec<i32> = (0..1000).collect();

    let start = std::time::Instant::now();
    let result1 = imperative_sum(&data);
    let elapsed1 = start.elapsed();

    let start = std::time::Instant::now();
    let result2 = functional_sum(&data);
    let elapsed2 = start.elapsed();

    println!("Imperative: {} ({:?})", result1, elapsed1);
    println!("Functional: {} ({:?})", result2, elapsed2);

    assert_eq!(result1, result2);
}
```

**Key Points**:
- Iterator chains compile to efficient loops
- Zero runtime overhead for abstractions
- Functional style is both readable and performant

### Example 19: Avoiding Allocations with String Slices

**Scenario**: Using &str instead of String when possible

```rust
// Bad: Allocates new String
fn greet_bad(name: &str) -> String {
    format!("Hello, {}!", name)
}

// Good: Returns a borrowed reference
fn greet_good(name: &str) -> impl std::fmt::Display + '_ {
    format_args!("Hello, {}!", name)
}

// Bad: Unnecessary String allocation
fn parse_header_bad(header: &str) -> (String, String) {
    let parts: Vec<&str> = header.split(": ").collect();
    (parts[0].to_string(), parts[1].to_string())
}

// Good: Return slices when possible
fn parse_header_good(header: &str) -> Option<(&str, &str)> {
    let mut parts = header.split(": ");
    let key = parts.next()?;
    let value = parts.next()?;
    Some((key, value))
}

fn main() {
    // String allocation example
    let name = "Alice";
    println!("{}", greet_good(name));

    // String slice parsing
    let header = "Content-Type: application/json";
    if let Some((key, value)) = parse_header_good(header) {
        println!("{}: {}", key, value);
    }
}
```

**Key Points**:
- Prefer `&str` over `String` for read-only operations
- Avoid `.to_string()` unless ownership is needed
- Slices prevent unnecessary allocations

### Example 20: Inline and Monomorphization

**Scenario**: Understanding how generics and inlining work

```rust
#[inline]
fn add<T>(a: T, b: T) -> T
where
    T: std::ops::Add<Output = T>,
{
    a + b
}

#[inline(always)]
fn multiply<T>(a: T, b: T) -> T
where
    T: std::ops::Mul<Output = T>,
{
    a * b
}

fn main() {
    // Monomorphized for i32
    let x = add(5, 3);
    println!("i32: {}", x);

    // Monomorphized for f64
    let y = add(5.0, 3.0);
    println!("f64: {}", y);

    // Inlined and monomorphized
    let z = multiply(10, 20);
    println!("Result: {}", z);
}
```

**Key Points**:
- Generic functions are specialized for each concrete type
- `#[inline]` suggests inlining to compiler
- `#[inline(always)]` forces inlining
- Results in zero abstraction overhead

---

## Production Web Server

### Example 21: Async Web Server with Tokio

**Scenario**: Building a production-ready HTTP server

```rust
use tokio::net::{TcpListener, TcpStream};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use std::sync::Arc;

struct AppState {
    request_count: std::sync::atomic::AtomicU64,
}

impl AppState {
    fn new() -> Self {
        AppState {
            request_count: std::sync::atomic::AtomicU64::new(0),
        }
    }

    fn increment_requests(&self) -> u64 {
        self.request_count
            .fetch_add(1, std::sync::atomic::Ordering::SeqCst)
    }
}

async fn handle_client(mut stream: TcpStream, state: Arc<AppState>) {
    let mut buffer = [0; 1024];

    match stream.read(&mut buffer).await {
        Ok(n) => {
            if n == 0 {
                return;
            }

            let request = String::from_utf8_lossy(&buffer[..n]);
            println!("Received: {}", request);

            let count = state.increment_requests();

            let response = format!(
                "HTTP/1.1 200 OK\r\nContent-Length: {}\r\n\r\nRequest #{}\n",
                format!("Request #{}\n", count).len(),
                count
            );

            if let Err(e) = stream.write_all(response.as_bytes()).await {
                eprintln!("Failed to write response: {}", e);
            }
        }
        Err(e) => {
            eprintln!("Failed to read from stream: {}", e);
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let listener = TcpListener::bind("127.0.0.1:8080").await?;
    let state = Arc::new(AppState::new());

    println!("Server listening on 127.0.0.1:8080");

    loop {
        let (stream, addr) = listener.accept().await?;
        let state = Arc::clone(&state);

        tokio::spawn(async move {
            println!("New connection from: {}", addr);
            handle_client(stream, state).await;
        });
    }
}
```

**Key Points**:
- Async I/O enables handling many concurrent connections
- Shared state uses atomic operations for thread safety
- Each connection is handled in a separate task

---

## CLI Application

### Example 22: Command-Line Tool with Structured Output

**Scenario**: Building a professional CLI application

```rust
use std::env;
use std::process;

struct Config {
    query: String,
    filename: String,
    case_sensitive: bool,
}

impl Config {
    fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("Not enough arguments");
        }

        let query = args[1].clone();
        let filename = args[2].clone();
        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}

fn search<'a>(query: &str, contents: &'a str, case_sensitive: bool) -> Vec<&'a str> {
    contents
        .lines()
        .filter(|line| {
            if case_sensitive {
                line.contains(query)
            } else {
                line.to_lowercase().contains(&query.to_lowercase())
            }
        })
        .collect()
}

fn run(config: Config) -> Result<(), Box<dyn std::error::Error>> {
    let contents = std::fs::read_to_string(config.filename)?;
    let results = search(&config.query, &contents, config.case_sensitive);

    if results.is_empty() {
        println!("No matches found");
    } else {
        println!("Found {} match(es):", results.len());
        for line in results {
            println!("  {}", line);
        }
    }

    Ok(())
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        eprintln!("Usage: {} <query> <filename>", args[0]);
        process::exit(1);
    });

    if let Err(e) = run(config) {
        eprintln!("Application error: {}", e);
        process::exit(1);
    }
}
```

**Key Points**:
- Separate config parsing from business logic
- Use `Result` for error handling
- Provide helpful error messages

---

## Database Connection Pool

### Example 23: Production Database Pattern

**Scenario**: Managing database connections efficiently

```rust
use std::sync::Arc;
use tokio::sync::Semaphore;

struct DbConnection {
    id: usize,
}

impl DbConnection {
    fn new(id: usize) -> Self {
        DbConnection { id }
    }

    async fn query(&self, sql: &str) -> Result<Vec<String>, String> {
        println!("Connection {} executing: {}", self.id, sql);
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
        Ok(vec![format!("Result from connection {}", self.id)])
    }
}

struct ConnectionPool {
    connections: Vec<Arc<DbConnection>>,
    semaphore: Arc<Semaphore>,
}

impl ConnectionPool {
    fn new(size: usize) -> Self {
        let connections = (0..size)
            .map(|i| Arc::new(DbConnection::new(i)))
            .collect();

        ConnectionPool {
            connections,
            semaphore: Arc::new(Semaphore::new(size)),
        }
    }

    async fn get(&self) -> PooledConnection {
        let permit = self.semaphore.clone().acquire_owned().await.unwrap();
        let conn_idx = 0; // Simplified: would track which connection is free

        PooledConnection {
            connection: Arc::clone(&self.connections[conn_idx]),
            _permit: permit,
        }
    }
}

struct PooledConnection {
    connection: Arc<DbConnection>,
    _permit: tokio::sync::OwnedSemaphorePermit,
}

impl std::ops::Deref for PooledConnection {
    type Target = DbConnection;

    fn deref(&self) -> &Self::Target {
        &self.connection
    }
}

#[tokio::main]
async fn main() {
    let pool = Arc::new(ConnectionPool::new(5));
    let mut handles = vec![];

    for i in 0..20 {
        let pool = Arc::clone(&pool);
        let handle = tokio::spawn(async move {
            let conn = pool.get().await;
            let result = conn.query(&format!("SELECT * FROM users WHERE id = {}", i)).await;
            println!("Query {} result: {:?}", i, result);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.await.unwrap();
    }

    println!("All queries completed");
}
```

**Key Points**:
- Connection pool limits concurrent database access
- Semaphore controls access to limited resources
- RAII pattern returns connections to pool automatically

---

**Total Examples**: 23 comprehensive, production-ready examples covering all major aspects of Rust systems programming from ownership to production patterns.
