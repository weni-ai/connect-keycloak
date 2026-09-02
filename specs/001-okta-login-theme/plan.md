# Implementation Plan: Identity-first login theme (Enterprise Okta)

**Branch**: `feature/okta-login-theme` | **Date**: 2026-08-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-okta-login-theme/spec.md`

## Summary

Split the login theme's single combined email-plus-password screen into the two identity-first screens
Keycloak's browser flow already asks for, without changing the combined screen that every non-migrated
realm still uses.

Concretely: add `login-username.ftl` (email only, keeping today's GitHub/Google/Microsoft block byte
for byte) and `login-password.ftl` (password only, showing the attempted email with a way back), and
extend the shared `template.ftl` with per-step submit state that leaves `canLogin` alone. That last
part is larger than it first looks: three regions of `template.ftl` are gated on a flag only
`login.ftl` passes, and two of them — the password-visibility state and the `connect:requestlogout`
`postMessage` — have to reach the new steps or they fail silently. Thirteen
Keycloak message keys get re-declared locally and two new keys get added, in all four bundles, because
Romanian currently falls back to English on almost every string these screens surface.

Phase 0 resolved the five open design questions by running a real identity-first flow against
Keycloak 26.2.0 with this theme mounted, rather than reasoning from documentation. That turned four of
the five from assumptions into measurements, and turned up two factual errors in the spec's Current
State plus a defect in the verification method SC-006 prescribes. All of it is in
[research.md](./research.md).

## Technical Context

**Language/Version**: FreeMarker (`.ftl`) for Keycloak 26.2, CSS, and browser-side Vue 3 (global
build, no bundler)

**Primary Dependencies**: Keycloak base theme (`parent=base`), UNNNIC via
`resources/vue/unnnic.umd.min.js`, `vue.min.js` — all vendored in-repo. No package manager, no build
step.

**Storage**: N/A

**Testing**: No automated suite exists in this repository. Verification is manual against
`docker-compose.yml` (`quay.io/keycloak/keycloak:26.2.0`, theme and template caching disabled). No
test framework and no `tests/` tree are introduced. See [quickstart.md](./quickstart.md).

**Target Platform**: Keycloak 26.2 locally; the release job packages `themes/` into `themes.tar.xz`
inside `bitnamilegacy/keycloak:26.3.2`. Templates must be valid on both.

**Project Type**: Keycloak theme. There is no `src/` or `tests/`; the unit of work is
`themes/ilhasoft/login/`.

**Performance Goals**: N/A — NFR-005 assigns redirect latency to Keycloak and the realm flow. The
theme's only obligation is that step 1 renders and accepts input without originating a network call.

**Constraints**: the diff stays inside `themes/ilhasoft/login/` (NFR-004);
`keycloak-user-migration/` untouched (NFR-003); no new stylesheet without a `styles=` entry (FR-021);
no new build step (FR-022).

**Unknowns**: none. No `NEEDS CLARIFICATION` markers were carried into Phase 0, and the five
deliberately-open design questions are resolved in [research.md](./research.md).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The spec's Constitution Compliance table was the starting point. Re-running each principle against the
Phase 0 findings changed three rows and found one error in the table itself.

### Pre-Phase 0 gate

| Principle | Verdict | Assessment |
| --- | --- | --- |
| I. Theme-First | **PASS** | Every artifact is a `.ftl`, a `messages/*.properties`, or CSS under `themes/ilhasoft/login/`. No new stack, bundler, or build step. FR-022 is the binding constraint. |
| II. Keycloak Flow Compatibility | **PASS** | The two new templates are overrides of pages base already serves, keeping Keycloak's field names (`username`, `password`), `${url.loginAction}`, and `${url.*}` contracts. No existing template loses a field, hidden input, or action URL. |
| III. Four-Locale Copy | **PASS** | FR-017 requires all four bundles in one change with `en` as the Crowdin source. Phase 0 measured the actual gap, so the requirement is now backed by data rather than by an incorrect premise. |
| IV. One Design System | **PASS** | Both steps compose existing `unnnic-*` elements. No second UI kit. New rules extend `resources/css/login.css`, already in `styles=`. |
| V. Vendored Migration SPI | **PASS** | `keycloak-user-migration/` is untouched (NFR-003). No Maven build runs. |
| VI. Bounded Scope | **PASS** | One bounded change, diff confined to `themes/ilhasoft/login/` (NFR-004). Named pre-existing defects are recorded, not fixed. |

### Runtime & Delivery Constraints gate

| Constraint | Verdict | Assessment |
| --- | --- | --- |
| Keycloak version — 26.2.0 is the reference runtime | **PASS** | Every template variable used was measured on 26.2.0. NFR-002 additionally requires validity on 26.3.2; the FR-018 re-declarations reduce the exposure by removing the dependency on base's per-locale completeness. |
| Local runtime — verify against Docker Compose with caching off | **PASS** | NFR-001 makes it a requirement and [quickstart.md](./quickstart.md) is the procedure. Phase 0 already exercised this path. |
| Delivery — must not depend on artifacts outside `themes.tar.xz` / `plugins.tar.xz` | **PASS** | Everything ships inside `themes/`. The one external reference, the Google Fonts stylesheet in `template.ftl`, is pre-existing and untouched. |
| Translations — Crowdin owns wording; hand-editing is acceptable when a spec adds a key | **PASS, with a caveat** | FR-017 forces all four bundles in the same commit, which is hand-editing three Crowdin-owned files. The constitution permits this when a spec adds a key. The caveat is recorded below. |
| `standalone.xml` — not live configuration | **PASS** | Untouched. |

### Post-Phase 1 re-check

| Principle | Verdict | What Phase 1 changed |
| --- | --- | --- |
| I. Theme-First | **PASS** | Unchanged. The design added no file type beyond `.ftl`, `.properties`, and CSS, and no `theme.properties` change at all — the provider block reuses `login.css`, so FR-021's "new stylesheet needs a `styles=` entry" is never triggered. |
| II. Keycloak Flow Compatibility | **PASS, after closing one gap** | Phase 0 measurement replaced two guesses with Keycloak's actual contract: step 1 branches on `usernameHidden` (which exists) rather than `usernameEditDisabled` (which does not exist anywhere in 26.2), and step 2 uses `auth.attemptedUsername` behind `auth.showUsername()`. Adding macro parameters with defaults is backward compatible for the eight existing callers; passing an undeclared one is a hard HTTP 500, which is why `template.ftl` must land before the new templates. The gap: three regions of `template.ftl` are gated on `displayLoginFormScriptsAndStyles`, a flag only `login.ftl` passes, and the new steps do not inherit them. One of the three is the `connect:requestlogout` `postMessage` — the outbound contract contracts/README.md says this change must not disturb, which would have gone silent on every identity-first realm. FR-023 and Decision 2c close it. |
| III. Four-Locale Copy | **PASS, with the spec's reasoning corrected** | The spec justified FR-018 with "base ships only `messages_en.properties`". Base ships 34 locale bundles. The real defect is that they are partial and the fallback is silent and per key: `base/login/messages_ro.properties` has 34 keys against English's 468, and **10 of the 11** keys these screens surface resolve to English under `ro`. `pt-BR` and `es` leak none. The conclusion stands; the premise did not. Separately, `pt-BR` inherits `showPassword` from `messages_pt` as European Portuguese — a key can be non-English and still wrong. **Recorded divergence**: copying base's English verbatim puts its "please" into `messages_en.properties`, this repository's Crowdin source, and the principle's copy rule forbids "please". Rewording would change copy on screens FR-013 freezes, so the divergence is accepted, recorded in spec.md's Constitution Compliance table, and left as a follow-up. FR-019 still binds every string this delivery authors. |
| IV. One Design System | **PASS** | Unchanged. FR-014's accessible names reuse the existing `loginWith` key, so no visual or component change is implied and PS-BD-007's deferral of provider restyling is respected. |
| V. Vendored Migration SPI | **PASS** | Unchanged. |
| VI. Bounded Scope | **PASS, and this is the row that needed the most care** | Phase 0 surfaced three pre-existing defects inside files this delivery touches or sits beside: the dead `usernameEditDisabled??` guards in `login.ftl` and `login-form.ftl`, the duplicate `:disabled` attribute on `login-form.ftl`'s username input, and `displayInfo=social.displayInfo` in `login.ftl` resolving against a property that no longer exists. All three are tempting one-line fixes in files the diff already opens. **None are fixed.** They are recorded in research.md so the new templates do not copy the pattern and so a reviewer does not read the new `!usernameHidden??` guard as an unexplained deviation. |

### Errors and divergences recorded

One divergence from the constitution is claimed, in item 5 below. Five items need to be visible at
review. The first three were errors in the spec and have been **applied to `spec.md` on 2026-08-26**;
they are kept here as the record of what changed and why, since no requirement was altered.

1. **"FR-023" did not exist.** The spec's Principle I row read "FR-023 forbids a new build step"; the
   requirement that forbids a new build step is **FR-022**. A citation typo, no requirement change.
   *Corrected in spec.md.*

2. **FR-018's stated reason was factually wrong** (Principle III row above). Base ships 34 locale
   bundles, not English only; the real defect is that the non-English ones are partial and the
   fallback is silent and per key. The requirement is correct and necessary; only its justification
   changed. *Corrected in spec.md — Current State, FR-018, Story 4 scenario 2, Assumptions, and the
   Constitution Compliance table.*

3. **SC-006's verification method did not work as written.** It prescribed `?kc_locale=ro` as the
   workaround for `ro` missing from `kc2UnnnicLanguages`. Measured: `kc_locale` is ignored on
   `/protocol/openid-connect/auth` and silently renders English, so as written SC-006 would have
   signed off Romanian by testing English. It works on `/login-actions/authenticate`, which is the URL
   Keycloak puts in `locale.supported[].url`. *Corrected in spec.md — Story 4's Independent Test and
   the Out of Scope note — and in `checklists/requirements.md` Note 2, which carried the same stale
   method.* The quickstart uses `ui_locales` for the first render and the language-selector URL
   thereafter.

4. **FR-017 requires hand-editing three Crowdin-owned bundles.** The constitution's Translations
   constraint allows this "when a spec adds a key" but adds that it "MUST NOT be used to override
   wording Crowdin owns". Nothing here overrides Crowdin: none of the 16 keys exists in this theme's
   bundles today, so Crowdin has never held wording for any of them. The design copies base's existing
   per-locale wording verbatim for the 13 re-declared keys in `en`, `pt_BR`, and `es`, and authors
   fresh, guide-compliant strings only where none exist, which is almost entirely `ro`. The two
   genuinely new keys go into `messages_en.properties` as the Crowdin source and are hand-seeded in
   the other three per FR-017.

   **One deliberate exception to "verbatim".** `pt_BR`'s `showPassword` / `hidePassword` are written
   in Brazilian wording rather than copied, because base leaves them to `messages_pt` and the
   inherited string (`Mostrar palavra-passe`) is European Portuguese — wrong, not merely unfashionable.
   Since the key is absent from this theme's `pt_BR` bundle today, this is still adding a key rather
   than overriding one.

5. **The copy rule in Principle III is departed from, and it is recorded rather than silent.** Copying
   base's English verbatim carries its "please" into `messages_en.properties`. See the Principle III
   row above and spec.md's Constitution Compliance table.

**Gate result: PASS**, with the Principle III copy-rule divergence recorded above. No entry in
Complexity Tracking — the divergence is a recorded exception, not unjustified complexity.

## Project Structure

### Documentation (this feature)

```text
specs/001-okta-login-theme/
├── spec.md               # Input (authoritative)
├── plan.md               # This file
├── research.md           # Phase 0 output — the five design decisions, measured
├── data-model.md         # Phase 1 output — states why there is no data model
├── quickstart.md         # Phase 1 output — the Compose verification procedure
├── contracts/
│   └── README.md         # Phase 1 output — states why there is no API surface
├── checklists/
│   └── requirements.md   # Pre-existing spec quality checklist
└── tasks.md              # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

There is no `src/` and no `tests/` in this repository, and none is added. The unit of work is a
Keycloak theme directory. Every path the delivery may touch is listed below; anything not listed is
out of bounds under NFR-004.

```text
themes/ilhasoft/login/
├── template.ftl                       # CHANGED  — per-step submit state, autofill reconciliation,
│                                      #            re-gated login-only regions, disclaimer role
├── login-username.ftl                 # NEW      — step 1, identity-first (FR-001…FR-005)
├── login-password.ftl                 # NEW      — step 2, password only (FR-006…FR-008)
├── login.ftl                          # UNCHANGED (FR-013) — combined screen entry point
├── login-form.ftl                     # UNCHANGED (FR-013) — combined form macro, owns canLogin
├── login-config-totp.ftl              # UNCHANGED (FR-013)
├── login-idp-link-confirm.ftl         # UNCHANGED (FR-013)
├── login-otp.ftl                      # UNCHANGED (FR-013)
├── login-reset-password.ftl           # UNCHANGED (FR-013)
├── login-update-password.ftl          # UNCHANGED (FR-013)
├── login-verify-email.ftl             # UNCHANGED (FR-013)
├── register.ftl                       # UNCHANGED (FR-013)
├── theme.properties                   # UNCHANGED — no new stylesheet, so no styles= entry (FR-021)
├── messages/
│   ├── messages_en.properties         # CHANGED  — Crowdin source; 2 new keys + 13 re-declared
│   ├── messages_pt_BR.properties      # CHANGED  — same keys (FR-017)
│   ├── messages_es.properties         # CHANGED  — same keys (FR-017)
│   └── messages_ro.properties         # CHANGED  — same keys; the only locale with a real gap
└── resources/
    ├── css/login.css                  # CHANGED  — step-1 and step-2 layout rules only
    └── img/login/                      # UNCHANGED — icon-{github,google,microsoft}.svg reused as-is
```

Explicitly **not** touched: `keycloak-user-migration/` (NFR-003), the `account` / `admin` / `email` /
`common` theme types, `docker-compose.yml`, `Dockerfile`, `crowdin.yml`, `standalone.xml`, and
`.github/workflows/` (NFR-004).

**Structure Decision**: the two new screens are separate top-level templates rather than a shared
macro parameterised by step. Keycloak selects them by filename — `UsernameForm` calls
`createLoginUsername()` and `PasswordForm` calls `createLoginPassword()` — so the filenames are the
contract, and a shared macro would add indirection without removing duplication. The provider block is
the one piece duplicated from `login.ftl`, and FR-003 and SC-003 explicitly require that duplication to
be byte-identical, so factoring it into a macro would work against the requirement it serves.

## Design decisions carried into Phase 2

Full reasoning and the measurements behind each is in [research.md](./research.md).

| # | Decision | Consequence for tasks |
| --- | --- | --- |
| 1 | Provider block lives in the `info` section with `displayInfo=true`; `template.ftl` does **not** learn to nest `socialProviders` | Keeps FR-003 parity and SC-003; avoids reopening `login.ftl`. `social.providers` is measured at 3 on step 1 and **0 on step 2**, so step 2 needs no filter but must not emit an orphaned separator |
| 1a | Step 1 reproduces the block's **enclosing** conditions too, not just its markup: one `realm.password && realm.registrationAllowed` guard over separator + providers + sign-up, and `v-if="!VTEXAppEmail"` on the separator | Easy to miss, because `login.ftl` puts three visually distinct regions inside one `<#if>` and the footer outside it. Splitting them would un-gate the providers and re-gate the footer, diverging from `login.ftl` on any realm with registration disabled — which the probe realm is not, so no existing check would catch it. The quickstart gains a row for it |
| 2 | Two new macro flags plus `canSubmitUsername` / `canSubmitPassword`; `canLogin` untouched | Ordering constraint: `template.ftl` ships before the new templates, because passing an undeclared macro parameter is an HTTP 500, not a no-op |
| 2a | Submit enablement reads the DOM input's `.value`, reconciled after mount and on `input` / `change` | The existing `onAutoFillStart` CSS hook and its `animationstart` listener cannot be relied on: the listener only logs, and `input-itself` is applied to an inner UNNNIC component, not necessarily the real `<input>`. SC-009 is a release gate |
| 2b | `submitting` flag set on the form's `@submit`; button `:disabled="submitting \|\| !canSubmitX"`; `native-type="submit"` declared explicitly | Mirrors base's `onsubmit="login.disabled = true"` for FR-011/SC-008 without needing base's `name="login"` global |
| 2c | The three regions of `template.ftl` gated on `displayLoginFormScriptsAndStyles` are re-gated so the new steps get what they need: `loginPasswordVisible` (step 2's show/hide toggle state) and the `connect:requestlogout` emission (step 1). `canLogin`, `loginUsername`, `loginPassword`, and `rememberMe` stay where they are | Two of these are silent failures, not build errors. Without the first, step 2's toggle renders and does nothing, because `toggleLoginPasswordVisibility` would write a property Vue never declared. Without the second, FR-023's `postMessage` stops firing for every user on a migrated realm, and Part 3 cannot see it because it runs on the default flow where `login.ftl` still passes the old flag |
| 2d | The form-level `unnnic-disclaimer` in `template.ftl` gains `role="alert"` | FR-015's second clause. Decision 6 suppresses the disclaimer whenever a per-field error exists, so the per-field work alone leaves the clause unmet for the generic errors that arrive without one (`invalidUserMessage`, `accountTemporarilyDisabledMessage`). It is shared with the frozen screens, which the spec now accepts explicitly under FR-015 |
| 3 | Step 1 guards on `!usernameHidden??`; sign-up block on `!registrationDisabled??` | `usernameEditDisabled` does not exist in 26.2; the new templates must not copy the dead guard from `login.ftl` |
| 4 | 2 new keys (`loginPasswordTitle`, `doChangeEmail`); 13 re-declared in all four bundles; `loginWith` reused for FR-014 | FR-014 and SC-007 cost no new copy. `ro` is the only locale with a functional gap and needs genuinely new, guide-compliant strings |
| 5 | FR-007 uses `auth.attemptedUsername` + `url.loginRestartFlowUrl` behind `auth?has_content && auth.showUsername()` | Confirmed, not assumed. Unguarded access throws where no user is established, including step 1 |
| 6 | Both steps pass `displayMessage=!messagesPerField.existsError('<field>')` | On a validation error Keycloak populates `message` **and** `messagesPerField` with the same sentence; without this the user sees it twice (FR-015) |

## Risks and open items

| Item | Impact | Handling |
| --- | --- | --- |
| `loginPasswordTitle` and `doChangeEmail` wording | Copy quality, four locales | Proposed in research.md against the Content Guide, with the tension named. Needs copy sign-off; the glossary does not list "change" |
| `VTEXAppEmail` is lost when step 1 re-renders after a validation error | FR-012 / Story 1 scenario 6 | Pre-existing — `login.ftl` behaves identically, because the post-submit URL carries no `redirect_uri`. Recorded, not fixed. Quickstart checks the first render |
| `select-organization.ftl` still renders as a stock page | Deferred by the spec under PS-BD-007 | Out of Scope. Remains a release-gate check for any customer with multi-organization members |
| `ro` absent from `kc2UnnnicLanguages` | Romanian unreachable through the UI selector | Pre-existing, bounded out under Constitution VI. Quickstart reaches `ro` by URL |
| `showPassword` / `hidePassword` give step 2's toggle an accessible name that `login-form.ftl`'s toggle lacks | Minor inconsistency between the two screens | Accepted. FR-014 names only the provider buttons and NFR-004 bounds the diff |
| Adding `role="alert"` to the shared disclaimer changes announcement on the eight screens FR-013 freezes | Behavior change outside the two new steps | Accepted and made explicit in FR-015. It is additive, drops nothing Keycloak requires, and improves the frozen screens. Part 3 confirms nothing else moved |
| Step 1 reproducing `realm.registrationAllowed` means a registration-disabled realm gets no third-party buttons | Looks like a bug on a realm none of the current customers run | Parity is what FR-003 and SC-003 require, and Constitution VI forbids fixing it here. Recorded as a spec edge case and checked in quickstart 8.9, so it is a decision rather than an accident |

## Complexity Tracking

No Constitution Check violations. Nothing to justify.
