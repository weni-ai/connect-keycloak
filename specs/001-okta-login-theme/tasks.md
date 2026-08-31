---

description: "Task list for the identity-first login theme (Enterprise Okta)"
---

# Tasks: Identity-first login theme (Enterprise Okta)

**Input**: Design documents from `/specs/001-okta-login-theme/`

**Prerequisites**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/README.md](./contracts/README.md), [quickstart.md](./quickstart.md)

**Tests**: There are **no automated tests in this delivery**. This repository has no test framework and
none is added (plan.md, Technical Context). NFR-001 replaces automated testing with manual verification
against `docker-compose.yml` (`quay.io/keycloak/keycloak:26.2.0`, theme and template caching off). Every
verification task below cites a part of [quickstart.md](./quickstart.md) rather than a test command. No
`tests/` tree, no contract tests (contracts/README.md: there is no API surface), no data-model tasks
(data-model.md: there is no data model).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel — different files, no dependency on an incomplete task
- **[Story]**: Which user story the task belongs to (US1, US2, US3, US4)
- Every task names the exact file it touches, or the quickstart part it executes

## Path Conventions

There is no `src/` and no `tests/` in this repository. The unit of work is the Keycloak theme
directory `themes/ilhasoft/login/`. Every path a task may touch:

```text
themes/ilhasoft/login/
├── template.ftl                       # CHANGED  — macro flags, per-step submit state, autofill
│                                      #            reconciliation, re-gated login-only regions,
│                                      #            disclaimer role
├── login-username.ftl                 # NEW      — step 1 (FR-001…FR-005)
├── login-password.ftl                 # NEW      — step 2 (FR-006…FR-008)
├── messages/messages_en.properties    # CHANGED  — Crowdin source
├── messages/messages_pt_BR.properties # CHANGED
├── messages/messages_es.properties    # CHANGED
├── messages/messages_ro.properties    # CHANGED  — the only locale with a real gap
└── resources/css/login.css            # CHANGED  — step-1 and step-2 layout rules only
```

**Out of bounds under NFR-004 / FR-013** — no task may edit these, and three tasks below exist only to
verify they are unchanged: `login.ftl`, `login-form.ftl`, `login-config-totp.ftl`,
`login-idp-link-confirm.ftl`, `login-otp.ftl`, `login-reset-password.ftl`, `login-update-password.ftl`,
`login-verify-email.ftl`, `register.ftl`, `theme.properties`, `resources/img/`,
`keycloak-user-migration/`, `docker-compose.yml`, `Dockerfile`, `crowdin.yml`, `standalone.xml`,
`.github/workflows/`, and the `account` / `admin` / `email` / `common` theme types.

---

## Phase 1: Setup (Runtime and baseline)

**Purpose**: This is an existing theme, so there is nothing to scaffold. Setup means standing up the
Compose runtime, building the probe realm both flows need, and capturing the Story 3 "before" record
**before any file is edited**, so a regression is attributable.

- [ ] T001 Bring up the runtime per [quickstart.md](./quickstart.md) Part 1: `docker network create keycloak`, `docker compose up -d`, wait for "Keycloak 26.2.0 on JVM ... started", and confirm `docker-compose.yml` mounts `./themes/ilhasoft/` with theme and template caching off so edits are picked up on page reload. Ignore the two `KEYCLOAK_ADMIN` deprecation warnings — changing them is outside NFR-004
- [ ] T002 Create the probe realm, client, user, and the three identity providers per [quickstart.md](./quickstart.md) Part 2 (`loginTheme=ilhasoft`, `internationalizationEnabled=true`, `supportedLocales=["en","pt-BR","es","ro"]`, `registrationEmailAsUsername=true`, `resetPasswordAllowed=true`, plus `github` / `google` / `microsoft`). Use `kc update realms/probe -s key=value` for any later change — a partial `PUT` silently wipes `internationalizationEnabled` and `supportedLocales`
- [ ] T003 Record the Story 3 "before" state by walking [quickstart.md](./quickstart.md) Part 3 on the **default** browser flow with the working tree unmodified: combined `login.ftl` screen, successful login, registration, reset password, update password, OTP setup, verify email, and a clean DevTools console on each. Save this record — T034 compares against it for SC-005
- [ ] T004 Create and bind the `identity-first` browser flow per [quickstart.md](./quickstart.md) Part 4 (`auth-cookie` ALTERNATIVE / `if-forms` ALTERNATIVE → `auth-username-form` REQUIRED → `if-password` REQUIRED → `auth-password-form` REQUIRED), then confirm the execution tree matches the expected `lvl0/lvl1/lvl2` listing and re-check that `internationalizationEnabled` and `supportedLocales` survived the `browserFlow` update

**Checkpoint**: A container is running with the theme mounted, a realm can be switched between the
default and identity-first flows, and the pre-change behavior of every existing screen is on record.

---

## Phase 2: Foundational (Blocking prerequisites)

**Purpose**: `template.ftl` and the four message bundles. Nothing in US1 or US2 can render without
these. Beyond adding state, this phase also **widens guards that already exist**: three regions of
`template.ftl` are gated on `displayLoginFormScriptsAndStyles`, a flag only `login.ftl` passes, and
two of them are things the new steps need (research.md Correction 3).

**⚠️ CRITICAL ordering constraint (research.md Decision 2)**: passing a macro argument
`registrationLayout` does not declare is a **hard HTTP 500**, not a no-op:

```text
freemarker.core._MiscTemplateException: Macro "registrationLayout" has no parameter with name
"displayLoginFormScriptsAndStyles". Valid parameter names are: bodyClass, displayInfo,
displayMessage, displayRequiredFields
```

Read that for the failure mode, not for the parameter list: it was reproduced against **base's**
`registrationLayout` in the Phase 0 probe theme. This theme's signature on line 1 of `template.ftl` is
wider — `bodyClass, displayInfo, displayMessage, displayHeader, displayRegisterScriptsAndStyles,
displayLoginFormScriptsAndStyles, displaySocial` — and has no `displayRequiredFields`. It is the one
T005 extends.

T005 therefore **MUST** land before T014 and T024. Adding a parameter *with a default* is backward
compatible for the eight existing callers, which is why they need no edit.

**⚠️ Three quieter ordering constraints.** Unlike T005, these fail *silently*, which makes them worse
to debug: T006 before T016 and T026 (an undefined `submitting` breaks the `@submit` handler), T007
before T018 and T028 (an undefined computed property leaves submit permanently disabled), and T008a
before T026 (step 2's show/hide toggle renders but does nothing).

- [ ] T005 Add two macro parameters with `false` defaults to the `registrationLayout` signature on line 1 of `themes/ilhasoft/login/template.ftl`, named **exactly** `displayUsernameFormScriptsAndStyles=false` (step-1 state) and `displayPasswordFormScriptsAndStyles=false` (step-2 state), following the existing `display*ScriptsAndStyles` style. These two names are **normative, not illustrative** — T014 and T024 pass these literal strings, and any divergence between the declaration here and the call there is the HTTP 500 this task exists to prevent. Defaults are mandatory: the eight existing callers (`login.ftl`, `register.ftl`, `login-otp.ftl`, `login-config-totp.ftl`, `login-reset-password.ftl`, `login-update-password.ftl`, `login-verify-email.ftl`, `login-idp-link-confirm.ftl`) must keep working untouched under FR-013. **BLOCKS T014 and T024**
- [ ] T006 Add a `submitting: false` data property to the Vue `data()` return in `themes/ilhasoft/login/template.ftl` (around line 152–203) for FR-011 / SC-008. It is inert on every existing screen because nothing else references it; the new templates flip it from the form's `@submit`. Mirrors base's `onsubmit="login.disabled = true"` without needing base's `name="login"` global, which `unnnic-button` does not emit
- [ ] T007 Add `canSubmitUsername` and `canSubmitPassword` computed properties to `themes/ilhasoft/login/template.ftl` (computed block, around line 206–251), each inside a `<#if>` on its own new flag from T005. `canSubmitUsername` reproduces only the username half of `canLogin` (`isEmailValid(usernameInput)` when `realm.registrationEmailAsUsername`, otherwise non-empty trimmed); `canSubmitPassword` depends only on `passwordInput`. **Leave `canLogin` on line 228–231 exactly as it is** — FR-009 requires it to keep its present behavior for `login-form.ftl`, and step 2 must not reuse it because `template.ftl` seeds `usernameInput` from `login.username`, which Keycloak populates with the submitted email on step 2 (measured)
- [ ] T008 Add autofill DOM reconciliation to `mounted()` in `themes/ilhasoft/login/template.ftl` (around line 269–343), gated on the T005 flags, for FR-010 / SC-009. Copy the inner `<input>`'s `.value` (reached via `$refs.<ref>.$el.querySelector('input')`) into `usernameInput` / `passwordInput` after mount, on `input`, and on `change`, with a short bounded retry over the first few frames for password managers that write the field before scripts settle. The existing `onAutoFillStart` / `animationstart` hook on line 310–326 may stay as one extra trigger for the same reconciliation but MUST NOT be the sole path: it currently only calls `console.log`, and UNNNIC applies `input-itself` to an inner `base-input` component rather than to the real `<input>` that `:autofill` can match
- [ ] T008a Widen the guard around `loginPasswordVisible` in the `data()` return of `themes/ilhasoft/login/template.ftl` (lines 197–202) so it is declared under the step-2 flag as well as `displayLoginFormScriptsAndStyles`. Without this, step 2's show/hide toggle is broken in a way that raises no error: `toggleLoginPasswordVisibility` is defined **ungated** on line 380, so it would flip a property Vue never declared, and the icon would never change. FR-006 requires the toggle and quickstart 6.1 asserts it works. Widen **only** `loginPasswordVisible` — `loginUsername`, `loginPassword`, and `rememberMe` stay where they are, and `rememberMe` reaching step 1 would contradict FR-001's ban on a remember-me control. **BLOCKS T026**
- [ ] T008b Widen the guard around `emitConnectEvent` and the `connect:requestlogout` `postMessage` in `mounted()` of `themes/ilhasoft/login/template.ftl` (lines 328–341) so it also fires under the step-1 flag, per FR-023. Step 1 replaces `login.ftl` as the first screen on an identity-first realm, and the emission is currently gated on `displayLoginFormScriptsAndStyles`, which only `login.ftl` passes — so without this the Connect web app silently stops receiving the message for every user on a migrated realm. contracts/README.md names this as the one outbound contract the change must not disturb. Step 2 does **not** get it: `login.ftl` emits it once per login screen and step 1 is that screen. **Verified by quickstart check 5.10, not by Part 3** — Part 3 runs on the default flow where `login.ftl` still passes the old flag, so it would report a clean pass over a live regression
- [ ] T008c Add `role="alert"` to the form-level `unnnic-disclaimer` in `themes/ilhasoft/login/template.ftl` (lines 97–101) for the second half of FR-015. T017 and T027 cover the per-field half; this covers the form-level one, and the two do not overlap — Decision 6 suppresses the disclaimer on exactly the renders where a per-field error exists, so the errors that reach the disclaimer (`invalidUserMessage`, `accountTemporarilyDisabledMessage`, expired-flow messages) arrive with no per-field error beside them. The disclaimer is shared with the eight screens FR-013 freezes, so this improves announcement there too; spec.md FR-015 now records that as accepted rather than incidental, because it drops nothing Keycloak requires. Verified by quickstart 7.10
- [ ] T009 Review the `themes/ilhasoft/login/template.ftl` diff for two contract hazards from contracts/README.md before moving on: any `url.*` reference newly added to the shared template must be written defensively as `${(url.x)!''}` (referencing `url.loginAction` on `error.ftl` returns HTTP 500), and the `connect:requestlogout` `postMessage` on lines 328–341 plus the per-realm Flows logout iframe on lines 426–443 must keep working — T008b widens the `postMessage`'s guard and must not otherwise alter it or the iframe. Then reload all eight existing callers in the container and confirm each still renders HTTP 200 with a clean console
- [ ] T010 Add the two new keys and the 14 re-declared keys — 13 rows in research.md Decision 4's table, because `showPassword` / `hidePassword` share one — to `themes/ilhasoft/login/messages/messages_en.properties` — this is the Crowdin source and holds the authoritative wording (FR-017). New: `loginPasswordTitle=Enter password`, `doChangeEmail=Change email`. Re-declared verbatim from base's English (research.md Decision 4): `username`, `usernameOrEmail`, `email`, `password`, `doForgotPassword`, `restartLoginTooltip`, `showPassword`, `hidePassword`, `invalidUsernameOrEmailMessage`, `missingUsernameMessage`, `invalidPasswordMessage`, `missingPasswordMessage`, `invalidUserMessage`, `accountTemporarilyDisabledMessage`. None of the 16 exists in this theme's bundles today — all currently resolve from `parent=base`, which was re-confirmed against the four bundles in the working tree. Do **not** reword base's English (including its "please"), because these bundles are shared with `login.ftl` and every other screen that FR-013 freezes
- [ ] T011 [P] Add the same key set to `themes/ilhasoft/login/messages/messages_pt_BR.properties` (FR-017 — all four bundles in the same change). Copy base's existing `pt_BR` wording verbatim for the re-declared keys, with **one deliberate exception**: `showPassword` / `hidePassword`, which base leaves to `messages_pt` and therefore resolves as European Portuguese (`Mostrar palavra-passe`) — write Brazilian wording there, because the inherited string is wrong rather than merely unfashionable. New keys: `loginPasswordTitle=Inserir senha`, `doChangeEmail=Alterar e-mail`
- [ ] T012 [P] Add the same key set to `themes/ilhasoft/login/messages/messages_es.properties` (FR-017). Copy base's existing `es` wording verbatim for the re-declared keys — `es` leaks no English today, so this is functionally a no-op that removes the dependency on base's per-locale completeness across the 26.2 → 26.3 range the release job spans (NFR-002). New keys: `loginPasswordTitle=Ingresar contraseña`, `doChangeEmail=Cambiar email`
- [ ] T013 [P] Add the same key set to `themes/ilhasoft/login/messages/messages_ro.properties` (FR-017). **This is the only locale with a functional gap**: base's `messages_ro.properties` holds 34 keys against English's 468, and 10 of the 11 keys these screens surface resolve to English under `ro` (`doForgotPassword` is the single one base translates). These are genuinely new strings and must follow the VTEX Content Guide per FR-019 — sentence case, no "please", no interjection, no exclamation mark, no pronoun in labels or titles, action labels of at most three words, lowercase after a colon. New keys: `loginPasswordTitle=Introdu parola`, `doChangeEmail=Schimbă e-mailul`

**Checkpoint**: `registrationLayout` accepts the two new flags, `canSubmitUsername` /
`canSubmitPassword` / `submitting` exist, `canLogin` is unchanged, `loginPasswordVisible` and the
`connect:requestlogout` emission are reachable from the steps that need them, the disclaimer announces,
all four bundles carry the same key set, and every existing screen still renders. US1 and US2 can now
be built.

---

## Phase 3: User Story 1 — Step 1 renders email only, with the three third-party actions intact (Priority: P1) 🎯 MVP

**Goal**: A branded first step with one email field and the same GitHub, Google, and Microsoft buttons
that exist today, in the same position and appearance, with no password field anywhere in the DOM.
Submitting hands control back to Keycloak.

**Independent Test**: [quickstart.md](./quickstart.md) **Part 5** (checks 5.1–5.11) on the probe realm
bound to `identity-first`, plus **Part 8** rows 8.3, 8.4, 8.5, 8.8, and 8.9. No test command exists — this is
a browser walkthrough in the Compose container per NFR-001.

**Design decisions carried in, not reopened**: the provider block lives in the `info` section with
`displayInfo=true` and `template.ftl` does **not** learn to nest `socialProviders` (Decision 1); step 1
guards on `!usernameHidden??` and `!registrationDisabled??`, **never** `usernameEditDisabled` (Decision
3, which measured that the string exists in no jar in 26.2); `displayMessage=!messagesPerField.existsError('username')`
(Decision 6).

- [ ] T014 [US1] Create `themes/ilhasoft/login/login-username.ftl` with `<#import "template.ftl" as layout>` and the macro call `<@layout.registrationLayout displayInfo=true displayMessage=!messagesPerField.existsError('username') displayUsernameFormScriptsAndStyles=true; section>`, plus empty `title` / `header` / `form` / `info` branches. Pass `displayInfo=true` literally — do **not** copy `login.ftl`'s `displayInfo=social.displayInfo`, which is a dead expression: `IdentityProviderBean` in 26.2 has no `displayInfo` property, so it has always resolved to the macro's declared default. `displayMessage=!messagesPerField.existsError('username')` is load-bearing: on a validation error Keycloak populates `message` **and** `messagesPerField` with the same sentence, and `template.ftl` renders the form-level `unnnic-disclaimer` on `displayMessage && message?has_content`, so without it the user sees the sentence twice (FR-015). **Depends on T005**
- [ ] T015 [US1] Fill the `title` and `header` sections of `themes/ilhasoft/login/login-username.ftl` with `${msg("loginTitle",(realm.displayName!''))}` and `${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}`, matching `login.ftl` lines 4–7, and render `${msg("loginFormTitle")}` as the card heading in the `form` section — already present in all four bundles, so no new copy (FR-002)
- [ ] T016 [US1] Add the step-1 form to the `form` section of `themes/ilhasoft/login/login-username.ftl`: `<form>` posting `method="post"` to `${url.loginAction}` with `@submit="submitting = true"`, wrapping the email field in `<#if !usernameHidden??>`. Reuse `login-form.ftl` lines 5–10 for the field — the same `unnnic-form-element` label conditional (`username` / `usernameOrEmail` / `email`), the same placeholder conditional (`placeholderLoginEmail` / `placeholderLoginName`), `name="username"`, `autocomplete` conditional on `realm.registrationEmailAsUsername`, `autofocus`, `v-model="usernameInput"`, `ref="loginUsername"`, and `@input="usernameInput = sanitizeHtml(usernameInput)"`. Declare `:disabled="!!VTEXAppEmail"` **once** — do not reproduce `login-form.ftl` line 9's duplicate `:disabled="<#if usernameEditDisabled??>…"`, which is inert dead markup. FR-001 forbids a password input, a forgot-password link, and a `rememberMe` control on this step. FR-002 forbids introducing a new placeholder string
- [ ] T017 [US1] Render Keycloak's per-field `username` error in `themes/ilhasoft/login/login-username.ftl` inside a region announced to assistive technology without a focus move — `role="alert"` or `aria-live="polite"` — driven by `messagesPerField.existsError('username')` / `messagesPerField.get('username')`, and mark the input's error state the way `login-reset-password.ftl` line 23 already does with `messagesPerField.printIfExists`. This is the per-field half of FR-015; the form-level `unnnic-disclaimer` is suppressed on the same render by T014's `displayMessage`
- [ ] T018 [US1] Add the submit control to `themes/ilhasoft/login/login-username.ftl`: `unnnic-button` with `text="${msg('doLogIn')}"`, `type="primary"`, `native-type="submit"` declared **explicitly** (matching `login-reset-password.ftl` line 34 rather than relying on `unnnic-button`'s `nativeType` defaulting to `""` and falling through HTML's missing-value default), and `:disabled="submitting || !canSubmitUsername"`. FR-009 — enablement depends on the email alone; FR-011 / SC-008 — exactly one POST per activation
- [ ] T019 [US1] Add the third-party provider block to the `info` section of `themes/ilhasoft/login/login-username.ftl`, reproducing `login.ftl` lines 14–34 with the same element ids (`zocial-${p.alias}`), class (`social-button`), `type="secondary"`, `size="large"`, `@click.prevent="navigateTo('${p.loginUrl}')"`, icon path `${url.resourcesPath}/img/login/icon-${p.alias}.svg`, `icon-image` class, and `social.providers` ordering — SC-003 requires byte-identical parity in ids, classes, icon paths, and ordering. Reproduce the **enclosing conditions** too, which is the part that is easy to get wrong: in `login.ftl` a single `<#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>` opens on line 13 and closes on line 43, so it wraps the separator, the provider list, **and** the sign-up block, while the footer sits outside it; the separator additionally carries `v-if="!VTEXAppEmail"`. Keep `realm.password && realm.registrationAllowed`, keep the separator's `v-if`, and substitute `!registrationDisabled??` for the dead third term (Decision 3). Splitting these three regions into independent guards would un-gate the providers on a registration-disabled realm and break FR-003 parity — invisibly, since the probe realm sets `registrationAllowed=true`; quickstart 8.9 is the check that catches it. FR-003 permits exactly **two** additions and no others: FR-014's accessible name, composed as `${msg('loginWith')} ${p.displayName!p.alias}` (`loginWith` already exists in all four bundles, so this costs no new copy), and a guard on the `separator-group` so a realm with no enabled providers renders **no orphaned separator** (edge case 8.4). Iterate `social.providers` only — never hardcode, add, remove, or filter a provider, and never emit an Okta entry (FR-004, PS-BD-001). `social.providers` is measured at 3 on step 1
- [ ] T020 [US1] Add the sign-up block and privacy footer to the `info` section of `themes/ilhasoft/login/login-username.ftl`, reproducing `login.ftl` lines 35–48: the sign-up block (35–42) sits **inside** the same guard as the provider block from T019 and carries `v-if="!VTEXAppEmail"`, while the privacy footer (44–48) sits **outside** it and always renders. Do not collapse the two into one conditional — that is the mirror image of the T019 mistake and would hide the footer on a registration-disabled realm. Keys `signUpForFree` / `doRegisterForFree` / `termsOfService`, and `properties.urlPrivacyPolicy`. Substitute `!registrationDisabled??` for `login.ftl`'s `!usernameEditDisabled??` — the latter exists in no jar in 26.2 and is a permanently-true dead guard; `registrationDisabled` is the attribute Keycloak actually sets, alongside `usernameHidden`, and is equal to today's behavior in every case the flow reaches (FR-005, Decision 3)
- [ ] T021 [US1] Add step-1 layout rules to `themes/ilhasoft/login/resources/css/login.css`. This file is already listed in `styles=` in `theme.properties`, so **no `theme.properties` change is needed and none may be made** — FR-021's "a new stylesheet requires a `styles=` entry" is never triggered, and FR-022 forbids a new build step. **Scope every new selector to step 1.** `login.css` is loaded on every screen in this theme, so an unscoped rule is the one way a CSS task can regress the screens FR-013 freezes; prefix under a step-1 root or a class the new template alone emits, and add no bare element or shared-class rule. Cover the 254-character email without the card overflowing (quickstart check 5.8), and a provider row that does not break layout when a realm enables a fourth provider with no local icon
- [ ] T022 [US1] Verify step 1 in the container against [quickstart.md](./quickstart.md) **Part 5**, checks 5.1–5.11: theme's own screen with no stock Keycloak styling (SC-001); `document.querySelectorAll('input[type=password]').length === 0` and no forgot-password link (SC-002); three provider buttons diffed against the baseline with `curl -s "$AUTH" | grep -A4 'id="zocial-'` versus `login.ftl` lines 19–34, one permitted difference (SC-003); each button's accessible name in the accessibility tree (FR-014); provider click going straight to `loginUrl` without reading the email field; submit disabled empty and enabled on a valid email with no password field in existence (FR-009); an invalid submit showing a theme-rendered message **once, not twice** (FR-015); the 254-character email not overflowing; exactly one POST to `${url.loginAction}` with field name `username` on Enter; the `connect:requestlogout` `postMessage` firing exactly once on load as it does on `login.ftl`, using the listener snippet in Part 5 (FR-023, SC-012 — this is the **only** check that covers T008b, since Part 3 runs on the default flow where the old flag still applies); and no theme-originated request in the Network panel that blocks the email field from accepting input (NFR-005)
- [ ] T023 [US1] Verify the step-1 edge cases in [quickstart.md](./quickstart.md) **Part 8**: 8.1 double submit produces exactly one POST with the control disabled after the first (SC-008); 8.3 the `VTEXAppEmail` prefill disables the field on the **first** render exactly as on `login.ftl` today — the post-submit URL carries no `redirect_uri`, so the prefill is lost on a re-render after a validation error, which is pre-existing, identical on `login.ftl`, and recorded rather than fixed; 8.4 no providers enabled renders the email field with no provider block and no orphaned separator; 8.5 a fourth provider does not break layout or render a broken image; 8.8 an unknown `kc_idp_hint` falls through to step 1 with Keycloak's generic message and **no copy naming a customer, naming a customer's identity provider, or calling a link invalid** (FR-020, SC-010); and 8.9 with `registrationAllowed=false`, step 1 and `login.ftl` render the **same** provider surface — today that means neither shows the separator, the provider buttons, or the sign-up block, because `login.ftl` puts all three inside one `realm.registrationAllowed` guard. Step 1 still showing buttons here means T019 split that guard apart (FR-003, SC-003)

**Checkpoint**: Step 1 is fully functional and independently verifiable. **This plus Phase 1 and Phase
2 is the MVP** — the screen every user sees, on a realm switched to identity-first.

---

## Phase 4: User Story 2 — Step 2 asks for the password only, and the user can go back (Priority: P1)

**Goal**: A branded second step asking only for the password, showing which email is being
authenticated, keeping the forgot-password link, and offering a way back to step 1 so a typo is
recoverable.

**Independent Test**: [quickstart.md](./quickstart.md) **Part 6** (checks 6.1–6.8) after submitting
`user@example.com` on step 1, plus **Part 8** rows 8.1, 8.2, 8.6, and 8.7.

**Design decisions carried in, not reopened**: FR-007 uses `auth.attemptedUsername` and
`url.loginRestartFlowUrl` behind `auth?has_content && auth.showUsername()` (Decision 5 — confirmed by
running the flow, and unguarded access throws where no user is established, including step 1);
`displayMessage=!messagesPerField.existsError('password')` (Decision 6); `social.providers` is measured
at **0** on step 2, because `IdentityProviderBean` narrows the list to the authenticated user's linked
brokers, so step 2 needs no filter but must still emit no orphaned separator or heading.

- [ ] T024 [US2] Create `themes/ilhasoft/login/login-password.ftl` with `<#import "template.ftl" as layout>` and the macro call `<@layout.registrationLayout displayInfo=false displayMessage=!messagesPerField.existsError('password') displayPasswordFormScriptsAndStyles=true; section>`, plus `title` / `header` / `form` branches. `displayInfo=false` is what keeps FR-006's "no third-party provider block" structural rather than conditional. **Depends on T005**
- [ ] T025 [US2] Fill the `title` and `header` sections of `themes/ilhasoft/login/login-password.ftl` and render `${msg("loginPasswordTitle")}` as the card heading — the new key added in T010–T013. It deliberately avoids the pronoun in the existing `loginFormTitle` ("Log in to your account") rather than copying it (FR-019)
- [ ] T026 [US2] Add the step-2 form to `themes/ilhasoft/login/login-password.ftl`: `<form>` posting `method="post"` to `${url.loginAction}` with `@submit="submitting = true"`, containing exactly one credential input — the password field, reusing `login-form.ftl` lines 12–25 for `name="password"`, `autocomplete="current-password"`, `placeholder="${msg('placeholderLoginPassword')}"`, `v-model="passwordInput"`, `ref="password"`, the `visibility` / `visibility_off` show/hide toggle bound to `toggleLoginPasswordVisibility`, and `autofocus` on the password field for FR-016. **Depends on T008a**: `loginPasswordVisible` is declared today only under `displayLoginFormScriptsAndStyles`, so without that task the toggle renders, raises no error, and does nothing. Add an `aria-label` to the toggle from the newly declared `showPassword` / `hidePassword` keys — step 2's toggle is therefore more accessible than `login-form.ftl`'s, which does not get one because FR-014 names only the provider buttons and NFR-004 bounds the diff. **Render no email or username input of any kind, visible or hidden** (FR-006, FR-012): `template.ftl`'s `usernameInput` already holds the submitted email because Keycloak populates `login.username` on step 2, so this is a constraint on the emitted DOM, not on the Vue state
- [ ] T027 [US2] Render Keycloak's per-field `password` error in `themes/ilhasoft/login/login-password.ftl` inside a region announced to assistive technology without a focus move (`role="alert"` or `aria-live="polite"`), driven by `messagesPerField.existsError('password')` / `messagesPerField.get('password')`, mirroring T017. FR-015
- [ ] T028 [US2] Add the submit control to `themes/ilhasoft/login/login-password.ftl`: `unnnic-button` with `text="${msg('doLogIn')}"`, `type="primary"`, `native-type="submit"` declared explicitly, and `:disabled="submitting || !canSubmitPassword"`. FR-009 — enablement depends on the password alone, which is why `canLogin` cannot gate this step
- [ ] T029 [US2] Add the attempted-username display and the back control to `themes/ilhasoft/login/login-password.ftl`, both inside `<#if auth?has_content && auth.showUsername()>`: render `${auth.attemptedUsername}` and a plain link to `${url.loginRestartFlowUrl}` labelled with the new `doChangeEmail` key. The guard is mandatory — `AuthenticationContextBean.showUsername()` is `true` only when the flow context, user, and authentication session are all present and the page is not `ERROR`, and `getAttemptedUsername()` returns `null` without it, so an unguarded read throws. `showResetCredentials()` is only true on the reset-password page, so step 2 does not need that part of base's condition. A plain link suffices because `url.loginRestartFlowUrl` needs no hidden form (FR-007)
- [ ] T030 [US2] Add the forgot-password link to `themes/ilhasoft/login/login-password.ftl` behind `<#if realm.resetPasswordAllowed>`, pointing at `${url.loginResetCredentialsUrl}` with `${msg("doForgotPassword")}`, matching `login-form.ftl` lines 46–49. FR-008
- [ ] T031 [US2] Add step-2 layout rules to `themes/ilhasoft/login/resources/css/login.css` for the password card, the attempted-username line, and the back control. Same two constraints as T021 — the file is already in `styles=`, so `theme.properties` stays unchanged (FR-021, FR-022), and every selector is scoped to step 2 so nothing leaks onto the screens FR-013 freezes. Sequential after T021, same file
- [ ] T032 [US2] Verify step 2 in the container against [quickstart.md](./quickstart.md) **Part 6**, checks 6.1–6.8: theme's own password screen with a working show/hide toggle; the Part 6 console snippet that lists every `input`'s type and name yielding only the password field, with no username or email input and no hidden duplicate (FR-012, SC-002); the submitted email displayed (FR-007); the back control linking to `${url.loginRestartFlowUrl}` and returning to step 1 with the email field **editable** (SC-004); the forgot-password link pointing at `${url.loginResetCredentialsUrl}`; a wrong password keeping the user on the theme's step 2 with a theme-rendered error shown **once**; the correct password completing login; and submit enabled by the password alone
- [ ] T033 [US2] Verify the step-2 edge cases in [quickstart.md](./quickstart.md) **Part 8**: 8.1 double submit produces exactly one POST (SC-008); 8.2 a browser-autofilled password enables submit with **zero keystrokes** — this is the release gate on T008's DOM reconciliation (SC-009); 8.6 no provider block renders, which must hold both because `displayInfo=false` and because Keycloak narrows `social.providers` to zero here; 8.7 an expired or restarted flow returns to step 1 rather than a stock Keycloak page

**Checkpoint**: Both identity-first steps work end to end. A user with an unmapped domain can log in
through two branded screens and recover from a typo.

---

## Phase 5: User Story 3 — Existing single-step login and the other login screens keep working (Priority: P1)

**Goal**: Realms not on identity-first keep rendering today's combined email-plus-password screen, and
registration, password reset, password update, OTP, email verification, and IdP link confirmation are
unchanged. Constitution Principle II makes silent divergence in any Keycloak flow a breaking change.

**Independent Test**: [quickstart.md](./quickstart.md) **Part 9** step 1 — switch back with
`kc update realms/probe -s browserFlow=browser` and re-run the whole of **Part 3**, comparing against
the "before" record captured in T003. SC-005 requires it to be identical.

- [ ] T034 [US3] Switch the probe realm back with `kc update realms/probe -s browserFlow=browser` and re-run the whole of [quickstart.md](./quickstart.md) **Part 3**, comparing every screen against the T003 record: the combined `login.ftl` screen with one email field, one password field with its show/hide toggle, three provider buttons, sign-up block, and privacy footer; a successful login; then registration, reset password, update password, OTP setup, and verify email. SC-005 requires the "after" to be identical to the "before". Pay particular attention to **layout**: the new `.ftl` files are never rendered by the default flow and cannot affect these screens, but `resources/css/login.css` and the four message bundles are shared with all of them, so shared CSS is the realistic way this fails. T021 and T031 are required to scope their selectors for exactly this reason
- [ ] T035 [US3] Confirm the DevTools console is clean on **every** screen in Part 3 — no new errors and no `Unnnic component not found` warnings. `template.ftl` is a changed file, so this is also the check that the `connect:requestlogout` `postMessage` and the per-realm Flows logout iframe on lines 426–443 still behave, which the spec's Assumptions freeze and contracts/README.md names as the one outbound contract this change must not disturb (Story 3 scenario 3)
- [ ] T036 [US3] Confirm `canLogin` still gates `login-form.ftl` with **both** values required, by checking in the container that the combined screen's submit button stays disabled with only an email and only a password. FR-009 requires `canLogin` to keep its present behavior; T007 must not have altered it
- [ ] T037 [US3] Confirm with `git diff --name-only "$(git merge-base HEAD origin/main)"...HEAD -- themes/ilhasoft/login` that no file outside `template.ftl`, `login-username.ftl`, `login-password.ftl`, `messages/messages_{en,pt_BR,es,ro}.properties`, and `resources/css/login.css` is modified — specifically that `login.ftl`, `login-form.ftl`, `login-config-totp.ftl`, `login-idp-link-confirm.ftl`, `login-otp.ftl`, `login-reset-password.ftl`, `login-update-password.ftl`, `login-verify-email.ftl`, `register.ftl`, `theme.properties`, and `resources/img/` are untouched (FR-013). **Diff against the merge base, not the index**: a bare `git diff` compares the working tree to the index and reports nothing once the work is committed, and this list instructs a commit after every task, so the plain form would pass without checking anything. This is the file-level companion to T044's repository-level scope check

**Checkpoint**: The delivery is safe to put on a realm that was not part of it. `weni`,
`weni-staging`, and `weni-develop` share this theme and their flows are switched by an operational
procedure outside this repository.

---

## Phase 6: User Story 4 — Copy, locales, and accessibility hold on both steps (Priority: P2)

**Goal**: Every string on both steps resolves in `en`, `pt_BR`, `es`, and `ro`, follows the VTEX
Content Guide, and both steps are completable with the keyboard alone with errors announced to
assistive technology.

**Verification** *(not independent — US1 and US2 must render first)*: [quickstart.md](./quickstart.md)
**Part 7** (checks 7.1–7.10) across all four locales on both steps, plus **Part 9** step 4's
locale-parity check. This is the one story of the four that cannot be verified on its own; US1 and US2
each can, and US3 needs only Phase 2 plus the two CSS tasks.

**⚠️ Do not use `?kc_locale=` on the authorization endpoint.** Measured on 26.2.0: appending
`&kc_locale=ro` to `$AUTH` renders **English**, on that request and the next in the same session, so
the method SC-006 originally prescribed would sign Romanian off by testing English. Use `ui_locales`
for the first render, the `kc_locale` parameter on the `/login-actions/authenticate` URL that Keycloak
itself puts in `locale.supported[].url` for any subsequent render, or a `KEYCLOAK_LOCALE` cookie —
which is the least fiddly way to walk a whole flow in one locale. `ro` cannot be reached through the
language selector at all, because it is missing from `kc2UnnnicLanguages` in `template.ftl` — a
pre-existing defect the spec bounds out under Constitution VI and which this delivery does **not** fix.

- [ ] T038 [US4] Re-bind `identity-first`, then walk both steps in `en`, `pt-BR`, `es`, and `ro` per [quickstart.md](./quickstart.md) **Part 7**, checks 7.1–7.5: no raw message key visible anywhere (no `no such message`, no bare `loginPasswordTitle`); no unexpected English string, paying particular attention to the field labels, the password label, the forgot-password link, the restart control, and validation errors; a validation error triggered in each locale rendering localized; and the two checks whose success criteria carry a per-locale qualifier that a single English pass does not satisfy — 7.4, the DOM assertion SC-002 requires "in all four locales", and 7.5, the back-control round trip SC-004 requires "in every locale". Romanian is where this fails if the T013 work is incomplete — 10 of the 11 Keycloak-provided keys these screens surface resolve to English under `ro` on the unmodified theme (SC-006, FR-018)
- [ ] T039 [US4] Check `pt-BR`'s show/hide toggle name specifically on step 2: without the T011 override it reads `Mostrar palavra-passe`, inherited from base's `messages_pt` through the `pt-BR → pt → en` chain, which is European Portuguese. A key can be "not English" and still wrong, so this needs its own look rather than folding into T038's English scan
- [ ] T040 [US4] Complete both steps with the keyboard alone per [quickstart.md](./quickstart.md) **Part 7**, checks 7.6–7.7: on step 1, focus starts in the email field and Tab reaches submit, each provider button, and the sign-up control; on step 2, the password field, the toggle, submit, forgot-password, and the back control, all reachable with Tab / Shift+Tab / Enter only (FR-016, SC-007)
- [ ] T041 [US4] Verify announcements with a screen reader running per [quickstart.md](./quickstart.md) **Part 7**, checks 7.8–7.10: each provider button is announced with its provider, e.g. "Login with github" (FR-014); a **per-field** submission error on either step is announced without the user moving focus; and a **form-level** error is announced too (FR-015). The last one needs producing deliberately — Decision 6 suppresses the disclaimer on exactly the renders that carry a per-field error, so 7.9 never exercises it; lock the account with repeated wrong passwords to raise `accountTemporarilyDisabledMessage`. If any fails, the fix belongs in T017 / T019 / T027 / T008c, not in a new file
- [ ] T042 [US4] Run the locale-parity check from [quickstart.md](./quickstart.md) **Part 9** step 4 — extract every `msg('…')` key from `login-username.ftl` and `login-password.ftl` and confirm each exists in all four `messages/messages_*.properties` files. A key absent from all four is acceptable only if base supplies it in every locale, which per the FR-018 table in [research.md](./research.md) Romanian usually does not; when in doubt, declare it locally (SC-006, FR-017)

**Checkpoint**: All four user stories are independently verifiable. A locale gap now blocks the
release rather than the development of stories 1–3, which is why this story is P2.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T043 Walk [quickstart.md](./quickstart.md) end to end in one sitting, Parts 1 through 9, on a clean container, and record the result as the NFR-001 verification evidence. Reading the diff is not verification and neither is "it looks right in the editor" — the review gate is the primary control here, because no automated UI suite exists in this repository (Constitution VI)
- [ ] T044 Run the SC-011 scope check from [quickstart.md](./quickstart.md) **Part 9** step 2. Two commands with different jobs: `git diff --name-only "$BASE"...HEAD` excluding `themes/ilhasoft/login` and `specs/001-okta-login-theme` **must return nothing**, and `git status --porcelain` must show nothing uncommitted outside those two paths — it will not be empty in general, since it also lists the theme work, which is the point of running it. Diff against the merge base rather than the index, or committing the work makes the gate pass vacuously. NFR-004 confines the diff to `themes/ilhasoft/login/` plus this feature's own spec directory, and NFR-003 keeps `keycloak-user-migration/` untouched
- [ ] T045 Confirm the no-new-build-step requirement from [quickstart.md](./quickstart.md) **Part 9** step 3: `themes/ilhasoft/login/theme.properties` gained no `scripts=` entry and, in fact, **should show no diff at all** — the plan expects zero `theme.properties` change because both new stylesheet blocks live in `resources/css/login.css`, which is already listed in `styles=`. `themes.tar.xz` therefore remains a complete artifact (FR-021, FR-022)
- [ ] T046 Confirm at review that the three pre-existing defects [research.md](./research.md) names were **not** opportunistically fixed: the dead `!usernameEditDisabled??` guards in `login.ftl` line 13 and `login-form.ftl` line 37, the duplicate `:disabled` attribute on `login-form.ftl` lines 7 and 9, and `displayInfo=social.displayInfo` in `login.ftl` line 3 resolving against a property `IdentityProviderBean` does not expose. All three are tempting one-line fixes in files the diff sits beside; FR-013 freezes them and Constitution VI bounds the scope. They are recorded so the new templates do not copy the pattern and so a reviewer does not read `!usernameHidden??` as an unexplained deviation
- [ ] T047 Raise `loginPasswordTitle` and `doChangeEmail` for copy sign-off against the VTEX Content Guide, with the tension named as [research.md](./research.md) states it: `Enter password` reads as an action label where the guide prefers a noun phrase for titles, and the guide's own alternative — the bare noun `Password` — duplicates the field label directly beneath it; `Change email` is proposed against the action-label rules, and the glossary does not list "change", so the `pt_BR`, `es`, and `ro` wording should be confirmed against <https://contentguide.vtex.com/pt/docs/glossary>. **Non-blocking**: this task gates neither an implementation task nor a phase checkpoint. The strings ship as proposed in T010–T013 and any revision is a wording-only follow-up in the same four bundles
- [ ] T048 [P] Bring up a `26.3.2` container per [quickstart.md](./quickstart.md) **Part 9** step 5 and repeat Parts 5 and 6 against it. NFR-002 requires the templates to be valid on both runtimes and the image is public, so this is not conditional on one being available — the release job builds into `bitnamilegacy/keycloak:26.3.2-debian-12-r0` and an incompatibility there is a broken release, not a nice-to-know. A FreeMarker incompatibility surfaces as an HTTP 500 on first render, so it fails loudly. The FR-018 re-declarations already reduce the exposure by removing the dependency on base's per-locale completeness across that range
- [ ] T049 Tear down with `docker compose down -v` per [quickstart.md](./quickstart.md) Teardown. The probe realm lives in the in-container H2 database, so `down -v` removes it. Keep the container up between edits during Phases 2–6 — caching is disabled, so template and message changes need only a page reload

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: no dependencies. T003 **must** run before any file is edited, or the Story 3 baseline is worthless
- **Foundational (Phase 2)**: depends on Setup. **Blocks US1 and US2**
- **US1 (Phase 3)** and **US2 (Phase 4)**: depend on Phase 2
- **US3 (Phase 5)**: depends on Phase 2 for the `template.ftl` change it regresses, and on T021 / T031 for the CSS. It does **not** depend on the new templates: `login-username.ftl` and `login-password.ftl` are never rendered by the default browser flow, so they cannot regress it. The real coupling is the two files US1 and US2 share with every existing screen — `resources/css/login.css` and the four message bundles — which is why running US3 before T021 and T031 would check the wrong thing
- **US4 (Phase 6)**: depends on US1 and US2 existing to render, and on Phase 2 for the bundles
- **Polish (Phase 7)**: depends on everything

### The one loud ordering constraint

**T005 → T014 and T005 → T024.** Passing a macro parameter `registrationLayout` does not declare is an
HTTP 500, not a no-op (measured, research.md Decision 2). `template.ftl` must carry the two new flags
before either new template references them. Adding the parameters *with defaults* is what keeps the
eight existing callers working untouched.

### The quiet ones, which matter more

Each of these fails without an error, so a developer who ignores them loses time to a symptom rather
than a stack trace:

- **T006 → T016 and T006 → T026.** `@submit="submitting = true"` against an undeclared `submitting`.
- **T007 → T018 and T007 → T028.** `:disabled="submitting || !canSubmitX"` against an undefined
  computed property evaluates truthy-negated, so the button is disabled forever and looks like a
  validation bug.
- **T008a → T026.** Step 2's show/hide toggle renders and does nothing.
- **T008b → T022.** Nothing to observe for quickstart check 5.10.
- **T008c → T041.** Nothing to announce for quickstart check 7.10.

### Within Phase 2

- T005 → T006 → T007 → T008 → T008a → T008b → T008c → T009: all the same file, `template.ftl`, so strictly sequential
- T010 → T011, T012, T013: `messages_en.properties` is the Crowdin source and fixes the authoritative wording for the two new keys before the other three bundles are seeded. T011–T013 are then parallel

### Within US1 and US2

- T014 → T015 → T016 → T017 → T018 → T019 → T020: all `login-username.ftl`, sequential
- T024 → T025 → T026 → T027 → T028 → T029 → T030: all `login-password.ftl`, sequential
- T021 → T031: both `resources/css/login.css`, sequential
- Verification (T022, T023, T032, T033) after the markup and CSS of its own story

### Parallel opportunities

- **T011, T012, T013** — three different bundle files, once T010 fixes the English wording
- **US1 (T014–T023) and US2 (T024–T033)** — different template files, both unblocked once Phase 2's `template.ftl` run (T005 through T009) is complete. T005 alone is not enough: T016 and T026 need T006, T018 and T028 need T007, and T026 needs T008a. The only shared file is `resources/css/login.css`, so serialize T021 and T031 between the two developers
- **T038 / T039 and T040 / T041** — locale verification and accessibility verification are independent passes over the same two screens
- **T048** — the 26.3 spot-check is independent of everything else in Polish

Nothing else parallelizes. Phase 2 is one file plus four bundles, and each new template is a single
file built up in place.

---

## Parallel Example: Phase 2 bundles

```text
# After T010 fixes the English wording, launch the other three bundles together:
Task: "Add the 2 new + 13 re-declared keys to themes/ilhasoft/login/messages/messages_pt_BR.properties,
       base wording verbatim except Brazilian showPassword/hidePassword"
Task: "Add the same keys to themes/ilhasoft/login/messages/messages_es.properties, base wording verbatim"
Task: "Add the same keys to themes/ilhasoft/login/messages/messages_ro.properties, new Content-Guide copy"
```

## Parallel Example: two developers after Phase 2

```text
# Developer A — step 1
Task: "T014–T020 login-username.ftl, then T021 login.css step-1 rules, then T022–T023 quickstart Part 5 + Part 8"

# Developer B — step 2
Task: "T024–T030 login-password.ftl, then T031 login.css step-2 rules (after A's T021), then T032–T033 quickstart Part 6 + Part 8"
```

---

## Implementation Strategy

### MVP: US1 plus the foundational work it depends on

1. Phase 1 Setup (T001–T004) — runtime, probe realm, **Story 3 baseline before any edit**, identity-first flow
2. Phase 2 Foundational (T005–T009 including T008a–T008c, then T010–T013) — `template.ftl` first, because T014 is an HTTP 500 without T005 and four other tasks fail silently without T006, T007, and T008a
3. Phase 3 US1 (T014–T023) — step 1
4. **STOP and VALIDATE**: quickstart Part 5 and the Part 8 step-1 rows
5. This is demoable: the screen every user sees, on a realm switched to identity-first

Phase 2's bundle work (T010–T013) is inside the MVP even though most of the 13 re-declared keys serve
step 2, because FR-017 requires all four bundles and all the keys in the **same change** — a follow-up
commit for locale parity does not satisfy it.

### Incremental delivery

1. Setup + Foundational → the shared layout accepts per-step state and the bundles are complete
2. Add US1 → verify Part 5 → demo (**MVP**)
3. Add US2 → verify Part 6 → password login works for every unmapped user
4. Run US3 → the regression gate; nothing ships until Part 3 matches the T003 record
5. Run US4 → the release gate; a locale or accessibility gap blocks the release, not the development
6. Polish → scope check, packaging check, and the recorded end-to-end walkthrough

### Notes

- `[P]` means a different file with no dependency on an incomplete task
- `[Story]` maps a task to a user story for traceability; Setup, Foundational, and Polish carry no story label
- There are no test tasks and no `tests/` tree. Verification is a browser walkthrough in the Compose container (NFR-001), and each verification task cites its quickstart part
- Keep the container running between edits — theme and template caching are off, so a page reload picks up every `.ftl`, CSS, and `messages/*.properties` change. If an edit does not appear, the file is outside the mount, which under NFR-004 means it should not have been edited
- Commit after each task or logical group. Stop at any checkpoint to validate the story independently
