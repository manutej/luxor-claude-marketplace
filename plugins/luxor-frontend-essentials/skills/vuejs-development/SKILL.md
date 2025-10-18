---
name: vuejs-development
description: Comprehensive Vue.js development skill covering Composition API, reactivity system, components, directives, and modern Vue 3 patterns based on official Vue.js documentation
category: frontend
tags: [vue, vuejs, composition-api, reactivity, components, directives, sfc]
version: 1.0.0
context7_library: /vuejs/docs
context7_trust_score: 9.7
---

# Vue.js Development Skill

This skill provides comprehensive guidance for building modern Vue.js applications using the Composition API, reactivity system, single-file components, directives, and lifecycle hooks based on official Vue.js documentation.

## When to Use This Skill

Use this skill when:
- Building single-page applications (SPAs) with Vue.js
- Creating progressive web applications (PWAs) with Vue
- Developing interactive user interfaces with reactive data
- Building component-based architectures
- Implementing forms, data fetching, and state management
- Creating reusable UI components and libraries
- Migrating from Options API to Composition API
- Optimizing Vue application performance
- Building accessible and maintainable web applications
- Integrating with TypeScript for type-safe development

## Core Concepts

### Reactivity System

Vue's reactivity system is the core mechanism that tracks dependencies and automatically updates the DOM when data changes.

**Reactive State with ref():**
```javascript
import { ref } from 'vue'

// ref creates a reactive reference to a value
const count = ref(0)

// Access value with .value
console.log(count.value) // 0

// Modify value
count.value++
console.log(count.value) // 1

// In templates, .value is automatically unwrapped
// <template>{{ count }}</template>
```

**Reactive Objects with reactive():**
```javascript
import { reactive } from 'vue'

// reactive creates a reactive proxy of an object
const state = reactive({
  name: 'Vue',
  version: 3,
  features: ['Composition API', 'Teleport', 'Suspense']
})

// Access and modify properties directly
console.log(state.name) // 'Vue'
state.name = 'Vue.js'

// Nested objects are also reactive
state.features.push('Fragments')
```

**When to Use ref() vs reactive():**
```javascript
// Use ref() for:
// - Primitive values (string, number, boolean)
// - Single values that need reactivity
const count = ref(0)
const message = ref('Hello')
const isActive = ref(true)

// Use reactive() for:
// - Objects with multiple properties
// - Complex data structures
const user = reactive({
  id: 1,
  name: 'John',
  email: 'john@example.com',
  preferences: {
    theme: 'dark',
    notifications: true
  }
})
```

**Computed Properties:**
```javascript
import { ref, computed } from 'vue'

const count = ref(0)

// Computed property automatically tracks dependencies
const doubled = computed(() => count.value * 2)

console.log(doubled.value) // 0
count.value = 5
console.log(doubled.value) // 10

// Writable computed
const firstName = ref('John')
const lastName = ref('Doe')

const fullName = computed({
  get() {
    return `${firstName.value} ${lastName.value}`
  },
  set(newValue) {
    [firstName.value, lastName.value] = newValue.split(' ')
  }
})

fullName.value = 'Jane Smith'
console.log(firstName.value) // 'Jane'
console.log(lastName.value) // 'Smith'
```

**Watchers:**
```javascript
import { ref, watch, watchEffect } from 'vue'

const count = ref(0)
const message = ref('Hello')

// Watch a single ref
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})

// Watch multiple sources
watch([count, message], ([newCount, newMessage], [oldCount, oldMessage]) => {
  console.log(`Count: ${newCount}, Message: ${newMessage}`)
})

// Watch reactive object property
const state = reactive({ count: 0 })
watch(
  () => state.count,
  (newValue, oldValue) => {
    console.log(`State count changed from ${oldValue} to ${newValue}`)
  }
)

// watchEffect automatically tracks dependencies
watchEffect(() => {
  console.log(`Count is ${count.value}`)
  // Automatically re-runs when count changes
})

// Immediate execution
watch(count, (newValue) => {
  console.log(`Count is now ${newValue}`)
}, { immediate: true })

// Deep watching
const user = reactive({ profile: { name: 'John' } })
watch(user, (newValue) => {
  console.log('User changed:', newValue)
}, { deep: true })
```

### Composition API

The Composition API provides a set of function-based APIs for organizing component logic.

**Basic Component with <script setup>:**
```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

// Props
const props = defineProps({
  title: String,
  count: {
    type: Number,
    default: 0
  }
})

// Emits
const emit = defineEmits(['update', 'delete'])

// Reactive state
const localCount = ref(props.count)
const message = ref('Hello Vue!')

// Computed
const doubledCount = computed(() => localCount.value * 2)

// Methods
function increment() {
  localCount.value++
  emit('update', localCount.value)
}

// Lifecycle
onMounted(() => {
  console.log('Component mounted')
})
</script>

<template>
  <div>
    <h2>{{ title }}</h2>
    <p>{{ message }}</p>
    <p>Count: {{ localCount }}</p>
    <p>Doubled: {{ doubledCount }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

**Component without <script setup> (verbose syntax):**
```vue
<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'MyComponent',
  props: {
    title: String,
    count: {
      type: Number,
      default: 0
    }
  },
  emits: ['update', 'delete'],
  setup(props, { emit }) {
    const localCount = ref(props.count)
    const message = ref('Hello Vue!')

    const doubledCount = computed(() => localCount.value * 2)

    function increment() {
      localCount.value++
      emit('update', localCount.value)
    }

    onMounted(() => {
      console.log('Component mounted')
    })

    return {
      localCount,
      message,
      doubledCount,
      increment
    }
  }
}
</script>
```

### Single-File Components

Single-file components (.vue) combine template, script, and styles in one file.

**Complete SFC Example:**
```vue
<script setup>
import { ref, computed } from 'vue'

const tasks = ref([
  { id: 1, text: 'Learn Vue', completed: false },
  { id: 2, text: 'Build app', completed: false }
])

const newTaskText = ref('')

const completedCount = computed(() =>
  tasks.value.filter(t => t.completed).length
)

const remainingCount = computed(() =>
  tasks.value.filter(t => !t.completed).length
)

function addTask() {
  if (newTaskText.value.trim()) {
    tasks.value.push({
      id: Date.now(),
      text: newTaskText.value,
      completed: false
    })
    newTaskText.value = ''
  }
}

function toggleTask(id) {
  const task = tasks.value.find(t => t.id === id)
  if (task) task.completed = !task.completed
}

function removeTask(id) {
  tasks.value = tasks.value.filter(t => t.id !== id)
}
</script>

<template>
  <div class="todo-app">
    <h1>Todo List</h1>

    <div class="add-task">
      <input
        v-model="newTaskText"
        @keyup.enter="addTask"
        placeholder="Add new task"
      >
      <button @click="addTask">Add</button>
    </div>

    <ul class="task-list">
      <li
        v-for="task in tasks"
        :key="task.id"
        :class="{ completed: task.completed }"
      >
        <input
          type="checkbox"
          :checked="task.completed"
          @change="toggleTask(task.id)"
        >
        <span>{{ task.text }}</span>
        <button @click="removeTask(task.id)">Delete</button>
      </li>
    </ul>

    <div class="stats">
      <p>Completed: {{ completedCount }}</p>
      <p>Remaining: {{ remainingCount }}</p>
    </div>
  </div>
</template>

<style scoped>
.todo-app {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
}

.add-task {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.add-task input {
  flex: 1;
  padding: 8px;
  font-size: 14px;
}

.task-list {
  list-style: none;
  padding: 0;
}

.task-list li {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border-bottom: 1px solid #eee;
}

.task-list li.completed span {
  text-decoration: line-through;
  opacity: 0.6;
}

.stats {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px solid #eee;
}

.stats p {
  margin: 5px 0;
}
</style>
```

### Template Syntax and Directives

Vue uses an HTML-based template syntax with special directives.

**Text Interpolation:**
```vue
<template>
  <div>
    <!-- Basic interpolation -->
    <p>{{ message }}</p>

    <!-- JavaScript expressions -->
    <p>{{ count + 1 }}</p>
    <p>{{ ok ? 'YES' : 'NO' }}</p>
    <p>{{ message.split('').reverse().join('') }}</p>

    <!-- Calling functions -->
    <p>{{ formatDate(timestamp) }}</p>
  </div>
</template>
```

**v-bind - Attribute Binding:**
```vue
<template>
  <!-- Bind attribute -->
  <img v-bind:src="imageUrl" v-bind:alt="imageAlt">

  <!-- Shorthand -->
  <img :src="imageUrl" :alt="imageAlt">

  <!-- Dynamic attribute name -->
  <button :[attributeName]="value">Click</button>

  <!-- Bind multiple attributes -->
  <div v-bind="objectOfAttrs"></div>

  <!-- Class binding -->
  <div :class="{ active: isActive, 'text-danger': hasError }"></div>
  <div :class="[activeClass, errorClass]"></div>
  <div :class="[isActive ? activeClass : '', errorClass]"></div>

  <!-- Style binding -->
  <div :style="{ color: activeColor, fontSize: fontSize + 'px' }"></div>
  <div :style="[baseStyles, overridingStyles]"></div>
</template>

<script setup>
import { ref, reactive } from 'vue'

const imageUrl = ref('/path/to/image.jpg')
const imageAlt = ref('Description')
const isActive = ref(true)
const hasError = ref(false)
const activeClass = ref('active')
const errorClass = ref('text-danger')
const activeColor = ref('red')
const fontSize = ref(14)

const objectOfAttrs = reactive({
  id: 'container',
  class: 'wrapper'
})
</script>
```

**v-on - Event Handling:**
```vue
<template>
  <!-- Method handler -->
  <button v-on:click="handleClick">Click me</button>

  <!-- Shorthand -->
  <button @click="handleClick">Click me</button>

  <!-- Inline handler -->
  <button @click="count++">Increment</button>

  <!-- Pass arguments -->
  <button @click="handleClick('hello', $event)">Click</button>

  <!-- Event modifiers -->
  <form @submit.prevent="onSubmit">Submit</form>
  <button @click.stop="handleClick">Stop Propagation</button>
  <div @click.self="handleClick">Only Self</div>
  <button @click.once="handleClick">Once</button>

  <!-- Key modifiers -->
  <input @keyup.enter="submit">
  <input @keyup.esc="cancel">
  <input @keyup.ctrl.s="save">

  <!-- Mouse modifiers -->
  <button @click.left="handleLeft">Left Click</button>
  <button @click.right="handleRight">Right Click</button>
  <button @click.middle="handleMiddle">Middle Click</button>
</template>

<script setup>
function handleClick(message, event) {
  console.log(message, event)
}

function onSubmit() {
  console.log('Form submitted')
}
</script>
```

**v-model - Two-Way Binding:**
```vue
<template>
  <!-- Text input -->
  <input v-model="text">
  <p>{{ text }}</p>

  <!-- Textarea -->
  <textarea v-model="message"></textarea>

  <!-- Checkbox -->
  <input type="checkbox" v-model="checked">

  <!-- Multiple checkboxes -->
  <input type="checkbox" value="Vue" v-model="checkedNames">
  <input type="checkbox" value="React" v-model="checkedNames">
  <input type="checkbox" value="Angular" v-model="checkedNames">
  <p>{{ checkedNames }}</p>

  <!-- Radio -->
  <input type="radio" value="One" v-model="picked">
  <input type="radio" value="Two" v-model="picked">

  <!-- Select -->
  <select v-model="selected">
    <option disabled value="">Please select</option>
    <option>A</option>
    <option>B</option>
    <option>C</option>
  </select>

  <!-- Multiple select -->
  <select v-model="multiSelected" multiple>
    <option>A</option>
    <option>B</option>
    <option>C</option>
  </select>

  <!-- Modifiers -->
  <input v-model.lazy="text">        <!-- Update on change, not input -->
  <input v-model.number="age">       <!-- Auto typecast to number -->
  <input v-model.trim="message">     <!-- Auto trim whitespace -->

  <!-- Custom component v-model -->
  <CustomInput v-model="searchText" />
</template>

<script setup>
import { ref } from 'vue'

const text = ref('')
const message = ref('')
const checked = ref(false)
const checkedNames = ref([])
const picked = ref('')
const selected = ref('')
const multiSelected = ref([])
const age = ref(0)
const searchText = ref('')
</script>
```

**v-if, v-else-if, v-else - Conditional Rendering:**
```vue
<template>
  <div v-if="type === 'A'">
    Type A
  </div>
  <div v-else-if="type === 'B'">
    Type B
  </div>
  <div v-else-if="type === 'C'">
    Type C
  </div>
  <div v-else>
    Not A, B, or C
  </div>

  <!-- v-if with template (doesn't render wrapper) -->
  <template v-if="ok">
    <h1>Title</h1>
    <p>Paragraph 1</p>
    <p>Paragraph 2</p>
  </template>
</template>

<script setup>
import { ref } from 'vue'
const type = ref('A')
const ok = ref(true)
</script>
```

**v-show - Toggle Display:**
```vue
<template>
  <!-- v-show toggles CSS display property -->
  <h1 v-show="isVisible">Hello!</h1>

  <!-- v-if vs v-show:
       - v-if: truly conditional, destroys/recreates elements
       - v-show: always rendered, toggles display CSS
       - Use v-show for frequent toggles
       - Use v-if for rarely changing conditions
  -->
</template>

<script setup>
import { ref } from 'vue'
const isVisible = ref(true)
</script>
```

**v-for - List Rendering:**
```vue
<template>
  <!-- Array iteration -->
  <ul>
    <li v-for="item in items" :key="item.id">
      {{ item.text }}
    </li>
  </ul>

  <!-- With index -->
  <ul>
    <li v-for="(item, index) in items" :key="item.id">
      {{ index }}: {{ item.text }}
    </li>
  </ul>

  <!-- Object iteration -->
  <ul>
    <li v-for="(value, key) in user" :key="key">
      {{ key }}: {{ value }}
    </li>
  </ul>

  <!-- With index for objects -->
  <ul>
    <li v-for="(value, key, index) in user" :key="key">
      {{ index }}. {{ key }}: {{ value }}
    </li>
  </ul>

  <!-- Range -->
  <span v-for="n in 10" :key="n">{{ n }}</span>

  <!-- v-for with v-if (not recommended) -->
  <!-- Use computed instead -->
  <ul>
    <li v-for="item in activeItems" :key="item.id">
      {{ item.text }}
    </li>
  </ul>

  <!-- v-for with template -->
  <template v-for="item in items" :key="item.id">
    <li>{{ item.text }}</li>
    <li class="divider"></li>
  </template>
</template>

<script setup>
import { ref, computed } from 'vue'

const items = ref([
  { id: 1, text: 'Learn Vue', active: true },
  { id: 2, text: 'Build app', active: false },
  { id: 3, text: 'Deploy', active: true }
])

const user = ref({
  name: 'John',
  age: 30,
  email: 'john@example.com'
})

const activeItems = computed(() =>
  items.value.filter(item => item.active)
)
</script>
```

### Lifecycle Hooks

Lifecycle hooks let you run code at specific stages of a component's lifecycle.

**Lifecycle Hooks in Composition API:**
```vue
<script setup>
import {
  ref,
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
  onErrorCaptured,
  onActivated,
  onDeactivated
} from 'vue'

const count = ref(0)

// Before component is mounted
onBeforeMount(() => {
  console.log('Before mount')
})

// After component is mounted (DOM available)
onMounted(() => {
  console.log('Mounted')
  // Good for: API calls, DOM manipulation, timers
  fetchData()
  setupEventListeners()
})

// Before component updates (reactive data changed)
onBeforeUpdate(() => {
  console.log('Before update')
})

// After component updates
onUpdated(() => {
  console.log('Updated')
  // Good for: DOM operations after data changes
})

// Before component is unmounted
onBeforeUnmount(() => {
  console.log('Before unmount')
  // Good for: Cleanup
})

// After component is unmounted
onUnmounted(() => {
  console.log('Unmounted')
  // Good for: Cleanup timers, event listeners
  clearInterval(interval)
  removeEventListeners()
})

// Error handling
onErrorCaptured((err, instance, info) => {
  console.error('Error captured:', err, info)
  return false // Prevent error from propagating
})

// For components in <keep-alive>
onActivated(() => {
  console.log('Component activated')
})

onDeactivated(() => {
  console.log('Component deactivated')
})
</script>
```

**Lifecycle Diagram:**
```
Creation Phase:
  setup() → onBeforeMount() → onMounted()

Update Phase (when reactive data changes):
  onBeforeUpdate() → onUpdated()

Destruction Phase:
  onBeforeUnmount() → onUnmounted()
```

## Component Communication

### Props (Parent to Child)

```vue
<!-- Child Component: UserCard.vue -->
<script setup>
// Define props with types
const props = defineProps({
  name: String,
  age: Number,
  email: String,
  isActive: {
    type: Boolean,
    default: true
  },
  roles: {
    type: Array,
    default: () => []
  },
  profile: {
    type: Object,
    required: true,
    validator: (value) => {
      return value.id && value.name
    }
  }
})

// Props are reactive and can be used in computed
import { computed } from 'vue'

const displayName = computed(() =>
  `${props.name} (${props.age})`
)
</script>

<template>
  <div class="user-card">
    <h3>{{ displayName }}</h3>
    <p>{{ email }}</p>
    <span v-if="isActive">Active</span>
    <ul>
      <li v-for="role in roles" :key="role">{{ role }}</li>
    </ul>
  </div>
</template>

<!-- Parent Component -->
<script setup>
import UserCard from './UserCard.vue'
import { reactive } from 'vue'

const user = reactive({
  name: 'John Doe',
  age: 30,
  email: 'john@example.com',
  isActive: true,
  roles: ['admin', 'editor'],
  profile: {
    id: 1,
    name: 'John'
  }
})
</script>

<template>
  <UserCard
    :name="user.name"
    :age="user.age"
    :email="user.email"
    :is-active="user.isActive"
    :roles="user.roles"
    :profile="user.profile"
  />

  <!-- Or pass entire object -->
  <UserCard v-bind="user" />
</template>
```

### Emits (Child to Parent)

```vue
<!-- Child Component: TodoItem.vue -->
<script setup>
const props = defineProps({
  todo: {
    type: Object,
    required: true
  }
})

// Define emits
const emit = defineEmits(['toggle', 'delete', 'update'])

// Or with validation
const emit = defineEmits({
  toggle: (id) => {
    if (typeof id === 'number') {
      return true
    } else {
      console.warn('Invalid toggle event payload')
      return false
    }
  },
  delete: (id) => typeof id === 'number',
  update: (id, text) => {
    return typeof id === 'number' && typeof text === 'string'
  }
})

function handleToggle() {
  emit('toggle', props.todo.id)
}

function handleDelete() {
  emit('delete', props.todo.id)
}

function handleUpdate(newText) {
  emit('update', props.todo.id, newText)
}
</script>

<template>
  <div class="todo-item">
    <input
      type="checkbox"
      :checked="todo.completed"
      @change="handleToggle"
    >
    <span>{{ todo.text }}</span>
    <button @click="handleDelete">Delete</button>
  </div>
</template>

<!-- Parent Component -->
<script setup>
import TodoItem from './TodoItem.vue'
import { ref } from 'vue'

const todos = ref([
  { id: 1, text: 'Learn Vue', completed: false },
  { id: 2, text: 'Build app', completed: false }
])

function toggleTodo(id) {
  const todo = todos.value.find(t => t.id === id)
  if (todo) todo.completed = !todo.completed
}

function deleteTodo(id) {
  todos.value = todos.value.filter(t => t.id !== id)
}

function updateTodo(id, text) {
  const todo = todos.value.find(t => t.id === id)
  if (todo) todo.text = text
}
</script>

<template>
  <div>
    <TodoItem
      v-for="todo in todos"
      :key="todo.id"
      :todo="todo"
      @toggle="toggleTodo"
      @delete="deleteTodo"
      @update="updateTodo"
    />
  </div>
</template>
```

### Provide/Inject (Ancestor to Descendant)

```vue
<!-- Ancestor Component: App.vue -->
<script setup>
import { provide, ref } from 'vue'
import ChildComponent from './ChildComponent.vue'

const theme = ref('dark')
const userSettings = ref({
  fontSize: 14,
  language: 'en'
})

// Provide to all descendants
provide('theme', theme)
provide('userSettings', userSettings)

// Provide with readonly to prevent modifications
import { readonly } from 'vue'
provide('theme', readonly(theme))

// Provide functions
function updateTheme(newTheme) {
  theme.value = newTheme
}
provide('updateTheme', updateTheme)
</script>

<template>
  <div>
    <ChildComponent />
  </div>
</template>

<!-- Descendant Component (any level deep) -->
<script setup>
import { inject } from 'vue'

// Inject provided values
const theme = inject('theme')
const userSettings = inject('userSettings')
const updateTheme = inject('updateTheme')

// With default value
const locale = inject('locale', 'en')

// With factory function for default
const settings = inject('settings', () => ({ mode: 'light' }))
</script>

<template>
  <div :class="`theme-${theme}`">
    <p>Font size: {{ userSettings.fontSize }}</p>
    <button @click="updateTheme('light')">Light Theme</button>
    <button @click="updateTheme('dark')">Dark Theme</button>
  </div>
</template>
```

### Slots (Parent Content Distribution)

```vue
<!-- Child Component: Card.vue -->
<script setup>
const props = defineProps({
  title: String
})
</script>

<template>
  <div class="card">
    <!-- Named slot with fallback -->
    <header>
      <slot name="header">
        <h2>{{ title }}</h2>
      </slot>
    </header>

    <!-- Default slot -->
    <main>
      <slot>
        <p>Default content</p>
      </slot>
    </main>

    <!-- Named slot -->
    <footer>
      <slot name="footer"></slot>
    </footer>
  </div>
</template>

<!-- Parent Component -->
<template>
  <Card title="My Card">
    <template #header>
      <h1>Custom Header</h1>
    </template>

    <p>Main content goes here</p>

    <template #footer>
      <button>Action</button>
    </template>
  </Card>
</template>

<!-- Scoped Slots: Child exposes data to parent -->
<!-- Child Component: TodoList.vue -->
<script setup>
import { ref } from 'vue'

const todos = ref([
  { id: 1, text: 'Learn Vue', completed: false },
  { id: 2, text: 'Build app', completed: true }
])
</script>

<template>
  <ul>
    <li v-for="todo in todos" :key="todo.id">
      <!-- Expose todo to parent via slot props -->
      <slot :todo="todo" :index="todo.id"></slot>
    </li>
  </ul>
</template>

<!-- Parent Component -->
<template>
  <TodoList>
    <!-- Access slot props -->
    <template #default="{ todo, index }">
      <span :class="{ completed: todo.completed }">
        {{ index }}. {{ todo.text }}
      </span>
    </template>
  </TodoList>

  <!-- Shorthand for default slot -->
  <TodoList v-slot="{ todo }">
    <span>{{ todo.text }}</span>
  </TodoList>
</template>
```

## State Management Patterns

### Local Component State

```vue
<script setup>
import { ref, reactive } from 'vue'

// Simple counter state
const count = ref(0)

function increment() {
  count.value++
}

// Form state
const formData = reactive({
  name: '',
  email: '',
  message: ''
})

function submitForm() {
  console.log('Submitting:', formData)
}

function resetForm() {
  formData.name = ''
  formData.email = ''
  formData.message = ''
}
</script>
```

### Composables (Reusable State Logic)

```javascript
// composables/useCounter.js
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)

  const doubled = computed(() => count.value * 2)

  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  function reset() {
    count.value = initialValue
  }

  return {
    count,
    doubled,
    increment,
    decrement,
    reset
  }
}

// Usage in component
<script setup>
import { useCounter } from '@/composables/useCounter'

const { count, doubled, increment, decrement, reset } = useCounter(10)
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="increment">+</button>
    <button @click="decrement">-</button>
    <button @click="reset">Reset</button>
  </div>
</template>
```

**Mouse Position Composable:**
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

// Usage
<script setup>
import { useMouse } from '@/composables/useMouse'

const { x, y } = useMouse()
</script>

<template>
  <p>Mouse position: {{ x }}, {{ y }}</p>
</template>
```

**Fetch Composable:**
```javascript
// composables/useFetch.js
import { ref, watchEffect, toValue } from 'vue'

export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)

  watchEffect(async () => {
    loading.value = true
    data.value = null
    error.value = null

    const urlValue = toValue(url)

    try {
      const response = await fetch(urlValue)
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      data.value = await response.json()
    } catch (e) {
      error.value = e
    } finally {
      loading.value = false
    }
  })

  return { data, error, loading }
}

// Usage
<script setup>
import { ref } from 'vue'
import { useFetch } from '@/composables/useFetch'

const userId = ref(1)
const url = computed(() => `https://api.example.com/users/${userId.value}`)

const { data: user, error, loading } = useFetch(url)
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">Error: {{ error.message }}</div>
  <div v-else-if="user">{{ user.name }}</div>
</template>
```

### Global State with Pinia

```javascript
// stores/counter.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// Option 1: Setup Stores (Composition API style)
export const useCounterStore = defineStore('counter', () => {
  // State
  const count = ref(0)
  const name = ref('Counter')

  // Getters
  const doubleCount = computed(() => count.value * 2)

  // Actions
  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  async function incrementAsync() {
    await new Promise(resolve => setTimeout(resolve, 1000))
    count.value++
  }

  return {
    count,
    name,
    doubleCount,
    increment,
    decrement,
    incrementAsync
  }
})

// Option 2: Options Stores
export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0,
    name: 'Counter'
  }),

  getters: {
    doubleCount: (state) => state.count * 2,
    doublePlusOne() {
      return this.doubleCount + 1
    }
  },

  actions: {
    increment() {
      this.count++
    },
    decrement() {
      this.count--
    },
    async incrementAsync() {
      await new Promise(resolve => setTimeout(resolve, 1000))
      this.count++
    }
  }
})

// Usage in component
<script setup>
import { useCounterStore } from '@/stores/counter'
import { storeToRefs } from 'pinia'

const counterStore = useCounterStore()

// Extract reactive state (preserves reactivity)
const { count, name, doubleCount } = storeToRefs(counterStore)

// Actions can be destructured directly
const { increment, decrement } = counterStore
</script>

<template>
  <div>
    <p>{{ name }}: {{ count }}</p>
    <p>Double: {{ doubleCount }}</p>
    <button @click="increment">+</button>
    <button @click="decrement">-</button>
  </div>
</template>
```

## Routing with Vue Router

**Router Setup:**
```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import About from '@/views/About.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: Home
  },
  {
    path: '/about',
    name: 'about',
    component: About
  },
  {
    path: '/user/:id',
    name: 'user',
    component: () => import('@/views/User.vue'), // Lazy loading
    props: true // Pass route params as props
  },
  {
    path: '/posts',
    name: 'posts',
    component: () => import('@/views/Posts.vue'),
    children: [
      {
        path: ':id',
        name: 'post-detail',
        component: () => import('@/views/PostDetail.vue')
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFound.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guards
router.beforeEach((to, from, next) => {
  // Check authentication, etc.
  if (to.meta.requiresAuth && !isAuthenticated()) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

**Using Router in Components:**
```vue
<script setup>
import { useRouter, useRoute } from 'vue-router'
import { computed } from 'vue'

const router = useRouter()
const route = useRoute()

// Access route params
const userId = computed(() => route.params.id)

// Access query params
const searchQuery = computed(() => route.query.q)

// Programmatic navigation
function goToHome() {
  router.push('/')
}

function goToUser(id) {
  router.push({ name: 'user', params: { id } })
}

function goBack() {
  router.back()
}

function goToSearch(query) {
  router.push({ path: '/search', query: { q: query } })
}
</script>

<template>
  <div>
    <!-- Declarative navigation -->
    <router-link to="/">Home</router-link>
    <router-link :to="{ name: 'about' }">About</router-link>
    <router-link :to="`/user/${userId}`">User Profile</router-link>

    <!-- Active class styling -->
    <router-link
      to="/dashboard"
      active-class="active"
      exact-active-class="exact-active"
    >
      Dashboard
    </router-link>

    <!-- Programmatic navigation -->
    <button @click="goToHome">Go Home</button>
    <button @click="goToUser(123)">View User 123</button>
    <button @click="goBack">Go Back</button>

    <!-- Render matched component -->
    <router-view />

    <!-- Named views -->
    <router-view name="sidebar" />
    <router-view name="main" />
  </div>
</template>
```

## Advanced Features

### Teleport

Move content to a different location in the DOM.

```vue
<script setup>
import { ref } from 'vue'

const showModal = ref(false)
</script>

<template>
  <div class="app">
    <h1>My App</h1>
    <button @click="showModal = true">Open Modal</button>

    <!-- Teleport modal to body -->
    <Teleport to="body">
      <div v-if="showModal" class="modal">
        <div class="modal-content">
          <h2>Modal Title</h2>
          <p>Modal content</p>
          <button @click="showModal = false">Close</button>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
}
</style>
```

### Suspense

Handle async components with loading states.

```vue
<!-- Async component -->
<script setup>
const data = await fetch('/api/data').then(r => r.json())
</script>

<template>
  <div>{{ data }}</div>
</template>

<!-- Parent using Suspense -->
<template>
  <Suspense>
    <!-- Component with async setup -->
    <template #default>
      <AsyncComponent />
    </template>

    <!-- Loading state -->
    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>

<!-- Error handling with Suspense -->
<script setup>
import { onErrorCaptured, ref } from 'vue'

const error = ref(null)

onErrorCaptured((err) => {
  error.value = err
  return true
})
</script>

<template>
  <div v-if="error">Error: {{ error.message }}</div>
  <Suspense v-else>
    <AsyncComponent />
    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>
```

### Transitions

Animate elements entering/leaving the DOM.

```vue
<script setup>
import { ref } from 'vue'

const show = ref(true)
</script>

<template>
  <button @click="show = !show">Toggle</button>

  <!-- Basic transition -->
  <Transition>
    <p v-if="show">Hello</p>
  </Transition>

  <!-- Named transition -->
  <Transition name="fade">
    <p v-if="show">Fade transition</p>
  </Transition>

  <!-- Custom classes -->
  <Transition
    enter-active-class="animate__animated animate__fadeIn"
    leave-active-class="animate__animated animate__fadeOut"
  >
    <p v-if="show">Custom animation</p>
  </Transition>

  <!-- List transitions -->
  <TransitionGroup name="list" tag="ul">
    <li v-for="item in items" :key="item.id">
      {{ item.text }}
    </li>
  </TransitionGroup>
</template>

<style>
/* Transition classes */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* List transitions */
.list-enter-active,
.list-leave-active {
  transition: all 0.3s ease;
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

.list-move {
  transition: transform 0.3s ease;
}
</style>
```

### Custom Directives

Create custom directives for DOM manipulation.

```javascript
// directives/focus.js
export const vFocus = {
  mounted(el) {
    el.focus()
  }
}

// directives/click-outside.js
export const vClickOutside = {
  mounted(el, binding) {
    el.clickOutsideEvent = (event) => {
      if (!(el === event.target || el.contains(event.target))) {
        binding.value(event)
      }
    }
    document.addEventListener('click', el.clickOutsideEvent)
  },
  unmounted(el) {
    document.removeEventListener('click', el.clickOutsideEvent)
  }
}

// Usage in component
<script setup>
import { vFocus } from '@/directives/focus'
import { vClickOutside } from '@/directives/click-outside'
import { ref } from 'vue'

const show = ref(false)

function closeDropdown() {
  show.value = false
}
</script>

<template>
  <!-- Auto-focus input -->
  <input v-focus type="text">

  <!-- Click outside to close -->
  <div v-click-outside="closeDropdown">
    <button @click="show = !show">Toggle</button>
    <div v-if="show">Dropdown content</div>
  </div>
</template>
```

## Performance Optimization

### Computed vs Methods

```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([1, 2, 3, 4, 5])

// Computed: cached, only re-runs when dependencies change
const total = computed(() => {
  console.log('Computing total')
  return items.value.reduce((sum, n) => sum + n, 0)
})

// Method: runs on every render
function getTotal() {
  console.log('Getting total')
  return items.value.reduce((sum, n) => sum + n, 0)
}
</script>

<template>
  <!-- Computed is called once and cached -->
  <p>{{ total }}</p>
  <p>{{ total }}</p>

  <!-- Method is called twice -->
  <p>{{ getTotal() }}</p>
  <p>{{ getTotal() }}</p>
</template>
```

### v-once and v-memo

```vue
<template>
  <!-- Render once, never update -->
  <div v-once>
    <h1>{{ title }}</h1>
    <p>{{ description }}</p>
  </div>

  <!-- Memoize based on dependencies -->
  <div v-memo="[count, message]">
    <p>{{ count }}</p>
    <p>{{ message }}</p>
    <!-- Only re-renders when count or message changes -->
  </div>

  <!-- Useful for long lists -->
  <div
    v-for="item in list"
    :key="item.id"
    v-memo="[item.selected]"
  >
    <!-- Only re-renders when item.selected changes -->
    {{ item.name }}
  </div>
</template>
```

### Lazy Loading Components

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

// Lazy load component
const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)

// With loading and error components
const AsyncComponent = defineAsyncComponent({
  loader: () => import('./AsyncComponent.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorDisplay,
  delay: 200,
  timeout: 3000
})
</script>

<template>
  <Suspense>
    <HeavyComponent />
    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>
```

### Virtual Scrolling

```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref(Array.from({ length: 10000 }, (_, i) => ({
  id: i,
  text: `Item ${i}`
})))

const containerHeight = 400
const itemHeight = 50
const visibleCount = Math.ceil(containerHeight / itemHeight)

const scrollTop = ref(0)

const startIndex = computed(() =>
  Math.floor(scrollTop.value / itemHeight)
)

const endIndex = computed(() =>
  Math.min(startIndex.value + visibleCount + 1, items.value.length)
)

const visibleItems = computed(() =>
  items.value.slice(startIndex.value, endIndex.value)
)

const offsetY = computed(() =>
  startIndex.value * itemHeight
)

const totalHeight = computed(() =>
  items.value.length * itemHeight
)

function handleScroll(event) {
  scrollTop.value = event.target.scrollTop
}
</script>

<template>
  <div
    class="virtual-scroll-container"
    :style="{ height: `${containerHeight}px`, overflow: 'auto' }"
    @scroll="handleScroll"
  >
    <div :style="{ height: `${totalHeight}px`, position: 'relative' }">
      <div :style="{ transform: `translateY(${offsetY}px)` }">
        <div
          v-for="item in visibleItems"
          :key="item.id"
          :style="{ height: `${itemHeight}px` }"
        >
          {{ item.text }}
        </div>
      </div>
    </div>
  </div>
</template>
```

## TypeScript Integration

### Basic Setup

```typescript
// Component with TypeScript
<script setup lang="ts">
import { ref, computed, type Ref } from 'vue'

// Type annotations
const count: Ref<number> = ref(0)
const message = ref<string>('Hello')

// Interface for objects
interface User {
  id: number
  name: string
  email: string
}

const user = ref<User>({
  id: 1,
  name: 'John',
  email: 'john@example.com'
})

// Props with types
interface Props {
  title: string
  count?: number
  user: User
}

const props = withDefaults(defineProps<Props>(), {
  count: 0
})

// Emits with types
interface Emits {
  (e: 'update', value: number): void
  (e: 'delete', id: number): void
}

const emit = defineEmits<Emits>()

// Computed with type inference
const doubled = computed(() => props.count * 2)

// Typed function
function updateUser(id: number, name: string): void {
  user.value.id = id
  user.value.name = name
}
</script>
```

### Composables with TypeScript

```typescript
// composables/useCounter.ts
import { ref, computed, type Ref, type ComputedRef } from 'vue'

interface UseCounterReturn {
  count: Ref<number>
  doubled: ComputedRef<number>
  increment: () => void
  decrement: () => void
}

export function useCounter(initialValue = 0): UseCounterReturn {
  const count = ref(initialValue)
  const doubled = computed(() => count.value * 2)

  function increment(): void {
    count.value++
  }

  function decrement(): void {
    count.value--
  }

  return {
    count,
    doubled,
    increment,
    decrement
  }
}
```

## Testing

### Component Testing with Vitest

```javascript
// Counter.test.js
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import Counter from './Counter.vue'

describe('Counter', () => {
  it('renders initial count', () => {
    const wrapper = mount(Counter, {
      props: {
        initialCount: 5
      }
    })

    expect(wrapper.text()).toContain('5')
  })

  it('increments count when button clicked', async () => {
    const wrapper = mount(Counter)

    await wrapper.find('button.increment').trigger('click')

    expect(wrapper.vm.count).toBe(1)
    expect(wrapper.text()).toContain('1')
  })

  it('emits update event', async () => {
    const wrapper = mount(Counter)

    await wrapper.find('button.increment').trigger('click')

    expect(wrapper.emitted()).toHaveProperty('update')
    expect(wrapper.emitted('update')[0]).toEqual([1])
  })
})
```

### Composable Testing

```javascript
// useCounter.test.js
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { count } = useCounter()
    expect(count.value).toBe(0)
  })

  it('initializes with custom value', () => {
    const { count } = useCounter(10)
    expect(count.value).toBe(10)
  })

  it('increments count', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })

  it('computes doubled value', () => {
    const { count, doubled, increment } = useCounter()
    expect(doubled.value).toBe(0)
    increment()
    expect(doubled.value).toBe(2)
  })
})
```

## Best Practices

### 1. Use Composition API for Complex Logic

Composition API provides better code organization and reusability.

```vue
<script setup>
// Good: Organized by feature
import { useUser } from '@/composables/useUser'
import { useProducts } from '@/composables/useProducts'
import { useCart } from '@/composables/useCart'

const { user, login, logout } = useUser()
const { products, fetchProducts } = useProducts()
const { cart, addToCart, removeFromCart } = useCart()
</script>
```

### 2. Keep Components Small and Focused

Break large components into smaller, reusable pieces.

```vue
<!-- Good: Focused components -->
<template>
  <div>
    <UserHeader :user="user" />
    <UserProfile :user="user" />
    <UserPosts :posts="posts" />
  </div>
</template>

<!-- Bad: One large component -->
<template>
  <div>
    <!-- 500 lines of mixed concerns -->
  </div>
</template>
```

### 3. Use Computed for Derived State

Don't compute values in templates or methods.

```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([...])

// Good: Computed property
const activeItems = computed(() =>
  items.value.filter(item => item.active)
)

// Bad: Method called in template
function getActiveItems() {
  return items.value.filter(item => item.active)
}
</script>

<template>
  <!-- Good -->
  <div v-for="item in activeItems" :key="item.id">

  <!-- Bad: Computed on every render -->
  <div v-for="item in getActiveItems()" :key="item.id">
</template>
```

### 4. Always Use Keys in v-for

Keys help Vue identify which items have changed.

```vue
<!-- Good -->
<div v-for="item in items" :key="item.id">

<!-- Bad: No key -->
<div v-for="item in items">

<!-- Bad: Using index as key (for dynamic lists) -->
<div v-for="(item, index) in items" :key="index">
```

### 5. Avoid v-if with v-for

Use computed properties to filter lists instead.

```vue
<script setup>
import { computed } from 'vue'

// Good: Filter with computed
const activeItems = computed(() =>
  items.value.filter(item => item.active)
)
</script>

<template>
  <!-- Good -->
  <div v-for="item in activeItems" :key="item.id">

  <!-- Bad: v-if with v-for -->
  <div v-for="item in items" :key="item.id" v-if="item.active">
</template>
```

### 6. Prop Validation

Always validate props in production components.

```vue
<script setup>
// Good: Validated props
defineProps({
  title: {
    type: String,
    required: true
  },
  count: {
    type: Number,
    default: 0,
    validator: (value) => value >= 0
  },
  status: {
    type: String,
    validator: (value) => ['draft', 'published', 'archived'].includes(value)
  }
})
</script>
```

### 7. Use Provide/Inject Sparingly

Provide/Inject is for deep component trees, not a replacement for props.

```vue
<!-- Good: Use for app-level state -->
<script setup>
provide('theme', theme)
provide('i18n', i18n)
</script>

<!-- Bad: Use for direct parent-child communication -->
<!-- Use props instead -->
```

### 8. Cleanup in onUnmounted

Always cleanup side effects to prevent memory leaks.

```vue
<script setup>
import { onMounted, onUnmounted } from 'vue'

let interval

onMounted(() => {
  interval = setInterval(() => {
    // Do something
  }, 1000)
})

onUnmounted(() => {
  clearInterval(interval)
})
</script>
```

### 9. Use Scoped Styles

Prevent style leaking with scoped styles.

```vue
<style scoped>
/* Styles only apply to this component */
.button {
  background: blue;
}
</style>

<!-- Deep selector for child components -->
<style scoped>
.parent :deep(.child) {
  color: red;
}
</style>
```

### 10. Lazy Load Routes

Improve initial load time with route-based code splitting.

```javascript
const routes = [
  {
    path: '/',
    component: () => import('@/views/Home.vue')
  },
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue')
  }
]
```

## Summary

This Vue.js development skill covers:

1. **Reactivity System**: ref(), reactive(), computed(), watch()
2. **Composition API**: <script setup>, composables, lifecycle hooks
3. **Single-File Components**: Template, script, and style organization
4. **Directives**: v-if, v-for, v-model, v-bind, v-on
5. **Component Communication**: Props, emits, provide/inject, slots
6. **State Management**: Local state, composables, Pinia
7. **Routing**: Vue Router navigation and guards
8. **Advanced Features**: Teleport, Suspense, Transitions, Custom Directives
9. **Performance**: Computed vs methods, v-memo, lazy loading, virtual scrolling
10. **TypeScript**: Type-safe props, emits, composables
11. **Testing**: Component and composable testing
12. **Best Practices**: Modern Vue 3 patterns and optimization techniques

The patterns and examples are based on official Vue.js documentation (Trust Score: 9.7) and represent modern Vue 3 development practices with Composition API and <script setup> syntax.
