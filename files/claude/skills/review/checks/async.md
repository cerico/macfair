# Async/Await Patterns

Check for async/await patterns that could be improved.

## Patterns to Find

- Using await inside loops when Promise.all could be used
- Not handling promises in parallel when they don't depend on each other
- Using .then() mixed with async/await in the same function
- Forgetting to await async functions (especially in event handlers)
- Using async functions where they're not needed (no await inside)
- Missing error handling for rejected promises
- Not using Promise.allSettled when partial failures are acceptable

## Examples

```typescript
// BAD - sequential when could be parallel
const user = await getUser(id)
const posts = await getPosts(id)

// GOOD - parallel execution
const [user, posts] = await Promise.all([getUser(id), getPosts(id)])
```

```typescript
// BAD - await in loop
for (const id of ids) {
  results.push(await fetchData(id))
}

// GOOD - parallel with Promise.all
const results = await Promise.all(ids.map(id => fetchData(id)))
```

```typescript
// BAD - mixing .then() with async/await
async function loadData() {
  const user = await getUser()
  getPosts(user.id).then(posts => {
    setPosts(posts)
  })
}

// GOOD - consistent async/await
async function loadData() {
  const user = await getUser()
  const posts = await getPosts(user.id)
  setPosts(posts)
}
```

```typescript
// BAD - forgetting await in event handler
const handleClick = async () => {
  saveData()  // not awaited, errors silently swallowed
  showSuccess()
}

// GOOD - await and handle errors
const handleClick = async () => {
  try {
    await saveData()
    showSuccess()
  } catch (error) {
    showError(error)
  }
}
```

```typescript
// BAD - async without await
async function getName() {
  return 'John'  // no await needed
}

// GOOD - just return directly
function getName() {
  return 'John'
}
```
