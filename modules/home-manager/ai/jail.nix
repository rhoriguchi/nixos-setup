{
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
}:
let
  homeDirectory = config.home.homeDirectory;
  configHome = config.xdg.configHome;

  jail = libJail.init pkgs;

  sharedPkgs = [
    config.programs.git.package
    osConfig.nix.package

    pkgs.bashInteractive
    pkgs.bzip2
    pkgs.coreutils
    pkgs.curl
    pkgs.diffutils
    pkgs.file
    pkgs.findutils
    pkgs.gawk
    pkgs.git-crypt
    pkgs.gnugrep
    pkgs.gnupg
    pkgs.gnused
    pkgs.gnutar
    pkgs.gzip
    pkgs.jq
    pkgs.nano
    pkgs.openssh
    pkgs.procps
    pkgs.unzip
    pkgs.which
    pkgs.xz
    pkgs.zip
    pkgs.zstd

    pkgs.nixfmt
    pkgs.nixfmt-tree
    pkgs.deadnix

    pkgs.poetry
    pkgs.python3
    pkgs.uv
  ]
  ++ lib.optional config.programs.gh.enable config.programs.gh.package
  ++ lib.optional osConfig.programs.git.lfs.enable osConfig.programs.git.lfs.package
  ++ lib.optionals osConfig.programs.java.enable [
    osConfig.programs.java.package
    pkgs.maven
  ]
  ++ lib.optionals osConfig.programs.npm.enable [
    osConfig.programs.npm.package
    pkgs.nodejs
    pkgs.typescript
    pkgs.yarn
  ]
  ++ lib.optionals osConfig.services.postgresql.enable [
    osConfig.services.postgresql.package
    pkgs.pgformatter
  ];

  mountCwd = jail.combinators.add-runtime ''
    REAL_PWD=$(realpath "$PWD")
    RUNTIME_ARGS+=(--chdir "$REAL_PWD")

    if [ "$REAL_PWD" = "${homeDirectory}" ]; then
      for entry in "$REAL_PWD"/*; do
        [ -e "$entry" ] || continue
        RUNTIME_ARGS+=(--bind "$entry" "$entry")
      done

      for allowed_config in git gh; do
        entry="$REAL_PWD/.config/$allowed_config"
        [ -e "$entry" ] || continue
        RUNTIME_ARGS+=(--bind "$entry" "$entry")
      done
    else
      RUNTIME_ARGS+=(--bind "$REAL_PWD" "$REAL_PWD")
    fi
  '';

  denyGitCryptFiles = jail.combinators.add-runtime ''
    git_root=$(${config.programs.git.package}/bin/git -C "$REAL_PWD" rev-parse --show-toplevel 2>/dev/null || true)

    if [ -n "$git_root" ]; then
      while IFS= read -r encrypted_path; do
        [ -n "$encrypted_path" ] || continue
        abs_path="$git_root/$encrypted_path"

        if [ -e "$abs_path" ]; then
          exec {deny_fd}< <(printf '%s\n' "This file is git-crypt encrypted and has been hidden from this sandboxed agent.")
          RUNTIME_ARGS+=(--ro-bind-data "$deny_fd" "$abs_path")
        fi
      done < <(cd "$git_root" && timeout 5 ${pkgs.git-crypt}/bin/git-crypt status -e 2>/dev/null | sed -n 's/^[[:space:]]*encrypted: //p' || true)
    fi
  '';

  writeSandboxAgentsFile =
    agentName: pkgsList:
    let
      packages = lib.pipe pkgsList [
        (map (pkg: {
          name = lib.getName pkg;
          version = lib.getVersion pkg;
        }))
        lib.unique
        (lib.sort (a: b: a.name < b.name))
      ];

      sshHosts = lib.pipe (config.programs.ssh.settings or { }) [
        builtins.attrNames
        (lib.remove "*")
        (lib.sort (a: b: a < b))
      ];

      notice = pkgs.writeText "jail-agents-md-${agentName}" ''
        # Sandbox Environment

        This project is opened inside a `bubblewrap` sandbox for the `${agentName}` agent. The sandbox restricts filesystem access to keep the rest of the host safe.

        ## What you can do

        - Read and write freely anywhere under this project directory (its bind-mounted root).
        - Reach the network (DNS, HTTP/HTTPS, git remotes, package registries, etc.).
        - Use `git`, with your SSH agent and GPG agent forwarded, so signed commits/tags and SSH remotes work normally.
        - Use `ssh` directly; your SSH agent and `~/.ssh/config`/`known_hosts` are forwarded, so every host listed below is reachable out of the box.
        - Use `gh` (GitHub CLI); it is pre-authenticated if the host has it configured.
        - Use package-manager caches (pip/uv, poetry, npm, yarn, Maven) that persist across sandbox runs.

        ## What you can NOT do

        - Access files outside this project directory, aside from a few forwarded config/cache paths; the rest of the host filesystem is not visible.
        - Write to the Nix store; it is mounted read-only.

        ## Available packages

        ${lib.concatMapStringsSep "\n" (package: "- ${package.name} ${package.version}") packages}

        ## SSH hosts

        ${lib.concatMapStringsSep "\n" (sshHost: "- ${sshHost}") sshHosts}

        ## Need another tool?

        The Nix store is mounted read-only, but `nix` itself is available inside the sandbox. Run e.g.:

            nix shell nixpkgs#ripgrep

        to get a temporary tool without leaving the sandbox.
      '';

      projectReference = pkgs.writeText "jail-agents-md-${agentName}-project-ref" ''

        ---

        ## Project instructions

        This project's own instructions are in `AGENTS.project.md`, not here. Always read it too. It is a writable view of the project's real `AGENTS.md`; edits to it are written straight through to the real `AGENTS.md` on the host, so the project stays normal outside the sandbox.

        ## Do not commit this file

        This `AGENTS.md` is a synthetic sandbox notice, not a real file in the repository — it only exists inside the sandbox and is not tracked at this path. Because of that, `git status` will show it as modified (and `AGENTS.project.md` as untracked): this is expected sandbox noise, not a real change.

        - Never `git add`, `git commit`, or otherwise stage `AGENTS.md` from inside the sandbox.
        - Never `git add`/commit `AGENTS.project.md` either; it is the writable stand-in for the real `AGENTS.md`, tracked under that name, not this one.
        - When staging changes (`git add -A`, `git commit -a`, etc.), explicitly exclude both paths, e.g. `git add -A -- . ':!AGENTS.md' ':!AGENTS.project.md'`, or stage files individually.
        - To change the project's real instructions, edit `AGENTS.project.md`; the write goes straight through to the host's `AGENTS.md` and will appear correctly in the next commit made outside the sandbox.
      '';
    in
    jail.combinators.compose [
      (jail.combinators.add-runtime ''
        REAL_PWD=$(realpath "$PWD")
        agents_file="$REAL_PWD/AGENTS.md"
        project_agents_file="$REAL_PWD/AGENTS.project.md"

        if [ -e "$agents_file" ]; then
          created_project_placeholder=1
          RUNTIME_ARGS+=(--bind "$agents_file" "$project_agents_file")
          exec {agents_fd}< <(cat ${notice} ${projectReference})
        else
          created_agents_placeholder=1
          exec {agents_fd}< <(cat ${notice})
        fi

        RUNTIME_ARGS+=(--ro-bind-data "$agents_fd" "$agents_file")
      '')

      (jail.combinators.add-cleanup ''
        [ -n "''${created_project_placeholder-}" ] && rm -f "$project_agents_file"
        [ -n "''${created_agents_placeholder-}" ] && rm -f "$agents_file"
        true
      '')
    ];

  forwardSsh = jail.combinators.compose [
    (jail.combinators.try-fwd-env "SSH_AUTH_SOCK")

    (jail.combinators.add-runtime ''
      if [ -n "''${SSH_AUTH_SOCK-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        RUNTIME_ARGS+=(--bind "$SSH_AUTH_SOCK" "$SSH_AUTH_SOCK")
      fi
    '')

    (jail.combinators.add-runtime ''
      if [ -e "${homeDirectory}/.ssh/config" ]; then
        exec {ssh_config_fd}<"${homeDirectory}/.ssh/config"
        RUNTIME_ARGS+=(--ro-bind-data "$ssh_config_fd" "${homeDirectory}/.ssh/config")
      fi
    '')

    (jail.combinators.try-readonly "${homeDirectory}/.ssh/known_hosts")
  ];

  forwardGpgAgent = jail.combinators.compose [
    (jail.combinators.write-text "${homeDirectory}/.gnupg/common.conf" "use-keyboxd")

    (jail.combinators.add-runtime ''
      GPG_AGENT_SOCKET=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket 2>/dev/null || true)
      if [ -n "$GPG_AGENT_SOCKET" ] && [ -S "$GPG_AGENT_SOCKET" ]; then
        RUNTIME_ARGS+=(--bind "$GPG_AGENT_SOCKET" "$GPG_AGENT_SOCKET")
      fi

      GPG_KEYBOXD_SOCKET=$(${pkgs.gnupg}/bin/gpgconf --list-dirs keyboxd-socket 2>/dev/null || true)
      if [ -n "$GPG_KEYBOXD_SOCKET" ] && [ -S "$GPG_KEYBOXD_SOCKET" ]; then
        RUNTIME_ARGS+=(--bind "$GPG_KEYBOXD_SOCKET" "$GPG_KEYBOXD_SOCKET")
      fi
    '')
  ];

  forwardWaylandClipboard = jail.combinators.compose [
    (jail.combinators.try-fwd-env "WAYLAND_DISPLAY")
    (jail.combinators.try-fwd-env "XDG_RUNTIME_DIR")
    (jail.combinators.try-fwd-env "XDG_SESSION_TYPE")

    (jail.combinators.add-runtime ''
      if [ -n "''${WAYLAND_DISPLAY-}" ] && [ -n "''${XDG_RUNTIME_DIR-}" ] && [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        RUNTIME_ARGS+=(--bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY")
      fi
    '')
  ];

  bindDragDropSources = jail.combinators.compose [
    (jail.combinators.try-readonly "${homeDirectory}/Downloads")
    (jail.combinators.try-readonly "${homeDirectory}/Pictures")
  ];

  forwardGh = jail.combinators.compose [
    (jail.combinators.add-runtime ''
      GH_TOKEN=$(${pkgs.libsecret}/bin/secret-tool lookup service gh:github.com username rhoriguchi 2>/dev/null || true)

      if [ -n "$GH_TOKEN" ]; then
        RUNTIME_ARGS+=(--setenv GH_TOKEN "$GH_TOKEN")
      fi
    '')

    (jail.combinators.try-readonly "${configHome}/gh")
  ];

  forwardNix = jail.combinators.compose [
    (jail.combinators.set-env "NIX_REMOTE" "daemon")
    (jail.combinators.readonly "/nix/store")
    (jail.combinators.try-readonly "/etc/nix/nix.conf")
    (jail.combinators.try-readonly "/etc/nix/registry.json")
    (jail.combinators.try-readwrite "/nix/var/nix/daemon-socket/socket")
    (jail.combinators.try-readwrite "${config.xdg.cacheHome}/nix")
  ];

  mountJailTmp = jail.combinators.add-runtime ''
    RUNTIME_ARGS+=(--bind "$(mktemp -d)" /tmp)
  '';
in
{
  inherit (jail) combinators;

  mkJailedAgent =
    {
      package,
      name ? package.meta.mainProgram,
      extraPkgs ? [ ],
      extraPermissions ? [ ],
    }:
    let
      allPkgs = [ package ] ++ sharedPkgs ++ extraPkgs;

      jailed = jail name package (
        [
          (jail.combinators.set-hostname osConfig.networking.hostName)
          jail.combinators.network
          jail.combinators.time-zone

          mountCwd

          denyGitCryptFiles
          (writeSandboxAgentsFile name allPkgs)

          (jail.combinators.try-readonly "/usr/bin/env")

          (jail.combinators.try-fwd-env "LOCALE_ARCHIVE")
          (jail.combinators.try-fwd-env "EDITOR")
          (jail.combinators.try-fwd-env "NIX_PATH")

          forwardGh
          forwardGpgAgent
          forwardNix
          forwardSsh
          forwardWaylandClipboard
          bindDragDropSources

          (jail.combinators.try-readonly "${configHome}/git")
          (jail.combinators.try-readonly "${homeDirectory}/.nanorc")

          (jail.combinators.try-readwrite "${homeDirectory}/.cache/pypoetry")
          (jail.combinators.try-readwrite "${homeDirectory}/.cache/uv")
          (jail.combinators.try-readwrite "${homeDirectory}/.cache/yarn")
          (jail.combinators.try-readwrite "${homeDirectory}/.m2")
          (jail.combinators.try-readwrite "${homeDirectory}/.npm")

          mountJailTmp

          (jail.combinators.add-pkg-deps allPkgs)
        ]
        ++ extraPermissions
      );
    in
    pkgs.symlinkJoin {
      inherit (package) name pname version;

      paths = [ jailed ];
      postBuild = ''
        ln -s ${package}/bin/${name} $out/bin/${name}-unwrapped
        ln -s ${pkgs.runtimeShell} $out/bin/${name}-bwrap

        rm "$out/bin/${name}"
        substitute "${jailed}/bin/${name}" "$out/bin/${name}" \
          --replace-fail "#!${pkgs.runtimeShell}" "#!$out/bin/${name}-bwrap"
        chmod +x "$out/bin/${name}"
      '';
    };
}
