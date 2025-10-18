# Next.js Development Skill

A comprehensive skill for building modern full-stack applications with Next.js App Router, Server Components, and advanced routing patterns.

## Overview

This skill provides complete guidance for Next.js development using the latest App Router architecture. It covers server and client components, data fetching patterns, routing strategies, API development, middleware, and production-ready optimization techniques.

## What is Next.js?

Next.js is a React framework for building full-stack web applications. It provides:

- **Server-Side Rendering (SSR)**: Pre-render pages on each request
- **Static Site Generation (SSG)**: Generate HTML at build time
- **Incremental Static Regeneration (ISR)**: Update static content after build
- **API Routes**: Build backend API endpoints
- **File-based Routing**: Automatic routing based on file structure
- **Automatic Optimization**: Images, fonts, scripts automatically optimized
- **Edge Computing**: Deploy serverless functions globally

## Key Features

### App Router

The App Router is Next.js's modern routing system built on React Server Components:

- File-based routing in the `app` directory
- Nested layouts that preserve state
- Loading UI with React Suspense
- Error boundaries for error handling
- Parallel and intercepting routes
- Route groups for organization

### Server Components

Server Components render on the server by default:

- Zero JavaScript sent to the client
- Direct access to backend resources (databases, APIs)
- Better performance and smaller bundle sizes
- Automatic code splitting
- SEO-friendly content

### Data Fetching

Extended fetch API with powerful caching:

- **Static**: `cache: 'force-cache'` - Generate at build time
- **Dynamic**: `cache: 'no-store'` - Fetch on every request
- **Revalidation**: `revalidate: 60` - Update periodically
- Parallel and sequential fetching patterns
- Automatic request deduplication

## Getting Started

### Installation

```bash
npx create-next-app@latest my-app
cd my-app
npm run dev
```

### Project Structure

```
my-app/
├── app/                    # App Router directory
│   ├── layout.tsx          # Root layout (required)
│   ├── page.tsx            # Home page
│   ├── loading.tsx         # Loading UI
│   ├── error.tsx           # Error UI
│   ├── not-found.tsx       # 404 page
│   └── api/                # API routes
│       └── hello/
│           └── route.ts
├── public/                 # Static files
│   ├── images/
│   └── fonts/
├── components/             # React components
├── lib/                    # Utility functions
├── styles/                 # CSS files
├── next.config.js          # Next.js configuration
├── package.json
└── tsconfig.json
```

### Basic Page

```tsx
// app/page.tsx
export default function HomePage() {
  return (
    <main>
      <h1>Welcome to Next.js</h1>
      <p>Start building your application</p>
    </main>
  )
}
```

### Root Layout

```tsx
// app/layout.tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
```

## Core Concepts

### Server vs Client Components

**Server Component (Default):**
```tsx
// No 'use client' directive
async function getData() {
  const res = await fetch('https://api.example.com/data')
  return res.json()
}

export default async function Page() {
  const data = await getData()
  return <div>{data.title}</div>
}
```

**Client Component:**
```tsx
'use client'

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

### Dynamic Routes

```tsx
// app/blog/[slug]/page.tsx
export default function BlogPost({ params }: { params: { slug: string } }) {
  return <h1>Post: {params.slug}</h1>
}

// Generate static pages at build time
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())
  return posts.map((post) => ({ slug: post.slug }))
}
```

### API Routes

```tsx
// app/api/users/route.ts
export async function GET(request: Request) {
  const users = await db.user.findMany()
  return Response.json(users)
}

export async function POST(request: Request) {
  const body = await request.json()
  const user = await db.user.create({ data: body })
  return Response.json(user, { status: 201 })
}
```

### Metadata

```tsx
// app/about/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn more about our company',
}

export default function AboutPage() {
  return <h1>About Us</h1>
}
```

## Common Use Cases

### 1. Blog or Content Site

- Static generation for blog posts
- Dynamic metadata for SEO
- Image optimization for fast loading
- Incremental Static Regeneration for updates

### 2. E-commerce

- Product catalog with filtering
- Shopping cart with client-side state
- Checkout with server actions
- Order management API

### 3. Dashboard Application

- Protected routes with middleware
- Real-time data with streaming
- Complex layouts with nested routes
- API integration

### 4. Marketing Website

- Fully static pages for performance
- SEO optimization with metadata
- Image and font optimization
- Fast page transitions

### 5. SaaS Application

- Authentication and authorization
- Database integration
- Server actions for mutations
- API routes for external integrations

## Performance Optimization

### Image Optimization

```tsx
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1920}
  height={1080}
  priority
/>
```

### Font Optimization

```tsx
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export default function RootLayout({ children }) {
  return (
    <html className={inter.className}>
      <body>{children}</body>
    </html>
  )
}
```

### Code Splitting

```tsx
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  )
}
```

### Caching Strategies

```tsx
// Static - cached indefinitely
fetch('https://api.example.com/data', { cache: 'force-cache' })

// Dynamic - never cached
fetch('https://api.example.com/data', { cache: 'no-store' })

// Revalidate - cached with time-based revalidation
fetch('https://api.example.com/data', { next: { revalidate: 3600 } })
```

## Deployment

### Vercel (Recommended)

```bash
npm install -g vercel
vercel
```

### Other Platforms

Next.js can be deployed to:
- AWS (Amplify, ECS, Lambda)
- Google Cloud Platform
- Azure
- DigitalOcean
- Self-hosted (Docker, Node.js)

### Build for Production

```bash
npm run build
npm run start
```

## Configuration

### next.config.js

```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
  },
  experimental: {
    serverActions: true,
  },
}

module.exports = nextConfig
```

### Environment Variables

```bash
# .env.local
DATABASE_URL="postgresql://..."
API_KEY="your-api-key"
NEXT_PUBLIC_ANALYTICS_ID="your-analytics-id"
```

Access in code:
```tsx
// Server components and API routes
const dbUrl = process.env.DATABASE_URL

// Client components (must start with NEXT_PUBLIC_)
const analyticsId = process.env.NEXT_PUBLIC_ANALYTICS_ID
```

## Best Practices

1. **Use Server Components by Default**: Only use Client Components when needed (interactivity, hooks, browser APIs)

2. **Fetch Data Where Needed**: Don't prop-drill data from parent to child components

3. **Parallel Fetching**: Use `Promise.all()` to fetch multiple data sources simultaneously

4. **Optimize Images**: Always use the `Image` component from `next/image`

5. **Implement Error Boundaries**: Add `error.tsx` files for graceful error handling

6. **Add Loading States**: Use `loading.tsx` files for better user experience

7. **Use Metadata API**: Define SEO metadata for every page

8. **Implement Middleware**: Use middleware for authentication, redirects, and common logic

9. **Type Safety**: Use TypeScript for better development experience

10. **Environment Variables**: Keep secrets in `.env.local` and never commit them

## Troubleshooting

### Common Issues

#### Error: "You're importing a component that needs useState"

**Problem**: Using hooks in a Server Component

**Solution**: Add `'use client'` directive at the top of the file:
```tsx
'use client'

import { useState } from 'react'
```

#### Error: "Hydration mismatch"

**Problem**: Server and client HTML don't match

**Solutions**:
- Don't use browser-only APIs during initial render
- Use `useEffect` for client-only code
- Check for conditional rendering based on `window`

```tsx
'use client'

import { useEffect, useState } from 'react'

export default function Component() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) return null

  return <div>{window.innerWidth}</div>
}
```

#### Error: "Module not found" after adding dependency

**Problem**: Package not installed or needs restart

**Solution**:
```bash
# Install the package
npm install package-name

# Restart dev server
npm run dev
```

#### Slow Build Times

**Solutions**:
- Enable SWC minifier (default in Next.js 13+)
- Use dynamic imports for large components
- Optimize images before adding to project
- Remove unused dependencies
- Consider incremental static regeneration instead of full static generation

```js
// next.config.js
module.exports = {
  swcMinify: true,
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
}
```

#### API Route Not Working

**Checklist**:
- File is in `app/api/` directory
- File is named `route.ts` or `route.js`
- Exported function name matches HTTP method (GET, POST, etc.)
- Response is returned using `Response` or `NextResponse`

```tsx
// ✅ Correct
export async function GET() {
  return Response.json({ message: 'Hello' })
}

// ❌ Incorrect - not exported
async function GET() {
  return Response.json({ message: 'Hello' })
}
```

#### Environment Variables Not Working

**Common Mistakes**:
- Not prefixing client-side variables with `NEXT_PUBLIC_`
- Not restarting dev server after changing `.env.local`
- Committing `.env.local` to git (should be in `.gitignore`)

**Solution**:
```bash
# Server-side only
DATABASE_URL=...

# Client and server-side
NEXT_PUBLIC_API_URL=...
```

#### Images Not Optimizing

**Checklist**:
- Using `next/image` component (not `<img>`)
- Width and height specified
- Remote images configured in `next.config.js`

```js
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
      },
    ],
  },
}
```

## Learning Resources

- **Official Docs**: https://nextjs.org/docs
- **Learn Next.js**: https://nextjs.org/learn
- **Examples**: https://github.com/vercel/next.js/tree/canary/examples
- **Community**: https://github.com/vercel/next.js/discussions

## Related Skills

- **react-development**: Core React concepts and hooks
- **typescript**: Type safety for Next.js applications
- **tailwind-css**: Utility-first CSS framework
- **prisma**: Database ORM for Next.js applications

## Version

This skill is based on Next.js 13+ with App Router. The patterns and examples follow the latest Next.js best practices and official documentation.

## License

This skill documentation is part of the Claude Code skill system and follows the same licensing as the Claude Code project.
