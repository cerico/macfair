# Timezone Handling

Check for date/timezone bugs.

## Patterns to Find

- Storing local time instead of UTC
- Comparing dates without timezone consideration
- Using `new Date()` for user-facing dates without timezone
- Using `format` from date-fns instead of `formatInTimeZone`
- Hardcoded timezone offsets
- Missing timezone in date serialization
- Displaying dates without converting to user's timezone
- Date arithmetic across DST boundaries

## Examples

```typescript
// BAD - storing local time
const createdAt = new Date().toISOString()  // OK, but...
const displayDate = format(createdAt, 'PPP')  // displays in server timezone

// GOOD - use formatInTimeZone
import { formatInTimeZone } from 'date-fns-tz'
const displayDate = formatInTimeZone(
  createdAt,
  facilityTimezone,
  'PPP'
)
```

```typescript
// BAD - comparing dates without timezone
const isToday = format(date, 'yyyy-MM-dd') === format(new Date(), 'yyyy-MM-dd')

// GOOD - compare in the same timezone
import { formatInTimeZone } from 'date-fns-tz'
const isToday =
  formatInTimeZone(date, tz, 'yyyy-MM-dd') ===
  formatInTimeZone(new Date(), tz, 'yyyy-MM-dd')
```

```typescript
// BAD - date input without timezone context
<input
  type="date"
  value={format(date, 'yyyy-MM-dd')}  // which timezone?
  onChange={e => setDate(new Date(e.target.value))}  // parsed as local
/>

// GOOD - explicit timezone handling
import { zonedTimeToUtc, utcToZonedTime } from 'date-fns-tz'

const zonedDate = utcToZonedTime(date, facilityTimezone)
<input
  type="date"
  value={format(zonedDate, 'yyyy-MM-dd')}
  onChange={e => {
    const localDate = parse(e.target.value, 'yyyy-MM-dd', new Date())
    setDate(zonedTimeToUtc(localDate, facilityTimezone))
  }}
/>
```

```typescript
// BAD - hardcoded offset
const utcDate = new Date(localDate.getTime() - 5 * 60 * 60 * 1000)  // assumes EST

// GOOD - use proper timezone library
import { zonedTimeToUtc } from 'date-fns-tz'
const utcDate = zonedTimeToUtc(localDate, 'America/New_York')
```

```typescript
// BAD - "add 24 hours" for "next day" (breaks at DST)
const tomorrow = new Date(date.getTime() + 24 * 60 * 60 * 1000)

// GOOD - use date-fns which handles DST
import { addDays } from 'date-fns'
const tomorrow = addDays(date, 1)
```

```typescript
// BAD - displaying UTC to user
<span>{invoice.createdAt}</span>  // shows "2024-01-15T14:30:00.000Z"

// GOOD - format for display
<span>{formatShortOrdinal(invoice.createdAt)}</span>  // shows "Jan 15th"
```
