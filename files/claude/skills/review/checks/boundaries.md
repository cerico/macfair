# Error Boundaries & Fault Tolerance

Check for missing error boundaries and graceful degradation.

## Patterns to Find

- React components without error boundaries for data-dependent UI
- Unhandled promise rejections in useEffect
- No fallback UI for failed data fetches
- Missing Suspense boundaries for lazy-loaded components
- Global error handlers not configured
- No retry logic for transient failures
- Single point of failure patterns

## Examples

```typescript
// BAD - no error boundary, crashes entire app
function Dashboard() {
  return (
    <div>
      <UserStats />    {/* if this throws, whole page crashes */}
      <RecentOrders />
      <Analytics />
    </div>
  )
}

// GOOD - isolated error boundaries
function Dashboard() {
  return (
    <div>
      <ErrorBoundary fallback={<StatsError />}>
        <UserStats />
      </ErrorBoundary>
      <ErrorBoundary fallback={<OrdersError />}>
        <RecentOrders />
      </ErrorBoundary>
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Analytics />
      </ErrorBoundary>
    </div>
  )
}
```

```typescript
// BAD - unhandled rejection in useEffect
useEffect(() => {
  fetchData().then(setData)  // rejected promise goes unhandled
}, [])

// GOOD - handle errors
useEffect(() => {
  fetchData()
    .then(setData)
    .catch(error => {
      setError(error)
      logger.error('Failed to fetch data', error)
    })
}, [])

// BETTER - use React Query which handles this
const { data, error } = useQuery(['data'], fetchData)
```

```typescript
// BAD - no suspense for lazy component
const HeavyChart = lazy(() => import('./HeavyChart'))

function Dashboard() {
  return <HeavyChart />  // will crash without Suspense
}

// GOOD - suspense with fallback
function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart />
    </Suspense>
  )
}
```

```typescript
// BAD - no retry for transient failures
async function fetchWithRetry(url) {
  return fetch(url)  // fails permanently on network blip
}

// GOOD - retry with backoff
async function fetchWithRetry(url, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await fetch(url)
    } catch (error) {
      if (i === retries - 1) throw error
      await new Promise(r => setTimeout(r, 1000 * Math.pow(2, i)))
    }
  }
}
```

```typescript
// BAD - assuming external service is always available
function PaymentForm() {
  const processPayment = async () => {
    await stripeApi.charge(amount)  // what if Stripe is down?
    await markOrderPaid(orderId)
  }
}

// GOOD - graceful degradation
function PaymentForm() {
  const processPayment = async () => {
    try {
      await stripeApi.charge(amount)
      await markOrderPaid(orderId)
    } catch (error) {
      if (error instanceof ServiceUnavailableError) {
        await queuePaymentForRetry(orderId, amount)
        showMessage('Payment will be processed shortly')
      } else {
        throw error
      }
    }
  }
}
```
