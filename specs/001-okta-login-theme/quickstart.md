# Phase 1 Quickstart: verifying the identity-first login theme

**Branch**: `feature/okta-login-theme` | **Date**: 2026-08-26 | **Spec**: [spec.md](./spec.md)

This is the verification procedure NFR-001 requires: both steps, all four locales, exercised through a
real browser flow in the Docker Compose container. "It looks right in the editor" is not verification,
and neither is reading the diff.

The setup commands below were run against `quay.io/keycloak/keycloak:26.2.0` with `themes/ilhasoft/`
mounted during Phase 0 research, so they work as written. What they did **not** cover is the two new
templates, which did not exist yet — the checks in Part 3 onward are the procedure for those.

## Prerequisites

- Docker with the Compose plugin.
- The external network the compose file expects. Create it once:

```bash
docker network create keycloak
```

- No other process on port 8080.

## Part 1 — Bring up the runtime

```bash
cd /path/to/connect-keycloak
docker compose up -d
docker compose logs -f keycloak   # wait for "Keycloak 26.2.0 on JVM ... started"
```

`docker-compose.yml` already mounts `./themes/ilhasoft/` into the container and disables theme and
template caching, so every `.ftl`, CSS, and `messages/*.properties` edit is picked up on the next page
load with no restart. If a change does not appear, the file is outside the mount — which under NFR-004
means it should not have been edited.

The startup log prints two deprecation warnings, because `docker-compose.yml` sets `KEYCLOAK_ADMIN` /
`KEYCLOAK_ADMIN_PASSWORD` rather than the `KC_BOOTSTRAP_ADMIN_*` names 26.x prefers. Verified on
26.2.0: the old names are still honoured, the temporary `admin` user is created, and `admin` / `admin`
authenticates. Ignore the warnings; changing them is outside NFR-004.

Convenience shell function used throughout:

```bash
kc() { docker compose exec -T keycloak /opt/keycloak/bin/kcadm.sh "$@"; }
kc config credentials --server http://localhost:8080 --realm master --user admin --password admin
```

## Part 2 — Create the probe realm

Two realms' worth of behavior has to be checked: one on an identity-first flow (Stories 1, 2, 4) and
one still on the default flow (Story 3). One realm with a switchable browser flow covers both.

```bash
kc create realms \
  -s realm=probe -s enabled=true -s loginTheme=ilhasoft \
  -s registrationAllowed=true -s resetPasswordAllowed=true \
  -s loginWithEmailAllowed=true -s registrationEmailAsUsername=true -s rememberMe=true \
  -s internationalizationEnabled=true -s 'supportedLocales=["en","pt-BR","es","ro"]' -s defaultLocale=en

kc create clients -r probe \
  -s clientId=probe-app -s enabled=true -s publicClient=true -s standardFlowEnabled=true \
  -s 'redirectUris=["http://localhost:3000/*"]' -s 'webOrigins=["*"]'

kc create users -r probe -s username=user@example.com -s email=user@example.com \
  -s emailVerified=true -s enabled=true
kc set-password -r probe --username user@example.com --new-password 'Passw0rd!'
```

Add the three providers FR-003 and SC-003 depend on. The credentials are dummies — the buttons only
need to render and link:

```bash
for p in github google microsoft; do
  kc create identity-provider/instances -r probe \
    -s alias=$p -s providerId=$p -s enabled=true \
    -s 'config={"clientId":"x","clientSecret":"y"}'
done
```

The login URL used everywhere below:

```bash
AUTH='http://localhost:8080/realms/probe/protocol/openid-connect/auth?client_id=probe-app&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2F&response_type=code&scope=openid'
echo "$AUTH"
```

> **Do not update the realm with a partial JSON body.** A `PUT /admin/realms/probe` carrying only a
> couple of fields resets everything absent from the body — during Phase 0 it silently wiped
> `internationalizationEnabled` and `supportedLocales`, which made every locale render English and
> looked like a message-bundle bug. Use `kc update realms/probe -s key=value`, which merges.

## Part 3 — Baseline: Story 3, the untouched flows (SC-005)

Do this **before** switching the flow, so a regression is attributable.

The realm is still on the default browser flow, so `login.ftl` serves the combined screen.

1. Open `$AUTH`. Confirm today's combined screen: brand logo, one email field, one password field with
   the show/hide toggle, the three provider buttons, the sign-up block, the privacy footer.
2. Log in with `user@example.com` / `Passw0rd!`. Confirm it succeeds and redirects.
3. Walk each remaining screen and confirm it is unchanged: registration, reset password
   (`login-reset-password.ftl`), update password, OTP setup (`login-config-totp.ftl`), verify email.
4. **Console must be clean.** Open DevTools before loading each screen and confirm no new errors and
   no `Unnnic component not found` warnings. `template.ftl` is a changed file, so this also covers the
   `connect:requestlogout` `postMessage` and the Flows logout iframe that the spec's Assumptions
   freeze — **on the default flow only**. `login.ftl` passes `displayLoginFormScriptsAndStyles`, which
   is what gates the `postMessage`, so a pass here says nothing about step 1. Check 5.10 is the one
   that covers identity-first.

Record this as the "before" state. Repeat the whole of Part 3 after the change; SC-005 requires it to
be identical.

## Part 4 — Switch to an identity-first flow

Create a flow that renders `login-username.ftl` then `login-password.ftl`:

```bash
TOKEN=$(curl -s -d client_id=admin-cli -d username=admin -d password=admin -d grant_type=password \
  http://localhost:8080/realms/master/protocol/openid-connect/token \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
A="Authorization: Bearer $TOKEN"; B=http://localhost:8080/admin/realms/probe
post() { curl -s -o /dev/null -w "%{http_code} $2\n" -X POST -H "$A" -H 'Content-Type: application/json' -d "$3" "$B$1"; }

post /authentication/flows '' '{"alias":"identity-first","providerId":"basic-flow","topLevel":true,"builtIn":false}'
post /authentication/flows/identity-first/executions/execution '' '{"provider":"auth-cookie"}'
post /authentication/flows/identity-first/executions/flow '' '{"alias":"if-forms","type":"basic-flow","provider":"registration-page-form"}'
post /authentication/flows/if-forms/executions/execution '' '{"provider":"auth-username-form"}'
post /authentication/flows/if-forms/executions/flow '' '{"alias":"if-password","type":"basic-flow","provider":"registration-page-form"}'
post /authentication/flows/if-password/executions/execution '' '{"provider":"auth-password-form"}'
```

New executions default to `DISABLED`, so set the requirements and bind the flow:

```bash
curl -s -H "$A" "$B/authentication/flows/identity-first/executions" > /tmp/ex.json
python3 - <<'PY'
import json, subprocess
want = {"Cookie":"ALTERNATIVE","if-forms":"ALTERNATIVE",
        "Username Form":"REQUIRED","if-password":"REQUIRED","Password Form":"REQUIRED"}
parent = {"Cookie":"identity-first","if-forms":"identity-first",
          "Username Form":"if-forms","if-password":"if-forms","Password Form":"if-password"}
for e in json.load(open('/tmp/ex.json')):
    name = e.get('displayName') or e.get('providerId')
    if name in want:
        print(name, "->", want[name])
        print(json.dumps({"flow": parent[name], "id": e["id"], "requirement": want[name]}))
PY
```

Apply each line with `PUT $B/authentication/flows/<flow>/executions`, then bind and confirm:

```bash
kc update realms/probe -s browserFlow=identity-first
curl -s -H "$A" "$B/authentication/flows/identity-first/executions" \
  | python3 -c 'import sys,json;[print(" ","lvl%s"%e["level"],e["requirement"],e.get("displayName") or e.get("providerId")) for e in json.load(sys.stdin)]'
```

Expected:

```text
  lvl0 ALTERNATIVE Cookie
  lvl0 ALTERNATIVE if-forms
  lvl1 REQUIRED    Username Form
  lvl1 REQUIRED    if-password
  lvl2 REQUIRED    Password Form
```

Verify `internationalizationEnabled` survived, since `browserFlow` was just changed:

```bash
kc get realms/probe --fields internationalizationEnabled,supportedLocales,loginTheme,browserFlow
```

## Part 5 — Story 1: step 1 (SC-001, SC-002, SC-003)

Open `$AUTH`. This is now `login-username.ftl`.

| # | Check | Requirement |
| --- | --- | --- |
| 5.1 | Theme's own step 1 renders — brand logo, UNNNIC form element, language selector. No stock Keycloak styling anywhere | SC-001 |
| 5.2 | **In the DOM**, `document.querySelectorAll('input[type=password]').length === 0` and there is no forgot-password link | SC-002 |
| 5.3 | Exactly three provider buttons, ids `zocial-github`, `zocial-google`, `zocial-microsoft`, class `social-button`, icons `img/login/icon-<alias>.svg`, in that order | FR-003, SC-003 |
| 5.4 | Each provider button has an accessible name identifying its provider — inspect the accessibility tree, expect e.g. "Login with github" | FR-014, SC-007 |
| 5.5 | Clicking a provider navigates straight to its `loginUrl` without reading the email field | Story 1 scenario 3 |
| 5.6 | Submit is disabled with the field empty, and enabled once a valid email is typed — **without** a password field existing | FR-009 |
| 5.7 | Submitting empty or malformed input keeps you on the theme's step 1 with a theme-rendered message, and the message appears **once**, not twice | FR-015, Decision 6 |
| 5.8 | Paste a 254-character email; the card does not overflow | Edge case |
| 5.9 | Press Enter in the email field. Exactly one POST to `${url.loginAction}` with field name `username` | Story 1 scenario 5 |
| 5.10 | The `connect:requestlogout` `postMessage` still fires on this screen, exactly as it does on `login.ftl` | FR-023, SC-012 |
| 5.11 | Nothing the theme originates blocks the email field from accepting input. In the Network panel, no request other than the page, the vendored assets, and the pre-existing Google Fonts stylesheet | NFR-005 |

For 5.3, diff the rendered block against the baseline instead of eyeballing it:

```bash
curl -s "$AUTH" | grep -A4 'id="zocial-'
```

Compare with `themes/ilhasoft/login/login.ftl` lines 19–34. SC-003 allows exactly one difference: the
accessible name added by FR-014.

For 5.6, note that `redirect_uri` is absent from the URL after any submit, so the `VTEXAppEmail`
prefill only applies on the **first** render — see Part 8.

Check 5.10 is the one that is easy to skip and expensive to miss. The emission is gated on
`displayLoginFormScriptsAndStyles`, which only `login.ftl` passes, so step 1 goes silent unless FR-023
was implemented — and Part 3 cannot detect that, because it runs on the default flow where `login.ftl`
still passes the flag. Listen for it from the parent frame:

```javascript
// paste in the console of the page that embeds the login, or run on the login page itself
// with window.top === window, then reload
window.addEventListener('message', (e) => {
  if (typeof e.data === 'string' && e.data.startsWith('connect:requestlogout')) {
    console.log('OK requestlogout:', e.data);
  }
});
```

Expect exactly one log on load, on step 1 and on `login.ftl` alike. Zero on step 1 is the regression.

## Part 6 — Story 2: step 2 (SC-001, SC-002, SC-004)

Submit `user@example.com` on step 1. This is now `login-password.ftl`.

| # | Check | Requirement |
| --- | --- | --- |
| 6.1 | Theme's own password screen renders, one password field, show/hide toggle works | FR-006, SC-001 |
| 6.2 | **In the DOM**, no `input[type=email]`, no `input[name=username]` — including hidden inputs — and no provider block | FR-006, FR-012, SC-002 |
| 6.3 | The submitted email is displayed | FR-007 |
| 6.4 | A control links to `${url.loginRestartFlowUrl}`; activating it returns to step 1 with the email field **editable** | FR-007, SC-004 |
| 6.5 | Forgot-password link points to `${url.loginResetCredentialsUrl}` | FR-008 |
| 6.6 | A wrong password keeps you on the theme's step 2 with a theme-rendered error, shown **once** | FR-015 |
| 6.7 | The correct password completes login and redirects | SC-001 |
| 6.8 | Submit is enabled by the password alone — the email is not re-entered anywhere | FR-009 |

For 6.2, the reason to check hidden inputs specifically: Keycloak populates `login.username` with the
submitted email on step 2, so `template.ftl`'s `usernameInput` already holds it. FR-012 is about the
rendered DOM, not the Vue state.

```javascript
// paste in the console on step 2
[...document.querySelectorAll('input')].map(i => `${i.type}/${i.name}`)
// expect only the password field (plus Keycloak's own hidden inputs, if any) — no username/email
```

## Part 7 — Story 4: four locales (SC-006)

**`?kc_locale=` does not work on the authorization endpoint.** Measured on 26.2.0: appending
`&kc_locale=ro` to `$AUTH` renders English, on that request and the next one in the same session. The
spec's Out of Scope note and SC-006 both prescribe it; as written it would sign Romanian off by testing
English.

Two methods that do work:

```bash
# First render — ui_locales is honoured on the authorization endpoint
for L in en pt-BR es ro; do echo "$AUTH&ui_locales=$L"; done
```

```javascript
// Any subsequent render — this is the URL Keycloak itself puts in the language selector
// Run in the console on the page you want to switch:
location.href = location.href.replace(/([?&])kc_locale=[^&]*/,'$1') + '&kc_locale=ro'
```

Setting the `KEYCLOAK_LOCALE=ro` cookie also works and survives navigation, which is the least
fiddly way to walk a whole flow in one locale.

Because `ro` is missing from `kc2UnnnicLanguages` in `template.ftl` — a pre-existing defect the spec
bounds out — Romanian cannot be reached through the language selector and must be reached by URL or
cookie.

For each of `en`, `pt-BR`, `es`, `ro`, on **both** steps:

| # | Check | Requirement |
| --- | --- | --- |
| 7.1 | No raw message key visible anywhere (`no such message` or a bare key like `loginPasswordTitle`) | SC-006 |
| 7.2 | No unexpected English string. Pay attention to the field labels, the password label, the forgot-password link, the restart control, and validation errors | FR-018, SC-006 |
| 7.3 | Trigger a validation error in each locale and confirm the message is localized | FR-015, FR-018 |
| 7.4 | In the DOM, step 1 has zero `input[type=password]` and step 2 has no username or email input. SC-002 asks for this **in all four locales**, not once — reuse the console snippet from Part 6 | SC-002 |
| 7.5 | Step 2's back control returns to an editable step 1. SC-004 asks for this **in every locale** | SC-004 |

Romanian is where this will fail if the FR-018 work is incomplete. Measured on the current theme, **10
of the 11** Keycloak-provided keys these screens surface resolve to English under `ro`, against zero for
`pt-BR` and `es`. Also check `pt-BR`'s show/hide toggle name specifically: base supplies it from
`messages_pt`, so without a local override it reads `Mostrar palavra-passe`, which is European
Portuguese.

Accessibility, per locale-independent SC-007:

| # | Check | Requirement |
| --- | --- | --- |
| 7.6 | Step 1 with Tab / Shift+Tab / Enter only: focus starts in the email field, then submit, each provider button, the sign-up control | FR-016 |
| 7.7 | Step 2 with the keyboard only: password field, toggle, submit, forgot-password, back control | FR-016 |
| 7.8 | With a screen reader running, each provider button is announced with its provider | FR-014, SC-007 |
| 7.9 | A **per-field** submission error on either step is announced without moving focus | FR-015, SC-007 |
| 7.10 | A **form-level** error is announced too. Check 7.9 does not exercise this: Decision 6 suppresses the disclaimer whenever a per-field error exists, so produce an error that arrives without one — lock the account with repeated wrong passwords to raise `accountTemporarilyDisabledMessage` | FR-015, SC-007 |

## Part 8 — Edge cases the spec calls out

| # | Scenario | How to produce it | Expected |
| --- | --- | --- | --- |
| 8.1 | Double submit (SC-008) | Click submit rapidly, or hold Enter, on both steps. Watch the Network panel | Exactly one POST; the control is disabled after the first |
| 8.2 | Autofilled password (SC-009) | Save the credential in the browser, revisit, let it fill step 2 without typing | Submit becomes enabled with zero keystrokes |
| 8.3 | `VTEXAppEmail` prefill (FR-012) | Load `$AUTH` with `redirect_uri=http%3A%2F%2Flocalhost%3A3000%2F%3Fvtex_app%3Demail%253Duser%2540example.com` | Step 1's email field prefilled and disabled, exactly as on `login.ftl` today. **Known limitation**: the post-submit URL carries no `redirect_uri`, so the prefill is lost when step 1 re-renders after a validation error. Pre-existing, identical on `login.ftl` |
| 8.4 | No providers enabled | `kc delete identity-provider/instances/github -r probe` and the other two | Step 1 renders the email field with no provider block and **no orphaned separator** |
| 8.5 | A fourth provider with no local icon | Add e.g. `gitlab` | Layout does not break and no broken image renders |
| 8.6 | Step 2 renders no providers | Reach step 2 with all three enabled | No provider block. Keycloak also narrows `social.providers` to zero here, so this must hold for both reasons |
| 8.7 | Expired / restarted flow | Reach step 2, wait out the session, submit | Returns to step 1, not to a stock page |
| 8.8 | Unknown `kc_idp_hint` | Append `&kc_idp_hint=nonexistent` to `$AUTH` | Step 1 plus Keycloak's generic message. No copy naming a customer or calling a link invalid (SC-010) |
| 8.9 | Registration disabled (FR-003, SC-003) | `kc update realms/probe -s registrationAllowed=false`, then load step 1 on `identity-first` and `login.ftl` on the default flow | **The same** provider surface on both. Today that means no separator, no provider buttons, and no sign-up block on either screen, because `login.ftl` puts all three inside one `realm.registrationAllowed` guard. A step 1 that still shows provider buttons here has split that guard apart and broken parity. Restore with `-s registrationAllowed=true` |

## Part 9 — Regression and packaging

1. **Re-run all of Part 3** with the flow switched back, and confirm it matches the "before" record:

```bash
kc update realms/probe -s browserFlow=browser
```

2. **Scope check (SC-011)** — the diff must touch nothing outside the theme's login directory and this
   feature's own spec directory.

   Compare against the **merge base**, not the index. `git diff` with no revision compares the working
   tree to the index, so it reports nothing the moment the work is staged or committed — and the
   workflow commits after every task, so written that way the gate passes without checking anything.

```bash
BASE=$(git merge-base HEAD origin/main)   # or whichever branch this was cut from

git diff --name-only "$BASE"...HEAD -- . \
  ':(exclude)themes/ilhasoft/login' \
  ':(exclude)specs/001-okta-login-theme'   # must be empty

git status --porcelain                     # nothing uncommitted outside those two paths
```

   `specs/001-okta-login-theme/` is excluded deliberately: the spec artifacts are the record of the
   change, not part of it, which is what NFR-004 now says.

3. **No new build step (FR-022)** — `theme.properties` gained no `scripts=` entry, and any new
   stylesheet has a `styles=` entry. The plan expects no `theme.properties` change at all.

4. **Locale parity (FR-017)** — every key the new templates reference exists in all four bundles:

```bash
cd themes/ilhasoft/login
grep -ohE "msg\('[^']+'\)|msg\(\"[^\"]+\"\)" login-username.ftl login-password.ftl \
  | sed -E "s/msg\\(['\"]//; s/['\"]\\)//" | sort -u > /tmp/keys.txt
for l in en pt_BR es ro; do
  missing=$(while read -r k; do grep -q "^$k=" "messages/messages_$l.properties" || echo "$k"; done < /tmp/keys.txt)
  echo "== $l: ${missing:-all present}"
done
```

A key absent from all four is fine only if base supplies it in every locale — which, per the FR-018
table in [research.md](./research.md), Romanian usually does not. When in doubt, declare it locally.

5. **26.3 validity (NFR-002)** — the release job builds into `bitnamilegacy/keycloak:26.3.2`, so the
   templates have to be valid there as well as on 26.2.0. NFR-002 is a MUST and the image is public,
   so this does not wait for a container to happen to be available. Bring one up alongside:

```bash
docker run -d --name kc263 --network keycloak -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v "$PWD/themes/ilhasoft:/opt/keycloak/themes/ilhasoft" \
  quay.io/keycloak/keycloak:26.3.2 start-dev \
  --spi-theme-cache-themes=false --spi-theme-cache-templates=false
```

   Rebuild the probe realm and the flow (Parts 2 and 4) against port 8081, then walk Parts 5 and 6. A
   FreeMarker incompatibility surfaces as an HTTP 500 on first render, so it fails loudly rather than
   subtly. Tear down with `docker rm -f kc263`.

## Teardown

```bash
docker compose down -v
```

The probe realm lives in the dev-mode H2 database inside the container, so `down -v` removes it. Keep
the container up between edits — caching is disabled, so template and message changes need only a page
reload.
