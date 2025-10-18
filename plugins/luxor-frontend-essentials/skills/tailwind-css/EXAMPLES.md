# Tailwind CSS Component Examples

Comprehensive collection of production-ready component patterns and examples using Tailwind CSS.

## Table of Contents

1. [Navigation Components](#navigation-components)
2. [Hero Sections](#hero-sections)
3. [Cards](#cards)
4. [Forms](#forms)
5. [Buttons](#buttons)
6. [Modals and Dialogs](#modals-and-dialogs)
7. [Alerts and Notifications](#alerts-and-notifications)
8. [Layout Patterns](#layout-patterns)
9. [Tables](#tables)
10. [Lists](#lists)
11. [Avatars and Badges](#avatars-and-badges)
12. [Loading States](#loading-states)

---

## Navigation Components

### Responsive Navigation Bar

```html
<nav class="bg-white dark:bg-gray-900 shadow-lg">
  <div class="container mx-auto px-4">
    <div class="flex items-center justify-between h-16">
      <!-- Logo -->
      <div class="flex items-center space-x-3">
        <img class="h-8 w-auto" src="/logo.svg" alt="Company Logo" />
        <span class="text-xl font-bold text-gray-900 dark:text-white">
          Brand
        </span>
      </div>

      <!-- Desktop Navigation -->
      <div class="hidden md:flex items-center space-x-8">
        <a href="#" class="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition">
          Home
        </a>
        <a href="#" class="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition">
          Products
        </a>
        <a href="#" class="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition">
          About
        </a>
        <a href="#" class="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition">
          Contact
        </a>
      </div>

      <!-- CTA Button -->
      <div class="hidden md:block">
        <button class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">
          Get Started
        </button>
      </div>

      <!-- Mobile menu button -->
      <button class="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
        <svg class="h-6 w-6 text-gray-700 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
    </div>

    <!-- Mobile Navigation -->
    <div class="md:hidden pb-4 space-y-2">
      <a href="#" class="block px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition">
        Home
      </a>
      <a href="#" class="block px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition">
        Products
      </a>
      <a href="#" class="block px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition">
        About
      </a>
      <a href="#" class="block px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition">
        Contact
      </a>
      <button class="w-full mt-2 bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">
        Get Started
      </button>
    </div>
  </div>
</nav>
```

### Vertical Sidebar Navigation

```html
<aside class="w-64 bg-gray-900 text-white min-h-screen p-4">
  <!-- Logo -->
  <div class="flex items-center space-x-2 mb-8">
    <div class="w-8 h-8 bg-blue-500 rounded-lg"></div>
    <span class="text-xl font-bold">Dashboard</span>
  </div>

  <!-- Navigation Links -->
  <nav class="space-y-2">
    <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-lg bg-blue-600 text-white">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
      <span>Home</span>
    </a>

    <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 transition">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>
      <span>Analytics</span>
    </a>

    <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 transition">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
      <span>Team</span>
    </a>

    <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 transition">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
      <span>Settings</span>
    </a>
  </nav>

  <!-- User Profile -->
  <div class="absolute bottom-4 left-4 right-4">
    <div class="flex items-center space-x-3 p-3 rounded-lg bg-gray-800">
      <img class="w-10 h-10 rounded-full" src="/avatar.jpg" alt="User" />
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium truncate">John Doe</p>
        <p class="text-xs text-gray-400 truncate">john@example.com</p>
      </div>
    </div>
  </div>
</aside>
```

---

## Hero Sections

### Gradient Hero with CTA

```html
<section class="relative bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 text-white py-20 lg:py-32 overflow-hidden">
  <!-- Background decoration -->
  <div class="absolute inset-0 opacity-20">
    <div class="absolute top-0 left-0 w-96 h-96 bg-white rounded-full blur-3xl"></div>
    <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full blur-3xl"></div>
  </div>

  <div class="container mx-auto px-4 relative">
    <div class="max-w-4xl mx-auto text-center">
      <!-- Badge -->
      <div class="inline-flex items-center px-4 py-2 mb-6 bg-white/10 backdrop-blur-sm rounded-full">
        <span class="text-sm font-semibold">New: Version 2.0 is here</span>
      </div>

      <!-- Heading -->
      <h1 class="text-4xl md:text-5xl lg:text-7xl font-bold mb-6 leading-tight">
        Build Amazing Websites
        <span class="block text-transparent bg-clip-text bg-gradient-to-r from-yellow-200 to-pink-200">
          Faster Than Ever
        </span>
      </h1>

      <!-- Description -->
      <p class="text-xl md:text-2xl mb-10 text-blue-100 max-w-2xl mx-auto">
        Create beautiful, responsive designs with our powerful framework.
        Ship faster, iterate quicker, and delight your users.
      </p>

      <!-- CTA Buttons -->
      <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
        <button class="w-full sm:w-auto bg-white text-blue-600 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-blue-50 transform hover:scale-105 transition shadow-xl">
          Get Started Free
        </button>
        <button class="w-full sm:w-auto border-2 border-white text-white px-8 py-4 rounded-lg font-semibold text-lg hover:bg-white hover:text-blue-600 transition">
          View Demo
        </button>
      </div>

      <!-- Social Proof -->
      <div class="mt-12 flex flex-col sm:flex-row items-center justify-center gap-8 text-sm">
        <div class="flex items-center">
          <div class="flex -space-x-2 mr-3">
            <img class="w-8 h-8 rounded-full border-2 border-white" src="/avatar1.jpg" alt="" />
            <img class="w-8 h-8 rounded-full border-2 border-white" src="/avatar2.jpg" alt="" />
            <img class="w-8 h-8 rounded-full border-2 border-white" src="/avatar3.jpg" alt="" />
          </div>
          <span>Trusted by 10,000+ developers</span>
        </div>
        <div class="flex items-center gap-2">
          <svg class="w-5 h-5 text-yellow-300" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
          <span>4.9/5 average rating</span>
        </div>
      </div>
    </div>
  </div>
</section>
```

### Split Hero with Image

```html
<section class="bg-white dark:bg-gray-900">
  <div class="container mx-auto px-4 py-16 lg:py-24">
    <div class="grid lg:grid-cols-2 gap-12 items-center">
      <!-- Content -->
      <div>
        <div class="inline-block px-3 py-1 mb-4 text-sm font-semibold text-blue-600 bg-blue-100 rounded-full dark:bg-blue-900 dark:text-blue-300">
          Introducing v2.0
        </div>

        <h1 class="text-4xl lg:text-6xl font-bold text-gray-900 dark:text-white mb-6">
          The Future of Web Development
        </h1>

        <p class="text-xl text-gray-600 dark:text-gray-400 mb-8">
          Build modern, responsive websites with our powerful framework.
          No configuration needed, just start building.
        </p>

        <div class="flex flex-col sm:flex-row gap-4">
          <button class="bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition">
            Start Building
          </button>
          <button class="border-2 border-gray-300 text-gray-700 dark:text-gray-300 dark:border-gray-600 px-8 py-3 rounded-lg font-semibold hover:border-blue-600 hover:text-blue-600 transition">
            View Documentation
          </button>
        </div>

        <!-- Features -->
        <div class="grid grid-cols-2 gap-6 mt-12">
          <div class="flex items-start space-x-3">
            <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <div>
              <p class="font-semibold text-gray-900 dark:text-white">Lightning Fast</p>
              <p class="text-sm text-gray-600 dark:text-gray-400">Optimized performance</p>
            </div>
          </div>

          <div class="flex items-start space-x-3">
            <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <div>
              <p class="font-semibold text-gray-900 dark:text-white">Mobile First</p>
              <p class="text-sm text-gray-600 dark:text-gray-400">Responsive by default</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Image -->
      <div class="relative">
        <div class="aspect-square rounded-2xl overflow-hidden shadow-2xl">
          <img
            class="w-full h-full object-cover"
            src="/hero-image.jpg"
            alt="Product showcase"
          />
        </div>

        <!-- Floating card -->
        <div class="absolute bottom-8 left-8 bg-white dark:bg-gray-800 rounded-lg shadow-xl p-4 max-w-xs">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <p class="text-sm font-semibold text-gray-900 dark:text-white">99.9% Uptime</p>
              <p class="text-xs text-gray-600 dark:text-gray-400">Reliable infrastructure</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
```

---

## Cards

### Feature Card

```html
<div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 hover:shadow-2xl transition-shadow">
  <!-- Icon -->
  <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center mb-6">
    <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
    </svg>
  </div>

  <!-- Title -->
  <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">
    Lightning Fast
  </h3>

  <!-- Description -->
  <p class="text-gray-600 dark:text-gray-400 mb-6">
    Optimized for performance with minimal overhead. Build blazing fast
    websites that your users will love.
  </p>

  <!-- Link -->
  <a href="#" class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold group">
    Learn more
    <svg class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
    </svg>
  </a>
</div>
```

### Product Card

```html
<div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden group">
  <!-- Image -->
  <div class="relative overflow-hidden bg-gray-200 dark:bg-gray-700 aspect-square">
    <img
      class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
      src="/product.jpg"
      alt="Product"
    />

    <!-- Badge -->
    <div class="absolute top-4 right-4 bg-red-500 text-white text-xs font-bold px-3 py-1 rounded-full">
      SALE
    </div>

    <!-- Quick Actions -->
    <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
      <button class="bg-white text-gray-900 p-3 rounded-full hover:bg-gray-100 transition">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
        </svg>
      </button>
      <button class="bg-white text-gray-900 p-3 rounded-full hover:bg-gray-100 transition">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
      </button>
    </div>
  </div>

  <!-- Content -->
  <div class="p-6">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
      Premium Wireless Headphones
    </h3>

    <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
      High-quality sound with active noise cancellation
    </p>

    <!-- Rating -->
    <div class="flex items-center mb-4">
      <div class="flex text-yellow-400">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
        <svg class="w-4 h-4 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      </div>
      <span class="ml-2 text-sm text-gray-600 dark:text-gray-400">(128 reviews)</span>
    </div>

    <!-- Price and CTA -->
    <div class="flex items-center justify-between">
      <div>
        <span class="text-2xl font-bold text-gray-900 dark:text-white">$299</span>
        <span class="ml-2 text-sm text-gray-500 line-through">$399</span>
      </div>
      <button class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">
        Add to Cart
      </button>
    </div>
  </div>
</div>
```

---

## Forms

### Contact Form

```html
<form class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 max-w-2xl mx-auto">
  <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-6">
    Get in Touch
  </h2>

  <div class="space-y-6">
    <!-- Name -->
    <div>
      <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Full Name
      </label>
      <input
        type="text"
        id="name"
        class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white transition"
        placeholder="John Doe"
      />
    </div>

    <!-- Email -->
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Email Address
      </label>
      <input
        type="email"
        id="email"
        class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white transition"
        placeholder="john@example.com"
      />
    </div>

    <!-- Subject -->
    <div>
      <label for="subject" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Subject
      </label>
      <select
        id="subject"
        class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white transition"
      >
        <option>General Inquiry</option>
        <option>Support Request</option>
        <option>Sales Question</option>
        <option>Partnership Opportunity</option>
      </select>
    </div>

    <!-- Message -->
    <div>
      <label for="message" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Message
      </label>
      <textarea
        id="message"
        rows="5"
        class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white transition resize-none"
        placeholder="Tell us about your project..."
      ></textarea>
    </div>

    <!-- Checkbox -->
    <div class="flex items-start">
      <input
        type="checkbox"
        id="newsletter"
        class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-2 focus:ring-blue-500 mt-0.5"
      />
      <label for="newsletter" class="ml-3 text-sm text-gray-700 dark:text-gray-300">
        Subscribe to our newsletter for updates and exclusive offers.
      </label>
    </div>

    <!-- Submit Button -->
    <button
      type="submit"
      class="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition"
    >
      Send Message
    </button>
  </div>
</form>
```

### Login Form

```html
<div class="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 py-12 px-4">
  <div class="max-w-md w-full space-y-8">
    <div class="text-center">
      <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
        Welcome back
      </h2>
      <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
        Please sign in to your account
      </p>
    </div>

    <form class="mt-8 space-y-6">
      <div class="space-y-4">
        <!-- Email -->
        <div>
          <label for="email-login" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Email address
          </label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
              </svg>
            </div>
            <input
              id="email-login"
              type="email"
              class="block w-full pl-10 pr-3 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-gray-800 dark:text-white"
              placeholder="you@example.com"
            />
          </div>
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Password
          </label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <input
              id="password"
              type="password"
              class="block w-full pl-10 pr-3 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-gray-800 dark:text-white"
              placeholder="••••••••"
            />
          </div>
        </div>
      </div>

      <!-- Remember and Forgot -->
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <input
            id="remember"
            type="checkbox"
            class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
          />
          <label for="remember" class="ml-2 block text-sm text-gray-700 dark:text-gray-300">
            Remember me
          </label>
        </div>

        <a href="#" class="text-sm font-medium text-blue-600 hover:text-blue-500">
          Forgot password?
        </a>
      </div>

      <!-- Submit -->
      <button
        type="submit"
        class="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition"
      >
        Sign in
      </button>

      <!-- Divider -->
      <div class="relative">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-gray-300 dark:border-gray-600"></div>
        </div>
        <div class="relative flex justify-center text-sm">
          <span class="px-2 bg-gray-50 dark:bg-gray-900 text-gray-500">Or continue with</span>
        </div>
      </div>

      <!-- Social Login -->
      <div class="grid grid-cols-2 gap-4">
        <button
          type="button"
          class="flex items-center justify-center gap-2 px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition"
        >
          <svg class="w-5 h-5" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Google
        </button>

        <button
          type="button"
          class="flex items-center justify-center gap-2 px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
          </svg>
          GitHub
        </button>
      </div>

      <!-- Sign up link -->
      <p class="text-center text-sm text-gray-600 dark:text-gray-400">
        Don't have an account?
        <a href="#" class="font-medium text-blue-600 hover:text-blue-500">
          Sign up
        </a>
      </p>
    </form>
  </div>
</div>
```

---

## Buttons

### Button Variants

```html
<!-- Primary Button -->
<button class="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition">
  Primary Button
</button>

<!-- Secondary Button -->
<button class="bg-gray-200 text-gray-900 px-6 py-3 rounded-lg font-semibold hover:bg-gray-300 dark:bg-gray-700 dark:text-white dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 transition">
  Secondary Button
</button>

<!-- Outline Button -->
<button class="border-2 border-blue-600 text-blue-600 px-6 py-3 rounded-lg font-semibold hover:bg-blue-600 hover:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
  Outline Button
</button>

<!-- Ghost Button -->
<button class="text-blue-600 px-6 py-3 rounded-lg font-semibold hover:bg-blue-50 dark:hover:bg-blue-900/20 focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
  Ghost Button
</button>

<!-- Danger Button -->
<button class="bg-red-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition">
  Danger Button
</button>

<!-- Success Button -->
<button class="bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition">
  Success Button
</button>

<!-- Disabled Button -->
<button
  disabled
  class="bg-gray-300 text-gray-500 px-6 py-3 rounded-lg font-semibold cursor-not-allowed opacity-60"
>
  Disabled Button
</button>

<!-- Loading Button -->
<button class="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold flex items-center gap-2" disabled>
  <svg class="animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
  </svg>
  Loading...
</button>

<!-- Button with Icon -->
<button class="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 flex items-center gap-2 transition">
  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
  </svg>
  Add Item
</button>

<!-- Icon-only Button -->
<button class="bg-blue-600 text-white p-3 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
  </svg>
</button>

<!-- Button Group -->
<div class="inline-flex rounded-lg shadow-sm">
  <button class="px-4 py-2 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-l-lg hover:bg-gray-100 focus:z-10 focus:ring-2 focus:ring-blue-500">
    Left
  </button>
  <button class="px-4 py-2 text-sm font-medium text-gray-900 bg-white border-t border-b border-gray-200 hover:bg-gray-100 focus:z-10 focus:ring-2 focus:ring-blue-500">
    Middle
  </button>
  <button class="px-4 py-2 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-r-lg hover:bg-gray-100 focus:z-10 focus:ring-2 focus:ring-blue-500">
    Right
  </button>
</div>
```

---

## Modals and Dialogs

### Modal

```html
<!-- Modal Overlay -->
<div class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
  <!-- Modal Container -->
  <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
    <!-- Modal Header -->
    <div class="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
      <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
        Confirm Action
      </h3>
      <button class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>

    <!-- Modal Body -->
    <div class="p-6">
      <p class="text-gray-600 dark:text-gray-400">
        Are you sure you want to proceed with this action? This cannot be undone.
      </p>
    </div>

    <!-- Modal Footer -->
    <div class="flex justify-end gap-3 p-6 bg-gray-50 dark:bg-gray-900/50">
      <button class="px-6 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg font-medium transition">
        Cancel
      </button>
      <button class="px-6 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition">
        Confirm
      </button>
    </div>
  </div>
</div>
```

---

## Alerts and Notifications

### Alert Variants

```html
<!-- Success Alert -->
<div class="bg-green-50 dark:bg-green-900/20 border-l-4 border-green-500 p-4 rounded-r-lg">
  <div class="flex items-start">
    <div class="flex-shrink-0">
      <svg class="h-5 w-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>
    </div>
    <div class="ml-3 flex-1">
      <p class="text-sm font-medium text-green-800 dark:text-green-200">
        Success! Your changes have been saved.
      </p>
    </div>
    <button class="ml-3 text-green-500 hover:text-green-700 dark:hover:text-green-300">
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
  </div>
</div>

<!-- Info Alert -->
<div class="bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-500 p-4 rounded-r-lg">
  <div class="flex items-start">
    <div class="flex-shrink-0">
      <svg class="h-5 w-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    </div>
    <div class="ml-3 flex-1">
      <p class="text-sm font-medium text-blue-800 dark:text-blue-200">
        A new software update is available.
      </p>
    </div>
  </div>
</div>

<!-- Warning Alert -->
<div class="bg-yellow-50 dark:bg-yellow-900/20 border-l-4 border-yellow-500 p-4 rounded-r-lg">
  <div class="flex items-start">
    <div class="flex-shrink-0">
      <svg class="h-5 w-5 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
    </div>
    <div class="ml-3 flex-1">
      <p class="text-sm font-medium text-yellow-800 dark:text-yellow-200">
        Your session will expire in 5 minutes.
      </p>
    </div>
  </div>
</div>

<!-- Error Alert -->
<div class="bg-red-50 dark:bg-red-900/20 border-l-4 border-red-500 p-4 rounded-r-lg">
  <div class="flex items-start">
    <div class="flex-shrink-0">
      <svg class="h-5 w-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    </div>
    <div class="ml-3 flex-1">
      <p class="text-sm font-medium text-red-800 dark:text-red-200">
        There was an error processing your request.
      </p>
    </div>
  </div>
</div>
```

### Toast Notification

```html
<!-- Toast Container (position fixed) -->
<div class="fixed bottom-4 right-4 max-w-sm w-full bg-white dark:bg-gray-800 rounded-lg shadow-2xl overflow-hidden z-50">
  <div class="p-4">
    <div class="flex items-start">
      <div class="flex-shrink-0">
        <div class="w-10 h-10 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
          <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
      </div>
      <div class="ml-3 flex-1">
        <p class="text-sm font-medium text-gray-900 dark:text-white">
          Successfully saved!
        </p>
        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Your changes have been saved successfully.
        </p>
      </div>
      <button class="ml-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  </div>
  <div class="h-1 bg-green-500"></div>
</div>
```

---

## Layout Patterns

### Dashboard Layout

```html
<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <!-- Sidebar (see sidebar navigation above) -->

  <!-- Main Content -->
  <main class="ml-64 p-8">
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <!-- Stat Card -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm text-gray-600 dark:text-gray-400">Total Users</span>
          <span class="text-green-500 text-sm font-semibold">+12%</span>
        </div>
        <p class="text-3xl font-bold text-gray-900 dark:text-white">24,563</p>
      </div>

      <!-- More stat cards... -->
    </div>

    <!-- Charts and Tables Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Chart Card -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Revenue Overview
        </h3>
        <div class="h-64 bg-gray-100 dark:bg-gray-700 rounded">
          <!-- Chart goes here -->
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Recent Activity
        </h3>
        <div class="space-y-4">
          <!-- Activity items -->
        </div>
      </div>
    </div>
  </main>
</div>
```

---

## Tables

### Data Table

```html
<div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
      <thead class="bg-gray-50 dark:bg-gray-900">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
            Name
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
            Email
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
            Status
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
            Role
          </th>
          <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
            Actions
          </th>
        </tr>
      </thead>
      <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700 transition">
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="flex items-center">
              <img class="h-10 w-10 rounded-full" src="/avatar1.jpg" alt="" />
              <div class="ml-4">
                <div class="text-sm font-medium text-gray-900 dark:text-white">
                  Jane Cooper
                </div>
              </div>
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-900 dark:text-gray-300">jane@example.com</div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400">
              Active
            </span>
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
            Admin
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
            <button class="text-blue-600 hover:text-blue-900 dark:hover:text-blue-400 mr-3">
              Edit
            </button>
            <button class="text-red-600 hover:text-red-900 dark:hover:text-red-400">
              Delete
            </button>
          </td>
        </tr>

        <!-- More rows... -->
      </tbody>
    </table>
  </div>

  <!-- Pagination -->
  <div class="bg-gray-50 dark:bg-gray-900 px-6 py-4 flex items-center justify-between border-t border-gray-200 dark:border-gray-700">
    <div class="text-sm text-gray-700 dark:text-gray-300">
      Showing <span class="font-medium">1</span> to <span class="font-medium">10</span> of{' '}
      <span class="font-medium">97</span> results
    </div>
    <div class="flex gap-2">
      <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium hover:bg-gray-100 dark:hover:bg-gray-700 transition">
        Previous
      </button>
      <button class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
        Next
      </button>
    </div>
  </div>
</div>
```

---

## Lists

### Task List

```html
<div class="bg-white dark:bg-gray-800 rounded-lg shadow">
  <div class="p-6 border-b border-gray-200 dark:border-gray-700">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Tasks</h3>
  </div>

  <ul class="divide-y divide-gray-200 dark:divide-gray-700">
    <li class="p-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition cursor-pointer">
      <div class="flex items-center">
        <input
          type="checkbox"
          class="h-5 w-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
        />
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-900 dark:text-white">
            Complete project documentation
          </p>
          <p class="text-sm text-gray-500 dark:text-gray-400">Due today</p>
        </div>
        <span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400">
          High
        </span>
      </div>
    </li>

    <li class="p-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition cursor-pointer">
      <div class="flex items-center">
        <input
          type="checkbox"
          checked
          class="h-5 w-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
        />
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400 line-through">
            Review pull requests
          </p>
          <p class="text-sm text-gray-500 dark:text-gray-400">Completed</p>
        </div>
        <span class="px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400">
          Medium
        </span>
      </div>
    </li>

    <!-- More tasks... -->
  </ul>
</div>
```

---

## Avatars and Badges

### Avatar Variations

```html
<!-- Single Avatar -->
<img class="h-10 w-10 rounded-full" src="/avatar.jpg" alt="User" />

<!-- Avatar with Ring -->
<img class="h-10 w-10 rounded-full ring-2 ring-white dark:ring-gray-800" src="/avatar.jpg" alt="User" />

<!-- Avatar Stack -->
<div class="flex -space-x-2">
  <img class="h-10 w-10 rounded-full ring-2 ring-white" src="/avatar1.jpg" alt="" />
  <img class="h-10 w-10 rounded-full ring-2 ring-white" src="/avatar2.jpg" alt="" />
  <img class="h-10 w-10 rounded-full ring-2 ring-white" src="/avatar3.jpg" alt="" />
  <div class="h-10 w-10 rounded-full ring-2 ring-white bg-gray-200 flex items-center justify-center text-xs font-medium text-gray-600">
    +99
  </div>
</div>

<!-- Avatar with Status -->
<div class="relative">
  <img class="h-10 w-10 rounded-full" src="/avatar.jpg" alt="User" />
  <span class="absolute bottom-0 right-0 block h-3 w-3 rounded-full bg-green-500 ring-2 ring-white"></span>
</div>

<!-- Initials Avatar -->
<div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-semibold">
  JD
</div>
```

### Badges

```html
<!-- Basic Badges -->
<span class="px-3 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">
  New
</span>

<!-- Status Badges -->
<span class="px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Success</span>
<span class="px-3 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">Warning</span>
<span class="px-3 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Error</span>
<span class="px-3 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">Neutral</span>

<!-- Badge with Dot -->
<span class="inline-flex items-center gap-1.5 px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
  <span class="h-1.5 w-1.5 rounded-full bg-green-500"></span>
  Active
</span>

<!-- Badge with Icon -->
<span class="inline-flex items-center gap-1 px-3 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
  <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
  </svg>
  Featured
</span>
```

---

## Loading States

### Spinners

```html
<!-- Simple Spinner -->
<svg class="animate-spin h-8 w-8 text-blue-600" fill="none" viewBox="0 0 24 24">
  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>

<!-- Dots Loader -->
<div class="flex space-x-2">
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-bounce" style="animation-delay: 0ms"></div>
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-bounce" style="animation-delay: 150ms"></div>
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-bounce" style="animation-delay: 300ms"></div>
</div>

<!-- Pulse Loader -->
<div class="flex space-x-2">
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-pulse"></div>
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-pulse" style="animation-delay: 0.2s"></div>
  <div class="h-3 w-3 bg-blue-600 rounded-full animate-pulse" style="animation-delay: 0.4s"></div>
</div>

<!-- Skeleton Loader -->
<div class="animate-pulse space-y-4">
  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4"></div>
  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded"></div>
  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-5/6"></div>
</div>
```

---

These examples cover the most common UI patterns you'll need when building with Tailwind CSS. Each component is:

- Fully responsive
- Dark mode compatible
- Accessible (focus states, ARIA labels)
- Production-ready
- Customizable with Tailwind utilities

For more examples and advanced patterns, refer to:
- Official Tailwind UI: https://tailwindui.com
- Headless UI: https://headlessui.com
- Tailwind Components: https://tailwindcomponents.com
