# AGENTS.md - NixOS Configuration Repository

This file contains essential information for agentic coding agents working with this personal NixOS configuration repository.

## Repository Overview

- **Primary Language**: Nix (flake-based configuration)
- **Supporting Languages**: Shell scripts, Python, Markdown (for non-NixOS docs)
- **Architecture**: Modular flake-parts with NixOS and home-manager configurations
- **Target Systems**: x86_64-linux, aarch64-linux
- **⚠️ CRITICAL**: Contains hardware-specific configs. NEVER build/deploy on other systems.

## Essential Commands

### Development Environment

```bash
nix develop                    # Enter dev shell with all tools
```

### Formatting (ALWAYS run before committing)

```bash
nixfmt default.nix             # Format a Nix files
treefmt .                      # Format all Nix files
```

### Linting

```bash
deadnix default.nix            # Lint Nix file for dead variables
```

### Building and Testing

```bash
# Full flake validation
nix flake check --keep-going

# Build specific outputs
nix build .#packages.x86_64-linux.<package-name>
nix build .#checks.x86_64-linux.<check-name> --no-link
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Show available outputs
nix flake show
nix flake show --json
```

### Host access

```bash
# Each configured host can be access with its hostname
ssh root@hostname
```

## Code Style Guidelines

### Nix Formatting

- Use `Nixfmt` for all Nix files (automated via `nixfmt` or `treefmt`)
- Maximum line length: 80 characters
- 2-space indentation (Nixfmt default)

### Module Structure

```nix
# Standard module pattern (mandatory when defining new options)
{ config, lib, pkgs, ... }: {
  options = {
    # Module options here
  };

  config = {
    # Configuration here
  };
}

# Profile/Grouping pattern (acceptable for combining existing configs)
{ config, lib, pkgs, ... }: {
  # Direct configuration or lib.mkIf block
  config = lib.mkIf config.services.something.enable {
    # ...
  };
}
```

### Import and Attribute Conventions

```nix
# Input imports (first line)
{ config, lib, pkgs, ... }:

# Option definitions use lib.mkOption
options.myOption = lib.mkOption {
  type = lib.types.str;
  default = "default";
  description = "Description of the option";
};

# Conditional config
config = lib.mkIf condition {
  # Configuration
};
```

### Naming Conventions

- **Files**: kebab-case (e.g., `nix-config.nix`, `home-manager.nix`).
  - *Exception*: `_common.nix` is used for shared internal imports.
  - *Exception*: Files in `disko/` or device-specific hardware configs may use the Hostname's casing (e.g., `XXLPitu-Aizen.nix`).
- **Options**: camelCase (e.g., `myCustomOption`)
- **Attributes**: kebab-case for flake outputs, camelCase for options

### Type Definitions

- Always specify types with `lib.mkOption`
- Use specific types (`lib.types.str`, `lib.types.listOf lib.types.str`)
- Provide descriptions for all options
- Use `lib.mkDefault` for sensible defaults

### Error Handling

- Use `lib.mkIf` for conditional configuration
- Validate inputs with proper types and `assertions`

### Import Organization

```nix
# 1. Standard inputs (including libCustom if needed)
{ config, lib, libCustom, pkgs, inputs', ... }:

# 2. Local imports
let
  myHelper = import ../helpers.nix { inherit lib; };
in

# 3. Module body
{
  # Configuration
}
```

## File Organization Patterns

### Package Definitions

```nix
{ pkgs, ... }:
{
  advcp = pkgs.callPackage ./advcp { };
  myPackage = pkgs.callPackage ./my-package { };
}
```

## CI/CD Integration

### Validation Checklist Before Commit

1. ✓ Run `treefmt .` to format all files
2. ✓ Run `deadnix .` on changed files to lint Nix files
3. ✓ Test specific changes: `nix build .#<affected-output>`
4. ✓ Ensure no secrets or credentials are committed

## Project Structure

### Key Directories

- `.github/` - GitHub Actions workflows and repository automation
- `configuration/` - Host-specific (under `devices/`) and common NixOS configurations.
  - Contains subdirectories for non-NixOS devices (e.g., Windows) documented via `README.md`.
- `disko/` - Disk partitioning layouts using Disko, often named after the host.
- `modules/` - Modular NixOS and Home Manager configurations.
- `modules/default/` - Service-specific modules auto-loaded via `libCustom.getImports`.
- `modules/home-manager*/` - Home Manager modules for core CLI, GNOME, and Hyprland.
- `modules/profiles/` - Logical groupings of configurations (e.g., `gaming`, `headless`).
- `overlays/` - Custom Nixpkgs overlays.

### Module Loading

- Service modules in `modules/default/` are auto-loaded using `libCustom.getImports ./.;` in `modules/default/default.nix`.
- Profile modules are manually mapped in `modules/profiles/default.nix`.
- Home Manager modules are configured via `flake.nix` using `users.<username>.imports`.
- New modules should be added to their respective `default.nix` or directory structure to be discovered.
