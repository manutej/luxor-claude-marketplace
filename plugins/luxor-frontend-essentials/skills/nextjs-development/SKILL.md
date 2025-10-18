---
name: nextjs-development
description: Comprehensive Next.js development skill covering App Router, Server Components, data fetching, routing patterns, API routes, middleware, and full-stack Next.js applications
category: frontend
tags: [nextjs, react, app-router, server-components, data-fetching, routing, api-routes, middleware, full-stack]
version: 1.0.0
context7_library: /vercel/next.js
context7_trust_score: 10
---

# Next.js Development Skill

This skill provides comprehensive guidance for building modern Next.js applications using the App Router, Server Components, data fetching patterns, routing, API routes, middleware, and full-stack development techniques based on official Next.js documentation.

## When to Use This Skill

Use this skill when:
- Building full-stack React applications with server-side rendering (SSR)
- Creating static sites with incremental static regeneration (ISR)
- Developing modern web applications with React Server Components
- Building API backends with serverless route handlers
- Implementing SEO-optimized applications with metadata and Open Graph
- Creating production-ready web applications with built-in optimization
- Building e-commerce, blogs, dashboards, or content-driven sites
- Implementing authentication, data fetching, and complex routing patterns
- Optimizing images, fonts, and performance automatically
- Deploying serverless applications with edge computing capabilities

## Core Concepts

### App Router

The App Router is Next.js's modern routing system built on React Server Components. It uses the `app` directory for file-based routing with enhanced features.

**Basic App Structure:**
```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Home page
├── loading.tsx         # Loading UI
├── error.tsx           # Error UI
├── not-found.tsx       # 404 page
├── about/
│   └── page.tsx        # /about route
└── blog/
    ├── page.tsx        # /blog route
    ├── [slug]/
    │   └── page.tsx    # /blog/[slug] dynamic route
    └── layout.tsx      # Blog layout
```

**Root Layout (Required):**
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

**Page Component:**
```tsx
// app/page.tsx
export default function HomePage() {
  return (
    <main>
      <h1>Welcome to Next.js</h1>
      <p>Building modern web applications</p>
    </main>
  )
}
```

### Server Components

Server Components are React components that render on the server. They are the default in the App Router and provide better performance.

**Server Component (Default):**
```tsx
// app/posts/page.tsx
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    cache: 'force-cache' // Static generation
  })
  return res.json()
}

export default async function PostsPage() {
  const posts = await getPosts()

  return (
    <div>
      <h1>Blog Posts</h1>
      {posts.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  )
}
```

**Client Component (When Needed):**
```tsx
'use client'

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  )
}
```

**Mixing Server and Client Components:**
```tsx
// app/dashboard/page.tsx (Server Component)
import ClientCounter from './ClientCounter'

async function getData() {
  const res = await fetch('https://api.example.com/data')
  return res.json()
}

export default async function DashboardPage() {
  const data = await getData()

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Server data: {data.value}</p>
      {/* Client component for interactivity */}
      <ClientCounter />
    </div>
  )
}
```

### Data Fetching

Next.js extends the native `fetch()` API with automatic caching and revalidation.

**Static Data Fetching (Default):**
```tsx
async function getStaticData() {
  const res = await fetch('https://api.example.com/data', {
    cache: 'force-cache' // Default, equivalent to getStaticProps
  })
  return res.json()
}

export default async function Page() {
  const data = await getStaticData()
  return <div>{data.title}</div>
}
```

**Dynamic Data Fetching:**
```tsx
async function getDynamicData() {
  const res = await fetch('https://api.example.com/data', {
    cache: 'no-store' // Equivalent to getServerSideProps
  })
  return res.json()
}

export default async function Page() {
  const data = await getDynamicData()
  return <div>{data.title}</div>
}
```

**Revalidation (ISR):**
```tsx
async function getRevalidatedData() {
  const res = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 } // Revalidate every 60 seconds
  })
  return res.json()
}

export default async function Page() {
  const data = await getRevalidatedData()
  return <div>{data.title}</div>
}
```

**Parallel Data Fetching:**
```tsx
async function getUser(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}`)
  return res.json()
}

async function getUserPosts(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}/posts`)
  return res.json()
}

export default async function UserPage({ params }: { params: { id: string } }) {
  // Fetch in parallel
  const [user, posts] = await Promise.all([
    getUser(params.id),
    getUserPosts(params.id)
  ])

  return (
    <div>
      <h1>{user.name}</h1>
      <ul>
        {posts.map((post) => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>
    </div>
  )
}
```

**Sequential Data Fetching:**
```tsx
async function getUser(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}`)
  return res.json()
}

async function getRecommendations(preferences: string[]) {
  const res = await fetch('https://api.example.com/recommendations', {
    method: 'POST',
    body: JSON.stringify({ preferences })
  })
  return res.json()
}

export default async function UserPage({ params }: { params: { id: string } }) {
  // First fetch user
  const user = await getUser(params.id)

  // Then fetch recommendations based on user data
  const recommendations = await getRecommendations(user.preferences)

  return (
    <div>
      <h1>{user.name}</h1>
      <h2>Recommendations</h2>
      <ul>
        {recommendations.map((item) => (
          <li key={item.id}>{item.title}</li>
        ))}
      </ul>
    </div>
  )
}
```

### Routing

Next.js uses file-system based routing in the `app` directory.

**Dynamic Routes:**
```tsx
// app/blog/[slug]/page.tsx
export default function BlogPost({ params }: { params: { slug: string } }) {
  return <h1>Post: {params.slug}</h1>
}

// Generates static pages for these slugs at build time
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())

  return posts.map((post) => ({
    slug: post.slug,
  }))
}
```

**Catch-All Routes:**
```tsx
// app/docs/[...slug]/page.tsx
export default function DocsPage({ params }: { params: { slug: string[] } }) {
  // /docs/a/b/c -> params.slug = ['a', 'b', 'c']
  return <h1>Docs: {params.slug.join('/')}</h1>
}
```

**Optional Catch-All Routes:**
```tsx
// app/shop/[[...slug]]/page.tsx
export default function ShopPage({ params }: { params: { slug?: string[] } }) {
  // /shop -> params.slug = undefined
  // /shop/clothes -> params.slug = ['clothes']
  // /shop/clothes/tops -> params.slug = ['clothes', 'tops']
  return <h1>Shop: {params.slug?.join('/') || 'All'}</h1>
}
```

**Route Groups:**
```
app/
├── (marketing)/          # Route group (not in URL)
│   ├── about/
│   │   └── page.tsx      # /about
│   └── contact/
│       └── page.tsx      # /contact
└── (shop)/
    ├── products/
    │   └── page.tsx      # /products
    └── cart/
        └── page.tsx      # /cart
```

**Parallel Routes:**
```
app/
├── @analytics/
│   └── page.tsx
├── @team/
│   └── page.tsx
└── layout.tsx

// app/layout.tsx
export default function Layout({
  children,
  analytics,
  team,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <>
      {children}
      {analytics}
      {team}
    </>
  )
}
```

**Intercepting Routes:**
```
app/
├── feed/
│   └── page.tsx
├── photo/
│   └── [id]/
│       └── page.tsx
└── @modal/
    └── (.)photo/
        └── [id]/
            └── page.tsx  # Intercepts /photo/[id] when navigating from /feed
```

### Layouts

Layouts wrap pages and preserve state across navigation.

**Nested Layouts:**
```tsx
// app/layout.tsx (Root Layout)
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header>
          <nav>Global Navigation</nav>
        </header>
        {children}
        <footer>Global Footer</footer>
      </body>
    </html>
  )
}

// app/dashboard/layout.tsx (Dashboard Layout)
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="dashboard">
      <aside>Dashboard Sidebar</aside>
      <main>{children}</main>
    </div>
  )
}

// app/dashboard/page.tsx
export default function DashboardPage() {
  return <h1>Dashboard</h1>
}
```

**Templates (Re-render on Navigation):**
```tsx
// app/template.tsx
export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <div>
      {/* This creates a new instance on each navigation */}
      {children}
    </div>
  )
}
```

### Loading UI

Special `loading.tsx` files create loading states with React Suspense.

**Loading State:**
```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="spinner">
      <p>Loading dashboard...</p>
    </div>
  )
}

// app/dashboard/page.tsx
async function getData() {
  const res = await fetch('https://api.example.com/data')
  return res.json()
}

export default async function DashboardPage() {
  const data = await getData()
  return <div>{data.content}</div>
}
```

**Streaming with Suspense:**
```tsx
// app/page.tsx
import { Suspense } from 'react'

async function SlowComponent() {
  await new Promise(resolve => setTimeout(resolve, 3000))
  return <div>Slow data loaded</div>
}

export default function Page() {
  return (
    <div>
      <h1>Page</h1>
      <Suspense fallback={<div>Loading slow component...</div>}>
        <SlowComponent />
      </Suspense>
    </div>
  )
}
```

### Error Handling

Special `error.tsx` files handle errors with error boundaries.

**Error Boundary:**
```tsx
// app/error.tsx
'use client' // Error components must be Client Components

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

**Global Error:**
```tsx
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h2>Application Error</h2>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  )
}
```

**Not Found:**
```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div>
      <h2>Page Not Found</h2>
      <p>Could not find the requested resource</p>
      <Link href="/">Return Home</Link>
    </div>
  )
}
```

### API Routes

Route Handlers allow you to create API endpoints using Web Request and Response APIs.

**Basic API Route:**
```tsx
// app/api/hello/route.ts
export async function GET(request: Request) {
  return Response.json({ message: 'Hello from Next.js!' })
}
```

**Dynamic Route Handler:**
```tsx
// app/api/posts/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const id = params.id
  const post = await db.post.findUnique({ where: { id } })

  if (!post) {
    return new Response('Post not found', { status: 404 })
  }

  return Response.json(post)
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  await db.post.delete({ where: { id: params.id } })
  return new Response(null, { status: 204 })
}
```

**POST Request with Body:**
```tsx
// app/api/posts/route.ts
export async function POST(request: Request) {
  const body = await request.json()

  const post = await db.post.create({
    data: {
      title: body.title,
      content: body.content,
    }
  })

  return Response.json(post, { status: 201 })
}
```

**Request with Headers:**
```tsx
// app/api/protected/route.ts
export async function GET(request: Request) {
  const token = request.headers.get('authorization')

  if (!token) {
    return new Response('Unauthorized', { status: 401 })
  }

  const user = await verifyToken(token)
  return Response.json({ user })
}
```

**Search Params:**
```tsx
// app/api/search/route.ts
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const query = searchParams.get('q')
  const page = searchParams.get('page') || '1'

  const results = await search(query, parseInt(page))

  return Response.json(results)
}
```

**CORS Headers:**
```tsx
// app/api/public/route.ts
export async function GET(request: Request) {
  const data = { message: 'Public API' }

  return Response.json(data, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  })
}

export async function OPTIONS(request: Request) {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  })
}
```

### Middleware

Middleware runs before a request is completed, allowing you to modify the response.

**Basic Middleware:**
```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Clone the request headers
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-custom-header', 'custom-value')

  // Return response with modified headers
  return NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  })
}

export const config = {
  matcher: '/api/:path*',
}
```

**Authentication Middleware:**
```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value

  // Redirect to login if no token
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Redirect to dashboard if already logged in
  if (token && request.nextUrl.pathname === '/login') {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/login'],
}
```

**Geolocation and Rewrites:**
```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const country = request.geo?.country || 'US'

  // Rewrite based on country
  if (country === 'GB') {
    return NextResponse.rewrite(new URL('/gb' + request.nextUrl.pathname, request.url))
  }

  return NextResponse.next()
}
```

**Rate Limiting:**
```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
})

export async function middleware(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1'
  const { success } = await ratelimit.limit(ip)

  if (!success) {
    return new Response('Too Many Requests', { status: 429 })
  }

  return NextResponse.next()
}

export const config = {
  matcher: '/api/:path*',
}
```

### Metadata and SEO

Next.js provides a Metadata API for defining page metadata.

**Static Metadata:**
```tsx
// app/about/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn more about our company',
  openGraph: {
    title: 'About Us',
    description: 'Learn more about our company',
    images: ['/og-image.jpg'],
  },
  twitter: {
    card: 'summary_large_image',
  },
}

export default function AboutPage() {
  return <h1>About Us</h1>
}
```

**Dynamic Metadata:**
```tsx
// app/blog/[slug]/page.tsx
import type { Metadata } from 'next'

type Props = {
  params: { slug: string }
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const post = await getPost(params.slug)

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
      type: 'article',
      publishedTime: post.publishedAt,
    },
  }
}

export default async function BlogPost({ params }: Props) {
  const post = await getPost(params.slug)
  return <article>{post.content}</article>
}
```

**Metadata with Icons:**
```tsx
// app/layout.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    default: 'My App',
    template: '%s | My App',
  },
  description: 'My application description',
  icons: {
    icon: '/favicon.ico',
    apple: '/apple-icon.png',
  },
  manifest: '/manifest.json',
}
```

### Image Optimization

Next.js automatically optimizes images with the Image component.

**Basic Image:**
```tsx
import Image from 'next/image'

export default function Page() {
  return (
    <Image
      src="/profile.jpg"
      alt="Profile picture"
      width={500}
      height={500}
    />
  )
}
```

**Remote Images:**
```tsx
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
  },
}

// Component
import Image from 'next/image'

export default function Page() {
  return (
    <Image
      src="https://images.unsplash.com/photo-1234567890"
      alt="Photo"
      width={800}
      height={600}
      priority // Load image with high priority
    />
  )
}
```

**Fill Container:**
```tsx
import Image from 'next/image'

export default function Page() {
  return (
    <div style={{ position: 'relative', width: '100%', height: '400px' }}>
      <Image
        src="/background.jpg"
        alt="Background"
        fill
        style={{ objectFit: 'cover' }}
      />
    </div>
  )
}
```

**Responsive Images:**
```tsx
import Image from 'next/image'

export default function Page() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero"
      width={1920}
      height={1080}
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
    />
  )
}
```

### Font Optimization

Next.js automatically optimizes fonts with `next/font`.

**Google Fonts:**
```tsx
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
})

const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-roboto-mono',
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.className} ${robotoMono.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

**Local Fonts:**
```tsx
// app/layout.tsx
import localFont from 'next/font/local'

const myFont = localFont({
  src: './fonts/my-font.woff2',
  display: 'swap',
  variable: '--font-my-font',
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={myFont.variable}>
      <body>{children}</body>
    </html>
  )
}
```

## Workflow Patterns

### Creating a New Page

1. Create a new folder in `app` directory
2. Add a `page.tsx` file
3. Export a default component
4. Optionally add layout, loading, and error files

```tsx
// app/products/page.tsx
export default function ProductsPage() {
  return <h1>Products</h1>
}

// app/products/layout.tsx
export default function ProductsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <nav>Products Navigation</nav>
      {children}
    </div>
  )
}

// app/products/loading.tsx
export default function Loading() {
  return <div>Loading products...</div>
}
```

### Server Actions

Server Actions allow you to run server-side code directly from client components.

**Form with Server Action:**
```tsx
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.post.create({
    data: { title, content }
  })

  revalidatePath('/posts')
}

// app/new-post/page.tsx
import { createPost } from '../actions'

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

**Server Action with useTransition:**
```tsx
// app/actions.ts
'use server'

export async function updateUser(userId: string, data: UserData) {
  await db.user.update({
    where: { id: userId },
    data,
  })
  return { success: true }
}

// app/profile/page.tsx
'use client'

import { useTransition } from 'react'
import { updateUser } from '../actions'

export default function ProfilePage() {
  const [isPending, startTransition] = useTransition()

  const handleSubmit = (formData: FormData) => {
    startTransition(async () => {
      await updateUser('user-id', {
        name: formData.get('name') as string,
      })
    })
  }

  return (
    <form action={handleSubmit}>
      <input name="name" />
      <button disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>
    </form>
  )
}
```

### Authentication Pattern

**Basic Authentication with Middleware:**
```tsx
// lib/auth.ts
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'

export async function getSession() {
  const session = cookies().get('session')?.value
  if (!session) return null
  return await verifySession(session)
}

export async function requireAuth() {
  const session = await getSession()
  if (!session) {
    redirect('/login')
  }
  return session
}

// app/dashboard/page.tsx
import { requireAuth } from '@/lib/auth'

export default async function DashboardPage() {
  const session = await requireAuth()

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
    </div>
  )
}

// app/api/login/route.ts
import { cookies } from 'next/headers'

export async function POST(request: Request) {
  const { email, password } = await request.json()

  const user = await validateCredentials(email, password)

  if (!user) {
    return Response.json({ error: 'Invalid credentials' }, { status: 401 })
  }

  const session = await createSession(user)
  cookies().set('session', session, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 24 * 7, // 1 week
  })

  return Response.json({ success: true })
}
```

### Database Pattern

**Prisma with Server Components:**
```tsx
// lib/db.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = global as unknown as { prisma: PrismaClient }

export const prisma = globalForPrisma.prisma || new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

// app/posts/page.tsx
import { prisma } from '@/lib/db'

async function getPosts() {
  return await prisma.post.findMany({
    orderBy: { createdAt: 'desc' },
    include: { author: true },
  })
}

export default async function PostsPage() {
  const posts = await getPosts()

  return (
    <div>
      {posts.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>By {post.author.name}</p>
          <p>{post.content}</p>
        </article>
      ))}
    </div>
  )
}
```

### Caching Strategies

**Revalidate on Demand:**
```tsx
// app/actions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

export async function createPost(data: PostData) {
  await db.post.create({ data })

  // Revalidate specific path
  revalidatePath('/posts')

  // Or revalidate by tag
  revalidateTag('posts')
}

// Fetch with cache tags
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  })
  return res.json()
}
```

**Time-based Revalidation:**
```tsx
async function getData() {
  const res = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 } // Revalidate every hour
  })
  return res.json()
}
```

**Route Segment Config:**
```tsx
// app/blog/page.tsx
export const revalidate = 3600 // Revalidate every hour
export const dynamic = 'force-static' // Force static generation
export const fetchCache = 'force-cache' // Force cache for all fetch requests

export default async function BlogPage() {
  const posts = await getPosts()
  return <div>{/* ... */}</div>
}
```

## Best Practices

### 1. Use Server Components by Default

Server Components are the default and provide better performance. Only use Client Components when needed.

```tsx
// ✅ Good - Server Component
async function getData() {
  const res = await fetch('https://api.example.com/data')
  return res.json()
}

export default async function Page() {
  const data = await getData()
  return <div>{data.title}</div>
}

// ✅ Good - Client Component only when needed
'use client'

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

### 2. Fetch Data Where You Need It

Don't prop-drill data. Fetch data in the component that needs it.

```tsx
// ✅ Good - Fetch where needed
async function Header() {
  const user = await getUser()
  return <div>Welcome, {user.name}</div>
}

async function Posts() {
  const posts = await getPosts()
  return <div>{/* render posts */}</div>
}

export default function Page() {
  return (
    <>
      <Header />
      <Posts />
    </>
  )
}
```

### 3. Use Parallel Data Fetching

Fetch data in parallel when possible to reduce loading time.

```tsx
// ✅ Good - Parallel fetching
export default async function Page() {
  const [user, posts] = await Promise.all([
    getUser(),
    getPosts()
  ])

  return <div>{/* ... */}</div>
}
```

### 4. Optimize Images

Always use the Image component for automatic optimization.

```tsx
// ✅ Good
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1920}
  height={1080}
  priority
/>

// ❌ Bad
<img src="/hero.jpg" alt="Hero" />
```

### 5. Use Metadata API for SEO

Define metadata for every page.

```tsx
// ✅ Good
export const metadata = {
  title: 'My Page',
  description: 'Page description',
}

export default function Page() {
  return <div>Content</div>
}
```

### 6. Implement Error Boundaries

Add error.tsx files for error handling.

```tsx
// app/error.tsx
'use client'

export default function Error({ error, reset }: { error: Error, reset: () => void }) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

### 7. Use Loading States

Add loading.tsx files for loading UI.

```tsx
// app/loading.tsx
export default function Loading() {
  return <div>Loading...</div>
}
```

### 8. Implement Route Handlers for APIs

Use Route Handlers instead of API routes in pages directory.

```tsx
// ✅ Good - app/api/users/route.ts
export async function GET(request: Request) {
  const users = await db.user.findMany()
  return Response.json(users)
}
```

### 9. Use Middleware for Common Logic

Implement authentication, redirects, and rewrites in middleware.

```tsx
// middleware.ts
export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')

  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}
```

### 10. Optimize Fonts

Use next/font for automatic font optimization.

```tsx
// ✅ Good
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

## Common Patterns

### Blog Pattern

```tsx
// app/blog/page.tsx
import Link from 'next/link'

async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 }
  })
  return res.json()
}

export default async function BlogPage() {
  const posts = await getPosts()

  return (
    <div>
      <h1>Blog</h1>
      {posts.map((post) => (
        <article key={post.id}>
          <h2>
            <Link href={`/blog/${post.slug}`}>{post.title}</Link>
          </h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  )
}

// app/blog/[slug]/page.tsx
import { notFound } from 'next/navigation'

async function getPost(slug: string) {
  const res = await fetch(`https://api.example.com/posts/${slug}`)
  if (!res.ok) return null
  return res.json()
}

export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())
  return posts.map((post) => ({ slug: post.slug }))
}

export async function generateMetadata({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug)
  if (!post) return {}

  return {
    title: post.title,
    description: post.excerpt,
  }
}

export default async function BlogPostPage({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug)

  if (!post) {
    notFound()
  }

  return (
    <article>
      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  )
}
```

### E-commerce Pattern

```tsx
// app/products/page.tsx
import { Suspense } from 'react'
import ProductGrid from './ProductGrid'
import Filters from './Filters'

export default function ProductsPage({
  searchParams,
}: {
  searchParams: { category?: string; sort?: string }
}) {
  return (
    <div>
      <h1>Products</h1>
      <Filters />
      <Suspense fallback={<div>Loading products...</div>}>
        <ProductGrid searchParams={searchParams} />
      </Suspense>
    </div>
  )
}

// app/products/ProductGrid.tsx
async function getProducts(category?: string, sort?: string) {
  const params = new URLSearchParams()
  if (category) params.set('category', category)
  if (sort) params.set('sort', sort)

  const res = await fetch(`https://api.example.com/products?${params}`, {
    next: { revalidate: 300 }
  })
  return res.json()
}

export default async function ProductGrid({
  searchParams,
}: {
  searchParams: { category?: string; sort?: string }
}) {
  const products = await getProducts(searchParams.category, searchParams.sort)

  return (
    <div className="grid">
      {products.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}

// app/products/[id]/page.tsx
async function getProduct(id: string) {
  const res = await fetch(`https://api.example.com/products/${id}`)
  return res.json()
}

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <p>${product.price}</p>
      <AddToCartButton productId={product.id} />
    </div>
  )
}
```

### Dashboard Pattern

```tsx
// app/dashboard/layout.tsx
import { requireAuth } from '@/lib/auth'
import Sidebar from './Sidebar'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = await requireAuth()

  return (
    <div className="dashboard">
      <Sidebar user={session.user} />
      <main>{children}</main>
    </div>
  )
}

// app/dashboard/page.tsx
import { Suspense } from 'react'
import Stats from './Stats'
import RecentActivity from './RecentActivity'
import Chart from './Chart'

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<div>Loading stats...</div>}>
        <Stats />
      </Suspense>

      <div className="grid">
        <Suspense fallback={<div>Loading chart...</div>}>
          <Chart />
        </Suspense>

        <Suspense fallback={<div>Loading activity...</div>}>
          <RecentActivity />
        </Suspense>
      </div>
    </div>
  )
}
```

## Summary

This Next.js development skill covers:

1. **App Router**: Modern routing with file-based system
2. **Server Components**: Default server-side rendering for better performance
3. **Data Fetching**: Extended fetch API with caching and revalidation
4. **Routing**: Dynamic routes, catch-all routes, route groups, parallel routes
5. **Layouts**: Nested layouts, templates, and layout composition
6. **Loading States**: Automatic loading UI with Suspense
7. **Error Handling**: Error boundaries and not-found pages
8. **API Routes**: Route handlers with Web APIs
9. **Middleware**: Request interception and modification
10. **Metadata**: SEO optimization with Metadata API
11. **Image Optimization**: Automatic image optimization with Image component
12. **Font Optimization**: Automatic font loading with next/font
13. **Server Actions**: Server-side mutations from client components
14. **Authentication**: Session management and protected routes
15. **Best Practices**: Performance optimization, caching strategies, and common patterns

All patterns are based on official Next.js documentation (Trust Score: 10) and represent modern Next.js 13+ App Router development practices.
