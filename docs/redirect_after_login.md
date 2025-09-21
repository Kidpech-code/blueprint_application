Redirect-after-login behavior

Overview

When the app detects an expired token or needs the user to authenticate, it should redirect the user to the login screen and then bring them back to the page they were on before.

Resolution priority (implemented):

1. widgetRedirect (query param) — If the login screen was reached via a named redirect (e.g. `/auth/login?redirect=%2Fblog%2F2024%2F...`), the app will try to use that. The value will be URL-decoded and validated.

2. RouteHistory.last — A service that records the last non-auth path visited via AppRouter.go/push/replace. This is used when there was no explicit redirect param.

3. Fallback — If neither of the above are available, fallback to the user's profile page (`/profile/<userId>`) if available, otherwise `/`.

Security & validation

- The resolver rejects any redirect values that look like full URLs (contain `://`) to prevent open-redirect vulnerabilities.
- The resolver requires the path to start with `/` and rejects paths that start with `/auth` (login/register) to avoid loops.

Integration points

- `RouteHistory` is updated when `AppRouter.go`, `push`, or `replace` are called.
- `AuthInterceptor` (Dio) detects 401 responses and will call logout then navigate to `/auth/login?redirect=<encoded-last>` using `RouteHistory.last`.
- `LoginView` accepts an optional `redirectTo` parameter (provided by the router). After successful login it resolves a safe redirect using the resolver utility and navigates there.

Examples

- Case: User is on `/blog/2024/01/01/hello`, token expires while they are reading. API returns 401. `AuthInterceptor` logs out and sends them to `/auth/login?redirect=%2Fblog%2F2024%2F01%2F01%2Fhello`. After login they are redirected back to the blog post.

- Case: App was closed and reopened, user opens app (no history). Login used without redirect. After successful login they will be taken to `/profile/<userId>` if available, otherwise `/`.

Notes

- If you need stricter control, replace the path validation with a whitelist of allowed destinations.
- Consider token refresh flow: currently 401 triggers logout+redirect; if your API provides refresh tokens, implement a refresh+retry before forcing logout.
