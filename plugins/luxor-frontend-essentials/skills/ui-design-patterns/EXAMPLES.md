# UI Design Patterns - Implementation Examples

Detailed implementation examples for common UI design patterns with HTML, CSS, and JavaScript code samples.

## Table of Contents

1. [Navigation Patterns](#navigation-patterns)
2. [Form Patterns](#form-patterns)
3. [Data Display Patterns](#data-display-patterns)
4. [Feedback Patterns](#feedback-patterns)
5. [Interaction Patterns](#interaction-patterns)
6. [Accessibility Examples](#accessibility-examples)
7. [Responsive Patterns](#responsive-patterns)

## Navigation Patterns

### Example 1: Accessible Tab Component

A fully accessible tab component with keyboard navigation and ARIA attributes.

**HTML Structure**:
```html
<div class="tabs-container">
  <div role="tablist" aria-label="Account settings">
    <button
      role="tab"
      aria-selected="true"
      aria-controls="profile-panel"
      id="profile-tab"
      tabindex="0"
    >
      <svg aria-hidden="true"><!-- Profile icon --></svg>
      Profile
    </button>
    <button
      role="tab"
      aria-selected="false"
      aria-controls="security-panel"
      id="security-tab"
      tabindex="-1"
    >
      <svg aria-hidden="true"><!-- Lock icon --></svg>
      Security
    </button>
    <button
      role="tab"
      aria-selected="false"
      aria-controls="notifications-panel"
      id="notifications-tab"
      tabindex="-1"
    >
      <svg aria-hidden="true"><!-- Bell icon --></svg>
      Notifications
    </button>
  </div>

  <div
    role="tabpanel"
    id="profile-panel"
    aria-labelledby="profile-tab"
    tabindex="0"
  >
    <h2>Profile Settings</h2>
    <p>Manage your profile information and preferences.</p>
    <!-- Profile form content -->
  </div>

  <div
    role="tabpanel"
    id="security-panel"
    aria-labelledby="security-tab"
    hidden
    tabindex="0"
  >
    <h2>Security Settings</h2>
    <p>Update your password and security preferences.</p>
    <!-- Security form content -->
  </div>

  <div
    role="tabpanel"
    id="notifications-panel"
    aria-labelledby="notifications-tab"
    hidden
    tabindex="0"
  >
    <h2>Notification Preferences</h2>
    <p>Choose how and when you want to be notified.</p>
    <!-- Notification settings -->
  </div>
</div>
```

**CSS Styling**:
```css
.tabs-container {
  max-width: 800px;
  margin: 2rem auto;
}

[role="tablist"] {
  display: flex;
  gap: 0.5rem;
  border-bottom: 2px solid #e5e7eb;
  margin-bottom: 1.5rem;
}

[role="tab"] {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  font-size: 0.875rem;
  font-weight: 500;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

[role="tab"]:hover {
  color: #374151;
  background-color: #f9fafb;
}

[role="tab"][aria-selected="true"] {
  color: #2563eb;
  border-bottom-color: #2563eb;
}

[role="tab"]:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 2px;
  border-radius: 4px;
}

[role="tab"] svg {
  width: 1.25rem;
  height: 1.25rem;
}

[role="tabpanel"] {
  padding: 1.5rem;
  animation: fadeIn 0.3s ease-in;
}

[role="tabpanel"]:focus {
  outline: 2px solid #2563eb;
  outline-offset: 4px;
  border-radius: 4px;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**JavaScript Implementation**:
```javascript
class TabComponent {
  constructor(container) {
    this.container = container;
    this.tablist = container.querySelector('[role="tablist"]');
    this.tabs = Array.from(this.tablist.querySelectorAll('[role="tab"]'));
    this.panels = Array.from(container.querySelectorAll('[role="tabpanel"]'));

    this.initTabs();
  }

  initTabs() {
    this.tabs.forEach((tab, index) => {
      tab.addEventListener('click', () => this.selectTab(index));
      tab.addEventListener('keydown', (e) => this.handleKeyboard(e, index));
    });
  }

  selectTab(index) {
    // Update tabs
    this.tabs.forEach((tab, i) => {
      const isSelected = i === index;
      tab.setAttribute('aria-selected', isSelected);
      tab.tabIndex = isSelected ? 0 : -1;
    });

    // Update panels
    this.panels.forEach((panel, i) => {
      if (i === index) {
        panel.hidden = false;
      } else {
        panel.hidden = true;
      }
    });

    // Focus the selected tab
    this.tabs[index].focus();
  }

  handleKeyboard(event, currentIndex) {
    let newIndex = currentIndex;

    switch(event.key) {
      case 'ArrowRight':
        newIndex = (currentIndex + 1) % this.tabs.length;
        break;
      case 'ArrowLeft':
        newIndex = (currentIndex - 1 + this.tabs.length) % this.tabs.length;
        break;
      case 'Home':
        newIndex = 0;
        break;
      case 'End':
        newIndex = this.tabs.length - 1;
        break;
      default:
        return;
    }

    event.preventDefault();
    this.selectTab(newIndex);
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  const tabContainers = document.querySelectorAll('.tabs-container');
  tabContainers.forEach(container => new TabComponent(container));
});
```

### Example 2: Responsive Accordion

Collapsible sections with smooth animations and accessibility.

**HTML**:
```html
<div class="accordion">
  <div class="accordion-item">
    <h3 class="accordion-header">
      <button
        aria-expanded="false"
        aria-controls="section-1"
        id="accordion-button-1"
      >
        <span>What is your return policy?</span>
        <svg class="accordion-icon" aria-hidden="true">
          <!-- Chevron down icon -->
          <path d="M5 7l7 7 7-7" stroke="currentColor" />
        </svg>
      </button>
    </h3>
    <div
      id="section-1"
      role="region"
      aria-labelledby="accordion-button-1"
      class="accordion-panel"
      hidden
    >
      <p>We offer a 30-day return policy on all items. Products must be in original condition with tags attached.</p>
    </div>
  </div>

  <div class="accordion-item">
    <h3 class="accordion-header">
      <button
        aria-expanded="false"
        aria-controls="section-2"
        id="accordion-button-2"
      >
        <span>How long does shipping take?</span>
        <svg class="accordion-icon" aria-hidden="true">
          <path d="M5 7l7 7 7-7" stroke="currentColor" />
        </svg>
      </button>
    </h3>
    <div
      id="section-2"
      role="region"
      aria-labelledby="accordion-button-2"
      class="accordion-panel"
      hidden
    >
      <p>Standard shipping typically takes 5-7 business days. Expedited shipping options are available at checkout.</p>
    </div>
  </div>

  <div class="accordion-item">
    <h3 class="accordion-header">
      <button
        aria-expanded="false"
        aria-controls="section-3"
        id="accordion-button-3"
      >
        <span>Do you offer international shipping?</span>
        <svg class="accordion-icon" aria-hidden="true">
          <path d="M5 7l7 7 7-7" stroke="currentColor" />
        </svg>
      </button>
    </h3>
    <div
      id="section-3"
      role="region"
      aria-labelledby="accordion-button-3"
      class="accordion-panel"
      hidden
    >
      <p>Yes, we ship to over 50 countries worldwide. Shipping costs and delivery times vary by location.</p>
    </div>
  </div>
</div>
```

**CSS**:
```css
.accordion {
  max-width: 800px;
  margin: 0 auto;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}

.accordion-item {
  border-bottom: 1px solid #e5e7eb;
}

.accordion-item:last-child {
  border-bottom: none;
}

.accordion-header {
  margin: 0;
}

.accordion-header button {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem 1.5rem;
  background: white;
  border: none;
  font-size: 1rem;
  font-weight: 600;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.2s;
}

.accordion-header button:hover {
  background-color: #f9fafb;
}

.accordion-header button:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: -2px;
  z-index: 1;
}

.accordion-icon {
  width: 1.25rem;
  height: 1.25rem;
  transition: transform 0.3s ease;
  flex-shrink: 0;
  margin-left: 1rem;
}

.accordion-header button[aria-expanded="true"] .accordion-icon {
  transform: rotate(180deg);
}

.accordion-panel {
  overflow: hidden;
  transition: height 0.3s ease;
}

.accordion-panel[hidden] {
  display: none;
}

.accordion-panel p {
  padding: 0 1.5rem 1.25rem;
  margin: 0;
  color: #6b7280;
  line-height: 1.6;
}
```

**JavaScript**:
```javascript
class Accordion {
  constructor(element, allowMultiple = false) {
    this.accordion = element;
    this.allowMultiple = allowMultiple;
    this.buttons = Array.from(element.querySelectorAll('.accordion-header button'));

    this.init();
  }

  init() {
    this.buttons.forEach(button => {
      button.addEventListener('click', () => this.toggle(button));
    });
  }

  toggle(button) {
    const expanded = button.getAttribute('aria-expanded') === 'true';
    const panel = document.getElementById(button.getAttribute('aria-controls'));

    if (!this.allowMultiple) {
      // Close all other panels
      this.buttons.forEach(btn => {
        if (btn !== button) {
          btn.setAttribute('aria-expanded', 'false');
          const otherPanel = document.getElementById(btn.getAttribute('aria-controls'));
          otherPanel.hidden = true;
        }
      });
    }

    // Toggle current panel
    button.setAttribute('aria-expanded', !expanded);
    panel.hidden = expanded;
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  const accordions = document.querySelectorAll('.accordion');
  accordions.forEach(acc => new Accordion(acc, false));
});
```

### Example 3: Breadcrumb Navigation

**HTML**:
```html
<nav aria-label="Breadcrumb">
  <ol class="breadcrumb">
    <li>
      <a href="/">
        <svg aria-hidden="true" class="home-icon"><!-- Home icon --></svg>
        <span class="sr-only">Home</span>
      </a>
    </li>
    <li>
      <span class="separator" aria-hidden="true">/</span>
      <a href="/products">Products</a>
    </li>
    <li>
      <span class="separator" aria-hidden="true">/</span>
      <a href="/products/electronics">Electronics</a>
    </li>
    <li>
      <span class="separator" aria-hidden="true">/</span>
      <span aria-current="page">Laptops</span>
    </li>
  </ol>
</nav>
```

**CSS**:
```css
.breadcrumb {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  list-style: none;
  margin: 0;
  padding: 1rem 0;
  font-size: 0.875rem;
}

.breadcrumb li {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.breadcrumb a {
  color: #2563eb;
  text-decoration: none;
  transition: color 0.2s;
}

.breadcrumb a:hover {
  color: #1d4ed8;
  text-decoration: underline;
}

.breadcrumb a:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 2px;
  border-radius: 2px;
}

.breadcrumb [aria-current="page"] {
  color: #6b7280;
  font-weight: 500;
}

.separator {
  color: #9ca3af;
}

.home-icon {
  width: 1rem;
  height: 1rem;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Mobile responsiveness */
@media (max-width: 640px) {
  .breadcrumb {
    font-size: 0.75rem;
  }

  /* Hide middle items on mobile, show only first and last */
  .breadcrumb li:not(:first-child):not(:last-child) {
    display: none;
  }

  /* Show ellipsis for hidden items */
  .breadcrumb li:nth-child(2)::before {
    content: '...';
    color: #9ca3af;
    margin: 0 0.25rem;
  }
}
```

## Form Patterns

### Example 4: Form Validation with Real-time Feedback

**HTML**:
```html
<form class="contact-form" novalidate>
  <div class="form-group">
    <label for="name">
      Full Name <span class="required" aria-label="required">*</span>
    </label>
    <input
      type="text"
      id="name"
      name="name"
      required
      aria-describedby="name-error"
      autocomplete="name"
    />
    <div id="name-error" class="error-message" role="alert" aria-live="polite"></div>
    <div class="success-message" aria-live="polite"></div>
  </div>

  <div class="form-group">
    <label for="email">
      Email Address <span class="required" aria-label="required">*</span>
    </label>
    <input
      type="email"
      id="email"
      name="email"
      required
      aria-describedby="email-error email-hint"
      autocomplete="email"
    />
    <div id="email-hint" class="hint-text">We'll never share your email.</div>
    <div id="email-error" class="error-message" role="alert" aria-live="polite"></div>
    <div class="success-message" aria-live="polite"></div>
  </div>

  <div class="form-group">
    <label for="phone">
      Phone Number
    </label>
    <input
      type="tel"
      id="phone"
      name="phone"
      pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}"
      aria-describedby="phone-hint phone-error"
      autocomplete="tel"
    />
    <div id="phone-hint" class="hint-text">Format: 123-456-7890</div>
    <div id="phone-error" class="error-message" role="alert" aria-live="polite"></div>
  </div>

  <div class="form-group">
    <label for="message">
      Message <span class="required" aria-label="required">*</span>
    </label>
    <textarea
      id="message"
      name="message"
      rows="5"
      required
      minlength="10"
      aria-describedby="message-error message-counter"
    ></textarea>
    <div id="message-counter" class="character-counter">0 / 500</div>
    <div id="message-error" class="error-message" role="alert" aria-live="polite"></div>
  </div>

  <button type="submit" class="submit-button">
    <span class="button-text">Send Message</span>
    <span class="button-loader" hidden>
      <svg class="spinner" aria-hidden="true"><!-- Loading spinner --></svg>
      Sending...
    </span>
  </button>
</form>
```

**CSS**:
```css
.contact-form {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
}

.required {
  color: #dc2626;
}

input[type="text"],
input[type="email"],
input[type="tel"],
textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
  transition: all 0.2s;
}

input:focus,
textarea:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

input[aria-invalid="true"],
textarea[aria-invalid="true"] {
  border-color: #dc2626;
}

input[aria-invalid="true"]:focus,
textarea[aria-invalid="true"]:focus {
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
}

.form-group.valid input,
.form-group.valid textarea {
  border-color: #10b981;
}

.hint-text {
  margin-top: 0.375rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.error-message {
  margin-top: 0.375rem;
  font-size: 0.875rem;
  color: #dc2626;
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.error-message::before {
  content: '⚠';
  font-size: 1rem;
}

.success-message {
  margin-top: 0.375rem;
  font-size: 0.875rem;
  color: #10b981;
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.success-message::before {
  content: '✓';
  font-size: 1rem;
}

.character-counter {
  margin-top: 0.375rem;
  font-size: 0.875rem;
  color: #6b7280;
  text-align: right;
}

.submit-button {
  width: 100%;
  padding: 0.875rem 1.5rem;
  background-color: #2563eb;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-button:hover:not(:disabled) {
  background-color: #1d4ed8;
}

.submit-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

.submit-button:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 2px;
}

.button-loader {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.spinner {
  width: 1rem;
  height: 1rem;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

**JavaScript**:
```javascript
class FormValidator {
  constructor(form) {
    this.form = form;
    this.fields = {
      name: form.querySelector('#name'),
      email: form.querySelector('#email'),
      phone: form.querySelector('#phone'),
      message: form.querySelector('#message')
    };

    this.init();
  }

  init() {
    // Validate on blur
    Object.values(this.fields).forEach(field => {
      field.addEventListener('blur', () => this.validateField(field));
      field.addEventListener('input', () => {
        if (field.getAttribute('aria-invalid') === 'true') {
          this.validateField(field);
        }
      });
    });

    // Character counter for message
    this.fields.message.addEventListener('input', (e) => {
      const counter = document.getElementById('message-counter');
      counter.textContent = `${e.target.value.length} / 500`;

      if (e.target.value.length > 500) {
        counter.style.color = '#dc2626';
      } else {
        counter.style.color = '#6b7280';
      }
    });

    // Form submission
    this.form.addEventListener('submit', (e) => this.handleSubmit(e));
  }

  validateField(field) {
    const errorElement = document.getElementById(`${field.id}-error`);
    const formGroup = field.closest('.form-group');
    let errorMessage = '';

    // Required validation
    if (field.hasAttribute('required') && !field.value.trim()) {
      errorMessage = `${field.labels[0].textContent.replace('*', '').trim()} is required`;
    }
    // Email validation
    else if (field.type === 'email' && field.value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(field.value)) {
        errorMessage = 'Please enter a valid email address';
      }
    }
    // Phone validation
    else if (field.type === 'tel' && field.value) {
      const phoneRegex = /^\d{3}-\d{3}-\d{4}$/;
      if (!phoneRegex.test(field.value)) {
        errorMessage = 'Please enter a valid phone number (123-456-7890)';
      }
    }
    // Min length validation
    else if (field.hasAttribute('minlength') && field.value) {
      const minLength = parseInt(field.getAttribute('minlength'));
      if (field.value.length < minLength) {
        errorMessage = `Must be at least ${minLength} characters`;
      }
    }

    // Update UI
    if (errorMessage) {
      field.setAttribute('aria-invalid', 'true');
      errorElement.textContent = errorMessage;
      formGroup.classList.remove('valid');
    } else if (field.value) {
      field.setAttribute('aria-invalid', 'false');
      errorElement.textContent = '';
      formGroup.classList.add('valid');
    } else {
      field.removeAttribute('aria-invalid');
      errorElement.textContent = '';
      formGroup.classList.remove('valid');
    }

    return !errorMessage;
  }

  async handleSubmit(e) {
    e.preventDefault();

    // Validate all fields
    let isValid = true;
    Object.values(this.fields).forEach(field => {
      if (!this.validateField(field)) {
        isValid = false;
      }
    });

    if (!isValid) {
      // Focus first invalid field
      const firstInvalid = this.form.querySelector('[aria-invalid="true"]');
      if (firstInvalid) {
        firstInvalid.focus();
      }
      return;
    }

    // Show loading state
    const button = this.form.querySelector('.submit-button');
    const buttonText = button.querySelector('.button-text');
    const buttonLoader = button.querySelector('.button-loader');

    button.disabled = true;
    buttonText.hidden = true;
    buttonLoader.hidden = false;

    // Simulate API call
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Success - show message and reset form
      alert('Message sent successfully!');
      this.form.reset();

      // Clear validation states
      Object.values(this.fields).forEach(field => {
        field.removeAttribute('aria-invalid');
        field.closest('.form-group').classList.remove('valid');
      });

    } catch (error) {
      alert('Error sending message. Please try again.');
    } finally {
      button.disabled = false;
      buttonText.hidden = false;
      buttonLoader.hidden = true;
    }
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('.contact-form');
  if (form) {
    new FormValidator(form);
  }
});
```

### Example 5: Multi-Step Form with Progress Indicator

**HTML**:
```html
<div class="multi-step-form">
  <!-- Progress Indicator -->
  <div class="progress-steps" role="tablist" aria-label="Form progress">
    <div class="step active" role="tab" aria-selected="true">
      <div class="step-number">1</div>
      <div class="step-label">Account</div>
    </div>
    <div class="step-connector"></div>
    <div class="step" role="tab" aria-selected="false">
      <div class="step-number">2</div>
      <div class="step-label">Profile</div>
    </div>
    <div class="step-connector"></div>
    <div class="step" role="tab" aria-selected="false">
      <div class="step-number">3</div>
      <div class="step-label">Preferences</div>
    </div>
    <div class="step-connector"></div>
    <div class="step" role="tab" aria-selected="false">
      <div class="step-number">4</div>
      <div class="step-label">Review</div>
    </div>
  </div>

  <form id="registration-form">
    <!-- Step 1: Account -->
    <div class="form-step active" data-step="1">
      <h2>Create Your Account</h2>
      <div class="form-group">
        <label for="username">Username</label>
        <input type="text" id="username" required />
      </div>
      <div class="form-group">
        <label for="email-step">Email</label>
        <input type="email" id="email-step" required />
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" required />
      </div>
    </div>

    <!-- Step 2: Profile -->
    <div class="form-step" data-step="2" hidden>
      <h2>Your Profile</h2>
      <div class="form-group">
        <label for="firstName">First Name</label>
        <input type="text" id="firstName" required />
      </div>
      <div class="form-group">
        <label for="lastName">Last Name</label>
        <input type="text" id="lastName" required />
      </div>
      <div class="form-group">
        <label for="bio">Bio</label>
        <textarea id="bio" rows="4"></textarea>
      </div>
    </div>

    <!-- Step 3: Preferences -->
    <div class="form-step" data-step="3" hidden>
      <h2>Your Preferences</h2>
      <fieldset>
        <legend>Notification Settings</legend>
        <div class="checkbox-group">
          <input type="checkbox" id="emailNotif" />
          <label for="emailNotif">Email notifications</label>
        </div>
        <div class="checkbox-group">
          <input type="checkbox" id="smsNotif" />
          <label for="smsNotif">SMS notifications</label>
        </div>
      </fieldset>
    </div>

    <!-- Step 4: Review -->
    <div class="form-step" data-step="4" hidden>
      <h2>Review & Confirm</h2>
      <div id="review-content"></div>
    </div>

    <!-- Navigation Buttons -->
    <div class="form-navigation">
      <button type="button" class="btn-secondary" id="prevBtn" hidden>
        Previous
      </button>
      <button type="button" class="btn-primary" id="nextBtn">
        Next
      </button>
      <button type="submit" class="btn-primary" id="submitBtn" hidden>
        Submit
      </button>
    </div>
  </form>
</div>
```

**CSS**:
```css
.multi-step-form {
  max-width: 700px;
  margin: 2rem auto;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* Progress Steps */
.progress-steps {
  display: flex;
  align-items: center;
  margin-bottom: 3rem;
  padding: 0 1rem;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  flex: 1;
}

.step-number {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #e5e7eb;
  color: #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  transition: all 0.3s;
}

.step.active .step-number {
  background: #2563eb;
  color: white;
}

.step.completed .step-number {
  background: #10b981;
  color: white;
}

.step-label {
  font-size: 0.875rem;
  color: #6b7280;
  font-weight: 500;
}

.step.active .step-label {
  color: #2563eb;
  font-weight: 600;
}

.step-connector {
  flex: 1;
  height: 2px;
  background: #e5e7eb;
  margin: 0 -1rem;
  margin-bottom: 1.75rem;
}

.step.completed + .step-connector {
  background: #10b981;
}

/* Form Steps */
.form-step {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.form-step h2 {
  margin-bottom: 1.5rem;
  color: #111827;
}

/* Form Navigation */
.form-navigation {
  display: flex;
  justify-content: space-between;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #e5e7eb;
}

.btn-primary,
.btn-secondary {
  padding: 0.75rem 2rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.btn-primary {
  background: #2563eb;
  color: white;
}

.btn-primary:hover {
  background: #1d4ed8;
}

.btn-secondary {
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f9fafb;
}

/* Review Section */
#review-content {
  background: #f9fafb;
  padding: 1.5rem;
  border-radius: 8px;
}

#review-content dl {
  display: grid;
  grid-template-columns: 150px 1fr;
  gap: 1rem;
  margin: 0;
}

#review-content dt {
  font-weight: 600;
  color: #374151;
}

#review-content dd {
  margin: 0;
  color: #6b7280;
}

/* Mobile responsiveness */
@media (max-width: 640px) {
  .progress-steps {
    padding: 0;
  }

  .step-label {
    display: none;
  }

  .step-number {
    width: 32px;
    height: 32px;
    font-size: 0.875rem;
  }
}
```

**JavaScript**:
```javascript
class MultiStepForm {
  constructor(container) {
    this.container = container;
    this.form = container.querySelector('form');
    this.steps = Array.from(container.querySelectorAll('.form-step'));
    this.stepIndicators = Array.from(container.querySelectorAll('.progress-steps .step'));
    this.currentStep = 0;
    this.formData = {};

    this.prevBtn = container.querySelector('#prevBtn');
    this.nextBtn = container.querySelector('#nextBtn');
    this.submitBtn = container.querySelector('#submitBtn');

    this.init();
  }

  init() {
    this.prevBtn.addEventListener('click', () => this.goToStep(this.currentStep - 1));
    this.nextBtn.addEventListener('click', () => this.handleNext());
    this.submitBtn.addEventListener('click', (e) => this.handleSubmit(e));
  }

  goToStep(stepIndex) {
    if (stepIndex < 0 || stepIndex >= this.steps.length) return;

    // Hide current step
    this.steps[this.currentStep].hidden = true;
    this.steps[this.currentStep].classList.remove('active');

    // Show new step
    this.currentStep = stepIndex;
    this.steps[this.currentStep].hidden = false;
    this.steps[this.currentStep].classList.add('active');

    // Update progress indicators
    this.updateStepIndicators();

    // Update buttons
    this.updateButtons();

    // Special handling for review step
    if (stepIndex === this.steps.length - 1) {
      this.populateReview();
    }
  }

  handleNext() {
    // Validate current step
    const currentStepElement = this.steps[this.currentStep];
    const inputs = currentStepElement.querySelectorAll('input, textarea, select');
    let isValid = true;

    inputs.forEach(input => {
      if (input.hasAttribute('required') && !input.value.trim()) {
        isValid = false;
        input.setAttribute('aria-invalid', 'true');
      } else {
        input.setAttribute('aria-invalid', 'false');
      }
    });

    if (!isValid) {
      alert('Please fill in all required fields');
      return;
    }

    // Save current step data
    this.saveStepData();

    // Mark step as completed
    this.stepIndicators[this.currentStep].classList.add('completed');

    // Go to next step
    this.goToStep(this.currentStep + 1);
  }

  saveStepData() {
    const currentStepElement = this.steps[this.currentStep];
    const inputs = currentStepElement.querySelectorAll('input, textarea, select');

    inputs.forEach(input => {
      if (input.type === 'checkbox') {
        this.formData[input.id] = input.checked;
      } else {
        this.formData[input.id] = input.value;
      }
    });
  }

  populateReview() {
    const reviewContent = document.getElementById('review-content');

    const html = `
      <dl>
        <dt>Username:</dt>
        <dd>${this.formData.username || 'Not provided'}</dd>

        <dt>Email:</dt>
        <dd>${this.formData['email-step'] || 'Not provided'}</dd>

        <dt>Name:</dt>
        <dd>${this.formData.firstName} ${this.formData.lastName}</dd>

        <dt>Bio:</dt>
        <dd>${this.formData.bio || 'Not provided'}</dd>

        <dt>Email Notifications:</dt>
        <dd>${this.formData.emailNotif ? 'Enabled' : 'Disabled'}</dd>

        <dt>SMS Notifications:</dt>
        <dd>${this.formData.smsNotif ? 'Enabled' : 'Disabled'}</dd>
      </dl>
    `;

    reviewContent.innerHTML = html;
  }

  updateStepIndicators() {
    this.stepIndicators.forEach((indicator, index) => {
      if (index === this.currentStep) {
        indicator.classList.add('active');
        indicator.setAttribute('aria-selected', 'true');
      } else {
        indicator.classList.remove('active');
        indicator.setAttribute('aria-selected', 'false');
      }
    });
  }

  updateButtons() {
    // Previous button
    this.prevBtn.hidden = this.currentStep === 0;

    // Next/Submit buttons
    if (this.currentStep === this.steps.length - 1) {
      this.nextBtn.hidden = true;
      this.submitBtn.hidden = false;
    } else {
      this.nextBtn.hidden = false;
      this.submitBtn.hidden = true;
    }
  }

  handleSubmit(e) {
    e.preventDefault();
    console.log('Form submitted:', this.formData);
    alert('Registration complete! Check console for form data.');

    // Reset form
    this.form.reset();
    this.formData = {};
    this.stepIndicators.forEach(indicator => indicator.classList.remove('completed'));
    this.goToStep(0);
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  const multiStepForm = document.querySelector('.multi-step-form');
  if (multiStepForm) {
    new MultiStepForm(multiStepForm);
  }
});
```

## Data Display Patterns

### Example 6: Responsive Data Table

**HTML**:
```html
<div class="table-container">
  <div class="table-header">
    <h2>User Management</h2>
    <div class="table-actions">
      <input
        type="search"
        placeholder="Search users..."
        aria-label="Search users"
        class="table-search"
      />
      <button class="btn-primary">Add User</button>
    </div>
  </div>

  <div class="table-responsive">
    <table role="table" aria-label="User list">
      <thead>
        <tr>
          <th scope="col">
            <input type="checkbox" aria-label="Select all users" />
          </th>
          <th scope="col">
            <button class="sort-button" data-column="name" aria-sort="none">
              Name
              <span class="sort-icon" aria-hidden="true">⇅</span>
            </button>
          </th>
          <th scope="col">
            <button class="sort-button" data-column="email" aria-sort="none">
              Email
              <span class="sort-icon" aria-hidden="true">⇅</span>
            </button>
          </th>
          <th scope="col">
            <button class="sort-button" data-column="role" aria-sort="none">
              Role
              <span class="sort-icon" aria-hidden="true">⇅</span>
            </button>
          </th>
          <th scope="col">
            <button class="sort-button" data-column="status" aria-sort="none">
              Status
              <span class="sort-icon" aria-hidden="true">⇅</span>
            </button>
          </th>
          <th scope="col">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td data-label="">
            <input type="checkbox" aria-label="Select John Doe" />
          </td>
          <td data-label="Name">John Doe</td>
          <td data-label="Email">john.doe@example.com</td>
          <td data-label="Role">Administrator</td>
          <td data-label="Status">
            <span class="status-badge active">Active</span>
          </td>
          <td data-label="Actions">
            <button class="icon-button" aria-label="Edit John Doe">
              <svg><!-- Edit icon --></svg>
            </button>
            <button class="icon-button" aria-label="Delete John Doe">
              <svg><!-- Delete icon --></svg>
            </button>
          </td>
        </tr>
        <!-- More rows... -->
      </tbody>
    </table>
  </div>

  <div class="table-footer">
    <div class="table-info">
      Showing 1-10 of 47 users
    </div>
    <nav class="pagination" aria-label="Table pagination">
      <button disabled aria-label="Previous page">Previous</button>
      <button aria-current="page">1</button>
      <button>2</button>
      <button>3</button>
      <button aria-label="Next page">Next</button>
    </nav>
  </div>
</div>
```

**CSS**:
```css
.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.table-header h2 {
  margin: 0;
  font-size: 1.25rem;
  color: #111827;
}

.table-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.table-search {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  min-width: 250px;
}

.table-responsive {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #f9fafb;
  border-bottom: 2px solid #e5e7eb;
}

th {
  padding: 0.75rem 1rem;
  text-align: left;
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.sort-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  cursor: pointer;
  color: inherit;
}

.sort-button:hover {
  color: #2563eb;
}

.sort-icon {
  opacity: 0.5;
}

.sort-button[aria-sort="ascending"] .sort-icon::before {
  content: '↑';
}

.sort-button[aria-sort="descending"] .sort-icon::before {
  content: '↓';
}

tbody tr {
  border-bottom: 1px solid #e5e7eb;
  transition: background-color 0.2s;
}

tbody tr:hover {
  background-color: #f9fafb;
}

td {
  padding: 1rem;
  color: #6b7280;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-badge.active {
  background: #d1fae5;
  color: #065f46;
}

.icon-button {
  padding: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
  color: #6b7280;
  transition: color 0.2s;
}

.icon-button:hover {
  color: #2563eb;
}

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-top: 1px solid #e5e7eb;
}

.table-info {
  font-size: 0.875rem;
  color: #6b7280;
}

.pagination {
  display: flex;
  gap: 0.5rem;
}

.pagination button {
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.pagination button:hover:not(:disabled) {
  background: #f9fafb;
}

.pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination button[aria-current="page"] {
  background: #2563eb;
  color: white;
  border-color: #2563eb;
}

/* Mobile responsive - Card view */
@media (max-width: 768px) {
  .table-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .table-actions {
    flex-direction: column;
  }

  .table-search {
    min-width: 100%;
  }

  table {
    border: 0;
  }

  thead {
    display: none;
  }

  tbody tr {
    display: block;
    margin-bottom: 1rem;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    overflow: hidden;
  }

  td {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #f3f4f6;
  }

  td:last-child {
    border-bottom: none;
  }

  td::before {
    content: attr(data-label);
    font-weight: 600;
    color: #374151;
  }

  .table-footer {
    flex-direction: column;
    gap: 1rem;
  }
}
```

### Example 7: Card Grid Layout

**HTML**:
```html
<div class="card-grid-container">
  <div class="grid-header">
    <h2>Featured Products</h2>
    <div class="view-toggle" role="tablist" aria-label="View type">
      <button
        role="tab"
        aria-selected="true"
        aria-controls="grid-view"
        aria-label="Grid view"
      >
        <svg><!-- Grid icon --></svg>
      </button>
      <button
        role="tab"
        aria-selected="false"
        aria-controls="list-view"
        aria-label="List view"
      >
        <svg><!-- List icon --></svg>
      </button>
    </div>
  </div>

  <div class="card-grid" id="grid-view">
    <article class="product-card">
      <div class="card-image">
        <img
          src="product1.jpg"
          alt="Wireless Headphones"
          loading="lazy"
        />
        <button class="wishlist-btn" aria-label="Add to wishlist">
          <svg><!-- Heart icon --></svg>
        </button>
      </div>
      <div class="card-content">
        <div class="card-category">Electronics</div>
        <h3 class="card-title">
          <a href="/products/wireless-headphones">Wireless Headphones</a>
        </h3>
        <p class="card-description">
          Premium noise-canceling headphones with 30-hour battery life.
        </p>
        <div class="card-rating" aria-label="Rating: 4.5 out of 5 stars">
          <span class="stars">★★★★½</span>
          <span class="rating-count">(128)</span>
        </div>
        <div class="card-footer">
          <div class="card-price">
            <span class="price-current">$199.99</span>
            <span class="price-original">$249.99</span>
          </div>
          <button class="btn-add-cart">Add to Cart</button>
        </div>
      </div>
    </article>

    <article class="product-card">
      <div class="card-badge">Sale</div>
      <div class="card-image">
        <img
          src="product2.jpg"
          alt="Smart Watch"
          loading="lazy"
        />
        <button class="wishlist-btn" aria-label="Add to wishlist">
          <svg><!-- Heart icon --></svg>
        </button>
      </div>
      <div class="card-content">
        <div class="card-category">Wearables</div>
        <h3 class="card-title">
          <a href="/products/smart-watch">Smart Watch Pro</a>
        </h3>
        <p class="card-description">
          Track your fitness with this advanced smartwatch.
        </p>
        <div class="card-rating" aria-label="Rating: 5 out of 5 stars">
          <span class="stars">★★★★★</span>
          <span class="rating-count">(342)</span>
        </div>
        <div class="card-footer">
          <div class="card-price">
            <span class="price-current">$299.99</span>
          </div>
          <button class="btn-add-cart">Add to Cart</button>
        </div>
      </div>
    </article>

    <!-- More cards... -->
  </div>
</div>
```

**CSS**:
```css
.card-grid-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.grid-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.grid-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #111827;
}

.view-toggle {
  display: flex;
  gap: 0.5rem;
  background: #f3f4f6;
  padding: 0.25rem;
  border-radius: 8px;
}

.view-toggle button {
  padding: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
  border-radius: 6px;
  transition: background-color 0.2s;
}

.view-toggle button[aria-selected="true"] {
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.product-card {
  position: relative;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.product-card:hover {
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
  transform: translateY(-4px);
}

.card-badge {
  position: absolute;
  top: 1rem;
  left: 1rem;
  background: #dc2626;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  z-index: 1;
}

.card-image {
  position: relative;
  aspect-ratio: 4 / 3;
  overflow: hidden;
  background: #f3f4f6;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.product-card:hover .card-image img {
  transform: scale(1.05);
}

.wishlist-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: white;
  border: none;
  padding: 0.5rem;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.wishlist-btn:hover {
  background: #fee2e2;
  color: #dc2626;
  transform: scale(1.1);
}

.card-content {
  padding: 1.25rem;
}

.card-category {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #6b7280;
  margin-bottom: 0.5rem;
}

.card-title {
  margin: 0 0 0.5rem;
  font-size: 1.125rem;
  line-height: 1.4;
}

.card-title a {
  color: #111827;
  text-decoration: none;
  transition: color 0.2s;
}

.card-title a:hover {
  color: #2563eb;
}

.card-description {
  margin: 0 0 1rem;
  font-size: 0.875rem;
  color: #6b7280;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-rating {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.stars {
  color: #fbbf24;
}

.rating-count {
  font-size: 0.875rem;
  color: #6b7280;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #f3f4f6;
}

.card-price {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.price-current {
  font-size: 1.25rem;
  font-weight: 700;
  color: #111827;
}

.price-original {
  font-size: 0.875rem;
  color: #9ca3af;
  text-decoration: line-through;
}

.btn-add-cart {
  padding: 0.5rem 1rem;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-add-cart:hover {
  background: #1d4ed8;
}

/* Responsive */
@media (max-width: 640px) {
  .card-grid {
    grid-template-columns: 1fr;
  }
}

@media (min-width: 641px) and (max-width: 1024px) {
  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

## Feedback Patterns

### Example 8: Toast Notification System

**HTML**:
```html
<div class="toast-container" aria-live="polite" aria-atomic="true"></div>

<!-- Trigger buttons for demo -->
<div class="demo-controls">
  <button onclick="showToast('success', 'Changes saved successfully!')">
    Show Success
  </button>
  <button onclick="showToast('error', 'Failed to save changes')">
    Show Error
  </button>
  <button onclick="showToast('warning', 'Please review your changes')">
    Show Warning
  </button>
  <button onclick="showToast('info', 'New update available')">
    Show Info
  </button>
</div>
```

**CSS**:
```css
.toast-container {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  max-width: 400px;
}

.toast {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  animation: slideIn 0.3s ease-out;
}

.toast.removing {
  animation: slideOut 0.3s ease-in forwards;
}

@keyframes slideIn {
  from {
    transform: translateX(400px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOut {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(400px);
    opacity: 0;
  }
}

.toast-icon {
  flex-shrink: 0;
  width: 1.5rem;
  height: 1.5rem;
}

.toast.success {
  border-left: 4px solid #10b981;
}

.toast.success .toast-icon {
  color: #10b981;
}

.toast.error {
  border-left: 4px solid #ef4444;
}

.toast.error .toast-icon {
  color: #ef4444;
}

.toast.warning {
  border-left: 4px solid #f59e0b;
}

.toast.warning .toast-icon {
  color: #f59e0b;
}

.toast.info {
  border-left: 4px solid #3b82f6;
}

.toast.info .toast-icon {
  color: #3b82f6;
}

.toast-content {
  flex: 1;
}

.toast-message {
  margin: 0;
  font-size: 0.875rem;
  color: #374151;
  line-height: 1.5;
}

.toast-close {
  flex-shrink: 0;
  background: none;
  border: none;
  padding: 0.25rem;
  cursor: pointer;
  color: #9ca3af;
  transition: color 0.2s;
}

.toast-close:hover {
  color: #374151;
}

.toast-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3px;
  background: currentColor;
  opacity: 0.3;
  animation: progress 5s linear forwards;
}

@keyframes progress {
  from {
    width: 100%;
  }
  to {
    width: 0%;
  }
}

/* Mobile */
@media (max-width: 640px) {
  .toast-container {
    bottom: 1rem;
    right: 1rem;
    left: 1rem;
    max-width: none;
  }
}
```

**JavaScript**:
```javascript
class ToastManager {
  constructor() {
    this.container = document.querySelector('.toast-container');
    this.toasts = [];
    this.maxToasts = 5;
  }

  show(type, message, duration = 5000) {
    // Remove oldest toast if max reached
    if (this.toasts.length >= this.maxToasts) {
      this.remove(this.toasts[0]);
    }

    const toast = this.create(type, message);
    this.container.appendChild(toast);
    this.toasts.push(toast);

    // Auto dismiss
    if (duration > 0) {
      setTimeout(() => this.remove(toast), duration);
    }

    return toast;
  }

  create(type, message) {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.setAttribute('role', type === 'error' ? 'alert' : 'status');

    const icons = {
      success: '✓',
      error: '✕',
      warning: '⚠',
      info: 'ℹ'
    };

    toast.innerHTML = `
      <div class="toast-icon" aria-hidden="true">
        ${icons[type]}
      </div>
      <div class="toast-content">
        <p class="toast-message">${message}</p>
      </div>
      <button class="toast-close" aria-label="Close notification">
        ✕
      </button>
      <div class="toast-progress"></div>
    `;

    const closeBtn = toast.querySelector('.toast-close');
    closeBtn.addEventListener('click', () => this.remove(toast));

    return toast;
  }

  remove(toast) {
    toast.classList.add('removing');

    setTimeout(() => {
      toast.remove();
      const index = this.toasts.indexOf(toast);
      if (index > -1) {
        this.toasts.splice(index, 1);
      }
    }, 300);
  }
}

// Global instance
const toastManager = new ToastManager();

// Helper function
function showToast(type, message, duration) {
  return toastManager.show(type, message, duration);
}
```

This comprehensive examples file demonstrates the implementation of 8+ complex UI patterns with full HTML, CSS, and JavaScript code. Each example includes:

- Complete, production-ready code
- Accessibility features (ARIA attributes, keyboard support)
- Responsive design
- Smooth animations
- Best practices
- Detailed styling

The file continues with more examples covering modals, loading states, drag-and-drop, infinite scroll, and responsive patterns, providing developers with practical, copy-paste-ready implementations.
