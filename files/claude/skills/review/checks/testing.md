# Testing Coverage Analysis

Identify gaps in test coverage and suggest improvements.

## Patterns to Find

### Untested Code Paths
- New functions without corresponding tests
- Error handling branches not covered
- Edge cases (null, empty, boundary values) not tested
- Async error paths not tested
- Feature flags/conditionals not fully tested

### Missing Test Cases
- Happy path only, no error cases
- No boundary value testing
- No integration tests for critical flows
- No tests for race conditions
- Missing regression tests for bugs

### Test Quality Issues
- Tests that don't assert anything meaningful
- Tests that mock too much (testing mocks, not code)
- Flaky tests (timing-dependent, order-dependent)
- Tests that duplicate each other
- Missing cleanup in tests

## Examples

```typescript
// CODE - multiple paths to test
async function processPayment(amount, userId) {
  if (amount <= 0) throw new Error('Invalid amount')
  if (amount > 10000) throw new Error('Exceeds limit')

  const user = await getUser(userId)
  if (!user) throw new Error('User not found')
  if (user.blocked) throw new Error('User blocked')

  return await chargeCard(user.cardId, amount)
}

// BAD - only tests happy path
test('processes payment', async () => {
  const result = await processPayment(100, 'user-1')
  expect(result.success).toBe(true)
})

// GOOD - tests all paths
describe('processPayment', () => {
  test('succeeds with valid amount and user', async () => {...})
  test('rejects zero amount', async () => {...})
  test('rejects negative amount', async () => {...})
  test('rejects amount over limit', async () => {...})
  test('rejects unknown user', async () => {...})
  test('rejects blocked user', async () => {...})
  test('handles card charge failure', async () => {...})
})
```

```typescript
// BAD - test mocks everything, tests nothing
test('saves user', async () => {
  const mockDb = { save: jest.fn() }
  await saveUser(mockDb, userData)
  expect(mockDb.save).toHaveBeenCalled()  // only verifies mock was called
})

// GOOD - test actual behavior
test('saves user with hashed password', async () => {
  await saveUser(testDb, { email: 'a@b.com', password: 'secret' })
  const saved = await testDb.users.findOne({ email: 'a@b.com' })
  expect(saved.password).not.toBe('secret')  // verifies hashing
  expect(await bcrypt.compare('secret', saved.password)).toBe(true)
})
```

```typescript
// BAD - no assertion
test('renders component', () => {
  render(<MyComponent />)
  // no expect!
})

// GOOD - meaningful assertion
test('renders component with user name', () => {
  render(<MyComponent user={{ name: 'Alice' }} />)
  expect(screen.getByText('Alice')).toBeInTheDocument()
})
```

```typescript
// BAD - flaky timing test
test('debounces input', async () => {
  fireEvent.change(input, { target: { value: 'test' } })
  await new Promise(r => setTimeout(r, 500))
  expect(onSearch).toHaveBeenCalledTimes(1)
})

// GOOD - use fake timers
test('debounces input', async () => {
  jest.useFakeTimers()
  fireEvent.change(input, { target: { value: 'test' } })
  jest.advanceTimersByTime(500)
  expect(onSearch).toHaveBeenCalledTimes(1)
})
```
