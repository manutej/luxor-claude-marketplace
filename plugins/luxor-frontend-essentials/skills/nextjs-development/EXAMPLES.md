# Next.js Development Examples

Comprehensive code examples demonstrating Next.js patterns and best practices.

## Table of Contents

1. [Basic App Structure](#1-basic-app-structure)
2. [Dynamic Routes with Static Generation](#2-dynamic-routes-with-static-generation)
3. [Server Components with Data Fetching](#3-server-components-with-data-fetching)
4. [Client Components with Interactivity](#4-client-components-with-interactivity)
5. [Parallel Data Fetching](#5-parallel-data-fetching)
6. [API Route Handlers](#6-api-route-handlers)
7. [Form Handling with Server Actions](#7-form-handling-with-server-actions)
8. [Authentication with Middleware](#8-authentication-with-middleware)
9. [Error Handling and Loading States](#9-error-handling-and-loading-states)
10. [Streaming with Suspense](#10-streaming-with-suspense)
11. [Dynamic Metadata and SEO](#11-dynamic-metadata-and-seo)
12. [Image Optimization](#12-image-optimization)
13. [Middleware for Rate Limiting](#13-middleware-for-rate-limiting)
14. [E-commerce Product Catalog](#14-e-commerce-product-catalog)
15. [Blog with MDX Content](#15-blog-with-mdx-content)
16. [Dashboard with Protected Routes](#16-dashboard-with-protected-routes)
17. [Search with Server Actions](#17-search-with-server-actions)
18. [Internationalization (i18n)](#18-internationalization-i18n)
19. [Real-time Updates with Server-Sent Events](#19-real-time-updates-with-server-sent-events)
20. [Advanced Caching Strategies](#20-advanced-caching-strategies)

---

## 1. Basic App Structure

A complete basic Next.js application structure with all essential files.

```tsx
// app/layout.tsx
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'My Next.js App',
  description: 'A modern Next.js application',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <nav className="navbar">
          <a href="/">Home</a>
          <a href="/about">About</a>
          <a href="/blog">Blog</a>
        </nav>
        <main>{children}</main>
        <footer>© 2024 My App</footer>
      </body>
    </html>
  )
}

// app/page.tsx
export default function HomePage() {
  return (
    <div>
      <h1>Welcome to Next.js</h1>
      <p>Start building your application with the App Router.</p>
    </div>
  )
}

// app/about/page.tsx
export const metadata = {
  title: 'About Us',
  description: 'Learn more about our company',
}

export default function AboutPage() {
  return (
    <div>
      <h1>About Us</h1>
      <p>We build amazing web applications with Next.js.</p>
    </div>
  )
}

// app/loading.tsx
export default function Loading() {
  return (
    <div className="loading-spinner">
      <div className="spinner"></div>
      <p>Loading...</p>
    </div>
  )
}

// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div>
      <h2>404 - Page Not Found</h2>
      <p>The page you're looking for doesn't exist.</p>
      <Link href="/">Go back home</Link>
    </div>
  )
}
```

---

## 2. Dynamic Routes with Static Generation

Building a blog with dynamic routes and static page generation.

```tsx
// app/blog/page.tsx
import Link from 'next/link'

interface Post {
  id: string
  slug: string
  title: string
  excerpt: string
  publishedAt: string
}

async function getPosts(): Promise<Post[]> {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 } // Revalidate every hour
  })

  if (!res.ok) {
    throw new Error('Failed to fetch posts')
  }

  return res.json()
}

export default async function BlogPage() {
  const posts = await getPosts()

  return (
    <div className="blog-container">
      <h1>Blog</h1>
      <div className="posts-grid">
        {posts.map((post) => (
          <article key={post.id} className="post-card">
            <h2>
              <Link href={`/blog/${post.slug}`}>
                {post.title}
              </Link>
            </h2>
            <p>{post.excerpt}</p>
            <time>{new Date(post.publishedAt).toLocaleDateString()}</time>
          </article>
        ))}
      </div>
    </div>
  )
}

// app/blog/[slug]/page.tsx
import { notFound } from 'next/navigation'
import type { Metadata } from 'next'

interface Post {
  id: string
  slug: string
  title: string
  content: string
  excerpt: string
  publishedAt: string
  author: {
    name: string
    avatar: string
  }
}

async function getPost(slug: string): Promise<Post | null> {
  const res = await fetch(`https://api.example.com/posts/${slug}`, {
    next: { revalidate: 3600 }
  })

  if (!res.ok) {
    return null
  }

  return res.json()
}

// Generate static paths at build time
export async function generateStaticParams() {
  const res = await fetch('https://api.example.com/posts')
  const posts: Post[] = await res.json()

  return posts.map((post) => ({
    slug: post.slug,
  }))
}

// Generate dynamic metadata
export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const post = await getPost(params.slug)

  if (!post) {
    return {
      title: 'Post Not Found',
    }
  }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: 'article',
      publishedTime: post.publishedAt,
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
    },
  }
}

export default async function BlogPostPage({
  params,
}: {
  params: { slug: string }
}) {
  const post = await getPost(params.slug)

  if (!post) {
    notFound()
  }

  return (
    <article className="blog-post">
      <header>
        <h1>{post.title}</h1>
        <div className="author-info">
          <img src={post.author.avatar} alt={post.author.name} />
          <div>
            <p>{post.author.name}</p>
            <time>{new Date(post.publishedAt).toLocaleDateString()}</time>
          </div>
        </div>
      </header>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: post.content }}
      />
    </article>
  )
}
```

---

## 3. Server Components with Data Fetching

Demonstrating various data fetching patterns in Server Components.

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'

// Static data - cached indefinitely
async function getAppConfig() {
  const res = await fetch('https://api.example.com/config', {
    cache: 'force-cache'
  })
  return res.json()
}

// Dynamic data - no caching
async function getUserData() {
  const res = await fetch('https://api.example.com/user', {
    cache: 'no-store'
  })
  return res.json()
}

// Revalidated data - cached with time-based revalidation
async function getStats() {
  const res = await fetch('https://api.example.com/stats', {
    next: { revalidate: 60 } // Revalidate every 60 seconds
  })
  return res.json()
}

export default async function DashboardPage() {
  // Parallel fetching
  const [config, user] = await Promise.all([
    getAppConfig(),
    getUserData()
  ])

  return (
    <div className="dashboard">
      <h1>Welcome, {user.name}</h1>

      <div className="stats-section">
        <Suspense fallback={<StatsLoading />}>
          <Stats />
        </Suspense>
      </div>

      <div className="config-section">
        <h2>Settings</h2>
        <pre>{JSON.stringify(config, null, 2)}</pre>
      </div>
    </div>
  )
}

async function Stats() {
  const stats = await getStats()

  return (
    <div className="stats-grid">
      <div className="stat-card">
        <h3>Total Users</h3>
        <p>{stats.totalUsers}</p>
      </div>
      <div className="stat-card">
        <h3>Active Sessions</h3>
        <p>{stats.activeSessions}</p>
      </div>
      <div className="stat-card">
        <h3>Revenue</h3>
        <p>${stats.revenue}</p>
      </div>
    </div>
  )
}

function StatsLoading() {
  return (
    <div className="stats-grid">
      {[1, 2, 3].map((i) => (
        <div key={i} className="stat-card skeleton">
          <div className="skeleton-title"></div>
          <div className="skeleton-value"></div>
        </div>
      ))}
    </div>
  )
}
```

---

## 4. Client Components with Interactivity

Creating interactive components that run on the client.

```tsx
// app/components/Counter.tsx
'use client'

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div className="counter">
      <p>Count: {count}</p>
      <div className="button-group">
        <button onClick={() => setCount(count - 1)}>-</button>
        <button onClick={() => setCount(0)}>Reset</button>
        <button onClick={() => setCount(count + 1)}>+</button>
      </div>
    </div>
  )
}

// app/components/SearchBar.tsx
'use client'

import { useState, useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'

export default function SearchBar() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [query, setQuery] = useState(searchParams.get('q') || '')

  useEffect(() => {
    // Debounce search
    const timer = setTimeout(() => {
      if (query) {
        router.push(`/search?q=${encodeURIComponent(query)}`)
      }
    }, 500)

    return () => clearTimeout(timer)
  }, [query, router])

  return (
    <div className="search-bar">
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
    </div>
  )
}

// app/components/Theme Provider.tsx
'use client'

import { createContext, useContext, useState, useEffect } from 'react'

type Theme = 'light' | 'dark'

const ThemeContext = createContext<{
  theme: Theme
  toggleTheme: () => void
}>({
  theme: 'light',
  toggleTheme: () => {},
})

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light')

  useEffect(() => {
    // Load theme from localStorage
    const savedTheme = localStorage.getItem('theme') as Theme
    if (savedTheme) {
      setTheme(savedTheme)
    }
  }, [])

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light'
    setTheme(newTheme)
    localStorage.setItem('theme', newTheme)
  }

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      <div data-theme={theme}>{children}</div>
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  return useContext(ThemeContext)
}

// app/components/ThemeToggle.tsx
'use client'

import { useTheme } from './ThemeProvider'

export default function ThemeToggle() {
  const { theme, toggleTheme } = useTheme()

  return (
    <button onClick={toggleTheme} className="theme-toggle">
      {theme === 'light' ? '🌙' : '☀️'}
    </button>
  )
}
```

---

## 5. Parallel Data Fetching

Optimizing performance by fetching data in parallel.

```tsx
// app/user/[id]/page.tsx
interface User {
  id: string
  name: string
  email: string
  bio: string
}

interface Post {
  id: string
  title: string
  excerpt: string
}

interface Activity {
  id: string
  type: string
  description: string
  timestamp: string
}

async function getUser(id: string): Promise<User> {
  const res = await fetch(`https://api.example.com/users/${id}`)
  return res.json()
}

async function getUserPosts(id: string): Promise<Post[]> {
  const res = await fetch(`https://api.example.com/users/${id}/posts`)
  return res.json()
}

async function getUserActivity(id: string): Promise<Activity[]> {
  const res = await fetch(`https://api.example.com/users/${id}/activity`)
  return res.json()
}

export default async function UserProfilePage({
  params,
}: {
  params: { id: string }
}) {
  // Fetch all data in parallel
  const [user, posts, activity] = await Promise.all([
    getUser(params.id),
    getUserPosts(params.id),
    getUserActivity(params.id),
  ])

  return (
    <div className="user-profile">
      <header className="profile-header">
        <h1>{user.name}</h1>
        <p>{user.email}</p>
        <p>{user.bio}</p>
      </header>

      <div className="profile-content">
        <section className="posts-section">
          <h2>Recent Posts</h2>
          {posts.map((post) => (
            <article key={post.id} className="post-preview">
              <h3>{post.title}</h3>
              <p>{post.excerpt}</p>
            </article>
          ))}
        </section>

        <aside className="activity-sidebar">
          <h2>Recent Activity</h2>
          {activity.map((item) => (
            <div key={item.id} className="activity-item">
              <p>{item.description}</p>
              <time>{new Date(item.timestamp).toLocaleString()}</time>
            </div>
          ))}
        </aside>
      </div>
    </div>
  )
}

// Example with waterfall pattern (sequential)
async function getRecommendations(userId: string, preferences: string[]) {
  const res = await fetch('https://api.example.com/recommendations', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId, preferences }),
  })
  return res.json()
}

export async function UserWithRecommendations({
  params,
}: {
  params: { id: string }
}) {
  // First, get user data
  const user = await getUser(params.id)

  // Then, get recommendations based on user preferences
  const recommendations = await getRecommendations(
    params.id,
    user.preferences
  )

  return (
    <div>
      <h1>{user.name}</h1>
      <div className="recommendations">
        <h2>Recommended for You</h2>
        {recommendations.map((item) => (
          <div key={item.id}>{item.title}</div>
        ))}
      </div>
    </div>
  )
}
```

---

## 6. API Route Handlers

Building RESTful API endpoints with Route Handlers.

```tsx
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

// Validation schema
const postSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
  published: z.boolean().optional(),
})

// GET /api/posts
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const page = parseInt(searchParams.get('page') || '1')
  const limit = parseInt(searchParams.get('limit') || '10')
  const search = searchParams.get('search') || ''

  try {
    const posts = await db.post.findMany({
      where: search
        ? {
            OR: [
              { title: { contains: search, mode: 'insensitive' } },
              { content: { contains: search, mode: 'insensitive' } },
            ],
          }
        : {},
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: { author: true },
    })

    const total = await db.post.count()

    return NextResponse.json({
      posts,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch posts' },
      { status: 500 }
    )
  }
}

// POST /api/posts
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validated = postSchema.parse(body)

    const post = await db.post.create({
      data: {
        title: validated.title,
        content: validated.content,
        published: validated.published ?? false,
        authorId: 'current-user-id', // Get from session
      },
    })

    return NextResponse.json(post, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      )
    }

    return NextResponse.json(
      { error: 'Failed to create post' },
      { status: 500 }
    )
  }
}

// app/api/posts/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const post = await db.post.findUnique({
      where: { id: params.id },
      include: { author: true, comments: true },
    })

    if (!post) {
      return NextResponse.json(
        { error: 'Post not found' },
        { status: 404 }
      )
    }

    return NextResponse.json(post)
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch post' },
      { status: 500 }
    )
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    const validated = postSchema.partial().parse(body)

    const post = await db.post.update({
      where: { id: params.id },
      data: validated,
    })

    return NextResponse.json(post)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      )
    }

    return NextResponse.json(
      { error: 'Failed to update post' },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    await db.post.delete({
      where: { id: params.id },
    })

    return new NextResponse(null, { status: 204 })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to delete post' },
      { status: 500 }
    )
  }
}

// app/api/upload/route.ts
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Upload to cloud storage (e.g., AWS S3, Cloudinary)
    const buffer = Buffer.from(await file.arrayBuffer())
    const url = await uploadToStorage(buffer, file.name)

    return NextResponse.json({ url })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to upload file' },
      { status: 500 }
    )
  }
}
```

---

## 7. Form Handling with Server Actions

Using Server Actions for form submissions and mutations.

```tsx
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'

const postSchema = z.object({
  title: z.string().min(1, 'Title is required').max(200),
  content: z.string().min(1, 'Content is required'),
  published: z.boolean().optional(),
})

export async function createPost(formData: FormData) {
  const validated = postSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
  })

  if (!validated.success) {
    return {
      error: 'Validation failed',
      details: validated.error.flatten().fieldErrors,
    }
  }

  try {
    const post = await db.post.create({
      data: validated.data,
    })

    revalidatePath('/posts')
    redirect(`/posts/${post.id}`)
  } catch (error) {
    return { error: 'Failed to create post' }
  }
}

export async function updatePost(id: string, formData: FormData) {
  const validated = postSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
  })

  if (!validated.success) {
    return {
      error: 'Validation failed',
      details: validated.error.flatten().fieldErrors,
    }
  }

  try {
    await db.post.update({
      where: { id },
      data: validated.data,
    })

    revalidatePath(`/posts/${id}`)
    revalidatePath('/posts')

    return { success: true }
  } catch (error) {
    return { error: 'Failed to update post' }
  }
}

export async function deletePost(id: string) {
  try {
    await db.post.delete({
      where: { id },
    })

    revalidatePath('/posts')
    redirect('/posts')
  } catch (error) {
    return { error: 'Failed to delete post' }
  }
}

// app/posts/new/page.tsx
import { createPost } from '@/app/actions'
import SubmitButton from './SubmitButton'

export default function NewPostPage() {
  return (
    <div className="new-post-page">
      <h1>Create New Post</h1>

      <form action={createPost} className="post-form">
        <div className="form-group">
          <label htmlFor="title">Title</label>
          <input
            type="text"
            id="title"
            name="title"
            required
            placeholder="Enter post title"
          />
        </div>

        <div className="form-group">
          <label htmlFor="content">Content</label>
          <textarea
            id="content"
            name="content"
            required
            rows={10}
            placeholder="Write your post content"
          />
        </div>

        <div className="form-group">
          <label>
            <input type="checkbox" name="published" />
            Publish immediately
          </label>
        </div>

        <SubmitButton />
      </form>
    </div>
  )
}

// app/posts/new/SubmitButton.tsx
'use client'

import { useFormStatus } from 'react-dom'

export default function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending} className="submit-button">
      {pending ? 'Creating...' : 'Create Post'}
    </button>
  )
}

// app/posts/[id]/edit/page.tsx
import { updatePost, deletePost } from '@/app/actions'
import { notFound } from 'next/navigation'

async function getPost(id: string) {
  const post = await db.post.findUnique({
    where: { id },
  })

  if (!post) {
    notFound()
  }

  return post
}

export default async function EditPostPage({
  params,
}: {
  params: { id: string }
}) {
  const post = await getPost(params.id)

  const updatePostWithId = updatePost.bind(null, params.id)
  const deletePostWithId = deletePost.bind(null, params.id)

  return (
    <div className="edit-post-page">
      <h1>Edit Post</h1>

      <form action={updatePostWithId} className="post-form">
        <div className="form-group">
          <label htmlFor="title">Title</label>
          <input
            type="text"
            id="title"
            name="title"
            defaultValue={post.title}
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="content">Content</label>
          <textarea
            id="content"
            name="content"
            defaultValue={post.content}
            required
            rows={10}
          />
        </div>

        <div className="form-group">
          <label>
            <input
              type="checkbox"
              name="published"
              defaultChecked={post.published}
            />
            Published
          </label>
        </div>

        <div className="button-group">
          <button type="submit" className="submit-button">
            Update Post
          </button>
        </div>
      </form>

      <form action={deletePostWithId} className="delete-form">
        <button type="submit" className="delete-button">
          Delete Post
        </button>
      </form>
    </div>
  )
}
```

---

## 8. Authentication with Middleware

Implementing authentication and protected routes.

```tsx
// lib/auth.ts
import { cookies } from 'next/headers'
import { jwtVerify, SignJWT } from 'jose'

const secret = new TextEncoder().encode(process.env.JWT_SECRET)

export async function createSession(userId: string) {
  const token = await new SignJWT({ userId })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .sign(secret)

  return token
}

export async function verifySession(token: string) {
  try {
    const { payload } = await jwtVerify(token, secret)
    return payload
  } catch (error) {
    return null
  }
}

export async function getSession() {
  const token = cookies().get('session')?.value

  if (!token) {
    return null
  }

  return await verifySession(token)
}

export async function getCurrentUser() {
  const session = await getSession()

  if (!session) {
    return null
  }

  const user = await db.user.findUnique({
    where: { id: session.userId as string },
  })

  return user
}

// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { verifySession } from './lib/auth'

const publicPaths = ['/login', '/register', '/']
const authPaths = ['/login', '/register']

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname
  const token = request.cookies.get('session')?.value

  // Check if path is public
  const isPublicPath = publicPaths.some((p) => path.startsWith(p))
  const isAuthPath = authPaths.some((p) => path.startsWith(p))

  // Verify session
  const session = token ? await verifySession(token) : null

  // Redirect to login if accessing protected route without session
  if (!isPublicPath && !session) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Redirect to dashboard if accessing auth pages with valid session
  if (isAuthPath && session) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}

// app/api/auth/login/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { cookies } from 'next/headers'
import { createSession } from '@/lib/auth'
import bcrypt from 'bcryptjs'

export async function POST(request: NextRequest) {
  try {
    const { email, password } = await request.json()

    // Find user
    const user = await db.user.findUnique({
      where: { email },
    })

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      )
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password)

    if (!isValid) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      )
    }

    // Create session
    const token = await createSession(user.id)

    cookies().set('session', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7, // 1 week
    })

    return NextResponse.json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
    })
  } catch (error) {
    return NextResponse.json(
      { error: 'Authentication failed' },
      { status: 500 }
    )
  }
}

// app/api/auth/logout/route.ts
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function POST() {
  cookies().delete('session')
  return NextResponse.json({ success: true })
}

// app/dashboard/page.tsx
import { getCurrentUser } from '@/lib/auth'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const user = await getCurrentUser()

  if (!user) {
    redirect('/login')
  }

  return (
    <div className="dashboard">
      <h1>Welcome, {user.name}</h1>
      <p>Email: {user.email}</p>
    </div>
  )
}

// app/login/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const router = useRouter()
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const formData = new FormData(e.currentTarget)
    const email = formData.get('email')
    const password = formData.get('password')

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (!res.ok) {
        const data = await res.json()
        setError(data.error || 'Login failed')
        return
      }

      router.push('/dashboard')
      router.refresh()
    } catch (error) {
      setError('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-page">
      <h1>Login</h1>

      <form onSubmit={handleSubmit} className="login-form">
        {error && <div className="error">{error}</div>}

        <div className="form-group">
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            name="email"
            required
            autoComplete="email"
          />
        </div>

        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            name="password"
            required
            autoComplete="current-password"
          />
        </div>

        <button type="submit" disabled={loading}>
          {loading ? 'Logging in...' : 'Login'}
        </button>
      </form>
    </div>
  )
}
```

---

## 9. Error Handling and Loading States

Implementing comprehensive error handling and loading UI.

```tsx
// app/error.tsx
'use client'

import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log error to error reporting service
    console.error('Error:', error)
  }, [error])

  return (
    <div className="error-container">
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      {error.digest && <p className="error-digest">Error ID: {error.digest}</p>}
      <button onClick={reset} className="retry-button">
        Try again
      </button>
    </div>
  )
}

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
        <div className="global-error">
          <h2>Application Error</h2>
          <p>An unexpected error occurred</p>
          <button onClick={reset}>Try again</button>
        </div>
      </body>
    </html>
  )
}

// app/loading.tsx
export default function Loading() {
  return (
    <div className="loading-container">
      <div className="spinner">
        <div className="bounce1"></div>
        <div className="bounce2"></div>
        <div className="bounce3"></div>
      </div>
      <p>Loading...</p>
    </div>
  )
}

// app/posts/[id]/loading.tsx
export default function PostLoading() {
  return (
    <div className="post-skeleton">
      <div className="skeleton skeleton-title"></div>
      <div className="skeleton skeleton-meta"></div>
      <div className="skeleton skeleton-content"></div>
      <div className="skeleton skeleton-content"></div>
      <div className="skeleton skeleton-content short"></div>
    </div>
  )
}

// app/posts/[id]/error.tsx
'use client'

import Link from 'next/link'

export default function PostError({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div className="post-error">
      <h2>Failed to load post</h2>
      <p>{error.message}</p>
      <div className="error-actions">
        <button onClick={reset}>Try again</button>
        <Link href="/posts">Back to posts</Link>
      </div>
    </div>
  )
}

// app/posts/[id]/not-found.tsx
import Link from 'next/link'

export default function PostNotFound() {
  return (
    <div className="not-found">
      <h2>Post Not Found</h2>
      <p>The post you're looking for doesn't exist.</p>
      <Link href="/posts" className="back-link">
        View all posts
      </Link>
    </div>
  )
}
```

---

## 10. Streaming with Suspense

Implementing streaming and progressive rendering.

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div className="dashboard">
      <h1>Dashboard</h1>

      {/* Immediately render header */}
      <header className="dashboard-header">
        <WelcomeMessage />
      </header>

      {/* Stream different sections independently */}
      <div className="dashboard-grid">
        <Suspense fallback={<CardSkeleton />}>
          <UserStats />
        </Suspense>

        <Suspense fallback={<CardSkeleton />}>
          <RecentOrders />
        </Suspense>

        <Suspense fallback={<ChartSkeleton />}>
          <SalesChart />
        </Suspense>

        <Suspense fallback={<CardSkeleton />}>
          <TopProducts />
        </Suspense>
      </div>
    </div>
  )
}

async function UserStats() {
  // Simulate slow data fetch
  await new Promise((resolve) => setTimeout(resolve, 1000))

  const stats = await fetch('https://api.example.com/stats').then((r) =>
    r.json()
  )

  return (
    <div className="stats-card">
      <h2>Statistics</h2>
      <div className="stats-grid">
        <div className="stat">
          <span className="stat-label">Total Users</span>
          <span className="stat-value">{stats.totalUsers}</span>
        </div>
        <div className="stat">
          <span className="stat-label">Active Users</span>
          <span className="stat-value">{stats.activeUsers}</span>
        </div>
        <div className="stat">
          <span className="stat-label">New Today</span>
          <span className="stat-value">{stats.newToday}</span>
        </div>
      </div>
    </div>
  )
}

async function RecentOrders() {
  await new Promise((resolve) => setTimeout(resolve, 1500))

  const orders = await fetch('https://api.example.com/orders/recent').then(
    (r) => r.json()
  )

  return (
    <div className="orders-card">
      <h2>Recent Orders</h2>
      <ul className="orders-list">
        {orders.map((order) => (
          <li key={order.id} className="order-item">
            <span>{order.customerName}</span>
            <span>${order.total}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

async function SalesChart() {
  await new Promise((resolve) => setTimeout(resolve, 2000))

  const salesData = await fetch('https://api.example.com/sales/chart').then(
    (r) => r.json()
  )

  return (
    <div className="chart-card">
      <h2>Sales Overview</h2>
      {/* Render chart component */}
      <ChartComponent data={salesData} />
    </div>
  )
}

async function TopProducts() {
  await new Promise((resolve) => setTimeout(resolve, 1200))

  const products = await fetch('https://api.example.com/products/top').then(
    (r) => r.json()
  )

  return (
    <div className="products-card">
      <h2>Top Products</h2>
      <ul className="products-list">
        {products.map((product) => (
          <li key={product.id} className="product-item">
            <img src={product.image} alt={product.name} />
            <div>
              <p>{product.name}</p>
              <span>{product.sales} sales</span>
            </div>
          </li>
        ))}
      </ul>
    </div>
  )
}

function CardSkeleton() {
  return (
    <div className="card-skeleton">
      <div className="skeleton skeleton-title"></div>
      <div className="skeleton skeleton-content"></div>
      <div className="skeleton skeleton-content"></div>
    </div>
  )
}

function ChartSkeleton() {
  return (
    <div className="chart-skeleton">
      <div className="skeleton skeleton-title"></div>
      <div className="skeleton skeleton-chart"></div>
    </div>
  )
}

function WelcomeMessage() {
  return (
    <div className="welcome">
      <h2>Welcome back!</h2>
      <p>Here's what's happening today</p>
    </div>
  )
}
```

---

## 11. Dynamic Metadata and SEO

Advanced SEO optimization with dynamic metadata.

```tsx
// app/blog/[slug]/page.tsx
import type { Metadata, ResolvingMetadata } from 'next'
import { notFound } from 'next/navigation'

interface Post {
  id: string
  slug: string
  title: string
  excerpt: string
  content: string
  publishedAt: string
  updatedAt: string
  coverImage: string
  author: {
    name: string
    image: string
  }
  tags: string[]
}

async function getPost(slug: string): Promise<Post | null> {
  const res = await fetch(`https://api.example.com/posts/${slug}`)
  if (!res.ok) return null
  return res.json()
}

export async function generateMetadata(
  { params }: { params: { slug: string } },
  parent: ResolvingMetadata
): Promise<Metadata> {
  const post = await getPost(params.slug)

  if (!post) {
    return {
      title: 'Post Not Found',
    }
  }

  const previousImages = (await parent).openGraph?.images || []

  return {
    title: post.title,
    description: post.excerpt,
    authors: [{ name: post.author.name }],
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: 'article',
      publishedTime: post.publishedAt,
      modifiedTime: post.updatedAt,
      authors: [post.author.name],
      images: [post.coverImage, ...previousImages],
      tags: post.tags,
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
      creator: '@yourhandle',
    },
    alternates: {
      canonical: `https://yourdomain.com/blog/${post.slug}`,
    },
    keywords: post.tags,
  }
}

export default async function BlogPostPage({
  params,
}: {
  params: { slug: string }
}) {
  const post = await getPost(params.slug)

  if (!post) {
    notFound()
  }

  return (
    <article className="blog-post" itemScope itemType="https://schema.org/BlogPosting">
      <meta itemProp="datePublished" content={post.publishedAt} />
      <meta itemProp="dateModified" content={post.updatedAt} />

      <header>
        <h1 itemProp="headline">{post.title}</h1>

        <div className="author-info" itemScope itemType="https://schema.org/Person">
          <img
            src={post.author.image}
            alt={post.author.name}
            itemProp="image"
          />
          <span itemProp="name">{post.author.name}</span>
        </div>

        <time dateTime={post.publishedAt}>
          {new Date(post.publishedAt).toLocaleDateString()}
        </time>

        <div className="tags">
          {post.tags.map((tag) => (
            <span key={tag} className="tag" itemProp="keywords">
              {tag}
            </span>
          ))}
        </div>
      </header>

      <img
        src={post.coverImage}
        alt={post.title}
        className="cover-image"
        itemProp="image"
      />

      <div
        className="content"
        itemProp="articleBody"
        dangerouslySetInnerHTML={{ __html: post.content }}
      />

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'BlogPosting',
            headline: post.title,
            description: post.excerpt,
            image: post.coverImage,
            datePublished: post.publishedAt,
            dateModified: post.updatedAt,
            author: {
              '@type': 'Person',
              name: post.author.name,
              image: post.author.image,
            },
            keywords: post.tags.join(', '),
          }),
        }}
      />
    </article>
  )
}

// app/products/[id]/page.tsx
export async function generateMetadata({
  params,
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await getProduct(params.id)

  return {
    title: `${product.name} - Buy Now`,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      type: 'website',
      images: product.images,
    },
    other: {
      'product:price:amount': product.price.toString(),
      'product:price:currency': 'USD',
    },
  }
}
```

---

## 12. Image Optimization

Advanced image optimization techniques.

```tsx
// app/gallery/page.tsx
import Image from 'next/image'

interface GalleryImage {
  id: string
  url: string
  title: string
  width: number
  height: number
}

async function getGalleryImages(): Promise<GalleryImage[]> {
  const res = await fetch('https://api.example.com/gallery')
  return res.json()
}

export default async function GalleryPage() {
  const images = await getGalleryImages()

  return (
    <div className="gallery">
      <h1>Photo Gallery</h1>

      <div className="gallery-grid">
        {images.map((image) => (
          <div key={image.id} className="gallery-item">
            <Image
              src={image.url}
              alt={image.title}
              width={image.width}
              height={image.height}
              sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
              quality={85}
              placeholder="blur"
              blurDataURL={generateBlurDataURL(image)}
            />
            <p>{image.title}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

// Hero image with priority loading
export function HeroSection() {
  return (
    <section className="hero">
      <Image
        src="/hero-background.jpg"
        alt="Hero background"
        fill
        style={{ objectFit: 'cover' }}
        priority
        quality={90}
      />
      <div className="hero-content">
        <h1>Welcome to Our Site</h1>
      </div>
    </section>
  )
}

// Responsive images with art direction
export function ResponsiveHero() {
  return (
    <div className="responsive-hero">
      <picture>
        <source
          media="(max-width: 768px)"
          srcSet="/hero-mobile.jpg"
        />
        <source
          media="(min-width: 769px)"
          srcSet="/hero-desktop.jpg"
        />
        <Image
          src="/hero-desktop.jpg"
          alt="Hero"
          width={1920}
          height={1080}
          priority
        />
      </picture>
    </div>
  )
}

// Product grid with lazy loading
export function ProductGrid({ products }) {
  return (
    <div className="product-grid">
      {products.map((product, index) => (
        <div key={product.id} className="product-card">
          <Image
            src={product.image}
            alt={product.name}
            width={400}
            height={400}
            loading={index < 4 ? 'eager' : 'lazy'}
            quality={80}
          />
          <h3>{product.name}</h3>
          <p>${product.price}</p>
        </div>
      ))}
    </div>
  )
}

// Helper function to generate blur data URL
function generateBlurDataURL(image: GalleryImage): string {
  // In production, generate this server-side
  return `data:image/svg+xml;base64,${Buffer.from(
    `<svg width="${image.width}" height="${image.height}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#f0f0f0"/>
    </svg>`
  ).toString('base64')}`
}

// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
      },
    ],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
}
```

---

## 13. Middleware for Rate Limiting

Implementing rate limiting and security with middleware.

```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

// Create rate limiter
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
  analytics: true,
})

export async function middleware(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1'
  const { success, pending, limit, reset, remaining } = await ratelimit.limit(
    `ratelimit_${ip}`
  )

  // Add rate limit headers
  const response = success
    ? NextResponse.next()
    : NextResponse.json(
        { error: 'Too Many Requests' },
        { status: 429 }
      )

  response.headers.set('X-RateLimit-Limit', limit.toString())
  response.headers.set('X-RateLimit-Remaining', remaining.toString())
  response.headers.set('X-RateLimit-Reset', reset.toString())

  return response
}

export const config = {
  matcher: '/api/:path*',
}

// middleware-auth.ts (Advanced example)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { verifySession } from './lib/auth'

const publicPaths = ['/login', '/register', '/about', '/']
const apiPublicPaths = ['/api/auth/login', '/api/auth/register']

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Security headers
  const response = NextResponse.next()
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=()'
  )

  // Skip auth check for public paths
  if (
    publicPaths.some((path) => pathname.startsWith(path)) ||
    apiPublicPaths.some((path) => pathname === path)
  ) {
    return response
  }

  // Check authentication
  const token = request.cookies.get('session')?.value

  if (!token) {
    if (pathname.startsWith('/api/')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Verify session
  const session = await verifySession(token)

  if (!session) {
    if (pathname.startsWith('/api/')) {
      return NextResponse.json({ error: 'Invalid session' }, { status: 401 })
    }
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add user info to request headers
  response.headers.set('X-User-Id', session.userId as string)

  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

---

## 14. E-commerce Product Catalog

Complete e-commerce implementation with filtering and pagination.

```tsx
// app/products/page.tsx
import { Suspense } from 'react'
import ProductGrid from './ProductGrid'
import Filters from './Filters'
import Pagination from './Pagination'

interface SearchParams {
  page?: string
  category?: string
  minPrice?: string
  maxPrice?: string
  sort?: string
  search?: string
}

export default function ProductsPage({
  searchParams,
}: {
  searchParams: SearchParams
}) {
  return (
    <div className="products-page">
      <h1>Products</h1>

      <div className="products-layout">
        <aside className="filters-sidebar">
          <Filters />
        </aside>

        <div className="products-content">
          <Suspense fallback={<ProductGridSkeleton />}>
            <ProductGrid searchParams={searchParams} />
          </Suspense>
        </div>
      </div>
    </div>
  )
}

// app/products/ProductGrid.tsx
interface Product {
  id: string
  name: string
  price: number
  image: string
  category: string
  rating: number
  inStock: boolean
}

interface ProductsResponse {
  products: Product[]
  total: number
  page: number
  totalPages: number
}

async function getProducts(
  searchParams: SearchParams
): Promise<ProductsResponse> {
  const params = new URLSearchParams()

  if (searchParams.page) params.set('page', searchParams.page)
  if (searchParams.category) params.set('category', searchParams.category)
  if (searchParams.minPrice) params.set('minPrice', searchParams.minPrice)
  if (searchParams.maxPrice) params.set('maxPrice', searchParams.maxPrice)
  if (searchParams.sort) params.set('sort', searchParams.sort)
  if (searchParams.search) params.set('search', searchParams.search)

  const res = await fetch(`https://api.example.com/products?${params}`, {
    next: { revalidate: 300 }, // Revalidate every 5 minutes
  })

  return res.json()
}

export default async function ProductGrid({
  searchParams,
}: {
  searchParams: SearchParams
}) {
  const data = await getProducts(searchParams)

  if (data.products.length === 0) {
    return (
      <div className="no-products">
        <p>No products found</p>
      </div>
    )
  }

  return (
    <>
      <div className="products-grid">
        {data.products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      <Pagination
        currentPage={data.page}
        totalPages={data.totalPages}
        total={data.total}
      />
    </>
  )
}

// app/products/ProductCard.tsx
import Image from 'next/image'
import Link from 'next/link'
import AddToCartButton from './AddToCartButton'

export default function ProductCard({ product }: { product: Product }) {
  return (
    <div className="product-card">
      <Link href={`/products/${product.id}`}>
        <Image
          src={product.image}
          alt={product.name}
          width={400}
          height={400}
          className="product-image"
        />
      </Link>

      <div className="product-info">
        <h3>
          <Link href={`/products/${product.id}`}>{product.name}</Link>
        </h3>

        <div className="product-rating">
          {'⭐'.repeat(Math.round(product.rating))}
          <span>{product.rating}</span>
        </div>

        <div className="product-footer">
          <span className="price">${product.price}</span>

          {product.inStock ? (
            <AddToCartButton productId={product.id} />
          ) : (
            <span className="out-of-stock">Out of Stock</span>
          )}
        </div>
      </div>
    </div>
  )
}

// app/products/[id]/page.tsx
import Image from 'next/image'
import { notFound } from 'next/navigation'
import AddToCartButton from '../AddToCartButton'
import RelatedProducts from './RelatedProducts'

async function getProduct(id: string) {
  const res = await fetch(`https://api.example.com/products/${id}`)
  if (!res.ok) return null
  return res.json()
}

export async function generateMetadata({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  if (!product) {
    return { title: 'Product Not Found' }
  }

  return {
    title: `${product.name} - Buy Now`,
    description: product.description,
  }
}

export default async function ProductPage({
  params,
}: {
  params: { id: string }
}) {
  const product = await getProduct(params.id)

  if (!product) {
    notFound()
  }

  return (
    <div className="product-page">
      <div className="product-details">
        <div className="product-images">
          <Image
            src={product.image}
            alt={product.name}
            width={600}
            height={600}
            priority
          />
        </div>

        <div className="product-info">
          <h1>{product.name}</h1>

          <div className="product-rating">
            {'⭐'.repeat(Math.round(product.rating))}
            <span>({product.reviewCount} reviews)</span>
          </div>

          <p className="price">${product.price}</p>

          <p className="description">{product.description}</p>

          <div className="product-meta">
            <p>Category: {product.category}</p>
            <p>SKU: {product.sku}</p>
            <p>
              Availability:{' '}
              {product.inStock ? 'In Stock' : 'Out of Stock'}
            </p>
          </div>

          {product.inStock && (
            <AddToCartButton productId={product.id} />
          )}
        </div>
      </div>

      <section className="related-products">
        <h2>Related Products</h2>
        <Suspense fallback={<div>Loading...</div>}>
          <RelatedProducts category={product.category} currentId={product.id} />
        </Suspense>
      </section>
    </div>
  )
}

// app/products/AddToCartButton.tsx
'use client'

import { useState } from 'react'

export default function AddToCartButton({ productId }: { productId: string }) {
  const [isAdding, setIsAdding] = useState(false)

  async function handleAddToCart() {
    setIsAdding(true)

    try {
      await fetch('/api/cart', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ productId, quantity: 1 }),
      })

      // Show success message
      alert('Added to cart!')
    } catch (error) {
      alert('Failed to add to cart')
    } finally {
      setIsAdding(false)
    }
  }

  return (
    <button
      onClick={handleAddToCart}
      disabled={isAdding}
      className="add-to-cart-button"
    >
      {isAdding ? 'Adding...' : 'Add to Cart'}
    </button>
  )
}
```

---

## 15. Blog with MDX Content

Building a blog with MDX support for rich content.

```tsx
// app/blog/[slug]/page.tsx
import { MDXRemote } from 'next-mdx-remote/rsc'
import { notFound } from 'next/navigation'
import { highlight } from 'sugar-high'

interface Post {
  slug: string
  title: string
  date: string
  content: string
  author: string
}

async function getPost(slug: string): Promise<Post | null> {
  try {
    const res = await fetch(`https://api.example.com/posts/${slug}`)
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}

// Custom MDX components
const components = {
  h1: (props) => <h1 className="text-4xl font-bold mb-4" {...props} />,
  h2: (props) => <h2 className="text-3xl font-bold mb-3" {...props} />,
  p: (props) => <p className="mb-4 leading-relaxed" {...props} />,
  code: ({ children, ...props }) => {
    const codeHTML = highlight(children)
    return <code dangerouslySetInnerHTML={{ __html: codeHTML }} {...props} />
  },
  pre: (props) => (
    <pre className="bg-gray-900 text-white p-4 rounded-lg overflow-x-auto mb-4" {...props} />
  ),
  a: (props) => (
    <a className="text-blue-600 hover:underline" {...props} />
  ),
  ul: (props) => <ul className="list-disc list-inside mb-4" {...props} />,
  ol: (props) => <ol className="list-decimal list-inside mb-4" {...props} />,
  blockquote: (props) => (
    <blockquote className="border-l-4 border-gray-300 pl-4 italic my-4" {...props} />
  ),
  img: (props) => (
    <img className="rounded-lg my-4 w-full" {...props} />
  ),
}

export default async function BlogPost({
  params,
}: {
  params: { slug: string }
}) {
  const post = await getPost(params.slug)

  if (!post) {
    notFound()
  }

  return (
    <article className="blog-post max-w-3xl mx-auto px-4 py-8">
      <header className="mb-8">
        <h1 className="text-5xl font-bold mb-4">{post.title}</h1>
        <div className="text-gray-600">
          <span>By {post.author}</span>
          <span className="mx-2">•</span>
          <time>{new Date(post.date).toLocaleDateString()}</time>
        </div>
      </header>

      <div className="prose prose-lg">
        <MDXRemote source={post.content} components={components} />
      </div>
    </article>
  )
}
```

---

## 16. Dashboard with Protected Routes

Complete dashboard implementation with authentication.

```tsx
// app/dashboard/layout.tsx
import { getCurrentUser } from '@/lib/auth'
import { redirect } from 'next/navigation'
import DashboardNav from './DashboardNav'
import UserMenu from './UserMenu'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getCurrentUser()

  if (!user) {
    redirect('/login')
  }

  return (
    <div className="dashboard-layout">
      <aside className="dashboard-sidebar">
        <div className="logo">
          <h1>Dashboard</h1>
        </div>
        <DashboardNav />
      </aside>

      <div className="dashboard-main">
        <header className="dashboard-header">
          <h2>Welcome, {user.name}</h2>
          <UserMenu user={user} />
        </header>

        <main className="dashboard-content">{children}</main>
      </div>
    </div>
  )
}

// app/dashboard/page.tsx
import { Suspense } from 'react'
import StatsCard from './StatsCard'
import RecentActivity from './RecentActivity'
import QuickActions from './QuickActions'

export default function DashboardPage() {
  return (
    <div className="dashboard-page">
      <div className="stats-grid">
        <Suspense fallback={<StatsCardSkeleton />}>
          <StatsCard type="users" />
        </Suspense>
        <Suspense fallback={<StatsCardSkeleton />}>
          <StatsCard type="revenue" />
        </Suspense>
        <Suspense fallback={<StatsCardSkeleton />}>
          <StatsCard type="orders" />
        </Suspense>
        <Suspense fallback={<StatsCardSkeleton />}>
          <StatsCard type="growth" />
        </Suspense>
      </div>

      <div className="dashboard-grid">
        <Suspense fallback={<div>Loading...</div>}>
          <RecentActivity />
        </Suspense>

        <QuickActions />
      </div>
    </div>
  )
}
```

---

## 17. Search with Server Actions

Implementing search functionality with Server Actions.

```tsx
// app/search/actions.ts
'use server'

import { redirect } from 'next/navigation'

export async function searchAction(formData: FormData) {
  const query = formData.get('query') as string

  if (!query) {
    return { error: 'Query is required' }
  }

  redirect(`/search/results?q=${encodeURIComponent(query)}`)
}

// app/search/page.tsx
import { searchAction } from './actions'
import SearchForm from './SearchForm'

export default function SearchPage() {
  return (
    <div className="search-page">
      <h1>Search</h1>
      <SearchForm action={searchAction} />
    </div>
  )
}

// app/search/results/page.tsx
import { Suspense } from 'react'

async function searchResults(query: string) {
  const res = await fetch(
    `https://api.example.com/search?q=${encodeURIComponent(query)}`
  )
  return res.json()
}

export default function SearchResultsPage({
  searchParams,
}: {
  searchParams: { q: string }
}) {
  return (
    <div className="search-results">
      <h1>Search Results for "{searchParams.q}"</h1>
      <Suspense fallback={<div>Searching...</div>}>
        <Results query={searchParams.q} />
      </Suspense>
    </div>
  )
}

async function Results({ query }: { query: string }) {
  const results = await searchResults(query)

  return (
    <div className="results-list">
      {results.map((result) => (
        <div key={result.id} className="result-item">
          <h3>{result.title}</h3>
          <p>{result.excerpt}</p>
        </div>
      ))}
    </div>
  )
}
```

---

## 18. Internationalization (i18n)

Implementing multi-language support.

```tsx
// app/[lang]/layout.tsx
import { i18n } from '@/i18n-config'

export async function generateStaticParams() {
  return i18n.locales.map((locale) => ({ lang: locale }))
}

export default function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: { lang: string }
}) {
  return (
    <html lang={params.lang}>
      <body>{children}</body>
    </html>
  )
}

// app/[lang]/page.tsx
import { getDictionary } from '@/get-dictionary'

export default async function HomePage({
  params,
}: {
  params: { lang: string }
}) {
  const dict = await getDictionary(params.lang)

  return (
    <div>
      <h1>{dict.home.title}</h1>
      <p>{dict.home.description}</p>
    </div>
  )
}
```

---

## 19. Real-time Updates with Server-Sent Events

Implementing real-time features.

```tsx
// app/api/events/route.ts
export async function GET() {
  const encoder = new TextEncoder()

  const stream = new ReadableStream({
    async start(controller) {
      const interval = setInterval(() => {
        const data = {
          time: new Date().toISOString(),
          value: Math.random(),
        }

        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify(data)}\n\n`)
        )
      }, 1000)

      // Clean up on close
      return () => clearInterval(interval)
    },
  })

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  })
}
```

---

## 20. Advanced Caching Strategies

Implementing sophisticated caching patterns.

```tsx
// app/actions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

export async function revalidateProduct(productId: string) {
  revalidateTag(`product-${productId}`)
  revalidatePath(`/products/${productId}`)
}

// Fetch with tags
async function getProduct(id: string) {
  const res = await fetch(`https://api.example.com/products/${id}`, {
    next: { tags: [`product-${id}`, 'products'] }
  })
  return res.json()
}

// Revalidate all products
export async function revalidateAllProducts() {
  revalidateTag('products')
}
```

---

This examples file provides comprehensive, production-ready code samples for all major Next.js development patterns.
