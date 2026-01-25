# Error Handling

Check for error handling patterns that could be improved.

## Patterns to Find

- Generic try/catch blocks that swallow all errors
- Not using proper error types or custom error classes
- Missing error boundaries in React components
- Not handling specific error cases (network, validation, auth)
- console.log for errors instead of proper logging
- Not cleaning up resources in finally blocks
- Throwing generic Error() instead of specific error types
- Missing error handling in async operations
- Accessing properties/methods without validating data shape first

## Examples

```typescript
// BAD - swallowing errors
try {
  await api.call()
} catch (error) {
  console.log(error)
}

// GOOD - specific error handling
try {
  await api.call()
} catch (error) {
  if (error instanceof NetworkError) {
    logger.error('Network failure', { url: error.url })
    throw new ServiceUnavailableError()
  }
  if (error instanceof ValidationError) {
    return { success: false, errors: error.details }
  }
  throw error  // re-throw unexpected errors
}
```

```typescript
// BAD - generic error
throw new Error('Something went wrong')

// GOOD - specific error with context
throw new InvoiceNotFoundError(invoiceId)
```

```typescript
// BAD - no error boundary for data-dependent UI
function UserProfile({ userId }) {
  const { data } = useQuery(['user', userId])
  return <div>{data.user.name}</div>  // crashes if data is undefined
}

// GOOD - with error boundary
function UserProfile({ userId }) {
  return (
    <ErrorBoundary fallback={<ProfileError />}>
      <UserProfileContent userId={userId} />
    </ErrorBoundary>
  )
}
```

```typescript
// BAD - missing finally for cleanup
async function processFile(path) {
  const file = await openFile(path)
  await processContents(file)  // if this throws, file stays open
  await closeFile(file)
}

// GOOD - cleanup in finally
async function processFile(path) {
  const file = await openFile(path)
  try {
    await processContents(file)
  } finally {
    await closeFile(file)
  }
}
```

```typescript
// BAD - accessing property without validating shape
const data = JSON.parse(fileContent)
const items = data.items.filter(i => i.active)  // throws if items isn't array

// GOOD - validate shape before accessing
const data = JSON.parse(fileContent)
if (!data || !Array.isArray(data.items)) {
  return []
}
const items = data.items.filter(i => i.active)
```
