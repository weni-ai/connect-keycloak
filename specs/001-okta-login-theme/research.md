# Phase 0 Research: Identity-first login theme (Enterprise Okta)

**Branch**: `feature/okta-login-theme` | **Date**: 2026-08-26 | **Spec**: [spec.md](./spec.md)

## How these answers were obtained

Nothing below is inferred from documentation. Every claim marked **Measured** was produced by
running Keycloak 26.2.0 with `themes/ilhasoft/` mounted and walking a real identity-first browser
flow, and every claim marked **Verified in bytecode** was produced by disassembling the shipped
Keycloak jars.

| Method | What it covered |
| --- | --- |
| `quay.io/keycloak/keycloak:26.2.0` + `themes/ilhasoft/` mounted, theme/template caching off | Rendered both steps, all four locales, error paths |
| A throwaway diagnostic theme (`parent=ilhasoft`) that dumps every template variable | `usernameHidden`, `auth.*`, `social.*`, `url.*`, `messagesPerField`, per-locale `msg()` |
| A real identity-first flow (`auth-cookie` ALT / `auth-username-form` REQ → `auth-password-form` REQ), bound as browser flow | Step 1 → step 2 transition, per-field errors, restart URL |
| `javap` over `keycloak-services`, `keycloak-server-spi-private`, `keycloak-themes` 26.2.0 | Where each attribute is set, and which no longer exist |

The probe realm, flow, and diagnostic theme were created inside a disposable container that has been
removed. No repository file was touched by the research.

## Corrections to the spec's Current State

Three corrections. The first two are statements in the spec that are factually wrong; neither changes
a requirement, but both change the reasoning a reviewer would apply. The third is a property of
`template.ftl` that no artifact had noticed and that does change the work — it added FR-023. All three
are recorded here rather than silently worked around.

### Correction 1 — `parent=base` does not mean "English only"

The spec says Keycloak's `base` theme ships **only** `messages_en.properties`. It ships **34** locale
bundles, including the three we care about. What varies is how complete they are:

| Bundle | Keys |
| --- | --- |
| `base/login/messages_en.properties` | 468 |
| `base/login/messages_es.properties` | 468 |
| `base/login/messages_pt_BR.properties` | 338 |
| `base/login/messages_ro.properties` | **34** |

**Verified in bytecode**: `LocaleUtil.getParentLocale` walks `pt-BR → pt → en`, and
`mergeGroupedMessages` overlays the more specific bundle on top of the less specific one. The
fallback is therefore **silent and per key**, not per bundle.

So FR-018's *requirement* is correct and necessary, but its *stated reason* is not. The real reason
is that base's non-English bundles are partial, and a key missing from one resolves to English
without any error. FR-018 should be read as "re-declare any base key whose target-locale bundle
lacks it", and the measured list is in Decision 4.

A second consequence of the `pt-BR → pt → en` chain: **Measured** — `showPassword` under `pt-BR`
resolves to `Mostrar palavra-passe`, which is European Portuguese, because base `messages_pt_BR`
lacks the key and `messages_pt` supplies it. A key can therefore be "not English" and still be
wrong.

### Correction 2 — `usernameEditDisabled` does not exist in Keycloak 26.2

**Verified in bytecode**: the string `usernameEditDisabled` appears in **no jar** in the 26.2.0
distribution. **Measured**: `usernameEditDisabled??` evaluated to `false` on every page of every
flow probed.

The theme relies on it in two places today:

```13:13:themes/ilhasoft/login/login.ftl
<#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
```

```37:37:themes/ilhasoft/login/login-form.ftl
<#if realm.rememberMe && !usernameEditDisabled??>
```

Both guards are permanently true, so they are dead conditions carried over from an older Keycloak.
`login-form.ftl` also carries a duplicate attribute — `:disabled="!!VTEXAppEmail"` on line 7 and
`:disabled="<#if usernameEditDisabled??>true<#else>false</#if>"` on line 9 on the same
`unnnic-input`. HTML keeps the first occurrence, so the second is inert and the field disables on
`VTEXAppEmail` alone, which happens to be the intended behavior.

**These are not fixed here.** They sit in `login.ftl` and `login-form.ftl`, which FR-013 freezes and
NFR-004 keeps out of the diff. They are recorded so the new templates do not copy the pattern, and
so a reviewer does not read the new `!usernameHidden??` guard as an unexplained deviation.

### Correction 3 — `displayLoginFormScriptsAndStyles` gates behavior, not just scripts and styles

The flag's name says scripts and styles. It actually gates three regions of `template.ftl`, and only
`login.ftl` passes it. Anything a new step needs from inside these is unavailable unless the guard is
widened, and two of the three fail **silently** rather than with an error:

| Lines | What is gated | Consequence for the new steps |
| --- | --- | --- |
| 197–202 | `loginUsername`, `loginPassword`, `loginPasswordVisible`, `rememberMe` in `data()` | `toggleLoginPasswordVisibility` is defined **ungated** at line 380, so on step 2 it would flip a property Vue never declared. The FR-006 show/hide toggle renders and does nothing |
| 227–232 | `canLogin` | Harmless, and wanted: FR-009 requires `canLogin` to stay bound to `login-form.ftl` |
| 328–341 | `emitConnectEvent` and the `connect:requestlogout` `postMessage` | The message stops firing on step 1, which replaces `login.ftl` as the first screen. This is the one outbound contract contracts/README.md says the change must not disturb |

The third is the dangerous one. Part 3's console check runs on the **default** browser flow, where
`login.ftl` still passes the old flag and the message still fires, so the existing verification
procedure cannot see the regression. FR-023 and quickstart check 5.10 exist because of this.

**Decision**: widen the guard around lines 197–202 and 328–341 to admit the new step flags —
`loginPasswordVisible` for step 2, the `requestlogout` emission for step 1 — and leave `canLogin`,
`loginUsername`, `loginPassword`, and `rememberMe` gated as they are. `rememberMe` in particular must
not reach step 1: FR-001 forbids a remember-me control there.

## Decision 1 — The third-party provider block goes in the `info` section

**Decision**: render the block inside `<#if section="info">` of the new `login-username.ftl`,
reproducing `login.ftl`'s markup verbatim, and pass `displayInfo=true` explicitly. Do **not** add
`<#nested "socialProviders">` to `template.ftl`.

**Why this is a real question**: Keycloak's own `login-username.ftl` puts providers in a dedicated
`socialProviders` section, and base's `template.ftl` nests it between the form and the info block.
Our `template.ftl` nests only `title`, `form`, and `info`. A section that is never nested is
silently discarded, so copying upstream's structure would make the providers disappear.

**Measured** — the `social` bean is available on the identity-first step:

| Page | `social??` | `social.providers?size` (3 IdPs enabled) |
| --- | --- | --- |
| `login.ftl` (default flow) | true | 3 |
| `login-username.ftl` (step 1) | true | **3** |
| `login-password.ftl` (step 2) | true | **0** |

**Verified in bytecode**: `social` is set in `FreeMarkerLoginFormsProvider.createCommonAttributes`,
which runs for every page, so its availability on step 1 is structural and not incidental.

The step-2 zero is the interesting result. `IdentityProviderBean` narrows the list to the
*authenticated user's linked brokers* once a user is established in the flow, so Keycloak itself
yields an empty list on step 2. FR-006's "no provider block on step 2" is therefore satisfied by
Keycloak as well as by the template — but the template must still avoid rendering an orphaned
separator or heading around an empty list, which is the spec's "no orphaned separator" edge case.

### The `social.displayInfo` trap

`login.ftl` opens with `displayInfo=social.displayInfo`. **Verified in bytecode**:
`IdentityProviderBean` in 26.2 exposes only `getProviders`, `getSession`, `getRealm`, `getBaseURI`,
and `getFlowContext`. There is **no** `displayInfo` property.

**Measured**: `social.displayInfo??` is `false`, the page renders **HTTP 200**, and the macro
parameter receives the value declared as the macro's default. Proven by declaring the default as
`false` in a probe template and observing `displayInfo_received=false`, then as `true` and observing
`true`.

So `displayInfo=social.displayInfo` in `login.ftl` has always meant `displayInfo=true`, because our
`template.ftl` declares `displayInfo=true`. It is a dead expression that looks meaningful.

The new template passes `displayInfo=true` so the intent is legible. Copying the existing expression
would propagate a misleading idiom into new code, and FR-005 requires the block's *position, keys,
and conditions* to match, not the macro call's dead arguments.

### The block's enclosing conditions are part of what FR-003 asks for

Reproducing the markup is not enough. `login.ftl` puts three visually distinct regions inside **one**
guard and leaves the footer outside it:

```13:13:themes/ilhasoft/login/login.ftl
<#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
```

That `<#if>` opens at line 13 and closes at line 43, so it covers the separator (14–18), the provider
list (19–34), **and** the sign-up block (35–42). The privacy footer (44–48) sits outside it. The
separator additionally carries `v-if="!VTEXAppEmail"`, and so does the sign-up block; the provider
list carries neither.

Two consequences a reviewer should not have to rediscover:

1. **Third-party login on `login.ftl` today depends on `realm.registrationAllowed`.** A realm with
   registration disabled shows no GitHub, Google, or Microsoft button at all. That reads like an
   oversight rather than a design, but FR-003 and SC-003 require parity and Constitution VI forbids
   fixing it in passing, so step 1 reproduces it. It is written into the spec's edge cases and checked
   in quickstart 8.9 so that it is a decision on the record.
2. **The probe realm sets `registrationAllowed=true`**, so no check in the original quickstart could
   distinguish a faithful reproduction from three regions split apart into independent guards. That is
   why the check was added rather than assumed.

The dead `!usernameEditDisabled??` third term is replaced by `!registrationDisabled??` per Decision 3;
the other two terms are reproduced as they are.

**Tradeoff accepted**: the theme diverges from upstream's section layout. The alternative — teaching
`template.ftl` to nest `socialProviders` — is rejected because it changes the shared layout for all
nine login screens, forces `login.ftl` to move its provider block to keep one convention, and so
breaks FR-003's byte-identical parity and SC-003 while enlarging the diff that NFR-004 bounds. The
`info` section already holds this exact block today, and reuse is what FR-003 asks for.

## Decision 2 — Per-step submit state, autofill, and single submit

**Decision**: add two macro flags and two computed properties to `template.ftl`, leave `canLogin`
untouched, drive enablement from a value reconciled against the DOM, and gate double submit on the
form's `submit` event.

### Per-step enablement without touching `canLogin` (FR-009)

`canLogin` requires a username **and** a password, and `login-form.ftl` depends on that. Adding
`canSubmitUsername` and `canSubmitPassword` alongside it, each gated by its own
`display*ScriptsAndStyles`-style macro flag, satisfies FR-009 without editing the existing property.

**Measured constraint on how flags are added**: passing an argument a macro does not declare is a
hard error, not a no-op. Reproduced against **base's** `registrationLayout` in the probe theme, which
is why the parameter list below is base's and not ours —

```text
freemarker.core._MiscTemplateException: Macro "registrationLayout" has no parameter with name
"displayLoginFormScriptsAndStyles". Valid parameter names are: bodyClass, displayInfo,
displayMessage, displayRequiredFields
```

Read the quote for the failure mode, not for the parameter list. This theme's own signature is
already wider, and it is the one T005 extends:

```1:1:themes/ilhasoft/login/template.ftl
<#macro registrationLayout bodyClass="" displayInfo=true displayMessage=true displayHeader=true displayRegisterScriptsAndStyles=false displayLoginFormScriptsAndStyles=false displaySocial=true>
```

Adding a parameter *with a default* is backward compatible: the eight existing callers keep working
untouched. Passing a new flag from a template before the parameter exists in `template.ftl` produces
an HTTP 500. This orders the implementation: `template.ftl` first, then the new templates.

**Measured, and load-bearing for FR-012**: on step 2, `login.username` is populated with the
submitted email (`login_username=user@example.com`). `template.ftl` seeds
`usernameInput: VTEXAppEmail || '${((login.username)!'')}'`, so on step 2 the Vue model already
holds the email even though no email field is rendered. This is precisely why step 2 must not reuse
`canLogin` — it would be half-satisfied by a value the user cannot see — and why FR-012's "not in any
form, visible or hidden" has to be checked in the DOM rather than in the Vue state.

### Autofill (FR-010)

The existing mechanism cannot be trusted. `login.css` defines `@keyframes onAutoFillStart` and hangs
it off `.input-itself:-webkit-autofill`, and `template.ftl` has a matching `animationstart` listener
— which only calls `console.log`:

```310:326:themes/ilhasoft/login/template.ftl
                if (this.$refs.loginUsername) {
                    this.$refs.loginUsername.$el.querySelector('input').addEventListener('animationstart', (event) => {
                        if (event.animationName === 'onAutoFillStart') {
                            setTimeout(() => {
                            console.log(this.$refs.loginUsername.$el.querySelector('input').value);

                            });
                        }
```

Two problems. The listener does nothing, and `class="input-itself"` is applied by UNNNIC to an inner
`base-input` **component**, so whether the class lands on the real `<input>` — the only element
`:autofill` can match — depends on that component's root node. `template.ftl` itself assumes it does
not, since it reaches the field via `$el.querySelector('input')`.

**Decision**: make the DOM the source of truth. After mount, and on `input` and `change`, copy the
inner `<input>`'s `.value` into the model that feeds the computed property, with a short bounded
reconciliation over the first few frames to catch password managers that write the field before
scripts settle. Keep the `animationstart` hook only as an extra trigger for the same reconciliation,
never as the sole path.

**Tradeoff accepted**: this is more JavaScript than a pure CSS-animation hook. The alternative
depends on a minified third-party component's root element and on `:autofill` support, and SC-009
("autofilled password enables submit without any keystroke") is a release gate. Reading `.value` is
correct in every browser regardless of how UNNNIC renders.

### Single submit (FR-011)

Base does this in one line — `onsubmit="login.disabled = true; return true;"`. Expressed in Vue: a
`submitting` flag set by the form's `@submit` handler, with `:disabled="submitting || !canSubmitX"`
on the button. The flag flips after the browser has already begun the submission, so it suppresses
the second activation without cancelling the first, and it needs no `name="login"` global that our
`unnnic-button` does not emit.

**Measured, worth knowing for the button markup**: `unnnic-button`'s `nativeType` prop defaults to
`""`. An empty `type` on a `<button>` falls back to `submit` per HTML's missing-value default, which
is why `login-form.ftl`'s button submits today without declaring `native-type`. The new templates
declare `native-type="submit"` explicitly, matching `login-reset-password.ftl`, so the behavior does
not rest on an invalid-value fallback.

## Decision 3 — Step 1 branches on `usernameHidden`, and this is confirmed, not assumed

**Decision**: guard step 1's email field with `!usernameHidden??` and its sign-up block with
`!registrationDisabled??`. Do not use `usernameEditDisabled??` in new code.

The spec asked for this to be stated as an assumption if it could not be confirmed without running
the flow. It was confirmed by running the flow.

**Verified in bytecode**: `usernameHidden` is a real `LoginFormsProvider` attribute, set in
`UsernamePasswordForm.authenticate()` — which `UsernameForm` inherits — and only on the branch where
`context.getUser() != null`. It is set together with `registrationDisabled`.

**Measured** across the identity-first flow:

| Variable | Step 1 (fresh) | Step 1 (after invalid submit) | Step 2 |
| --- | --- | --- | --- |
| `usernameHidden??` | false | false | false |
| `usernameEditDisabled??` | false | false | false |
| `registrationDisabled??` | false | false | false |
| `auth.showUsername()` | false | false | **true** |

`usernameHidden` is thus normally absent on step 1 — the field renders — and becomes `true` only when
a user is already established in the flow, which is exactly the case where the field must be hidden.
That is the semantics base's `<#if !usernameHidden??>` encodes, and reproducing it makes the new
template correct in a branch we are unlikely to exercise by hand.

**Reconciliation with FR-005 and FR-012**: FR-005 requires the sign-up block, separator, and footer
to keep "the same keys" and to honor "the existing `VTEXAppEmail` and `realm.registrationAllowed`
conditions". It does not require reproducing `!usernameEditDisabled??`, which is dead. The new
template keeps `realm.password && realm.registrationAllowed`, keeps the `v-if="!VTEXAppEmail"`
wrappers, and substitutes `!registrationDisabled??` for the dead guard — the condition Keycloak
actually sets, and equal to today's behavior in every case the flow can reach.

**Measured edge case that touches FR-012 and Story 1 scenario 6**: `VTEXAppEmail` is derived from the
`redirect_uri` query parameter of the current URL. After any submit, the browser is on
`/login-actions/authenticate?...`, which carries no `redirect_uri`, so the prefill and disabled state
are lost when step 1 re-renders after a validation error. This is pre-existing — `login.ftl` behaves
the same way — so it is not a regression, but the quickstart checks the first render rather than the
re-render, and the limitation is recorded rather than discovered at review.

## Decision 4 — New message keys, and the measured FR-018 list

### New keys

Only two new keys are needed. Everything else on both steps already exists in all four of the
theme's bundles.

| Key | en | pt_BR | es | ro |
| --- | --- | --- | --- | --- |
| `loginPasswordTitle` | `Enter password` | `Inserir senha` | `Ingresar contraseña` | `Introdu parola` |
| `doChangeEmail` | `Change email` | `Alterar e-mail` | `Cambiar email` | `Schimbă e-mailul` |

Both follow the Content Guide: sentence case, no trailing period, no "please", no interjection, no
pronoun, and at most three words. `doChangeEmail` is an action label in verb + object form and takes
the `do*` prefix the theme already uses for `doLogIn`, `doRegister`, and `doForgotPassword`.
`loginPasswordTitle` is the step-2 card heading and deliberately avoids the pronoun in the existing
`loginFormTitle` ("Log in to your account") rather than copying it.

**Flagged for copy review, not silently decided**: `Enter password` reads as an action label where
the guide prefers a noun phrase for titles, and the guide's own alternative — the bare noun
`Password` — duplicates the field label directly beneath it. `Change email` is proposed against the
guide's action-label rules; the glossary does not list "change", so the pt_BR, es, and ro wording
above should be confirmed against <https://contentguide.vtex.com/pt/docs/glossary> when the bundles
are edited, in the same change per FR-017.

### Keys reused with no new copy

- **Step 1 title**: `loginFormTitle`, already in all four bundles.
- **Provider accessible names (FR-014)**: `loginWith`, already in all four bundles — `Login with` /
  `Entrar com` / `Iniciar sesión con` / `Autentificare cu`. Composing
  `${msg('loginWith')} ${p.displayName!p.alias}` gives each button a provider-identifying name with
  zero new copy, which is the cheapest way to satisfy FR-014 and SC-007.
- **Placeholders**: `placeholderLoginEmail`, `placeholderLoginName`, `placeholderLoginPassword`, all
  present in all four bundles, as FR-002 requires.

### The FR-018 re-declaration list

Measured by rendering both steps in all four locales and comparing each resolved string against its
English resolution:

| Key | Surfaced by | pt-BR | es | ro |
| --- | --- | --- | --- | --- |
| `username` | step 1 label | ok | ok | **English** |
| `usernameOrEmail` | step 1 label | ok | ok | **English** |
| `email` | step 1 label | ok | ok (`Email` is correct Spanish) | **English** |
| `password` | step 2 label | ok | ok | **English** |
| `doForgotPassword` | step 2 link | ok | ok | ok |
| `restartLoginTooltip` | step 2 restart | ok | ok | **English** |
| `showPassword` / `hidePassword` | step 2 toggle | **pt-PT wording** | ok | **English** |
| `invalidUsernameOrEmailMessage` | step 1 error | ok | ok | **English** |
| `missingUsernameMessage` | step 1 error | ok | ok | **English** |
| `invalidPasswordMessage` | step 2 error | ok | ok | **English** |
| `missingPasswordMessage` | step 2 error | ok | ok | **English** |
| `invalidUserMessage` | generic error | ok | ok | **English** |
| `accountTemporarilyDisabledMessage` | lockout | ok | ok | **English** |

The functional gap is almost entirely Romanian: **10 of the 11** keys probed leak English under `ro`,
while `pt-BR` leaks none and `es` leaks none. `doForgotPassword` is the single key base translates
into Romanian.

**Decision**: follow FR-017 literally and add every key in the table to all four bundles, not just to
`messages_ro.properties`.

**Tradeoff accepted**: for `en`, `pt_BR`, and `es` this is functionally a no-op and duplicates ~13
keys that base already resolves. It is done anyway because it makes the bundles self-describing,
removes the dependency on base's per-locale completeness across the 26.2 → 26.3 range the release job
spans (NFR-002), and is what FR-017 says. The `ro` strings are genuinely new copy and must follow the
Content Guide.

**Wording rule for the re-declared keys**: copy base's existing per-locale wording verbatim for `en`,
`pt_BR`, and `es`. Do not "improve" it. These bundles are shared with `login.ftl`, `login-form.ftl`,
and every other screen, so rewriting `missingPasswordMessage` from `Please specify password.` would
change copy on screens FR-013 freezes. The `pt-BR` `showPassword` value is the one exception worth
correcting to Brazilian wording, because there the inherited string is wrong rather than merely
unfashionable. The guide's objection to "please" in the inherited English strings is recorded as a
follow-up, not resolved here.

**One asymmetry to note**: adding `showPassword` / `hidePassword` supports an `aria-label` on step 2's
show/hide toggle. The existing toggle in `login-form.ftl` has no accessible name and does not get one,
because FR-014 names only the provider buttons and NFR-004 bounds the diff. Step 2's toggle will
therefore be more accessible than step 1's legacy equivalent on `login.ftl`.

## Decision 5 — Step 2 can use `auth.attemptedUsername` and `url.loginRestartFlowUrl`

**Decision**: implement FR-007 with `auth.attemptedUsername` and `url.loginRestartFlowUrl`, guarded by
`auth?has_content && auth.showUsername()`. Confirmed by running the flow; not an assumption.

**Measured** on step 2 after submitting `user@example.com` on step 1:

```text
auth_present=true
auth_hasContent=true
auth_showUsername=true
auth_attemptedUsername=user@example.com
url_loginRestartFlowUrl=/realms/probe/login-actions/restart?client_id=probe-app&tab_id=...&skip_logout=false
auth_showTryAnotherWay=false
```

The concern was that `template.ftl` does not render Keycloak's `kc-username` block, so these values
might be scoped to it. They are not. **Verified in bytecode**: `auth` and `url` are both set in
`createCommonAttributes` for every page; base's `template.ftl` merely *chooses* to render them behind
`auth?has_content && auth.showUsername() && !auth.showResetCredentials()`.

The guard still matters. `AuthenticationContextBean.showUsername()` returns true only when the flow
context, the user, and the authentication session are all present and the page is not `ERROR`, and
`getAttemptedUsername()` returns `null` when the context is absent. Rendering `${auth.attemptedUsername}`
unguarded would throw on any page where a user is not established — including step 1, where
`showUsername()` is `false`.

`showResetCredentials()` is only true on the reset-password page, so step 2 does not need that part of
base's condition; `auth?has_content && auth.showUsername()` is sufficient and is what the template
will use.

`url.loginRestartFlowUrl` is available on step 1 as well, which is why FR-007's back control is a
plain link and needs no hidden form.

**A guard our probe learned the hard way**: `url.loginAction` is *not* present on every page —
referencing it on `error.ftl` throws `An error has occurred when reading existing sub-variable
"loginAction"` and returns HTTP 500. The new templates only render it inside their own forms, so they
are safe, but any `url.*` reference added to the shared `template.ftl` must be written defensively as
`${(url.x)!''}`.

## Incidental findings that change how the work is verified

1. **`?kc_locale=` does not switch the locale on the initial authorization request.** **Measured**:
   `.../protocol/openid-connect/auth?...&kc_locale=ro` renders English, on that request and on the
   next one in the same authentication session. The same parameter on
   `/login-actions/authenticate?...&execution=...&kc_locale=ro` switches correctly — that is the URL
   Keycloak itself puts in `locale.supported[].url`. `ui_locales=ro` works on the initial request;
   `KEYCLOAK_LOCALE=ro` as a cookie and `Accept-Language: ro` also work.

   This matters because SC-006 and the spec's Out of Scope note both prescribe `?kc_locale=ro` as the
   workaround for `ro` missing from `kc2UnnnicLanguages`. As written it silently tests English. The
   quickstart uses `ui_locales` for the first render and the language-selector URL thereafter.

2. **The Romanian language label is the raw tag.** **Measured**: `locale.supported` yields
   `[ro|ro|...]` where the other three yield `Portuguese (Brazil) (Português (Brasil))`, `Spanish
   (Español)`, `English`, because base has no `locale_ro` key. Cosmetic, and invisible while `ro` is
   absent from `kc2UnnnicLanguages`, but it will surface the moment that pre-existing defect is fixed.

3. **`message` and `messagesPerField` both fire on a step-1 validation error.** **Measured** on an
   empty submit: `messagesPerField.existsError('username')` is `true` with text
   `Invalid username or email.`, *and* `message.summary` is the same string with `message.type=error`.
   Our `template.ftl` renders the form-level `unnnic-disclaimer` whenever `displayMessage && message?has_content`,
   so a step that also renders a per-field error would show the same sentence twice.

   Base avoids this by passing `displayMessage=!messagesPerField.existsError('username')`. The new
   templates do the same — `('username')` on step 1, `('password')` on step 2 — which is how FR-015
   gets a per-field message without a duplicated form-level one.

4. **Cookies are `Secure` even over plain HTTP**, so scripted verification with `curl` needs the
   `Set-Cookie` values passed back by hand. Irrelevant to browser verification, noted so the
   quickstart's optional scripted checks are reproducible.

## Resolved unknowns

The Technical Context carried no `NEEDS CLARIFICATION` markers. All five questions the spec left open
are resolved above, and four of the five are resolved by measurement rather than by argument:

| Question | Resolution | Basis |
| --- | --- | --- |
| 1. Where the provider block lives | `info` section, `displayInfo=true` | Measured |
| 2. Per-step submit state, autofill, single submit | New flags + computed props; DOM-reconciled value; `@submit` flag | Measured constraints, design decision |
| 3. `usernameHidden` vs `usernameEditDisabled` | `usernameHidden`; the other does not exist in 26.2 | Measured + bytecode |
| 4. New keys, wording, FR-018 list | 2 new keys; 13 re-declared; `ro` is the real gap | Measured |
| 5. `auth.attemptedUsername` on step 2 | Available and populated; guard on `auth.showUsername()` | Measured |
