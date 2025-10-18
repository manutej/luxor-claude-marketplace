# Vue.js Development Skill

A comprehensive skill for building modern Vue.js applications with the Composition API, reactivity system, and Vue 3 best practices.

## Overview

This skill provides expert guidance on Vue.js development, covering everything from basic reactivity to advanced patterns like state management, routing, and performance optimization. It's based on official Vue.js documentation (Context7 Trust Score: 9.7) and focuses on modern Vue 3 patterns.

## What This Skill Covers

### Core Vue.js Concepts
- **Reactivity System**: Understanding Vue's reactive primitives (`ref()`, `reactive()`)
- **Composition API**: Modern component organization with `<script setup>`
- **Single-File Components**: Structuring .vue files with template, script, and styles
- **Template Syntax**: Directives, interpolation, and event handling
- **Component Communication**: Props, emits, provide/inject, and slots

### State Management
- Local component state with `ref()` and `reactive()`
- Reusable logic with composables
- Global state management with Pinia
- Advanced patterns for complex applications

### Routing and Navigation
- Vue Router setup and configuration
- Route navigation and guards
- Nested routes and dynamic routing
- Programmatic navigation

### Advanced Features
- **Teleport**: Render content outside component hierarchy
- **Suspense**: Handle async components gracefully
- **Transitions**: Animate elements and lists
- **Custom Directives**: Create reusable DOM manipulations

### Performance Optimization
- Computed properties vs methods
- Lazy loading components and routes
- Virtual scrolling for large lists
- Memoization with `v-memo`

### TypeScript Integration
- Type-safe props and emits
- Typed composables
- Interface definitions for complex data

### Testing
- Component testing with Vue Test Utils
- Composable testing strategies
- Best practices for testable code

## Quick Start

### Installation

```bash
# Create new Vue 3 project
npm create vue@latest

# Or with Vite
npm create vite@latest my-vue-app -- --template vue

# Install dependencies
cd my-vue-app
npm install

# Start development server
npm run dev
```

### Your First Component

Create a simple counter component:

```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
const doubled = computed(() => count.value * 2)

function increment() {
  count.value++
}
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>

<style scoped>
button {
  padding: 8px 16px;
  background: #42b883;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background: #35495e;
}
</style>
```

### Project Structure

```
my-vue-app/
├── public/              # Static assets
├── src/
│   ├── assets/         # Images, fonts, etc.
│   ├── components/     # Reusable components
│   ├── composables/    # Reusable composition functions
│   ├── router/         # Vue Router configuration
│   ├── stores/         # Pinia stores
│   ├── views/          # Route-level components
│   ├── App.vue         # Root component
│   └── main.js         # Application entry point
├── index.html
├── package.json
└── vite.config.js
```

## Key Concepts

### Reactivity

Vue's reactivity system automatically tracks dependencies and updates the DOM when data changes:

```javascript
import { ref, reactive, computed, watch } from 'vue'

// Reactive primitive
const count = ref(0)

// Reactive object
const user = reactive({
  name: 'John',
  age: 30
})

// Computed value
const displayName = computed(() => `${user.name} (${user.age})`)

// Watcher
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})
```

### Composition API

The Composition API provides better code organization and reusability:

```vue
<script setup>
import { ref, onMounted } from 'vue'

// Props and emits
const props = defineProps({
  title: String
})

const emit = defineEmits(['update'])

// Reactive state
const message = ref('Hello')

// Lifecycle hooks
onMounted(() => {
  console.log('Component mounted')
})

// Methods
function handleClick() {
  emit('update', message.value)
}
</script>
```

### Composables

Extract and reuse stateful logic across components:

```javascript
// composables/useMouse.js
import { ref, onMounted, onUnmounted } from 'vue'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)

  function update(event) {
    x.value = event.pageX
    y.value = event.pageY
  }

  onMounted(() => {
    window.addEventListener('mousemove', update)
  })

  onUnmounted(() => {
    window.removeEventListener('mousemove', update)
  })

  return { x, y }
}

// Usage in component
<script setup>
import { useMouse } from '@/composables/useMouse'

const { x, y } = useMouse()
</script>

<template>
  <p>Mouse: {{ x }}, {{ y }}</p>
</template>
```

## Common Patterns

### Form Handling

```vue
<script setup>
import { reactive, ref } from 'vue'

const form = reactive({
  name: '',
  email: '',
  message: ''
})

const errors = ref({})
const isSubmitting = ref(false)

async function handleSubmit() {
  errors.value = {}

  // Validation
  if (!form.name) errors.value.name = 'Name is required'
  if (!form.email) errors.value.email = 'Email is required'

  if (Object.keys(errors.value).length > 0) return

  isSubmitting.value = true
  try {
    await submitForm(form)
  } catch (error) {
    errors.value.submit = error.message
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <div>
      <input v-model="form.name" placeholder="Name">
      <span v-if="errors.name">{{ errors.name }}</span>
    </div>

    <div>
      <input v-model="form.email" type="email" placeholder="Email">
      <span v-if="errors.email">{{ errors.email }}</span>
    </div>

    <div>
      <textarea v-model="form.message" placeholder="Message"></textarea>
    </div>

    <button type="submit" :disabled="isSubmitting">
      {{ isSubmitting ? 'Submitting...' : 'Submit' }}
    </button>

    <div v-if="errors.submit">{{ errors.submit }}</div>
  </form>
</template>
```

### Data Fetching

```vue
<script setup>
import { ref, onMounted } from 'vue'

const data = ref(null)
const loading = ref(true)
const error = ref(null)

async function fetchData() {
  loading.value = true
  error.value = null

  try {
    const response = await fetch('https://api.example.com/data')
    if (!response.ok) throw new Error('Failed to fetch')
    data.value = await response.json()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">Error: {{ error }}</div>
  <div v-else>{{ data }}</div>
</template>
```

### List Management

```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([
  { id: 1, text: 'Item 1', completed: false },
  { id: 2, text: 'Item 2', completed: true }
])

const newItemText = ref('')

const completedCount = computed(() =>
  items.value.filter(item => item.completed).length
)

function addItem() {
  if (newItemText.value.trim()) {
    items.value.push({
      id: Date.now(),
      text: newItemText.value,
      completed: false
    })
    newItemText.value = ''
  }
}

function removeItem(id) {
  items.value = items.value.filter(item => item.id !== id)
}

function toggleItem(id) {
  const item = items.value.find(item => item.id === id)
  if (item) item.completed = !item.completed
}
</script>

<template>
  <div>
    <input v-model="newItemText" @keyup.enter="addItem">
    <button @click="addItem">Add</button>

    <ul>
      <li v-for="item in items" :key="item.id">
        <input
          type="checkbox"
          :checked="item.completed"
          @change="toggleItem(item.id)"
        >
        <span :class="{ completed: item.completed }">{{ item.text }}</span>
        <button @click="removeItem(item.id)">Delete</button>
      </li>
    </ul>

    <p>Completed: {{ completedCount }} / {{ items.length }}</p>
  </div>
</template>
```

## Ecosystem

### Essential Libraries

- **Vue Router**: Official routing library
- **Pinia**: Official state management library
- **VueUse**: Collection of essential Vue composition utilities
- **Vite**: Next-generation build tool
- **Vitest**: Fast unit testing framework

### UI Component Libraries

- **Vuetify**: Material Design component framework
- **Element Plus**: Desktop-focused component library
- **Naive UI**: Vue 3 component library
- **PrimeVue**: Rich UI component suite
- **Quasar**: Build responsive apps

### Development Tools

- **Vue DevTools**: Browser extension for debugging
- **Volar**: VS Code extension for Vue 3
- **ESLint Plugin Vue**: Official ESLint plugin
- **Prettier**: Code formatter

## Resources

### Official Documentation
- [Vue.js Official Docs](https://vuejs.org/)
- [Vue Router](https://router.vuejs.org/)
- [Pinia](https://pinia.vuejs.org/)
- [Vite](https://vitejs.dev/)

### Learning Resources
- [Vue Mastery](https://www.vuemastery.com/)
- [Vue School](https://vueschool.io/)
- [VueUse Documentation](https://vueuse.org/)

### Community
- [Vue.js Forum](https://forum.vuejs.org/)
- [Vue.js Discord](https://discord.com/invite/vue)
- [GitHub Discussions](https://github.com/vuejs/core/discussions)

## Best Practices

1. **Use Composition API** for complex logic and better code organization
2. **Keep components small** and focused on a single responsibility
3. **Use computed properties** for derived state instead of methods
4. **Always use keys** in `v-for` loops with unique identifiers
5. **Validate props** in production components
6. **Use scoped styles** to prevent style leaking
7. **Lazy load routes** for better performance
8. **Extract reusable logic** into composables
9. **Cleanup side effects** in `onUnmounted` hook
10. **Use TypeScript** for better type safety and developer experience

## Performance Tips

- Use `computed()` for expensive calculations
- Implement virtual scrolling for large lists
- Lazy load components and routes
- Use `v-show` for frequently toggled elements
- Use `v-memo` for expensive list items
- Debounce user input handlers
- Use `shallowRef()` and `shallowReactive()` for large objects

## Getting Help

When using this skill, you can ask questions like:
- "How do I create a reusable composable for form validation?"
- "What's the best way to handle authentication state in Vue 3?"
- "How do I optimize a component with a large list?"
- "How do I test a component that uses Pinia?"
- "What's the difference between ref() and reactive()?"

## License

This skill documentation is based on official Vue.js documentation and community best practices.

## Related Skills

- **TypeScript Development**: For type-safe Vue applications
- **Testing**: For comprehensive testing strategies
- **Web Performance**: For optimization techniques
- **Accessibility**: For building accessible Vue applications

## Version

**1.0.0** - Based on Vue 3 and official documentation (Context7 Trust Score: 9.7)

Last Updated: 2025
