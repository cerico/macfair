# Documentation Quality

Check for documentation gaps and issues.

## Patterns to Find

### Missing Documentation
- Public APIs without JSDoc/TSDoc
- Complex functions without explanation
- Non-obvious return values undocumented
- Side effects not mentioned
- Required vs optional parameters unclear

### Outdated Documentation
- Comments that don't match code behavior
- TODO/FIXME comments that are stale
- README examples that don't work
- Changelog not updated with changes
- API docs referencing removed endpoints

### Documentation Quality
- Comments explaining "what" instead of "why"
- Overly verbose comments on obvious code
- Missing examples in complex docs
- No error documentation
- Missing deprecation notices

## Examples

```typescript
// BAD - no documentation on public API
export function calculateShipping(items, destination, options) {
  // complex logic
}

// GOOD - documented public API
/**
 * Calculate shipping cost for an order.
 *
 * @param items - Array of items with weight and dimensions
 * @param destination - Shipping address with country code
 * @param options - Optional shipping preferences
 * @param options.express - Use express shipping (default: false)
 * @param options.insurance - Add insurance (default: false)
 * @returns Shipping cost in cents, or null if destination unsupported
 * @throws {ValidationError} If items array is empty
 *
 * @example
 * const cost = calculateShipping(
 *   [{ weight: 500, dimensions: { l: 10, w: 10, h: 5 } }],
 *   { country: 'US', zip: '10001' }
 * )
 */
export function calculateShipping(items, destination, options) {
```

```typescript
// BAD - outdated comment
// Returns user's full name
function getUserName(user) {
  return user.email  // comment lies!
}

// GOOD - accurate or no comment
function getUserEmail(user) {
  return user.email
}
```

```typescript
// BAD - explains "what" (obvious from code)
// Increment counter by 1
counter++

// GOOD - explains "why" (not obvious)
// Offset by 1 because API uses 1-based pagination
counter++
```

```typescript
// BAD - stale TODO
// TODO: Add validation (added 2019)
function saveUser(data) {
  // 5 years later, still no validation
}

// GOOD - actionable TODO with context
// TODO(#1234): Add email validation before Q2 launch
function saveUser(data) {
```

```typescript
// BAD - missing deprecation notice
export function oldMethod() {
  return newMethod()  // silently redirects
}

// GOOD - clear deprecation
/**
 * @deprecated Use `newMethod` instead. Will be removed in v3.0.
 */
export function oldMethod() {
  console.warn('oldMethod is deprecated, use newMethod')
  return newMethod()
}
```
