# Wireframing Examples

This document provides detailed, real-world examples of wireframes across different fidelity levels, project types, and use cases. Each example includes context, annotations, and considerations for implementation.

## Table of Contents

1. [E-Commerce Examples](#e-commerce-examples)
2. [SaaS Application Examples](#saas-application-examples)
3. [Mobile App Examples](#mobile-app-examples)
4. [Content & Media Examples](#content--media-examples)
5. [Form & Input Examples](#form--input-examples)
6. [Navigation Examples](#navigation-examples)
7. [Data Visualization Examples](#data-visualization-examples)
8. [Progressive Disclosure Examples](#progressive-disclosure-examples)
9. [Responsive Design Examples](#responsive-design-examples)
10. [Interaction Pattern Examples](#interaction-pattern-examples)

---

## E-Commerce Examples

### Example 1: Product Detail Page (High-Fidelity)

**Context**: Main product page for an e-commerce site selling consumer electronics

**Wireframe Structure**:
```
+------------------------------------------------------------+
| Logo  [Search...                    ]  Cart(3)  Account   |
+------------------------------------------------------------+
| Home > Electronics > Cameras > Product Name                |
+------------------------------------------------------------+
|                                                            |
| +------------------+  Product Name - Full Description      |
| |                  |  ★★★★☆ (247 reviews)                  |
| |  Main Product    |                                        |
| |      Image       |  $XXX.XX  [Was: $XXX.XX] Save 20%    |
| |                  |                                        |
| +------------------+  Color: [Black ▼]                     |
| [📷][📷][📷][📷]    Storage: ( ) 128GB ( ) 256GB (•) 512GB |
|                     Quantity: [-] 1 [+]                    |
|                                                            |
|                     [Add to Cart]  [Add to Wishlist ♡]    |
|                                                            |
|                     ✓ In Stock - Ships in 1-2 days        |
|                     ✓ Free Shipping on orders over $50    |
|                     ✓ 30-Day Return Policy                |
|                                                            |
+------------------------------------------------------------+
|                                                            |
| [Description] [Specifications] [Reviews] [Q&A]            |
+------------------------------------------------------------+
| Product Description                                        |
|                                                            |
| Lorem ipsum dolor sit amet, consectetur adipiscing elit.   |
| Detailed product information, features, and benefits go    |
| here with proper formatting and bullet points:             |
|                                                            |
| • Key Feature 1 with detailed explanation                  |
| • Key Feature 2 with detailed explanation                  |
| • Key Feature 3 with detailed explanation                  |
|                                                            |
| [Read More ▼]                                              |
+------------------------------------------------------------+
|                                                            |
| Customers Also Viewed                                      |
| +----------+  +----------+  +----------+  +----------+     |
| |[Image]   |  |[Image]   |  |[Image]   |  |[Image]   |     |
| |Product   |  |Product   |  |Product   |  |Product   |     |
| |$XX.XX    |  |$XX.XX    |  |$XX.XX    |  |$XX.XX    |     |
| |★★★★★     |  |★★★★☆     |  |★★★★★     |  |★★★★☆     |     |
| +----------+  +----------+  +----------+  +----------+     |
+------------------------------------------------------------+
```

**Annotations**:

1. **Product Image Gallery**:
   - Main image: 600x600px minimum
   - Thumbnails: 80x80px, up to 8 images
   - Click thumbnail to update main image
   - Click main image for lightbox/zoom view
   - Support touch gestures on mobile (swipe)

2. **Product Options**:
   - Color dropdown: Show available colors with visual swatches if possible
   - Storage: Radio buttons for mutually exclusive options
   - Update price and availability based on selections
   - Disable "Add to Cart" if required options not selected

3. **Pricing Display**:
   - Original price strikethrough if on sale
   - Show percentage savings
   - Update dynamically based on quantity/options
   - Include tax information based on location

4. **Add to Cart**:
   - Primary CTA button
   - On click: Add item to cart, show confirmation, update cart count
   - Disable if out of stock
   - Loading state during API call

5. **Tabs**:
   - Lazy load content for performance
   - Deep linkable (e.g., #reviews)
   - Reviews tab: Show rating distribution, sorting, filtering
   - Q&A tab: Community questions with upvoting

6. **Recommendations**:
   - Personalized based on browsing history
   - Horizontal scroll on mobile
   - Track clicks for analytics

**Responsive Behavior**:
- Desktop: Two-column layout (image left, details right)
- Tablet: Two-column with adjusted proportions
- Mobile: Single column, image full-width, sticky "Add to Cart"

**Edge Cases to Consider**:
- Out of stock scenarios
- Backordered items
- Pre-order functionality
- Limited quantity warnings
- Variant-specific availability
- Price changes during session

---

### Example 2: Shopping Cart (Mid-Fidelity)

**Context**: Cart page showing selected items before checkout

**Wireframe Structure**:
```
+------------------------------------------------------------+
| [Logo]                            [Search]  [Account]      |
+------------------------------------------------------------+
|                                                            |
| Shopping Cart (3 items)                                    |
|                                                            |
| +--------------------------------------------------------+ |
| | [X]  [Image]  Product Name                             | |
| |              Color: Black, Size: Large                 | |
| |              SKU: ABC123                               | |
| |                                          $XX.XX        | |
| |              Qty: [-] 2 [+]            Subtotal: $XX.XX| |
| |                                                        | |
| |              [Save for Later]  [Remove]                | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [X]  [Image]  Product Name 2                           | |
| |              Color: Blue                               | |
| |              In Stock                   $XX.XX         | |
| |              Qty: [-] 1 [+]            Subtotal: $XX.XX| |
| |                                                        | |
| |              [Save for Later]  [Remove]                | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [X]  [Image]  Product Name 3                           | |
| |              Low Stock - Only 2 left!                  | |
| |              Ships in 3-5 days          $XX.XX         | |
| |              Qty: [-] 1 [+]            Subtotal: $XX.XX| |
| |                                                        | |
| |              [Save for Later]  [Remove]                | |
| +--------------------------------------------------------+ |
|                                                            |
| [Continue Shopping]                                        |
|                                                            |
+------------------------------------------------------------+
|                                      Order Summary         |
|                                      +------------------+  |
|                                      | Subtotal: $XX.XX |  |
|                                      | Shipping: $X.XX  |  |
|                                      | Tax:      $X.XX  |  |
|                                      |------------------|  |
|                                      | Total:    $XX.XX |  |
|                                      +------------------+  |
|                                                            |
|                                      Promo Code:          |
|                                      [____________] [Apply]|
|                                                            |
|                                      [Proceed to Checkout]|
+------------------------------------------------------------+
```

**Annotations**:

1. **Cart Items**:
   - Show product image (thumbnail), name, variant details
   - Price per item and subtotal
   - Quantity selector with validation (max available stock)
   - Remove and Save for Later actions

2. **Quantity Changes**:
   - Update subtotal immediately
   - Recalculate order summary
   - Validate against available stock
   - Show loading indicator during update
   - Handle API errors gracefully

3. **Stock Warnings**:
   - Show "Low Stock" or "Only X left" messages
   - Disable quantity increase if at max available
   - Handle out-of-stock situations (move to saved items)

4. **Order Summary**:
   - Fixed/sticky position on desktop
   - Automatically updates when cart changes
   - Shipping estimate (may require ZIP code)
   - Tax calculation (based on shipping address)

5. **Promo Code**:
   - Validate code on apply
   - Show success/error message
   - Display discount in order summary
   - Only one code allowed, or multiple depending on business rules

6. **Empty Cart State**:
   ```
   +--------------------------------------------+
   |                                            |
   |           [Shopping Cart Icon]             |
   |                                            |
   |         Your cart is empty                 |
   |                                            |
   |    [Continue Shopping]                     |
   |                                            |
   |    Saved Items (2)                         |
   |    [Show Saved Items]                      |
   +--------------------------------------------+
   ```

**Responsive Behavior**:
- Desktop: Cart items left, order summary right (sticky)
- Tablet: Similar to desktop, narrower columns
- Mobile: Single column, order summary at bottom

---

## SaaS Application Examples

### Example 3: Analytics Dashboard (High-Fidelity)

**Context**: Main dashboard for a marketing analytics platform

**Wireframe Structure**:
```
+------------------------------------------------------------+
| [☰] AppName    [Search]       [Notifications] [@UserName▼]|
+------------------------------------------------------------+
| Dashboard    Reports    Campaigns    Settings              |
+------------------------------------------------------------+
|                                                            |
| Welcome back, [User]!          [Date Range: Last 30 Days▼]|
|                                [Compare to: Previous Period]|
|                                                            |
| +---------------+  +---------------+  +------------------+ |
| | Total Revenue |  | Conversions   |  | Avg. Order Value | |
| |               |  |               |  |                  | |
| |   $XXX,XXX    |  |    X,XXX      |  |     $XX.XX       | |
| |   +XX.X% ↑    |  |    +X.X% ↑    |  |     -X.X% ↓      | |
| |               |  |               |  |                  | |
| | [View Report] |  | [View Report] |  | [View Report]    | |
| +---------------+  +---------------+  +------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | Revenue Over Time                    [Daily▼] [Chart▼]| |
| |                                                        | |
| |      $XX                                               | |
| |       │     ╱╲                                         | |
| |       │    ╱  ╲     ╱╲                                 | |
| |  $XX  │   ╱    ╲   ╱  ╲                                | |
| |       │  ╱      ╲ ╱    ╲                               | |
| |   $XX │ ╱        ╱      ╲                              | |
| |       └─────────────────────────────                   | |
| |        Mon Tue Wed Thu Fri Sat Sun                     | |
| |                                                        | |
| |  ━ Current Period  ━ Previous Period                  | |
| +--------------------------------------------------------+ |
|                                                            |
| +---------------------------+  +--------------------------+|
| | Traffic Sources           |  | Top Performing Campaigns ||
| |                           |  |                          ||
| | [Pie Chart]               |  | 1. Campaign A    $X,XXX  ||
| |                           |  |    XX,XXX clicks         ||
| | Organic:      XX%         |  |    X.X% conversion       ||
| | Paid:         XX%         |  |                          ||
| | Social:       XX%         |  | 2. Campaign B    $X,XXX  ||
| | Direct:       XX%         |  |    XX,XXX clicks         ||
| | Referral:     XX%         |  |    X.X% conversion       ||
| |                           |  |                          ||
| | [View Details]            |  | 3. Campaign C    $X,XXX  ||
| +---------------------------+  |    XX,XXX clicks         ||
|                                |    X.X% conversion       ||
|                                |                          ||
|                                | [View All Campaigns]     ||
|                                +--------------------------+|
|                                                            |
| +--------------------------------------------------------+ |
| | Recent Activity                                        | |
| |                                                        | |
| | • [Time] New conversion from Campaign A                | |
| | • [Time] Traffic spike detected on Landing Page B      | |
| | • [Time] Campaign budget alert: 80% spent              | |
| | • [Time] New user signup via organic search            | |
| |                                                        | |
| | [View All Activity]                                    | |
| +--------------------------------------------------------+ |
+------------------------------------------------------------+
```

**Annotations**:

1. **Date Range Selector**:
   - Predefined ranges: Today, Yesterday, Last 7 days, Last 30 days, Custom
   - Calendar picker for custom dates
   - Updates all dashboard metrics on change
   - Save user preferences for default range

2. **Metric Cards**:
   - Large number display for primary metric
   - Percentage change with directional indicator (↑↓)
   - Color coding: Green for positive, red for negative
   - Click card to drill down to detailed report
   - Hover for additional context/tooltip

3. **Revenue Chart**:
   - Line chart with comparison to previous period
   - Hover to see exact values for each data point
   - Toggle between daily/weekly/monthly granularity
   - Switch chart types: Line, Bar, Area
   - Export data as CSV
   - Full-screen mode available

4. **Traffic Sources (Pie Chart)**:
   - Interactive: Click slice to filter dashboard
   - Hover for exact numbers
   - Legend with percentages
   - Option to switch to bar/table view

5. **Top Campaigns List**:
   - Sortable by revenue, clicks, conversion rate
   - Click campaign name to view details
   - Shows top 3, link to view all
   - Real-time data updates (optional)

6. **Activity Feed**:
   - Real-time or near-real-time updates
   - Filter by activity type
   - Click activity to view details
   - Limit to 5 most recent, link to full log

**Responsive Behavior**:
- Desktop: Multi-column grid layout as shown
- Tablet: 2-column grid, some full-width elements
- Mobile: Single column, vertical stack, simplified charts

**Performance Considerations**:
- Lazy load charts and heavy visualizations
- Cache data where appropriate
- Skeleton screens during initial load
- Progressive enhancement for complex charts

---

### Example 4: Project Management Board (Kanban Style)

**Context**: Task management interface with drag-and-drop functionality

**Wireframe Structure**:
```
+--------------------------------------------------------------------+
| [Logo] MyProjects            [@User▼] [Notifications] [Settings]  |
+--------------------------------------------------------------------+
| Project Name                 [⊞ Board] [≡ List] [⊟ Timeline]       |
| Members: [@] [@] [@] [+]     [Filter▼] [Search...] [+ New Task]   |
+--------------------------------------------------------------------+
|                                                                    |
| +-------------+  +-------------+  +-------------+  +-------------+ |
| | To Do (5)   |  | In Progress |  | Review (2)  |  | Done (8)    | |
| | [+]         |  | (3) [+]     |  | [+]         |  | [+]         | |
| +-------------+  +-------------+  +-------------+  +-------------+ |
| |             |  |             |  |             |  |             | |
| | ┌─────────┐ |  | ┌─────────┐ |  | ┌─────────┐ |  | ┌─────────┐ |
| | │Task #1  │ |  | │Task #6  │ |  | │Task #9  │ |  | │Task #12 │ |
| | │         │ |  | │         │ |  | │         │ |  | │         │ |
| | │[Label]  │ |  | │[Label]  │ |  | │[Label]  │ |  | │[Label]  │ |
| | │[@User]  │ |  | │[@User]  │ |  | │[@User]  │ |  | │[@User]  │ |
| | │Due: Date│ |  | │⏱ 2d     │ |  | │Due: Date│ |  | │✓ Done   │ |
| | └─────────┘ |  | └─────────┘ |  | └─────────┘ |  | └─────────┘ |
| |             |  |             |  |             |  |             | |
| | ┌─────────┐ |  | ┌─────────┐ |  | ┌─────────┐ |  | ┌─────────┐ |
| | │Task #2  │ |  | │Task #7  │ |  | │Task #10 │ |  | │Task #13 │ |
| | │[Priority]│|  | │[Urgent] │ |  | │         │ |  | │         │ |
| | │[@User]  │ |  | │[@User]  │ |  | │[@User]  │ |  | │[@User]  │ |
| | │📎 2      │ |  | │💬 3      │ |  | │📎 1      │ |  | │✓ Done   │ |
| | └─────────┘ |  | └─────────┘ |  | └─────────┘ |  | └─────────┘ |
| |             |  |             |  |             |  |             | |
| | ┌─────────┐ |  | ┌─────────┐ |  |             |  | ┌─────────┐ |
| | │Task #3  │ |  | │Task #8  │ |  |             |  | │Task #14 │ |
| | │         │ |  | │⚠ Blocked│ |  |             |  | │✓ Done   │ |
| | │[@User]  │ |  | │[@User]  │ |  |             |  | │[@User]  │ |
| | └─────────┘ |  | └─────────┘ |  |             |  | └─────────┘ |
| +-------------+  +-------------+  +-------------+  +-------------+ |
+--------------------------------------------------------------------+
```

**Annotations**:

1. **Board Columns**:
   - Customizable column titles and order
   - Card count in column header
   - Add new card with [+] button in each column
   - Horizontal scroll if columns exceed viewport width
   - Column settings: Edit name, set WIP limits, delete

2. **Task Cards**:
   - Draggable to any column (reorder within column or move between)
   - Click card to open detail modal
   - Color-coded labels for categorization
   - Assignee avatar (click to change)
   - Due date display (highlight if overdue)
   - Icons for attachments (📎), comments (💬), checklist progress
   - Priority indicators (color or icon)

3. **Drag and Drop**:
   - Visual feedback when dragging (shadow, opacity)
   - Drop zones highlight on hover
   - Smooth animation on drop
   - Optimistic UI updates, rollback if API fails
   - Keyboard accessible (arrow keys + space to pick/drop)

4. **Card Detail Modal** (on click):
   ```
   +------------------------------------------+
   | Task #1 Title                        [X] |
   +------------------------------------------+
   | Status: [To Do ▼]      Assignee: [@User▼]|
   | Priority: [Medium ▼]   Due: [Date picker]|
   |                                           |
   | Description                               |
   | [Rich text editor area]                   |
   |                                           |
   | Attachments (2)                           |
   | [file1.pdf] [image.jpg] [+ Add]           |
   |                                           |
   | Checklist (2/5 complete)                  |
   | [✓] Subtask 1                             |
   | [✓] Subtask 2                             |
   | [ ] Subtask 3                             |
   | [+ Add subtask]                           |
   |                                           |
   | Comments (3)                              |
   | [@User] [Time] Comment text...            |
   | [@User] [Time] Another comment...         |
   | [Add comment...]                          |
   |                                           |
   | [Delete Task]     [Save Changes]          |
   +------------------------------------------+
   ```

5. **Filtering and Search**:
   - Filter by: Assignee, Label, Due date, Priority
   - Search by task title or description
   - Multiple filters combine with AND logic
   - Clear filters button
   - Save filter presets

6. **View Modes**:
   - Board view (Kanban): As shown
   - List view: Traditional task list with columns
   - Timeline view: Gantt-style calendar view
   - Preserve filters across view changes

**Responsive Behavior**:
- Desktop: Full multi-column board
- Tablet: Horizontal scroll, 2-3 columns visible
- Mobile: Single column with dropdown to switch between columns

---

## Mobile App Examples

### Example 5: Restaurant Ordering App - Home Screen

**Context**: Food delivery app home screen

**Wireframe Structure** (Mobile):
```
┌─────────────────────┐
│ [≡]  Location ▼ [🔔]│
│     123 Main St     │
├─────────────────────┤
│                     │
│ [Search for food or │
│  restaurant...    🔍]│
│                     │
├─────────────────────┤
│ Quick Filters       │
│ [🍔] [🍕] [🍜] [☕] │
│ Burger Pizza Ramen  │
│                     │
├─────────────────────┤
│ [Banner: Promo Ad]  │
│ Get 20% Off First   │
│ Order               │
├─────────────────────┤
│                     │
│ Popular Near You    │
│                     │
│ ┌─────────────────┐ │
│ │ [Restaurant Img]│ │
│ │                 │ │
│ │ Restaurant Name │ │
│ │ ★★★★☆ (200)    │ │
│ │ Pizza • Italian │ │
│ │ 20-30 min • $   │ │
│ │ Free Delivery   │ │
│ └─────────────────┘ │
│                     │
│ ┌─────────────────┐ │
│ │ [Restaurant Img]│ │
│ │                 │ │
│ │ Restaurant Name │ │
│ │ ★★★★★ (500)    │ │
│ │ Burger • Fast   │ │
│ │ 15-25 min • $$  │ │
│ └─────────────────┘ │
│                     │
│ [Load More...]      │
│                     │
├─────────────────────┤
│ [🏠] [🔍] [🎫] [👤] │
│ Home Search Offers  │
│                 You │
└─────────────────────┘
```

**Annotations**:

1. **Header**:
   - Hamburger menu: Access account, settings, help
   - Location selector: Choose or search delivery address, GPS option
   - Notifications bell: Order updates, promos (badge if unread)

2. **Search Bar**:
   - Tap to focus and show keyboard
   - Recent searches appear
   - Autocomplete suggestions as user types
   - Search both restaurants and specific dishes

3. **Quick Filter Chips**:
   - Horizontal scroll for more categories
   - Tap to filter restaurant list
   - Active state indicated by fill color or border
   - Can select multiple filters

4. **Promotional Banner**:
   - Carousel/slider if multiple promos
   - Tap to view promo details or apply code
   - Auto-advance with manual swipe override
   - Dot indicators for position in carousel

5. **Restaurant Cards**:
   - Tap card to view restaurant menu
   - Image should be appetizing, high-quality
   - Rating with review count
   - Cuisine type and category tags
   - Estimated delivery time
   - Price indicator ($ to $$$$)
   - Special badges (Free Delivery, New, etc.)
   - Heart icon to favorite (top right of card)

6. **Bottom Navigation**:
   - Fixed position, always accessible
   - Active state clearly indicated
   - Badge on Offers if new promotions
   - You/Profile for account, orders, favorites

**Interaction Details**:
- Pull to refresh content
- Infinite scroll or "Load More" for restaurant list
- Skeleton screens during loading
- Offline state handling (show cached content, indicate offline)

---

### Example 6: Fitness Tracking App - Workout Screen

**Context**: Active workout session screen with real-time data

**Wireframe Structure** (Mobile):
```
┌─────────────────────┐
│ [<] Workout  [Pause]│
├─────────────────────┤
│                     │
│     [Animation]     │
│   Exercise Demo     │
│                     │
│   Jumping Jacks     │
│                     │
├─────────────────────┤
│                     │
│     00:42           │
│    Time Elapsed     │
│                     │
│    ──────●─────     │
│  Sets: 2/3          │
│                     │
├─────────────────────┤
│                     │
│ ┌─────────────────┐ │
│ │ Heart Rate      │ │
│ │    142 bpm      │ │
│ │    ♥♥♥♥♥        │ │
│ └─────────────────┘ │
│                     │
│ ┌────┐  ┌────┐     │
│ │120 │  │450 │     │
│ │Cals│  │Reps│     │
│ └────┘  └────┘     │
│                     │
├─────────────────────┤
│                     │
│ Next: Push-ups      │
│ [Preview Image]     │
│                     │
├─────────────────────┤
│                     │
│ [  Skip Exercise  ] │
│                     │
│ [  Finish Workout ] │
│                     │
└─────────────────────┘
```

**Annotations**:

1. **Header Controls**:
   - Back button: Confirm before exiting active workout
   - Pause button: Pause timer and tracking, show resume modal
   - During pause: Options to resume, end workout, or rest timer

2. **Exercise Display**:
   - Animated demonstration (GIF or video loop)
   - Exercise name prominent
   - Tap for detailed instructions/form tips

3. **Progress Indicators**:
   - Timer: Count up or countdown depending on workout type
   - Progress bar: Visual representation of sets completed
   - Set counter: Current set / total sets
   - Auto-advance to next exercise or rest period

4. **Real-Time Metrics**:
   - Heart rate: From connected device (watch, chest strap)
   - Calories burned: Real-time calculation
   - Reps counter: Manual tap to count, or auto-detect
   - Update frequently (every second for timer)

5. **Next Exercise Preview**:
   - Prepare user for what's coming
   - Shows after rest period or between sets
   - Tap to see full details

6. **Action Buttons**:
   - Skip Exercise: Move to next, confirm action
   - Finish Workout: End session, show summary
   - Additional actions in menu (☰): Adjust volume, modify workout

**Workout Complete Modal**:
```
┌─────────────────────┐
│    🎉 Great Job!    │
│                     │
│ Workout Complete    │
│                     │
│ ┌─────────────────┐ │
│ │ Duration: 45min │ │
│ │ Calories: 420   │ │
│ │ Exercises: 12   │ │
│ │ Avg HR: 138 bpm │ │
│ └─────────────────┘ │
│                     │
│ How do you feel?    │
│ 😫 😐 😊 😄 🤩     │
│                     │
│ [Add Note]          │
│                     │
│ [Share] [View Stats]│
│                     │
│ [    Done    ]      │
└─────────────────────┘
```

---

## Content & Media Examples

### Example 7: News Article Page with Paywall

**Context**: Online publication with metered paywall

**Wireframe Structure**:
```
+------------------------------------------------------------+
| [Logo]  News  Opinion  Business  Tech  Sports    [Search] |
| [Subscribe] [Sign In]                                      |
+------------------------------------------------------------+
|                                                            |
| Technology > Artificial Intelligence                       |
|                                                            |
|   Article Headline Goes Here in Large, Bold Type          |
|   This Is a Compelling Subheading That Draws You In       |
|                                                            |
| By Author Name  |  Published: Date, Time  |  X min read    |
| [Share: 📧 f t in]                                         |
|                                                            |
+------------------------------------------------------------+
|                                                            |
|           [Featured Article Image - Full Width]            |
|           Photo credit: Photographer Name                  |
|                                                            |
+------------------------------------------------------------+
|                                                            |
| Article body content begins here. The first few paragraphs |
| are accessible to everyone. Lorem ipsum dolor sit amet,    |
| consectetur adipiscing elit. Sed do eiusmod tempor         |
| incididunt ut labore et dolore magna aliqua.               |
|                                                            |
| Ut enim ad minim veniam, quis nostrud exercitation ullamco |
| laboris nisi ut aliquip ex ea commodo consequat. Duis aute |
| irure dolor in reprehenderit in voluptate velit esse.      |
|                                                            |
| ┌────────────────────────────────────────────────────────┐ |
| │                    PAYWALL OVERLAY                     │ |
| │                                                        │ |
| │         Continue reading this article with             │ |
| │              unlimited access to all content           │ |
| │                                                        │ |
| │   [Subscribe for $X.XX/month]  [Sign In]               │ |
| │                                                        │ |
| │   ✓ Unlimited articles                                 │ |
| │   ✓ Ad-free experience                                 │ |
| │   ✓ Exclusive newsletters                              │ |
| │   ✓ Cancel anytime                                     │ |
| │                                                        │ |
| │   You have X free articles remaining this month        │ |
| └────────────────────────────────────────────────────────┘ |
|                                                            |
| [Content continues below, blurred or truncated]            |
|                                                            |
+------------------------------------------------------------+
```

**Annotations**:

1. **Article Metadata**:
   - Byline links to author page
   - Timestamp in relative format ("2 hours ago") with tooltip showing exact time
   - Reading time estimate based on word count
   - Share buttons: Email, Facebook, Twitter, LinkedIn

2. **Paywall Mechanics**:
   - Trigger: After X paragraphs or Y% of article
   - Non-subscribers: Show overlay with call-to-action
   - Metered: Track free articles (3-5 per month typical)
   - Signed out users: Prompt to sign in (may have free articles)
   - Cookie/localStorage tracking, server-side validation

3. **Paywall Overlay**:
   - Covers content but doesn't completely hide it (slight blur)
   - Fixed position, scrolls with page
   - Can't be dismissed without action
   - Clear value proposition
   - Prominent CTA buttons

4. **Subscriber Experience**:
   - No paywall shown
   - Full article content
   - Additional features (save, comment, no ads)

5. **SEO Considerations**:
   - Full content in HTML for crawlers (with proper markup)
   - Structured data for article
   - Paywall implemented client-side for Googlebot access

**Mobile Paywall Variant**:
```
┌─────────────────────┐
│ [×]                 │
├─────────────────────┤
│                     │
│ Enjoy unlimited     │
│ access              │
│                     │
│ ✓ Unlimited stories │
│ ✓ Ad-free reading   │
│ ✓ Newsletters       │
│                     │
│ [Subscribe $X/mo]   │
│                     │
│ [Sign In]           │
│                     │
│ X free articles left│
│                     │
└─────────────────────┘
```

---

### Example 8: Video Streaming Platform - Browse Page

**Context**: Netflix-style content browsing interface

**Wireframe Structure**:
```
+------------------------------------------------------------+
| [Logo] Home  TV Shows  Movies  My List     [🔍] [@User▼]  |
+------------------------------------------------------------+
|                                                            |
|                  [Hero Image/Video]                        |
|                                                            |
|            Featured Show Title                             |
|                                                            |
|         Brief description of the show goes here.           |
|         Highlighting key themes and appeal.                |
|                                                            |
|      [▶ Play]  [+ My List]  [ℹ More Info]                 |
|                                                            |
+------------------------------------------------------------+
|                                                            |
| Continue Watching                               [See All >]|
| ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                |
| │Img │ │Img │ │Img │ │Img │ │Img │ │Img │                |
| │ ▶● │ │ ▶● │ │ ▶● │ │ ▶● │ │ ▶● │ │ ▶● │                |
| │45% │ │12% │ │78% │ │90% │ │23% │ │56% │                |
| └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                |
| Title  Title  Title  Title  Title  Title                   |
|                                                            |
| Trending Now                                    [See All >]|
| ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                |
| │Img │ │Img │ │Img │ │Img │ │Img │ │Img │                |
| │ [1]│ │ [2]│ │ [3]│ │ [4]│ │ [5]│ │ [6]│                |
| └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                |
| Title  Title  Title  Title  Title  Title                   |
|                                                            |
| Because You Watched "Show Name"                 [See All >]|
| ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                |
| │Img │ │Img │ │Img │ │Img │ │Img │ │Img │                |
| │    │ │    │ │    │ │    │ │    │ │    │                |
| │    │ │    │ │    │ │    │ │    │ │    │                |
| └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                |
| Title  Title  Title  Title  Title  Title                   |
|                                                            |
| New Releases                                    [See All >]|
| ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                |
| │Img │ │Img │ │Img │ │Img │ │Img │ │Img │                |
| └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                |
|                                                            |
| Award Winners                                   [See All >]|
| ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                |
| │Img │ │Img │ │Img │ │Img │ │Img │ │Img │                |
| └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                |
+------------------------------------------------------------+
```

**Annotations**:

1. **Hero Section**:
   - Auto-playing video preview (muted) or high-quality image
   - Rotates featured content periodically
   - Mute/unmute button if video
   - Content appropriate to user preferences
   - Background darkened for text readability

2. **Hero Actions**:
   - Play button: Start watching from S01E01 or resume
   - My List: Add/remove from personal watchlist
   - More Info: Navigate to detail page
   - Buttons appear on hover/focus

3. **Content Rows**:
   - Horizontal scroll carousel
   - 5-6 items visible at once
   - Arrow navigation on desktop (left/right)
   - Touch/swipe on mobile and tablet
   - "See All" links to expanded category page

4. **Continue Watching**:
   - Shows in-progress content
   - Progress bar overlay on thumbnail
   - Percentage complete
   - Hover/click to resume playback
   - "X" to remove from list

5. **Tile Interactions**:
   - Hover effect: Slight scale up, show overlay with details
   - Overlay includes: Title, brief description, play button, add to list, rating
   - Click to go to detail page
   - Right-click for context menu (remove from row, not interested)

6. **Personalization**:
   - "Because You Watched" rows based on viewing history
   - Trending considers user location and demographics
   - Row order personalized per user

**Content Tile Hover State**:
```
┌──────────────────┐
│  [Larger Image]  │
│                  │
│  Title           │
│  ★★★★☆ 2023     │
│  1h 45m  Drama   │
│                  │
│  Brief synopsis  │
│  goes here...    │
│                  │
│  [▶]  [+]  [▼]   │
└──────────────────┘
```

---

## Form & Input Examples

### Example 9: Multi-Step Form - Insurance Quote

**Context**: Progressive insurance quote form with save/resume

**Step 1: Personal Information**
```
+------------------------------------------------------------+
| Get Your Free Quote                                     [?]|
+------------------------------------------------------------+
|                                                            |
| Step 1 of 4: Personal Information        ●○○○             |
|                                                            |
| First Name                      Last Name                  |
| [________________]              [________________]          |
|                                                            |
| Date of Birth                                              |
| [MM] / [DD] / [YYYY]                                       |
|                                                            |
| Gender                                                     |
| ( ) Male   ( ) Female   ( ) Non-binary   ( ) Prefer not to |
|     say                                                    |
|                                                            |
| Marital Status                                             |
| [Select...                                              ▼] |
|                                                            |
| [ ] I consent to the privacy policy and terms of service  |
|                                                            |
|                                     [Continue to Step 2 >] |
|                                                            |
| All fields required unless marked optional                 |
+------------------------------------------------------------+
```

**Annotations**:

1. **Progress Indicator**:
   - 4 filled circles showing progress (1 of 4)
   - Step labels on hover
   - Can click previous steps to go back
   - Current step highlighted

2. **Form Validation**:
   - Validate on blur (after leaving field)
   - Show inline errors below field
   - Disable Continue button until all required fields valid
   - Error summary at top if form submitted with errors

3. **Input Constraints**:
   - Date of birth: Must be 18+, format MM/DD/YYYY
   - Names: Letters and hyphens only
   - Auto-capitalize names

4. **Save Progress**:
   - Auto-save to localStorage every 30 seconds
   - If user returns, offer to resume: "Would you like to continue your quote?"
   - Clear saved data after X days or on completion

5. **Help Icon [?]**:
   - Click for live chat, phone number, FAQ
   - Available on every step

**Step 2: Vehicle Information**
```
+------------------------------------------------------------+
| Get Your Free Quote                                     [?]|
+------------------------------------------------------------+
|                                                            |
| Step 2 of 4: Vehicle Information         ○●○○             |
|                                                            |
| Year                Make                   Model           |
| [Select ▼]          [Select ▼]            [Select ▼]      |
|                                                            |
| Vehicle Identification Number (VIN) - Optional             |
| [_________________________________]        [What's this?]  |
|                                                            |
| Estimated Annual Mileage                                   |
| ( ) Less than 5,000      ( ) 5,000 - 10,000                |
| ( ) 10,000 - 15,000      ( ) More than 15,000              |
|                                                            |
| Primary Use                                                |
| ( ) Commuting to work    ( ) Business                      |
| ( ) Pleasure             ( ) Farm                          |
|                                                            |
| Is the vehicle                                             |
| ( ) Owned   ( ) Leased   ( ) Financed                      |
|                                                            |
| [+ Add Another Vehicle]                                    |
|                                                            |
| [< Back]                            [Continue to Step 3 >] |
+------------------------------------------------------------+
```

**Step 3: Coverage Preferences**
```
+------------------------------------------------------------+
| Get Your Free Quote                                     [?]|
+------------------------------------------------------------+
|                                                            |
| Step 3 of 4: Coverage                    ○○●○             |
|                                                            |
| Select your coverage limits:                               |
|                                                            |
| Bodily Injury Liability                                    |
| [50/100 ▼] per person/per accident     [What's this?]      |
|                                                            |
| Property Damage Liability                                  |
| [$50,000 ▼]                            [What's this?]      |
|                                                            |
| [ ] Comprehensive Coverage                                 |
|     Covers damage from theft, vandalism, weather           |
|     Deductible: [$500 ▼]                                   |
|                                                            |
| [ ] Collision Coverage                                     |
|     Covers damage from accidents                           |
|     Deductible: [$500 ▼]                                   |
|                                                            |
| [ ] Rental Car Reimbursement                               |
|     Up to $XX/day while your car is being repaired         |
|                                                            |
| [ ] Roadside Assistance                                    |
|     24/7 towing, jump starts, tire changes                 |
|                                                            |
| Estimated Monthly Premium: $XXX                            |
| (Final price on next page)                                 |
|                                                            |
| [< Back]                            [Continue to Review >] |
+------------------------------------------------------------+
```

**Annotations for Coverage Step**:

1. **Dynamic Pricing**:
   - Update estimated premium as selections change
   - AJAX call to recalculate or client-side estimation
   - Show loading indicator during calculation

2. **Help Text**:
   - "What's this?" links open modal with explanation
   - Plain language explanations
   - Examples and scenarios

3. **Smart Defaults**:
   - Pre-select recommended coverage based on vehicle value
   - Indicate "Most Popular" or "Recommended" options

**Step 4: Review and Quote**
```
+------------------------------------------------------------+
| Get Your Free Quote                                     [?]|
+------------------------------------------------------------+
|                                                            |
| Step 4 of 4: Review and Quote            ○○○●             |
|                                                            |
| Review Your Information                          [Edit]    |
| +--------------------------------------------------------+ |
| | Personal Information                          [Edit]   | |
| | Name: John Doe                                         | |
| | DOB: 01/15/1985                                        | |
| | Marital Status: Single                                 | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | Vehicle Information                           [Edit]   | |
| | 2020 Honda Accord LX                                   | |
| | VIN: XXXXXXXXXXXXX                                     | |
| | Annual Mileage: 10,000-15,000                          | |
| | Primary Use: Commuting                                 | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | Coverage Selected                             [Edit]   | |
| | Bodily Injury: 50/100                                  | |
| | Property Damage: $50,000                               | |
| | Comprehensive: $500 deductible                         | |
| | Collision: $500 deductible                             | |
| +--------------------------------------------------------+ |
|                                                            |
| +========================================================+ |
| |         Your Estimated Monthly Premium                 | |
| |                                                        | |
| |                 $XXX.XX/month                          | |
| |                                                        | |
| |            or $X,XXX.XX paid in full                   | |
| |                 (Save $XX.XX)                          | |
| +========================================================+ |
|                                                            |
| [ ] I agree to the terms and conditions                    |
| [ ] Send me emails about discounts and offers (optional)   |
|                                                            |
| [< Back]                                  [Get My Quote >] |
|                                                            |
| Final quote may vary based on verification                 |
+------------------------------------------------------------+
```

---

## Navigation Examples

### Example 10: Mega Menu Navigation

**Context**: E-commerce site with complex category structure

**Closed State**:
```
+------------------------------------------------------------+
| [Logo]  Shop  New  Sale  About  Blog        [🔍] [♡] [🛒] |
+------------------------------------------------------------+
```

**Open State** (Hover on "Shop"):
```
+------------------------------------------------------------+
| [Logo]  Shop▼ New  Sale  About  Blog        [🔍] [♡] [🛒] |
+------------------------------------------------------------+
| +--------------------------------------------------------+ |
| | Women's          | Men's            | Kids             | |
| |                  |                  |                  | |
| | • Clothing       | • Clothing       | • Clothing       | |
| |   - Tops         |   - Shirts       |   - Baby (0-24mo)| |
| |   - Bottoms      |   - Pants        |   - Toddler (2-4)| |
| |   - Dresses      |   - Shorts       |   - Kids (5-12)  | |
| |   - Outerwear    |   - Outerwear    |   - Teen (13+)   | |
| |                  |                  |                  | |
| | • Shoes          | • Shoes          | • Shoes          | |
| |   - Sneakers     |   - Sneakers     |   - Sneakers     | |
| |   - Boots        |   - Boots        |   - Sandals      | |
| |   - Sandals      |   - Dress Shoes  |                  | |
| |                  |                  |                  | |
| | • Accessories    | • Accessories    | • Toys & Games   | |
| |   - Bags         |   - Watches      |                  | |
| |   - Jewelry      |   - Wallets      | [Featured Item]  | |
| |   - Hats         |   - Belts        | [Image]          | |
| |                  |                  | New Collection   | |
| | [Shop All Women] | [Shop All Men]   | [Shop Now]       | |
| +--------------------------------------------------------+ |
+------------------------------------------------------------+
```

**Annotations**:

1. **Trigger Behavior**:
   - Hover to open (desktop)
   - Click/tap on mobile (dropdown or full-screen overlay)
   - Slight delay before opening (~200ms) to prevent accidental triggers
   - Remains open when hovering over menu content

2. **Menu Structure**:
   - Three main columns: Women's, Men's, Kids
   - Hierarchical subcategories
   - Link on every level (can click "Clothing" or specific items)
   - Promotional content area (featured items, sales)

3. **Visual Design**:
   - Dropdown appears below main nav
   - Semi-transparent overlay on content behind
   - Organized with clear visual separation
   - Product images where relevant

4. **Accessibility**:
   - Keyboard navigable (Tab, Arrow keys)
   - ESC to close
   - ARIA attributes for screen readers
   - Focus trap within menu when open

5. **Mobile Adaptation**:
   - Full-screen overlay menu
   - Accordion-style subcategories
   - Back button to previous level
   - Sticky header with close button

**Mobile Mega Menu**:
```
┌─────────────────────┐
│ [×] Menu            │
├─────────────────────┤
│ Shop              > │
│ New               > │
│ Sale              > │
│ About               │
│ Blog                │
├─────────────────────┤
│ [🔍] Search         │
│ [♡] Favorites       │
│ [👤] Account        │
└─────────────────────┘

[After tapping "Shop"]
┌─────────────────────┐
│ [<] Shop            │
├─────────────────────┤
│ Women's           > │
│ Men's             > │
│ Kids              > │
│ Sale              > │
│ New Arrivals      > │
└─────────────────────┘
```

---

## Data Visualization Examples

### Example 11: Financial Portfolio Dashboard

**Context**: Investment portfolio tracker with charts

**Wireframe**:
```
+------------------------------------------------------------+
| [Logo] Portfolio  Markets  Research  [Account ▼]          |
+------------------------------------------------------------+
|                                                            |
| Portfolio Value              [Range: 1D 1W 1M 3M 1Y ALL]  |
|                                                            |
| $XXX,XXX.XX                                     +$X,XXX.XX |
| +X.XX%                                           (+X.XX%)  |
|                                                            |
| +--------------------------------------------------------+ |
| |                 [Line Chart]                           | |
| |   $XX                                                  | |
| |    │         ╱──╲                                      | |
| |    │       ╱      ╲                                    | |
| |    │     ╱          ╲     ╱                            | |
| |    │   ╱              ╲ ╱                              | |
| |    │ ╱                  ╲                              | |
| |    └──────────────────────────────                     | |
| |    Mon  Tue  Wed  Thu  Fri  Sat  Sun                  | |
| +--------------------------------------------------------+ |
|                                                            |
| Holdings                            [Search] [Filter ▼]    |
| +--------------------------------------------------------+ |
| | Symbol | Name        | Shares | Price  | Value  | +/-%  | |
| +--------------------------------------------------------+ |
| | AAPL   | Apple Inc.  | 100    | $XX.XX | $X,XXX | +X.X% | |
| | GOOGL  | Alphabet    | 50     | $XX.XX | $X,XXX | -X.X% | |
| | MSFT   | Microsoft   | 75     | $XX.XX | $X,XXX | +X.X% | |
| | TSLA   | Tesla       | 25     | $XX.XX | $X,XXX | +XX.X%| |
| | AMZN   | Amazon      | 30     | $XX.XX | $X,XXX | -X.X% | |
| +--------------------------------------------------------+ |
|                                                            |
| Asset Allocation                Recent Transactions        |
| +---------------------+        +-----------------------+   |
| | [Pie Chart]         |        | Buy  AAPL  10 shares  |   |
| |                     |        | Date: MM/DD  $X,XXX   |   |
| | Stocks:      65%    |        |                       |   |
| | Bonds:       20%    |        | Sell GOOGL 5 shares   |   |
| | Cash:        10%    |        | Date: MM/DD  $X,XXX   |   |
| | Crypto:       5%    |        |                       |   |
| |                     |        | Dividend MSFT         |   |
| | [Rebalance]         |        | Date: MM/DD  $XX.XX   |   |
| +---------------------+        |                       |   |
|                                | [View All]            |   |
|                                +-----------------------+   |
+------------------------------------------------------------+
```

**Annotations**:

1. **Portfolio Value Chart**:
   - Real-time or delayed quote updates
   - Time range selector (1D, 1W, 1M, 3M, 1Y, ALL)
   - Hover for exact value at specific time
   - Pan and zoom on touch devices
   - Toggle: Show total value or percent change

2. **Holdings Table**:
   - Sortable columns (click header to sort)
   - Click row to view stock detail
   - Real-time price updates (market hours)
   - Color-coded gains/losses (green/red)
   - Search to filter by symbol or name
   - Export to CSV option

3. **Asset Allocation Pie Chart**:
   - Interactive: Click slice to filter holdings
   - Shows percentage breakdown
   - Target allocation vs actual (if set)
   - Rebalance button: Suggests trades to hit targets

4. **Recent Transactions**:
   - Last 3-5 transactions
   - "View All" links to full transaction history
   - Filter by type (buy, sell, dividend, fee)

5. **Performance Considerations**:
   - Virtualize holdings table if >100 rows
   - Debounce search input
   - Cache chart data
   - WebSocket for real-time updates vs polling

---

## Progressive Disclosure Examples

### Example 12: Settings Panel with Expandable Sections

**Context**: Application settings organized with accordions

**Wireframe**:
```
+------------------------------------------------------------+
| Settings                                                [×]|
+------------------------------------------------------------+
|                                                            |
| [▼] Account Settings                                       |
| +--------------------------------------------------------+ |
| | Profile Picture              [Change]  [Remove]        | |
| | [Avatar]                                               | |
| |                                                        | |
| | Email Address                                          | |
| | user@example.com                          [Verified ✓]| |
| | [Change Email]                                         | |
| |                                                        | |
| | Password                                               | |
| | ••••••••••••                                           | |
| | [Change Password]                                      | |
| |                                                        | |
| | Two-Factor Authentication                              | |
| | Currently disabled                                     | |
| | [Enable 2FA]                                           | |
| +--------------------------------------------------------+ |
|                                                            |
| [>] Privacy Settings                                       |
|                                                            |
| [>] Notification Preferences                               |
|                                                            |
| [▼] Appearance                                             |
| +--------------------------------------------------------+ |
| | Theme                                                  | |
| | ( ) Light  (•) Dark  ( ) Auto                          | |
| |                                                        | |
| | Language                                               | |
| | [English (US)                                       ▼] | |
| |                                                        | |
| | Timezone                                               | |
| | [America/New_York                                   ▼] | |
| +--------------------------------------------------------+ |
|                                                            |
| [>] Integrations                                           |
|                                                            |
| [>] Advanced                                               |
|                                                            |
| [>] Billing                                                |
|                                                            |
+------------------------------------------------------------+
| [Cancel]                                     [Save Changes]|
+------------------------------------------------------------+
```

**Annotations**:

1. **Accordion Behavior**:
   - Click section header to expand/collapse
   - Chevron rotates to indicate state (> collapsed, ▼ expanded)
   - Can have multiple sections open simultaneously (optional: only one at a time)
   - Smooth animation for expand/collapse
   - Deep linkable (e.g., #privacy to auto-expand that section)

2. **State Management**:
   - Track which sections are expanded (localStorage)
   - Remember user's last view on return
   - Unsaved changes warning if navigating away

3. **Form Validation**:
   - Enable Save button only when changes made
   - Validate on blur
   - Show errors inline
   - Scroll to first error if validation fails on save

4. **Individual Setting Actions**:
   - Some settings have immediate actions (e.g., Change Email opens modal)
   - Others batch save with main Save button
   - Clearly indicate which is which

**Expanded Privacy Section**:
```
| [▼] Privacy Settings                                       |
| +--------------------------------------------------------+ |
| | Profile Visibility                                     | |
| | Who can see your profile?                              | |
| | (•) Everyone  ( ) Connections only  ( ) Only me        | |
| |                                                        | |
| | Activity Status                                        | |
| | [ ] Show when I'm online                               | |
| |                                                        | |
| | Data Collection                                        | |
| | [ ] Allow analytics and usage data collection          | |
| | [ ] Personalize my experience based on my activity     | |
| |                                                        | |
| | Search Engine Indexing                                 | |
| | [ ] Allow search engines to index my profile           | |
| |                                                        | |
| | [Learn more about privacy]                             | |
| +--------------------------------------------------------+ |
```

---

## Responsive Design Examples

### Example 13: Responsive News Homepage

**Context**: News website with complex layout adapting across devices

**Desktop View** (1200px+):
```
+------------------------------------------------------------+
| [Logo]  News  Politics  Tech  Sports  Opinion    [Search] |
+------------------------------------------------------------+
|                                                            |
| +----------------------------------+  +------------------+ |
| |                                  |  | [Ad: 300x250]    | |
| |  [Featured Article Image]        |  |                  | |
| |                                  |  +------------------+ |
| |  Main Headline Goes Here         |  |                  | |
| |  This Is the Subheading          |  | Top Stories      | |
| |                                  |  | • Story 1        | |
| |  By Author | 2h ago              |  | • Story 2        | |
| +----------------------------------+  | • Story 3        | |
|                                       | • Story 4        | |
| +-------------+ +-------------+       | • Story 5        | |
| | [Image]     | | [Image]     |       |                  | |
| | Headline    | | Headline    |       | [More Stories]   | |
| | Author|Time | | Author|Time |       +------------------+ |
| +-------------+ +-------------+       |                  | |
|                                       | Most Read        | |
| +-------------+ +-------------+       | 1. Article Title | |
| | [Image]     | | [Image]     |       | 2. Article Title | |
| | Headline    | | Headline    |       | 3. Article Title | |
| | Author|Time | | Author|Time |       +------------------+ |
| +-------------+ +-------------+       |                  | |
|                                       | [Newsletter Box] | |
| Latest News                           | Sign up for      | |
| • Article Title    [Image]            | daily updates    | |
| • Article Title    [Image]            | [Email] [Submit] | |
| • Article Title    [Image]            +------------------+ |
+------------------------------------------------------------+
```

**Tablet View** (768px - 1199px):
```
+----------------------------------------+
| [☰] [Logo]         [Search] [@User]   |
+----------------------------------------+
|                                        |
| +------------------------------------+ |
| | [Featured Article Image]           | |
| |                                    | |
| | Main Headline                      | |
| | Subheading                         | |
| |                                    | |
| | Author | 2h ago                    | |
| +------------------------------------+ |
|                                        |
| +----------------+ +----------------+  |
| | [Image]        | | [Image]        |  |
| | Headline       | | Headline       |  |
| | Author | Time  | | Author | Time  |  |
| +----------------+ +----------------+  |
|                                        |
| [Ad: Full Width]                       |
|                                        |
| Latest News                            |
| • Article Title             [Thumb]    |
| • Article Title             [Thumb]    |
| • Article Title             [Thumb]    |
|                                        |
| Most Read                              |
| 1. Article Title                       |
| 2. Article Title                       |
| 3. Article Title                       |
+----------------------------------------+
```

**Mobile View** (<768px):
```
┌─────────────────────┐
│ [☰] Logo      [🔍]  │
├─────────────────────┤
│                     │
│ [Featured Image]    │
│                     │
│ Main Headline Here  │
│ Goes Across Multiple│
│ Lines               │
│                     │
│ Author | 2h ago     │
├─────────────────────┤
│ [Story Image]       │
│ Headline            │
│ Author | Time       │
├─────────────────────┤
│ [Story Image]       │
│ Headline            │
│ Author | Time       │
├─────────────────────┤
│ [Ad: 320x100]       │
├─────────────────────┤
│ Latest News         │
│ • Story 1           │
│ • Story 2           │
│ • Story 3           │
│ [More]              │
├─────────────────────┤
│ Most Read           │
│ 1. Article          │
│ 2. Article          │
│ 3. Article          │
└─────────────────────┘
```

**Annotations**:

1. **Breakpoint Strategy**:
   - Mobile: 320px - 767px
   - Tablet: 768px - 1199px
   - Desktop: 1200px+
   - Large Desktop: 1400px+ (optional enhancement)

2. **Layout Changes**:
   - Desktop: Sidebar, multi-column grid
   - Tablet: No sidebar, 2-column grid
   - Mobile: Single column, vertical stack

3. **Navigation**:
   - Desktop: Full horizontal nav
   - Tablet/Mobile: Hamburger menu
   - Sticky header on scroll (mobile)

4. **Images**:
   - Responsive images with srcset for resolution
   - Different aspect ratios per breakpoint
   - Lazy loading below the fold

5. **Ads**:
   - Different ad units per breakpoint
   - Desktop: 300x250 sidebar, in-feed native
   - Mobile: 320x100, 320x50, in-feed native

6. **Typography**:
   - Fluid typography (scales with viewport)
   - Shorter headlines on mobile (truncate)
   - Larger touch targets on mobile (min 44px)

---

## Interaction Pattern Examples

### Example 14: Drag-and-Drop File Upload

**Context**: Document upload with drag-and-drop and progress tracking

**Initial State**:
```
+------------------------------------------------------------+
|                                                            |
|                         [📁]                               |
|                                                            |
|               Drag files here to upload                    |
|                                                            |
|                          or                                |
|                                                            |
|                   [Browse Files]                           |
|                                                            |
|   Supported formats: PDF, DOC, DOCX, JPG, PNG             |
|   Maximum file size: 25MB                                  |
|                                                            |
+------------------------------------------------------------+
```

**Drag Over State**:
```
+------------------------------------------------------------+
|  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  |
|  ┃                                                      ┃  |
|  ┃                      [📁↓]                           ┃  |
|  ┃                                                      ┃  |
|  ┃              Drop files to upload                   ┃  |
|  ┃                                                      ┃  |
|  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  |
+------------------------------------------------------------+
```

**Upload in Progress**:
```
+------------------------------------------------------------+
|                                                            |
| Uploading Files (2 of 3 complete)                          |
|                                                            |
| +--------------------------------------------------------+ |
| | [📄] Document1.pdf                          [✓] Done   | |
| | 2.5 MB                                                 | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [📄] Image.jpg                              [✓] Done   | |
| | 1.2 MB                                                 | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [📄] Presentation.pptx                  [⌛] Uploading | |
| | 8.7 MB                                                 | |
| | ████████████░░░░░░░░░░░░░░ 45%                        | |
| +--------------------------------------------------------+ |
|                                                            |
| [Cancel All]                                               |
+------------------------------------------------------------+
```

**Upload Complete**:
```
+------------------------------------------------------------+
|                                                            |
| ✓ Upload Complete (3 files)                   [Upload More]|
|                                                            |
| +--------------------------------------------------------+ |
| | [📄] Document1.pdf              2.5 MB      [×] [⋯]    | |
| +--------------------------------------------------------+ |
| | [📄] Image.jpg                  1.2 MB      [×] [⋯]    | |
| +--------------------------------------------------------+ |
| | [📄] Presentation.pptx          8.7 MB      [×] [⋯]    | |
| +--------------------------------------------------------+ |
|                                                            |
| [Download All] [Share]                                     |
+------------------------------------------------------------+
```

**Error State**:
```
+------------------------------------------------------------+
|                                                            |
| Upload Issues (1 failed, 2 successful)        [Upload More]|
|                                                            |
| +--------------------------------------------------------+ |
| | [📄] Document1.pdf              2.5 MB      [×] [⋯]    | |
| +--------------------------------------------------------+ |
| | [📄] Image.jpg                  1.2 MB      [×] [⋯]    | |
| +--------------------------------------------------------+ |
| | [⚠] Large_File.zip             35 MB       [✗] Failed | |
| | Error: File exceeds maximum size of 25MB              | |
| | [Retry]                                                | |
| +--------------------------------------------------------+ |
|                                                            |
+------------------------------------------------------------+
```

**Annotations**:

1. **Drag and Drop**:
   - Listen for dragenter, dragover, dragleave, drop events
   - Show visual feedback on dragover (highlighted border)
   - Prevent default browser behavior (opening file)
   - Support multiple file selection

2. **File Validation**:
   - Check file type against allowed list
   - Verify file size before upload
   - Show clear error message if validation fails
   - Don't start upload for invalid files

3. **Upload Process**:
   - Use FormData and XMLHttpRequest or Fetch API
   - Show individual progress for each file
   - Overall progress indicator
   - Upload files in parallel (limit concurrent uploads)
   - Pause/resume capability (advanced)

4. **Progress Tracking**:
   - Progress bar with percentage
   - File size and upload speed
   - Time remaining estimate
   - Status icons (pending, uploading, complete, error)

5. **Error Handling**:
   - Network errors: Offer retry
   - File too large: Clear message, don't upload
   - Unsupported format: List supported formats
   - Server errors: Display server message

6. **Post-Upload Actions**:
   - Preview uploaded files
   - Download individually or as zip
   - Share link
   - Delete files
   - Context menu (⋯) for additional actions

---

### Example 15: Infinite Scroll with Load More Option

**Context**: Social media feed or content listing

**Wireframe**:
```
+------------------------------------------------------------+
|                                                            |
| +--------------------------------------------------------+ |
| | [Post 1]                                               | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [Post 2]                                               | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
| +--------------------------------------------------------+ |
| | [Post 3]                                               | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
| ... (initial posts loaded) ...                             |
|                                                            |
| +--------------------------------------------------------+ |
| | [Post 10]                                              | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
| ┌────────────────────────────────────────────────────────┐ |
| │                  [Load More Posts]                     │ |
| │                                                        │ |
| │              or scroll to load automatically           │ |
| └────────────────────────────────────────────────────────┘ |
|                                                            |
+------------------------------------------------------------+
```

**Loading State** (when scrolling near bottom):
```
|                                                            |
| +--------------------------------------------------------+ |
| | [Post 10]                                              | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
|                    [Loading spinner]                       |
|                    Loading more posts...                   |
|                                                            |
| (Skeleton screens for next posts appear here)              |
|                                                            |
```

**End of Content**:
```
|                                                            |
| +--------------------------------------------------------+ |
| | [Last Post]                                            | |
| | Content preview...                                     | |
| | [Like] [Comment] [Share]                               | |
| +--------------------------------------------------------+ |
|                                                            |
| ┌────────────────────────────────────────────────────────┐ |
| │                                                        │ |
| │           You've reached the end!                      │ |
| │                                                        │ |
| │         [Back to Top] [View Saved Posts]               │ |
| │                                                        │ |
| └────────────────────────────────────────────────────────┘ |
|                                                            |
+------------------------------------------------------------+
```

**Annotations**:

1. **Infinite Scroll Trigger**:
   - Detect when user scrolls to X pixels from bottom (e.g., 500px)
   - Use Intersection Observer API for better performance
   - Load next page of content automatically
   - Debounce scroll events to prevent multiple simultaneous loads

2. **Load More Button**:
   - Alternative to pure infinite scroll
   - User control over when to load more
   - Hybrid approach: Show button, auto-load on scroll past it
   - Disable button during loading

3. **Loading States**:
   - Spinner or loading indicator
   - Skeleton screens for upcoming content
   - Maintain scroll position during load
   - Smooth insertion of new content

4. **Performance Considerations**:
   - Virtualization for very long lists (only render visible items)
   - Lazy load images in new content
   - Pagination in URL (e.g., ?page=3) for shareability
   - Browser history: Preserve scroll position on back button

5. **End of Content**:
   - Clear indication when all content is loaded
   - "Back to Top" button for easy navigation
   - Related action suggestions

6. **Error Handling**:
   - If load fails: Show error message with retry button
   - Don't break the feed
   - Allow user to continue viewing loaded content

**Error State**:
```
|                                                            |
| ┌────────────────────────────────────────────────────────┐ |
| │                        ⚠                               │ |
| │                                                        │ |
| │         Failed to load more posts                      │ |
| │                                                        │ |
| │              [Try Again]                               │ |
| │                                                        │ |
| └────────────────────────────────────────────────────────┘ |
|                                                            |
```

---

## Conclusion

These 15 comprehensive examples cover a wide range of wireframing scenarios across different industries, platforms, and interaction patterns. Each example demonstrates:

- **Appropriate fidelity level** for the use case
- **Clear annotations** explaining functionality and behavior
- **Responsive considerations** across device sizes
- **Edge cases and error states**
- **Accessibility considerations**
- **Performance implications**

Use these examples as templates and inspiration for your own wireframing projects. Remember to:

1. **Match fidelity to your stage** in the design process
2. **Annotate thoroughly** to communicate intent
3. **Consider all states**: default, loading, error, empty, success
4. **Think responsively** from the start
5. **Test with real users** early and often
6. **Iterate based on feedback**
7. **Document your decisions** and rationale

By studying and adapting these examples, you'll develop a strong foundation in wireframing best practices and be equipped to tackle a wide variety of design challenges.
