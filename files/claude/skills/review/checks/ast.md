# AST-based Analysis

Advanced static analysis patterns that benefit from understanding code structure.

## Patterns to Find

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
