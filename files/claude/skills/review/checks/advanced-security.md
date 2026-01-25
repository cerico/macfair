# Advanced Security

Security checks beyond the basics - prototype pollution, ReDoS, timing attacks, deserialization.

## Patterns to Find

### Prototype Pollution
- Object merging without protection (`Object.assign`, spread on user input)
- Deep merge utilities on untrusted data
- Setting properties via bracket notation with user-controlled keys

### ReDoS (Regular Expression Denial of Service)
- Regex with nested quantifiers `(a+)+`
- Regex with overlapping alternations `(a|a)+`
- Unbounded repetition on complex groups
- User input directly in regex without escaping

### Timing Attacks
- String comparison for secrets using `===` (not constant-time)
- Early return on password/token mismatch
- Observable timing differences in auth checks

### Insecure Deserialization
- `eval()` on user data
- `JSON.parse()` without schema validation
- Deserializing untrusted YAML/XML
- Dynamic `require()` or `import()` with user input

## Examples

```typescript
// BAD - prototype pollution via merge
function merge(target, source) {
  for (const key in source) {
    target[key] = source[key]  // __proto__ can be set!
  }
}

// Attacker sends: {"__proto__": {"isAdmin": true}}

// GOOD - protect against prototype pollution
function safeMerge(target, source) {
  for (const key in source) {
    if (key === '__proto__' || key === 'constructor') continue
    if (!Object.prototype.hasOwnProperty.call(source, key)) continue
    target[key] = source[key]
  }
}
```

```typescript
// BAD - ReDoS vulnerable regex
const emailRegex = /^([a-zA-Z0-9]+)+@/  // nested quantifier

// Input "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!" causes catastrophic backtracking

// GOOD - linear time regex
const emailRegex = /^[a-zA-Z0-9]+@/
```

```typescript
// BAD - timing attack on token comparison
function validateToken(provided, expected) {
  return provided === expected  // fast fail reveals length
}

// GOOD - constant-time comparison
import { timingSafeEqual } from 'crypto'
function validateToken(provided, expected) {
  if (provided.length !== expected.length) {
    return timingSafeEqual(Buffer.from(expected), Buffer.from(expected))
  }
  return timingSafeEqual(Buffer.from(provided), Buffer.from(expected))
}
```

```typescript
// BAD - eval on user input
const result = eval(userInput)

// BAD - dynamic require
const module = require(userProvidedPath)

// BAD - unvalidated JSON
const data = JSON.parse(userInput)
processOrder(data)  // trusts structure

// GOOD - validate with schema
import { z } from 'zod'
const OrderSchema = z.object({
  id: z.string(),
  amount: z.number().positive()
})
const data = OrderSchema.parse(JSON.parse(userInput))
```

```typescript
// BAD - user input in regex without escaping
const pattern = new RegExp(userInput)

// GOOD - escape special chars
function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}
const pattern = new RegExp(escapeRegex(userInput))
```
