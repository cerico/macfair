---
name: test-review
description: Review existing tests for completeness, quality issues, and common mistakes
---

# Test Review

Review tests for a feature to catch coverage gaps and quality issues before PR.

## Instructions

1. Identify the feature being tested (from user or recent git changes)
2. Find related source files: validations, tRPC routers, components, pages
3. Find related test files: vitest and playwright
4. Check coverage gaps - what's missing?
5. Check test quality - are assertions meaningful?
6. Check for common mistakes
7. Report findings with file:line references

## Coverage Gaps

### Validation Schemas
- [ ] Happy path with valid input
- [ ] Each required field missing
- [ ] Invalid formats (email, date, etc.)
- [ ] Edge cases (empty string, zero, negative numbers)
- [ ] Type coercion if applicable

### tRPC Procedures
- [ ] Success case returns expected shape
- [ ] Error case (not found, unauthorized)
- [ ] Input validation rejects bad data
- [ ] Side effects happen (database updated, email sent)

### React Components
- [ ] Renders without crashing
- [ ] Displays data correctly
- [ ] Loading state
- [ ] Error state
- [ ] User interactions (click, submit, type)
- [ ] Accessibility (keyboard nav, screen reader)

### E2E (Playwright)
- [ ] Happy path flow start to finish
- [ ] Form validation errors shown to user
- [ ] Error recovery (retry, go back)
- [ ] Empty states

## Test Quality

### Meaningful Assertions
```typescript
// Bad - just checks truthy
expect(result).toBeTruthy()

// Good - checks specific value
expect(result.id).toBe('123')
expect(result.items).toHaveLength(3)
```

### Independent Tests
- No shared mutable state between tests
- Each test sets up its own data
- Order of tests doesn't matter

### Realistic Mocks
```typescript
// Bad - mock returns nothing useful
const mockFetch = jest.fn()

// Good - mock returns realistic data
const mockFetch = jest.fn().mockResolvedValue({
  id: '123',
  name: 'Test User',
  createdAt: new Date(),
})
```

### Error Testing
```typescript
// Bad - just checks it throws
expect(() => fn()).toThrow()

// Good - checks specific error
expect(() => fn()).toThrow('User not found')
expect(() => fn()).toThrow(NotFoundError)
```

## Common Mistakes

### General
- [ ] No `.only` or `.skip` left in code
- [ ] No `console.log` in tests
- [ ] No hardcoded IDs that won't exist in CI
- [ ] No time-dependent tests without mocking `Date.now()`

### Async Issues
```typescript
// Bad - no await, test passes before async completes
it('creates user', () => {
  createUser({ name: 'Test' })
  expect(db.users).toHaveLength(1)
})

// Good - awaits async operation
it('creates user', async () => {
  await createUser({ name: 'Test' })
  expect(db.users).toHaveLength(1)
})
```

### Playwright-Specific
- [ ] Uses semantic locators (`getByRole`, `getByLabel`) not CSS selectors
- [ ] No `page.waitForTimeout()` - use `waitForResponse`, `waitForSelector`, or `expect().toBeVisible()`
- [ ] Tests don't depend on previous test's state
- [ ] Assertions check visible outcomes, not implementation

```typescript
// Bad - fragile selector, arbitrary timeout
await page.click('.btn-submit')
await page.waitForTimeout(1000)

// Good - semantic locator, waits for outcome
await page.getByRole('button', { name: 'Submit' }).click()
await expect(page.getByText('Saved successfully')).toBeVisible()
```

### Vitest-Specific
- [ ] Mocks are reset between tests (`vi.clearAllMocks()` in `beforeEach`)
- [ ] No network calls without MSW or manual mocking
- [ ] `describe` blocks group related tests logically

## Output Format

```
## Test Review: [feature]

### Coverage Gaps
- validations/booking.ts has no tests for `updateBookingSchema`
- No E2E test for delete flow
- Missing error state test for BookingForm component

### Quality Issues
- tests/vitest/booking.test.ts:23 - assertion just checks truthy, verify specific value
- tests/vitest/booking.test.ts:45 - mock returns empty object, use realistic data

### Common Mistakes
- tests/playwright/booking.spec.ts:12 - uses `waitForTimeout(2000)`, use `waitForResponse` or assertion
- tests/vitest/booking.test.ts:67 - `.only` left in code

### Passed
- Validation schema has happy path + required field tests
- tRPC procedures test success and not-found cases
- No hardcoded IDs
- Semantic locators used throughout
```

## Notes

- Focus on changed files first, but check related test files too
- Not every gap needs fixing - use judgment on risk vs effort
- Flag `.only` and `.skip` as blockers - these break CI
