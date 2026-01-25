# Concurrency & Race Conditions

Check for race conditions and concurrent access issues.

## Patterns to Find

- Optimistic updates without conflict detection
- Two users editing same resource with last-write-wins
- Stale data overwrites (no version/timestamp check)
- Missing database transactions for multi-step operations
- Read-modify-write without locking
- Parallel requests that depend on shared state
- Missing request deduplication for rapid clicks

## Examples

```typescript
// BAD - last write wins, no conflict detection
async function updateInvoice(id, data) {
  await prisma.invoice.update({
    where: { id },
    data
  })
}

// GOOD - optimistic locking with version
async function updateInvoice(id, data, expectedVersion) {
  const result = await prisma.invoice.updateMany({
    where: { id, version: expectedVersion },
    data: { ...data, version: { increment: 1 } }
  })
  if (result.count === 0) {
    throw new ConcurrentModificationError('Invoice was modified by another user')
  }
}
```

```typescript
// BAD - read-modify-write without transaction
async function incrementCounter(id) {
  const record = await prisma.counter.findUnique({ where: { id } })
  await prisma.counter.update({
    where: { id },
    data: { value: record.value + 1 }  // race condition!
  })
}

// GOOD - atomic update
async function incrementCounter(id) {
  await prisma.counter.update({
    where: { id },
    data: { value: { increment: 1 } }
  })
}
```

```typescript
// BAD - multi-step operation without transaction
async function transferFunds(fromId, toId, amount) {
  await prisma.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } }
  })
  // If this fails, money disappears!
  await prisma.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } }
  })
}

// GOOD - use transaction
async function transferFunds(fromId, toId, amount) {
  await prisma.$transaction([
    prisma.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    }),
    prisma.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    })
  ])
}
```

```typescript
// BAD - rapid clicks cause duplicate submissions
<button onClick={() => createOrder(cart)}>
  Place Order
</button>

// GOOD - disable during submission or debounce
const { mutate, isPending } = useMutation(createOrder)
<button onClick={() => mutate(cart)} disabled={isPending}>
  {isPending ? 'Placing...' : 'Place Order'}
</button>
```

```typescript
// BAD - stale closure in async operation
function SearchComponent() {
  const [query, setQuery] = useState('')

  const search = async () => {
    const results = await fetchResults(query)  // uses stale query
    setResults(results)
  }
}

// GOOD - abort stale requests
function SearchComponent() {
  const [query, setQuery] = useState('')

  useEffect(() => {
    const controller = new AbortController()
    fetchResults(query, { signal: controller.signal })
      .then(setResults)
      .catch(e => { if (e.name !== 'AbortError') throw e })
    return () => controller.abort()
  }, [query])
}
```
