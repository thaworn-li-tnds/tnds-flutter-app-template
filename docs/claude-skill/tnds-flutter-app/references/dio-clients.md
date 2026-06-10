# Dio Client Selection

## Trigger

Signals: new repository provider, Dio injection, encryption, salt, cert pinning, `viperaDio`, `mymoMsDio`, `cdnDio`, baseUrl, interceptor
Before generating code in this area, output verbatim: `Reading: dio-clients.md`

## Rules — NEVER Violate

1. **A new repository's Dio client CANNOT be inferred** from the API spec, payload shape, or operation name — it is a crypto/session contract owned by the backend.
2. **Never silently default** or copy whichever Dio a nearby repository uses.
3. **ASK the user to confirm** the client before wiring a new `*_repository.dart` provider (use AskUserQuestion). A wrong pick fails only at request time against the real backend.
4. Record a one-line comment on the provider when the choice is non-obvious (e.g. why a Vipera repo uses the app salt).

## The five clients

All in `lib/src/shared/data/remote/` (`vipera_dio.dart`, `mymo_ms_dio.dart`, `config_dio.dart`):

| Provider | Backend | Payload encryption (ViperaInterceptor) | Cert pinning |
|---|---|---|---|
| `mymoMsDioProvider` | App backend (MS) | none | no |
| `viperaDioProvider` | Vipera | AES-GCM, **session salt** (dynamic: `userId + seed`) | yes (SHA-256 ×3) |
| `viperaAppSaltDioProvider` | Vipera | AES-GCM, **app salt** (fixed: `AppEnv.viperaCertificateSalt`) | yes (SHA-256 ×3) |
| `cdnDioProvider` | CDN / static assets | none | no |
| `viperaConfigDioProvider` | Vipera config | per source | per source |

## `viperaDio` vs `viperaAppSaltDio` — the salt is the only difference

Both clients are otherwise identical (baseUrl, timeouts, headers, pinning, cookie jar). They differ in which `CryptoManager` feeds the `ViperaInterceptor`:

| | `viperaDio` | `viperaAppSaltDio` |
|---|---|---|
| crypto provider | `cryptoManagerProvider` | `cryptoManagerAppSaltProvider` |
| salt | dynamic — `clearSalt()` before login, `updateSalt(user, seed)` after login | fixed — always `AppEnv.viperaCertificateSalt` |
| key (PBKDF2 over `passphrase + salt`, `lib/src/utils/encrypt_decrypt.dart`) | follows login state | never changes |

### Decision flow

1. Does this API go to the **app backend (MS)**? → `mymoMsDio`. Static/CDN asset? → `cdnDio`.
2. If Vipera: must the backend **always decrypt with the fixed app key**, independent of any session (canonical case: app-protection / security logging that can fire pre-login, mid-onboarding, on screenshot — `ViperaPreLoginRepository`)? → `viperaAppSaltDio`.
3. Otherwise (works after login, or both pre- and post-login) → `viperaDio`. The dynamic salt adapts: app salt before login, that user's session salt after. Most authenticated feature APIs (account, payment, user, timeline) and re-launchable modules (FR, OTP) use this.

> History note: OTP originally used `viperaAppSaltDio`, then moved to `viperaDio` so it could be reused after login. Do not assume "pre-login flow ⇒ app salt" — face recognition is a pre-login module yet uses `viperaDio`. The deciding question is **the backend's decrypt key**, not the screen's position in the flow.

## Request/response envelope (what the interceptor does)

`ViperaInterceptor` (`lib/src/shared/data/remote/vipera_interceptor.dart`):

- onRequest: wraps your `data` map into the Vipera envelope (`req.dom/app/srv/op/sid`), encrypts the payload with the active `CryptoManager` key.
- onResponse: decrypts `header.data` and flattens it into `response.data`, so repository code parses plain JSON.
- onError: network pre-checks reject with `NoneNetworkDetectionException`; pin mismatch surfaces as `CertificateExpiredException` (see [error-handling.md](error-handling.md)).

Repositories therefore never encrypt, never read cookies, never build envelopes — they only call `postOp` (see [data-layer.md](data-layer.md)).

## Recap

1. New repo ⇒ ask the user: MS or Vipera; if Vipera, fixed app key or session key.
2. `viperaDio` = key follows login; `viperaAppSaltDio` = fixed key (security logging only).
3. Comment non-obvious choices on the provider.
