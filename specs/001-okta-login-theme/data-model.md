# Phase 1 Data Model: Identity-first login theme (Enterprise Okta)

**Branch**: `feature/okta-login-theme` | **Date**: 2026-08-26 | **Spec**: [spec.md](./spec.md)

## There is no data model

This delivery adds no entity, no persisted field, no schema, and no migration. Inventing entities here
to fill the template would be misleading, so this document records why the artifact is empty and what
takes its place.

A Keycloak login theme is a presentation layer. Every value the two new templates render is supplied
by Keycloak at request time and lives for exactly one HTTP response:

- The realm, user, and credential model belongs to Keycloak's own schema, which this repository does
  not define, migrate, or extend.
- The identity-first behavior itself is realm and browser-flow configuration. The spec assigns it to
  PS-BD-005's operational procedure and lists it under Out of Scope, and this repository holds no
  realm export.
- Session and credential state is held by Keycloak's authentication session. The theme reads it and
  never writes it.
- `keycloak-user-migration/`, the only component here that touches user storage, is excluded by
  NFR-003.

The repository's model conventions — integer primary key plus a `uuid` public identifier, `auto_now_add`
timestamps, `UniqueConstraint` over `unique=True`, tenant-first indexes — are Django ORM rules. There is
no Django application and no ORM in this repository, so they do not apply to any part of this change.

## What stands in for a data model

Three things carry the weight a data model normally would, and all are specified elsewhere.

### 1. The template variables the new screens read

This is the real "schema" of the change: the contract between Keycloak and the templates. Every entry
below was measured on Keycloak 26.2.0 against a live identity-first flow rather than read from
documentation. Details, including the values observed, are in [research.md](./research.md).

| Variable | Step 1 | Step 2 | Note |
| --- | --- | --- | --- |
| `login.username` | empty on first render | **populated** with the submitted email | Why step 2 must not reuse `canLogin`, and why FR-012 is checked in the DOM |
| `usernameHidden??` | `false` | `false` | Set only when a user is already established in the flow |
| `usernameEditDisabled??` | `false` | `false` | Does not exist anywhere in Keycloak 26.2 — a dead guard in the current theme |
| `registrationDisabled??` | `false` | `false` | Set alongside `usernameHidden`; replaces the dead guard |
| `social.providers?size` | **3** | **0** | Keycloak narrows the list to the user's linked brokers once a user exists |
| `auth.showUsername()` | `false` | **`true`** | The guard FR-007 depends on |
| `auth.attemptedUsername` | unavailable | the submitted email | Throws if read unguarded |
| `url.loginRestartFlowUrl` | present | present | FR-007's back control is a plain link |
| `url.loginResetCredentialsUrl` | present | present | FR-008 |
| `messagesPerField.existsError('username' \| 'password')` | `true` on invalid submit | `true` on wrong password | Fires together with `message`, hence `displayMessage=!...` |

### 2. Client-side state added to the shared Vue app

Transient, per-page-load, never persisted. Named here so a reviewer can check the diff against an
agreed surface.

| Name | Kind | Purpose |
| --- | --- | --- |
| `displayUsernameFormScriptsAndStyles` | macro parameter, default `false` | Gates every step-1 addition. **The name is normative**, not illustrative — `login-username.ftl` passes this exact string, and a mismatch between the declaration and the call is an HTTP 500, not a no-op |
| `displayPasswordFormScriptsAndStyles` | macro parameter, default `false` | The same, for step 2 and `login-password.ftl` |
| `canSubmitUsername` | computed | Step-1 enablement, email only (FR-009) |
| `canSubmitPassword` | computed | Step-2 enablement, password only (FR-009) |
| `submitting` | data | One POST per activation (FR-011, SC-008) |
| `canLogin` | computed, **unchanged** | Still gates `login-form.ftl` only, still requires both values |

### 3. Existing state the new steps must be given access to

Not new state — state that already exists but is unreachable from the new steps, because
`template.ftl` gates it on `displayLoginFormScriptsAndStyles` and only `login.ftl` passes that flag.
Two of the three fail silently rather than loudly, which is why they are tabulated here alongside the
additions. Full detail in [research.md](./research.md), Correction 3.

| Region | Currently gated | Needed by | If missed |
| --- | --- | --- | --- |
| `loginPasswordVisible` (data) | `displayLoginFormScriptsAndStyles` | Step 2's show/hide toggle (FR-006) | `toggleLoginPasswordVisibility` is ungated and would flip an undeclared property. The toggle renders and does nothing |
| `connect:requestlogout` `postMessage` | `displayLoginFormScriptsAndStyles` | Step 1, which replaces `login.ftl` (FR-023) | The Connect web app stops receiving it on every identity-first realm, invisibly to Part 3 |
| `canLogin`, `loginUsername`, `loginPassword`, `rememberMe` | `displayLoginFormScriptsAndStyles` | Nothing — they stay gated | `rememberMe` reaching step 1 would contradict FR-001 |

Message keys are the fourth piece of specified surface; the exact list, wording, and per-locale
coverage are in [research.md](./research.md), Decision 4.
