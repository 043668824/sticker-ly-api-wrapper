# Sticker.ly API Wrapper - External Endpoint Proxy Analysis

## Summary

- **Total proxied endpoints discovered**: 14 API endpoints + 1 static file proxy
- **External services being proxied**: 
  - Sticker.ly API (main service) - 8 unique external endpoints
  - Sticker.ly Static File CDN (stickerly.pstatic.net) - 1 direct proxy

### Unique External API Endpoints

| External Endpoint | Nuxt Routes Using It | Purpose |
|-------------------|---------------------|---------|
| `v4/sticker/searchV2` | `/stickers/search`, `/packs/search` | Search functionality |
| `v4/sticker/recommend` | `/stickers/recommended` | Sticker recommendations |
| `v4/sticker/related` | `/stickers/[id]/related` | Related stickers |
| `v4/sticker/tag/recommend` | `/tags/recommended` | Tag recommendations |
| `v4/stickerPack/recommend` | `/packs/recommended` | Pack recommendations |
| `v4/stickerPack/{id}` | `/packs/[id]` | Pack details |
| `v4/stickerPack/{id}/recommendedCategories` | `/packs/[id]/related` | Related packs |
| `v4/stickerTag/search` | `/tags/search` | Tag search |
| `v4/trending/search` | `/tags/trending`, `/artists/trending` | Trending data |
| `v4/artist/recommend` | `/artists/recommended` | Artist recommendations |
| `v4/hometab/overview` | `/home-tabs` | Home tab overview |
| `v4/hometab/{id}/packs` | `/home-tabs/[id]` | Home tab packs |

## Configuration Analysis

### Environment Variables

The application relies on the following environment variables for external service configuration:

```bash
# Sticker.ly API configuration
STICKERLY_API_BASE_URL=         # Base URL for the Sticker.ly API
STICKERLY_USER_AGENT=           # User-Agent header for API requests

# Public URL configuration
NUXT_PUBLIC_SITE_URL=           # Used for URL rewriting in responses

# Database configuration
DATABASE_URL=                   # PostgreSQL connection string for internal logging
```

### Proxy Mechanisms

1. **Direct Proxy (Nitro routeRules)**: Static file serving
2. **Server-side Proxy (useFetchApi)**: API endpoint proxying with transformation

## Internal (Non-Proxied) Endpoints

The application also provides internal endpoints that do not proxy to external services:

### Endpoint: API Request Logs
- **Nuxt Route**: `/api/logs`
- **Purpose**: Retrieve API request logs from internal PostgreSQL database
- **Methods**: `GET`
- **Authentication**: None
- **Data Source**: Internal database (not external proxy)

### Endpoint: API Statistics
- **Nuxt Route**: `/api/stats`
- **Purpose**: Retrieve API usage statistics from internal PostgreSQL database
- **Methods**: `GET`
- **Authentication**: None
- **Data Source**: Internal database (not external proxy)

## External API Endpoint Mapping

The following table summarizes all unique external API endpoints being proxied:

| Nuxt Endpoint | External API Endpoint | HTTP Method | Purpose |
|---------------|----------------------|-------------|---------|
| `/file/**` | `https://stickerly.pstatic.net/**` | GET | Static file serving |
| `/api/v1/stickers/search` | `v4/sticker/searchV2` | POST | Search stickers |
| `/api/v1/stickers/recommended` | `v4/sticker/recommend` | GET | Get recommended stickers |
| `/api/v1/stickers/[id]/related` | `v4/sticker/related?sid={id}` | GET | Get related stickers |
| `/api/v1/packs/search` | `v4/sticker/searchV2` | POST | Search stickers (returns stickers, not packs) |
| `/api/v1/packs/recommended` | `v4/stickerPack/recommend` | GET | Get recommended packs |
| `/api/v1/packs/[id]` | `v4/stickerPack/{id}` | GET | Get pack details |
| `/api/v1/packs/[id]/related` | `v4/stickerPack/{id}/recommendedCategories` | GET | Get related packs |
| `/api/v1/tags/search` | `v4/stickerTag/search` | POST | Search tags |
| `/api/v1/tags/recommended` | `v4/sticker/tag/recommend` | GET | Get recommended tags |
| `/api/v1/tags/trending` | `v4/trending/search` | POST | Get trending tags |
| `/api/v1/artists/recommended` | `v4/artist/recommend` | POST | Get recommended artists |
| `/api/v1/artists/trending` | `v4/trending/search` | POST | Get trending artists |
| `/api/v1/home-tabs` | `v4/hometab/overview` | GET | Get home tab overview |
| `/api/v1/home-tabs/[id]` | `v4/hometab/{id}/packs` | GET | Get home tab packs |

### Notable Patterns

1. **Shared External Endpoints**: Some external endpoints serve multiple Nuxt routes:
   - `v4/sticker/searchV2` serves both sticker and pack search
   - `v4/trending/search` serves both trending tags and trending artists

2. **Method Transformation**: Several GET endpoints in Nuxt are transformed to POST requests for the external API:
   - All search endpoints (stickers, packs, tags)
   - Trending endpoints (tags, artists)
   - Artist recommendations

3. **Response Filtering**: The trending endpoint returns different data types, but the Nuxt endpoints filter and map specific parts:
   - `/tags/trending` extracts `keywords` from the response
   - `/artists/trending` extracts `recommendUsers` from the response

## Detailed Endpoint Documentation

### Endpoint #1: Static File Proxy

- **Nuxt Route**: `/file/**`
- **External Target**: `https://stickerly.pstatic.net/**`
- **Methods**: `GET`
- **Authentication**: None required
- **Headers**:
  - Required: None
  - Forwarded: All standard headers
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: N/A (GET only)
- **Response Format**: Raw file data (images, etc.)
- **Error Handling**: Default Nitro proxy error handling
- **Rate Limiting**: None configured
- **Caching**: 1 hour cache (`maxAge: 60 * 60`)

### Endpoint #2: Stickers Search

- **Nuxt Route**: `/api/v1/stickers/search`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/sticker/searchV2`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: Content-Type: application/json
- **Query Parameters**: 
  - `keyword` (required): Search term
  - `pagination[page]` (optional, default: 1): Page number
  - `pagination[pageSize]` (optional, default: 10): Results per page
- **Request Body Schema** (external API):
  ```json
  {
    "keyword": "string (processed with normalization and country filter)",
    "size": "number",
    "cursor": "number",
    "limit": "number"
  }
  ```
- **Response Format**: Standardized API response with sticker array and pagination meta
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 30 seconds cache, 30 minutes stale cache

### Endpoint #3: Recommended Stickers

- **Nuxt Route**: `/api/v1/stickers/recommended`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/sticker/recommend`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with recommended stickers array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 10 minutes cache, 2 hours stale cache

### Endpoint #4: Related Stickers by ID

- **Nuxt Route**: `/api/v1/stickers/[id]/related`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/sticker/related?sid={id}`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: 
  - `id` (from route params): Sticker ID
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with related stickers array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 5 minutes cache, 1 hour stale cache

### Endpoint #5: Pack Search

- **Nuxt Route**: `/api/v1/packs/search`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/sticker/searchV2`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: Content-Type: application/json
- **Query Parameters**:
  - `keyword` (required): Search term
  - `pagination[page]` (optional, default: 1): Page number
  - `pagination[pageSize]` (optional, default: 10): Results per page
- **Request Body Schema** (external API):
  ```json
  {
    "keyword": "string (processed with normalization and country filter)",
    "size": "number",
    "cursor": "number", 
    "limit": "number"
  }
  ```
- **Response Format**: Standardized API response with stickers array and pagination meta (Note: Returns stickers, not packs despite endpoint name)
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 30 seconds cache, 30 minutes stale cache

### Endpoint #6: Recommended Packs

- **Nuxt Route**: `/api/v1/packs/recommended`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/stickerPack/recommend`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with packs and premium packs arrays
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 10 minutes cache, 2 hours stale cache

### Endpoint #7: Pack by ID

- **Nuxt Route**: `/api/v1/packs/[id]`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/stickerPack/{id}`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**:
  - `id` (from route params): Pack ID
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with pack details and sticker URLs
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 5 minutes cache, 1 hour stale cache

### Endpoint #8: Related Packs by ID

- **Nuxt Route**: `/api/v1/packs/[id]/related`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/stickerPack/{id}/recommendedCategories`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**:
  - `id` (from route params): Pack ID
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with related packs array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 5 minutes cache, 1 hour stale cache

### Endpoint #9: Tag Search

- **Nuxt Route**: `/api/v1/tags/search`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/stickerTag/search`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: Content-Type: application/json
- **Query Parameters**:
  - `keyword` (required): Search term
  - `pagination[page]` (optional, default: 1): Page number
  - `pagination[pageSize]` (optional, default: 10): Results per page
- **Request Body Schema** (external API):
  ```json
  {
    "keyword": "string (lowercased)",
    "size": "number",
    "cursor": "number",
    "limit": "number"
  }
  ```
- **Response Format**: Standardized API response with tag array and pagination meta
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 30 seconds cache, 30 minutes stale cache

### Endpoint #10: Recommended Tags

- **Nuxt Route**: `/api/v1/tags/recommended`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/sticker/tag/recommend`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with recommended tags array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 10 minutes cache, 2 hours stale cache

### Endpoint #11: Trending Tags

- **Nuxt Route**: `/api/v1/tags/trending`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/trending/search`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: Empty POST body
- **Response Format**: Standardized API response with trending tags array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 30 minutes cache, 6 hours stale cache

### Endpoint #12: Recommended Artists

- **Nuxt Route**: `/api/v1/artists/recommended`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/artist/recommend`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: Empty POST body
- **Response Format**: Standardized API response with recommended artists array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 10 minutes cache, 2 hours stale cache

### Endpoint #13: Trending Artists

- **Nuxt Route**: `/api/v1/artists/trending`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/trending/search`
- **Methods**: `GET` (Nuxt) → `POST` (External API)
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: Empty POST body
- **Response Format**: Standardized API response with trending artists array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 30 minutes cache, 6 hours stale cache

### Endpoint #14: Home Tabs Overview

- **Nuxt Route**: `/api/v1/home-tabs`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/hometab/overview`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**: None
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with home tabs array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 5 minutes cache, 1 hour stale cache

### Endpoint #15: Home Tab Packs by ID

- **Nuxt Route**: `/api/v1/home-tabs/[id]`
- **External Target**: `{STICKERLY_API_BASE_URL}v4/hometab/{id}/packs`
- **Methods**: `GET`
- **Authentication**: User-Agent header (`STICKERLY_USER_AGENT`)
- **Headers**:
  - Required: User-Agent (from env var)
  - Forwarded: None
  - Added by proxy: None
- **Query Parameters**:
  - `id` (from route params): Home tab ID
- **Request Body Schema**: N/A
- **Response Format**: Standardized API response with packs array
- **Error Handling**: Formatted errors with status codes, fallback to 500
- **Rate Limiting**: None configured
- **Caching**: 5 minutes cache, 1 hour stale cache

## Data Transformation Patterns

### URL Rewriting
All responses undergo URL transformation where external CDN URLs are replaced with local proxy URLs:
- **From**: `https://stickerly.pstatic.net/`
- **To**: `{NUXT_PUBLIC_SITE_URL}/file/` (or `/file/` if env var not set)

### Request Transformation
Several endpoints transform GET requests to POST requests for the external API, adding request bodies with structured data.

### Response Standardization
All API responses are formatted using a consistent structure:
```json
{
  "status": "success|error",
  "message": "string",
  "data": "any",
  "meta": "object (optional)",
  "errors": "object (optional for errors)",
  "timestamp": "ISO string"
}
```

## Security Considerations

### Current Security Measures
- **Environment-based configuration**: API credentials stored in environment variables
- **User-Agent authentication**: All external API calls include required User-Agent header
- **Input validation**: Keyword validation for search endpoints
- **Error sanitization**: Error details are logged server-side but sanitized in responses

### Potential Security Concerns
- **No rate limiting**: External API calls have no rate limiting protection
- **User-Agent exposure**: The User-Agent string might contain sensitive information
- **No CORS restrictions**: No explicit CORS configuration found
- **Environment variable exposure**: Risk if environment variables are not properly secured

### Data Exposure Risks
- **API response caching**: Responses are cached which may expose data longer than intended
- **Error stack traces**: Development error details might be exposed in production
- **No request size limits**: No apparent limits on request payload sizes

## Recommendations

### Missing Error Handling
- Implement consistent timeout handling for external API calls
- Add retry logic for failed external API requests
- Implement circuit breaker pattern for external service failures

### Potential Security Improvements
- Add rate limiting to prevent abuse of the proxy endpoints
- Implement request size limits
- Add input sanitization for all user inputs
- Consider adding API key authentication for the wrapper API
- Implement proper CORS configuration
- Add request/response logging with sanitization

### Documentation Gaps
- Missing OpenAPI/Swagger specification for the wrapper API
- No documentation of external API rate limits or quotas
- Missing information about external API authentication requirements
- No documentation of external service SLA or availability

### Performance Optimizations
- Consider implementing request batching for multiple related calls
- Add compression for large responses
- Implement more granular caching strategies based on content type
- Consider CDN integration for static file proxy

## Implementation Details

### Proxy Architecture
The application uses two different proxy mechanisms:

1. **Nitro Route Rules** (`nuxt.config.ts`):
   - Direct proxy for static files
   - Minimal configuration with caching
   - No transformation or authentication

2. **Server-side Fetch Proxy** (`server/utils/fetchApi.ts`):
   - Custom proxy implementation using `$fetch`
   - Supports request/response transformation
   - Handles authentication and error formatting
   - Integrates with Nuxt's caching system

### External Service Dependencies
- **Primary**: Sticker.ly API (all functionality depends on this)
- **Secondary**: Sticker.ly CDN (for static file serving)
- **Internal**: PostgreSQL database (for request logging, not proxying)

### Implementation Architecture

This Nuxt.js application implements a **hybrid proxy pattern**:

1. **Static Proxy Layer**: Direct file proxy using Nitro's built-in proxy capabilities
2. **API Transformation Layer**: Server-side API endpoints that fetch, transform, and standardize responses

### Request Flow Pattern

```mermaid
Client Request → Nuxt API Endpoint → useFetchApi() → External Sticker.ly API → Response Transformation → Standardized Response
```

1. **Client** makes request to Nuxt API endpoint (e.g., `/api/v1/stickers/search`)
2. **Nuxt handler** validates input and prepares request
3. **useFetchApi utility** makes authenticated request to external API
4. **Response transformer** processes the response (URL rewriting, data mapping)
5. **Standardized response** returned to client with consistent format

### Cache Strategy
Different endpoints have varying cache durations based on data volatility:
- **Search results**: 30 seconds (highly dynamic)
- **Recommendations**: 10 minutes (moderately dynamic)
- **Trending data**: 30 minutes (less dynamic)
- **Static content**: 1 hour (rarely changes)