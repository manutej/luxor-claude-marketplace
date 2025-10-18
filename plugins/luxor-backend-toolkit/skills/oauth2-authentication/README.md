# OAuth2 Authentication Skill

A comprehensive skill for implementing secure authentication and authorization using OAuth2 and OpenID Connect protocols. This skill provides complete guidance for building modern authentication systems across web, mobile, and API applications.

## Overview

OAuth2 is the industry-standard authorization framework that enables applications to obtain limited access to user accounts on HTTP services. Combined with OpenID Connect (OIDC), it provides both authentication and authorization capabilities for modern applications.

This skill covers everything from basic concepts to advanced implementation patterns, security best practices, and real-world examples.

## What You'll Learn

- **Authorization Flows**: Authorization Code, PKCE, Client Credentials, Device Flow
- **Token Management**: Access tokens, refresh tokens, ID tokens, storage, and rotation
- **Security**: PKCE implementation, state parameters, token validation, secure storage
- **OpenID Connect**: Identity layer, ID tokens, UserInfo endpoint, claims
- **Implementation**: Server-side, SPA, mobile apps, OAuth2 server development
- **Best Practices**: Security patterns, performance optimization, common pitfalls
- **Real-World Examples**: Social login, API authentication, multi-tenancy, SSO

## Quick Start Guide

### Choosing the Right OAuth2 Flow

**Authorization Code Flow (with PKCE)**
- ✅ Single Page Applications (React, Vue, Angular)
- ✅ Mobile applications (iOS, Android, React Native)
- ✅ Desktop applications
- ✅ Any public client that cannot store secrets

**Authorization Code Flow (without PKCE)**
- ✅ Traditional server-side web applications
- ✅ Applications with secure backend
- ✅ Can securely store client secrets

**Client Credentials Flow**
- ✅ Backend service-to-service authentication
- ✅ Microservices communication
- ✅ Cron jobs and scheduled tasks
- ✅ CI/CD pipelines
- ❌ No user context (machine-to-machine only)

**Device Authorization Flow**
- ✅ Smart TVs and streaming devices
- ✅ IoT devices without keyboards
- ✅ CLI tools and terminal applications
- ✅ Gaming consoles

**Avoid These Deprecated Flows:**
- ❌ Implicit Flow (use Authorization Code + PKCE instead)
- ❌ Resource Owner Password Credentials (security risk)

### Basic Implementation Examples

#### 1. Server-Side Web Application (Node.js + Express)

```javascript
// Simple OAuth2 login implementation
const express = require('express');
const session = require('express-session');
const crypto = require('crypto');

const app = express();

// OAuth2 Configuration
const config = {
  clientId: process.env.OAUTH2_CLIENT_ID,
  clientSecret: process.env.OAUTH2_CLIENT_SECRET,
  authorizationUrl: 'https://auth.example.com/oauth/authorize',
  tokenUrl: 'https://auth.example.com/oauth/token',
  redirectUri: 'https://yourapp.com/auth/callback',
  scopes: ['openid', 'profile', 'email'],
};

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true, // HTTPS only
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
  },
}));

// Login route - redirects to authorization server
app.get('/login', (req, res) => {
  const state = crypto.randomBytes(32).toString('hex');
  req.session.oauth2State = state;

  const authUrl = new URL(config.authorizationUrl);
  authUrl.searchParams.set('client_id', config.clientId);
  authUrl.searchParams.set('redirect_uri', config.redirectUri);
  authUrl.searchParams.set('response_type', 'code');
  authUrl.searchParams.set('scope', config.scopes.join(' '));
  authUrl.searchParams.set('state', state);

  res.redirect(authUrl.toString());
});

// Callback route - handles authorization code
app.get('/auth/callback', async (req, res) => {
  const { code, state } = req.query;

  // Validate state parameter (CSRF protection)
  if (state !== req.session.oauth2State) {
    return res.status(403).send('Invalid state parameter');
  }

  try {
    // Exchange authorization code for tokens
    const response = await fetch(config.tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: config.redirectUri,
        client_id: config.clientId,
        client_secret: config.clientSecret,
      }),
    });

    const tokens = await response.json();

    // Store tokens in session
    req.session.accessToken = tokens.access_token;
    req.session.refreshToken = tokens.refresh_token;

    res.redirect('/dashboard');
  } catch (error) {
    console.error('Authentication failed:', error);
    res.status(500).send('Authentication failed');
  }
});

// Protected route
app.get('/dashboard', (req, res) => {
  if (!req.session.accessToken) {
    return res.redirect('/login');
  }

  res.send('Welcome to your dashboard!');
});

app.listen(3000);
```

#### 2. Single Page Application with PKCE (React)

```javascript
// OAuth2 with PKCE for React applications
import { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

export function useAuth() {
  return useContext(AuthContext);
}

// PKCE helper functions
function generateRandomString(length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  const values = crypto.getRandomValues(new Uint8Array(length));
  return Array.from(values).map(v => chars[v % chars.length]).join('');
}

async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return base64UrlEncode(hash);
}

function base64UrlEncode(buffer) {
  const bytes = new Uint8Array(buffer);
  const binary = String.fromCharCode(...bytes);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [accessToken, setAccessToken] = useState(null);

  async function login() {
    // Generate PKCE parameters
    const codeVerifier = generateRandomString(64);
    const codeChallenge = await generateCodeChallenge(codeVerifier);
    const state = generateRandomString(32);

    // Store for callback
    sessionStorage.setItem('code_verifier', codeVerifier);
    sessionStorage.setItem('oauth2_state', state);

    // Build authorization URL
    const params = new URLSearchParams({
      client_id: 'your_client_id',
      redirect_uri: window.location.origin + '/callback',
      response_type: 'code',
      scope: 'openid profile email',
      state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    });

    // Redirect to authorization server
    window.location.href = `https://auth.example.com/oauth/authorize?${params}`;
  }

  async function handleCallback(code, state) {
    // Validate state
    const savedState = sessionStorage.getItem('oauth2_state');
    if (state !== savedState) {
      throw new Error('Invalid state parameter');
    }

    // Get code verifier
    const codeVerifier = sessionStorage.getItem('code_verifier');

    // Exchange code for tokens
    const response = await fetch('https://auth.example.com/oauth/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: window.location.origin + '/callback',
        client_id: 'your_client_id',
        code_verifier: codeVerifier,
      }),
    });

    const tokens = await response.json();
    setAccessToken(tokens.access_token);

    // Fetch user info
    const userResponse = await fetch('https://auth.example.com/oauth/userinfo', {
      headers: { Authorization: `Bearer ${tokens.access_token}` },
    });
    const userInfo = await userResponse.json();
    setUser(userInfo);

    // Clean up
    sessionStorage.removeItem('code_verifier');
    sessionStorage.removeItem('oauth2_state');
  }

  function logout() {
    setUser(null);
    setAccessToken(null);
    sessionStorage.clear();
  }

  return (
    <AuthContext.Provider value={{ user, accessToken, login, logout, handleCallback }}>
      {children}
    </AuthContext.Provider>
  );
}
```

#### 3. Client Credentials Flow (Backend Services)

```javascript
// Machine-to-machine authentication
class OAuth2ServiceClient {
  constructor(clientId, clientSecret, tokenUrl) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.tokenUrl = tokenUrl;
    this.accessToken = null;
    this.tokenExpiry = null;
  }

  async getAccessToken() {
    // Return cached token if still valid
    if (this.accessToken && Date.now() < this.tokenExpiry - 60000) {
      return this.accessToken;
    }

    // Request new token
    const response = await fetch(this.tokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: this.clientId,
        client_secret: this.clientSecret,
        scope: 'read:data write:data',
      }),
    });

    const data = await response.json();

    // Cache token
    this.accessToken = data.access_token;
    this.tokenExpiry = Date.now() + (data.expires_in * 1000);

    return this.accessToken;
  }

  async callApi(url, options = {}) {
    const token = await this.getAccessToken();

    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        Authorization: `Bearer ${token}`,
      },
    });
  }
}

// Usage
const client = new OAuth2ServiceClient(
  process.env.CLIENT_ID,
  process.env.CLIENT_SECRET,
  'https://auth.example.com/oauth/token'
);

// Make authenticated API calls
const response = await client.callApi('https://api.example.com/data');
const data = await response.json();
```

## Key Concepts

### OAuth2 Roles

1. **Resource Owner**: The user who owns the data
2. **Client**: Your application requesting access
3. **Authorization Server**: Issues access tokens after authenticating the user
4. **Resource Server**: Hosts the protected resources (your API)

### Token Types

**Access Token**
- Short-lived credential (15-60 minutes)
- Used to access protected resources
- Can be opaque or JWT format
- Sent in `Authorization: Bearer <token>` header

**Refresh Token**
- Long-lived credential (days to months)
- Used to obtain new access tokens
- Must be stored securely
- Single-use with token rotation (recommended)

**ID Token (OpenID Connect)**
- Contains user identity information
- Always JWT format
- Used for authentication (not authorization)
- Includes standard claims: sub, name, email, etc.

### Security Parameters

**State Parameter**
- Prevents CSRF attacks
- Random value included in authorization request
- Validated in callback
- Required for security

**PKCE (Code Verifier & Challenge)**
- Prevents authorization code interception
- Required for public clients (SPAs, mobile apps)
- Code verifier: Random string (43-128 chars)
- Code challenge: SHA256 hash of verifier
- Validated during token exchange

### Scopes

Scopes define the permissions being requested:

```
openid              - Request OIDC ID token
profile             - User profile information
email               - User email address
read:data           - Read access to data
write:data          - Write access to data
admin:users         - Admin access to users
```

## Token Storage Best Practices

### Web Applications (Server-Side)

✅ **Recommended:**
- Store tokens in server-side session
- Use secure session cookies (httpOnly, secure, sameSite)
- Encrypt tokens at rest
- Implement session timeout

❌ **Avoid:**
- Storing tokens in localStorage
- Exposing tokens to client-side JavaScript
- Including tokens in URLs

### Single Page Applications (SPAs)

✅ **Recommended:**
- Access tokens in memory only (React state, Vuex, Redux)
- Refresh tokens in httpOnly cookies via BFF (Backend for Frontend)
- Token Handler pattern for enhanced security
- Silent authentication for token refresh

❌ **Avoid:**
- localStorage (vulnerable to XSS)
- sessionStorage (also vulnerable to XSS)
- Storing refresh tokens in browser

### Mobile Applications

✅ **Recommended:**
- Use platform secure storage:
  - iOS: Keychain Services
  - Android: EncryptedSharedPreferences or Android Keystore
- Implement biometric authentication
- Use refresh tokens for long-lived sessions

❌ **Avoid:**
- Storing tokens in SharedPreferences (Android)
- Storing tokens in UserDefaults (iOS)
- Plaintext storage

## Common Use Cases

### 1. Social Login Integration

Implement "Sign in with Google/GitHub/Facebook":

```javascript
// Google OAuth2 configuration
const googleConfig = {
  clientId: 'your_google_client_id',
  clientSecret: 'your_google_client_secret',
  authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenUrl: 'https://oauth2.googleapis.com/token',
  scopes: ['openid', 'profile', 'email'],
};

// GitHub OAuth2 configuration
const githubConfig = {
  clientId: 'your_github_client_id',
  clientSecret: 'your_github_client_secret',
  authorizationUrl: 'https://github.com/login/oauth/authorize',
  tokenUrl: 'https://github.com/login/oauth/access_token',
  scopes: ['read:user', 'user:email'],
};
```

### 2. API Authentication

Protect your APIs with OAuth2 tokens:

```javascript
// Validate access token middleware
async function validateAccessToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }

  const token = authHeader.substring(7);

  try {
    // Validate JWT token
    const payload = jwt.verify(token, publicKey, {
      algorithms: ['RS256'],
      issuer: 'https://auth.example.com',
      audience: 'https://api.example.com',
    });

    // Check required scopes
    if (!payload.scope || !payload.scope.includes('read:data')) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    req.user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

// Protected API endpoint
app.get('/api/data', validateAccessToken, (req, res) => {
  res.json({ message: 'Protected data', userId: req.user.sub });
});
```

### 3. Multi-Tenant Authentication

Support organization-based authentication:

```javascript
// Organization-scoped token request
const params = new URLSearchParams({
  client_id: 'your_client_id',
  redirect_uri: 'https://yourapp.com/callback',
  response_type: 'code',
  scope: 'openid profile email organization:acme-corp',
  state: state,
});

// API validates organization access
function validateOrganization(req, res, next) {
  const orgId = req.params.orgId;
  const tokenOrgId = req.user.org_id;

  if (orgId !== tokenOrgId) {
    return res.status(403).json({ error: 'Access denied to organization' });
  }

  next();
}
```

## Security Checklist

✅ **Essential Security Measures:**

- [ ] Use HTTPS for all OAuth2 endpoints
- [ ] Implement PKCE for public clients (SPAs, mobile)
- [ ] Always validate state parameter (CSRF protection)
- [ ] Strictly validate redirect URIs (exact match)
- [ ] Use short-lived access tokens (15-60 minutes)
- [ ] Implement refresh token rotation
- [ ] Validate all JWT tokens (signature, exp, iss, aud)
- [ ] Never store tokens in localStorage
- [ ] Use secure token storage (httpOnly cookies, Keychain)
- [ ] Implement token revocation
- [ ] Use scope-based access control
- [ ] Log authentication events
- [ ] Monitor for suspicious activity
- [ ] Implement rate limiting on auth endpoints
- [ ] Use strong client secrets (64+ random characters)

❌ **Security Anti-Patterns to Avoid:**

- [ ] Using Implicit Flow (deprecated)
- [ ] Storing tokens in localStorage
- [ ] Using weak or predictable state values
- [ ] Allowing wildcard redirect URIs
- [ ] Long-lived access tokens (hours/days)
- [ ] Ignoring token expiration
- [ ] Not validating JWT signatures
- [ ] Using HS256 with shared secrets for JWTs
- [ ] Including tokens in URLs or logs
- [ ] Not implementing PKCE for public clients
- [ ] Using Resource Owner Password Credentials flow
- [ ] Exposing client secrets in client-side code

## Troubleshooting Common Issues

### Issue: "Invalid redirect_uri"

**Cause:** Redirect URI doesn't match registered URI exactly

**Solution:**
```javascript
// Ensure exact match including:
// - Protocol (http vs https)
// - Host (domain.com vs www.domain.com)
// - Port (if specified)
// - Path (if specified)

// Registered: https://app.example.com/auth/callback
// Request must use: https://app.example.com/auth/callback
// NOT: http://app.example.com/auth/callback (wrong protocol)
// NOT: https://app.example.com/callback (wrong path)
```

### Issue: "Invalid state parameter"

**Cause:** State mismatch or missing state validation

**Solution:**
```javascript
// Generate cryptographically secure state
const state = crypto.randomBytes(32).toString('hex');

// Store in session or encrypted cookie
req.session.oauth2State = state;

// Validate in callback
if (req.query.state !== req.session.oauth2State) {
  throw new Error('Invalid state - possible CSRF attack');
}

// Clear state after validation
delete req.session.oauth2State;
```

### Issue: "Invalid code_verifier"

**Cause:** PKCE code verifier doesn't match challenge

**Solution:**
```javascript
// Ensure code verifier is stored correctly
const codeVerifier = generateRandomString(64);
sessionStorage.setItem('code_verifier', codeVerifier);

// Generate challenge correctly (SHA256, base64url-encoded)
const codeChallenge = await generateCodeChallenge(codeVerifier);

// Use code_challenge_method: 'S256' (not 'plain')
// Retrieve and send code_verifier in token request
```

### Issue: "Token expired"

**Cause:** Access token expired, not refreshed

**Solution:**
```javascript
// Implement automatic token refresh
async function getValidToken() {
  const expiresAt = sessionStorage.getItem('token_expiry');

  if (Date.now() >= parseInt(expiresAt)) {
    // Token expired, refresh it
    await refreshAccessToken();
  }

  return sessionStorage.getItem('access_token');
}

// Or use proactive refresh (5 minutes before expiry)
const refreshIn = (expiresIn - 300) * 1000;
setTimeout(refreshAccessToken, refreshIn);
```

## Performance Optimization

### Token Caching

```javascript
// Cache tokens to avoid unnecessary requests
class TokenCache {
  constructor() {
    this.cache = new Map();
  }

  get(key) {
    const entry = this.cache.get(key);
    if (!entry) return null;

    // Check expiration
    if (Date.now() >= entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }

    return entry.token;
  }

  set(key, token, expiresIn) {
    this.cache.set(key, {
      token,
      expiresAt: Date.now() + (expiresIn * 1000),
    });
  }
}
```

### Connection Pooling

```javascript
// Reuse HTTP connections for better performance
const https = require('https');
const axios = require('axios');

const agent = new https.Agent({
  keepAlive: true,
  maxSockets: 50,
});

const client = axios.create({
  httpsAgent: agent,
  timeout: 30000,
});
```

## Testing OAuth2 Implementations

### Mock Authorization Server

```javascript
// Mock OAuth2 server for testing
const express = require('express');
const jwt = require('jsonwebtoken');

const mockAuthServer = express();

mockAuthServer.post('/oauth/token', (req, res) => {
  const { grant_type, code } = req.body;

  if (grant_type === 'authorization_code' && code === 'test_code') {
    res.json({
      access_token: jwt.sign({ sub: 'test_user' }, 'secret', { expiresIn: '1h' }),
      token_type: 'Bearer',
      expires_in: 3600,
      refresh_token: 'test_refresh_token',
    });
  } else {
    res.status(400).json({ error: 'invalid_grant' });
  }
});

mockAuthServer.listen(9000);
```

### Integration Tests

```javascript
// Test OAuth2 flow
describe('OAuth2 Authentication', () => {
  it('should complete authorization code flow', async () => {
    // 1. Initiate authorization
    const authUrl = generateAuthorizationUrl();
    expect(authUrl).toContain('response_type=code');
    expect(authUrl).toContain('state=');

    // 2. Simulate callback
    const tokens = await handleCallback('test_code', 'test_state');
    expect(tokens.access_token).toBeDefined();
    expect(tokens.refresh_token).toBeDefined();

    // 3. Verify token can access protected resource
    const response = await fetch('/api/protected', {
      headers: { Authorization: `Bearer ${tokens.access_token}` },
    });
    expect(response.status).toBe(200);
  });
});
```

## Migration Strategies

### From Session-Based to OAuth2

1. **Phase 1: Dual Authentication**
   - Support both session and OAuth2 simultaneously
   - New users use OAuth2
   - Existing users continue with sessions

2. **Phase 2: Migration Flow**
   - Prompt existing users to link OAuth2 account
   - Migrate user data to new authentication system
   - Maintain session as fallback

3. **Phase 3: Full Cutover**
   - Deprecate session-based authentication
   - Force remaining users to migrate
   - Remove legacy authentication code

### From Implicit Flow to PKCE

```javascript
// Old: Implicit Flow (deprecated)
// response_type=token (returns token in URL)

// New: Authorization Code Flow with PKCE
const codeVerifier = generateRandomString(64);
const codeChallenge = await generateCodeChallenge(codeVerifier);

// response_type=code with code_challenge
// Tokens exchanged on backend, not exposed in URL
```

## Additional Resources

### OAuth2 Providers and Services

- **Auth0**: Comprehensive identity platform
- **Okta**: Enterprise identity management
- **Amazon Cognito**: AWS authentication service
- **Google Identity Platform**: Google's OAuth2 provider
- **Azure Active Directory**: Microsoft identity platform
- **Keycloak**: Open-source identity and access management
- **ORY Hydra**: Open-source OAuth2 server

### Useful Libraries

**JavaScript:**
- `oauth4webapi` - Modern OAuth2/OIDC client
- `passport` - Authentication middleware
- `node-oauth2-server` - OAuth2 server
- `jsonwebtoken` - JWT library

**Python:**
- `authlib` - OAuth2/OIDC library
- `python-oauth2` - OAuth2 provider

**PHP:**
- `league/oauth2-client` - OAuth2 client
- `league/oauth2-server` - OAuth2 server

### Learning Resources

- [OAuth2 Simplified](https://aaronparecki.com/oauth-2-simplified/)
- [The OAuth 2.0 Authorization Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749)
- [OAuth 2.0 Security Best Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)
- [OpenID Connect Explained](https://openid.net/connect/)

## Next Steps

1. Review the complete [SKILL.md](./SKILL.md) for detailed implementation guides
2. Explore [EXAMPLES.md](./EXAMPLES.md) for real-world code examples
3. Choose the appropriate OAuth2 flow for your application
4. Implement security best practices from day one
5. Test thoroughly with both success and error scenarios
6. Monitor authentication metrics and security events

---

**Need Help?** Refer to SKILL.md for comprehensive documentation and EXAMPLES.md for complete working examples.
