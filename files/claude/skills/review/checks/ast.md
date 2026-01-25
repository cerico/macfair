# AST-based Analysis

Advanced static analysis patterns that benefit from understanding code structure.

## Patterns to Find

### Dead Code
- Unreachable code after return/throw/break
- Unused variables, functions, or imports
- Conditions that are always true/false
- Unused function parameters
- Code after unconditional loops

### Cyclomatic Complexity
- Functions with many branches (if/else/switch)
- Deeply nested conditionals (>3 levels)
- Functions longer than ~50 lines
- Many early returns making flow hard to follow

### Duplicate Code
- Copy-pasted logic that could be extracted
- Similar functions that differ only slightly
- Repeated patterns across files
- Magic numbers/strings used in multiple places

### Dependency Graph
- Circular dependencies between modules
- Tightly coupled modules that should be decoupled
- God modules that everything imports
- Orphan modules that nothing uses

## Examples

```typescript
// Dead code - unreachable
function process(x) {
  if (x < 0) {
    return 'negative'
  }
  return 'non-negative'
  console.log('done')  // unreachable
}
```

```typescript
// Dead code - always true condition
const DEBUG = true
if (DEBUG) {
  // this branch always runs
} else {
  // dead code
}
```

```typescript
// High cyclomatic complexity - refactor needed
function processOrder(order) {
  if (order.type === 'standard') {
    if (order.priority === 'high') {
      if (order.customer.isVip) {
        // deeply nested - hard to follow
      }
    }
  }
}

// Better - early returns or separate functions
function processOrder(order) {
  if (order.type !== 'standard') return handleSpecialOrder(order)
  if (order.priority !== 'high') return handleNormalPriority(order)
  if (order.customer.isVip) return handleVipOrder(order)
  return handleStandardOrder(order)
}
```

```typescript
// Duplicate code - extract to function
// File A
const total = items.reduce((sum, item) => sum + item.price * item.qty, 0)

// File B
const orderTotal = products.reduce((sum, p) => sum + p.price * p.qty, 0)

// Better - shared utility
function calculateTotal(items: {price: number, qty: number}[]) {
  return items.reduce((sum, item) => sum + item.price * item.qty, 0)
}
```

```typescript
// Circular dependency
// userService.ts
import { orderService } from './orderService'

// orderService.ts
import { userService } from './userService'  // circular!

// Fix: extract shared logic to third module or use dependency injection
```
