# N+1 Query Detection

Look for N+1 query problems across different data access patterns.

## Patterns to Find

- Database queries inside loops (Prisma, SQL, GraphQL resolvers)
- API calls in map/forEach functions
- Separate fetch calls for related data that could be batched
- GraphQL resolvers that don't use DataLoader
- React components making individual API calls in useEffect
- tRPC queries called in loops or map functions

## For Each Issue Found

- Identify the root query and the repeated nested queries
- Suggest batching solutions (include, select, joins, DataLoader)
- Recommend pagination for large datasets
- Propose caching strategies where appropriate

## Examples

```typescript
// BAD - N+1 with Prisma
const users = await prisma.user.findMany()
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { userId: user.id } })
  // 1 + N queries
}

// GOOD - single query with include
const users = await prisma.user.findMany({
  include: { posts: true }
  // 1 query total
})
```

```typescript
// BAD - API calls in component loop
function UserList({ userIds }) {
  return userIds.map(id => <UserCard key={id} userId={id} />)
}
function UserCard({ userId }) {
  const user = useQuery(['user', userId], () => fetchUser(userId))
  // N API calls
}

// GOOD - batch fetch in parent
function UserList({ userIds }) {
  const users = useQuery(['users', userIds], () => fetchUsers(userIds))
  return users.map(user => <UserCard key={user.id} user={user} />)
  // 1 API call
}
```

```typescript
// BAD - tRPC in loop
for (const id of userIds) {
  const user = await trpc.user.byId.query({ id })
  users.push(user)
}

// GOOD - tRPC batch query
const users = await trpc.user.byIds.query({ ids: userIds })
```
