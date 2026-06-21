{ lib, ... }:
{
  getImports =
    dir:
    lib.pipe (lib.readDir dir) [
      (lib.mapAttrsToList (
        name: type: {
          path = dir + "/${name}";
          inherit type name;
        }
      ))

      (lib.filter (
        file:
        if file.type == "directory" then
          lib.pathExists (file.path + "/default.nix")
        else
          lib.hasSuffix ".nix" file.name && file.name != "default.nix"
      ))

      (map (file: file.path))
    ];

  relativeToRoot = lib.path.append ./.;

  hyprland = rec {
    mkWindowRules = attrs: map (match: { inherit match; } // attrs);

    _mkLuaCommand =
      let
        toLua = args: lib.generators.toLua { } args;

        dispatcherMap = {
          dpms = args: "hl.dsp.dpms(${toLua { action = args; }})";
          dragWindow = _: "hl.dsp.window.drag()";
          exec = args: "hl.dsp.exec_cmd(${toLua args})";
          killActive = _: "hl.dsp.window.close()";
          resizeWindow =
            args: if args == "" then "hl.dsp.window.resize()" else "hl.dsp.window.resize(${toLua args})";
          moveFocus = args: "hl.dsp.focus(${toLua { direction = args; }})";
          moveToWorkspace =
            args:
            "hl.dsp.window.move(${
              toLua {
                workspace = args;
                follow = true;
              }
            })";
          moveWindow = args: "hl.dsp.window.move(${toLua args})";
          submap = args: "hl.dsp.submap(${toLua args})";
          switchWorkspace = args: "hl.dsp.focus(${toLua { workspace = args; }})";
          toggleFloating = _: "hl.dsp.window.float(${toLua { action = "toggle"; }})";
          toggleFullscreen = _: "hl.dsp.window.fullscreen()";
          togglePseudo = _: "hl.dsp.window.pseudo()";
        };
      in
      {
        dispatcher,
        args ? "",
      }:
      lib.generators.mkLuaInline (dispatcherMap.${dispatcher} args);
    mkLuaExecCommand =
      command:
      _mkLuaCommand {
        dispatcher = "exec";
        args = command;
      };

    mkBindRule =
      {
        mods ? "",
        key,
        dispatcher,
        args ? "",
        flags ? { },
      }:
      {
        _args = [
          (if mods == "" then toString key else "${mods} + ${toString key}")
          (_mkLuaCommand { inherit dispatcher args; })
        ]
        ++ lib.optional (flags != { }) flags;
      };
    mkExecBindRule =
      {
        mods ? "",
        key,
        command,
        flags ? { },
      }:
      mkBindRule {
        inherit mods key flags;
        dispatcher = "exec";
        args = command;
      };
  };
}
