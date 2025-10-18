# Tailwind CSS Skill

Master the utility-first CSS framework for rapidly building modern user interfaces.

## Quick Start

### Installation

#### With Vite (Recommended)

```bash
# Create new project
npm create vite@latest my-project
cd my-project

# Install Tailwind CSS
npm install tailwindcss @tailwindcss/vite
```

```javascript
// vite.config.ts
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [tailwindcss()],
})
```

```css
/* src/style.css */
@import "tailwindcss";
```

```html
<!-- index.html -->
<!doctype html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="/src/style.css" rel="stylesheet">
</head>
<body>
  <h1 class="text-3xl font-bold underline">
    Hello, Tailwind CSS!
  </h1>
</body>
</html>
```

#### With CLI (No Build Tool)

```bash
# Install Tailwind CLI
npm install -D @tailwindcss/cli

# Create your CSS file
echo '@import "tailwindcss";' > src/input.css

# Start build process with watch mode
npx @tailwindcss/cli -i ./src/input.css -o ./src/output.css --watch
```

```html
<!-- Link compiled CSS in HTML -->
<link href="/src/output.css" rel="stylesheet">
```

### Framework-Specific Setup

#### Next.js

```bash
# Install dependencies
npm install tailwindcss @tailwindcss/vite
```

```css
/* app/globals.css */
@import "tailwindcss";
```

```javascript
// next.config.js
import tailwindcss from '@tailwindcss/vite'

export default {
  experimental: {
    vite: {
      plugins: [tailwindcss()],
    },
  },
}
```

#### React (Vite)

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [tailwindcss(), react()],
})
```

#### Vue / Nuxt

```typescript
// nuxt.config.ts
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  vite: {
    plugins: [tailwindcss()],
  },
})
```

#### Svelte / SvelteKit

```typescript
// vite.config.ts
import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';

export default {
  plugins: [tailwindcss(), sveltekit()],
};
```

#### Astro

```javascript
// astro.config.mjs
import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  vite: {
    plugins: [tailwindcss()]
  }
});
```

## Core Concepts

### Utility-First Approach

Instead of writing custom CSS, compose utilities in your HTML:

```html
<!-- Traditional CSS approach -->
<style>
  .button {
    background-color: blue;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 0.25rem;
  }
  .button:hover {
    background-color: darkblue;
  }
</style>
<button class="button">Click me</button>

<!-- Tailwind utility-first approach -->
<button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
  Click me
</button>
```

### Responsive Design

Mobile-first responsive design with breakpoint prefixes:

```html
<!-- Stack on mobile, horizontal on tablet, 3 columns on desktop -->
<div class="flex flex-col md:flex-row lg:grid lg:grid-cols-3 gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

### State Variants

Apply styles for different states:

```html
<button class="
  bg-blue-500 text-white
  hover:bg-blue-600
  focus:outline-2 focus:outline-blue-400
  active:bg-blue-700
  disabled:opacity-50
">
  Interactive Button
</button>
```

### Dark Mode

Automatic or manual dark mode support:

```html
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  <p class="text-gray-600 dark:text-gray-400">
    Content that adapts to dark mode
  </p>
</div>
```

## Common Utilities Reference

### Layout

```html
<!-- Flexbox -->
<div class="flex items-center justify-between">...</div>

<!-- Grid -->
<div class="grid grid-cols-3 gap-4">...</div>

<!-- Positioning -->
<div class="relative">
  <div class="absolute top-0 right-0">...</div>
</div>
```

### Spacing

```html
<!-- Padding and margin -->
<div class="p-4 m-2">All sides</div>
<div class="px-4 py-2">Horizontal and vertical</div>
<div class="pt-8 pb-4 pl-6 pr-2">Individual sides</div>

<!-- Negative margins -->
<div class="-mt-4">Negative margin top</div>

<!-- Space between -->
<div class="flex space-x-4">Horizontal spacing</div>
```

### Typography

```html
<!-- Font sizes -->
<p class="text-sm">Small text (0.875rem)</p>
<p class="text-base">Base text (1rem)</p>
<h1 class="text-4xl">Large heading (2.25rem)</h1>

<!-- Font weights -->
<p class="font-normal">Normal (400)</p>
<p class="font-semibold">Semibold (600)</p>
<p class="font-bold">Bold (700)</p>

<!-- Text colors -->
<p class="text-gray-900 dark:text-white">Primary text</p>
<p class="text-gray-600 dark:text-gray-400">Secondary text</p>
```

### Colors

```html
<!-- Background -->
<div class="bg-blue-500">Solid background</div>
<div class="bg-blue-500/50">50% opacity</div>

<!-- Gradients -->
<div class="bg-gradient-to-r from-purple-500 to-pink-500">
  Gradient background
</div>

<!-- Borders -->
<div class="border border-gray-300">Default border</div>
<div class="border-2 border-blue-500">Thick blue border</div>
```

### Effects

```html
<!-- Shadows -->
<div class="shadow-md">Medium shadow</div>
<div class="shadow-lg">Large shadow</div>

<!-- Rounded corners -->
<div class="rounded">0.25rem radius</div>
<div class="rounded-lg">0.5rem radius</div>
<div class="rounded-full">Full circle/pill</div>

<!-- Opacity -->
<div class="opacity-50">50% opacity</div>
<div class="opacity-0 hover:opacity-100">Fade in on hover</div>
```

## Configuration

### Custom Theme

```css
/* app.css */
@import "tailwindcss";

@theme {
  /* Custom colors */
  --color-primary: #6366f1;
  --color-secondary: #8b5cf6;

  /* Custom spacing */
  --spacing-18: 4.5rem;

  /* Custom fonts */
  --font-display: "Montserrat", sans-serif;

  /* Custom breakpoints */
  --breakpoint-xs: 30rem;
  --breakpoint-3xl: 120rem;
}
```

### Custom Utilities

```css
/* app.css */
@import "tailwindcss";

@utility content-auto {
  content-visibility: auto;
}

@utility scrollbar-hidden {
  &::-webkit-scrollbar {
    display: none;
  }
}
```

## Best Practices

### 1. Follow Mobile-First

Start with mobile styles, add breakpoints for larger screens:

```html
<!-- Good: Mobile-first -->
<div class="w-full md:w-1/2 lg:w-1/3">

<!-- Avoid: Desktop-first -->
<div class="lg:w-1/3 md:w-1/2 w-full">
```

### 2. Extract Components

For repeated patterns, create reusable components:

```jsx
// React component
function Button({ children, variant = 'primary' }) {
  const variants = {
    primary: 'bg-blue-500 hover:bg-blue-600',
    secondary: 'bg-gray-200 hover:bg-gray-300'
  }

  return (
    <button className={`px-4 py-2 rounded ${variants[variant]}`}>
      {children}
    </button>
  )
}
```

### 3. Use Semantic HTML

Always use appropriate HTML elements:

```html
<!-- Good -->
<article class="bg-white rounded-lg p-6">
  <h2 class="text-2xl font-bold">Title</h2>
  <p class="text-gray-600">Content</p>
</article>

<!-- Avoid -->
<div class="bg-white rounded-lg p-6">
  <div class="text-2xl font-bold">Title</div>
  <div class="text-gray-600">Content</div>
</div>
```

### 4. Maintain Accessibility

Always include focus states and ARIA attributes:

```html
<button
  class="focus:outline-2 focus:outline-offset-2 focus:outline-blue-500"
  aria-label="Close dialog"
>
  <span class="sr-only">Close</span>
  <svg>...</svg>
</button>
```

### 5. Optimize for Production

- Configure content paths correctly
- Enable CSS minification
- Use JIT mode (default in v4)
- Remove unused custom utilities

## Common Patterns

See [EXAMPLES.md](./EXAMPLES.md) for complete component examples including:

- Navigation bars
- Hero sections
- Feature grids
- Cards
- Forms
- Modals
- Dropdowns
- And more...

## Troubleshooting

### Styles Not Applying

1. Check content configuration in CSS
2. Verify build process is running
3. Ensure no typos in class names
4. Check browser console for errors

### Dark Mode Not Working

1. Verify dark variant configuration
2. Check if dark class is applied to `<html>`
3. Test system preference detection
4. Ensure dark styles are defined

### Build Performance

1. Use JIT mode (default)
2. Optimize content paths
3. Remove unused dependencies
4. Enable caching

## Resources

- **Official Docs**: https://tailwindcss.com
- **Component Library**: https://tailwindui.com
- **Play CDN**: https://play.tailwindcss.com
- **GitHub**: https://github.com/tailwindlabs/tailwindcss
- **Discord Community**: https://tailwindcss.com/discord

## Learning Path

1. Start with **SKILL.md** for comprehensive concepts
2. Review **EXAMPLES.md** for practical component patterns
3. Build real projects to practice
4. Explore official plugins for advanced features
5. Customize theme for your brand
6. Optimize for production

## Support

For issues or questions:

1. Check the [official documentation](https://tailwindcss.com)
2. Search [GitHub issues](https://github.com/tailwindlabs/tailwindcss/issues)
3. Ask in [Discord community](https://tailwindcss.com/discord)
4. Review this skill's comprehensive guides

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained by**: Tailwind Labs
