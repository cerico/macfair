# State Mutation Patterns

Check for state mutation issues.

## Patterns to Find

- Directly mutating state objects or arrays
- Not using proper immutable update patterns
- Complex nested state updates that could use immer
- useState with objects that should be separate state variables
- Missing dependency arrays in useEffect/useMemo/useCallback
- Not memoizing expensive calculations or child components

## Examples

```typescript
// BAD - direct mutation
const [items, setItems] = useState([])
const addItem = (item) => {
  items.push(item)  // mutating state
  setItems(items)   // same reference, won't trigger re-render
}

// GOOD - immutable update
const addItem = (item) => {
  setItems(prev => [...prev, item])
}
```

```typescript
// BAD - nested mutation
const [user, setUser] = useState({ profile: { settings: { theme: 'light' } } })
user.profile.settings.theme = 'dark'
setUser(user)

// GOOD - immutable nested update
setUser(prev => ({
  ...prev,
  profile: {
    ...prev.profile,
    settings: {
      ...prev.profile.settings,
      theme: 'dark'
    }
  }
}))

// BETTER - use immer for complex nesting
import { produce } from 'immer'
setUser(produce(draft => {
  draft.profile.settings.theme = 'dark'
}))
```

```typescript
// BAD - missing dependencies
useEffect(() => {
  fetchData(userId)
}, [])  // userId missing from deps

// GOOD - proper dependencies
useEffect(() => {
  fetchData(userId)
}, [userId])
```

```typescript
// BAD - object state that should be split
const [formState, setFormState] = useState({
  name: '',
  email: '',
  isSubmitting: false,
  error: null
})

// GOOD - separate concerns
const [name, setName] = useState('')
const [email, setEmail] = useState('')
const { mutate, isPending, error } = useMutation(...)
```
