# Performance Issues

Check for common performance problems.

## Patterns to Find

- Large bundle sizes (importing entire libraries)
- Unnecessary re-renders in React components
- Expensive operations in render functions
- Not virtualizing long lists
- Loading all data upfront instead of lazy loading
- Not implementing proper caching
- Blocking the main thread with heavy computations
- Inline object/function creation causing re-renders

## Examples

```typescript
// BAD - importing entire library
import _ from 'lodash'
const result = _.debounce(fn, 100)

// GOOD - tree-shakeable import
import debounce from 'lodash/debounce'
const result = debounce(fn, 100)
```

```typescript
// BAD - expensive operation in render
function UserList({ users }) {
  const sortedUsers = users.sort((a, b) => a.name.localeCompare(b.name))
  return <div>{sortedUsers.map(...)}</div>
}

// GOOD - memoized
function UserList({ users }) {
  const sortedUsers = useMemo(
    () => [...users].sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
  return <div>{sortedUsers.map(...)}</div>
}
```

```typescript
// BAD - new objects/functions every render
<ChildComponent
  style={{ marginTop: 10 }}
  onClick={() => doSomething()}
/>

// GOOD - stable references
const style = useMemo(() => ({ marginTop: 10 }), [])
const handleClick = useCallback(() => doSomething(), [])

<ChildComponent style={style} onClick={handleClick} />
```

```typescript
// BAD - rendering 10,000 items
function ItemList({ items }) {
  return (
    <div>
      {items.map(item => <Item key={item.id} item={item} />)}
    </div>
  )
}

// GOOD - virtualized list
import { FixedSizeList } from 'react-window'

function ItemList({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
    >
      {({ index, style }) => (
        <div style={style}>
          <Item item={items[index]} />
        </div>
      )}
    </FixedSizeList>
  )
}
```

```typescript
// BAD - loading everything at once
import HeavyComponent from './HeavyComponent'

// GOOD - lazy loading
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />
})
```
