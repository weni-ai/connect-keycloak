# Phase 1 Contracts: Identity-first login theme (Enterprise Okta)

**Branch**: `feature/okta-login-theme` | **Date**: 2026-08-26 | **Spec**: [spec.md](./spec.md)

## There is no API surface

This directory is intentionally empty of contract files. This delivery exposes no public API, no CLI,
no grammar, and no interface that another system consumes. Writing an OpenAPI document or a schema here
would describe something that does not exist.

A Keycloak login theme sits **behind** Keycloak's HTTP endpoints. It renders the HTML that Keycloak
serves for pages Keycloak itself routes; it does not define, add, or modify a single route. The
endpoints involved — `/realms/{realm}/protocol/openid-connect/auth` and
`/realms/{realm}/login-actions/authenticate` — are Keycloak's, are unchanged by this work, and are
already documented upstream.

## The contracts that do exist are Keycloak's, and we consume them

Three inbound contracts constrain the templates. All are owned by Keycloak, and the requirement in each
case is to keep them intact — Constitution Principle II makes silently dropping one a breaking change
rather than a styling regression.

### 1. Form submission

| Step | Method | Action | Field name | Autocomplete |
| --- | --- | --- | --- | --- |
| 1 — `login-username.ftl` | `POST` | `${url.loginAction}` | `username` | `email` or `username`, per `realm.registrationEmailAsUsername` |
| 2 — `login-password.ftl` | `POST` | `${url.loginAction}` | `password` | `current-password` |

Keycloak's `UsernameForm` reads `username` and `PasswordForm` reads `password` from the decoded form
parameters. Renaming either field, or posting anywhere other than `${url.loginAction}`, breaks
authentication. FR-001 and FR-006 encode this.

Neither step may add a field Keycloak does not accept on that step — FR-001 names the password input,
the forgot-password link, and `rememberMe` specifically.

### 2. Template selection by filename

Keycloak chooses the template; the theme does not register anything. `UsernameForm.createLoginForm`
calls `LoginFormsProvider.createLoginUsername()` and `PasswordForm.createLoginForm` calls
`createLoginPassword()`, which resolve to `login-username.ftl` and `login-password.ftl` in the active
theme, falling back through `parent=base`. The filenames are therefore the contract, which is why the
plan keeps the two screens as separate top-level templates instead of one parameterised macro.

### 3. The template variable contract

Keycloak passes a fixed set of beans into every page. This is the closest thing to a schema in this
change, and it is tabulated in [data-model.md](../data-model.md) with the values measured on a live
26.2.0 flow. Two entries are contract violations waiting to happen if read carelessly:

- `auth.attemptedUsername` throws where no user is established in the flow, including step 1. It must
  be read behind `auth?has_content && auth.showUsername()`.
- `url.loginAction` is absent on some pages — referencing it on `error.ftl` returns HTTP 500. Any
  `url.*` reference added to the shared `template.ftl` must be written defensively.

## The one outbound contract this change must not disturb

`template.ftl` posts `connect:requestlogout` to `window.top` via `postMessage` (lines 328–341), and
injects a per-realm Flows logout iframe (lines 426–443). The Connect web app consumes both. The spec's
Assumptions freeze them, and this delivery does not change session or logout behavior — but
`template.ftl` is a changed file, so this is a review checkpoint rather than a guarantee from scope
alone.

**Keeping it intact takes deliberate work, and the obvious check does not cover it.** The
`postMessage` sits inside `<#if displayLoginFormScriptsAndStyles>`, a flag only `login.ftl` passes.
Step 1 replaces `login.ftl` as the first screen on an identity-first realm, so without FR-023 the
message simply stops being sent — no error, no console warning. The Part 3 console check runs on the
**default** browser flow, where `login.ftl` still passes the flag and the message still fires, so it
would have reported a clean pass over a live regression. Quickstart check 5.10 is the one that
actually covers this; Part 3 covers the iframe and everything else.

## Verification

There are no contract tests, because there is no contract of ours to test and the repository has no
test framework — a constraint the Technical Context states and NFR-001 replaces with manual
verification in the running container. The equivalent evidence is
[quickstart.md](../quickstart.md), which exercises the field names, action URLs, and template selection
above through a real browser flow in all four locales.
