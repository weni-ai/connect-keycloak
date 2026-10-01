<!--
Sync Impact Report
==================
Version change: 1.0.0 → 2.0.0
Bump rationale: MAJOR. Governance is redefined: the VTEX CX engineering base
constitutions (root + frontend) now take precedence over the project layer, and
the former "Evidence rule" is narrowed to project-layer rules. Principle VI is
redefined (its secrets clause moves to Principle VIII). New MUST rules make an
existing artifact non-conformant (spec 001 inheritance format, see TODOs).
Principles I–VI keep their numbers so existing spec references stay valid.

Modified principles:
- III. Four-Locale User-Facing Copy → III. Four-Locale User-Facing Copy and
  Internationalization (absorbs frontend "Internationalization")
- IV. One Design System (absorbs the design-token rule of frontend "Styling
  Standards", instantiated as the `--unnnic-*` custom properties)
- VI. Bounded Scope (secrets clause moved to VIII)

Added principles:
- VII. Version Control and Review (root)
- VIII. Security and Secrets (root)
- IX. Observability (root)
- X. Versioned Contracts (root)
- XI. Specification Traceability (root)
- XII. No Silent Divergence (root)
- XIII. Commit Messages (root)
- XIV. Release Versioning and Changelog (root "Changelog Maintenance")
- XV. Code as Documentation (frontend)
- XVI. Type Safety (frontend, with explicit project exception)
- XVII. Single Responsibility (frontend)
- XVIII. Naming Conventions (frontend, with explicit in-DOM component exception)
- XIX. Component Architecture (frontend)
- XX. Styling Standards and BEM (frontend "Styling Standards" + "BEM Methodology")
- XXI. State Management (frontend)
- XXII. Async State Correctness (frontend)
- XXIII. API Integration and Data Boundaries (frontend "API Integration" +
  "API and Data Boundaries")

Added sections:
- Quality Standards: Testing, Accessibility, Performance, Defensive
  Programming, Maintainability (frontend)

Modified sections:
- Development Workflow: product-spec inheritance, commit, and pull-request steps
- Governance: precedence chain, applicability, transition rule for specs
  planned under 1.0.0, evidence rule scoped to the project layer

Removed sections: none.

Explicit exceptions to base articles (each justified in its article):
- XVI Type Safety: TypeScript not required while Principle I forbids a build step
- XVIII Naming Conventions: in-DOM Vue components are kebab-case
- XIX Component Architecture: `.ftl` templates cannot be grouped in folders
- IV / XX: email HTML uses inline literal styles instead of tokens and classes
- Quality Standards / Testing: no unit tests required for theme JavaScript;
  manual verification in the running container is the compensating control
- XIV: Keep a Changelog is scoped to public libraries; this repo is a deployable

Templates:
- .specify/templates/spec-template.md ⚠ pending: has no "Inheritance from
  Product Spec" section required by XI. Authors add it by hand until the
  template is updated in a separate change.
- .specify/templates/plan-template.md ✅ no change (Constitution Check is generic)
- .specify/templates/tasks-template.md ✅ no change

Follow-up TODOs (current state that does not yet comply):
- TODO(PR_CI): no workflow runs on pull requests; VII requires a green CI run.
  Minimum gate: `sh ./mvnw clean package` in `keycloak-user-migration/`.
- TODO(BRANCH_PROTECTION): `master` protection (≥1 approval, required checks,
  direct pushes blocked) could not be verified from the local checkout.
- TODO(CONSOLE_PII): `themes/ilhasoft/login/template.ftl` writes the autofilled
  username input value to the browser console with `console.log` (IX).
- TODO(SPI_LOG_PII): `UserModelFactory` (INFO) and `LegacyProvider` (WARN) log
  the username, a personal identifier (IX). Changing them needs a spec (V).
- TODO(UNUSED_ASSETS): `login/resources/vue/vue.js` and
  `login/resources/vue/unnnic.umd.js` are not referenced; only the `.min.js`
  builds are loaded (Quality Standards / Performance).
- TODO(RO_LOCALE): `ro` is missing from `kc2UnnnicLanguages` in
  `login/template.ftl` and from `locales=` in `email/theme.properties` (III).
- TODO(SPEC_001_INHERITANCE): `specs/001-okta-login-theme/spec.md` uses a table
  instead of the exact XI format. Convert when the spec is next amended.
- TODO(CROWDIN_COMMITS): Crowdin pull requests commit as "New Crowdin
  translations by GitHub Action", which does not follow XIII.
- TODO(DEP_SCAN): no vulnerability check runs for Maven dependencies or vendored
  JavaScript (`common/resources` pins AngularJS 1.6.6 and jQuery 3.2.1), and the
  vendored Vue and Unnnic bundles have no recorded upstream version (VIII).
- TODO(FOCUS_AUDIT): `login/resources/css/login.css` sets `outline: none` in
  three rules; confirm each has a visible focus replacement (Accessibility).
- TODO(THEME_TESTS): decide whether a dev-only JavaScript test runner is
  acceptable under Principle I; if so, lift the Testing exception.
- TODO(TEMPLATE_SIZE): `login/template.ftl` is 503 lines, above the XVII limit.

Provenance:
- Source: weni-ai/vtex-cx-engineering-constitutions (main @ a516a7c0c25a24486f965c2875d47c62d27c637c)
- Bases: base-constitution.md, frontend/base-constitution.md
- Domains: frontend
- Project layer: this repository (Keycloak 26 theme `ilhasoft` + vendored
  user-migration SPI)
-->

# connect-keycloak Constitution

## Core Principles

### I. Theme-First

All login, account, admin, and email UI work MUST live under `themes/ilhasoft/`
and MUST follow the Keycloak theme layout already present in this repo: a
`theme.properties` per theme type, FreeMarker `.ftl` templates, `messages/*.properties`
for copy, and `resources/` for CSS, images, and JS. New frontend stacks, build
pipelines, bundlers, or template engines MUST NOT be introduced. A change that
cannot be expressed as theme files is out of scope for a theme spec.

**Rationale:** Keycloak loads themes by convention, and the deployed artifact is a plain
`themes.tar.xz` (see `.github/workflows/build-keycloak-push-tag-release.yaml`). Any
stack that needs a build step outside `theme.properties` would not ship.

### II. Keycloak Flow Compatibility

The behavior of Keycloak's login, registration, password reset and update, OTP/TOTP,
and email flows MUST be preserved unless a spec explicitly states the change. Keycloak
internals MUST NOT be rewritten or forked; templates MUST keep using the `${url.*}`,
`${msg(...)}`, and form-action contracts the base theme provides. Removing a form field,
hidden input, element ID, or action URL that Keycloak requires is a breaking change and
requires an explicit spec statement.

**Rationale:** `themes/ilhasoft/login/theme.properties` sets `parent=base`, so these
templates are overrides of Keycloak's own flows. Silent divergence breaks
authentication in production, not just visually.

### III. Four-Locale User-Facing Copy and Internationalization

User-facing strings MUST NOT be hardcoded in `.ftl` templates or JavaScript; they MUST
come from message bundles through `msg(...)`. This includes accessible names
(`aria-label`, `alt`) and email subjects.

Any change to user-facing copy MUST keep `en`, `pt_BR`, `es`, and `ro` in sync in both
`themes/ilhasoft/login/messages/` and `themes/ilhasoft/email/messages/`, in the same
change, before merge. Adding a key to `messages_en.properties` without adding it to the
other three locales is incomplete work. `messages_en.properties` is the Crowdin source
of truth and MUST hold the authoritative wording. Copy MUST follow the VTEX Content
Guide: sentence case, no "please", no interjections, no exclamation marks outside
celebratory success messages.

Locale wiring MUST stay consistent with the message files: a locale is supported only
when it has bundles and is listed wherever the theme selects a language (`locales=` in a
`theme.properties` that declares it, and `kc2UnnnicLanguages` in `login/template.ftl`).
Date and number formatting MUST follow Keycloak's current locale (`locale.current`).

**Rationale:** `crowdin.yml` registers only these two message directories with
`messages_en.properties` as source, and `.github/workflows/crowdin-upload.yaml` pushes on
every change to those paths. A key missing from a locale renders as a raw key to the
user, and a locale with bundles but no wiring is silently unavailable.

### IV. One Design System

UI work MUST reuse the existing Unnnic components and theme CSS already wired through
`theme.properties` — the `unnnic-*` elements backed by
`themes/ilhasoft/login/resources/vue/unnnic.umd.min.js`, and the stylesheets declared in
the `styles=` key. A parallel UI kit, component library, or CSS framework MUST NOT be
added. New styles MUST extend the existing CSS files listed in `styles=` rather than
introducing competing conventions; new stylesheets require a `styles=` entry and a
stated reason.

Theme CSS MUST use the Unnnic design tokens defined as custom properties in
`login/resources/css/unnic.css` instead of hardcoded values whenever a token exists:
`var(--unnnic-space-{n})` for spacing, `var(--unnnic-color-*)` for color, and
`var(--unnnic-font-*)` for typography. Raw pixel values for spacing MUST NOT be
introduced, and the deprecated `--unnnic-spacing-*` names MUST NOT be used. New tokens
are declared only in `css/unnic.css`.

Exception — email HTML: templates under `email/html/` MUST use inline literal values,
because email clients do not reliably support CSS custom properties or stylesheets.
Those literals SHOULD match an Unnnic token value (for example `#E0E0E0` is
`--unnnic-color-gray-3`).

**Rationale:** `themes/ilhasoft/login/theme.properties` already declares the full style
chain (`css/login.css css/unnic.css css/password-update.css css/otp-settings.css`).
A second kit would double the CSS payload and produce two visual languages on one
screen. Tokens keep the theme aligned with the rest of the Weni product as the design
system evolves.

### V. Vendored Migration SPI

`keycloak-user-migration/` is a vendored third-party Keycloak SPI
(`com.danielfrak.code.keycloak.providers.rest`) and MUST NOT be treated as part of the
theme. It MUST be modified only when a spec names it as the target. When it is modified,
its existing JUnit tests under `keycloak-user-migration/src/test/java/` MUST be updated
alongside the change and `sh ./mvnw clean package` MUST pass, because the release build
runs it.

**Rationale:** The plugin and the theme are separate deployables (`plugins.tar.xz` vs
`themes.tar.xz`) with separate upstream lineage. Mixing them makes upstream updates
unmergeable and couples a styling change to authentication storage behavior.

### VI. Bounded Scope

Each spec MUST cover one bounded change. Reverse-engineering or refactoring the whole
theme as a side effect of a scoped change is prohibited. Files outside the stated scope
MUST NOT be edited opportunistically. Code that predates a rule in this constitution is
brought into compliance when it falls inside a change's scope, not by sweeping edits.
Secrets are governed by Principle VIII.

**Rationale:** This is a shared authentication surface with no automated UI test suite,
so blast radius is controlled by review, and review only works when the diff is small
enough to read.

### VII. Version Control and Review

All changes MUST enter `master` through a pull request. A merge MUST require at least
one approved review and a green CI run. Direct pushes to `master` MUST be blocked by
GitHub branch protection. CI on pull requests MUST at least run the SPI build
(`sh ./mvnw clean package` in `keycloak-user-migration/`), the same command the release
build runs. Because version tags deploy directly (see Runtime & Delivery Constraints), a
production tag (`X.Y.Z`) MUST point to a commit on `master`.

**Rationale:** The policy is only real when the platform enforces it. Peer review and a
protected branch keep history auditable and stop unreviewed changes from reaching the
login screen of every Weni user.

### VIII. Security and Secrets

Secrets MUST never be committed. CI credentials (DockerHub, Crowdin, the
`kubernetes-manifests-connect` token) MUST live in GitHub Actions secrets and be
referenced as `${{ secrets.* }}`; `crowdin.yml` MUST name environment variables, never
values. Runtime credentials — realm admin passwords, the SPI's legacy-API token — MUST
be injected at deploy time or configured in Keycloak, never stored in this repository.
The `admin`/`admin` values in `docker-compose.yml` are local `start-dev` defaults and
MUST NOT be used in any deployed environment.

Access MUST follow least privilege; workflows SHOULD declare `permissions:` explicitly,
as `crowdin-download.yaml` does. Dependencies MUST come only from trusted sources: Maven
via `mvnw` for the SPI, yarn with a committed `yarn.lock` for
`common/resources/node_modules`, and an identified upstream release for every vendored
bundle under `login/resources/vue/`. Dependencies MUST be checked for known
vulnerabilities.

**Rationale:** Leaked credentials and untrusted dependencies are among the most common
and damaging breaches. On an identity provider the damage is account takeover across
every product that trusts it.

### IX. Observability

Logs MUST be structured and MUST never contain secrets or personal data — passwords,
tokens, usernames, emails, or form values. The SPI MUST log through Keycloak's logger
(`org.jboss.logging.Logger`) so the runtime's structured log format applies. Theme
JavaScript MUST NOT write user data to the browser console, and debug `console.log`
calls MUST NOT be merged; `console.warn` is acceptable for theme setup failures such as
a missing Unnnic component. Errors MUST be traceable across components: SPI failures
MUST carry identifiers that correlate them with the Keycloak event that triggered them,
without using personal data as the identifier.

**Rationale:** Structured, privacy-safe telemetry makes authentication incidents
diagnosable without turning logs and browser consoles into a new source of personal
data exposure.

### X. Versioned Contracts

Every public interface of this repository MUST be versioned with SemVer. Changes MUST
be backward compatible or ship with an announced deprecation path; silent breaking
changes MUST NOT be introduced. Public interfaces here are:

- the release tags, the DockerHub image `connectof/keycloak:<tag>`, and the
  `themes.tar.xz` / `plugins.tar.xz` artifacts, including the theme name `ilhasoft`
  and the archive layout that `weni-ai/kubernetes-manifests-connect` consumes;
- the URL parameters the login theme reads from callers (`redirect_uri` →
  `vtex_app` → `email`);
- the `postMessage` protocol sent to the embedding Connect app
  (`connect:<event>:<json>`, for example `connect:requestlogout`);
- the REST contract the SPI expects from the legacy user API.

Keycloak's own flow contracts are governed by Principle II.

**Rationale:** The Connect web app, the deployment manifests, and the legacy user
service depend on these interfaces. Explicit versioning and deprecation give them a
predictable path to adapt without a login outage.

### XI. Specification Traceability

Every engineering spec in `specs/<NNN-name>/spec.md` MUST derive from exactly one
approved product spec (product specs live in `weni-ai/vtex-cx-experience-specs`) and
MUST reference it through an immutable, pinned version (commit or tag); a mutable URL,
branch name, or ID alone MUST NOT be used. The product spec MUST exist and be tagged
before its engineering spec is created. An engineering spec MUST NOT redefine the
"what" it inherits: problem, scope, success criteria, and binding decisions belong to
the product spec. A technical architecture document SHOULD be produced for non-trivial
features; when it exists it MUST be linked from the engineering spec, pinned by commit
or tag, but its absence MUST NOT block the engineering spec.

Every engineering spec MUST open with an inheritance section in exactly this format:

```
## Inheritance from Product Spec
- Product Spec: <title> — <URL>
- Pinned version: <commit/tag>
- Architecture doc: <none | URL + commit/tag>
- Inherited binding decisions: <short list>
- Scope of this spec: <slice implemented by this repo>
- Divergences: <none | link to amendment>
```

**Rationale:** Traceability from product intent to technical execution keeps decisions
auditable. Pinning guarantees every team implements the same version of the feature
instead of divergent readings of a spec that changed mid-flight. A single inheritance
format keeps the link machine-checkable across repositories.

### XII. No Silent Divergence

When a technical need contradicts something inherited from the product spec — scope,
success criteria, or a binding decision — the divergence MUST NOT be implemented
silently in code. It MUST be raised as an amendment in `weni-ai/vtex-cx-experience-specs`
and recorded in the `Divergences` field of the engineering spec's inheritance section,
linking to that amendment. Once the amendment is approved and tagged, the engineering
spec's `Pinned version` MUST be updated to it. A technical difference that contradicts
nothing inherited is an implementation decision and MUST live in the engineering spec.

**Rationale:** The product spec is the single source of truth. A silent code deviation
makes intent and implementation drift apart with no audit trail.

### XIII. Commit Messages

Commits MUST follow Conventional Commits: `<type>: <description>`. Allowed types:
`feat`, `fix`, `docs`, `refactor`, `test`, `chore`. The description MUST be imperative,
specific, and no longer than 50 characters. Commits MUST be atomic: one logical change
per commit. This applies to authored commits and squash-merge titles; automated commits
(Crowdin translation pull requests) MUST be configured to the same format.

**Rationale:** Conventional commits enable automated changelogs and semantic versioning.
Atomic commits simplify bisecting, reverting, and reviewing.

### XIV. Release Versioning and Changelog

Release tags MUST follow SemVer: `X.Y.Z` for production, `X.Y.Z-staging` and
`X.Y.Z-develop` for pre-production, matching the tag filters in `.github/workflows/`.
This repository ships deployable artifacts rather than a library consumed as a
dependency, so the base requirement that public libraries keep a changelog does not
apply. If a `CHANGELOG.md` is introduced, it MUST follow Keep a Changelog, with every
user-facing change under Added, Changed, Deprecated, Removed, Fixed, or Security.

**Rationale:** The tag drives which environment receives a release, so its format is
operational, not cosmetic. SemVer gives the manifests repository a predictable upgrade
order.

### XV. Code as Documentation

All code — identifiers, comments, and documentation in `.ftl`, JavaScript, CSS, and
Java — MUST be written in English. Domain terms or acronyms that only have meaning in
the original language MAY remain untranslated. Message bundle values are translations,
not code. Code MUST prioritize readability over brevity. Every non-trivial decision
MUST be documented with a comment explaining the "why", not the "what"; in templates
these SHOULD be FreeMarker comments (`<#-- -->`) so they do not ship in rendered HTML.

**Rationale:** A globally readable codebase enables cross-team collaboration. Comments
that explain reasoning stop future changes from breaking invariants they cannot see,
such as the Vue 2 compatibility shim in `login/template.ftl`.

### XVI. Type Safety

The base rule that new files MUST be TypeScript with strict mode is suspended in this
repository by explicit exception. Keycloak serves `resources/` as-is and renders `.ftl`
on the server, and Principle I forbids the build step TypeScript needs. Theme
JavaScript MUST therefore be plain browser JavaScript that runs without compilation.
This exception lapses if a spec amends Principle I to allow a build step; from then on,
new script files MUST be TypeScript with `strict` enabled, and `any` SHOULD be avoided
except at untyped library boundaries.

**Rationale:** Static typing is valuable, but a rule that cannot ship is a rule that
gets ignored. Stating the exception and its lapse condition keeps the base intent
intact.

### XVII. Single Responsibility

Each file SHOULD contain no more than 350 lines. Each function MUST have one
responsibility. Template logic MUST live in the Vue app's `computed` properties or
`methods` (as `canLogin` and `canSubmitUsername` do), not inline in attribute
expressions. Complex conditions, in Vue or in FreeMarker `<#if>`, MUST be named as a
descriptive boolean: a computed property or an `<#assign>`. New logic that does not
need FreeMarker interpolation SHOULD go in a script under `login/resources/js/` rather
than growing `login/template.ftl`.

**Rationale:** Small, focused units are easier to review and change. `template.ftl`
hosts the single Vue app for every login screen, so each addition to it raises the cost
of every future login change.

### XVIII. Naming Conventions

Variables and functions MUST use `camelCase`; message keys added by this theme MUST use
`camelCase`, matching Keycloak's. File and directory names MUST be lowercase, using
hyphens as the theme already does (`login-update-password.ftl`, `otp-settings.css`).
Names fixed by Keycloak — template file names, `theme.properties` keys such as
`kcFormClass`, base message keys — follow Keycloak and MUST NOT be renamed (Principle
II). Abbreviations MUST be avoided unless universally understood.

Exception — component names: the base requires `PascalCase`. Here components are used
in in-DOM templates, which the browser parses as case-insensitive HTML before Vue reads
them, so they MUST be registered and referenced in kebab-case (`unnnic-button`), as
`componentsToRegister` in `login/template.ftl` does.

**Rationale:** Consistent naming makes the theme searchable. The kebab-case exception
is a technical constraint of in-DOM templates, not a style preference.

### XIX. Component Architecture

UI MUST be built from Unnnic components registered once in `componentsToRegister` in
`login/template.ftl`; a component MUST be registered there before use. Shared markup
MUST be factored into FreeMarker macros (`registrationLayout`, `loginLayout`) rather
than copied between templates. Props MUST have descriptive names (`userEmail`, not
`val`). Custom events MUST be prefixed with `on`. Methods that update state SHOULD be
prefixed with `handle`. State MUST clearly reflect what it holds; booleans SHOULD read
as `is*` or `has*` (`isSubmitting`).

Exception — folders: Keycloak resolves login and email templates by fixed file name,
so `.ftl` files cannot be grouped in subfolders. Resources are grouped by type under
`resources/` (`css/`, `js/`, `img/`, `vue/`).

**Rationale:** A single registration point and named macros make it obvious which
components and layouts exist. Clear interface names reduce integration errors.

### XX. Styling Standards and BEM

CSS selectors MUST use classes. IDs that Keycloak or its scripts depend on
(`kc-form-login`, `username`, `password`) MUST stay in markup (Principle II), but new
CSS MUST NOT target IDs. Nested selectors, whether native CSS nesting or long
descendant chains, SHOULD be avoided. Tokens are governed by Principle IV.

New class names MUST follow BEM: blocks are independent components (`.totp-info`),
elements use double underscores (`.totp-info__text`), and modifiers use double hyphens
(`.totp-info--{modifier}`). Elements MUST NOT be nested in class names
(`.block__elem`, not `.block__elem1__elem2`). Class names supplied by Keycloak or
PatternFly through `kc*Class` keys in `theme.properties` (`login-pf-page`, `card-pf`)
are external and exempt. Email HTML is exempt for the reason given in Principle IV.

**Rationale:** `login.css` already carries ID selectors that make overrides
unpredictable. Class-only, flat BEM naming prevents specificity wars and keeps
selectors scoped as the theme grows.

### XXI. State Management

The root Vue app created in `login/template.ftl` (`Vue.createApp({ data() … })`) is the
designated store for login-screen state. State MUST NOT be duplicated: a value from the
Keycloak FreeMarker model (`login.username`, `register.formData.*`) MUST be read into
`data()` once and referenced from there. Related state SHOULD be grouped in objects, as
`passwordRules` is. State only one component needs SHOULD stay local to that component.

**Rationale:** One store per page keeps data flow traceable. Two copies of the same
field drift apart, which on a login form means submitting a value the user did not see.

### XXII. Async State Correctness

Async operations — form submissions to Keycloak action URLs (`${url.loginAction}`) and
any client-side request — MUST track loading, success, and error states. Submit
controls MUST be disabled while a submission is in flight, using the existing
`submitting` mechanism (`@submit="submitting = true"` with `:disabled="submitting || …"`).
Errors returned by Keycloak (`message`, `messagesPerField`) MUST be rendered to the
user; failures MUST NOT be silent. Contradictory states, such as loading and error at
once, MUST be prevented. Optimistic updates MUST be rolled back on failure.

**Rationale:** A double-submitted login or OTP form can lock an account or burn a
one-time code. Users must always know whether their sign-in is in progress, failed, or
done.

### XXIII. API Integration and Data Boundaries

The login theme's I/O today is form posts to Keycloak and `postMessage` to the parent
window; it makes no client-side HTTP calls. Any client-side API call MUST live in a
dedicated script under `login/resources/js/`, separate from the Vue app, with explicit
error handling; API errors MUST NOT surface as unhandled exceptions, and loading and
error state MUST follow Principle XXII.

Internal code MUST use camelCase. External snake_case names MUST be normalized at the
boundary and MUST NOT leak into app state or templates; URL parameters such as
`redirect_uri` and `vtex_app` MUST be parsed once, at the top of the app script, into
camelCase values. Raw interfaces that intentionally represent an external contract MAY
keep its naming.

**Rationale:** Separating I/O from rendering keeps the Vue app focused and testable
by inspection. Normalizing at the edge keeps the rest of the theme consistent when an
external contract changes.

## Quality Standards

### Testing

Business logic MUST be covered by tests that verify behavior and outcomes, not
implementation details. Tests MUST NOT be added only to raise coverage, and a test that
would still pass after a regression MUST be fixed or removed.

- **SPI**: JUnit tests live in `keycloak-user-migration/src/test/java/`, mirroring the
  package of the code under test (the Maven equivalent of colocated tests), and MUST
  pass in `sh ./mvnw clean package`.
- **Theme — explicit exception**: unit tests are not required for theme JavaScript.
  Most of it is inline in `.ftl` files, interleaved with FreeMarker directives, and
  only exists after Keycloak renders it; the repository has no JavaScript toolchain by
  design (Principle I). The compensating control is mandatory: each spec MUST list the
  screens and flows to exercise, and the change MUST be verified against them in the
  Docker Compose runtime (Development Workflow step 5).

**Rationale:** Behavior-focused tests survive refactors. Where unit tests cannot run,
an explicit, spec-defined manual check is the only thing that keeps a regression off
the login screen.

### Accessibility

Interactive elements MUST be keyboard accessible. Form inputs MUST have associated
labels (the `label` of `unnnic-form-element` or an explicit `<label for>`). Icon-only
buttons, such as identity-provider buttons, MUST have an accessible name from a message
key. Images MUST have meaningful `alt` text, or `alt=""` when decorative, including in
email HTML. Color MUST NOT be the only means of conveying information: field errors
MUST include text, not only `--unnnic-color-fg-critical`. Focus states MUST be visible;
CSS MUST NOT remove `outline` without a visible replacement.

**Rationale:** Sign-in is the one screen every user must pass. An inaccessible login is
a locked door, and accessibility is a legal requirement in many jurisdictions.

### Performance

Unused dependencies and assets MUST be removed. Heavy computations on frequent events
(`input`, `scroll`, `resize`, `animationstart`) MUST be memoized or debounced. Images
and fonts MUST be optimized; icons SHOULD be SVG, as in `login/resources/img/login/`.
The size impact of a new vendored library or asset SHOULD be stated in the spec before
it is added, because every login page already loads `vue/unnnic.css` and
`vue/unnnic.umd.min.js`. Above-the-fold content SHOULD load first.

**Rationale:** The login page is the first load for every session, often on mobile
networks. Each extra kilobyte delays every user's access to the product.

### Defensive Programming

Defensive guards SHOULD only be added when the invalid state is realistically
reachable. Root causes MUST be fixed rather than masked. Guards MUST follow the
patterns already in the surrounding code: FreeMarker defaults (`!''`, `??`) where
Keycloak can legitimately omit a value, and early returns in JavaScript as in
`bindAutofillReconciliation` (`if (!component || !component.$el) return;`).

**Rationale:** Unneeded guards hide real logic and real bugs. Guards that match local
patterns read as intentional.

### Maintainability

Business rules MUST NOT be duplicated; each MUST have one source of truth. In
`login/template.ftl` the username validity rule appears in both `canLogin` and
`canSubmitUsername`, and the password rules in both `watch` and `mounted`; new rules
MUST NOT repeat that pattern, and changes touching those rules SHOULD consolidate them.
Local duplication of utility code MAY remain when extraction would create unnecessary
coupling. Abstractions SHOULD only be created for a pattern with several uses.

**Rationale:** A rule written twice is eventually changed once. Premature abstraction
creates coupling worse than the duplication it removes.

## Runtime & Delivery Constraints

- **Keycloak version**: Keycloak 26 (`quay.io/keycloak/keycloak:26.2.0`) is the reference
  runtime. Template and `theme.properties` syntax MUST be valid for that version.
- **Local runtime**: theme work MUST be verified against the Docker Compose setup, which
  mounts `themes/ilhasoft/` into the container and disables theme caching
  (`--spi-theme-cache-themes=false`, `--spi-theme-cache-templates=false`). "It looks right
  in the editor" is not verification.
- **Delivery**: tags matching `*.*.*`, `*.*.*-staging`, and `*.*.*-develop` trigger the
  DockerHub image build and the GitHub release that publishes `themes.tar.xz` and
  `plugins.tar.xz`. Changes MUST NOT depend on artifacts outside those two archives.
- **Translations**: translated files arrive by automated Crowdin pull request
  (`[CROWDIN] - New translations`). Hand-editing non-English message files is acceptable
  when a spec adds a key, but MUST NOT be used to override wording Crowdin owns.
- **`standalone.xml`**: retained for legacy reference and currently not mounted. It MUST
  NOT be treated as live configuration without a spec that re-enables it.

## Development Workflow

1. **Start from a product spec.** Open the engineering spec with the inheritance section
   from Principle XI, pinned to a tagged product spec.
2. **Locate before writing.** Identify the exact `.ftl`, `theme.properties`, CSS file, or
   message keys involved, and confirm which of the four theme types (`login`, `account`,
   `admin`, `email`) is affected.
3. **Follow the neighbors.** Existing files in the same theme type are the reference for
   structure, class names, and message-key naming. Match them, except where this
   constitution sets a newer rule for code in scope.
4. **Change copy in all four locales in the same change.** No follow-up commit for
   locale parity.
5. **Verify in the running container.** Bring up Docker Compose and exercise the actual
   flow — the real login, reset-password, or OTP screen — against the scenarios the
   spec lists, not just the changed file.
6. **Verify the plugin build when the plugin changed.** Run its Maven build and tests.
7. **Commit and open a pull request.** Atomic Conventional Commits (Principle XIII),
   one pull request into `master` with a green CI run and at least one approval
   (Principle VII).
8. **Review gate.** A change is reviewable only if it states which principle governs it
   and, when it diverges, why. Diffs touching unrelated files are sent back.

## Governance

This constitution supersedes ad-hoc convention for work in this repository. When a spec,
plan, or task conflicts with a principle here, this document wins and the spec MUST be
corrected. Plans MUST pass the Constitution Check against the current version, and
`/speckit-analyze` treats a conflict with a MUST as CRITICAL.

- **Precedence**: this document synthesizes three layers. The VTEX CX engineering root
  constitution prevails over the frontend domain constitution, which prevails over the
  project layer (`weni-ai/vtex-cx-engineering-constitutions`, see provenance in the Sync
  Impact Report). When the bases change, this file is re-synced with a new Sync Impact
  Report.
- **Applicability**: Principles XV–XXIII and Quality Standards apply to theme code under
  `themes/ilhasoft/`. The vendored SPI is governed by Principle V, the engineering
  principles VII–XIV, and the SPI rules in Quality Standards / Testing.
- **Amendments** MUST be made by updating this file with an accompanying Sync Impact
  Report, and MUST be reviewed like any other change.
- **Versioning** follows semantic versioning: MAJOR for removing or redefining a principle
  or governance rule in a backward-incompatible way, MINOR for adding a principle or
  materially expanding guidance, PATCH for clarifications and wording.
- **Compliance** is verified at review time. Reviewers MUST check the spec's pinned
  inheritance section, locale parity, that the change stayed inside its stated scope,
  that no Keycloak flow contract or public interface was silently changed, commit
  format, and that no secret or personal data was committed or logged.
- **Justified divergence** from a project-layer rule is allowed but never silent: it MUST
  be recorded in the spec with the principle it departs from and the reason. A spec
  MUST NOT waive a MUST derived from the base constitutions; that requires an explicit
  exception in this document, justified in the article.
- **Transition**: specs planned under 1.0.0 (`specs/001-okta-login-theme`) remain valid
  for their delivered scope and MUST be brought into compliance with this version,
  including the Principle XI inheritance format, when next amended.
- **Evidence rule**: project-layer rules are added here only when this repository
  evidences them; a practice borrowed from another stack MUST NOT be added on the
  assumption it applies. Base-derived rules apply by default and are adapted to this
  repository, or excepted with justification, never silently dropped.

**Version**: 2.0.0 | **Ratified**: 2026-08-26 | **Last Amended**: 2026-10-01
