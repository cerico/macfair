# Idempotency

Check for operations that should be idempotent but aren't.

## Patterns to Find

- Non-idempotent mutations (duplicate submissions cause duplicate records)
- Missing idempotency keys for payment/order operations
- Retry logic without idempotency protection
- Form submissions without duplicate prevention
- Webhook handlers that aren't idempotent
- Database operations that should use upsert
- Counter increments that should be "set to value"

## Why This Matters

Network requests can fail mid-flight and get retried. If the operation isn't idempotent, retries cause duplicate effects (double charges, duplicate orders, etc.).

## Examples

```typescript
// BAD - duplicate order creation
async function createOrder(cart) {
  return await prisma.order.create({
    data: { items: cart.items, total: cart.total }
  })
  // If network fails after create but before response, retry creates duplicate
}

// GOOD - idempotency key
async function createOrder(cart, idempotencyKey) {
  const existing = await prisma.order.findUnique({
    where: { idempotencyKey }
  })
  if (existing) return existing

  return await prisma.order.create({
    data: {
      idempotencyKey,
      items: cart.items,
      total: cart.total
    }
  })
}
```

```typescript
// BAD - webhook handler not idempotent
app.post('/webhooks/stripe', async (req, res) => {
  const { eventId, type, data } = req.body

  if (type === 'payment.success') {
    await prisma.payment.create({ data })  // duplicate webhooks = duplicate records
  }
})

// GOOD - track processed events
app.post('/webhooks/stripe', async (req, res) => {
  const { eventId, type, data } = req.body

  const processed = await prisma.processedEvent.findUnique({
    where: { eventId }
  })
  if (processed) return res.json({ ok: true })  // already handled

  await prisma.$transaction(async (tx) => {
    await tx.processedEvent.create({ data: { eventId } })
    if (type === 'payment.success') {
      await tx.payment.create({ data })
    }
  })
})
```

```typescript
// BAD - increment can double-count on retry
async function recordView(articleId) {
  await prisma.article.update({
    where: { id: articleId },
    data: { views: { increment: 1 } }
  })
}

// GOOD - use unique constraint to prevent duplicates
async function recordView(articleId, visitorId) {
  await prisma.articleView.upsert({
    where: {
      articleId_visitorId: { articleId, visitorId }
    },
    create: { articleId, visitorId },
    update: {}  // no-op if exists
  })
}
```

```typescript
// BAD - form allows double-submit
const handleSubmit = async () => {
  await createUser(formData)
}

// GOOD - prevent double submission
const { mutate, isPending } = useMutation(createUser)

const handleSubmit = () => {
  if (!isPending) mutate(formData)
}

<button disabled={isPending}>
  {isPending ? 'Creating...' : 'Create User'}
</button>
```

```typescript
// BAD - using insert when upsert is appropriate
async function saveUserPreference(userId, key, value) {
  await prisma.preference.create({
    data: { userId, key, value }
  })
  // Fails if preference already exists
}

// GOOD - upsert for set-like operations
async function saveUserPreference(userId, key, value) {
  await prisma.preference.upsert({
    where: { userId_key: { userId, key } },
    create: { userId, key, value },
    update: { value }
  })
}
```
