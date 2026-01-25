# React Rules of Hooks

Check for violations of the Rules of Hooks.

## Patterns to Find

- Calling hooks inside loops, conditions, or nested functions
- Calling hooks after early returns
- Calling hooks in non-React functions
- Using hooks in class components
- Conditional hook calls (useState, useEffect, etc.)
- Hooks called in event handlers or other callbacks
- Custom hooks not starting with "use"

## Why This Matters

React relies on the order of hook calls being consistent between renders. Conditional or dynamic hook calls break this invariant and cause bugs.

## Examples

```typescript
// BAD - conditional hook call
function MyComponent({ shouldFetch }) {
  if (shouldFetch) {
    const data = useQuery()  // hook in condition
  }
  return <div>...</div>
}

// GOOD - hook called unconditionally
function MyComponent({ shouldFetch }) {
  const data = useQuery({ enabled: shouldFetch })
  return <div>...</div>
}
```

```typescript
// BAD - hook after early return
function MyComponent({ user }) {
  if (!user) return null
  const [count, setCount] = useState(0)  // hook after return
  return <div>{count}</div>
}

// GOOD - hooks before conditional return
function MyComponent({ user }) {
  const [count, setCount] = useState(0)
  if (!user) return null
  return <div>{count}</div>
}
```

```typescript
// BAD - hook in event handler
function MyComponent() {
  const handleClick = () => {
    const [clicked, setClicked] = useState(false)  // hook in callback
  }
  return <button onClick={handleClick}>Click</button>
}

// GOOD - hook at component level
function MyComponent() {
  const [clicked, setClicked] = useState(false)
  const handleClick = () => setClicked(true)
  return <button onClick={handleClick}>Click</button>
}
```

```typescript
// BAD - hook in loop
function MyComponent({ items }) {
  items.forEach(item => {
    const [value, setValue] = useState(item)  // hook in loop
  })
}

// GOOD - lift state up or use a child component
function MyComponent({ items }) {
  return items.map(item => <ItemEditor key={item.id} item={item} />)
}

function ItemEditor({ item }) {
  const [value, setValue] = useState(item)
  // ...
}
```
