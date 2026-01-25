# Memory Leaks

Check for memory leak patterns beyond just useEffect cleanup.

## Patterns to Find

- Event listeners on window/document not removed
- Growing arrays/objects that never get cleared
- Closures holding references to large objects
- Subscriptions not unsubscribed
- Timers not cleared
- Caches without eviction policy
- Refs holding onto unmounted component state
- WebSocket connections not closed

## Examples

```typescript
// BAD - window listener not removed
useEffect(() => {
  window.addEventListener('resize', handleResize)
  // missing cleanup
}, [])

// GOOD - cleanup listener
useEffect(() => {
  window.addEventListener('resize', handleResize)
  return () => window.removeEventListener('resize', handleResize)
}, [])
```

```typescript
// BAD - growing array without bounds
const history = []
function logAction(action) {
  history.push({ action, timestamp: Date.now() })
  // never cleared, grows forever
}

// GOOD - bounded history
const MAX_HISTORY = 1000
function logAction(action) {
  history.push({ action, timestamp: Date.now() })
  if (history.length > MAX_HISTORY) {
    history.shift()
  }
}
```

```typescript
// BAD - cache without eviction
const cache = new Map()
function getCached(key, fetcher) {
  if (!cache.has(key)) {
    cache.set(key, fetcher())
  }
  return cache.get(key)
  // cache grows forever
}

// GOOD - use LRU cache or WeakMap
import LRU from 'lru-cache'
const cache = new LRU({ max: 500 })

// or for object keys
const cache = new WeakMap()  // auto-GC when key is unreachable
```

```typescript
// BAD - closure captures large data
function createHandler(largeData) {
  return () => {
    console.log(largeData.length)  // keeps largeData in memory forever
  }
}
const handler = createHandler(loadGigabytesOfData())

// GOOD - only capture what's needed
function createHandler(dataLength) {
  return () => {
    console.log(dataLength)
  }
}
const data = loadGigabytesOfData()
const handler = createHandler(data.length)
// data can now be GC'd
```

```typescript
// BAD - WebSocket never closed
function ChatRoom({ roomId }) {
  useEffect(() => {
    const ws = new WebSocket(`wss://chat.example.com/${roomId}`)
    ws.onmessage = handleMessage
    // never closed
  }, [roomId])
}

// GOOD - close on cleanup
function ChatRoom({ roomId }) {
  useEffect(() => {
    const ws = new WebSocket(`wss://chat.example.com/${roomId}`)
    ws.onmessage = handleMessage
    return () => ws.close()
  }, [roomId])
}
```

```typescript
// BAD - updating state after unmount
function AsyncComponent() {
  const [data, setData] = useState(null)

  useEffect(() => {
    fetchData().then(setData)  // may fire after unmount
  }, [])
}

// GOOD - track mounted state
function AsyncComponent() {
  const [data, setData] = useState(null)

  useEffect(() => {
    let mounted = true
    fetchData().then(result => {
      if (mounted) setData(result)
    })
    return () => { mounted = false }
  }, [])
}

// BETTER - use AbortController or React Query
```
