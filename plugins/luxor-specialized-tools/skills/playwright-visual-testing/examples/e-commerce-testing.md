# E-Commerce Site Testing Example

Complete workflow for testing an e-commerce website using Playwright MCP server. This example covers product browsing, shopping cart, checkout process, and visual validation.

## Scenario

Testing a production e-commerce site (example.com/shop) to verify:
- Product listing and search functionality
- Product detail page rendering
- Add to cart functionality
- Shopping cart operations
- Checkout flow
- Payment form validation
- Order confirmation

## Test Environment Setup

**Target URL**: https://example.com/shop
**Test Browsers**: Chromium, Firefox, WebKit
**Viewports**: Mobile (375x667), Desktop (1920x1080)

## Step 1: Product Listing Page Testing

### Navigate and Capture Initial State

```
Tool: browser_navigate

Parameters:
url: "https://example.com/shop"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading products..."
```

```
Tool: browser_snapshot

Returns:
heading "Shop" [ref=101]
textbox "Search products" [ref=102]
button "Filter" [ref=103]
list "Products" [ref=104]
  listitem "Product 1 - $29.99" [ref=105]
    button "Quick View" [ref=106]
    button "Add to Cart" [ref=107]
  listitem "Product 2 - $49.99" [ref=108]
    button "Quick View" [ref=109]
    button "Add to Cart" [ref=110]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "shop-products-desktop.png"
fullPage: true
```

### Test Product Search

```
Tool: browser_type

Parameters:
element: "Search products textbox"
ref: "102"
text: "wireless headphones"
submit: true
```

```
Tool: browser_wait_for

Parameters:
text: "Results for"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "shop-search-results.png"
fullPage: true
```

```
Tool: browser_snapshot

Returns:
heading "Results for 'wireless headphones'" [ref=201]
text "8 products found" [ref=202]
list "Search Results" [ref=203]
  listitem "Bluetooth Headphones - $79.99" [ref=204]
  listitem "Gaming Headset - $99.99" [ref=205]
```

### Test Product Filtering

```
Tool: browser_click

Parameters:
element: "Filter button"
ref: "103"
```

```
Tool: browser_wait_for

Parameters:
text: "Price Range"
```

```
Tool: browser_snapshot

Returns:
dialog "Filter Products" [ref=301]
  heading "Filter Products" [ref=302]
  group "Price Range" [ref=303]
    slider "Min Price" [ref=304]
    slider "Max Price" [ref=305]
  group "Category" [ref=306]
    checkbox "Electronics" [ref=307]
    checkbox "Accessories" [ref=308]
  button "Apply Filters" [ref=309]
  button "Clear All" [ref=310]
```

```
Tool: browser_click

Parameters:
element: "Electronics checkbox"
ref: "307"
```

```
Tool: browser_click

Parameters:
element: "Apply Filters button"
ref: "309"
```

```
Tool: browser_wait_for

Parameters:
text: "Filters applied"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "shop-filtered-products.png"
fullPage: true
```

## Step 2: Product Detail Page Testing

### Navigate to Product

```
Tool: browser_click

Parameters:
element: "Bluetooth Headphones product"
ref: "204"
```

```
Tool: browser_wait_for

Parameters:
text: "Product Details"
```

```
Tool: browser_snapshot

Returns:
heading "Bluetooth Headphones" [ref=401]
text "$79.99" [ref=402]
img "Product Image" [ref=403]
button "Previous Image" [ref=404]
button "Next Image" [ref=405]
group "Quantity" [ref=406]
  button "Decrease" [ref=407]
  textbox "Quantity" [ref=408]
  button "Increase" [ref=409]
button "Add to Cart" [ref=410]
button "Add to Wishlist" [ref=411]
heading "Description" [ref=412]
text "Premium wireless headphones..." [ref=413]
```

### Test Product Image Gallery

```
Tool: browser_take_screenshot

Parameters:
filename: "product-detail-image-1.png"
element: "Product Image"
ref: "403"
```

```
Tool: browser_click

Parameters:
element: "Next Image button"
ref: "405"
```

```
Tool: browser_wait_for

Parameters:
time: 0.5
```

```
Tool: browser_take_screenshot

Parameters:
filename: "product-detail-image-2.png"
element: "Product Image"
ref: "403"
```

### Test Quantity Selection

```
Tool: browser_click

Parameters:
element: "Increase quantity button"
ref: "409"
```

```
Tool: browser_click

Parameters:
element: "Increase quantity button"
ref: "409"
```

```
Tool: browser_snapshot

Returns:
textbox "Quantity" [ref=408]
  value: "3"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "product-quantity-updated.png"
```

### Add to Cart

```
Tool: browser_click

Parameters:
element: "Add to Cart button"
ref: "410"
```

```
Tool: browser_wait_for

Parameters:
text: "Added to cart"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "product-added-to-cart.png"
```

```
Tool: browser_snapshot

Returns:
alert "Added to cart" [ref=501]
  text "3 items added successfully" [ref=502]
  button "View Cart" [ref=503]
  button "Continue Shopping" [ref=504]
```

## Step 3: Shopping Cart Testing

### Open Cart

```
Tool: browser_click

Parameters:
element: "View Cart button"
ref: "503"
```

```
Tool: browser_wait_for

Parameters:
text: "Shopping Cart"
```

```
Tool: browser_snapshot

Returns:
heading "Shopping Cart" [ref=601]
text "3 items" [ref=602]
list "Cart Items" [ref=603]
  listitem "Bluetooth Headphones" [ref=604]
    img "Product thumbnail" [ref=605]
    text "Quantity: 3" [ref=606]
    text "Price: $79.99 each" [ref=607]
    text "Subtotal: $239.97" [ref=608]
    button "Update" [ref=609]
    button "Remove" [ref=610]
group "Cart Summary" [ref=611]
  text "Subtotal: $239.97" [ref=612]
  text "Shipping: $9.99" [ref=613]
  text "Tax: $24.00" [ref=614]
  text "Total: $273.96" [ref=615]
button "Continue Shopping" [ref=616]
button "Proceed to Checkout" [ref=617]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "shopping-cart-full.png"
fullPage: true
```

### Test Quantity Update

```
Tool: browser_click

Parameters:
element: "Update quantity button"
ref: "609"
```

```
Tool: browser_wait_for

Parameters:
text: "Update quantity"
```

```
Tool: browser_snapshot

Returns:
dialog "Update Quantity" [ref=701]
  textbox "New quantity" [ref=702]
  button "Update" [ref=703]
  button "Cancel" [ref=704]
```

```
Tool: browser_type

Parameters:
element: "New quantity textbox"
ref: "702"
text: "2"
```

```
Tool: browser_click

Parameters:
element: "Update button"
ref: "703"
```

```
Tool: browser_wait_for

Parameters:
text: "Cart updated"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "cart-quantity-updated.png"
```

### Test Remove Item

```
Tool: browser_navigate_back
```

```
Tool: browser_click

Parameters:
element: "Add to Cart button"
ref: "410"
```

```
Tool: browser_wait_for

Parameters:
text: "Added to cart"
```

```
Tool: browser_click

Parameters:
element: "View Cart button"
ref: "503"
```

```
Tool: browser_snapshot
```

```
Tool: browser_click

Parameters:
element: "Remove item button"
ref: "610"
```

```
Tool: browser_handle_dialog

Parameters:
accept: true
```

```
Tool: browser_wait_for

Parameters:
text: "Item removed"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "cart-item-removed.png"
```

## Step 4: Checkout Process Testing

### Navigate to Checkout

```
Tool: browser_click

Parameters:
element: "Proceed to Checkout button"
ref: "617"
```

```
Tool: browser_wait_for

Parameters:
text: "Checkout"
```

```
Tool: browser_snapshot

Returns:
heading "Checkout" [ref=801]
group "Step 1: Shipping Information" [ref=802]
  textbox "Full Name" [ref=803]
  textbox "Email" [ref=804]
  textbox "Phone" [ref=805]
  textbox "Address Line 1" [ref=806]
  textbox "Address Line 2" [ref=807]
  textbox "City" [ref=808]
  combobox "State" [ref=809]
  textbox "Zip Code" [ref=810]
button "Continue to Payment" [ref=811]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-step1-shipping.png"
fullPage: true
```

### Fill Shipping Information

```
Tool: browser_fill_form

Parameters:
fields: [
  {
    name: "Full Name",
    type: "textbox",
    ref: "803",
    value: "John Doe"
  },
  {
    name: "Email",
    type: "textbox",
    ref: "804",
    value: "john.doe@example.com"
  },
  {
    name: "Phone",
    type: "textbox",
    ref: "805",
    value: "555-0123"
  },
  {
    name: "Address Line 1",
    type: "textbox",
    ref: "806",
    value: "123 Main Street"
  },
  {
    name: "City",
    type: "textbox",
    ref: "808",
    value: "New York"
  },
  {
    name: "Zip Code",
    type: "textbox",
    ref: "810",
    value: "10001"
  }
]
```

```
Tool: browser_select_option

Parameters:
element: "State dropdown"
ref: "809"
values: ["New York"]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-shipping-filled.png"
fullPage: true
```

### Test Validation

```
Tool: browser_type

Parameters:
element: "Email textbox"
ref: "804"
text: "invalid-email"
```

```
Tool: browser_click

Parameters:
element: "Continue to Payment button"
ref: "811"
```

```
Tool: browser_wait_for

Parameters:
text: "Please enter a valid email"
```

```
Tool: browser_snapshot

Returns:
text "Please enter a valid email" [ref=901]
  role: alert
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-validation-error.png"
```

### Fix and Continue

```
Tool: browser_type

Parameters:
element: "Email textbox"
ref: "804"
text: "john.doe@example.com"
```

```
Tool: browser_click

Parameters:
element: "Continue to Payment button"
ref: "811"
```

```
Tool: browser_wait_for

Parameters:
text: "Payment Information"
```

## Step 5: Payment Form Testing

```
Tool: browser_snapshot

Returns:
heading "Step 2: Payment Information" [ref=1001]
group "Payment Method" [ref=1002]
  radio "Credit Card" [ref=1003] checked
  radio "PayPal" [ref=1004]
  radio "Apple Pay" [ref=1005]
group "Card Details" [ref=1006]
  textbox "Card Number" [ref=1007]
  textbox "Cardholder Name" [ref=1008]
  textbox "Expiry Date (MM/YY)" [ref=1009]
  textbox "CVV" [ref=1010]
checkbox "Save card for future purchases" [ref=1011]
button "Review Order" [ref=1012]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-step2-payment.png"
fullPage: true
```

### Fill Payment Information

```
Tool: browser_fill_form

Parameters:
fields: [
  {
    name: "Card Number",
    type: "textbox",
    ref: "1007",
    value: "4111111111111111"
  },
  {
    name: "Cardholder Name",
    type: "textbox",
    ref: "1008",
    value: "John Doe"
  },
  {
    name: "Expiry Date",
    type: "textbox",
    ref: "1009",
    value: "12/25"
  },
  {
    name: "CVV",
    type: "textbox",
    ref: "1010",
    value: "123"
  },
  {
    name: "Save card",
    type: "checkbox",
    ref: "1011",
    value: "true"
  }
]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-payment-filled.png"
fullPage: true
```

### Review Order

```
Tool: browser_click

Parameters:
element: "Review Order button"
ref: "1012"
```

```
Tool: browser_wait_for

Parameters:
text: "Review Your Order"
```

```
Tool: browser_snapshot

Returns:
heading "Step 3: Review Your Order" [ref=1101]
group "Shipping Address" [ref=1102]
  text "John Doe" [ref=1103]
  text "123 Main Street" [ref=1104]
  text "New York, NY 10001" [ref=1105]
  button "Edit" [ref=1106]
group "Payment Method" [ref=1107]
  text "Credit Card ending in 1111" [ref=1108]
  button "Edit" [ref=1109]
group "Order Summary" [ref=1110]
  list "Order Items" [ref=1111]
    listitem "Bluetooth Headphones (2) - $159.98" [ref=1112]
  text "Subtotal: $159.98" [ref=1113]
  text "Shipping: $9.99" [ref=1114]
  text "Tax: $16.00" [ref=1115]
  text "Total: $185.97" [ref=1116]
button "Place Order" [ref=1117]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "checkout-step3-review.png"
fullPage: true
```

## Step 6: Order Placement and Confirmation

### Place Order

```
Tool: browser_click

Parameters:
element: "Place Order button"
ref: "1117"
```

```
Tool: browser_wait_for

Parameters:
text: "Processing order"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "order-processing.png"
```

```
Tool: browser_wait_for

Parameters:
text: "Order Confirmed"
```

```
Tool: browser_snapshot

Returns:
heading "Order Confirmed!" [ref=1201]
text "Thank you for your purchase" [ref=1202]
text "Order Number: #12345" [ref=1203]
text "Confirmation email sent to john.doe@example.com" [ref=1204]
group "Order Details" [ref=1205]
  text "Expected Delivery: Oct 25, 2025" [ref=1206]
  text "Total Paid: $185.97" [ref=1207]
button "View Order Details" [ref=1208]
button "Continue Shopping" [ref=1209]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "order-confirmed.png"
fullPage: true
```

### Verify Network Activity

```
Tool: browser_network_requests

Returns:
[
  {
    url: "https://example.com/api/checkout",
    method: "POST",
    status: 200,
    response: {
      orderId: "12345",
      status: "confirmed",
      total: 185.97
    }
  },
  {
    url: "https://example.com/api/payment/process",
    method: "POST",
    status: 200,
    response: {
      transactionId: "txn_abc123",
      status: "success"
    }
  },
  {
    url: "https://example.com/api/email/confirmation",
    method: "POST",
    status: 200
  }
]
```

### Check Console Messages

```
Tool: browser_console_messages

Parameters:
onlyErrors: true

Returns:
[No errors found]
```

## Step 7: Responsive Testing - Mobile

### Resize to Mobile

```
Tool: browser_resize

Parameters:
width: 375
height: 667
```

### Navigate to Shop

```
Tool: browser_navigate

Parameters:
url: "https://example.com/shop"
```

```
Tool: browser_wait_for

Parameters:
textGone: "Loading products..."
```

```
Tool: browser_snapshot

Returns:
button "Menu" [ref=1301]
heading "Shop" [ref=1302]
button "Search" [ref=1303]
list "Products" [ref=1304]
  listitem "Product Card (Mobile)" [ref=1305]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "shop-mobile-view.png"
fullPage: true
```

### Test Mobile Navigation

```
Tool: browser_click

Parameters:
element: "Menu button"
ref: "1301"
```

```
Tool: browser_wait_for

Parameters:
text: "Navigation"
```

```
Tool: browser_snapshot

Returns:
navigation "Mobile Menu" [ref=1401]
  link "Home" [ref=1402]
  link "Shop" [ref=1403]
  link "Cart" [ref=1404]
  link "Account" [ref=1405]
  button "Close Menu" [ref=1406]
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-menu-open.png"
fullPage: true
```

### Test Mobile Product View

```
Tool: browser_click

Parameters:
element: "Close Menu button"
ref: "1406"
```

```
Tool: browser_click

Parameters:
element: "Product Card"
ref: "1305"
```

```
Tool: browser_wait_for

Parameters:
text: "Product Details"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "product-detail-mobile.png"
fullPage: true
```

### Test Mobile Cart

```
Tool: browser_click

Parameters:
element: "Add to Cart button"
ref: "410"
```

```
Tool: browser_wait_for

Parameters:
text: "Added to cart"
```

```
Tool: browser_take_screenshot

Parameters:
filename: "mobile-cart-notification.png"
```

## Results Summary

### Screenshots Captured

**Desktop (1920x1080):**
1. shop-products-desktop.png - Product listing page
2. shop-search-results.png - Search functionality
3. shop-filtered-products.png - Applied filters
4. product-detail-image-1.png - Product image gallery
5. product-added-to-cart.png - Add to cart confirmation
6. shopping-cart-full.png - Cart with items
7. cart-quantity-updated.png - Updated quantities
8. cart-item-removed.png - Item removal
9. checkout-step1-shipping.png - Shipping form
10. checkout-shipping-filled.png - Completed shipping
11. checkout-validation-error.png - Validation errors
12. checkout-step2-payment.png - Payment form
13. checkout-payment-filled.png - Completed payment
14. checkout-step3-review.png - Order review
15. order-processing.png - Processing state
16. order-confirmed.png - Confirmation page

**Mobile (375x667):**
17. shop-mobile-view.png - Mobile product listing
18. mobile-menu-open.png - Mobile navigation
19. product-detail-mobile.png - Mobile product view
20. mobile-cart-notification.png - Mobile cart feedback

### Tests Performed

- Product search functionality: ✅ Passed
- Product filtering: ✅ Passed
- Product image gallery: ✅ Passed
- Quantity selection: ✅ Passed
- Add to cart: ✅ Passed
- Cart update: ✅ Passed
- Cart remove item: ✅ Passed
- Checkout shipping form: ✅ Passed
- Form validation: ✅ Passed
- Payment form: ✅ Passed
- Order review: ✅ Passed
- Order placement: ✅ Passed
- Mobile responsive layout: ✅ Passed
- Mobile navigation: ✅ Passed

### Network Activity

- All API calls returned 200 status
- No failed network requests
- Payment processing successful
- Confirmation email sent

### Console Messages

- No JavaScript errors detected
- No console warnings
- Clean execution

## Best Practices Demonstrated

1. **Wait for dynamic content**: Used browser_wait_for consistently
2. **Snapshot before interaction**: Always captured snapshot to get refs
3. **Screenshot critical states**: Documented each major step
4. **Test validation**: Verified error states and validation
5. **Mobile testing**: Tested responsive layouts
6. **Network verification**: Checked API calls and responses
7. **Console monitoring**: Verified no JavaScript errors
8. **Descriptive filenames**: Used clear naming convention
9. **Full workflow**: Tested complete user journey
10. **Error handling**: Tested and documented error states

## Next Steps

1. **Visual regression**: Compare screenshots against baselines
2. **Cross-browser**: Repeat tests on Firefox and WebKit
3. **Performance**: Monitor page load times and network timing
4. **Accessibility**: Verify ARIA labels and keyboard navigation
5. **Error scenarios**: Test network failures and timeouts
6. **Edge cases**: Test with maximum quantities, special characters
7. **Integration**: Add to CI/CD pipeline for automated testing
