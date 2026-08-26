<!--
Sync Impact Report
==================
Version change: none (unfilled template) → 1.0.0
Bump rationale: Initial ratification. The previous file was the unpopulated
scaffold with no project-specific governance, so this is the first real version.

Modified principles:
- [PRINCIPLE_1_NAME] (placeholder) → I. Theme-First
- [PRINCIPLE_2_NAME] (placeholder) → II. Keycloak Flow Compatibility
- [PRINCIPLE_3_NAME] (placeholder) → III. Four-Locale User-Facing Copy
- [PRINCIPLE_4_NAME] (placeholder) → IV. One Design System
- [PRINCIPLE_5_NAME] (placeholder) → V. Vendored Migration SPI
- (new slot beyond template) → VI. Bounded Scope

Added sections:
- Runtime & Delivery Constraints (fills [SECTION_2_NAME]/[SECTION_2_CONTENT])
- Development Workflow (fills [SECTION_3_NAME]/[SECTION_3_CONTENT])
- Governance (fills [GOVERNANCE_RULES])

Removed sections: none. Template guidance comments dropped once replaced.

Follow-up TODOs: none. All placeholders resolved; no bracket tokens remain.
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

Rationale: Keycloak loads themes by convention, and the deployed artifact is a plain
`themes.tar.xz` (see `.github/workflows/build-keycloak-push-tag-release.yaml`). Any
stack that needs a build step outside `theme.properties` would not ship.

### II. Keycloak Flow Compatibility

The behavior of Keycloak's login, registration, password reset and update, OTP/TOTP,
and email flows MUST be preserved unless a spec explicitly states the change. Keycloak
internals MUST NOT be rewritten or forked; templates MUST keep using the `${url.*}`,
`${msg(...)}`, and form-action contracts the base theme provides. Removing a form field,
hidden input, or action URL that Keycloak requires is a breaking change and requires an
explicit spec statement.

Rationale: `themes/ilhasoft/login/theme.properties` sets `parent=base`, so these
templates are overrides of Keycloak's own flows. Silent divergence breaks
authentication in production, not just visually.

### III. Four-Locale User-Facing Copy

Any change to user-facing copy MUST keep `en`, `pt_BR`, `es`, and `ro` in sync in both
`themes/ilhasoft/login/messages/` and `themes/ilhasoft/email/messages/`. Adding a key to
`messages_en.properties` without adding it to the other three locales is incomplete work.
`messages_en.properties` is the Crowdin source of truth and MUST hold the authoritative
wording. Copy MUST follow the VTEX Content Guide: sentence case, no "please", no
interjections, no exclamation marks outside celebratory success messages.

Rationale: `crowdin.yml` registers only these two message directories with
`messages_en.properties` as source, and `.github/workflows/crowdin-upload.yaml` pushes on
every change to those paths. A key missing from a locale renders as a raw key to the user.

### IV. One Design System

UI work MUST reuse the existing UNNNIC components and theme CSS already wired through
`theme.properties` — the `unnnic-*` FreeMarker elements backed by
`themes/ilhasoft/login/resources/vue/unnnic.umd.js`, and the stylesheets declared in the
`styles=` key. A parallel UI kit, component library, or CSS framework MUST NOT be added.
New styles MUST extend the existing CSS files listed in `styles=` rather than introducing
competing conventions; new stylesheets require a `styles=` entry and a stated reason.

Rationale: `themes/ilhasoft/login/theme.properties` already declares the full style
chain (`css/login.css css/unnic.css css/password-update.css css/otp-settings.css`).
A second kit would double the CSS payload and produce two visual languages on one screen.

### V. Vendored Migration SPI

`keycloak-user-migration/` is a vendored third-party Keycloak SPI
(`com.danielfrak.code.keycloak.providers.rest`) and MUST NOT be treated as part of the
theme. It MUST be modified only when a spec names it as the target. When it is modified,
its existing JUnit tests under `keycloak-user-migration/src/test/java/` MUST be updated
alongside the change and `sh ./mvnw clean package` MUST pass, because the release build
runs it.

Rationale: The plugin and the theme are separate deployables (`plugins.tar.xz` vs
`themes.tar.xz`) with separate upstream lineage. Mixing them makes upstream updates
unmergeable and couples a styling change to authentication storage behavior.

### VI. Bounded Scope

Each spec MUST cover one bounded change. Reverse-engineering or refactoring the whole
theme as a side effect of a scoped change is prohibited. Files outside the stated scope
MUST NOT be edited opportunistically. Secrets — credentials, Crowdin or DockerHub tokens,
realm admin passwords — MUST NOT be committed; they belong in GitHub Actions secrets or
local environment variables.

Rationale: This is a shared authentication surface with no automated UI test suite, so
blast radius is controlled by review, and review only works when the diff is small enough
to read.

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

1. **Locate before writing.** Identify the exact `.ftl`, `theme.properties`, CSS file, or
   message keys involved, and confirm which of the four theme types (`login`, `account`,
   `admin`, `email`) is affected.
2. **Follow the neighbors.** Existing files in the same theme type are the reference for
   structure, class names, and message-key naming. Match them.
3. **Change copy in all four locales in the same change.** No follow-up commit for
   locale parity.
4. **Verify in the running container.** Bring up Docker Compose and exercise the actual
   flow — the real login, reset-password, or OTP screen — not just the changed file.
5. **Verify the plugin build when the plugin changed.** Run its Maven build and tests.
6. **Review gate.** A change is reviewable only if it states which principle governs it
   and, when it diverges, why. Diffs touching unrelated files are sent back.

## Governance

This constitution supersedes ad-hoc convention for work in this repository. When a spec,
plan, or task conflicts with a principle here, this document wins and the spec MUST be
corrected.

- **Amendments** MUST be made by updating this file with an accompanying Sync Impact
  Report, and MUST be reviewed like any other change.
- **Versioning** follows semantic versioning: MAJOR for removing or redefining a principle
  in a backward-incompatible way, MINOR for adding a principle or materially expanding
  guidance, PATCH for clarifications and wording.
- **Compliance** is verified at review time. Reviewers MUST check locale parity, that the
  change stayed inside its stated scope, that no Keycloak flow contract was silently
  dropped, and that no secret was committed.
- **Justified divergence** is allowed but never silent: it MUST be recorded in the spec
  with the principle it departs from and the reason.
- **Evidence rule**: rules are added here only when this repository evidences them. A
  practice borrowed from another stack MUST NOT be added on the assumption it applies.

**Version**: 1.0.0 | **Ratified**: 2026-08-26 | **Last Amended**: 2026-08-26
