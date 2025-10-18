# Figma Design Examples

Comprehensive collection of practical Figma plugin examples, design system patterns, and automation workflows based on official Figma Plugin API documentation from Context7.

## Table of Contents

1. [Component Creation Examples](#component-creation-examples)
2. [Auto Layout Examples](#auto-layout-examples)
3. [Design System Examples](#design-system-examples)
4. [Plugin Development Examples](#plugin-development-examples)
5. [Data Management Examples](#data-management-examples)
6. [Export Examples](#export-examples)
7. [Prototyping Examples](#prototyping-examples)
8. [Batch Operations Examples](#batch-operations-examples)
9. [Advanced Patterns](#advanced-patterns)

---

## Component Creation Examples

### Example 1: Create Button Component with Variants

```typescript
async function createButtonSystem() {
  // Create component set for variants
  const buttonSet = figma.createComponentSet()
  buttonSet.name = "Button"
  buttonSet.x = 100
  buttonSet.y = 100

  // Variant configurations
  const variants = [
    { type: 'Primary', size: 'Small', width: 100, height: 32, fontSize: 12 },
    { type: 'Primary', size: 'Medium', width: 120, height: 40, fontSize: 14 },
    { type: 'Primary', size: 'Large', width: 140, height: 48, fontSize: 16 },
    { type: 'Secondary', size: 'Small', width: 100, height: 32, fontSize: 12 },
    { type: 'Secondary', size: 'Medium', width: 120, height: 40, fontSize: 14 },
    { type: 'Secondary', size: 'Large', width: 140, height: 48, fontSize: 16 }
  ]

  const colorMap = {
    Primary: { r: 0.2, g: 0.5, b: 1 },
    Secondary: { r: 0.5, g: 0.5, b: 0.5 }
  }

  for (const variant of variants) {
    // Create component
    const component = figma.createComponent()
    component.name = `Type=${variant.type}, Size=${variant.size}`
    component.resize(variant.width, variant.height)

    // Create background
    const bg = figma.createRectangle()
    bg.name = "Background"
    bg.resize(variant.width, variant.height)
    bg.cornerRadius = 8
    bg.fills = [{
      type: 'SOLID',
      color: colorMap[variant.type]
    }]
    component.appendChild(bg)

    // Create text
    const text = figma.createText()
    await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
    text.name = "Label"
    text.characters = "Button"
    text.fontSize = variant.fontSize
    text.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]

    // Center text
    text.x = (variant.width - text.width) / 2
    text.y = (variant.height - text.height) / 2
    component.appendChild(text)

    // Add to component set
    buttonSet.appendChild(component)
  }

  figma.currentPage.selection = [buttonSet]
  figma.viewport.scrollAndZoomIntoView([buttonSet])
  figma.notify('Button system created with 6 variants!')

  return buttonSet
}
```

### Example 2: Icon Component Library

```typescript
async function createIconLibrary() {
  const icons = {
    'home': 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
    'user': 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2',
    'settings': 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z'
  }

  const iconComponents = []
  let xOffset = 0

  for (const [name, path] of Object.entries(icons)) {
    // Create SVG wrapper
    const svgString = `
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <path d="${path}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    `

    const iconNode = figma.createNodeFromSvg(svgString)

    // Convert to component
    const component = figma.createComponentFromNode(iconNode)
    component.name = `Icon/${name}`
    component.x = xOffset
    component.y = 100

    iconComponents.push(component)
    xOffset += 50
  }

  figma.currentPage.selection = iconComponents
  figma.viewport.scrollAndZoomIntoView(iconComponents)
  figma.notify(`Created ${iconComponents.length} icon components!`)

  return iconComponents
}
```

### Example 3: Card Component with Instance Swap

```typescript
async function createCardComponent() {
  // Create base card component
  const card = figma.createComponent()
  card.name = "Card"
  card.resize(300, 400)
  card.layoutMode = 'VERTICAL'
  card.primaryAxisSizingMode = 'AUTO'
  card.itemSpacing = 16
  card.paddingLeft = 24
  card.paddingRight = 24
  card.paddingTop = 24
  card.paddingBottom = 24
  card.cornerRadius = 12
  card.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  card.effects = [{
    type: 'DROP_SHADOW',
    color: { r: 0, g: 0, b: 0, a: 0.1 },
    offset: { x: 0, y: 4 },
    radius: 12,
    visible: true,
    blendMode: 'NORMAL'
  }]

  // Add image placeholder
  const imagePlaceholder = figma.createRectangle()
  imagePlaceholder.name = "Image"
  imagePlaceholder.resize(252, 200)
  imagePlaceholder.cornerRadius = 8
  imagePlaceholder.fills = [{ type: 'SOLID', color: { r: 0.9, g: 0.9, b: 0.9 } }]
  if ('layoutAlign' in imagePlaceholder) {
    imagePlaceholder.layoutAlign = 'STRETCH'
  }
  card.appendChild(imagePlaceholder)

  // Add title
  const title = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
  title.name = "Title"
  title.characters = "Card Title"
  title.fontSize = 20
  if ('layoutAlign' in title) {
    title.layoutAlign = 'STRETCH'
  }
  card.appendChild(title)

  // Add description
  const description = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
  description.name = "Description"
  description.characters = "Card description goes here with more details about the content."
  description.fontSize = 14
  description.textAlignVertical = 'TOP'
  if ('layoutAlign' in description) {
    description.layoutAlign = 'STRETCH'
  }
  card.appendChild(description)

  // Add component properties
  card.addComponentProperty('title', 'TEXT', 'Card Title')
  card.addComponentProperty('description', 'TEXT', 'Card description')
  card.addComponentProperty('showImage', 'BOOLEAN', true)

  figma.notify('Card component created!')
  return card
}
```

---

## Auto Layout Examples

### Example 4: Responsive Navigation Bar

```typescript
async function createNavBar() {
  // Create nav container
  const nav = figma.createFrame()
  nav.name = "Navigation Bar"
  nav.layoutMode = 'HORIZONTAL'
  nav.primaryAxisSizingMode = 'FIXED'
  nav.counterAxisSizingMode = 'FIXED'
  nav.resize(1200, 64)
  nav.itemSpacing = 24
  nav.paddingLeft = 32
  nav.paddingRight = 32
  nav.primaryAxisAlignItems = 'SPACE_BETWEEN'
  nav.counterAxisAlignItems = 'CENTER'
  nav.fills = [{ type: 'SOLID', color: { r: 0.1, g: 0.1, b: 0.1 } }]

  // Logo section
  const logo = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
  logo.name = "Logo"
  logo.characters = "LOGO"
  logo.fontSize = 24
  logo.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  nav.appendChild(logo)

  // Menu items container
  const menu = figma.createFrame()
  menu.name = "Menu"
  menu.layoutMode = 'HORIZONTAL'
  menu.primaryAxisSizingMode = 'AUTO'
  menu.counterAxisSizingMode = 'FIXED'
  menu.resize(0, 40)
  menu.itemSpacing = 32
  menu.fills = []
  menu.layoutGrow = 1

  const menuItems = ['Home', 'About', 'Services', 'Contact']
  for (const item of menuItems) {
    const menuItem = figma.createText()
    await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
    menuItem.name = item
    menuItem.characters = item
    menuItem.fontSize = 16
    menuItem.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
    menu.appendChild(menuItem)
  }

  nav.appendChild(menu)

  // CTA Button
  const cta = figma.createFrame()
  cta.name = "CTA"
  cta.layoutMode = 'HORIZONTAL'
  cta.primaryAxisSizingMode = 'AUTO'
  cta.counterAxisSizingMode = 'FIXED'
  cta.resize(0, 40)
  cta.paddingLeft = 24
  cta.paddingRight = 24
  cta.cornerRadius = 8
  cta.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.5, b: 1 } }]
  cta.primaryAxisAlignItems = 'CENTER'
  cta.counterAxisAlignItems = 'CENTER'

  const ctaText = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
  ctaText.characters = "Get Started"
  ctaText.fontSize = 14
  ctaText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  cta.appendChild(ctaText)

  nav.appendChild(cta)

  figma.currentPage.selection = [nav]
  figma.viewport.scrollAndZoomIntoView([nav])
  figma.notify('Navigation bar created!')

  return nav
}
```

### Example 5: Grid Layout System

```typescript
async function createGridLayout(rows: number, cols: number) {
  const container = figma.createFrame()
  container.name = `Grid ${rows}x${cols}`
  container.layoutMode = 'VERTICAL'
  container.primaryAxisSizingMode = 'AUTO'
  container.counterAxisSizingMode = 'FIXED'
  container.resize(800, 0)
  container.itemSpacing = 16
  container.paddingLeft = 24
  container.paddingRight = 24
  container.paddingTop = 24
  container.paddingBottom = 24
  container.fills = [{ type: 'SOLID', color: { r: 0.95, g: 0.95, b: 0.95 } }]

  for (let row = 0; row < rows; row++) {
    const rowFrame = figma.createFrame()
    rowFrame.name = `Row ${row + 1}`
    rowFrame.layoutMode = 'HORIZONTAL'
    rowFrame.primaryAxisSizingMode = 'FIXED'
    rowFrame.counterAxisSizingMode = 'AUTO'
    rowFrame.resize(752, 0)
    rowFrame.itemSpacing = 16
    rowFrame.fills = []
    if ('layoutAlign' in rowFrame) {
      rowFrame.layoutAlign = 'STRETCH'
    }

    for (let col = 0; col < cols; col++) {
      const cell = figma.createFrame()
      cell.name = `Cell ${row + 1}-${col + 1}`
      cell.layoutMode = 'VERTICAL'
      cell.primaryAxisSizingMode = 'AUTO'
      cell.counterAxisSizingMode = 'FIXED'
      cell.resize((752 - (cols - 1) * 16) / cols, 0)
      cell.paddingLeft = 16
      cell.paddingRight = 16
      cell.paddingTop = 16
      cell.paddingBottom = 16
      cell.cornerRadius = 8
      cell.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
      cell.layoutGrow = 1

      // Add content
      const text = figma.createText()
      await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
      text.characters = `Cell ${row + 1}-${col + 1}`
      text.fontSize = 14
      if ('layoutAlign' in text) {
        text.layoutAlign = 'STRETCH'
      }
      cell.appendChild(text)

      rowFrame.appendChild(cell)
    }

    container.appendChild(rowFrame)
  }

  figma.currentPage.selection = [container]
  figma.viewport.scrollAndZoomIntoView([container])
  figma.notify(`${rows}x${cols} grid created!`)

  return container
}

// Usage
createGridLayout(3, 4) // 3 rows, 4 columns
```

### Example 6: Flexible Dashboard Layout

```typescript
async function createDashboard() {
  const dashboard = figma.createFrame()
  dashboard.name = "Dashboard"
  dashboard.layoutMode = 'VERTICAL'
  dashboard.primaryAxisSizingMode = 'FIXED'
  dashboard.counterAxisSizingMode = 'FIXED'
  dashboard.resize(1200, 800)
  dashboard.itemSpacing = 24
  dashboard.paddingLeft = 24
  dashboard.paddingRight = 24
  dashboard.paddingTop = 24
  dashboard.paddingBottom = 24
  dashboard.fills = [{ type: 'SOLID', color: { r: 0.98, g: 0.98, b: 0.98 } }]

  // Header
  const header = figma.createFrame()
  header.name = "Header"
  header.layoutMode = 'HORIZONTAL'
  header.primaryAxisSizingMode = 'FIXED'
  header.counterAxisSizingMode = 'FIXED'
  header.resize(1152, 80)
  header.paddingLeft = 32
  header.paddingRight = 32
  header.primaryAxisAlignItems = 'SPACE_BETWEEN'
  header.counterAxisAlignItems = 'CENTER'
  header.cornerRadius = 12
  header.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]

  const title = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
  title.characters = "Dashboard Overview"
  title.fontSize = 28
  header.appendChild(title)

  dashboard.appendChild(header)

  // Stats row
  const statsRow = figma.createFrame()
  statsRow.name = "Stats"
  statsRow.layoutMode = 'HORIZONTAL'
  statsRow.primaryAxisSizingMode = 'FIXED'
  statsRow.counterAxisSizingMode = 'AUTO'
  statsRow.resize(1152, 0)
  statsRow.itemSpacing = 24
  statsRow.fills = []
  if ('layoutAlign' in statsRow) {
    statsRow.layoutAlign = 'STRETCH'
  }

  const stats = [
    { label: 'Total Users', value: '12,456' },
    { label: 'Revenue', value: '$45,678' },
    { label: 'Growth', value: '+23.5%' },
    { label: 'Active', value: '8,234' }
  ]

  for (const stat of stats) {
    const statCard = figma.createFrame()
    statCard.name = stat.label
    statCard.layoutMode = 'VERTICAL'
    statCard.primaryAxisSizingMode = 'AUTO'
    statCard.counterAxisSizingMode = 'FIXED'
    statCard.resize(270, 0)
    statCard.paddingLeft = 24
    statCard.paddingRight = 24
    statCard.paddingTop = 20
    statCard.paddingBottom = 20
    statCard.itemSpacing = 8
    statCard.cornerRadius = 12
    statCard.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
    statCard.layoutGrow = 1

    const label = figma.createText()
    await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
    label.characters = stat.label
    label.fontSize = 14
    label.fills = [{ type: 'SOLID', color: { r: 0.5, g: 0.5, b: 0.5 } }]
    statCard.appendChild(label)

    const value = figma.createText()
    await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
    value.characters = stat.value
    value.fontSize = 32
    statCard.appendChild(value)

    statsRow.appendChild(statCard)
  }

  dashboard.appendChild(statsRow)

  // Main content area
  const content = figma.createFrame()
  content.name = "Content"
  content.layoutMode = 'HORIZONTAL'
  content.primaryAxisSizingMode = 'FIXED'
  content.counterAxisSizingMode = 'FIXED'
  content.resize(1152, 580)
  content.itemSpacing = 24
  content.fills = []
  if ('layoutAlign' in content) {
    content.layoutAlign = 'STRETCH'
  }

  // Chart area (2/3 width)
  const chartArea = figma.createFrame()
  chartArea.name = "Chart"
  chartArea.resize(752, 580)
  chartArea.cornerRadius = 12
  chartArea.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  chartArea.layoutGrow = 2
  content.appendChild(chartArea)

  // Sidebar (1/3 width)
  const sidebar = figma.createFrame()
  sidebar.name = "Sidebar"
  sidebar.resize(376, 580)
  sidebar.cornerRadius = 12
  sidebar.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  sidebar.layoutGrow = 1
  content.appendChild(sidebar)

  dashboard.appendChild(content)

  figma.currentPage.selection = [dashboard]
  figma.viewport.scrollAndZoomIntoView([dashboard])
  figma.notify('Dashboard created!')

  return dashboard
}
```

---

## Design System Examples

### Example 7: Complete Design Token System

```typescript
async function createDesignTokens() {
  const collection = figma.variables.createVariableCollection('Design System')
  const defaultMode = collection.modes[0]
  defaultMode.name = 'Light'
  const darkMode = collection.addMode('Dark')

  // Color tokens
  const colorTokens = {
    'color/primary': {
      light: { r: 0.2, g: 0.5, b: 1, a: 1 },
      dark: { r: 0.4, g: 0.7, b: 1, a: 1 }
    },
    'color/secondary': {
      light: { r: 0.5, g: 0.2, b: 0.8, a: 1 },
      dark: { r: 0.7, g: 0.4, b: 0.9, a: 1 }
    },
    'color/background': {
      light: { r: 1, g: 1, b: 1, a: 1 },
      dark: { r: 0.1, g: 0.1, b: 0.1, a: 1 }
    },
    'color/surface': {
      light: { r: 0.98, g: 0.98, b: 0.98, a: 1 },
      dark: { r: 0.15, g: 0.15, b: 0.15, a: 1 }
    },
    'color/text/primary': {
      light: { r: 0, g: 0, b: 0, a: 1 },
      dark: { r: 1, g: 1, b: 1, a: 1 }
    },
    'color/text/secondary': {
      light: { r: 0.5, g: 0.5, b: 0.5, a: 1 },
      dark: { r: 0.7, g: 0.7, b: 0.7, a: 1 }
    },
    'color/success': {
      light: { r: 0.2, g: 0.8, b: 0.3, a: 1 },
      dark: { r: 0.3, g: 0.9, b: 0.4, a: 1 }
    },
    'color/warning': {
      light: { r: 1, g: 0.7, b: 0, a: 1 },
      dark: { r: 1, g: 0.8, b: 0.2, a: 1 }
    },
    'color/error': {
      light: { r: 0.9, g: 0.2, b: 0.2, a: 1 },
      dark: { r: 1, g: 0.3, b: 0.3, a: 1 }
    }
  }

  const colorVars = {}
  for (const [name, values] of Object.entries(colorTokens)) {
    const variable = figma.variables.createVariable(name, collection, 'COLOR')
    variable.setValueForMode(defaultMode.modeId, values.light)
    variable.setValueForMode(darkMode, values.dark)
    colorVars[name] = variable
  }

  // Spacing tokens
  const spacingValues = [0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128]
  const spacingVars = []

  for (let i = 0; i < spacingValues.length; i++) {
    const variable = figma.variables.createVariable(
      `spacing/${i}`,
      collection,
      'FLOAT'
    )
    variable.setValueForMode(defaultMode.modeId, spacingValues[i])
    variable.setValueForMode(darkMode, spacingValues[i])
    spacingVars.push(variable)
  }

  // Typography tokens
  const fontSizes = [12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 64]
  const typographyVars = []

  for (let i = 0; i < fontSizes.length; i++) {
    const variable = figma.variables.createVariable(
      `typography/size/${i}`,
      collection,
      'FLOAT'
    )
    variable.setValueForMode(defaultMode.modeId, fontSizes[i])
    variable.setValueForMode(darkMode, fontSizes[i])
    typographyVars.push(variable)
  }

  // Border radius tokens
  const borderRadii = [0, 4, 8, 12, 16, 24, 999]
  const radiusVars = []

  for (let i = 0; i < borderRadii.length; i++) {
    const variable = figma.variables.createVariable(
      `radius/${i}`,
      collection,
      'FLOAT'
    )
    variable.setValueForMode(defaultMode.modeId, borderRadii[i])
    variable.setValueForMode(darkMode, borderRadii[i])
    radiusVars.push(variable)
  }

  // Create semantic color aliases
  const bgVariable = figma.variables.createVariable(
    'semantic/background',
    collection,
    'COLOR'
  )
  const bgAlias = figma.variables.createVariableAlias(colorVars['color/background'])
  bgVariable.setValueForMode(defaultMode.modeId, bgAlias)
  bgVariable.setValueForMode(darkMode, bgAlias)

  figma.notify(`Design tokens created! ${Object.keys(colorTokens).length} colors, ${spacingValues.length} spacing values, ${fontSizes.length} font sizes`)

  return {
    collection,
    colorVars,
    spacingVars,
    typographyVars,
    radiusVars
  }
}
```

### Example 8: Typography Style System

```typescript
async function createTypographySystem() {
  const styles = [
    { name: 'Heading/H1', family: 'Inter', style: 'Bold', size: 48, lineHeight: 120 },
    { name: 'Heading/H2', family: 'Inter', style: 'Bold', size: 40, lineHeight: 120 },
    { name: 'Heading/H3', family: 'Inter', style: 'Bold', size: 32, lineHeight: 125 },
    { name: 'Heading/H4', family: 'Inter', style: 'Bold', size: 24, lineHeight: 130 },
    { name: 'Heading/H5', family: 'Inter', style: 'Bold', size: 20, lineHeight: 135 },
    { name: 'Heading/H6', family: 'Inter', style: 'Bold', size: 18, lineHeight: 140 },
    { name: 'Body/Large', family: 'Inter', style: 'Regular', size: 18, lineHeight: 150 },
    { name: 'Body/Medium', family: 'Inter', style: 'Regular', size: 16, lineHeight: 150 },
    { name: 'Body/Small', family: 'Inter', style: 'Regular', size: 14, lineHeight: 150 },
    { name: 'Caption/Regular', family: 'Inter', style: 'Regular', size: 12, lineHeight: 140 },
    { name: 'Caption/Bold', family: 'Inter', style: 'Bold', size: 12, lineHeight: 140 },
    { name: 'Overline', family: 'Inter', style: 'Medium', size: 10, lineHeight: 140 }
  ]

  const textStyles = []

  for (const styleConfig of styles) {
    const textStyle = figma.createTextStyle()
    textStyle.name = styleConfig.name
    textStyle.fontName = {
      family: styleConfig.family,
      style: styleConfig.style
    }
    textStyle.fontSize = styleConfig.size
    textStyle.lineHeight = {
      value: styleConfig.lineHeight,
      unit: 'PERCENT'
    }
    textStyle.letterSpacing = {
      value: 0,
      unit: 'PIXELS'
    }

    textStyles.push(textStyle)
  }

  // Create sample text nodes for preview
  const preview = figma.createFrame()
  preview.name = "Typography Preview"
  preview.layoutMode = 'VERTICAL'
  preview.primaryAxisSizingMode = 'AUTO'
  preview.counterAxisSizingMode = 'FIXED'
  preview.resize(600, 0)
  preview.itemSpacing = 24
  preview.paddingLeft = 32
  preview.paddingRight = 32
  preview.paddingTop = 32
  preview.paddingBottom = 32
  preview.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]

  for (const style of textStyles) {
    const text = figma.createText()
    await figma.loadFontAsync(style.fontName)
    text.textStyleId = style.id
    text.characters = style.name
    if ('layoutAlign' in text) {
      text.layoutAlign = 'STRETCH'
    }
    preview.appendChild(text)
  }

  figma.currentPage.selection = [preview]
  figma.viewport.scrollAndZoomIntoView([preview])
  figma.notify(`Created ${textStyles.length} text styles!`)

  return textStyles
}
```

### Example 9: Color Palette with Paint Styles

```typescript
async function createColorPalette() {
  const palette = {
    'Primary': {
      '50': { r: 0.93, g: 0.95, b: 1 },
      '100': { r: 0.86, g: 0.91, b: 1 },
      '200': { r: 0.73, g: 0.82, b: 1 },
      '300': { r: 0.60, g: 0.73, b: 1 },
      '400': { r: 0.47, g: 0.64, b: 1 },
      '500': { r: 0.2, g: 0.5, b: 1 },
      '600': { r: 0.16, g: 0.4, b: 0.8 },
      '700': { r: 0.12, g: 0.3, b: 0.6 },
      '800': { r: 0.08, g: 0.2, b: 0.4 },
      '900': { r: 0.04, g: 0.1, b: 0.2 }
    },
    'Gray': {
      '50': { r: 0.98, g: 0.98, b: 0.98 },
      '100': { r: 0.96, g: 0.96, b: 0.96 },
      '200': { r: 0.93, g: 0.93, b: 0.93 },
      '300': { r: 0.87, g: 0.87, b: 0.87 },
      '400': { r: 0.74, g: 0.74, b: 0.74 },
      '500': { r: 0.62, g: 0.62, b: 0.62 },
      '600': { r: 0.46, g: 0.46, b: 0.46 },
      '700': { r: 0.38, g: 0.38, b: 0.38 },
      '800': { r: 0.26, g: 0.26, b: 0.26 },
      '900': { r: 0.13, g: 0.13, b: 0.13 }
    }
  }

  const paintStyles = []
  let yOffset = 0

  for (const [colorName, shades] of Object.entries(palette)) {
    let xOffset = 0

    for (const [shade, color] of Object.entries(shades)) {
      // Create paint style
      const paintStyle = figma.createPaintStyle()
      paintStyle.name = `${colorName}/${shade}`
      paintStyle.paints = [{
        type: 'SOLID',
        color: color
      }]
      paintStyles.push(paintStyle)

      // Create preview swatch
      const swatch = figma.createRectangle()
      swatch.name = `${colorName}-${shade}`
      swatch.resize(80, 80)
      swatch.x = xOffset
      swatch.y = yOffset
      swatch.fillStyleId = paintStyle.id
      swatch.cornerRadius = 8

      xOffset += 90
    }

    yOffset += 90
  }

  figma.notify(`Created ${paintStyles.length} paint styles!`)
  return paintStyles
}
```

---

## Plugin Development Examples

### Example 10: Selection Inspector Plugin

```typescript
// code.ts
figma.showUI(__html__, { width: 350, height: 500, themeColors: true })

function inspectSelection() {
  const selection = figma.currentPage.selection

  if (selection.length === 0) {
    figma.ui.postMessage({
      type: 'inspection',
      data: { message: 'No selection' }
    })
    return
  }

  const inspectionData = selection.map(node => {
    const data: any = {
      id: node.id,
      name: node.name,
      type: node.type,
      visible: node.visible,
      locked: node.locked
    }

    if ('x' in node) {
      data.position = { x: node.x, y: node.y }
    }

    if ('width' in node) {
      data.size = { width: node.width, height: node.height }
    }

    if ('fills' in node) {
      data.fills = node.fills
    }

    if ('strokes' in node) {
      data.strokes = node.strokes
      data.strokeWeight = node.strokeWeight
    }

    if ('cornerRadius' in node) {
      data.cornerRadius = node.cornerRadius
    }

    if ('opacity' in node) {
      data.opacity = node.opacity
    }

    if ('layoutMode' in node) {
      data.autoLayout = {
        mode: node.layoutMode,
        spacing: node.itemSpacing,
        padding: {
          left: node.paddingLeft,
          right: node.paddingRight,
          top: node.paddingTop,
          bottom: node.paddingBottom
        }
      }
    }

    if (node.type === 'TEXT') {
      data.text = {
        characters: node.characters,
        fontSize: node.fontSize,
        fontName: node.fontName
      }
    }

    return data
  })

  figma.ui.postMessage({
    type: 'inspection',
    data: inspectionData
  })
}

figma.on('selectionchange', inspectSelection)
inspectSelection()

figma.ui.onmessage = async (msg) => {
  if (msg.type === 'select-node') {
    const node = await figma.getNodeByIdAsync(msg.id)
    if (node && 'x' in node) {
      figma.currentPage.selection = [node]
      figma.viewport.scrollAndZoomIntoView([node])
    }
  }
}
```

```html
<!-- ui.html -->
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
      font-size: 12px;
    }

    .node-card {
      background: var(--figma-color-bg-secondary);
      padding: 12px;
      border-radius: 6px;
      margin-bottom: 12px;
      cursor: pointer;
    }

    .node-card:hover {
      background: var(--figma-color-bg-hover);
    }

    .node-type {
      font-size: 10px;
      color: var(--figma-color-text-secondary);
      text-transform: uppercase;
    }

    .node-name {
      font-weight: 600;
      margin: 4px 0;
    }

    .property {
      display: flex;
      justify-content: space-between;
      margin: 4px 0;
      font-size: 11px;
    }

    .property-label {
      color: var(--figma-color-text-secondary);
    }
  </style>
</head>
<body>
  <div id="content"></div>

  <script>
    window.onmessage = (event) => {
      const msg = event.data.pluginMessage

      if (msg.type === 'inspection') {
        renderInspection(msg.data)
      }
    }

    function renderInspection(data) {
      const content = document.getElementById('content')

      if (data.message) {
        content.innerHTML = `<p>${data.message}</p>`
        return
      }

      content.innerHTML = data.map(node => `
        <div class="node-card" onclick="selectNode('${node.id}')">
          <div class="node-type">${node.type}</div>
          <div class="node-name">${node.name}</div>

          ${node.position ? `
            <div class="property">
              <span class="property-label">Position</span>
              <span>x: ${node.position.x.toFixed(0)}, y: ${node.position.y.toFixed(0)}</span>
            </div>
          ` : ''}

          ${node.size ? `
            <div class="property">
              <span class="property-label">Size</span>
              <span>${node.size.width.toFixed(0)} × ${node.size.height.toFixed(0)}</span>
            </div>
          ` : ''}

          ${node.opacity !== undefined ? `
            <div class="property">
              <span class="property-label">Opacity</span>
              <span>${(node.opacity * 100).toFixed(0)}%</span>
            </div>
          ` : ''}

          ${node.cornerRadius !== undefined ? `
            <div class="property">
              <span class="property-label">Corner Radius</span>
              <span>${node.cornerRadius}</span>
            </div>
          ` : ''}
        </div>
      `).join('')
    }

    function selectNode(id) {
      parent.postMessage({
        pluginMessage: { type: 'select-node', id }
      }, '*')
    }
  </script>
</body>
</html>
```

### Example 11: Batch Rename Plugin

```typescript
// code.ts
figma.showUI(__html__, { width: 400, height: 300 })

figma.ui.onmessage = async (msg) => {
  if (msg.type === 'rename') {
    const { find, replace, useRegex, caseSensitive } = msg

    const selection = figma.currentPage.selection

    if (selection.length === 0) {
      figma.notify('Please select nodes to rename', { error: true })
      return
    }

    let renamed = 0
    const flags = caseSensitive ? 'g' : 'gi'

    for (const node of selection) {
      const oldName = node.name

      if (useRegex) {
        try {
          const regex = new RegExp(find, flags)
          node.name = node.name.replace(regex, replace)
        } catch (error) {
          figma.notify('Invalid regex pattern', { error: true })
          return
        }
      } else {
        if (caseSensitive) {
          node.name = node.name.split(find).join(replace)
        } else {
          const regex = new RegExp(find, 'gi')
          node.name = node.name.replace(regex, replace)
        }
      }

      if (node.name !== oldName) {
        renamed++
      }
    }

    figma.notify(`Renamed ${renamed} of ${selection.length} nodes`)
  }

  if (msg.type === 'close') {
    figma.closePlugin()
  }
}
```

### Example 12: Style Applier Plugin

```typescript
// code.ts
figma.showUI(__html__, { width: 400, height: 500 })

async function loadStyles() {
  const paintStyles = await figma.getLocalPaintStylesAsync()
  const textStyles = await figma.getLocalTextStylesAsync()
  const effectStyles = await figma.getLocalEffectStylesAsync()

  figma.ui.postMessage({
    type: 'styles-loaded',
    data: {
      paint: paintStyles.map(s => ({ id: s.id, name: s.name })),
      text: textStyles.map(s => ({ id: s.id, name: s.name })),
      effect: effectStyles.map(s => ({ id: s.id, name: s.name }))
    }
  })
}

figma.ui.onmessage = async (msg) => {
  if (msg.type === 'apply-style') {
    const { styleId, styleType } = msg
    const selection = figma.currentPage.selection

    if (selection.length === 0) {
      figma.notify('Please select nodes', { error: true })
      return
    }

    let applied = 0

    for (const node of selection) {
      try {
        if (styleType === 'paint' && 'fillStyleId' in node) {
          node.fillStyleId = styleId
          applied++
        } else if (styleType === 'text' && node.type === 'TEXT') {
          node.textStyleId = styleId
          applied++
        } else if (styleType === 'effect' && 'effectStyleId' in node) {
          node.effectStyleId = styleId
          applied++
        }
      } catch (error) {
        console.error('Error applying style:', error)
      }
    }

    figma.notify(`Applied style to ${applied} nodes`)
  }
}

loadStyles()
```

---

## Data Management Examples

### Example 13: Version Control System

```typescript
interface VersionData {
  version: string
  timestamp: string
  author: string
  changes: string
  snapshot: string
}

async function saveVersion(node: SceneNode, message: string) {
  // Get current versions
  const versionsJson = node.getPluginData('versions') || '[]'
  const versions: VersionData[] = JSON.parse(versionsJson)

  // Create new version
  const newVersion: VersionData = {
    version: `v${versions.length + 1}`,
    timestamp: new Date().toISOString(),
    author: 'current-user',
    changes: message,
    snapshot: JSON.stringify({
      name: node.name,
      type: node.type,
      properties: extractProperties(node)
    })
  }

  versions.push(newVersion)

  // Save back to node
  node.setPluginData('versions', JSON.stringify(versions))
  node.setPluginData('currentVersion', newVersion.version)

  figma.notify(`Version ${newVersion.version} saved!`)
  return newVersion
}

function extractProperties(node: SceneNode): Record<string, any> {
  const props: any = {}

  if ('x' in node) {
    props.position = { x: node.x, y: node.y }
  }

  if ('width' in node) {
    props.size = { width: node.width, height: node.height }
  }

  if ('fills' in node) {
    props.fills = node.fills
  }

  if ('opacity' in node) {
    props.opacity = node.opacity
  }

  return props
}

async function listVersions(node: SceneNode): Promise<VersionData[]> {
  const versionsJson = node.getPluginData('versions') || '[]'
  return JSON.parse(versionsJson)
}

// Usage
const selectedNode = figma.currentPage.selection[0]
await saveVersion(selectedNode, 'Updated button styling')
const versions = await listVersions(selectedNode)
console.log('Versions:', versions)
```

### Example 14: Design Status Tracker

```typescript
type DesignStatus = 'draft' | 'in-review' | 'approved' | 'published'

interface StatusData {
  status: DesignStatus
  updatedAt: string
  updatedBy: string
  comments: string
}

async function setDesignStatus(
  node: SceneNode,
  status: DesignStatus,
  comments: string = ''
) {
  const statusData: StatusData = {
    status,
    updatedAt: new Date().toISOString(),
    updatedBy: 'current-user',
    comments
  }

  node.setPluginData('design-status', JSON.stringify(statusData))

  // Set visual indicator
  if ('strokes' in node) {
    const statusColors: Record<DesignStatus, RGB> = {
      'draft': { r: 0.5, g: 0.5, b: 0.5 },
      'in-review': { r: 1, g: 0.7, b: 0 },
      'approved': { r: 0.2, g: 0.8, b: 0.3 },
      'published': { r: 0.2, g: 0.5, b: 1 }
    }

    node.strokes = [{
      type: 'SOLID',
      color: statusColors[status]
    }]
    node.strokeWeight = 3
  }

  figma.notify(`Status set to: ${status}`)
}

async function getDesignStatus(node: SceneNode): Promise<StatusData | null> {
  const data = node.getPluginData('design-status')
  return data ? JSON.parse(data) : null
}

async function findNodesByStatus(status: DesignStatus): Promise<SceneNode[]> {
  const allNodes = figma.currentPage.findAllWithCriteria({
    pluginData: {
      keys: ['design-status']
    }
  })

  const filtered: SceneNode[] = []

  for (const node of allNodes) {
    const statusData = await getDesignStatus(node)
    if (statusData && statusData.status === status) {
      filtered.push(node)
    }
  }

  return filtered
}

// Usage
const frame = figma.currentPage.selection[0]
await setDesignStatus(frame, 'in-review', 'Ready for review')
const reviewNodes = await findNodesByStatus('in-review')
console.log(`Found ${reviewNodes.length} nodes in review`)
```

### Example 15: Component Usage Analytics

```typescript
interface UsageMetrics {
  instanceCount: number
  lastUsed: string
  usedInPages: string[]
  variantUsage: Record<string, number>
}

async function trackComponentUsage(component: ComponentNode): Promise<UsageMetrics> {
  const instances = figma.currentPage.findAllWithCriteria({
    types: ['INSTANCE']
  }).filter(instance => instance.mainComponent?.id === component.id)

  const usedInPages = new Set<string>()
  const variantUsage: Record<string, number> = {}

  for (const instance of instances) {
    // Track page usage
    if (instance.parent?.type === 'PAGE') {
      usedInPages.add(instance.parent.name)
    }

    // Track variant usage
    if (instance.variantProperties) {
      const variantKey = JSON.stringify(instance.variantProperties)
      variantUsage[variantKey] = (variantUsage[variantKey] || 0) + 1
    }
  }

  const metrics: UsageMetrics = {
    instanceCount: instances.length,
    lastUsed: new Date().toISOString(),
    usedInPages: Array.from(usedInPages),
    variantUsage
  }

  // Save metrics to component
  component.setPluginData('usage-metrics', JSON.stringify(metrics))

  return metrics
}

async function generateUsageReport(): Promise<string> {
  const components = figma.currentPage.findAllWithCriteria({
    types: ['COMPONENT']
  })

  let report = 'Component Usage Report\n'
  report += '======================\n\n'

  for (const component of components) {
    const metrics = await trackComponentUsage(component)

    report += `${component.name}\n`
    report += `  Instances: ${metrics.instanceCount}\n`
    report += `  Pages: ${metrics.usedInPages.join(', ')}\n`
    report += `  Last Used: ${metrics.lastUsed}\n\n`
  }

  return report
}

// Usage
const report = await generateUsageReport()
console.log(report)
```

---

## Export Examples

### Example 16: Multi-Format Asset Exporter

```typescript
async function exportAssets() {
  const selection = figma.currentPage.selection

  if (selection.length === 0) {
    figma.notify('Please select nodes to export', { error: true })
    return
  }

  const exports: Array<{
    name: string
    formats: Record<string, Uint8Array>
  }> = []

  for (const node of selection) {
    const nodeExports: Record<string, Uint8Array> = {}

    // PNG exports at different scales
    nodeExports['png-1x'] = await node.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 1 }
    })

    nodeExports['png-2x'] = await node.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 2 }
    })

    nodeExports['png-3x'] = await node.exportAsync({
      format: 'PNG',
      constraint: { type: 'SCALE', value: 3 }
    })

    // JPG export
    nodeExports['jpg'] = await node.exportAsync({
      format: 'JPG',
      constraint: { type: 'SCALE', value: 2 }
    })

    // SVG export
    nodeExports['svg'] = await node.exportAsync({
      format: 'SVG',
      svgIdAttribute: true,
      svgOutlineText: false,
      svgSimplifyStroke: true
    })

    // PDF export
    nodeExports['pdf'] = await node.exportAsync({
      format: 'PDF'
    })

    exports.push({
      name: node.name,
      formats: nodeExports
    })
  }

  // Send to UI for download
  figma.ui.postMessage({
    type: 'exports-ready',
    exports: exports.map(exp => ({
      name: exp.name,
      formats: Object.fromEntries(
        Object.entries(exp.formats).map(([format, bytes]) => [
          format,
          Array.from(bytes)
        ])
      )
    }))
  })

  figma.notify(`Exported ${exports.length} assets in multiple formats`)
}
```

### Example 17: Icon Set Exporter

```typescript
async function exportIconSet() {
  // Find all components with "Icon/" prefix
  const iconComponents = figma.currentPage.findAllWithCriteria({
    types: ['COMPONENT']
  }).filter(comp => comp.name.startsWith('Icon/'))

  if (iconComponents.length === 0) {
    figma.notify('No icon components found', { error: true })
    return
  }

  const iconExports = []

  for (const icon of iconComponents) {
    const iconName = icon.name.replace('Icon/', '')

    // Export as SVG
    const svg = await icon.exportAsync({
      format: 'SVG',
      svgIdAttribute: true,
      svgOutlineText: false,
      svgSimplifyStroke: true
    })

    // Export as PNG at multiple sizes
    const png24 = await icon.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 24 }
    })

    const png48 = await icon.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 48 }
    })

    const png96 = await icon.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 96 }
    })

    iconExports.push({
      name: iconName,
      svg: Array.from(svg),
      png24: Array.from(png24),
      png48: Array.from(png48),
      png96: Array.from(png96)
    })
  }

  // Send to UI
  figma.ui.postMessage({
    type: 'icon-exports-ready',
    icons: iconExports
  })

  figma.notify(`Exported ${iconExports.length} icons`)
}
```

### Example 18: Screenshot Generator

```typescript
async function generateScreenshots() {
  const frames = figma.currentPage.findAllWithCriteria({
    types: ['FRAME']
  }).filter(frame => frame.name.startsWith('Screen/'))

  const screenshots = []

  for (const frame of frames) {
    const screenName = frame.name.replace('Screen/', '')

    // Desktop screenshot (1920x1080)
    const desktop = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 1920 }
    })

    // Tablet screenshot (1024x768)
    const tablet = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 1024 }
    })

    // Mobile screenshot (375x667)
    const mobile = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 375 }
    })

    // Thumbnail (400px wide)
    const thumbnail = await frame.exportAsync({
      format: 'PNG',
      constraint: { type: 'WIDTH', value: 400 }
    })

    screenshots.push({
      name: screenName,
      desktop: Array.from(desktop),
      tablet: Array.from(tablet),
      mobile: Array.from(mobile),
      thumbnail: Array.from(thumbnail)
    })
  }

  figma.ui.postMessage({
    type: 'screenshots-ready',
    screenshots
  })

  figma.notify(`Generated ${screenshots.length} screenshot sets`)
}
```

---

## Prototyping Examples

### Example 19: Interaction Builder

```typescript
async function createInteractionFlow() {
  const frames = figma.currentPage.selection.filter(
    node => node.type === 'FRAME'
  ) as FrameNode[]

  if (frames.length < 2) {
    figma.notify('Please select at least 2 frames', { error: true })
    return
  }

  // Create navigation flow
  for (let i = 0; i < frames.length - 1; i++) {
    const currentFrame = frames[i]
    const nextFrame = frames[i + 1]

    // Add button to navigate to next frame
    const button = figma.createFrame()
    button.name = "Next Button"
    button.resize(120, 40)
    button.x = currentFrame.width - 140
    button.y = currentFrame.height - 60
    button.cornerRadius = 8
    button.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.5, b: 1 } }]
    button.layoutMode = 'HORIZONTAL'
    button.primaryAxisAlignItems = 'CENTER'
    button.counterAxisAlignItems = 'CENTER'
    button.paddingLeft = 16
    button.paddingRight = 16

    const buttonText = figma.createText()
    await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
    buttonText.characters = 'Next'
    buttonText.fontSize = 14
    buttonText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
    button.appendChild(buttonText)

    currentFrame.appendChild(button)

    // Add reaction to navigate
    await button.setReactionsAsync([
      {
        action: {
          type: 'NODE',
          destinationId: nextFrame.id,
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
  }

  figma.notify(`Created navigation flow with ${frames.length} frames`)
}
```

### Example 20: Modal Overlay System

```typescript
async function createModalSystem() {
  // Create base screen
  const baseScreen = figma.createFrame()
  baseScreen.name = "Base Screen"
  baseScreen.resize(375, 812)
  baseScreen.fills = [{ type: 'SOLID', color: { r: 0.98, g: 0.98, b: 0.98 } }]

  // Create open modal button
  const openButton = figma.createFrame()
  openButton.name = "Open Modal"
  openButton.resize(200, 48)
  openButton.x = (375 - 200) / 2
  openButton.y = 400
  openButton.cornerRadius = 24
  openButton.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.5, b: 1 } }]
  openButton.layoutMode = 'HORIZONTAL'
  openButton.primaryAxisAlignItems = 'CENTER'
  openButton.counterAxisAlignItems = 'CENTER'

  const buttonText = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
  buttonText.characters = 'Open Modal'
  buttonText.fontSize = 16
  buttonText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  openButton.appendChild(buttonText)

  baseScreen.appendChild(openButton)

  // Create modal overlay
  const modal = figma.createFrame()
  modal.name = "Modal"
  modal.resize(375, 812)
  modal.fills = [{ type: 'SOLID', color: { r: 0, g: 0, b: 0, a: 0.5 } }]
  modal.layoutMode = 'VERTICAL'
  modal.primaryAxisAlignItems = 'CENTER'
  modal.counterAxisAlignItems = 'CENTER'

  // Modal content
  const modalContent = figma.createFrame()
  modalContent.name = "Modal Content"
  modalContent.resize(320, 400)
  modalContent.cornerRadius = 16
  modalContent.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }]
  modalContent.layoutMode = 'VERTICAL'
  modalContent.itemSpacing = 16
  modalContent.paddingLeft = 24
  modalContent.paddingRight = 24
  modalContent.paddingTop = 24
  modalContent.paddingBottom = 24

  const modalTitle = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Bold' })
  modalTitle.characters = 'Modal Title'
  modalTitle.fontSize = 24
  modalContent.appendChild(modalTitle)

  const modalBody = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
  modalBody.characters = 'This is a modal overlay with content.'
  modalBody.fontSize = 16
  modalContent.appendChild(modalBody)

  // Close button
  const closeButton = figma.createFrame()
  closeButton.name = "Close"
  closeButton.resize(280, 48)
  closeButton.cornerRadius = 8
  closeButton.fills = [{ type: 'SOLID', color: { r: 0.9, g: 0.9, b: 0.9 } }]
  closeButton.layoutMode = 'HORIZONTAL'
  closeButton.primaryAxisAlignItems = 'CENTER'
  closeButton.counterAxisAlignItems = 'CENTER'

  const closeText = figma.createText()
  await figma.loadFontAsync({ family: 'Inter', style: 'Medium' })
  closeText.characters = 'Close'
  closeText.fontSize = 16
  closeButton.appendChild(closeText)

  modalContent.appendChild(closeButton)
  modal.appendChild(modalContent)

  // Set up interactions
  await openButton.setReactionsAsync([
    {
      action: {
        type: 'NODE',
        destinationId: modal.id,
        navigation: 'OVERLAY',
        transition: {
          type: 'DISSOLVE',
          easing: { type: 'EASE_OUT' },
          duration: 0.2
        },
        overlayRelativePosition: { x: 0, y: 0 }
      },
      trigger: {
        type: 'ON_CLICK'
      }
    }
  ])

  await closeButton.setReactionsAsync([
    {
      action: {
        type: 'CLOSE',
        transition: {
          type: 'DISSOLVE',
          easing: { type: 'EASE_IN' },
          duration: 0.2
        }
      },
      trigger: {
        type: 'ON_CLICK'
      }
    }
  ])

  figma.notify('Modal system created!')
  return { baseScreen, modal }
}
```

---

## Advanced Patterns

### Example 21: Responsive Layout Converter

```typescript
async function convertToResponsive(node: FrameNode) {
  if (node.type !== 'FRAME') {
    figma.notify('Please select a frame', { error: true })
    return
  }

  // Store original child positions
  const childData = node.children.map(child => ({
    node: child,
    x: 'x' in child ? child.x : 0,
    y: 'y' in child ? child.y : 0,
    width: 'width' in child ? child.width : 0,
    height: 'height' in child ? child.height : 0
  }))

  // Convert to auto layout
  node.layoutMode = 'VERTICAL'
  node.primaryAxisSizingMode = 'AUTO'
  node.counterAxisSizingMode = 'FIXED'
  node.itemSpacing = 16
  node.paddingLeft = 24
  node.paddingRight = 24
  node.paddingTop = 24
  node.paddingBottom = 24

  // Configure children
  node.children.forEach((child, index) => {
    if ('layoutAlign' in child) {
      child.layoutAlign = 'STRETCH'
      child.layoutGrow = 0
    }

    if ('minWidth' in child) {
      child.minWidth = Math.min(childData[index].width, 200)
      child.maxWidth = Math.max(childData[index].width, 800)
    }

    if ('minHeight' in child) {
      child.minHeight = childData[index].height
    }
  })

  figma.notify('Converted to responsive auto layout!')
}

// Usage
const selectedFrame = figma.currentPage.selection[0] as FrameNode
await convertToResponsive(selectedFrame)
```

### Example 22: Smart Component Swapper

```typescript
async function smartSwapComponents(
  findComponent: ComponentNode,
  replaceComponent: ComponentNode
) {
  const instances = figma.currentPage.findAllWithCriteria({
    types: ['INSTANCE']
  }).filter(instance => instance.mainComponent?.id === findComponent.id)

  let swapped = 0
  const errors: string[] = []

  for (const instance of instances) {
    try {
      // Preserve overrides
      const overrides = { ...instance.componentProperties }

      // Swap component
      await instance.swapAsync(replaceComponent)

      // Reapply compatible overrides
      for (const [key, value] of Object.entries(overrides)) {
        if (key in instance.componentProperties) {
          instance.setProperties({ [key]: value })
        }
      }

      swapped++
    } catch (error) {
      errors.push(`Failed to swap ${instance.name}: ${error.message}`)
    }
  }

  if (errors.length > 0) {
    console.error('Swap errors:', errors)
  }

  figma.notify(`Swapped ${swapped} of ${instances.length} instances`)
  return { swapped, total: instances.length, errors }
}
```

---

## Summary

This examples document includes 22 comprehensive, production-ready examples covering:

1-3: Component creation (button variants, icons, cards)
4-6: Auto layout patterns (navigation, grids, dashboards)
7-9: Design systems (tokens, typography, colors)
10-12: Plugin development (inspector, batch rename, style applier)
13-15: Data management (versioning, status tracking, analytics)
16-18: Export workflows (multi-format, icons, screenshots)
19-20: Prototyping (interactions, modals)
21-22: Advanced patterns (responsive conversion, component swapping)

All examples use Context7-validated Figma Plugin API patterns and best practices for production use.
