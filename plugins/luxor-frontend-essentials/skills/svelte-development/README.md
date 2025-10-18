# Svelte Development Skill

Comprehensive guide for building modern web applications with Svelte 5, covering reactivity runes, components, stores, lifecycle hooks, transitions, and animations.

## Overview

Svelte is a radical new approach to building user interfaces. Unlike frameworks that do the bulk of their work in the browser, Svelte shifts that work into a compile step that happens when you build your app. Instead of using techniques like virtual DOM diffing, Svelte writes code that surgically updates the DOM when the state of your app changes.

### Why Svelte?

**Performance:**
- No virtual DOM overhead
- Compile-time optimization
- Smaller bundle sizes
- Faster runtime performance

**Developer Experience:**
- Less boilerplate code
- True reactivity
- Scoped CSS by default
- Built-in transitions and animations

**Modern Features:**
- Runes for type-safe reactivity (Svelte 5)
- Powerful stores for state management
- Component composition with slots
- Rich ecosystem with SvelteKit

## Getting Started

### Installation

Create a new Svelte project with Vite:

```bash
npm create vite@latest my-svelte-app -- --template svelte
cd my-svelte-app
npm install
npm run dev
```

For TypeScript support:

```bash
npm create vite@latest my-svelte-app -- --template svelte-ts
```

### With SvelteKit (Recommended for Full Applications)

```bash
npm create svelte@latest my-app
cd my-app
npm install
npm run dev
```

### Project Structure

```
my-svelte-app/
├── src/
│   ├── lib/
│   │   ├── components/
│   │   │   ├── Button.svelte
│   │   │   └── Card.svelte
│   │   ├── stores/
│   │   │   └── user.js
│   │   └── utils/
│   │       └── api.js
│   ├── routes/
│   │   ├── +page.svelte
│   │   └── +layout.svelte
│   ├── app.html
│   └── app.css
├── static/
│   └── favicon.png
├── svelte.config.js
├── vite.config.js
└── package.json
```

## Quick Start Examples

### Counter (Svelte 5 with Runes)

```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);

  function increment() {
    count++;
  }

  function decrement() {
    count--;
  }

  function reset() {
    count = 0;
  }
</script>

<div class="counter">
  <h1>Counter: {count}</h1>
  <p>Doubled: {doubled}</p>

  <div class="buttons">
    <button on:click={decrement}>-</button>
    <button on:click={reset}>Reset</button>
    <button on:click={increment}>+</button>
  </div>
</div>

<style>
  .counter {
    text-align: center;
    padding: 2rem;
  }

  .buttons {
    display: flex;
    gap: 1rem;
    justify-content: center;
  }

  button {
    padding: 0.5rem 1rem;
    font-size: 1rem;
    cursor: pointer;
    background: #ff3e00;
    color: white;
    border: none;
    border-radius: 4px;
  }

  button:hover {
    background: #ff5722;
  }
</style>
```

### Todo List

```svelte
<script>
  let todos = $state([
    { id: 1, text: 'Learn Svelte', done: false },
    { id: 2, text: 'Build an app', done: false }
  ]);

  let newTodo = $state('');

  function addTodo() {
    if (newTodo.trim()) {
      todos = [...todos, {
        id: Date.now(),
        text: newTodo,
        done: false
      }];
      newTodo = '';
    }
  }

  function toggleTodo(id) {
    todos = todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    );
  }

  function deleteTodo(id) {
    todos = todos.filter(t => t.id !== id);
  }

  let remaining = $derived(todos.filter(t => !t.done).length);
</script>

<div class="todo-app">
  <h1>Todo List</h1>
  <p>{remaining} remaining</p>

  <form on:submit|preventDefault={addTodo}>
    <input
      bind:value={newTodo}
      placeholder="What needs to be done?"
    />
    <button type="submit">Add</button>
  </form>

  <ul>
    {#each todos as todo (todo.id)}
      <li class:done={todo.done}>
        <input
          type="checkbox"
          checked={todo.done}
          on:change={() => toggleTodo(todo.id)}
        />
        <span>{todo.text}</span>
        <button on:click={() => deleteTodo(todo.id)}>Delete</button>
      </li>
    {/each}
  </ul>
</div>

<style>
  .todo-app {
    max-width: 600px;
    margin: 2rem auto;
    padding: 2rem;
  }

  form {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  input[type="text"] {
    flex: 1;
    padding: 0.5rem;
    font-size: 1rem;
  }

  ul {
    list-style: none;
    padding: 0;
  }

  li {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem;
    border-bottom: 1px solid #eee;
  }

  li.done span {
    text-decoration: line-through;
    opacity: 0.6;
  }

  li span {
    flex: 1;
  }
</style>
```

### Data Fetching

```svelte
<script>
  import { onMount } from 'svelte';

  let users = $state([]);
  let loading = $state(true);
  let error = $state(null);

  onMount(async () => {
    try {
      const response = await fetch('https://jsonplaceholder.typicode.com/users');
      if (!response.ok) throw new Error('Failed to fetch');
      users = await response.json();
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  });
</script>

<div class="users">
  <h1>Users</h1>

  {#if loading}
    <p>Loading...</p>
  {:else if error}
    <p class="error">Error: {error}</p>
  {:else}
    <ul>
      {#each users as user}
        <li>
          <strong>{user.name}</strong>
          <span>{user.email}</span>
        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  .users {
    max-width: 800px;
    margin: 2rem auto;
    padding: 2rem;
  }

  ul {
    list-style: none;
    padding: 0;
  }

  li {
    display: flex;
    justify-content: space-between;
    padding: 1rem;
    border-bottom: 1px solid #eee;
  }

  .error {
    color: red;
  }
</style>
```

## Core Concepts

### Reactivity

Svelte's reactivity is built on assignments. When you assign a new value to a variable, Svelte knows to update the DOM.

**Svelte 5 Runes (Modern):**
```javascript
let count = $state(0);           // Reactive state
let doubled = $derived(count * 2); // Derived value
$effect(() => {                   // Side effects
  console.log(`Count: ${count}`);
});
```

**Legacy Reactive Declarations:**
```javascript
let count = 0;
$: doubled = count * 2;
$: console.log(`Count: ${count}`);
```

### Components

Components are reusable building blocks. Each .svelte file is a component with three sections:

```svelte
<script>
  // JavaScript logic
</script>

<!-- HTML markup -->

<style>
  /* Scoped CSS */
</style>
```

### Stores

Stores provide a way to share state across components:

```javascript
import { writable } from 'svelte/store';

export const count = writable(0);
```

Use in components with the `$` prefix:

```svelte
<script>
  import { count } from './stores.js';
</script>

<p>Count: {$count}</p>
<button on:click={() => $count++}>Increment</button>
```

### Props

Pass data to components via props:

```svelte
<!-- Parent.svelte -->
<Child name="Alice" age={30} />

<!-- Child.svelte -->
<script>
  let { name, age } = $props();
</script>

<p>{name} is {age} years old</p>
```

### Events

Components can dispatch custom events:

```svelte
<!-- Button.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();
</script>

<button on:click={() => dispatch('clicked')}>
  Click me
</button>

<!-- Parent.svelte -->
<Button on:clicked={handleClick} />
```

### Slots

Slots allow parent components to pass content to children:

```svelte
<!-- Card.svelte -->
<div class="card">
  <slot name="header">Default header</slot>
  <slot>Default content</slot>
  <slot name="footer">Default footer</slot>
</div>

<!-- Usage -->
<Card>
  <h2 slot="header">Custom Header</h2>
  <p>Custom content</p>
  <button slot="footer">Action</button>
</Card>
```

## Advanced Features

### Context API

Share data without prop drilling:

```svelte
<!-- Parent.svelte -->
<script>
  import { setContext } from 'svelte';
  import { writable } from 'svelte/store';

  const theme = writable('light');
  setContext('theme', theme);
</script>

<!-- Child.svelte -->
<script>
  import { getContext } from 'svelte';
  const theme = getContext('theme');
</script>

<div class={$theme}>Content</div>
```

### Transitions

Built-in animations for element entry/exit:

```svelte
<script>
  import { fade, fly, slide } from 'svelte/transition';
  let visible = $state(true);
</script>

{#if visible}
  <div transition:fade>Fades in and out</div>
  <div transition:fly={{ y: 200 }}>Flies in and out</div>
  <div transition:slide>Slides in and out</div>
{/if}
```

### Actions

Reusable element-level functionality:

```svelte
<script>
  function tooltip(node, text) {
    const tooltip = document.createElement('div');
    tooltip.textContent = text;

    function mouseOver() {
      document.body.appendChild(tooltip);
    }

    function mouseMove(event) {
      tooltip.style.left = `${event.pageX + 5}px`;
      tooltip.style.top = `${event.pageY + 5}px`;
    }

    function mouseLeave() {
      document.body.removeChild(tooltip);
    }

    node.addEventListener('mouseover', mouseOver);
    node.addEventListener('mousemove', mouseMove);
    node.addEventListener('mouseleave', mouseLeave);

    return {
      destroy() {
        node.removeEventListener('mouseover', mouseOver);
        node.removeEventListener('mousemove', mouseMove);
        node.removeEventListener('mouseleave', mouseLeave);
      }
    };
  }
</script>

<button use:tooltip="Tooltip text">Hover me</button>
```

## TypeScript Support

Svelte has excellent TypeScript support:

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

  let count: number = $state(0);
  let users: User[] = $state([]);
</script>
```

## Testing

### Component Testing with Vitest

```javascript
import { render, fireEvent } from '@testing-library/svelte';
import { expect, test } from 'vitest';
import Counter from './Counter.svelte';

test('increments counter', async () => {
  const { getByText } = render(Counter);

  const button = getByText('+');
  await fireEvent.click(button);

  expect(getByText('Count: 1')).toBeInTheDocument();
});
```

## Build and Deployment

### Build for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

### Deploy to Vercel

```bash
npm i -g vercel
vercel
```

### Deploy to Netlify

```bash
npm i -g netlify-cli
netlify deploy
```

## Best Practices

1. **Use Svelte 5 Runes** - Prefer `$state`, `$derived`, and `$effect` over legacy syntax
2. **Keep Components Small** - Single responsibility principle
3. **Use Stores for Global State** - Share state across components
4. **Leverage Scoped CSS** - No need for CSS-in-JS libraries
5. **Use TypeScript** - Better type safety and developer experience
6. **Optimize Performance** - Use keyed each blocks for lists
7. **Handle Errors** - Implement error boundaries and loading states
8. **Test Components** - Write unit and integration tests
9. **Follow Accessibility Guidelines** - Use semantic HTML and ARIA attributes
10. **Use SvelteKit** - For full-stack applications with SSR/SSG

## Resources

- [Svelte Documentation](https://svelte.dev/docs)
- [Svelte Tutorial](https://svelte.dev/tutorial)
- [SvelteKit Documentation](https://kit.svelte.dev/docs)
- [Svelte REPL](https://svelte.dev/repl)
- [Svelte Society](https://sveltesociety.dev/)
- [Svelte Discord](https://discord.com/invite/yy75DKs)

## Common Patterns

### Loading States

```svelte
{#if loading}
  <Spinner />
{:else if error}
  <ErrorMessage {error} />
{:else}
  <Content {data} />
{/if}
```

### Conditional Classes

```svelte
<div class:active={isActive} class:disabled={isDisabled}>
  Content
</div>
```

### List Rendering

```svelte
{#each items as item (item.id)}
  <Item {item} />
{/each}
```

### Form Binding

```svelte
<input bind:value={name} />
<textarea bind:value={message} />
<select bind:value={selected}>
  <option value="a">A</option>
  <option value="b">B</option>
</select>
```

## Migration Guide

### From React

- Replace `useState` with `$state`
- Replace `useMemo` with `$derived`
- Replace `useEffect` with `$effect`
- No need for virtual DOM reconciliation
- CSS is scoped by default

### From Vue

- Similar template syntax
- Replace `ref` with `$state`
- Replace `computed` with `$derived`
- Replace `watch` with `$effect`
- No need for `.value` syntax

### From Angular

- Simpler component structure
- No decorators needed
- Built-in reactivity without RxJS
- Smaller bundle sizes
- Easier learning curve

## Performance Tips

1. **Use Keyed Each Blocks** - Helps Svelte identify items
2. **Avoid Unnecessary Reactivity** - Use `$derived` judiciously
3. **Lazy Load Components** - Use dynamic imports
4. **Optimize Images** - Use modern formats and lazy loading
5. **Code Splitting** - Split routes in SvelteKit
6. **Minimize Store Subscriptions** - Unsubscribe when not needed
7. **Use CSS Transforms** - Better than animating layout properties
8. **Profile with DevTools** - Identify bottlenecks

## Ecosystem

### UI Libraries

- **Svelte Material UI** - Material Design components
- **Carbon Components Svelte** - IBM Carbon Design System
- **Flowbite Svelte** - Tailwind CSS components
- **Skeleton** - UI toolkit for Svelte and SvelteKit

### State Management

- **Svelte Stores** - Built-in state management
- **Pinia for Svelte** - Vue-like state management
- **XState** - State machine library

### Routing

- **SvelteKit** - Official routing solution
- **svelte-routing** - Declarative routing
- **Routify** - File-based routing

### Testing

- **Vitest** - Fast unit test framework
- **Playwright** - End-to-end testing
- **Testing Library** - User-centric testing utilities

## Next Steps

1. Complete the [official tutorial](https://svelte.dev/tutorial)
2. Build a simple app (todo list, weather app)
3. Learn SvelteKit for full-stack applications
4. Explore the ecosystem and component libraries
5. Join the community on Discord
6. Contribute to open-source Svelte projects

---

For more detailed examples and patterns, see SKILL.md and EXAMPLES.md in this directory.
