# Engineering Specification: Identity-first login theme (Enterprise Okta)

**Feature Branch**: `feature/okta-login-theme`

**Created**: 2026-08-26

**Status**: Draft <!-- Draft | Clarified | Reviewed | Ratified -->

**Input**: User description: "We have a product spec and need to create our engineering spec based on that. Scope of this spec: keycloak theme changes."

## Inheritance from Product Spec *(mandatory)*

| Field | Value |
| --- | --- |
| Product Spec | Enterprise Okta login — `weni-ai/vtex-cx-experience-specs`, `specs/003-okta-login/spec.md` |
| Pinned version | branch `003-okta-login-v2`, commit `14f91f5281c6c1d1ad2589836cf969c71a8c608b` |
| Product spec status at pin | Ratified |
| Inherited binding decisions | PS-BD-001 … PS-BD-009 |
| Scope of this spec | `themes/ilhasoft/login/` only |
| Divergences from product spec | None |

Product-spec identifiers are cited with a `PS-` prefix (`PS-FR-002`, `PS-BD-003`, `PS-NFR-005`).
Identifiers without that prefix belong to this engineering spec.

This spec is the theme-side half of PS-BD-003 and PS-BD-005: the product spec places the
identity-first screen in the **Keycloak login theme** and states the Connect web app MUST NOT host a
replacement login page. Everything the product spec assigns to realm configuration, the identity
routing table, Connect organization policy, or the Connect web app is out of scope here and listed
under **Out of Scope**.

Per the repository constitution (Principle I, Development Workflow step 1), Keycloak template names,
`theme.properties` keys, and message-bundle paths are the domain vocabulary of this repository, not
leaked implementation detail. They are named explicitly so a reviewer can check the diff against the
scope. Concrete markup, CSS rules, and Vue code remain the job of `/speckit-plan`.

## Current State *(mandatory)*

Verified against the working tree at the time of writing:

- `themes/ilhasoft/login/theme.properties` sets `parent=base`, `import=common/keycloak`, and
  `styles=css/login.css css/unnic.css css/password-update.css css/otp-settings.css`.
- `login.ftl` renders a **single-step** form via the `login-form.ftl` macro: email/username **and**
  password on the same screen, followed by a separator, the third-party provider list, the sign-up
  block, and the privacy-policy footer.
- The third-party list is generic: it iterates `social.providers` and renders one icon-only
  `unnnic-button` per provider (`id="zocial-${p.alias}"`, class `social-button`, image
  `img/login/icon-${p.alias}.svg`). Only `icon-github.svg`, `icon-google.svg`, and
  `icon-microsoft.svg` exist in `resources/img/login/`.
- Those third-party buttons carry **no accessible name** — the `<img>` has no `alt` and the button has
  no label or `aria-label`.
- `template.ftl` hosts one Vue 3 app for every login screen. It nests only the `title`, `form`, and
  `info` sections. It does **not** nest Keycloak's `socialProviders` section, and it does **not**
  render Keycloak's `kc-username` / restart-login block or a "Try another way" link.
- `template.ftl` gates login state behind `displayLoginFormScriptsAndStyles` and exposes a single
  `canLogin` computed property that requires **both** a valid username **and** a non-empty password.
- `template.ftl` reads `redirect_uri` → `vtex_app` → `email` into `VTEXAppEmail`, prefills
  `usernameInput`, and disables the username field when it is present.
- `template.ftl` maps Keycloak locales to UNNNIC in `kc2UnnnicLanguages`, which contains `pt-BR`,
  `en`, and `es` — **`ro` is missing**, so Romanian is not offered in the language selector even
  though `messages_ro.properties` exists.
- Form-level feedback is a single `unnnic-disclaimer` in `template.ftl` with no `aria-live` or
  `role`. No template in this theme renders `messagesPerField` per-field errors.
- The theme does **not** override `login-username.ftl`, `login-password.ftl`, or
  `select-organization.ftl`. Keycloak 26.2's `base` theme provides all three, so today they would
  render as unstyled stock Keycloak pages inside this theme.
- Keycloak's `base` theme ships 34 locale bundles, but the non-English ones are **partial**:
  `messages_en.properties` and `messages_es.properties` hold 468 keys, `messages_pt_BR.properties`
  holds 338, and `messages_ro.properties` holds **34**. Keycloak resolves a locale by overlaying the
  requested bundle on its parent (`pt-BR` → `pt` → `en`), so a key missing from a locale bundle falls
  back to English **silently and per key**. Measured against the two new steps: 10 of the 11
  Keycloak-provided keys they surface resolve to English under `ro`, while `pt_BR` and `es` resolve
  none of them to English. One key can also be non-English and still wrong — `showPassword` under
  `pt_BR` is inherited from `messages_pt` as European Portuguese. Any Keycloak-provided key these
  steps surface therefore has to be checked per locale and re-declared in this theme's own bundles
  where the base bundle lacks it.
- Keycloak 26's `OrganizationAuthenticator` resolves an organization from the email domain and, on a
  match with a linked broker, redirects; when it cannot resolve, it re-challenges with
  `login-username.ftl`, and when several organizations match it challenges with
  `select-organization.ftl`. Domain comparison is exact on the part after `@`.
- Local runtime is `quay.io/keycloak/keycloak:26.2.0` via `docker-compose.yml` with theme and
  template caching disabled. The release job packages `themes/` into `themes.tar.xz` inside
  `bitnamilegacy/keycloak:26.3.2-debian-12-r0`.

The gap this spec closes: the product spec requires a two-step, identity-first first screen
(PS-FR-001, PS-FR-002, PS-BD-003), and this theme has no styled templates for either step.

## User Scenarios & Testing *(mandatory)*

"Verified in the running container" below means the Docker Compose realm exercised through a real
browser flow, per Development Workflow step 4. It does not mean reading the diff.

### User Story 1 - Step 1 renders email only, with the three third-party actions intact (Priority: P1)

A person opens the platform login on a realm configured for identity-first. The theme renders a
branded first step containing one email field and the same GitHub, Google, and Microsoft buttons that
exist today, in the same position and appearance. There is no password field. Submitting the email
hands control back to Keycloak, which decides whether to redirect to a customer Okta or advance to
the password step.

**Why this priority**: This is the screen every user sees. Without it, the realm flow either shows a
stock unstyled Keycloak page or cannot be switched to identity-first at all. Nothing else in this
delivery is observable until step 1 exists.

**Independent Test**: Switch the local realm's browser flow to an identity-first flow, open the login
page, and confirm the first screen shows the brand, one email field, and exactly the providers
enabled in the realm — with no password field anywhere in the DOM.

**Acceptance Scenarios**:

1. **Given** a realm on an identity-first browser flow, **When** the login page loads, **Then** the
   theme's own step-1 screen renders (brand logo, UNNNIC form element, language selector) and no
   stock Keycloak styling appears.
2. **Given** step 1 is rendered, **When** the DOM is inspected, **Then** there is no `password` input
   and no forgot-password link.
3. **Given** the realm has GitHub, Google, and Microsoft enabled, **When** step 1 renders, **Then**
   the provider block has the same element ids, classes, icons, and ordering as the block in today's
   `login.ftl`, and clicking one navigates straight to `${p.loginUrl}` without reading the email
   field.
4. **Given** an empty or malformed email, **When** the user submits, **Then** the flow stays on step 1
   and the message is rendered by the theme, not by a stock Keycloak page.
5. **Given** the email field has a value, **When** the user presses Enter, **Then** the form posts to
   `${url.loginAction}` with field name `username` and the submit control cannot be triggered a second
   time.
6. **Given** a `redirect_uri` carrying a `vtex_app` email, **When** step 1 loads, **Then** the email
   field is prefilled and disabled exactly as it is today on `login.ftl`.

---

### User Story 2 - Step 2 asks for the password only, and the user can go back (Priority: P1)

A person whose email domain is not mapped to a customer Okta submits their email and lands on a
branded second step. It asks only for the password, shows which email is being authenticated, keeps
the forgot-password link, and offers a way back to step 1 so a typo is recoverable.

**Why this priority**: PS-FR-003 keeps platform password available on the second step. Shipping step 1
without a styled step 2 makes password login visually broken for every unmapped user, which is the
majority of current traffic.

**Independent Test**: Submit an unmapped-domain email on the local realm and confirm the password
screen is the theme's own, shows the submitted email, and its back control returns to step 1.

**Acceptance Scenarios**:

1. **Given** an unmapped-domain email was submitted, **When** step 2 renders, **Then** the theme's own
   password screen appears with a single password field and the existing show/hide toggle.
2. **Given** step 2 is rendered, **When** the DOM is inspected, **Then** there is no email input and no
   third-party provider block.
3. **Given** step 2 is rendered, **When** Keycloak exposes the attempted username, **Then** the
   submitted email is displayed and a control links to `${url.loginRestartFlowUrl}`.
4. **Given** the user activates that control, **When** the page loads, **Then** they are on step 1 with
   the email field editable.
5. **Given** `realm.resetPasswordAllowed` is true, **When** step 2 renders, **Then** the
   forgot-password link points to `${url.loginResetCredentialsUrl}`.
6. **Given** a wrong password, **When** the user submits, **Then** the error is rendered by the theme
   and the flow stays on step 2.

---

### User Story 3 - Existing single-step login and the other login screens keep working (Priority: P1)

Realms and flows that are not on identity-first continue to render today's combined
email-plus-password screen. Registration, password reset, password update, OTP, email verification,
and IdP link confirmation are unchanged.

**Why this priority**: One theme serves `weni`, `weni-staging`, and `weni-develop`, and the realm flow
is switched by an operational procedure (PS-BD-005), not by this repository. Constitution Principle II
makes silent divergence in any Keycloak flow a breaking change. A regression here is an outage on a
realm that was not part of this delivery.

**Independent Test**: On a realm still using the stock browser flow, log in with email and password on
one screen, then walk reset-password, update-password, and OTP setup.

**Acceptance Scenarios**:

1. **Given** a realm on the default browser flow, **When** the login page loads, **Then** today's
   combined screen renders with no visual or behavioral change.
2. **Given** any non-login screen in this theme, **When** it renders, **Then** it is unchanged from
   before this delivery.
3. **Given** the Vue app in `template.ftl`, **When** any screen loads, **Then** the browser console
   reports no new errors or missing-component warnings.

---

### User Story 4 - Copy, locales, and accessibility hold on both steps (Priority: P2)

Every string on the two new steps is available in `en`, `pt_BR`, `es`, and `ro`, follows the VTEX
Content Guide, and both steps are completable with the keyboard alone with errors announced to
assistive technology.

**Why this priority**: PS-NFR-005 requires it and Constitution Principle III makes locale parity a
completion condition, but the flow can be proven correct on staging first (PS-BD-007) before every
locale is signed off. It is separated so that a locale gap blocks the release rather than the
development of stories 1–3.

**Verification** *(not independent — Stories 1 and 2 must render before this can run)*: Load each step
in each of the four locales and confirm no raw message key and no
unexpected English string appears; then complete both steps using only Tab, Shift+Tab, and Enter with a
screen reader running. Note that `?kc_locale=` is **not** honored on the authorization endpoint in
Keycloak 26.2 — it silently renders English there. Use `?ui_locales=` for the first render, or the
`kc_locale` parameter on the `/login-actions/authenticate` URL that Keycloak itself puts in
`locale.supported[].url`, or a `KEYCLOAK_LOCALE` cookie.

**Acceptance Scenarios**:

1. **Given** any of the four locales, **When** step 1 and step 2 render, **Then** no raw message key is
   visible and every string is in the requested locale.
2. **Given** a Keycloak-provided key newly surfaced by these steps, **When** a non-English locale is
   requested, **Then** the string is localized, because it is defined in this theme's own bundles
   rather than left to base's partial non-English bundles and their silent per-key English fallback.
3. **Given** a keyboard-only user, **When** they Tab through step 1, **Then** they reach the email
   field, the submit control, each third-party button, and the sign-up control, and each third-party
   button is announced with a name identifying its provider.
4. **Given** a submission error on either step, **When** it renders, **Then** it is announced by
   assistive technology without requiring the user to move focus.

---

### Edge Cases

- **Unknown or malformed `kc_idp_hint`** (PS-FR-013): Keycloak falls through to the login form. The
  theme MUST render step 1 plus whatever generic message Keycloak supplies through the existing
  disclaimer, and MUST NOT introduce copy that names a customer or states that a link is invalid.
- **Realm with no identity providers enabled**: step 1 renders the email field with no provider block
  and no orphaned separator.
- **Realm with registration disabled**: `login.ftl` today wraps the separator, the provider list, and
  the sign-up block in one `realm.registrationAllowed` guard, so a realm with registration disabled
  shows no third-party buttons at all. Step 1 must match that, per FR-003. The behavior is odd enough
  to look like an oversight, which is why it is written down rather than silently reproduced or
  silently dropped; changing it is a separate decision on a screen FR-013 freezes.
- **Realm with more than three providers, or a provider with no local icon**: the provider block must
  not break layout and must not render a broken image. Only three icons exist today.
- **A customer Okta broker that is not hidden from the login page**: it would appear as a public
  button, which PS-BD-001 forbids. The theme renders exactly what `social.providers` yields and MUST
  NOT hardcode or filter providers; keeping the broker hidden is realm configuration (Out of Scope),
  and this is recorded as a dependency and a release-gate check.
- **Multi-organization match**: Keycloak challenges with `select-organization.ftl`, which this theme
  does not override, so a stock Keycloak page appears inside the branded flow. Accepted for this
  delivery under PS-BD-007 and listed under Out of Scope. It must be re-checked before production
  go-live for any customer whose members belong to more than one organization.
- **Double submit on either step**: exactly one POST per activation; the submit control is disabled
  once submitted.
- **Browser autofill on step 2**: an autofilled password must enable the submit control without the
  user typing, so submit enablement cannot depend only on `input` events.
- **`VTEXAppEmail` present**: the prefilled, disabled email must not reappear as a disabled field or
  a hidden duplicate on step 2.
- **Expired or restarted flow on step 2**: the restart control and Keycloak's own restart both return
  to step 1, not to a stock page.
- **Long email (254 characters)**: step 1 layout must not overflow the card.

## Requirements *(mandatory)*

### Functional Requirements

**Step 1 — identity-first screen**

- **FR-001**: The theme MUST provide a `login-username.ftl` override under
  `themes/ilhasoft/login/` that renders through `template.ftl`'s `registrationLayout` macro and
  presents exactly one credential input — the email/username field — posting to `${url.loginAction}`
  under field name `username`. It MUST NOT render a password input, a forgot-password link, or a
  remember-me control that Keycloak does not accept on this step. *(PS-FR-001, PS-BD-003)*
- **FR-002**: The field label and placeholder MUST keep the existing conditional logic and the
  existing keys (`username` / `usernameOrEmail` / `email`, and `placeholderLoginEmail` /
  `placeholderLoginName`). This delivery MUST NOT introduce a new placeholder string.
  *(PS design vision; PS clarification 2026-08-25 on placeholders)*
- **FR-003**: The third-party provider block on step 1 MUST reproduce the block currently in
  `login.ftl` with the same element ids, classes, icon paths, ordering, and click behavior, so hover,
  focus, and pressed appearance are inherited rather than redefined. It MUST also reproduce the
  block's enclosing conditions: in `login.ftl` the separator, the provider list, and the sign-up block
  share one `realm.password && realm.registrationAllowed` guard, and the separator additionally
  carries `v-if="!VTEXAppEmail"`. A realm with registration disabled MUST therefore render the same
  provider surface on step 1 as it does on `login.ftl` today. Exactly two additions are permitted: the
  accessible name required by FR-014, and a guard that suppresses the separator when
  `social.providers` is empty. Neither changes an id, class, icon path, or ordering.
  *(PS-FR-001, PS-BD-007)*
- **FR-004**: Step 1 MUST render only the providers Keycloak supplies in `social.providers`. The
  theme MUST NOT hardcode, add, remove, or filter a provider, and MUST NOT render any Okta entry.
  *(PS-BD-001, PS-FR-001)*
- **FR-005**: The sign-up block, the separator, and the privacy-policy footer MUST appear on step 1
  in the same position and with the same keys as on today's `login.ftl`, and MUST honor the existing
  `VTEXAppEmail` and `realm.registrationAllowed` conditions.

**Step 2 — password screen**

- **FR-006**: The theme MUST provide a `login-password.ftl` override that presents exactly one
  credential input — the password field — posting to `${url.loginAction}` under field name
  `password`, with `autocomplete="current-password"` and the show/hide toggle already used in
  `login-form.ftl`. It MUST NOT render an email input or the third-party provider block.
  *(PS-FR-002, PS-FR-003)*
- **FR-007**: When Keycloak exposes the attempted username, step 2 MUST display it and MUST offer a
  control that returns to step 1 via `${url.loginRestartFlowUrl}`. *(PS journey 1 scenario 3; PS edge
  case "user abandons / retries")*
- **FR-008**: Step 2 MUST keep the forgot-password link to `${url.loginResetCredentialsUrl}` when
  `realm.resetPasswordAllowed` is true. *(PS-FR-003)*

**Shared layout and state**

- **FR-009**: `template.ftl` MUST expose per-step submit state so that step 1 enablement depends only
  on the email field and step 2 enablement depends only on the password field. The current `canLogin`
  property, which requires both values, MUST NOT gate either new step, and MUST keep its present
  behavior for `login-form.ftl`. *(FR-001, FR-006; PS-FR-001, PS-FR-002)*
- **FR-010**: Submit enablement MUST tolerate browser autofill on both steps — a value placed by the
  browser without an `input` event MUST still enable submit.
- **FR-011**: On both steps, activating submit MUST produce exactly one POST and MUST disable further
  activation until the page navigates. *(PS design vision, "Loading … user cannot double-submit")*
- **FR-012**: The `VTEXAppEmail` prefill and disabled state MUST apply to step 1's email field and
  MUST NOT appear on step 2 in any form, visible or hidden.
- **FR-013**: `login.ftl`, `login-form.ftl`, and every other template in
  `themes/ilhasoft/login/` MUST keep their current behavior. No Keycloak-required form field, hidden
  input, or action URL may be dropped from any existing template. *(Constitution II)*
- **FR-023**: The `connect:requestlogout` `postMessage` that `template.ftl` emits on the login screen
  MUST also be emitted on step 1, which replaces `login.ftl` as the first screen on an identity-first
  realm. It is currently gated on `displayLoginFormScriptsAndStyles`, a flag only `login.ftl` passes,
  so it would otherwise stop firing for every user on a migrated realm. *(Constitution II; the
  Assumption that this delivery does not change session or logout behavior)*

**Accessibility and feedback**

- **FR-014**: Each third-party button MUST have an accessible name identifying its provider. Adding
  an accessible name is not a visual change and is therefore not deferred by PS-BD-007.
  *(PS-NFR-005)*
- **FR-015**: Both steps MUST render Keycloak's per-field validation errors for their own field
  (`username` on step 1, `password` on step 2) in a region announced to assistive technology, and the
  existing form-level `unnnic-disclaimer` MUST be announced when it carries an error. That disclaimer
  lives in `template.ftl` and is shared with the screens FR-013 freezes, so annotating it improves
  announcement on those screens too. This is accepted rather than avoided: it drops no field, hidden
  input, or action URL, and FR-013's freeze governs Keycloak flow contracts, not additive
  accessibility. *(PS-NFR-005)*
- **FR-016**: Both steps MUST be completable with the keyboard alone, with focus starting on the
  step's single input and a logical tab order through submit, providers, and secondary links.
  *(PS-NFR-005)*

**Copy and locales**

- **FR-017**: Every message key that step 1 or step 2 renders MUST exist in all four bundles —
  `messages_en.properties`, `messages_pt_BR.properties`, `messages_es.properties`,
  `messages_ro.properties` — in the same change, with `messages_en.properties` holding the
  authoritative wording as the Crowdin source. *(Constitution III; PS-NFR-005)*
- **FR-018**: Any key these steps surface that is provided by Keycloak's own bundle rather than this
  theme — the restart-login label required by FR-007 is the known case — MUST be defined in all four
  of this theme's bundles, because base's non-English bundles are partial and a key they omit falls
  back to English silently and per key. An English string appearing under `pt_BR`, `es`, or `ro` is a
  defect, not a fallback. *(Constitution III; PS-NFR-005)*
- **FR-019**: New copy MUST follow the VTEX Content Guide: sentence case, no "please", no
  interjections, no exclamation marks, no personal pronouns in labels or titles, action labels of at
  most three words, and lowercase after a colon in `pt_BR`, `es`, and `ro`. *(PS design vision;
  Constitution III)*
- **FR-020**: The theme MUST NOT introduce any string that names a customer, names a customer's
  identity provider, or states that a sign-in link is invalid. *(PS-FR-013, PS-NFR-003)*

**Styling and packaging**

- **FR-021**: New styles MUST extend the stylesheets already listed in `styles=` in
  `themes/ilhasoft/login/theme.properties`. A new stylesheet requires a `styles=` entry and a stated
  reason, and no second UI kit, CSS framework, or component library may be added.
  *(Constitution I, IV)*
- **FR-022**: The delivery MUST consist only of files under `themes/ilhasoft/login/` and MUST require
  no build step beyond what `theme.properties` already declares, so that `themes.tar.xz` remains a
  complete artifact. *(Constitution I, Runtime & Delivery Constraints)*

### Non-Functional Requirements

- **NFR-001**: Both steps and every existing login screen MUST be verified in the Docker Compose
  container against a real flow, not by inspecting the diff. *(Constitution, Development Workflow 4)*
- **NFR-002**: Templates MUST be valid FreeMarker for the local runtime (`26.2.0`) and for the image
  the release job builds in (`26.3.2`). *(Runtime & Delivery Constraints)*
- **NFR-003**: `keycloak-user-migration/` MUST NOT be modified. *(Constitution V)*
- **NFR-004**: No repository file outside `themes/ilhasoft/login/` may be edited. The feature's own
  specification artifacts under `specs/001-okta-login-theme/` are excluded — they are the record of
  the change, not part of it, and the SC-011 scope check must exclude them explicitly rather than
  report them as violations. *(Constitution VI)*
- **NFR-005**: Redirect-start latency for a mapped domain is decided by Keycloak and the realm flow,
  not by the theme. The theme's only latency obligation is that step 1 renders and accepts input
  without waiting on a network call it originates. *(PS-NFR-002)*

### Key Entities

- **Step-1 template** (`login-username.ftl`, new): the identity-first screen. Rendered by Keycloak's
  username-form and organization authenticators.
- **Step-2 template** (`login-password.ftl`, new): the password screen for an unmapped domain.
- **Shared layout** (`template.ftl`, changed): the single Vue app, brand, language selector,
  form-level disclaimer, and per-step submit state.
- **Legacy single-step form** (`login.ftl` + `login-form.ftl`, unchanged): the combined screen for
  realms not on identity-first.
- **Message bundles** (`messages/messages_{en,pt_BR,es,ro}.properties`, changed): all four move
  together; `en` is the Crowdin source.
- **Login stylesheet** (`resources/css/login.css`, changed): the only place new rules belong unless a
  new file is registered in `styles=`.

## Success Criteria *(mandatory)*

- **SC-001**: On a realm using an identity-first browser flow, 100% of loads of the first login screen
  render this theme's step 1, and no stock Keycloak login page appears at any point in the happy path
  for either step. *(FR-001, FR-006)*
- **SC-002**: Step 1 contains zero password inputs and step 2 contains zero email inputs, checked in
  the rendered DOM in all four locales. *(FR-001, FR-006, FR-012)*
- **SC-003**: The step-1 provider block is byte-identical in ids, classes, icon paths, and ordering to
  the block in `login.ftl` at the pinned baseline, except for the two additions FR-003 permits: the
  accessible names added by FR-014 and the empty-list separator guard. Its enclosing
  `realm.registrationAllowed` condition is reproduced, checked on a realm with registration disabled.
  *(FR-003, FR-014)*
- **SC-004**: Submitting an unmapped-domain email reaches this theme's step 2, and its back control
  returns to an editable step 1, in every locale. *(FR-006, FR-007)*
- **SC-005**: On a realm still using the default browser flow, today's combined screen plus
  registration, reset-password, update-password, OTP, and verify-email all render and complete
  unchanged, with no new console errors. *(FR-013)*
- **SC-006**: Every message key referenced by the new and changed templates resolves in all four
  bundles, with zero raw keys and zero English strings shown under `pt_BR`, `es`, or `ro`.
  *(FR-017, FR-018)*
- **SC-007**: Step 1 and step 2 are each completed end to end using only the keyboard, and a screen
  reader announces each provider button by provider and announces validation and form-level errors
  without a manual focus move. *(FR-014, FR-015, FR-016)*
- **SC-008**: Activating submit repeatedly and rapidly on either step produces exactly one POST.
  *(FR-011)*
- **SC-009**: An autofilled password on step 2 enables submit without any keystroke. *(FR-010)*
- **SC-010**: No string introduced by this delivery names a customer, names a customer's identity
  provider, or asserts that a sign-in link is invalid. *(FR-020)*
- **SC-011**: The diff touches only paths under `themes/ilhasoft/login/` and this feature's own
  `specs/001-okta-login-theme/`, adds no new build step, and the release job's `themes.tar.xz` still
  contains everything the screens need. Checked against the merge base, not against the index, so that
  committing the work cannot make the check pass vacuously. *(FR-021, FR-022, NFR-003, NFR-004)*
- **SC-012**: The `connect:requestlogout` `postMessage` is observed on step 1 of an identity-first
  realm, as it is on `login.ftl` today. *(FR-023)*

## Out of Scope

Each item below is assigned by the product spec to something other than the Keycloak login theme.

- **Realm and flow configuration**: switching the browser flow to identity-first, creating customer
  Okta brokers, hiding them from the login page, mapping email domains, and organization setup. These
  are the internal operational procedure of PS-BD-005 and PS-FR-011, and this repository holds no
  realm export.
- **Domain-to-identity-source routing logic** and the exact-match rule (PS-FR-002). Decided by
  Keycloak and realm configuration; the theme neither implements nor reimplements it.
- **Connect organization access policy**, the identity-source allowlist, empty-list fail-closed
  behavior, and the PS-FR-017 blast-radius rule.
- **Blocked-organization copy (PS-FR-012)** and **door B handling in the web app**. The product spec
  assigns both to the Connect web app: "The web app's in-scope slice is door B handling and
  blocked-organization copy (FR-012)."
- **Door B and door C routing behavior** (PS-FR-013). `kc_idp_hint` is handled by Keycloak's identity
  provider redirector before any theme template renders. The theme's only obligation is FR-020 plus
  rendering step 1 with Keycloak's generic message when the hint does not resolve.
- **Platform password removal for members of an Okta-configured organization** (PS-FR-010,
  PS-BD-009).
- **Visual redesign of the third-party buttons' hover, focus, and pressed states** — deferred by
  PS-BD-007. Adding an accessible name (FR-014) is not part of that deferral.
- **The organization-selection screen (`select-organization.ftl`)** — deferred to a follow-up spec.
  Keycloak's organization authenticator renders it when a user's email matches more than one
  organization, and this theme does not override it, so a stock Keycloak page appears inside the
  branded flow. Deferred under PS-BD-007 (staging-correct flow before visual refinement) on the
  understanding that the screen is not on the first customers' happy path. It is a release-gate check,
  not a silent gap: before production go-live for any customer whose members belong to more than one
  organization, either the screen is styled or the flow is confirmed not to reach it.
- **The `account`, `admin`, `email`, and `welcome` theme types**, and `keycloak-user-migration/`.
- **The missing `ro` entry in `kc2UnnnicLanguages`**: Romanian message files exist but Romanian is not
  offered in the language selector. This is a pre-existing defect that predates this delivery and is
  bounded out under Constitution VI. It is raised here because it limits how PS-NFR-005 can be
  verified for `ro` through the UI. The workaround used by SC-006 is `?ui_locales=ro` on the
  authorization endpoint, or a `KEYCLOAK_LOCALE=ro` cookie — **not** `?kc_locale=ro`, which Keycloak
  26.2 ignores on that endpoint and which would therefore sign Romanian off by rendering English. It
  should be fixed in its own change.
- **Metrics, tracing, and login observability** (PS "Observability").

## Assumptions & Dependencies

- **Identity-first is delivered by the realm's browser flow, not by the theme.** Whether it is
  Keycloak 26's organization authenticator or a username-form/password-form pair, both render
  `login-username.ftl` for the first step and `login-password.ftl` for the second, so the theme
  surface in FR-001 and FR-006 is the same either way. The organization authenticator additionally
  renders `select-organization.ftl`, which is deferred (see Out of Scope).
- **The first customers' members belong to one organization each**, so the deferred
  organization-selection screen is not on their happy path. If that turns out to be false for a
  customer, the deferral must be revisited before that customer's production go-live.
- The realm's third-party providers stay GitHub, Google, and Microsoft. If a fourth is enabled, the
  theme renders it generically (FR-004) but no icon exists for it — a realm-configuration concern,
  flagged as an edge case.
- Customer Okta brokers are configured as hidden on the login page. If that is missed, a public Okta
  button appears and PS-BD-001 is violated by configuration, not by the theme. This is a release-gate
  check for the operational procedure, not something the theme can enforce.
- Keycloak's own message keys used by these steps are stable across 26.2 and 26.3; FR-018 removes the
  dependency on Keycloak shipping *complete* non-English bundles by defining the keys locally.
- Translations for new keys may arrive by the Crowdin pull request, but FR-017 requires all four
  bundles in the same change; a follow-up commit for locale parity does not satisfy it.
- The `weni`-realm logout iframe list and the Connect `postMessage` events in `template.ftl` stay as
  they are; this delivery does not change session or logout behavior. Holding that assumption is not
  free: the `connect:requestlogout` emission is gated on a flag only `login.ftl` passes, so keeping
  the behavior unchanged on an identity-first realm takes the deliberate work FR-023 requires.
- No automated UI test suite exists in this repository, so every success criterion is verified
  manually in the Compose container (NFR-001) and the review gate is the primary control
  (Constitution VI).

## Constitution Compliance

| Principle | How this spec complies |
| --- | --- |
| I. Theme-First | Every requirement is expressed as `.ftl`, `theme.properties`, `messages/*.properties`, or CSS under `themes/ilhasoft/login/`. FR-022 forbids a new build step. |
| II. Keycloak Flow Compatibility | FR-013 preserves every existing template; FR-001 and FR-006 keep Keycloak's field names and action URLs. Story 3 tests the untouched flows. FR-023 keeps the one outbound `postMessage` contract alive on the screen that replaces `login.ftl`. |
| III. Four-Locale Copy | FR-017 requires all four bundles in one change with `en` as Crowdin source; FR-018 closes the silent per-key English-fallback gap left by base's partial non-English bundles; FR-019 binds the VTEX Content Guide. **Recorded divergence**: the 13 keys re-declared under FR-018 are copied from base verbatim, so `messages_en.properties` will carry base's inherited wording including its "please" (`missingPasswordMessage=Please specify password.`), which Principle III's copy rule forbids. Rewording them would change copy on screens FR-013 freezes, so the divergence is accepted and recorded here. FR-019 binds only copy this delivery authors; correcting base's inherited English is a follow-up change of its own. |
| IV. One Design System | FR-003 reuses the existing UNNNIC composition; FR-021 forbids a second UI kit and requires new rules to extend the stylesheets already in `styles=`. |
| V. Vendored Migration SPI | NFR-003 excludes `keycloak-user-migration/`. |
| VI. Bounded Scope | NFR-004 limits the diff to `themes/ilhasoft/login/`. The `ro` language-selector defect is named and explicitly bounded out rather than fixed opportunistically. |

One divergence is claimed and recorded, in the Principle III row above. No other is claimed.

## Traceability

| Product spec | This spec |
| --- | --- |
| PS-FR-001 (first step: email only, three third-party actions unchanged) | FR-001, FR-002, FR-003, FR-004, FR-005 |
| PS-FR-002 (mapped domain redirects, no password on that attempt) | FR-001, FR-006, FR-009; routing itself is Out of Scope |
| PS-FR-003 (password remains on the second step) | FR-006, FR-008 |
| PS-FR-004 (no "Okta or Google" choice after email submit) | FR-006 (step 2 renders no provider block) |
| PS-FR-005 (doors A/B/C yield the same session) | Out of Scope — session issuance is Keycloak's |
| PS-FR-006, PS-FR-007, PS-FR-008, PS-FR-009, PS-FR-010, PS-FR-014, PS-FR-015, PS-FR-016, PS-FR-017 | Out of Scope — organization policy and identity routing |
| PS-FR-007 (per-organization enforcement; dual membership) | No theme requirement — the organization-selection screen is deferred (Out of Scope) |
| PS-FR-011 (no configuration UI in v1) | Honored by omission — this delivery adds no settings screen |
| PS-FR-012 (provider-agnostic blocked-organization copy) | Out of Scope — Connect web app |
| PS-FR-013 (direct-start identifiers must not leak a tenant) | FR-020, plus the unknown-`kc_idp_hint` edge case |
| PS-NFR-001, PS-NFR-002 | NFR-005; step 1 originates no network call of its own |
| PS-NFR-003 (support-explainable without leaking configuration) | FR-020 |
| PS-NFR-004 (enabling customer 2 needs no new login product) | FR-004 — the theme is provider-generic, so a second customer adds no theme work |
| PS-NFR-005 (keyboard, accessible names, announced errors, four locales) | FR-014, FR-015, FR-016, FR-017, FR-018, FR-019 |
| PS-BD-001 (no public Okta button; single issuer) | FR-004 |
| PS-BD-002 (door A is the product) | Story 1 is P1 |
| PS-BD-003 (identity-first is realm-wide) | FR-001, FR-006, FR-009; Story 3 keeps non-identity-first realms working |
| PS-BD-004 (routing and enforcement are two layers) | Out of Scope for the theme |
| PS-BD-005 (Keycloak is the issuer; no configuration UI) | Whole-spec premise; realm configuration is Out of Scope |
| PS-BD-006 (invite-only) | Out of Scope |
| PS-BD-007 (staging-correct flow before visual polish) | FR-003 inherits provider appearance; Story 4 is P2; the organization-selection screen is deferred; FR-014 is excluded from the deferral |
| PS-BD-008 (OIDC by default, SAML if forced) | No theme impact — the theme never renders the protocol |
| PS-BD-009 (no platform password except support domains) | Out of Scope |
