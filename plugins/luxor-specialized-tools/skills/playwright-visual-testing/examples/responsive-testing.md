# Responsive Design Testing Example

Complete workflow for testing responsive web design across multiple viewports using Playwright MCP server. This example validates layout, navigation, and functionality across mobile, tablet, and desktop devices.

## Scenario

Testing a marketing website (example.com) to verify:
- Responsive layout at different breakpoints
- Mobile navigation menu behavior
- Touch-friendly interactive elements
- Image scaling and optimization
- Typography and readability
- Form usability across devices
- Content reflow and stacking

## Test Viewports

**Mobile Devices:**
- iPhone SE: 375 x 667 (Small mobile)
- iPhone 14 Pro: 393 x 852 (Standard mobile)
- Pixel 7: 412 x 915 (Large mobile)

**Tablets:**
- iPad Mini: 768 x 1024 (Small tablet portrait)
- iPad Pro 11": 834 x 1194 (Medium tablet portrait)
- iPad Pro 12.9": 1024 x 1366 (Large tablet portrait)

**Desktop:**
- Laptop: 1366 x 768 (Small laptop)
- Desktop HD: 1920 x 1080 (Full HD)
- Desktop 2K: 2560 x 1440 (High resolution)

## Step 1: Mobile Testing (iPhone SE - 375x667)

### Setup Mobile Viewport

```
Tool: browser_resize

Parameters:
width: 375
height: 667
```

### Navigate to Homepage

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading..."
```

### Capture Mobile Layout

```
Tool: browser_snapshot

Returns:
banner "Mobile Header" [ref=101]
  button "Menu" [ref=102]
  img "Logo" [ref=103]
  button "Search" [ref=104]
main "Content" [ref=105]
  heading "Welcome to Example" [ref=106]
  text "Building great products..." [ref=107]
  button "Get Started" [ref=108]
  img "Hero Image Mobile" [ref=109]
group "Features" [ref=110]
  article "Feature 1" [ref=111]
    img "Icon 1" [ref=112]
    heading "Fast" [ref=113]
    text "Lightning quick performance" [ref=114]
  article "Feature 2" [ref=115]
  article "Feature 3" [ref=116]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-mobile-375.png"
fullPage: true
```

### Test Mobile Navigation

```
Tool: browser_click

Parameters:
element: "Menu button"
ref: "102"
```

```
Tool: browser_wait_for

Parameters:
text: "Navigation"
```

```
Tool: browser_snapshot

Returns:
navigation "Mobile Menu Drawer" [ref=201]
  button "Close" [ref=202]
  list "Menu Items" [ref=203]
    link "Home" [ref=204]
    link "Features" [ref=205]
    link "Pricing" [ref=206]
    link "About" [ref=207]
    link "Contact" [ref=208]
  button "Sign In" [ref=209]
  button "Sign Up" [ref=210]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-menu-open-375.png"
fullPage: true
```

### Verify Touch-Friendly Buttons

```
Tool: browser_snapshot

Note: Verify button sizes
- Menu button: Should be at least 44x44px (touch-friendly)
- Get Started button: Should be large and prominent
- Navigation links: Should have adequate spacing
```

```
Tool: browser_evaluate

Parameters:
element: "Menu button"
ref: "102"
function: "(element) => { const rect = element.getBoundingClientRect(); return { width: rect.width, height: rect.height }; }"

Returns:
{ width: 48, height: 48 }
```

### Close Menu and Test Scroll

```
Tool: browser_click

Parameters:
element: "Close button"
ref: "202"
```

```
Tool: browser_evaluate

Parameters:
function: "() => { window.scrollTo(0, 500); }"
```

```
Tool: browser_wait_for

Parameters:
time: 1
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-scrolled-375.png"
```

## Step 2: Tablet Testing (iPad - 768x1024)

### Resize to Tablet

```
Tool: browser_resize

Parameters:
width: 768
height: 1024
```

### Navigate to Homepage

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading..."
```

### Capture Tablet Layout

```
Tool: browser_snapshot

Returns:
banner "Tablet Header" [ref=301]
  img "Logo" [ref=302]
  navigation "Main Nav" [ref=303]
    link "Features" [ref=304]
    link "Pricing" [ref=305]
    link "About" [ref=306]
    link "Contact" [ref=307]
  button "Sign In" [ref=308]
  button "Sign Up" [ref=309]
main "Content" [ref=310]
  group "Hero Section" [ref=311]
    heading "Welcome to Example" [ref=312]
    text "Building great products..." [ref=313]
    button "Get Started" [ref=314]
    img "Hero Image Tablet" [ref=315]
group "Features Grid" [ref=316]
  article "Feature 1" [ref=317]
  article "Feature 2" [ref=318]
  article "Feature 3" [ref=319]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-tablet-768.png"
fullPage: true
```

### Verify Layout Differences

**Key observations:**
- No hamburger menu (navigation visible in header)
- Hero image different aspect ratio
- Features displayed in 2-column grid (vs stacked on mobile)
- Buttons in header visible (not hidden in menu)

### Test Navigation (No Menu Button)

```
Tool: browser_click

Parameters:
element: "Features link"
ref: "304"
```

```
Tool: browser_wait_for

Parameters:
text: "Features"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "features-page-tablet-768.png"
fullPage: true
```

## Step 3: Desktop Testing (1920x1080)

### Resize to Desktop

```
Tool: browser_resize

Parameters:
width: 1920
height: 1080
```

### Navigate to Homepage

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading..."
```

### Capture Desktop Layout

```
Tool: browser_snapshot

Returns:
banner "Desktop Header" [ref=401]
  img "Logo Large" [ref=402]
  navigation "Main Navigation" [ref=403]
    link "Features" [ref=404]
    link "Pricing" [ref=405]
    link "About" [ref=406]
    link "Contact" [ref=407]
    link "Blog" [ref=408]
  group "User Actions" [ref=409]
    button "Sign In" [ref=410]
    button "Sign Up" [ref=411]
main "Hero Section" [ref=412]
  group "Hero Content" [ref=413]
    heading "Welcome to Example" [ref=414]
    text "Building great products for modern teams" [ref=415]
    button "Get Started Free" [ref=416]
    button "Watch Demo" [ref=417]
  img "Hero Image Desktop" [ref=418]
group "Features Section" [ref=419]
  heading "Why Choose Us" [ref=420]
  grid "Features" [ref=421]
    article "Feature 1" [ref=422]
    article "Feature 2" [ref=423]
    article "Feature 3" [ref=424]
    article "Feature 4" [ref=425]
    article "Feature 5" [ref=426]
    article "Feature 6" [ref=427]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-desktop-1920.png"
fullPage: true
```

### Verify Desktop Layout

**Key observations:**
- Full navigation visible with all links
- Hero section side-by-side layout (text left, image right)
- Features in 3-column grid
- Additional "Blog" link visible
- "Watch Demo" button visible (hidden on mobile)
- Larger typography and spacing

### Test Hover States

```
Tool: browser_hover

Parameters:
element: "Features link"
ref: "404"
```

```
Tool: browser_wait_for

Parameters:
time: 0.5
```

```
Tool: browser_take_screenshot

Parameters:
filename: "desktop-nav-hover-1920.png"
element: "Main Navigation"
ref: "403"
```

```
Tool: browser_hover

Parameters:
element: "Get Started Free button"
ref: "416"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "desktop-cta-hover-1920.png"
element: "Get Started Free button"
ref: "416"
```

## Step 4: Form Testing Across Viewports

### Mobile Form (375x667)

```
Tool: browser_resize

Parameters:
width: 375
height: 667
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com/contact"
```

```
Tool: browser_wait_for

Parameters:
text: "Contact Us"
```

```
Tool: browser_snapshot

Returns:
heading "Contact Us" [ref=501]
form "Contact Form" [ref=502]
  textbox "Name" [ref=503]
    placeholder: "Your name"
  textbox "Email" [ref=504]
    placeholder: "your@email.com"
  textbox "Phone" [ref=505]
    placeholder: "Optional"
  combobox "Subject" [ref=506]
  textbox "Message" [ref=507]
    multiline: true
  button "Send Message" [ref=508]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "contact-form-mobile-375.png"
fullPage: true
```

### Fill Mobile Form

```
Tool: browser_fill_form

Parameters:
fields: [
  {
    name: "Name",
    type: "textbox",
    ref: "503",
    value: "Jane Smith"
  },
  {
    name: "Email",
    type: "textbox",
    ref: "504",
    value: "jane@example.com"
  },
  {
    name: "Phone",
    type: "textbox",
    ref: "505",
    value: "555-0199"
  }
]
```

```
Tool: browser_select_option

Parameters:
element: "Subject dropdown"
ref: "506"
values: ["General Inquiry"]
```

```
Tool: browser_type

Parameters:
element: "Message textbox"
ref: "507"
text: "I would like to learn more about your services."
```

```
Tool: browser_take_screenshot

Parameters:
filename: "contact-form-filled-mobile-375.png"
fullPage: true
```

### Desktop Form (1920x1080)

```
Tool: browser_resize

Parameters:
width: 1920
height: 1080
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com/contact"
```

```
Tool: browser_wait_for

Parameters:
text: "Contact Us"
```

```
Tool: browser_snapshot

Returns:
group "Contact Page Layout" [ref=601]
  group "Form Section" [ref=602]
    heading "Get in Touch" [ref=603]
    form "Contact Form" [ref=604]
      group "Name and Email Row" [ref=605]
        textbox "Name" [ref=606]
        textbox "Email" [ref=607]
      group "Phone and Subject Row" [ref=608]
        textbox "Phone" [ref=609]
        combobox "Subject" [ref=610]
      textbox "Message" [ref=611]
        multiline: true
      button "Send Message" [ref=612]
  group "Contact Info" [ref=613]
    heading "Contact Information" [ref=614]
    text "Email: info@example.com" [ref=615]
    text "Phone: 1-800-555-0100" [ref=616]
    text "Address: 123 Main St" [ref=617]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "contact-form-desktop-1920.png"
fullPage: true
```

**Layout observations:**
- Mobile: Stacked single-column form
- Desktop: Two-column layout with form on left, contact info on right
- Desktop: Name/Email in same row, Phone/Subject in same row
- Mobile: All fields full-width, stacked vertically

## Step 5: Image Responsiveness Testing

### Test at Different Viewports

**Mobile (375x667):**

```
Tool: browser_resize

Parameters:
width: 375
height: 667
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading..."
```

```
Tool: browser_evaluate

Parameters:
element: "Hero Image Mobile"
ref: "109"
function: "(element) => { const img = element; return { src: img.src, width: img.width, height: img.height, naturalWidth: img.naturalWidth, naturalHeight: img.naturalHeight }; }"

Returns:
{
  src: "https://example.com/images/hero-mobile-375.jpg",
  width: 375,
  height: 250,
  naturalWidth: 750,
  naturalHeight: 500
}
```

```
Tool: browser_take_screenshot

Parameters:
filename: "hero-image-mobile-375.png"
element: "Hero Image Mobile"
ref: "109"
```

**Tablet (768x1024):**

```
Tool: browser_resize

Parameters:
width: 768
height: 1024
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_evaluate

Parameters:
element: "Hero Image Tablet"
ref: "315"
function: "(element) => { const img = element; return { src: img.src, width: img.width, height: img.height, naturalWidth: img.naturalWidth, naturalHeight: img.naturalHeight }; }"

Returns:
{
  src: "https://example.com/images/hero-tablet-768.jpg",
  width: 768,
  height: 400,
  naturalWidth: 1536,
  naturalHeight: 800
}
```

```
Tool: browser_take_screenshot

Parameters:
filename: "hero-image-tablet-768.png"
element: "Hero Image Tablet"
ref: "315"
```

**Desktop (1920x1080):**

```
Tool: browser_resize

Parameters:
width: 1920
height: 1080
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_evaluate

Parameters:
element: "Hero Image Desktop"
ref: "418"
function: "(element) => { const img = element; return { src: img.src, width: img.width, height: img.height, naturalWidth: img.naturalWidth, naturalHeight: img.naturalHeight }; }"

Returns:
{
  src: "https://example.com/images/hero-desktop-1920.jpg",
  width: 960,
  height: 640,
  naturalWidth: 1920,
  naturalHeight: 1280
}
```

```
Tool: browser_take_screenshot

Parameters:
filename: "hero-image-desktop-1920.png"
element: "Hero Image Desktop"
ref: "418"
```

**Verification:**
- ✅ Different image sources per viewport (optimized images)
- ✅ Appropriate image dimensions
- ✅ 2x resolution for retina displays
- ✅ Proper aspect ratios maintained

## Step 6: Typography and Readability Testing

### Mobile Typography (375x667)

```
Tool: browser_resize

Parameters:
width: 375
height: 667
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_evaluate

Parameters:
element: "Welcome heading"
ref: "106"
function: "(element) => { const styles = getComputedStyle(element); return { fontSize: styles.fontSize, lineHeight: styles.lineHeight, fontWeight: styles.fontWeight }; }"

Returns:
{
  fontSize: "32px",
  lineHeight: "38px",
  fontWeight: "700"
}
```

```
Tool: browser_evaluate

Parameters:
element: "Body text"
ref: "107"
function: "(element) => { const styles = getComputedStyle(element); return { fontSize: styles.fontSize, lineHeight: styles.lineHeight }; }"

Returns:
{
  fontSize: "16px",
  lineHeight: "24px"
}
```

### Desktop Typography (1920x1080)

```
Tool: browser_resize

Parameters:
width: 1920
height: 1080
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_evaluate

Parameters:
element: "Welcome heading"
ref: "414"
function: "(element) => { const styles = getComputedStyle(element); return { fontSize: styles.fontSize, lineHeight: styles.lineHeight, fontWeight: styles.fontWeight }; }"

Returns:
{
  fontSize: "56px",
  lineHeight: "64px",
  fontWeight: "700"
}
```

```
Tool: browser_evaluate

Parameters:
element: "Body text"
ref: "415"
function: "(element) => { const styles = getComputedStyle(element); return { fontSize: styles.fontSize, lineHeight: styles.lineHeight }; }"

Returns:
{
  fontSize: "18px",
  lineHeight: "28px"
}
```

**Typography Scaling:**
- Mobile heading: 32px
- Desktop heading: 56px (75% larger)
- Mobile body: 16px
- Desktop body: 18px (12.5% larger)
- ✅ Appropriate scaling for readability

## Step 7: Breakpoint Validation

### Test Key Breakpoints

**320px (Very small mobile):**

```
Tool: browser_resize

Parameters:
width: 320
height: 568
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-320.png"
fullPage: true
```

**480px (Small mobile landscape):**

```
Tool: browser_resize

Parameters:
width: 480
height: 320
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-480.png"
fullPage: true
```

**640px (Phablet):**

```
Tool: browser_resize

Parameters:
width: 640
height: 1136
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-640.png"
fullPage: true
```

**768px (Tablet portrait):**

```
Tool: browser_resize

Parameters:
width: 768
height: 1024
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-768.png"
fullPage: true
```

**1024px (Tablet landscape / Small laptop):**

```
Tool: browser_resize

Parameters:
width: 1024
height: 768
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-1024.png"
fullPage: true
```

**1280px (Standard laptop):**

```
Tool: browser_resize

Parameters:
width: 1280
height: 720
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-1280.png"
fullPage: true
```

**1920px (Full HD desktop):**

```
Tool: browser_resize

Parameters:
width: 1920
height: 1080
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-1920.png"
fullPage: true
```

**2560px (2K desktop):**

```
Tool: browser_resize

Parameters:
width: 2560
height: 1440
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "homepage-breakpoint-2560.png"
fullPage: true
```

## Step 8: Landscape vs Portrait Testing

### Mobile Portrait (iPhone 14 Pro)

```
Tool: browser_resize

Parameters:
width: 393
height: 852
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-portrait-393x852.png"
fullPage: true
```

### Mobile Landscape

```
Tool: browser_resize

Parameters:
width: 852
height: 393
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-landscape-852x393.png"
fullPage: true
```

### Tablet Portrait (iPad Pro 11")

```
Tool: browser_resize

Parameters:
width: 834
height: 1194
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "tablet-portrait-834x1194.png"
fullPage: true
```

### Tablet Landscape

```
Tool: browser_resize

Parameters:
width: 1194
height: 834
```

```
Tool: browser_navigate

Parameters:
url: "https://example.com"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "tablet-landscape-1194x834.png"
fullPage: true
```

## Results Summary

### Screenshots Captured by Category

**Mobile Viewports (7 screenshots):**
1. homepage-mobile-375.png
2. mobile-menu-open-375.png
3. mobile-scrolled-375.png
4. contact-form-mobile-375.png
5. contact-form-filled-mobile-375.png
6. hero-image-mobile-375.png
7. mobile-portrait-393x852.png

**Tablet Viewports (5 screenshots):**
8. homepage-tablet-768.png
9. features-page-tablet-768.png
10. contact-form-tablet-768.png
11. hero-image-tablet-768.png
12. tablet-portrait-834x1194.png

**Desktop Viewports (6 screenshots):**
13. homepage-desktop-1920.png
14. desktop-nav-hover-1920.png
15. desktop-cta-hover-1920.png
16. contact-form-desktop-1920.png
17. hero-image-desktop-1920.png
18. desktop-breakpoint-1920.png

**Breakpoint Testing (8 screenshots):**
19. homepage-breakpoint-320.png
20. homepage-breakpoint-480.png
21. homepage-breakpoint-640.png
22. homepage-breakpoint-768.png
23. homepage-breakpoint-1024.png
24. homepage-breakpoint-1280.png
25. homepage-breakpoint-1920.png
26. homepage-breakpoint-2560.png

**Orientation Testing (4 screenshots):**
27. mobile-portrait-393x852.png
28. mobile-landscape-852x393.png
29. tablet-portrait-834x1194.png
30. tablet-landscape-1194x834.png

### Responsive Features Verified

**Layout Adaptations:**
- ✅ Mobile: Single column, stacked layout
- ✅ Tablet: Two-column layout, visible navigation
- ✅ Desktop: Three-column grid, full navigation
- ✅ Proper content reflow at breakpoints

**Navigation:**
- ✅ Mobile: Hamburger menu with drawer
- ✅ Tablet/Desktop: Horizontal navigation bar
- ✅ Touch-friendly button sizes (48x48px minimum)

**Images:**
- ✅ Responsive images with appropriate sources
- ✅ Optimized for each viewport
- ✅ 2x resolution for retina displays
- ✅ Proper aspect ratios maintained

**Typography:**
- ✅ Readable font sizes at all viewports
- ✅ Appropriate line height
- ✅ Scaled headings for emphasis
- ✅ Consistent vertical rhythm

**Forms:**
- ✅ Mobile: Full-width, stacked fields
- ✅ Desktop: Multi-column layout
- ✅ Touch-friendly input sizes
- ✅ Proper keyboard types on mobile

**Breakpoints:**
- ✅ 320px: Very small mobile
- ✅ 480px: Small mobile landscape
- ✅ 640px: Large mobile
- ✅ 768px: Tablet portrait
- ✅ 1024px: Tablet landscape
- ✅ 1280px: Laptop
- ✅ 1920px: Desktop
- ✅ 2560px: Large desktop

### Issues Found

None - All responsive behaviors working as expected.

## Best Practices Demonstrated

1. **Systematic Testing**: Tested major viewport categories
2. **Breakpoint Validation**: Verified all CSS breakpoints
3. **Orientation Testing**: Checked portrait and landscape
4. **Touch Targets**: Verified minimum 44x44px sizes
5. **Image Optimization**: Confirmed responsive images
6. **Typography Scaling**: Verified readable sizes
7. **Layout Reflow**: Confirmed proper content stacking
8. **Navigation Patterns**: Verified appropriate UI per device
9. **Form Usability**: Tested form layouts across devices
10. **Screenshot Organization**: Clear naming convention

## Recommendations

1. **Performance**: Test image loading times at each viewport
2. **Accessibility**: Verify touch target spacing
3. **Content Priority**: Ensure critical content visible on mobile
4. **Progressive Enhancement**: Test with JavaScript disabled
5. **Network Throttling**: Test on slow connections
6. **Device Testing**: Test on real devices when possible
