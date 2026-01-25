# React Antipatterns

Check for common React antipatterns.

## Patterns to Find

- Mutating props directly
- Using array indexes as keys for dynamic lists
- Not cleaning up subscriptions or timers in useEffect
- Using useEffect for derived state that could be computed
- Using useEffect for data fetching (should use React Query/tRPC/server components)
- Props drilling instead of context or state management
- Massive components that should be split up
- Inline object/function creation in JSX causing unnecessary re-renders

## Examples

```typescript
// BAD - mutating props
function UserProfile({ user }) {
  user.lastSeen = new Date()  // mutating props
  return <div>{user.name}</div>
}

// GOOD - deriving without mutation
function UserProfile({ user }) {
  const userWithLastSeen = { ...user, lastSeen: new Date() }
  return <div>{userWithLastSeen.name}</div>
}
```

```typescript
// BAD - index as key for dynamic list
{items.map((item, index) => (
  <Item key={index} item={item} />
))}

// GOOD - stable unique key
{items.map(item => (
  <Item key={item.id} item={item} />
))}
```

```typescript
// BAD - not cleaning up
useEffect(() => {
  const interval = setInterval(() => fetchData(), 1000)
  // missing cleanup
}, [])

// GOOD - proper cleanup
useEffect(() => {
  const interval = setInterval(() => fetchData(), 1000)
  return () => clearInterval(interval)
}, [])
```

```typescript
// BAD - useEffect for derived state
function UserList({ users, searchTerm }) {
  const [filteredUsers, setFilteredUsers] = useState([])

  useEffect(() => {
    setFilteredUsers(users.filter(u => u.name.includes(searchTerm)))
  }, [users, searchTerm])
}

// GOOD - compute directly
function UserList({ users, searchTerm }) {
  const filteredUsers = useMemo(
    () => users.filter(u => u.name.includes(searchTerm)),
    [users, searchTerm]
  )
}
```

```typescript
// BAD - useEffect for data fetching
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])
}

// GOOD - use React Query or tRPC
function UserProfile({ userId }) {
  const { data: user } = useQuery(['user', userId], () => fetchUser(userId))
}
```
