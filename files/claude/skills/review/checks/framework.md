# Framework-specific Checks

Next.js, tRPC, Prisma, and React Server Component patterns.

## Next.js App Router

### Patterns to Find
- Using `'use client'` unnecessarily (prefer server components)
- Fetching data in client components when server component would work
- Missing `loading.tsx` or `error.tsx` for routes
- Using `useEffect` for data that could be fetched server-side
- Importing server-only code in client components
- Missing metadata exports for SEO

```typescript
// BAD - client component for static data
'use client'
export default function ProductPage({ id }) {
  const [product, setProduct] = useState(null)
  useEffect(() => {
    fetch(`/api/products/${id}`).then(r => r.json()).then(setProduct)
  }, [id])
}

// GOOD - server component
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}
```

## tRPC Security

### Patterns to Find
- Missing input validation on procedures
- Exposing sensitive data in responses
- Missing auth middleware on protected routes
- N+1 queries in resolvers

```typescript
// BAD - no input validation
export const getUser = publicProcedure
  .query(({ input }) => {
    return db.user.findUnique({ where: { id: input.id } })
  })

// GOOD - validated input
export const getUser = publicProcedure
  .input(z.object({ id: z.string().uuid() }))
  .query(({ input }) => {
    return db.user.findUnique({
      where: { id: input.id },
      select: { id: true, name: true }  // explicit fields
    })
  })
```

## Prisma Optimization

### Patterns to Find
- Missing `select` returning entire models
- N+1 queries (queries in loops)
- Missing indexes on frequently queried fields
- Not using `include` for related data
- Raw queries without parameterization
- Using `$transaction` array form with conditional nulls

```typescript
// BAD - N+1 query
const users = await prisma.user.findMany()
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { authorId: user.id } })
}

// GOOD - single query with include
const users = await prisma.user.findMany({
  include: { posts: true }
})
```

```typescript
// BAD - $transaction with conditional null (type/runtime issues)
await prisma.$transaction([
  prisma.event.create({ data: { id } }),
  condition ? prisma.item.create({ data }) : null
].filter(Boolean))

// GOOD - use callback form for conditional operations
await prisma.$transaction(async (tx) => {
  await tx.event.create({ data: { id } })
  if (condition) {
    await tx.item.create({ data })
  }
})
```

## React Server Components

### Patterns to Find
- Passing non-serializable props from server to client components
- Using hooks in server components
- Large client component trees that could be partially server-rendered
- Client components that don't need interactivity

```typescript
// BAD - function prop from server to client
// ServerComponent.tsx
import ClientComponent from './ClientComponent'
export default function Server() {
  const handleClick = () => console.log('clicked')  // can't serialize!
  return <ClientComponent onClick={handleClick} />
}

// GOOD - pass serializable data, define handler in client
// ServerComponent.tsx
export default function Server() {
  return <ClientComponent itemId="123" />
}
// ClientComponent.tsx
'use client'
export default function Client({ itemId }) {
  const handleClick = () => console.log('clicked', itemId)
  return <button onClick={handleClick}>Click</button>
}
```
