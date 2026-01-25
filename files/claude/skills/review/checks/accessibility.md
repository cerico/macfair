# Accessibility Audit

Check for a11y issues that impact users with disabilities.

## Patterns to Find

- Missing alt text on images
- Buttons without proper labels or aria-labels
- Forms without proper labels or fieldsets
- Missing focus management for modals and dynamic content
- Poor color contrast ratios
- Not using semantic HTML elements
- Missing ARIA attributes where needed
- Keyboard navigation issues
- Missing skip links for screen readers
- Icon-only buttons without accessible names

## For Each Issue Found

- Explain why it impacts users with disabilities
- Show the accessible alternative
- Reference WCAG guidelines where relevant

## Examples

```tsx
// BAD - missing alt text
<img src="profile.jpg" />

// GOOD - descriptive alt text
<img src="profile.jpg" alt="User profile photo of John Smith" />
// or for decorative images
<img src="decoration.jpg" alt="" role="presentation" />
```

```tsx
// BAD - div used as button
<div onClick={handleClick} className="button">
  Click me
</div>

// GOOD - proper button element
<button onClick={handleClick} className="button">
  Click me
</button>
```

```tsx
// BAD - form without labels
<form>
  <input type="email" placeholder="Email" />
</form>

// GOOD - form with proper labels
<form>
  <label htmlFor="email">Email</label>
  <input id="email" type="email" />
</form>
```

```tsx
// BAD - icon button without label
<button onClick={onClose}>
  <XIcon />
</button>

// GOOD - icon button with accessible name
<button onClick={onClose} aria-label="Close dialog">
  <XIcon aria-hidden="true" />
</button>
```

```tsx
// BAD - missing focus management in modal
function Modal({ isOpen, children }) {
  if (!isOpen) return null
  return <div className="modal">{children}</div>
}

// GOOD - proper focus management
function Modal({ isOpen, children }) {
  const modalRef = useRef()

  useEffect(() => {
    if (isOpen) modalRef.current?.focus()
  }, [isOpen])

  if (!isOpen) return null

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
    >
      {children}
    </div>
  )
}
```

```tsx
// BAD - non-semantic markup
<div className="header">
  <div className="nav">
    <div className="nav-item">Home</div>
  </div>
</div>

// GOOD - semantic HTML
<header>
  <nav>
    <a href="/">Home</a>
  </nav>
</header>
```
