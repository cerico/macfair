# Security Audit

Check for common security vulnerabilities.

## Patterns to Find

- Hardcoded API keys, passwords, or secrets
- SQL injection vulnerabilities (string concatenation in queries)
- XSS vulnerabilities (dangerouslySetInnerHTML, unescaped user input)
- Insecure direct object references (user input as database IDs without auth check)
- Missing input validation and sanitization
- Exposing sensitive data in client-side code
- Weak authentication checks
- CORS misconfigurations (allowing all origins)
- Using HTTP instead of HTTPS for sensitive operations
- Missing rate limiting on sensitive endpoints
- JWT tokens stored in localStorage (XSS vulnerable)

## For Each Issue Found

- Explain the vulnerability and potential impact
- Show secure alternatives
- Suggest validation libraries or security middleware
- Recommend environment variables for secrets

## Examples

```typescript
// BAD - hardcoded secret
const JWT_SECRET = 'my-secret-key-123'

// GOOD - environment variable
const JWT_SECRET = process.env.JWT_SECRET
```

```typescript
// BAD - SQL injection risk
const query = `SELECT * FROM users WHERE id = ${userId}`

// GOOD - parameterized query
const query = 'SELECT * FROM users WHERE id = ?'
db.query(query, [userId])
```

```typescript
// BAD - XSS vulnerability
<div dangerouslySetInnerHTML={{__html: userInput}} />

// GOOD - escaped content or sanitize
<div>{userInput}</div>
// or use DOMPurify if HTML is required
<div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userInput)}} />
```

```typescript
// BAD - no authorization check
app.delete('/api/posts/:id', async (req, res) => {
  await deletePost(req.params.id)
})

// GOOD - proper authorization
app.delete('/api/posts/:id', authenticate, async (req, res) => {
  const post = await getPost(req.params.id)
  if (!post) {
    return res.status(404).json({ error: 'Not found' })
  }
  if (post.authorId !== req.user.id) {
    return res.status(403).json({ error: 'Unauthorized' })
  }
  await deletePost(req.params.id)
})
```

```typescript
// BAD - exposing sensitive data
const user = await getUser(id)
res.json(user)  // includes password hash

// GOOD - filtering sensitive data
const user = await getUser(id)
res.json({
  id: user.id,
  name: user.name,
  email: user.email
})
```
