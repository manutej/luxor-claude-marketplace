# Figma Design Skill

Production-ready Figma plugin development, component systems, auto layout, and design system management based on official Figma Plugin API documentation.

## Overview

This skill provides comprehensive knowledge for working with Figma, covering:
- Plugin development with the Figma Plugin API
- Component architecture and design systems
- Auto layout and responsive design
- Variables and design tokens
- Prototyping and interactions
- Batch operations and automation
- Export workflows and image handling

## Quick Start

### Creating Your First Plugin

**1. Set up plugin files:**

```
my-plugin/
├── manifest.json
├── code.ts
└── ui.html (optional)
```

**2. manifest.json:**
```json
{
  "name": "My First Plugin",
  "id": "my-unique-id",
  "api": "1.0.0",
  "main": "code.js",
  "ui": "ui.html",
  "editorType": ["figma"]
}
```

**3. code.ts:**
```typescript
// Show UI
figma.showUI(__html__, { width: 400, height: 300 })

// Handle messages from UI
figma.ui.onmessage = async (msg) => {
  if (msg.type === 'create-rectangle') {
    const rect = figma.createRectangle()
    rect.resize(100, 100)
    rect.fills = [{
      type: 'SOLID',
      color: { r: 0.2, g: 0.5, b: 1 }
    }]

    figma.currentPage.selection = [rect]
    figma.viewport.scrollAndZoomIntoView([rect])
  }

  if (msg.type === 'close') {
    figma.closePlugin()
  }
}
```

**4. ui.html:**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      margin: 16px;
      font-family: 'Inter', sans-serif;
      background: var(--figma-color-bg);
      color: var(--figma-color-text);
    }
    button {
      background: var(--figma-color-bg-brand);
      color: var(--figma-color-text-onbrand);
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <button onclick="create()">Create Rectangle</button>
  <button onclick="close()">Close</button>

  <script>
    function create() {
      parent.postMessage({
        pluginMessage: { type: 'create-rectangle' }
      }, '*')
    }

    function close() {
      parent.postMessage({
        pluginMessage: { type: 'close' }
      }, '*')
    }
  </script>
</body>
</html>
```

**5. Build and test:**
```bash
# Install dependencies
npm install @figma/plugin-typings --save-dev

# Compile TypeScript
tsc code.ts

# In Figma: Plugins > Development > Import plugin from manifest
```

## Core Workflows

### 1. Creating Components

```typescript
// Create a button component
const button = figma.createComponent()
button.name = "Primary Button"
button.resize(120, 40)

// Add background
const bg = figma.createRectangle()
bg.resize(120, 40)
bg.cornerRadius = 8
bg.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.5, b: 1 } }]
button.appendChild(bg)

// Add text
const text = figma.createText()
await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
text.characters = 'Button'
text.fontSize = 14
text.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
text.x = (120 - text.width) / 2
text.y = (40 - text.height) / 2
button.appendChild(text)

// Create instance
const instance = button.createInstance()
instance.x = 200
instance.y = 100
```

### 2. Auto Layout

```typescript
// Create vertical auto-layout frame
const frame = figma.createFrame()
frame.name = "Card"
frame.layoutMode = 'VERTICAL'
frame.primaryAxisSizingMode = 'AUTO'
frame.counterAxisSizingMode = 'FIXED'
frame.resize(300, 0)
frame.itemSpacing = 16
frame.paddingLeft = 24
frame.paddingRight = 24
frame.paddingTop = 24
frame.paddingBottom = 24
frame.cornerRadius = 12
frame.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]

// Add header
const header = figma.createText()
await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
header.characters = 'Card Title'
header.fontSize = 20
frame.appendChild(header)

// Add body
const body = figma.createText()
await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
body.characters = 'Card description goes here...'
body.fontSize = 14
frame.appendChild(body)

// Make body stretch
if ('layoutAlign' in body) {
  body.layoutAlign = 'STRETCH'
}
```

### 3. Design System with Variables

```typescript
async function createDesignSystem() {
  // Create collection
  const tokens = figma.variables.createVariableCollection('Design Tokens')
  const defaultMode = tokens.modes[0]

  // Create color variables
  const colors = {
    'primary': { r: 0.2, g: 0.5, b: 1, a: 1 },
    'secondary': { r: 0.5, g: 0.2, b: 0.8, a: 1 },
    'background': { r: 1, g: 1, b: 1, a: 1 },
    'text': { r: 0, g: 0, b: 0, a: 1 }
  }

  const colorVars = {}
  for (const [name, value] of Object.entries(colors)) {
    const variable = figma.variables.createVariable(
      `color/${name}`,
      tokens,
      'COLOR'
    )
    variable.setValueForMode(defaultMode.modeId, value)
    colorVars[name] = variable
  }

  // Create spacing variables
  const spacings = [4, 8, 12, 16, 24, 32, 48, 64]
  const spacingVars = []

  for (let i = 0; i < spacings.length; i++) {
    const variable = figma.variables.createVariable(
      `spacing/${i}`,
      tokens,
      'FLOAT'
    )
    variable.setValueForMode(defaultMode.modeId, spacings[i])
    spacingVars.push(variable)
  }

  // Add dark mode
  const darkMode = tokens.addMode('Dark')
  colorVars['primary'].setValueForMode(darkMode, {
    r: 0.4, g: 0.7, b: 1, a: 1
  })
  colorVars['background'].setValueForMode(darkMode, {
    r: 0.1, g: 0.1, b: 0.1, a: 1
  })
  colorVars['text'].setValueForMode(darkMode, {
    r: 1, g: 1, b: 1, a: 1
  })

  figma.notify('Design system created!')
}
```

### 4. Finding and Modifying Nodes

```typescript
// Find all text nodes (FAST)
const textNodes = figma.currentPage.findAllWithCriteria({
  types: ['TEXT']
})

// Update font size for all
for (const node of textNodes) {
  await figma.loadFontAsync(node.fontName)
  node.fontSize = 16
}

// Find nodes with specific plugin data
const approved = figma.currentPage.findAllWithCriteria({
  pluginData: {
    keys: ['status']
  }
}).filter(node => node.getPluginData('status') === 'approved')

// Find frames and components
const containers = figma.currentPage.findAllWithCriteria({
  types: ['FRAME', 'COMPONENT']
})
```

### 5. Export Assets

```typescript
async function exportAssets() {
  const selection = figma.currentPage.selection

  for (const node of selection) {
    // Export 1x PNG
    const png1x = await node.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 1 }
    })

    // Export 2x PNG
    const png2x = await node.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 2 }
    })

    // Export SVG
    const svg = await node.exportAsync({
      format: 'SVG',
      svgIdAttribute: true,
      svgOutlineText: false
    })

    // Send to UI for download
    figma.ui.postMessage({
      type: 'export-ready',
      name: node.name,
      formats: {
        'png1x': Array.from(png1x),
        'png2x': Array.from(png2x),
        'svg': Array.from(svg)
      }
    })
  }
}
```

## Plugin Architecture Patterns

### Event-Driven Architecture

```typescript
class PluginController {
  private listeners: Map<string, Function[]> = new Map()

  constructor() {
    this.setupFigmaListeners()
    this.setupUIListeners()
  }

  setupFigmaListeners() {
    figma.on('selectionchange', () => {
      this.emit('selection-changed', figma.currentPage.selection)
    })

    figma.on('documentchange', (event) => {
      this.emit('document-changed', event.documentChanges)
    })
  }

  setupUIListeners() {
    figma.ui.onmessage = (msg) => {
      this.emit(msg.type, msg.data)
    }
  }

  on(event: string, handler: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, [])
    }
    this.listeners.get(event)!.push(handler)
  }

  emit(event: string, data: any) {
    const handlers = this.listeners.get(event) || []
    handlers.forEach(handler => handler(data))
  }
}

// Usage
const controller = new PluginController()

controller.on('selection-changed', (nodes) => {
  console.log(`Selected ${nodes.length} nodes`)
  figma.ui.postMessage({
    type: 'selection-update',
    count: nodes.length
  })
})

controller.on('create-shapes', async (data) => {
  // Handle shape creation
})
```

### State Management

```typescript
interface PluginState {
  preferences: {
    theme: 'light' | 'dark'
    lastColor: RGB
    history: string[]
  }
  currentOperation: string | null
  isProcessing: boolean
}

class StateManager {
  private state: PluginState
  private listeners: Set<(state: PluginState) => void> = new Set()

  constructor() {
    this.state = {
      preferences: {
        theme: 'light',
        lastColor: { r: 0.2, g: 0.5, b: 1 },
        history: []
      },
      currentOperation: null,
      isProcessing: false
    }
  }

  async load() {
    const saved = await figma.clientStorage.getAsync('state')
    if (saved) {
      this.state = { ...this.state, ...saved }
    }
  }

  async save() {
    await figma.clientStorage.setAsync('state', this.state.preferences)
  }

  getState(): PluginState {
    return { ...this.state }
  }

  setState(partial: Partial<PluginState>) {
    this.state = { ...this.state, ...partial }
    this.notifyListeners()
    this.save()
  }

  subscribe(listener: (state: PluginState) => void) {
    this.listeners.add(listener)
    return () => this.listeners.delete(listener)
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this.state))
  }
}

// Usage
const stateManager = new StateManager()
await stateManager.load()

stateManager.subscribe((state) => {
  figma.ui.postMessage({
    type: 'state-update',
    state
  })
})
```

### Command Pattern

```typescript
interface Command {
  execute(): Promise<void>
  undo(): Promise<void>
}

class CreateRectangleCommand implements Command {
  private rectangle: RectangleNode | null = null

  constructor(
    private x: number,
    private y: number,
    private width: number,
    private height: number
  ) {}

  async execute() {
    this.rectangle = figma.createRectangle()
    this.rectangle.x = this.x
    this.rectangle.y = this.y
    this.rectangle.resize(this.width, this.height)
  }

  async undo() {
    if (this.rectangle) {
      this.rectangle.remove()
    }
  }
}

class CommandManager {
  private history: Command[] = []
  private currentIndex = -1

  async execute(command: Command) {
    // Remove any commands after current index
    this.history = this.history.slice(0, this.currentIndex + 1)

    await command.execute()
    this.history.push(command)
    this.currentIndex++
  }

  async undo() {
    if (this.currentIndex >= 0) {
      await this.history[this.currentIndex].undo()
      this.currentIndex--
    }
  }

  async redo() {
    if (this.currentIndex < this.history.length - 1) {
      this.currentIndex++
      await this.history[this.currentIndex].execute()
    }
  }
}
```

## Performance Best Practices

### 1. Use Optimized Search

```typescript
// ✅ FAST: Use findAllWithCriteria
const textNodes = figma.currentPage.findAllWithCriteria({
  types: ['TEXT']
})

// ❌ SLOW: Use findAll with callback
const textNodes = figma.currentPage.findAll(n => n.type === 'TEXT')
```

### 2. Enable Performance Flags

```typescript
// Skip invisible instance children for better performance
figma.skipInvisibleInstanceChildren = true
```

### 3. Batch Operations

```typescript
// ✅ Create all nodes, then update viewport once
const nodes = []
for (let i = 0; i < 100; i++) {
  const rect = figma.createRectangle()
  rect.x = i * 120
  nodes.push(rect)
}
figma.viewport.scrollAndZoomIntoView(nodes)

// ❌ Update viewport for each node
for (let i = 0; i < 100; i++) {
  const rect = figma.createRectangle()
  figma.viewport.scrollAndZoomIntoView([rect]) // Slow!
}
```

### 4. Async Iteration

```typescript
async function processLargeDataset(nodes: SceneNode[]) {
  for (let i = 0; i < nodes.length; i++) {
    await processNode(nodes[i])

    // Yield to UI every 100 items
    if (i % 100 === 0) {
      await new Promise(resolve => setTimeout(resolve, 0))
      figma.ui.postMessage({
        type: 'progress',
        current: i,
        total: nodes.length
      })
    }
  }
}
```

## Common Patterns

### Loading Indicator

```typescript
// code.ts
async function longOperation() {
  figma.ui.postMessage({ type: 'loading', show: true })

  try {
    // Perform operation
    await processNodes()

    figma.ui.postMessage({ type: 'loading', show: false })
    figma.notify('Operation complete!')
  } catch (error) {
    figma.ui.postMessage({ type: 'loading', show: false })
    figma.notify('Error: ' + error.message, { error: true })
  }
}
```

```html
<!-- ui.html -->
<div id="loading" style="display: none;">
  <div class="spinner"></div>
  <p>Processing...</p>
</div>

<script>
  window.onmessage = (event) => {
    const msg = event.data.pluginMessage

    if (msg.type === 'loading') {
      document.getElementById('loading').style.display =
        msg.show ? 'block' : 'none'
    }
  }
</script>
```

### Error Boundaries

```typescript
class PluginError extends Error {
  constructor(
    message: string,
    public userMessage: string
  ) {
    super(message)
  }
}

async function safeExecute<T>(
  operation: () => Promise<T>,
  errorMessage: string = 'Operation failed'
): Promise<T | null> {
  try {
    return await operation()
  } catch (error) {
    console.error(error)

    if (error instanceof PluginError) {
      figma.notify(error.userMessage, { error: true })
    } else {
      figma.notify(errorMessage, { error: true })
    }

    return null
  }
}

// Usage
await safeExecute(
  async () => {
    const node = await figma.getNodeByIdAsync(id)
    if (!node) {
      throw new PluginError(
        'Node not found',
        'The selected node no longer exists'
      )
    }
    return node
  },
  'Failed to find node'
)
```

### Validation

```typescript
function validateSelection(): boolean {
  const selection = figma.currentPage.selection

  if (selection.length === 0) {
    figma.notify('Please select at least one node', { error: true })
    return false
  }

  const hasInvalidTypes = selection.some(
    node => !['FRAME', 'COMPONENT'].includes(node.type)
  )

  if (hasInvalidTypes) {
    figma.notify('Please select only frames or components', { error: true })
    return false
  }

  return true
}

// Usage
if (!validateSelection()) {
  return
}

// Proceed with operation
```

## TypeScript Configuration

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "typeRoots": [
      "./node_modules/@types",
      "./node_modules/@figma"
    ]
  },
  "include": ["*.ts"],
  "exclude": ["node_modules"]
}
```

**package.json:**
```json
{
  "name": "my-figma-plugin",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch"
  },
  "devDependencies": {
    "@figma/plugin-typings": "^1.89.0",
    "typescript": "^5.0.0"
  }
}
```

## Testing Strategies

### Unit Testing Node Operations

```typescript
// test-helpers.ts
export function createMockRectangle(
  props: Partial<RectangleNode> = {}
): RectangleNode {
  const rect = figma.createRectangle()
  Object.assign(rect, props)
  return rect
}

export function assertNodeProperties(
  node: SceneNode,
  expected: Record<string, any>
) {
  for (const [key, value] of Object.entries(expected)) {
    if (node[key] !== value) {
      throw new Error(
        `Expected ${key} to be ${value}, got ${node[key]}`
      )
    }
  }
}

// Usage in plugin
try {
  const rect = createMockRectangle({ x: 100, y: 100 })
  assertNodeProperties(rect, { x: 100, y: 100 })
  console.log('✓ Test passed')
} catch (error) {
  console.error('✗ Test failed:', error.message)
}
```

### Integration Testing

```typescript
async function testWorkflow() {
  console.log('Starting integration test...')

  // Test 1: Create component
  const component = figma.createComponent()
  component.name = 'Test Button'
  console.assert(component.type === 'COMPONENT', 'Component created')

  // Test 2: Create instance
  const instance = component.createInstance()
  console.assert(
    instance.mainComponent?.id === component.id,
    'Instance linked to component'
  )

  // Test 3: Export
  const bytes = await component.exportAsync({ format: 'PNG' })
  console.assert(bytes.length > 0, 'Export successful')

  // Cleanup
  component.remove()
  instance.remove()

  console.log('✓ All tests passed')
}
```

## Debugging Tips

### 1. Console Logging

```typescript
// Log node hierarchy
function logNodeTree(node: BaseNode, indent = 0) {
  console.log('  '.repeat(indent) + `${node.type}: ${node.name}`)

  if ('children' in node) {
    node.children.forEach(child => logNodeTree(child, indent + 1))
  }
}

// Log selection details
figma.on('selectionchange', () => {
  console.group('Selection Changed')
  figma.currentPage.selection.forEach(node => {
    console.log({
      type: node.type,
      name: node.name,
      id: node.id,
      position: { x: node.x, y: node.y },
      size: 'width' in node ? { width: node.width, height: node.height } : null
    })
  })
  console.groupEnd()
})
```

### 2. Performance Profiling

```typescript
async function profileOperation<T>(
  name: string,
  operation: () => Promise<T>
): Promise<T> {
  const start = performance.now()
  const result = await operation()
  const duration = performance.now() - start

  console.log(`${name} took ${duration.toFixed(2)}ms`)
  return result
}

// Usage
await profileOperation('Find all text nodes', async () => {
  return figma.currentPage.findAllWithCriteria({ types: ['TEXT'] })
})
```

### 3. Error Tracking

```typescript
const errors: Array<{ timestamp: Date; message: string; stack?: string }> = []

function trackError(error: Error) {
  errors.push({
    timestamp: new Date(),
    message: error.message,
    stack: error.stack
  })

  // Send to UI for display
  figma.ui.postMessage({
    type: 'error-logged',
    error: {
      message: error.message,
      timestamp: new Date().toISOString()
    }
  })
}

// Global error handler
process.on('unhandledRejection', (error: Error) => {
  trackError(error)
  figma.notify('An unexpected error occurred', { error: true })
})
```

## Resources

- **Official Documentation**: https://www.figma.com/plugin-docs/
- **Context7 Library**: /figma/plugin-typings (Trust Score: 9.8)
- **Plugin Samples**: https://github.com/figma/plugin-samples
- **TypeScript Typings**: https://github.com/figma/plugin-typings
- **Community Forum**: https://forum.figma.com/
- **Widget API**: https://www.figma.com/widget-docs/
- **REST API**: https://www.figma.com/developers/api

## Next Steps

1. Review `SKILL.md` for comprehensive API reference
2. Check `EXAMPLES.md` for 18+ practical examples
3. Build your first plugin following the Quick Start
4. Join the Figma community forum for support
5. Explore official plugin samples on GitHub

## Support

For issues and questions:
- Figma Plugin Forum: https://forum.figma.com/c/plugin-api/
- GitHub Issues: https://github.com/figma/plugin-samples/issues
- Official Documentation: https://www.figma.com/plugin-docs/
