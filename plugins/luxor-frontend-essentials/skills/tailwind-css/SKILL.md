---
name: tailwind-css
description: Utility-first CSS framework for rapid UI development with responsive design, component patterns, and production optimization. Master core utilities, dark mode, customization, and modern component composition for building beautiful, performant user interfaces.
---

# Tailwind CSS - Utility-First Framework

A comprehensive skill for mastering Tailwind CSS, the utility-first CSS framework for rapidly building custom user interfaces. This skill covers core concepts, responsive design patterns, component extraction, dark mode implementation, theme customization, and production optimization.

## When to Use This Skill

Use this skill when:

- Building modern web applications with utility-first CSS approach
- Creating responsive designs that work across all device sizes
- Implementing dark mode and theme switching in applications
- Developing reusable component libraries with consistent styling
- Optimizing CSS performance for production deployments
- Customizing design systems with brand-specific tokens
- Building accessible, mobile-first user interfaces
- Integrating with frameworks like React, Vue, Svelte, or Next.js
- Prototyping and iterating on UI designs rapidly
- Maintaining design consistency across large codebases

## Core Concepts

### Utility-First Philosophy

Tailwind CSS takes a different approach from traditional CSS frameworks:

- **Utility Classes Over Components**: Instead of pre-built components, use single-purpose utility classes
- **Compose in HTML**: Build complex designs by composing utilities directly in your markup
- **No Context Switching**: Stay in your HTML/JSX without jumping to CSS files
- **Design System Built-In**: Consistent spacing, colors, and typography out of the box
- **Responsive by Default**: Every utility has responsive variants built-in
- **JIT Compilation**: Just-in-Time mode generates only the CSS you actually use

### Key Principles

1. **Single Responsibility**: Each class does one thing well
2. **Composability**: Combine utilities to create complex designs
3. **Constraints**: Design system constraints lead to better, more consistent UIs
4. **Flexibility**: Arbitrary values for one-off customizations when needed
5. **Performance**: Minimal CSS output through intelligent purging

## Core Utilities Reference

### Layout Utilities

#### Display
```html
<!-- Block and inline -->
<div class="block">Block element</div>
<span class="inline">Inline element</span>
<div class="inline-block">Inline-block</div>

<!-- Flexbox -->
<div class="flex items-center justify-between">
  <div>Left</div>
  <div>Right</div>
</div>

<!-- Grid -->
<div class="grid grid-cols-3 gap-4">
  <div>1</div>
  <div>2</div>
  <div>3</div>
</div>

<!-- Hidden -->
<div class="hidden md:block">Visible on medium screens and up</div>
```

#### Positioning
```html
<!-- Static, relative, absolute, fixed, sticky -->
<div class="relative">
  <div class="absolute top-0 right-0">Top-right corner</div>
</div>

<div class="fixed bottom-4 right-4">Fixed bottom-right</div>
<div class="sticky top-0">Sticky header</div>
```

#### Sizing
```html
<!-- Width and height -->
<div class="w-full h-screen">Full width, viewport height</div>
<div class="w-1/2 h-64">Half width, 16rem height</div>
<div class="w-[750px] h-[500px]">Arbitrary values</div>

<!-- Min/max -->
<div class="min-w-0 max-w-md">Constrained width</div>
<div class="min-h-screen max-h-full">Constrained height</div>
```

### Spacing Utilities

#### Padding and Margin
```html
<!-- All sides -->
<div class="p-4 m-2">Padding 1rem, margin 0.5rem</div>

<!-- Individual sides -->
<div class="pt-8 pb-4 pl-6 pr-2">Individual padding</div>
<div class="mt-4 mb-8 ml-auto mr-auto">Individual margin</div>

<!-- Logical properties -->
<div class="px-4 py-2">Horizontal and vertical</div>
<div class="ps-4 pe-2">Inline start/end (RTL-aware)</div>

<!-- Negative margins -->
<div class="-mt-4 -ml-2">Negative margins for overlap</div>

<!-- Space between -->
<div class="flex space-x-4">Horizontal spacing between children</div>
<div class="flex flex-col space-y-2">Vertical spacing between children</div>
```

### Typography Utilities

#### Font Family, Size, and Weight
```html
<!-- Font families -->
<p class="font-sans">Sans-serif font</p>
<p class="font-serif">Serif font</p>
<p class="font-mono">Monospace font</p>

<!-- Font sizes -->
<p class="text-xs">Extra small (0.75rem)</p>
<p class="text-sm">Small (0.875rem)</p>
<p class="text-base">Base (1rem)</p>
<p class="text-lg">Large (1.125rem)</p>
<p class="text-xl">Extra large (1.25rem)</p>
<h1 class="text-4xl">4XL heading (2.25rem)</h1>

<!-- Font weights -->
<p class="font-light">Light (300)</p>
<p class="font-normal">Normal (400)</p>
<p class="font-medium">Medium (500)</p>
<p class="font-semibold">Semibold (600)</p>
<p class="font-bold">Bold (700)</p>
```

#### Text Styling
```html
<!-- Text alignment -->
<p class="text-left">Left aligned</p>
<p class="text-center">Center aligned</p>
<p class="text-right">Right aligned</p>

<!-- Text color -->
<p class="text-gray-900">Dark gray text</p>
<p class="text-blue-600">Blue text</p>
<p class="text-red-500/75">Red text with 75% opacity</p>

<!-- Text decoration -->
<p class="underline">Underlined text</p>
<p class="line-through">Strikethrough text</p>
<a class="no-underline hover:underline">Hover underline</a>

<!-- Text transform -->
<p class="uppercase">UPPERCASE TEXT</p>
<p class="lowercase">lowercase text</p>
<p class="capitalize">Capitalize Each Word</p>

<!-- Line height and letter spacing -->
<p class="leading-tight">Tight line height</p>
<p class="leading-relaxed">Relaxed line height</p>
<p class="tracking-wide">Wide letter spacing</p>
```

### Color Utilities

#### Background Colors
```html
<!-- Solid backgrounds -->
<div class="bg-white">White background</div>
<div class="bg-gray-100">Light gray background</div>
<div class="bg-blue-500">Blue background</div>
<div class="bg-red-600/50">Red background at 50% opacity</div>

<!-- Gradients -->
<div class="bg-gradient-to-r from-purple-500 to-pink-500">
  Purple to pink gradient
</div>
<div class="bg-gradient-to-br from-blue-400 via-purple-500 to-pink-600">
  Three-color gradient
</div>
```

#### Text and Border Colors
```html
<!-- Text colors -->
<p class="text-gray-900 dark:text-white">Adaptive text color</p>
<p class="text-blue-600 hover:text-blue-800">Interactive text color</p>

<!-- Border colors -->
<div class="border border-gray-300">Gray border</div>
<div class="border-2 border-blue-500">Thick blue border</div>
<div class="divide-y divide-gray-200">Divided children</div>
```

### Border and Rounding Utilities

```html
<!-- Border width -->
<div class="border">1px border</div>
<div class="border-2">2px border</div>
<div class="border-t-4">4px top border only</div>

<!-- Border radius -->
<div class="rounded">0.25rem radius</div>
<div class="rounded-lg">0.5rem radius</div>
<div class="rounded-full">Full circle/pill</div>
<div class="rounded-t-lg">Round top only</div>

<!-- Border style -->
<div class="border-solid">Solid border</div>
<div class="border-dashed">Dashed border</div>
<div class="border-dotted">Dotted border</div>
```

### Shadow and Effects

```html
<!-- Box shadows -->
<div class="shadow-sm">Small shadow</div>
<div class="shadow-md">Medium shadow</div>
<div class="shadow-lg">Large shadow</div>
<div class="shadow-xl">Extra large shadow</div>
<div class="shadow-none hover:shadow-lg">Interactive shadow</div>

<!-- Text shadow -->
<h1 class="text-shadow-lg">Large text shadow</h1>
<p class="text-shadow-sm text-shadow-gray-300">Colored text shadow</p>

<!-- Opacity -->
<div class="opacity-50">50% opacity</div>
<div class="opacity-0 hover:opacity-100">Fade in on hover</div>
```

## Responsive Design

### Breakpoint System

Tailwind uses a mobile-first breakpoint system:

```css
/* Breakpoint reference */
sm: 640px   /* @media (min-width: 640px) */
md: 768px   /* @media (min-width: 768px) */
lg: 1024px  /* @media (min-width: 1024px) */
xl: 1280px  /* @media (min-width: 1280px) */
2xl: 1536px /* @media (min-width: 1536px) */
```

### Responsive Utilities

```html
<!-- Mobile-first approach -->
<div class="w-full md:w-1/2 lg:w-1/3">
  Full width on mobile, half on tablet, third on desktop
</div>

<!-- Responsive flexbox -->
<div class="flex flex-col md:flex-row gap-4">
  Vertical on mobile, horizontal on tablet+
</div>

<!-- Responsive grid -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  1 column mobile, 2 tablet, 4 desktop
</div>

<!-- Responsive text -->
<h1 class="text-2xl md:text-4xl lg:text-6xl">
  Scales with screen size
</h1>

<!-- Show/hide at breakpoints -->
<div class="block md:hidden">Mobile only</div>
<div class="hidden md:block">Desktop only</div>
<div class="hidden md:block lg:hidden">Tablet only</div>
```

### Custom Breakpoints

```css
/* app.css */
@import "tailwindcss";

@theme {
  --breakpoint-xs: 30rem;    /* 480px */
  --breakpoint-3xl: 120rem;  /* 1920px */
}
```

```html
<!-- Using custom breakpoints -->
<div class="grid xs:grid-cols-2 3xl:grid-cols-6">
  Uses custom xs and 3xl breakpoints
</div>
```

### Targeting Breakpoint Ranges

```html
<!-- Active only between md and xl -->
<div class="md:max-xl:flex">
  Flex layout only on tablets
</div>

<!-- Max-width utilities -->
<div class="flex max-md:hidden">
  Hidden below medium breakpoint
</div>
```

### Container Queries

```html
<!-- Container-based responsive design -->
<div class="@container">
  <div class="@lg:grid-cols-3 grid grid-cols-1">
    Responds to container size, not viewport
  </div>
</div>

<!-- Arbitrary container queries -->
<div class="@container">
  <div class="flex flex-col @min-[475px]:flex-row">
    Custom container breakpoint
  </div>
</div>

<!-- Using container query units -->
<div class="@container">
  <div class="w-[50cqw]">
    50% of container width
  </div>
</div>
```

## Dark Mode Implementation

### Automatic Dark Mode (Media Query)

Default behavior based on system preference:

```html
<!-- Automatically adapts to system preference -->
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg">
    <h3 class="text-gray-900 dark:text-white font-semibold">
      Card Title
    </h3>
    <p class="text-gray-500 dark:text-gray-400">
      Content automatically adapts to color scheme preference
    </p>
  </div>
</div>
```

### Manual Dark Mode (Class-Based)

Configure custom variant for manual control:

```css
/* app.css */
@import "tailwindcss";

@custom-variant dark (&:where(.dark, .dark *));
```

```html
<!-- Toggle dark mode with class -->
<html class="dark">
  <body>
    <div class="bg-white dark:bg-black">
      Controlled by .dark class on ancestor
    </div>
  </body>
</html>
```

### Dark Mode Toggle Logic

```javascript
// Dark mode toggle with localStorage persistence
// Add inline in <head> to avoid FOUC (Flash of Unstyled Content)
document.documentElement.classList.toggle(
  "dark",
  localStorage.theme === "dark" ||
    (!("theme" in localStorage) &&
     window.matchMedia("(prefers-color-scheme: dark)").matches)
);

// User explicitly chooses light mode
function setLightMode() {
  localStorage.theme = "light";
  document.documentElement.classList.remove("dark");
}

// User explicitly chooses dark mode
function setDarkMode() {
  localStorage.theme = "dark";
  document.documentElement.classList.add("dark");
}

// User chooses to respect OS preference
function setSystemMode() {
  localStorage.removeItem("theme");
  document.documentElement.classList.toggle(
    "dark",
    window.matchMedia("(prefers-color-scheme: dark)").matches
  );
}
```

### Data Attribute Dark Mode

Alternative approach using data attributes:

```css
/* app.css */
@import "tailwindcss";

@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
```

```html
<html data-theme="dark">
  <body>
    <div class="bg-white dark:bg-black">
      Uses data-theme attribute
    </div>
  </body>
</html>
```

## State Variants

### Interactive States

```html
<!-- Hover, focus, active states -->
<button class="
  bg-blue-500
  hover:bg-blue-600
  focus:bg-blue-700
  active:bg-blue-800
  focus:outline-2
  focus:outline-offset-2
  focus:outline-blue-500
">
  Interactive button
</button>

<!-- Disabled state -->
<button class="
  bg-blue-500
  disabled:opacity-50
  disabled:cursor-not-allowed
" disabled>
  Disabled button
</button>

<!-- Focus within -->
<div class="border-2 border-transparent focus-within:border-blue-500">
  <input class="outline-none" placeholder="Focus container changes" />
</div>
```

### Form States

```html
<!-- Input states -->
<input class="
  border
  border-gray-300
  focus:border-blue-500
  focus:ring-2
  focus:ring-blue-200
  invalid:border-red-500
  placeholder:text-gray-400
" />

<!-- Checkbox and radio -->
<input type="checkbox" class="
  checked:bg-blue-500
  indeterminate:bg-gray-500
" />

<!-- File input -->
<input type="file" class="
  file:mr-4
  file:rounded-full
  file:border-0
  file:bg-violet-50
  file:px-4
  file:py-2
  file:text-sm
  file:font-semibold
  hover:file:bg-violet-100
" />
```

### Pseudo-Classes and Pseudo-Elements

```html
<!-- First, last, odd, even -->
<ul>
  <li class="first:font-bold">First item is bold</li>
  <li class="even:bg-gray-100">Even items have background</li>
  <li class="last:border-b-0">Last item has no border</li>
</ul>

<!-- Before and after -->
<div class="
  before:content-['→']
  before:mr-2
  after:content-['←']
  after:ml-2
">
  Content with decorations
</div>

<!-- Group hover -->
<div class="group">
  <img class="group-hover:opacity-75" src="..." />
  <p class="group-hover:text-blue-600">Hover parent to affect children</p>
</div>

<!-- Peer state -->
<input type="checkbox" class="peer" id="toggle" />
<label class="peer-checked:text-blue-600" for="toggle">
  Changes when checkbox is checked
</label>
```

### Media Query Variants

```html
<!-- Motion preferences -->
<button class="
  transition
  hover:-translate-y-1
  motion-reduce:transition-none
  motion-reduce:hover:translate-y-0
">
  Respects user motion preference
</button>

<!-- Contrast preferences -->
<label>
  <input class="contrast-more:border-gray-400" />
  <p class="opacity-75 contrast-more:opacity-100">
    Adjusts for contrast needs
  </p>
</label>

<!-- Print styles -->
<article class="print:hidden">Not shown when printing</article>
<div class="hidden print:block">Only visible in print</div>

<!-- Orientation -->
<div class="portrait:hidden">Hidden in portrait mode</div>
<div class="landscape:grid-cols-2">Adapts to orientation</div>
```

## Component Extraction Patterns

### When to Extract Components

Extract components when:

1. **Repeated Patterns**: Same utility combinations used multiple times
2. **Semantic Meaning**: Pattern represents a specific UI element (button, card)
3. **Team Communication**: Need to share consistent components
4. **Maintenance**: Changes should propagate to all instances

### Framework Component Extraction

#### React Components

```jsx
// Button.jsx - Reusable component with variants
export function Button({ size = 'md', variant = 'primary', children, ...props }) {
  const baseStyles = "font-bold rounded transition focus:outline-2 focus:outline-offset-2";

  const sizeStyles = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-5 py-3 text-lg"
  };

  const variantStyles = {
    primary: "bg-blue-500 text-white hover:bg-blue-600 focus:outline-blue-500",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300 focus:outline-gray-500",
    danger: "bg-red-500 text-white hover:bg-red-600 focus:outline-red-500"
  };

  return (
    <button
      className={`${baseStyles} ${sizeStyles[size]} ${variantStyles[variant]}`}
      {...props}
    >
      {children}
    </button>
  );
}

// Usage
<Button size="lg" variant="primary">Save Changes</Button>
<Button size="sm" variant="danger">Delete</Button>
```

#### Vue Components

```vue
<!-- Card.vue -->
<template>
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
    <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
      {{ title }}
    </h3>
    <p class="text-gray-600 dark:text-gray-400">
      <slot />
    </p>
  </div>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      required: true
    }
  }
}
</script>

<!-- Usage -->
<Card title="Feature Title">
  This is the card content that adapts to dark mode.
</Card>
```

#### Svelte Components

```svelte
<!-- Alert.svelte -->
<script>
  export let type = 'info'; // info, success, warning, error

  const styles = {
    info: 'bg-blue-50 border-blue-200 text-blue-800',
    success: 'bg-green-50 border-green-200 text-green-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    error: 'bg-red-50 border-red-200 text-red-800'
  };
</script>

<div class="border-l-4 p-4 {styles[type]}" role="alert">
  <slot />
</div>

<!-- Usage -->
<Alert type="success">
  Your changes have been saved successfully!
</Alert>
```

### CSS Component Classes

For non-component frameworks or shared styles:

```css
/* app.css */
@import "tailwindcss";

/* Component layer for reusable patterns */
@layer components {
  .btn {
    @apply font-bold py-2 px-4 rounded transition;
  }

  .btn-primary {
    @apply bg-blue-500 text-white;
    @apply hover:bg-blue-600;
    @apply focus:outline-2 focus:outline-offset-2 focus:outline-blue-500;
  }

  .btn-secondary {
    @apply bg-gray-200 text-gray-900;
    @apply hover:bg-gray-300;
  }

  .card {
    @apply bg-white rounded-lg shadow-xl p-6;
    @apply dark:bg-gray-800;
  }

  .input-field {
    @apply border border-gray-300 rounded px-3 py-2;
    @apply focus:border-blue-500 focus:ring-2 focus:ring-blue-200;
    @apply dark:bg-gray-700 dark:border-gray-600;
  }
}
```

```html
<!-- Using component classes -->
<button class="btn btn-primary">Primary Action</button>
<div class="card">
  <h3>Card Title</h3>
  <p>Card content</p>
</div>
<input class="input-field" placeholder="Enter text..." />
```

## Theme Customization

### Extending the Theme

```css
/* app.css */
@import "tailwindcss";

@theme {
  /* Custom colors */
  --color-primary: #6366f1;
  --color-secondary: #8b5cf6;
  --color-brand-blue: #3b82f6;
  --color-brand-purple: #a855f7;

  /* Custom spacing */
  --spacing-18: 4.5rem;
  --spacing-72: 18rem;

  /* Custom breakpoints */
  --breakpoint-xs: 30rem;
  --breakpoint-3xl: 120rem;

  /* Custom fonts */
  --font-display: "Montserrat", sans-serif;
  --font-body: "Inter", sans-serif;

  /* Custom shadows */
  --shadow-glow: 0 0 20px rgba(99, 102, 241, 0.5);

  /* Custom border radius */
  --radius-4xl: 2rem;

  /* Custom z-index */
  --z-index-dropdown: 1000;
  --z-index-modal: 2000;
}
```

```html
<!-- Using custom theme values -->
<div class="bg-primary text-white">Primary color</div>
<div class="font-display text-4xl">Display font</div>
<div class="shadow-glow rounded-4xl">Custom shadow and radius</div>
<div class="xs:grid-cols-2 3xl:grid-cols-6">Custom breakpoints</div>
```

### Using CSS Variables

```css
/* Dynamic theming with CSS variables */
@import "tailwindcss";

@theme {
  --color-primary-50: oklch(0.95 0.02 250);
  --color-primary-100: oklch(0.90 0.04 250);
  --color-primary-200: oklch(0.85 0.08 250);
  --color-primary-500: oklch(0.55 0.22 250);
  --color-primary-900: oklch(0.25 0.15 250);
}
```

```html
<!-- Arbitrary values with CSS variables -->
<div class="bg-[var(--color-primary-500)]">
  Using CSS variable
</div>

<!-- Setting CSS variables inline -->
<div class="[--spacing:1rem] lg:[--spacing:2rem]">
  <div class="p-[var(--spacing)]">
    Responsive custom property
  </div>
</div>
```

## Custom Utilities

### Simple Custom Utilities

```css
/* app.css */
@import "tailwindcss";

/* Simple utility */
@utility content-auto {
  content-visibility: auto;
}

/* Complex utility with nesting */
@utility scrollbar-hidden {
  &::-webkit-scrollbar {
    display: none;
  }
  scrollbar-width: none;
}
```

```html
<!-- Using custom utilities -->
<div class="content-auto hover:content-auto">
  Supports all variants automatically
</div>

<div class="scrollbar-hidden">
  Hidden scrollbar
</div>
```

### Functional Custom Utilities

```css
/* app.css */
@import "tailwindcss";

/* Define theme values */
@theme {
  --tab-size-2: 2;
  --tab-size-4: 4;
  --tab-size-8: 8;
}

/* Functional utility accepting arguments */
@utility tab-* {
  tab-size: --value(--tab-size-*);
}

/* Utility with modifiers */
@utility text-* {
  font-size: --value(--text-*, [length]);
  line-height: --modifier(--leading-*, [length], [*]);
}

/* Supporting arbitrary values */
@utility opacity-* {
  opacity: --value([percentage]);
  opacity: calc(--value(integer) * 1%);
  opacity: --value(--opacity-*);
}
```

```html
<!-- Using functional utilities -->
<div class="tab-4">Tab size 4</div>
<div class="tab-[12]">Arbitrary tab size</div>

<p class="text-2xl/relaxed">Font size with line height modifier</p>

<div class="opacity-50">50% opacity from theme</div>
<div class="opacity-[0.35]">Arbitrary opacity</div>
```

## Production Optimization

### Build Configuration

```javascript
// vite.config.ts
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  build: {
    minify: 'terser',
    cssMinify: true,
  }
})
```

### Content Configuration

Ensure Tailwind scans all files:

```css
/* app.css */
@import "tailwindcss";

@source "../../**/*.{html,js,jsx,ts,tsx,vue,svelte}";
```

### Performance Best Practices

1. **Use JIT Mode** (enabled by default in v4)
   - Only generates CSS for classes you use
   - Fast build times
   - Smaller file sizes

2. **Minimize Arbitrary Values**
   - Use theme values when possible
   - Arbitrary values prevent reuse and increase CSS size

3. **Avoid Deep Nesting**
   - Keep utility combinations reasonable
   - Extract components for complex patterns

4. **Optimize Images**
   ```html
   <img
     class="w-full h-auto"
     src="/image.jpg"
     loading="lazy"
     decoding="async"
   />
   ```

5. **Use CSS Containment**
   ```html
   <div class="content-auto">
     Browser can optimize rendering
   </div>
   ```

### Production Build Checklist

- [ ] Enable CSS minification
- [ ] Configure content sources correctly
- [ ] Remove unused custom utilities
- [ ] Optimize image assets
- [ ] Test dark mode variants
- [ ] Verify responsive breakpoints
- [ ] Check accessibility (contrast, focus states)
- [ ] Test performance (Lighthouse scores)

## Plugins and Extensions

### Official Plugins

#### Typography Plugin
```bash
npm install @tailwindcss/typography
```

```html
<!-- Beautiful typography for markdown/CMS content -->
<article class="prose lg:prose-xl dark:prose-invert">
  <h1>Article Title</h1>
  <p>Automatically styled content with sensible defaults.</p>
</article>
```

#### Forms Plugin
```bash
npm install @tailwindcss/forms
```

```html
<!-- Better default form styles -->
<form class="space-y-4">
  <input type="text" class="form-input rounded-md" />
  <select class="form-select rounded-md"></select>
  <textarea class="form-textarea rounded-md"></textarea>
</form>
```

#### Container Queries Plugin
```bash
npm install @tailwindcss/container-queries
```

```html
<div class="@container">
  <div class="@lg:grid-cols-3">
    Responds to container, not viewport
  </div>
</div>
```

## Framework Integration

### React / Next.js

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

export default {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
} satisfies Config
```

```jsx
// Component with Tailwind
export default function Hero() {
  return (
    <section className="bg-gradient-to-r from-blue-500 to-purple-600 text-white py-20">
      <div className="container mx-auto px-4">
        <h1 className="text-5xl font-bold mb-4">Welcome</h1>
        <p className="text-xl">Beautiful UI with Tailwind CSS</p>
      </div>
    </section>
  )
}
```

### Vue / Nuxt

```typescript
// nuxt.config.ts
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  vite: {
    plugins: [tailwindcss()],
  },
})
```

### Svelte / SvelteKit

```typescript
// vite.config.ts
import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';

export default {
  plugins: [tailwindcss(), sveltekit()],
};
```

## Best Practices

### Naming and Organization

1. **Use Semantic HTML**
   ```html
   <!-- Good -->
   <article class="bg-white rounded-lg p-6">
     <h2 class="text-2xl font-bold">Title</h2>
   </article>

   <!-- Avoid -->
   <div class="bg-white rounded-lg p-6">
     <div class="text-2xl font-bold">Title</div>
   </div>
   ```

2. **Order Utilities Consistently**
   ```html
   <!-- Suggested order: layout → spacing → sizing → typography → visual → misc -->
   <div class="
     flex items-center justify-between
     p-4 mx-auto
     w-full max-w-4xl
     text-lg font-semibold
     bg-white rounded-lg shadow-md
     hover:shadow-lg transition
   ">
   ```

3. **Extract Repeated Patterns**
   ```jsx
   // Don't repeat long class strings
   const cardClasses = "bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6";

   <div className={cardClasses}>Card 1</div>
   <div className={cardClasses}>Card 2</div>
   ```

### Accessibility

```html
<!-- Focus states -->
<button class="focus:outline-2 focus:outline-offset-2 focus:outline-blue-500">
  Accessible button
</button>

<!-- Screen reader only -->
<span class="sr-only">Additional context for screen readers</span>

<!-- High contrast mode -->
<div class="border border-gray-300 forced-colors:border-current">
  Adapts to forced colors mode
</div>

<!-- Reduced motion -->
<div class="transition-transform motion-reduce:transition-none">
  Respects prefers-reduced-motion
</div>
```

### Performance

1. **Avoid Inline Styles for Dynamic Values**
   ```jsx
   // Good - use CSS variables
   <button
     style={{ backgroundColor: buttonColor }}
     className="rounded-md px-3 py-1.5"
   >

   // Avoid - generates unique CSS for each color
   <button className={`bg-[${buttonColor}]`}>
   ```

2. **Leverage Purging**
   - Ensure content paths are correct
   - Remove unused custom utilities
   - Test production builds

3. **Optimize for First Paint**
   ```html
   <!-- Inline critical CSS in <head> -->
   <style>
     .hero { /* Critical above-fold styles */ }
   </style>
   ```

## Common Patterns

### Navigation Bar

```html
<nav class="bg-white dark:bg-gray-900 shadow-lg">
  <div class="container mx-auto px-4">
    <div class="flex items-center justify-between h-16">
      <!-- Logo -->
      <div class="flex items-center">
        <img class="h-8 w-auto" src="/logo.svg" alt="Logo" />
      </div>

      <!-- Desktop Navigation -->
      <div class="hidden md:flex items-center space-x-8">
        <a href="#" class="text-gray-900 dark:text-white hover:text-blue-600">Home</a>
        <a href="#" class="text-gray-900 dark:text-white hover:text-blue-600">About</a>
        <a href="#" class="text-gray-900 dark:text-white hover:text-blue-600">Contact</a>
      </div>

      <!-- Mobile menu button -->
      <button class="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800">
        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
    </div>
  </div>
</nav>
```

### Hero Section

```html
<section class="relative bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20 lg:py-32">
  <div class="container mx-auto px-4">
    <div class="max-w-3xl mx-auto text-center">
      <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold mb-6">
        Build Amazing Websites
      </h1>
      <p class="text-xl md:text-2xl mb-8 text-blue-100">
        Create beautiful, responsive designs with Tailwind CSS
      </p>
      <div class="flex flex-col sm:flex-row gap-4 justify-center">
        <button class="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition">
          Get Started
        </button>
        <button class="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition">
          Learn More
        </button>
      </div>
    </div>
  </div>
</section>
```

### Feature Grid

```html
<section class="py-16 bg-gray-50 dark:bg-gray-900">
  <div class="container mx-auto px-4">
    <h2 class="text-3xl font-bold text-center mb-12 text-gray-900 dark:text-white">
      Our Features
    </h2>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <!-- Feature Card -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition">
        <div class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center mb-4">
          <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold mb-2 text-gray-900 dark:text-white">
          Lightning Fast
        </h3>
        <p class="text-gray-600 dark:text-gray-400">
          Build and ship faster with utility-first CSS approach.
        </p>
      </div>

      <!-- More feature cards... -->
    </div>
  </div>
</section>
```

## Troubleshooting

### Common Issues

**Styles not applying**
- Check content configuration in CSS
- Ensure classes are written correctly (no typos)
- Verify build process is running
- Check for CSS specificity conflicts

**Dark mode not working**
- Verify dark variant configuration
- Check if dark class is applied to HTML element
- Ensure localStorage logic is correct
- Test system preference detection

**Responsive classes not working**
- Verify breakpoint configuration
- Check mobile-first approach (base → larger)
- Ensure viewport meta tag is present
- Test in actual devices/browser dev tools

**Build is slow**
- Use JIT mode (default in v4)
- Optimize content paths
- Remove unnecessary dependencies
- Check for circular imports

**File size too large**
- Configure content paths correctly
- Remove unused custom utilities
- Enable CSS minification
- Audit third-party dependencies

## Resources

- Official Documentation: https://tailwindcss.com
- Tailwind UI Components: https://tailwindui.com
- Headless UI: https://headlessui.com
- Tailwind Play (Online Editor): https://play.tailwindcss.com
- GitHub Repository: https://github.com/tailwindlabs/tailwindcss
- Community Discord: https://tailwindcss.com/discord
- YouTube Channel: https://www.youtube.com/tailwindlabs

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: CSS Framework, UI Development, Design Systems
**Compatible With**: React, Vue, Svelte, Next.js, Nuxt, SvelteKit, Astro, and vanilla HTML
