---
name: figma-design
description: Figma workflows, components, auto layout, constraints, prototyping, design systems, and plugin development based on Figma Plugin API documentation
category: design
tags: [figma, design-systems, prototyping, components, auto-layout, plugins]
version: 1.0.0
context7_library: /figma/plugin-typings
context7_trust_score: 9.8
---

# Figma Design Skill

Comprehensive guide for Figma design workflows, plugin development, component systems, auto layout, prototyping, and design system management based on official Figma Plugin API documentation from Context7.

## When to Use This Skill

Use this skill when working with:
- **Figma Plugin Development**: Building custom plugins, UI extensions, automation tools
- **Design Systems**: Creating and managing variables, styles, components, and libraries
- **Component Architecture**: Building reusable components, variants, and instances
- **Auto Layout**: Implementing responsive frames with constraints and spacing
- **Prototyping**: Creating interactive prototypes with reactions and flows
- **Batch Operations**: Automating repetitive design tasks across multiple nodes
- **Export & Integration**: Exporting assets in various formats (PNG, JPG, SVG)
- **Data Management**: Storing and retrieving plugin/shared data on nodes
- **Collaboration**: Managing version history, comments, and team workflows

## Core Concepts

### 1. Figma Node Hierarchy

The Figma document structure is a tree of nodes:

```
DocumentNode (root)
└── PageNode
    ├── FrameNode
    │   ├── TextNode
    │   ├── RectangleNode
    │   └── ComponentNode
    └── SectionNode
        └── FrameNode
```

**Key Node Types:**
- `FRAME`: Container with auto-layout capabilities
- `COMPONENT`: Reusable design element (master)
- `INSTANCE`: Copy of a component
- `TEXT`: Editable text layer
- `RECTANGLE`, `ELLIPSE`, `POLYGON`, `STAR`, `LINE`: Basic shapes
- `SECTION`: Organizational container for frames
- `GROUP`: Non-layout container

### 2. Components and Instances

**Components** are master elements that can be instantiated multiple times:

```typescript
// Create a component
const button = figma.createComponent()
button.name = "Primary Button"
button.resize(120, 40)

// Add visual elements
const bg = figma.createRectangle()
bg.resize(120, 40)
bg.cornerRadius = 8
bg.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.5, b: 1 } }]
button.appendChild(bg)

// Create instance
const buttonInstance = button.createInstance()
buttonInstance.x = 200
buttonInstance.y = 100
```

**Component Properties:**
- `BOOLEAN`: Toggle visibility or states
- `TEXT`: Customizable text content
- `INSTANCE_SWAP`: Swap nested components
- `VARIANT`: Different component variations

### 3. Auto Layout

Auto Layout creates responsive frames that adapt to content changes:

**Core Properties:**
- `layoutMode`: 'HORIZONTAL', 'VERTICAL', or 'NONE'
- `primaryAxisSizingMode`: 'FIXED' or 'AUTO'
- `counterAxisSizingMode`: 'FIXED' or 'AUTO'
- `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom`
- `itemSpacing`: Gap between children
- `primaryAxisAlignItems`: Alignment on main axis
- `counterAxisAlignItems`: Alignment on cross axis

**Constraints for Children:**
- `minWidth`, `maxWidth`: Width boundaries
- `minHeight`, `maxHeight`: Height boundaries
- `layoutAlign`: 'MIN', 'CENTER', 'MAX', 'STRETCH'
- `layoutGrow`: 0 (fixed) or 1 (fill container)

```typescript
// Create auto-layout frame
const frame = figma.createFrame()
frame.layoutMode = 'VERTICAL'
frame.primaryAxisSizingMode = 'AUTO'
frame.counterAxisSizingMode = 'FIXED'
frame.resize(300, 0) // Width fixed, height auto
frame.itemSpacing = 16
frame.paddingLeft = 24
frame.paddingRight = 24
frame.paddingTop = 24
frame.paddingBottom = 24

// Add children with constraints
const child = figma.createRectangle()
child.resize(252, 100)
child.layoutAlign = 'STRETCH' // Fill width
child.minHeight = 100
child.maxHeight = 200
frame.appendChild(child)
```

### 4. Constraints

Constraints control how nodes resize when their parent changes:

```typescript
interface Constraints {
  horizontal: 'MIN' | 'CENTER' | 'MAX' | 'STRETCH' | 'SCALE'
  vertical: 'MIN' | 'CENTER' | 'MAX' | 'STRETCH' | 'SCALE'
}

node.constraints = {
  horizontal: 'MIN',    // Pin to left
  vertical: 'MAX'       // Pin to bottom
}
```

**Constraint Types:**
- `MIN`: Pin to top/left edge
- `CENTER`: Center in parent
- `MAX`: Pin to bottom/right edge
- `STRETCH`: Scale with parent (both edges)
- `SCALE`: Maintain proportional position and size

### 5. Variables and Design Tokens

Variables create dynamic design systems (Figma Design only):

```typescript
// Create variable collection
const collection = figma.variables.createVariableCollection('Design Tokens')

// Create color variable
const primaryColor = figma.variables.createVariable(
  'color/primary',
  collection,
  'COLOR'
)

// Set value for default mode
const defaultMode = collection.modes[0]
primaryColor.setValueForMode(defaultMode.modeId, {
  r: 0.2, g: 0.5, b: 1, a: 1
})

// Add dark mode
const darkMode = collection.addMode('Dark')
primaryColor.setValueForMode(darkMode, {
  r: 0.4, g: 0.7, b: 1, a: 1
})

// Create variable alias (reference)
const accentColor = figma.variables.createVariable(
  'color/accent',
  collection,
  'COLOR'
)
const alias = figma.variables.createVariableAlias(primaryColor)
accentColor.setValueForMode(defaultMode.modeId, alias)

// Bind variable to node
const rect = figma.createRectangle()
const fill = { type: 'SOLID', color: { r: 0, g: 0, b: 0 } } as SolidPaint
const boundFill = figma.variables.setBoundVariableForPaint(
  fill,
  'color',
  primaryColor
)
rect.fills = [boundFill]
```

**Variable Types:**
- `COLOR`: RGB/RGBA values
- `FLOAT`: Numeric values (spacing, sizes)
- `BOOLEAN`: True/false flags
- `STRING`: Text values

### 6. Styles

Styles define reusable visual properties:

```typescript
// Paint style (fills/strokes)
const paintStyle = figma.createPaintStyle()
paintStyle.name = 'Brand/Primary'
paintStyle.paints = [{
  type: 'SOLID',
  color: { r: 0.2, g: 0.5, b: 1 }
}]

// Text style
const textStyle = figma.createTextStyle()
textStyle.name = 'Heading/H1'
textStyle.fontSize = 32
textStyle.fontName = { family: 'Inter', style: 'Bold' }
textStyle.lineHeight = { value: 120, unit: 'PERCENT' }
textStyle.letterSpacing = { value: -0.5, unit: 'PIXELS' }

// Effect style (shadows, blurs)
const effectStyle = figma.createEffectStyle()
effectStyle.name = 'Shadow/Card'
effectStyle.effects = [{
  type: 'DROP_SHADOW',
  color: { r: 0, g: 0, b: 0, a: 0.15 },
  offset: { x: 0, y: 4 },
  radius: 8,
  visible: true,
  blendMode: 'NORMAL'
}]

// Apply styles
rect.fillStyleId = paintStyle.id
text.textStyleId = textStyle.id
frame.effectStyleId = effectStyle.id
```

## Prototyping

### 1. Reactions and Interactions

Reactions define interactive behavior in prototypes:

```typescript
// Set reactions on a node
await node.setReactionsAsync([
  {
    action: {
      type: 'NODE',
      destinationId: 'nodeId', // Target frame
      navigation: 'NAVIGATE',
      transition: {
        type: 'SMART_ANIMATE',
        easing: { type: 'EASE_IN_AND_OUT' },
        duration: 0.3
      },
      preserveScrollPosition: false
    },
    trigger: {
      type: 'ON_CLICK'
    }
  }
])
```

**Trigger Types:**
- `ON_CLICK`: Click/tap
- `ON_HOVER`: Mouse hover
- `ON_PRESS`: Touch press
- `ON_DRAG`: Drag interaction
- `MOUSE_ENTER`, `MOUSE_LEAVE`, `MOUSE_UP`, `MOUSE_DOWN`
- `AFTER_TIMEOUT`: Delayed trigger

**Navigation Types:**
- `NAVIGATE`: Go to destination
- `SWAP`: Swap overlay
- `OVERLAY`: Open as overlay
- `SCROLL_TO`: Scroll to position
- `CHANGE_TO`: Change to state

### 2. Overlay Configuration

Control how frames appear as overlays:

```typescript
frame.overlayPositionType // 'CENTER' | 'TOP_LEFT' | 'TOP_CENTER' | etc.
frame.overlayBackground // How overlay obscures background
frame.overlayBackgroundInteraction // Click-through behavior
```

### 3. Scrolling Frames

Configure frame scrolling behavior:

```typescript
frame.overflowDirection = 'VERTICAL_SCROLLING' // or 'HORIZONTAL_SCROLLING'
frame.numberOfFixedChildren = 1 // First N children stay fixed during scroll
```

## Plugin Development

### 1. Plugin Structure

**Basic Plugin Files:**
```
my-plugin/
├── manifest.json       # Plugin configuration
├── code.ts            # Main plugin logic
└── ui.html            # Optional UI
```

**manifest.json:**
```json
{
  "name": "My Plugin",
  "id": "unique-plugin-id",
  "api": "1.0.0",
  "main": "code.js",
  "ui": "ui.html",
  "editorType": ["figma", "figjam"],
  "documentAccess": "dynamic-page",
  "networkAccess": {
    "allowedDomains": ["api.example.com"]
  }
}
```

### 2. Plugin Lifecycle

```typescript
// Initialize plugin
async function init() {
  // Show UI (optional)
  figma.showUI(__html__, {
    width: 400,
    height: 500,
    title: "My Plugin",
    themeColors: true
  })

  // Load saved preferences
  const prefs = await figma.clientStorage.getAsync('preferences')

  // Send initial data to UI
  figma.ui.postMessage({
    type: 'init',
    data: prefs
  })
}

// Handle UI messages
figma.ui.onmessage = async (msg) => {
  if (msg.type === 'create-shapes') {
    await createShapes(msg.count, msg.color)
  }

  if (msg.type === 'export') {
    await exportSelection()
  }
}

// Clean up on close
figma.on('close', () => {
  console.log('Plugin closing...')
})

// Start plugin
init()
```

### 3. UI Communication

**Send message from plugin to UI:**
```typescript
figma.ui.postMessage({
  type: 'selection-changed',
  count: figma.currentPage.selection.length,
  nodes: figma.currentPage.selection.map(n => ({
    id: n.id,
    name: n.name,
    type: n.type
  }))
})
```

**Receive messages in UI (ui.html):**
```html
<script>
  window.onmessage = (event) => {
    const msg = event.data.pluginMessage

    if (msg.type === 'selection-changed') {
      document.getElementById('count').textContent = msg.count
    }
  }

  // Send message to plugin
  function createShapes() {
    parent.postMessage({
      pluginMessage: {
        type: 'create-shapes',
        count: 5,
        color: { r: 1, g: 0, b: 0 }
      }
    }, '*')
  }
</script>
```

### 4. Event Listeners

Monitor document and selection changes:

```typescript
// Selection changes
figma.on('selectionchange', () => {
  const selection = figma.currentPage.selection
  console.log(`Selected ${selection.length} nodes`)
})

// Document changes
figma.on('documentchange', (event) => {
  for (const change of event.documentChanges) {
    if (change.type === 'CREATE') {
      console.log(`Created: ${change.id}`)
    }

    if (change.type === 'DELETE') {
      console.log(`Deleted: ${change.id}`)
    }

    if (change.type === 'PROPERTY_CHANGE') {
      console.log(`Changed properties: ${change.properties.join(', ')}`)
    }
  }
})

// Page changes
figma.on('currentpagechange', () => {
  console.log(`Now on page: ${figma.currentPage.name}`)
})
```

### 5. Data Storage

**Plugin Data (private to your plugin):**
```typescript
// Store data on node
node.setPluginData('status', 'approved')
node.setPluginData('metadata', JSON.stringify({
  author: 'John',
  tags: ['important']
}))

// Retrieve data
const status = node.getPluginData('status')
const metadata = JSON.parse(node.getPluginData('metadata') || '{}')

// List all keys
const keys = node.getPluginDataKeys()
```

**Shared Plugin Data (accessible by namespace):**
```typescript
// Store shared data
node.setSharedPluginData('com.example.plugin', 'version', '2.0')

// Retrieve shared data
const version = node.getSharedPluginData('com.example.plugin', 'version')

// List shared keys
const keys = node.getSharedPluginDataKeys('com.example.plugin')
```

**Client Storage (persistent settings):**
```typescript
// Save preferences
await figma.clientStorage.setAsync('preferences', {
  theme: 'dark',
  lastUsed: new Date().toISOString()
})

// Load preferences
const prefs = await figma.clientStorage.getAsync('preferences')

// Delete data
await figma.clientStorage.deleteAsync('preferences')

// List all keys
const keys = await figma.clientStorage.keysAsync()
```

## Finding Nodes

### 1. Optimized Search with findAllWithCriteria

**FASTEST method for large documents** (hundreds of times faster):

```typescript
// Enable performance optimization
figma.skipInvisibleInstanceChildren = true

// Find by type
const textNodes = figma.currentPage.findAllWithCriteria({
  types: ['TEXT']
})

// Find multiple types
const shapes = figma.currentPage.findAllWithCriteria({
  types: ['RECTANGLE', 'ELLIPSE', 'POLYGON']
})

// Find nodes with plugin data
const nodesWithStatus = figma.currentPage.findAllWithCriteria({
  pluginData: {
    keys: ['status']
  }
})

// Find nodes with shared plugin data
const nodesWithSharedData = figma.currentPage.findAllWithCriteria({
  sharedPluginData: {
    namespace: 'com.example.plugin',
    keys: ['version']
  }
})

// Combine criteria
const textWithData = figma.currentPage.findAllWithCriteria({
  types: ['TEXT'],
  pluginData: {} // Any plugin data
})
```

### 2. Traditional Search Methods

```typescript
// Find all matching nodes
const frames = figma.currentPage.findAll(node => node.type === 'FRAME')

// Find first match
const template = figma.currentPage.findOne(node =>
  node.name.startsWith('Template')
)

// Find by ID
const node = await figma.getNodeByIdAsync('123:456')

// Recursive tree traversal
function walkTree(node: BaseNode) {
  console.log(`${node.type}: ${node.name}`)

  if ('children' in node) {
    for (const child of node.children) {
      walkTree(child)
    }
  }
}

walkTree(figma.currentPage)
```

## Export and Image Handling

### 1. Export Nodes

```typescript
// Export as PNG
const pngBytes = await node.exportAsync({
  format: 'PNG',
  constraint: { type: 'SCALE', value: 2 } // 2x resolution
})

// Export as JPG
const jpgBytes = await node.exportAsync({
  format: 'JPG',
  constraint: { type: 'SCALE', value: 1 },
  contentsOnly: false // Include background
})

// Export as SVG
const svgBytes = await node.exportAsync({
  format: 'SVG',
  svgIdAttribute: true,
  svgOutlineText: false,
  svgSimplifyStroke: true
})

// Export with fixed dimensions
const thumbnail = await node.exportAsync({
  format: 'PNG',
  constraint: { type: 'WIDTH', value: 200 }
})

// Export with height constraint
const preview = await node.exportAsync({
  format: 'PNG',
  constraint: { type: 'HEIGHT', value: 400 }
})
```

### 2. Load Images

```typescript
// Load from URL
const image = await figma.createImageAsync('https://example.com/image.png')
const { width, height } = await image.getSizeAsync()

// Create rectangle with image
const rect = figma.createRectangle()
rect.resize(width, height)
rect.fills = [{
  type: 'IMAGE',
  imageHash: image.hash,
  scaleMode: 'FILL' // or 'FIT', 'CROP', 'TILE'
}]

// Load from bytes
function loadFromBytes(bytes: Uint8Array) {
  const image = figma.createImage(bytes)
  return image
}

// Create from SVG string
const svgString = `
  <svg width="100" height="100">
    <circle cx="50" cy="50" r="40" fill="#3366ff"/>
  </svg>
`
const node = figma.createNodeFromSvg(svgString)
```

## Text Handling

### 1. Text Basics

```typescript
// Create text (MUST load font first)
const text = figma.createText()
await figma.loadFontAsync(text.fontName) // Load default font

// Set content
text.characters = 'Hello World'

// Change font
await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
text.fontName = { family: 'Inter', style: 'Bold' }

// Styling
text.fontSize = 24
text.lineHeight = { value: 150, unit: 'PERCENT' }
text.letterSpacing = { value: 0, unit: 'PIXELS' }
text.textAlignHorizontal = 'CENTER'
text.textAlignVertical = 'CENTER'
text.textCase = 'UPPER' // or 'LOWER', 'TITLE', 'ORIGINAL'
text.textDecoration = 'UNDERLINE' // or 'STRIKETHROUGH', 'NONE'
```

### 2. Rich Text Formatting

```typescript
// Apply formatting to range
text.setRangeFontSize(0, 5, 32) // First 5 chars = 32px
text.setRangeFills(0, 5, [{
  type: 'SOLID',
  color: { r: 1, g: 0, b: 0 }
}])

// Get font at position
const fontName = text.getRangeFontName(0, 1)
const fontSize = text.getRangeFontSize(0, 1)
```

## Resizing and Transforms

### 1. Resizing Methods

```typescript
// Resize with constraints applied
node.resize(300, 200)

// Resize without constraints
node.resizeWithoutConstraints(300, 200)

// Scale proportionally
node.rescale(1.5) // 150% scale
```

### 2. Transforms

```typescript
// Position
node.x = 100
node.y = 200

// Relative to parent
console.log(node.relativeTransform) // [[1,0,x], [0,1,y]]

// Absolute position on page
console.log(node.absoluteTransform)

// Bounding box
const bounds = node.absoluteBoundingBox
// { x: number, y: number, width: number, height: number }
```

## Collaboration Features

### 1. Comments

While plugins can't create comments via API, they can:
- Navigate to frames with comments
- Read comment metadata via REST API
- Trigger notifications

### 2. Version History

```typescript
// Plugin data can track custom versioning
node.setPluginData('version', '2.1.0')
node.setPluginData('lastModified', new Date().toISOString())
node.setPluginData('modifiedBy', 'user@example.com')
```

### 3. Team Libraries

```typescript
// Check if node is from external library
if (node.type === 'INSTANCE') {
  const component = node.mainComponent
  if (component && component.parent?.type === 'PAGE') {
    // Component is from library
  }
}
```

## Best Practices from Context7

### 1. Performance Optimization

```typescript
// ✅ Use findAllWithCriteria for large documents
const nodes = figma.currentPage.findAllWithCriteria({
  types: ['TEXT']
})

// ❌ Avoid findAll for simple type searches
const nodes = figma.currentPage.findAll(n => n.type === 'TEXT')

// ✅ Enable invisible instance optimization
figma.skipInvisibleInstanceChildren = true

// ✅ Batch operations
const nodes = []
for (let i = 0; i < 100; i++) {
  const rect = figma.createRectangle()
  rect.x = i * 120
  nodes.push(rect)
}
figma.currentPage.selection = nodes
figma.viewport.scrollAndZoomIntoView(nodes)

// ❌ Avoid individual viewport updates
for (let i = 0; i < 100; i++) {
  const rect = figma.createRectangle()
  figma.viewport.scrollAndZoomIntoView([rect]) // Slow!
}
```

### 2. Font Loading

```typescript
// ✅ Always load fonts before modifying text
const text = figma.createText()
await figma.loadFontAsync(text.fontName)
text.characters = 'Hello'

// ✅ Load font before changing fontName
await figma.loadFontAsync({ family: 'Roboto', style: 'Bold' })
text.fontName = { family: 'Roboto', style: 'Bold' }

// ❌ This will error
text.characters = 'Hello' // Error: font not loaded
```

### 3. Error Handling

```typescript
try {
  const node = await figma.getNodeByIdAsync(id)
  if (!node) {
    figma.notify('Node not found', { error: true })
    return
  }

  // Process node
} catch (error) {
  figma.notify(`Error: ${error.message}`, { error: true })
  console.error(error)
}
```

### 4. Memory Management

```typescript
// ✅ Clean up large data
figma.on('close', () => {
  // Clear large caches
  cache.clear()
})

// ✅ Use async iteration for large datasets
async function processManyNodes() {
  const nodes = figma.currentPage.findAllWithCriteria({ types: ['TEXT'] })

  for (let i = 0; i < nodes.length; i++) {
    await processNode(nodes[i])

    // Yield to UI every 100 items
    if (i % 100 === 0) {
      await new Promise(resolve => setTimeout(resolve, 0))
    }
  }
}
```

### 5. Type Safety

```typescript
// ✅ Type guards
if (node.type === 'TEXT') {
  // TypeScript knows node is TextNode
  console.log(node.characters)
}

if ('children' in node) {
  // Node has children
  node.children.forEach(child => console.log(child.name))
}

// ✅ Use specific types
function processText(node: TextNode) {
  console.log(node.characters)
}

// ❌ Avoid any
function processNode(node: any) { // Bad!
  console.log(node.characters) // Might error
}
```

## Common Workflows

### 1. Design System Setup

```typescript
async function setupDesignSystem() {
  // Create variable collection
  const tokens = figma.variables.createVariableCollection('Design Tokens')

  // Colors
  const colors = {
    'color/primary': { r: 0.2, g: 0.5, b: 1, a: 1 },
    'color/secondary': { r: 0.5, g: 0.2, b: 0.8, a: 1 },
    'color/success': { r: 0.2, g: 0.8, b: 0.3, a: 1 },
    'color/error': { r: 0.9, g: 0.2, b: 0.2, a: 1 }
  }

  for (const [name, value] of Object.entries(colors)) {
    const variable = figma.variables.createVariable(name, tokens, 'COLOR')
    variable.setValueForMode(tokens.modes[0].modeId, value)
  }

  // Spacing
  const spacing = [4, 8, 12, 16, 24, 32, 48, 64]
  spacing.forEach((value, i) => {
    const variable = figma.variables.createVariable(
      `spacing/${i}`,
      tokens,
      'FLOAT'
    )
    variable.setValueForMode(tokens.modes[0].modeId, value)
  })

  // Create styles
  const primaryStyle = figma.createPaintStyle()
  primaryStyle.name = 'Color/Primary'
  primaryStyle.paints = [{
    type: 'SOLID',
    color: colors['color/primary']
  }]

  figma.notify('Design system created!')
}
```

### 2. Component Library

```typescript
async function createButtonLibrary() {
  // Create component set for variants
  const buttons = figma.createComponentSet()
  buttons.name = "Button"

  // Primary variant
  const primary = figma.createComponent()
  primary.name = "Type=Primary, Size=Medium"
  primary.resize(120, 40)
  buttons.appendChild(primary)

  // Secondary variant
  const secondary = figma.createComponent()
  secondary.name = "Type=Secondary, Size=Medium"
  secondary.resize(120, 40)
  buttons.appendChild(secondary)

  // Large size
  const large = figma.createComponent()
  large.name = "Type=Primary, Size=Large"
  large.resize(160, 48)
  buttons.appendChild(large)

  return buttons
}
```

### 3. Batch Export

```typescript
async function exportAllFrames() {
  const frames = figma.currentPage.findAllWithCriteria({
    types: ['FRAME']
  })

  const exports = []

  for (const frame of frames) {
    // Export 1x and 2x
    const bytes1x = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 1 }
    })

    const bytes2x = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 2 }
    })

    exports.push({
      name: frame.name,
      '1x': bytes1x,
      '2x': bytes2x
    })
  }

  // Send to UI for download
  figma.ui.postMessage({
    type: 'exports-ready',
    exports
  })
}
```

### 4. Style Sync

```typescript
async function syncStyles() {
  const paintStyles = await figma.getLocalPaintStylesAsync()
  const textStyles = await figma.getLocalTextStylesAsync()

  // Update all instances
  const nodes = figma.currentPage.findAllWithCriteria({
    types: ['RECTANGLE', 'TEXT']
  })

  for (const node of nodes) {
    if (node.type === 'RECTANGLE') {
      // Apply paint style based on name
      const style = paintStyles.find(s => s.name === 'Brand/Primary')
      if (style) {
        node.fillStyleId = style.id
      }
    }

    if (node.type === 'TEXT') {
      // Apply text style
      const style = textStyles.find(s => s.name === 'Body/Regular')
      if (style) {
        node.textStyleId = style.id
      }
    }
  }

  figma.notify('Styles synced!')
}
```

## Plugin UI Patterns

### 1. Theme-Aware UI

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      margin: 0;
      padding: 16px;
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
      font-size: 14px;
    }

    button:hover {
      background: var(--figma-color-bg-brand-hover);
    }

    input {
      background: var(--figma-color-bg);
      color: var(--figma-color-text);
      border: 1px solid var(--figma-color-border);
      padding: 8px;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <h2>My Plugin</h2>
  <input type="text" id="input" placeholder="Enter text...">
  <button onclick="handleClick()">Create</button>
</body>
</html>
```

### 2. Loading States

```html
<div id="status">
  <div class="spinner"></div>
  <p>Processing...</p>
</div>

<script>
  function showLoading() {
    document.getElementById('status').style.display = 'block'
  }

  function hideLoading() {
    document.getElementById('status').style.display = 'none'
  }

  async function process() {
    showLoading()
    parent.postMessage({ pluginMessage: { type: 'process' } }, '*')
  }

  window.onmessage = (event) => {
    if (event.data.pluginMessage.type === 'complete') {
      hideLoading()
    }
  }
</script>
```

## FigJam-Specific Features

```typescript
if (figma.editorType === 'figjam') {
  // Create sticky note
  const sticky = figma.createSticky()
  sticky.x = 100
  sticky.y = 100
  await figma.loadFontAsync({ family: "Roboto", style: "Regular" })
  sticky.text.characters = "TODO: Review designs"

  // Create connector
  const connector = figma.createConnector()
  connector.connectorStart = {
    endpointNodeId: sticky.id,
    position: { x: 0, y: 0.5 }
  }

  // Create shape
  const shape = figma.createShape()
  shape.resize(100, 100)
  shape.fills = [{ type: 'SOLID', color: { r: 1, g: 0.8, b: 0 } }]
}
```

## Advanced Techniques

### 1. Smart Component Swapping

```typescript
async function swapComponents(oldComponent: ComponentNode, newComponent: ComponentNode) {
  const instances = figma.currentPage.findAllWithCriteria({
    types: ['INSTANCE']
  })

  let swapCount = 0

  for (const instance of instances) {
    if (instance.mainComponent?.id === oldComponent.id) {
      await instance.swapAsync(newComponent)
      swapCount++
    }
  }

  figma.notify(`Swapped ${swapCount} instances`)
}
```

### 2. Auto Layout Migration

```typescript
function convertToAutoLayout(frame: FrameNode) {
  // Store original positions
  const childData = frame.children.map(child => ({
    node: child,
    x: child.x,
    y: child.y
  }))

  // Enable auto layout
  frame.layoutMode = 'VERTICAL'
  frame.primaryAxisSizingMode = 'AUTO'
  frame.counterAxisSizingMode = 'FIXED'
  frame.itemSpacing = 16
  frame.paddingLeft = 24
  frame.paddingRight = 24
  frame.paddingTop = 24
  frame.paddingBottom = 24

  // Configure children
  frame.children.forEach(child => {
    if ('layoutAlign' in child) {
      child.layoutAlign = 'STRETCH'
    }
  })
}
```

### 3. Responsive Resize

```typescript
function makeResponsive(frame: FrameNode) {
  frame.layoutMode = 'VERTICAL'
  frame.primaryAxisSizingMode = 'AUTO'
  frame.counterAxisSizingMode = 'FIXED'

  // Make children responsive
  frame.children.forEach(child => {
    if ('resize' in child) {
      child.layoutAlign = 'STRETCH'
      child.layoutGrow = 0
      child.minWidth = 200
      child.maxWidth = 800
    }
  })
}
```

## Testing and Debugging

```typescript
// Console logging
console.log('Selection:', figma.currentPage.selection)
console.error('Error occurred:', error)

// Notifications
figma.notify('Success!', { timeout: 2000 })
figma.notify('Error occurred', { error: true })

// Debugging helpers
function debugNode(node: SceneNode) {
  console.log('Node Debug Info:')
  console.log('  Type:', node.type)
  console.log('  Name:', node.name)
  console.log('  ID:', node.id)
  console.log('  Position:', { x: node.x, y: node.y })

  if ('width' in node) {
    console.log('  Size:', { width: node.width, height: node.height })
  }

  if ('children' in node) {
    console.log('  Children:', node.children.length)
  }
}
```

## Resources

- Official Figma Plugin API: https://www.figma.com/plugin-docs/
- Context7 Library: /figma/plugin-typings (Trust Score: 9.8)
- Plugin Samples: https://github.com/figma/plugin-samples
- Community Forum: https://forum.figma.com/
- Widget API: https://www.figma.com/widget-docs/
- REST API: https://www.figma.com/developers/api

## Summary

This skill covers:
- Component and instance management
- Auto layout and constraints
- Variables and design tokens
- Styles (paint, text, effect)
- Prototyping and interactions
- Plugin development patterns
- Node search and manipulation
- Export and image handling
- Performance optimization
- Best practices from Context7 research

Use this skill for building production-ready Figma plugins, automating design workflows, managing design systems, and creating scalable component libraries.
