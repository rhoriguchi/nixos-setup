# AGENTS.md - NixOS Configuration Repository

Personal flake-based NixOS + home-manager configuration (flake-parts).
Targets: `x86_64-linux`, `aarch64-linux`. Other languages: shell, Python,
Markdown (docs for non-NixOS devices only).

## Critical Rules

- Contains hardware-specific configs. NEVER build or deploy on a system
  other than the target host.
- Deploying applies changes immediately. Prefer a single host; deploy only
  when explicitly asked. Ensure the SSH connection cannot break.
- Never commit secrets or credentials.
- Never use `with`; use dotted access (`pkgs.foo`) or
  `inherit (attrset) name;`.
- Always run `treefmt .` before committing.

## Commands

Run inside `nix develop` (provides all tools). Hosts are reachable as
`ssh root@<hostname>`.

```bash
treefmt .                      # Format all Nix files (nixfmt)
nixfmt <file>                  # Format a single file
deadnix <file>                 # Lint for dead variables

nix flake check --keep-going   # Full validation
nix flake show                 # List outputs (--json for machine output)
nix build .#packages.x86_64-linux.<package>
nix build .#checks.x86_64-linux.<check> --no-link
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Deployment (deploy-rs)

```bash
# Dry run: builds only, applies nothing. Use to verify evaluation/build.
deploy --keep-result --skip-checks --dry-activate '.#<hostname>'   # '.' = all hosts

# Deploy: applies immediately.
deploy --magic-rollback false --rollback-succeeded false --auto-rollback false \
  --keep-result --skip-checks '.#<hostname>'                       # '.' = all hosts
```

- Flags are chosen to keep builds fast and prevent hosts getting stuck; do
  not change them without understanding the rollback implications.
- If a deployment fails, inspect before retrying; never retry automatically.

## Pre-commit Checklist

1. `treefmt .`
2. `deadnix .` on changed files.
3. `nix build .#<affected-output>` for the specific change.
4. No secrets or credentials staged.

## Commit Messages

Check `git log --oneline -20` for examples first.

- Subject line only: no body, footer, `Co-authored-by` or sign-off trailers.
- Imperative, capitalized verb (`Add`, `Remove`, `Fix`, `Update`, `Rename`,
  `Extract`, `Simplify`, `Move`, `Bind`, `Handle`, `Scope`, `Track`), as if
  completing "This commit will ...". No trailing period.
- Well under 72 characters, one line (no hard-wrap).
- State the effect, not the diff (`Add nix-topology`, `Fix nginx_status`,
  `Remove samba server`).
- Sign every commit.
- One commit per fix/feature; a flake update is its own separate commit.
- App version bumps: `Update <name> version`.
- From inside the sandbox never stage `AGENTS.md` or `AGENTS.project.md`
  (sandbox-generated). Stage files individually, or exclude both with
  pathspecs (`':!AGENTS.md' ':!AGENTS.project.md'`).

## Nix Code Style

- `nixfmt` formatting (via `treefmt`): 2-space indent, max 80 columns.
- Argument order: standard inputs first (`{ config, lib, libCustom, pkgs,
  inputs', ... }:`), then `let` with local imports, then the module body.
- New options: use the `options = { ... }; config = { ... };` module
  pattern (mandatory). Profile/grouping modules that only combine existing
  configs may use a bare `config = lib.mkIf ... { ... };`.
- `lib.mkOption`: always set a specific `type` (`lib.types.str`,
  `lib.types.listOf lib.types.str`, ...) and a `description`.
- Use `lib.mkDefault` for sensible defaults, `lib.mkIf` for conditional
  attribute sets (avoid `optionalAttrs` and `//` chains), and `assertions`
  plus proper types to validate input.
- Package sets: `{ pkgs, ... }: { name = pkgs.callPackage ./name { }; }`.
- Never use `rec`; avoid `builtins.*` when a `lib.*` equivalent exists
  (exceptions: `builtins.path`, `fetchTarball`, `getFlake`).
- Use `lib.pipe` for chained operations and full (unabbreviated) variable
  names.
- Overlays: prefer `prev` over `final`; combine with
  `lib.composeManyExtensions` instead of `builtins.foldl'`.
- Explicit-parameter style: `function = var: expr var`.
- Use arithmetic (`60 * 5`) instead of magic numbers.
- Reference unit names via `config.systemd.services.<name>.name` so
  renames fail the build. Prefer `systemd.services.<name>.script` (adds
  `set -euo pipefail`). Order units with explicit `wants`/`after`, not
  `RestartSec` loops; per-app files only declare their own dependencies.
- Set only non-default fields; remove comments before committing.
- JSON templates: build from an attrset with `toJSON`; secrets via
  `config.sops.placeholder`.

### File and attribute naming

- Files: kebab-case (`nix-config.nix`). Exceptions: `_common.nix` (shared
  internal imports); files in `disko/` and device-specific hardware configs
  may use the hostname's casing (`XXLPitu-Aizen.nix`).
- Options and other attributes: camelCase. Flake outputs: kebab-case.

## sops Secrets

### Secret and template naming

- `sops.secrets.<name>`: the `/`-separated path matching its location in
  `secrets.yaml` exactly (`services/rustdesk/privateKey`, `users/xxlpitu`,
  `wifis/${ssid}`). `key` defaults to `name`; never override it just to
  rename, whether the secret is read directly (`.path`, `.owner`) or via
  `sops.placeholder.<name>`. Any explicit `key` uses `/` as the separator.
- `sops.templates.<name>`: dot notation describing what it generates
  (`services.webdav.environmentFile`, `services.deluge.authFile`,
  `networking.wireless.secretsFile`).

### Shared keys

A `secrets.yaml` key declared or referenced by more than one module on the
same host MUST NOT use its bare name in those modules:

- Give each consumer its own `sops.secrets` entry named `<consumer>+<key>`
  with `key = "<key>"`; keep no unprefixed entry
  (`borgmatic+services/tvTrackTime/postgres/password`,
  `headplane+services/headscale/apiKey`,
  `headscale+services/headscale/apiKey`).
- `<consumer>` is the service/module that reads the secret (`radarr`,
  `bazarr`, `declarr`, `openweather`), not the secret's owner.
- Use the prefixed name everywhere that consumer touches it: `.path`,
  `sops.placeholder`, `owner`/`group`, `restartUnits`/`reloadUnits`. This
  applies even when owners are equal, so `owner` and `restartUnits` never
  silently merge.
- Several references from one module (secret + template + exporter +
  `LoadCredential`) are one consumer and share one entry.
- A key used by one consumer, or on different hosts, stays bare.

### Restart/reload

- Put `restartUnits`/`reloadUnits` on the leaf a unit actually reads: the
  TEMPLATE when the secret is only consumed via `sops.placeholder.<name>`
  (templates already restart on rendered-content change); also the secret
  if it is also/only read directly. Omit for secrets with no running unit
  (e.g. `hashedPasswordFile`/`neededForUsers`, read by PAM/activation).
- Prefer `reloadUnits` when the unit defines `ExecReload` and re-reads the
  secret on reload (`bind`'s `rndc reload`, `netdata`'s `SIGHUP`). Use
  `restartUnits` for units without `ExecReload` or that load secrets only
  at start (`LoadCredential`, `EnvironmentFile`, `preStart`).

### Modules

`modules/default/*` never reference `config.sops.*` (secrets are runtime
files, not eval-time strings). Take a file-path option (e.g. `apiKeyFile`),
or an `internal` rendered-text option when the value must be inlined in
generated text; the host wraps it via `sops.placeholder`/`sops.templates`.

## Project Structure

- `.github/` - GitHub Actions workflows and automation.
- `configuration/` - common NixOS configs; host-specific ones under
  `devices/`. Non-NixOS devices (e.g. Windows) are documented in a
  `README.md` in their subdirectory.
- `disko/` - Disko partition layouts, usually named after the host.
- `modules/default/` - service modules, auto-loaded via
  `libCustom.getImports ./.;` in `modules/default/default.nix`.
- `modules/home-manager*/` - home-manager modules (core CLI, GNOME,
  Hyprland, ...). Wired in `flake.nix` via `users.<username>.imports`.
- `modules/profiles/` - logical groupings (`gaming`, `headless`, ...),
  mapped manually in `modules/profiles/default.nix`.
- `overlays/` - custom nixpkgs overlays.

New modules must be placed in the matching directory and, where
registration is manual (profiles, home-manager), added to its `default.nix`
or `flake.nix` entry.
