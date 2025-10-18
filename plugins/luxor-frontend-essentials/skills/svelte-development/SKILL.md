---
name: svelte-development
description: Comprehensive Svelte development skill covering reactivity runes, components, stores, lifecycle, transitions, and modern Svelte 5 patterns
category: frontend
tags: [svelte, reactivity, runes, components, stores, transitions, animations]
version: 1.0.0
context7_library: /sveltejs/svelte
context7_trust_score: 8.1
---

# Svelte Development Skill

This skill provides comprehensive guidance for building modern Svelte applications using reactivity runes (Svelte 5), components, stores, lifecycle hooks, transitions, and animations based on official Svelte documentation.

## When to Use This Skill

Use this skill when:
- Building high-performance web applications with minimal JavaScript overhead
- Creating single-page applications (SPAs) with reactive UI
- Developing interactive user interfaces with compile-time optimization
- Building embedded widgets and components with small bundle sizes
- Implementing real-time dashboards and data visualizations
- Creating progressive web apps (PWAs) with excellent performance
- Developing component libraries with native reactivity
- Building server-side rendered applications with SvelteKit
- Migrating from frameworks with virtual DOM to compiled approach
- Creating accessible and performant web applications

## Core Concepts

### Reactivity with Runes (Svelte 5)

Svelte 5 introduces runes, a new way to declare reactive state with better TypeScript support and clearer semantics.

**$state Rune:**
```javascript
<script>
  let count = $state(0);
  let user = $state({ name: 'Alice', age: 30 });

  function increment() {
    count++;
  }

  function updateAge() {
    user.age++;
  }
</script>

<button on:click={increment}>
  Count: {count}
</button>

<button on:click={updateAge}>
  {user.name} is {user.age} years old
</button>
```

**$derived Rune:**
```javascript
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  let quadrupled = $derived(doubled * 2);

  // Complex derived values
  let users = $state([
    { name: 'Alice', active: true },
    { name: 'Bob', active: false },
    { name: 'Charlie', active: true }
  ]);

  let activeUsers = $derived(users.filter(u => u.active));
  let activeCount = $derived(activeUsers.length);
</script>

<p>Count: {count}</p>
<p>Doubled: {doubled}</p>
<p>Quadrupled: {quadrupled}</p>
<p>Active users: {activeCount}</p>
```

**$effect Rune:**
```javascript
<script>
  let count = $state(0);
  let name = $state('Alice');

  // Effect runs when dependencies change
  $effect(() => {
    console.log(`Count is now ${count}`);
    document.title = `Count: ${count}`;
  });

  // Effect with cleanup
  $effect(() => {
    const interval = setInterval(() => {
      count++;
    }, 1000);

    return () => {
      clearInterval(interval);
    };
  });

  // Conditional effects
  $effect(() => {
    if (count > 10) {
      console.log('Count exceeded 10!');
    }
  });
</script>
```

**$props Rune:**
```javascript
<script>
  // Type-safe props in Svelte 5
  let { name, age = 18, onClick } = $props();

  // With TypeScript
  interface Props {
    name: string;
    age?: number;
    onClick?: () => void;
  }

  let { name, age = 18, onClick }: Props = $props();
</script>

<div>
  <h2>{name}</h2>
  <p>Age: {age}</p>
  {#if onClick}
    <button on:click={onClick}>Click me</button>
  {/if}
</div>
```

### Components

Components are the building blocks of Svelte applications. Each component is a single file with script, markup, and styles.

**Basic Component Structure:**
```svelte
<script>
  // Component logic
  let name = $state('World');
  let count = $state(0);

  function handleClick() {
    count++;
  }
</script>

<!-- Component markup -->
<div class="container">
  <h1>Hello {name}!</h1>
  <p>Count: {count}</p>
  <button on:click={handleClick}>Increment</button>
</div>

<!-- Component styles (scoped by default) -->
<style>
  .container {
    padding: 1rem;
    border: 1px solid #ccc;
    border-radius: 8px;
  }

  h1 {
    color: #ff3e00;
    font-size: 2rem;
  }

  button {
    background: #ff3e00;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
  }

  button:hover {
    background: #ff5722;
  }
</style>
```

**Component Props:**
```svelte
<!-- Card.svelte -->
<script>
  let { title, description, imageUrl, onClick } = $props();
</script>

<div class="card" on:click={onClick}>
  {#if imageUrl}
    <img src={imageUrl} alt={title} />
  {/if}
  <h3>{title}</h3>
  <p>{description}</p>
</div>

<style>
  .card {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 1rem;
    cursor: pointer;
    transition: transform 0.2s;
  }

  .card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }

  img {
    width: 100%;
    border-radius: 4px;
  }
</style>
```

**Component Events:**
```svelte
<!-- Button.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';

  let { variant = 'primary', disabled = false } = $props();

  const dispatch = createEventDispatcher();

  function handleClick() {
    dispatch('click', { timestamp: Date.now() });
  }
</script>

<button
  class="btn {variant}"
  {disabled}
  on:click={handleClick}
>
  <slot />
</button>

<style>
  .btn {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  .primary {
    background: #ff3e00;
    color: white;
  }

  .secondary {
    background: #676778;
    color: white;
  }
</style>

<!-- Usage -->
<script>
  import Button from './Button.svelte';

  function handleButtonClick(event) {
    console.log('Clicked at:', event.detail.timestamp);
  }
</script>

<Button on:click={handleButtonClick}>Click me</Button>
<Button variant="secondary" on:click={handleButtonClick}>Secondary</Button>
```

**Slots and Composition:**
```svelte
<!-- Modal.svelte -->
<script>
  let { isOpen = false, onClose } = $props();
</script>

{#if isOpen}
  <div class="modal-overlay" on:click={onClose}>
    <div class="modal-content" on:click|stopPropagation>
      <button class="close-btn" on:click={onClose}>×</button>

      <div class="modal-header">
        <slot name="header">
          <h2>Modal Title</h2>
        </slot>
      </div>

      <div class="modal-body">
        <slot>
          <p>Modal content goes here</p>
        </slot>
      </div>

      <div class="modal-footer">
        <slot name="footer">
          <button on:click={onClose}>Close</button>
        </slot>
      </div>
    </div>
  </div>
{/if}

<style>
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal-content {
    background: white;
    border-radius: 8px;
    padding: 2rem;
    max-width: 500px;
    width: 90%;
    position: relative;
  }

  .close-btn {
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: none;
    border: none;
    font-size: 2rem;
    cursor: pointer;
  }
</style>

<!-- Usage -->
<script>
  import Modal from './Modal.svelte';
  let isModalOpen = $state(false);
</script>

<button on:click={() => isModalOpen = true}>Open Modal</button>

<Modal {isModalOpen} onClose={() => isModalOpen = false}>
  <svelte:fragment slot="header">
    <h2>Custom Title</h2>
  </svelte:fragment>

  <p>This is custom modal content.</p>

  <svelte:fragment slot="footer">
    <button on:click={() => isModalOpen = false}>Cancel</button>
    <button on:click={handleSave}>Save</button>
  </svelte:fragment>
</Modal>
```

### Stores

Stores are observable values that can be shared across components.

**Writable Store:**
```javascript
// stores.js
import { writable } from 'svelte/store';

export const count = writable(0);

export const user = writable({
  name: 'Guest',
  loggedIn: false
});

export const todos = writable([]);

// Custom store with methods
function createCounter() {
  const { subscribe, set, update } = writable(0);

  return {
    subscribe,
    increment: () => update(n => n + 1),
    decrement: () => update(n => n - 1),
    reset: () => set(0)
  };
}

export const counter = createCounter();
```

**Using Stores in Components:**
```svelte
<script>
  import { count, user, counter } from './stores.js';

  // Auto-subscription with $
  $: console.log('Count changed:', $count);

  function increment() {
    count.update(n => n + 1);
  }

  function login() {
    user.set({ name: 'Alice', loggedIn: true });
  }
</script>

<p>Count: {$count}</p>
<button on:click={increment}>Increment</button>

<p>Welcome, {$user.name}!</p>
{#if !$user.loggedIn}
  <button on:click={login}>Login</button>
{/if}

<p>Counter: {$counter}</p>
<button on:click={counter.increment}>+</button>
<button on:click={counter.decrement}>-</button>
<button on:click={counter.reset}>Reset</button>
```

**Readable Store:**
```javascript
// stores.js
import { readable } from 'svelte/store';

export const time = readable(new Date(), (set) => {
  const interval = setInterval(() => {
    set(new Date());
  }, 1000);

  return () => clearInterval(interval);
});

export const mousePosition = readable({ x: 0, y: 0 }, (set) => {
  const handleMouseMove = (e) => {
    set({ x: e.clientX, y: e.clientY });
  };

  window.addEventListener('mousemove', handleMouseMove);

  return () => {
    window.removeEventListener('mousemove', handleMouseMove);
  };
});
```

**Derived Store:**
```javascript
// stores.js
import { writable, derived } from 'svelte/store';

export const todos = writable([
  { id: 1, text: 'Buy milk', done: false },
  { id: 2, text: 'Walk dog', done: true },
  { id: 3, text: 'Code review', done: false }
]);

export const completedTodos = derived(
  todos,
  $todos => $todos.filter(t => t.done)
);

export const activeTodos = derived(
  todos,
  $todos => $todos.filter(t => !t.done)
);

export const todoStats = derived(
  todos,
  $todos => ({
    total: $todos.length,
    completed: $todos.filter(t => t.done).length,
    active: $todos.filter(t => !t.done).length
  })
);

// Derived from multiple stores
export const firstName = writable('Alice');
export const lastName = writable('Smith');

export const fullName = derived(
  [firstName, lastName],
  ([$firstName, $lastName]) => `${$firstName} ${$lastName}`
);
```

**Custom Store with Complex Logic:**
```javascript
// stores/cart.js
import { writable, derived } from 'svelte/store';

function createCart() {
  const { subscribe, set, update } = writable([]);

  return {
    subscribe,
    addItem: (item) => update(items => {
      const existing = items.find(i => i.id === item.id);
      if (existing) {
        return items.map(i =>
          i.id === item.id
            ? { ...i, quantity: i.quantity + 1 }
            : i
        );
      }
      return [...items, { ...item, quantity: 1 }];
    }),
    removeItem: (id) => update(items =>
      items.filter(i => i.id !== id)
    ),
    updateQuantity: (id, quantity) => update(items =>
      items.map(i => i.id === id ? { ...i, quantity } : i)
    ),
    clear: () => set([])
  };
}

export const cart = createCart();

export const cartTotal = derived(
  cart,
  $cart => $cart.reduce((sum, item) => sum + item.price * item.quantity, 0)
);

export const cartItemCount = derived(
  cart,
  $cart => $cart.reduce((count, item) => count + item.quantity, 0)
);
```

### Lifecycle Hooks

Lifecycle hooks let you run code at specific points in a component's lifecycle.

**onMount:**
```svelte
<script>
  import { onMount } from 'svelte';

  let data = $state([]);
  let loading = $state(true);
  let error = $state(null);

  onMount(async () => {
    try {
      const response = await fetch('/api/data');
      if (!response.ok) throw new Error('Failed to fetch');
      data = await response.json();
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  });

  // onMount with cleanup
  onMount(() => {
    const interval = setInterval(() => {
      console.log('Tick');
    }, 1000);

    return () => {
      clearInterval(interval);
    };
  });
</script>

{#if loading}
  <p>Loading...</p>
{:else if error}
  <p>Error: {error}</p>
{:else}
  <ul>
    {#each data as item}
      <li>{item.name}</li>
    {/each}
  </ul>
{/if}
```

**onDestroy:**
```svelte
<script>
  import { onDestroy } from 'svelte';

  const subscription = eventSource.subscribe(data => {
    console.log(data);
  });

  onDestroy(() => {
    subscription.unsubscribe();
  });

  // Multiple cleanup operations
  onDestroy(() => {
    console.log('Component is being destroyed');
  });
</script>
```

**beforeUpdate and afterUpdate:**
```svelte
<script>
  import { beforeUpdate, afterUpdate } from 'svelte';

  let div;
  let autoscroll = $state(true);

  beforeUpdate(() => {
    if (div) {
      const scrollableDistance = div.scrollHeight - div.offsetHeight;
      autoscroll = div.scrollTop > scrollableDistance - 20;
    }
  });

  afterUpdate(() => {
    if (autoscroll) {
      div.scrollTo(0, div.scrollHeight);
    }
  });
</script>

<div bind:this={div}>
  <!-- Content -->
</div>
```

**tick:**
```svelte
<script>
  import { tick } from 'svelte';

  let text = $state('');
  let textarea;

  async function handleKeydown(event) {
    if (event.key === 'Tab') {
      event.preventDefault();

      const { selectionStart, selectionEnd, value } = textarea;
      text = value.slice(0, selectionStart) + '\t' + value.slice(selectionEnd);

      // Wait for DOM to update
      await tick();

      // Set cursor position
      textarea.selectionStart = textarea.selectionEnd = selectionStart + 1;
    }
  }
</script>

<textarea
  bind:value={text}
  bind:this={textarea}
  on:keydown={handleKeydown}
/>
```

### Transitions and Animations

Svelte provides built-in transitions and animations for smooth UI effects.

**Built-in Transitions:**
```svelte
<script>
  import { fade, fly, slide, scale, blur } from 'svelte/transition';
  import { quintOut } from 'svelte/easing';

  let visible = $state(true);
</script>

<button on:click={() => visible = !visible}>Toggle</button>

{#if visible}
  <div transition:fade>Fades in and out</div>

  <div transition:fly={{ y: 200, duration: 500 }}>
    Flies in and out
  </div>

  <div transition:slide={{ duration: 300 }}>
    Slides in and out
  </div>

  <div transition:scale={{
    duration: 500,
    start: 0.5,
    easing: quintOut
  }}>
    Scales in and out
  </div>

  <div transition:blur={{ duration: 300 }}>
    Blurs in and out
  </div>
{/if}
```

**In and Out Transitions:**
```svelte
<script>
  import { fade, fly } from 'svelte/transition';

  let visible = $state(true);
</script>

{#if visible}
  <div
    in:fly={{ y: -200, duration: 500 }}
    out:fade={{ duration: 200 }}
  >
    Different in/out transitions
  </div>
{/if}
```

**Custom Transitions:**
```svelte
<script>
  import { cubicOut } from 'svelte/easing';

  function typewriter(node, { speed = 1 }) {
    const valid = node.childNodes.length === 1 &&
                  node.childNodes[0].nodeType === Node.TEXT_NODE;

    if (!valid) return {};

    const text = node.textContent;
    const duration = text.length / (speed * 0.01);

    return {
      duration,
      tick: t => {
        const i = Math.trunc(text.length * t);
        node.textContent = text.slice(0, i);
      }
    };
  }

  function spin(node, { duration }) {
    return {
      duration,
      css: t => {
        const eased = cubicOut(t);
        return `
          transform: scale(${eased}) rotate(${eased * 360}deg);
          opacity: ${eased};
        `;
      }
    };
  }

  let visible = $state(false);
</script>

{#if visible}
  <p transition:typewriter={{ speed: 1 }}>
    This text will type out character by character
  </p>

  <div transition:spin={{ duration: 600 }}>
    Spinning!
  </div>
{/if}
```

**Animations:**
```svelte
<script>
  import { flip } from 'svelte/animate';
  import { quintOut } from 'svelte/easing';

  let todos = $state([
    { id: 1, text: 'Buy milk' },
    { id: 2, text: 'Walk dog' },
    { id: 3, text: 'Code review' }
  ]);

  function shuffle() {
    todos = todos.sort(() => Math.random() - 0.5);
  }
</script>

<button on:click={shuffle}>Shuffle</button>

<ul>
  {#each todos as todo (todo.id)}
    <li animate:flip={{ duration: 300, easing: quintOut }}>
      {todo.text}
    </li>
  {/each}
</ul>
```

**Deferred Transitions:**
```svelte
<script>
  import { quintOut } from 'svelte/easing';
  import { crossfade } from 'svelte/transition';

  const [send, receive] = crossfade({
    duration: d => Math.sqrt(d * 200),
    fallback(node, params) {
      const style = getComputedStyle(node);
      const transform = style.transform === 'none' ? '' : style.transform;

      return {
        duration: 600,
        easing: quintOut,
        css: t => `
          transform: ${transform} scale(${t});
          opacity: ${t}
        `
      };
    }
  });

  let todos = $state([
    { id: 1, text: 'Buy milk', done: false },
    { id: 2, text: 'Walk dog', done: true }
  ]);

  function toggleDone(id) {
    todos = todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    );
  }
</script>

<div class="board">
  <div class="column">
    <h2>Todo</h2>
    {#each todos.filter(t => !t.done) as todo (todo.id)}
      <div
        class="card"
        in:receive={{ key: todo.id }}
        out:send={{ key: todo.id }}
        on:click={() => toggleDone(todo.id)}
      >
        {todo.text}
      </div>
    {/each}
  </div>

  <div class="column">
    <h2>Done</h2>
    {#each todos.filter(t => t.done) as todo (todo.id)}
      <div
        class="card"
        in:receive={{ key: todo.id }}
        out:send={{ key: todo.id }}
        on:click={() => toggleDone(todo.id)}
      >
        {todo.text}
      </div>
    {/each}
  </div>
</div>
```

### Bindings

Svelte provides powerful two-way binding capabilities.

**Input Bindings:**
```svelte
<script>
  let name = $state('');
  let age = $state(0);
  let message = $state('');
  let selected = $state('');
  let checked = $state(false);
  let group = $state([]);
</script>

<!-- Text input -->
<input bind:value={name} placeholder="Enter name" />
<p>Hello {name}!</p>

<!-- Number input -->
<input type="number" bind:value={age} />
<p>Age: {age}</p>

<!-- Textarea -->
<textarea bind:value={message}></textarea>
<p>Message length: {message.length}</p>

<!-- Select -->
<select bind:value={selected}>
  <option value="red">Red</option>
  <option value="blue">Blue</option>
  <option value="green">Green</option>
</select>
<p>Selected: {selected}</p>

<!-- Checkbox -->
<input type="checkbox" bind:checked={checked} />
<p>Checked: {checked}</p>

<!-- Checkbox group -->
<input type="checkbox" bind:group={group} value="apple" /> Apple
<input type="checkbox" bind:group={group} value="banana" /> Banana
<input type="checkbox" bind:group={group} value="orange" /> Orange
<p>Selected: {group.join(', ')}</p>
```

**Component Bindings:**
```svelte
<!-- Input.svelte -->
<script>
  let { value = '' } = $props();
</script>

<input bind:value />

<!-- Parent.svelte -->
<script>
  import Input from './Input.svelte';
  let name = $state('');
</script>

<Input bind:value={name} />
<p>Name: {name}</p>
```

**Element Bindings:**
```svelte
<script>
  let canvas;
  let video;
  let div;

  let clientWidth = $state(0);
  let clientHeight = $state(0);
  let offsetWidth = $state(0);

  onMount(() => {
    const ctx = canvas.getContext('2d');
    // Draw on canvas
  });
</script>

<canvas bind:this={canvas} width={400} height={300}></canvas>

<video bind:this={video} bind:currentTime bind:duration bind:paused>
  <source src="video.mp4" />
</video>

<div bind:clientWidth bind:clientHeight bind:offsetWidth bind:this={div}>
  Size: {clientWidth} × {clientHeight}
</div>
```

**Contenteditable Bindings:**
```svelte
<script>
  let html = $state('<p>Edit me!</p>');
</script>

<div contenteditable="true" bind:innerHTML={html}></div>

<pre>{html}</pre>
```

## API Reference

### Runes (Svelte 5)

**$state(initialValue)**
- Creates reactive state
- Returns a reactive variable
- Mutations automatically trigger updates

**$derived(expression)**
- Creates derived reactive value
- Automatically tracks dependencies
- Recomputes when dependencies change

**$effect(callback)**
- Runs side effects when dependencies change
- Can return cleanup function
- Automatically tracks dependencies

**$props()**
- Declares component props
- Supports destructuring and defaults
- Type-safe with TypeScript

### Store Functions

**writable(initialValue, start?)**
- Creates writable store
- Returns { subscribe, set, update }
- Optional start function for setup

**readable(initialValue, start)**
- Creates read-only store
- Returns { subscribe }
- Requires start function

**derived(stores, callback, initialValue?)**
- Creates derived store
- Depends on one or more stores
- Automatically updates

**get(store)**
- Gets current value without subscription
- Use sparingly (prefer $store syntax)

### Lifecycle Functions

**onMount(callback)**
- Runs after component first renders
- Can return cleanup function
- Good for data fetching, subscriptions

**onDestroy(callback)**
- Runs before component is destroyed
- Use for cleanup operations

**beforeUpdate(callback)**
- Runs before DOM updates
- Access previous state

**afterUpdate(callback)**
- Runs after DOM updates
- Good for DOM manipulation

**tick()**
- Returns promise that resolves after state changes
- Ensures DOM is updated

### Transition Functions

**fade(node, params)**
- Fades element in/out
- Params: { delay, duration, easing }

**fly(node, params)**
- Flies element in/out
- Params: { delay, duration, easing, x, y, opacity }

**slide(node, params)**
- Slides element in/out
- Params: { delay, duration, easing }

**scale(node, params)**
- Scales element in/out
- Params: { delay, duration, easing, start, opacity }

**blur(node, params)**
- Blurs element in/out
- Params: { delay, duration, easing, amount, opacity }

**crossfade(params)**
- Creates send/receive transition pair
- Good for moving elements between lists

### Animation Functions

**flip(node, animation, params)**
- Animates position changes
- Use with each blocks
- Params: { delay, duration, easing }

## Workflow Patterns

### Component Composition

**Container/Presenter Pattern:**
```svelte
<!-- TodoContainer.svelte -->
<script>
  import TodoList from './TodoList.svelte';
  import { todos } from './stores.js';

  function addTodo(text) {
    todos.update(list => [...list, {
      id: Date.now(),
      text,
      done: false
    }]);
  }

  function toggleTodo(id) {
    todos.update(list => list.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    ));
  }

  function deleteTodo(id) {
    todos.update(list => list.filter(t => t.id !== id));
  }
</script>

<TodoList
  todos={$todos}
  onAdd={addTodo}
  onToggle={toggleTodo}
  onDelete={deleteTodo}
/>

<!-- TodoList.svelte (Presenter) -->
<script>
  let { todos, onAdd, onToggle, onDelete } = $props();
  let newTodo = $state('');

  function handleSubmit() {
    if (newTodo.trim()) {
      onAdd(newTodo);
      newTodo = '';
    }
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <input bind:value={newTodo} placeholder="Add todo" />
  <button type="submit">Add</button>
</form>

<ul>
  {#each todos as todo}
    <li>
      <input
        type="checkbox"
        checked={todo.done}
        on:change={() => onToggle(todo.id)}
      />
      <span class:done={todo.done}>{todo.text}</span>
      <button on:click={() => onDelete(todo.id)}>Delete</button>
    </li>
  {/each}
</ul>

<style>
  .done {
    text-decoration: line-through;
    opacity: 0.6;
  }
</style>
```

### State Management

**Context API Pattern:**
```svelte
<!-- App.svelte -->
<script>
  import { setContext } from 'svelte';
  import { writable } from 'svelte/store';

  const user = writable({ name: 'Alice', role: 'admin' });
  const theme = writable('light');

  setContext('user', user);
  setContext('theme', theme);
</script>

<slot />

<!-- Child.svelte -->
<script>
  import { getContext } from 'svelte';

  const user = getContext('user');
  const theme = getContext('theme');
</script>

<div class={$theme}>
  <p>Welcome, {$user.name}!</p>
  <p>Role: {$user.role}</p>
</div>
```

### Form Validation

**Form with Validation:**
```svelte
<script>
  let formData = $state({
    email: '',
    password: '',
    confirmPassword: ''
  });

  let errors = $state({});
  let touched = $state({});
  let isSubmitting = $state(false);

  function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }

  function validateForm() {
    const newErrors = {};

    if (!formData.email) {
      newErrors.email = 'Email is required';
    } else if (!validateEmail(formData.email)) {
      newErrors.email = 'Invalid email address';
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }

    return newErrors;
  }

  function handleBlur(field) {
    touched[field] = true;
    errors = validateForm();
  }

  async function handleSubmit() {
    touched = { email: true, password: true, confirmPassword: true };
    errors = validateForm();

    if (Object.keys(errors).length === 0) {
      isSubmitting = true;
      try {
        await submitForm(formData);
        // Success
      } catch (error) {
        errors.submit = error.message;
      } finally {
        isSubmitting = false;
      }
    }
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <div class="field">
    <label for="email">Email</label>
    <input
      id="email"
      type="email"
      bind:value={formData.email}
      on:blur={() => handleBlur('email')}
      class:error={touched.email && errors.email}
    />
    {#if touched.email && errors.email}
      <span class="error-message">{errors.email}</span>
    {/if}
  </div>

  <div class="field">
    <label for="password">Password</label>
    <input
      id="password"
      type="password"
      bind:value={formData.password}
      on:blur={() => handleBlur('password')}
      class:error={touched.password && errors.password}
    />
    {#if touched.password && errors.password}
      <span class="error-message">{errors.password}</span>
    {/if}
  </div>

  <div class="field">
    <label for="confirmPassword">Confirm Password</label>
    <input
      id="confirmPassword"
      type="password"
      bind:value={formData.confirmPassword}
      on:blur={() => handleBlur('confirmPassword')}
      class:error={touched.confirmPassword && errors.confirmPassword}
    />
    {#if touched.confirmPassword && errors.confirmPassword}
      <span class="error-message">{errors.confirmPassword}</span>
    {/if}
  </div>

  {#if errors.submit}
    <div class="error-message">{errors.submit}</div>
  {/if}

  <button type="submit" disabled={isSubmitting}>
    {isSubmitting ? 'Submitting...' : 'Submit'}
  </button>
</form>

<style>
  .field {
    margin-bottom: 1rem;
  }

  input.error {
    border-color: red;
  }

  .error-message {
    color: red;
    font-size: 0.875rem;
    margin-top: 0.25rem;
  }
</style>
```

### Data Fetching

**Fetch with Loading States:**
```svelte
<script>
  import { onMount } from 'svelte';

  let data = $state([]);
  let loading = $state(true);
  let error = $state(null);

  async function fetchData() {
    loading = true;
    error = null;

    try {
      const response = await fetch('/api/data');
      if (!response.ok) throw new Error('Failed to fetch');
      data = await response.json();
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  }

  onMount(fetchData);
</script>

{#if loading}
  <div class="spinner">Loading...</div>
{:else if error}
  <div class="error">
    <p>Error: {error}</p>
    <button on:click={fetchData}>Retry</button>
  </div>
{:else}
  <ul>
    {#each data as item}
      <li>{item.name}</li>
    {/each}
  </ul>
{/if}
```

## Best Practices

### 1. Use Runes for Reactivity (Svelte 5)

Prefer runes over legacy reactive declarations:

```svelte
<!-- ✅ Good - Using runes -->
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);

  $effect(() => {
    console.log(`Count: ${count}`);
  });
</script>

<!-- ❌ Avoid - Legacy syntax -->
<script>
  let count = 0;
  $: doubled = count * 2;

  $: {
    console.log(`Count: ${count}`);
  }
</script>
```

### 2. Component Organization

Keep components focused and single-purpose:

```svelte
<!-- ✅ Good - Focused component -->
<!-- Button.svelte -->
<script>
  let { variant = 'primary', onClick } = $props();
</script>

<button class={variant} on:click={onClick}>
  <slot />
</button>

<!-- ❌ Avoid - Too many responsibilities -->
<script>
  // Button that also handles data fetching, validation, etc.
</script>
```

### 3. Store Usage

Use stores for shared state, local state for component-specific data:

```svelte
<!-- ✅ Good -->
<script>
  import { user } from './stores.js'; // Shared state
  let localCount = $state(0); // Component-specific
</script>

<!-- ❌ Avoid - Store for component-specific state -->
<script>
  import { count } from './stores.js'; // Only used in one component
</script>
```

### 4. Accessibility

Always include proper ARIA attributes and keyboard support:

```svelte
<button
  on:click={handleClick}
  aria-label="Close dialog"
  aria-pressed={isPressed}
>
  Close
</button>

<input
  type="text"
  aria-label="Search"
  aria-describedby="search-help"
/>
<span id="search-help">Enter keywords to search</span>
```

### 5. Performance Optimization

Use keyed each blocks for lists:

```svelte
<!-- ✅ Good - Keyed each -->
{#each items as item (item.id)}
  <Item {item} />
{/each}

<!-- ❌ Avoid - Unkeyed each -->
{#each items as item}
  <Item {item} />
{/each}
```

### 6. TypeScript Integration

Use TypeScript for type safety:

```svelte
<script lang="ts">
  interface User {
    name: string;
    age: number;
    email?: string;
  }

  interface Props {
    user: User;
    onUpdate?: (user: User) => void;
  }

  let { user, onUpdate }: Props = $props();
</script>
```

### 7. CSS Scoping

Leverage Svelte's scoped styles:

```svelte
<style>
  /* Scoped to this component by default */
  .container {
    padding: 1rem;
  }

  /* Global styles when needed */
  :global(body) {
    margin: 0;
  }

  /* Combining scoped and global */
  .container :global(p) {
    color: blue;
  }
</style>
```

### 8. Event Modifiers

Use event modifiers for cleaner code:

```svelte
<!-- preventDefault -->
<form on:submit|preventDefault={handleSubmit}>

<!-- stopPropagation -->
<div on:click|stopPropagation={handleClick}>

<!-- once -->
<button on:click|once={handleClick}>

<!-- capture -->
<div on:click|capture={handleClick}>

<!-- self -->
<div on:click|self={handleClick}>

<!-- passive -->
<div on:scroll|passive={handleScroll}>

<!-- nonpassive -->
<div on:wheel|nonpassive={handleWheel}>
```

### 9. Component Communication

Use events for child-to-parent communication:

```svelte
<!-- Child.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  function notify() {
    dispatch('message', { text: 'Hello!' });
  }
</script>

<!-- Parent.svelte -->
<Child on:message={handleMessage} />
```

### 10. Error Boundaries

Handle errors gracefully:

```svelte
<script>
  import { onDestroy } from 'svelte';

  let error = $state(null);

  function handleError(err) {
    error = err.message;
    console.error(err);
  }

  // Global error handler
  const errorHandler = (event) => {
    handleError(event.error);
  };

  if (typeof window !== 'undefined') {
    window.addEventListener('error', errorHandler);
  }

  onDestroy(() => {
    if (typeof window !== 'undefined') {
      window.removeEventListener('error', errorHandler);
    }
  });
</script>

{#if error}
  <div class="error-boundary">
    <h2>Something went wrong</h2>
    <p>{error}</p>
    <button on:click={() => error = null}>Try again</button>
  </div>
{:else}
  <slot />
{/if}
```

## Summary

This Svelte development skill covers:

1. **Reactivity with Runes**: $state, $derived, $effect, $props
2. **Components**: Structure, props, events, slots
3. **Stores**: Writable, readable, derived, custom stores
4. **Lifecycle**: onMount, onDestroy, beforeUpdate, afterUpdate, tick
5. **Transitions**: Built-in and custom transitions
6. **Animations**: FLIP animations, crossfade
7. **Bindings**: Input, component, element bindings
8. **Workflow Patterns**: Component composition, state management, forms, data fetching
9. **Best Practices**: Performance, accessibility, TypeScript, CSS scoping
10. **Real-world Patterns**: Todo apps, modals, forms with validation

All patterns are based on Svelte 5 with runes and represent modern Svelte development practices focusing on compile-time optimization and reactive programming.
