{ lib, ... }:
{
  getImports =
    let
      getFiles = dir: lib.attrNames (builtins.readDir dir);
      filter =
        file:
        if lib.pathIsDirectory file then
          lib.elem "default.nix" (getFiles file)
        else
          lib.hasSuffix ".nix" file && !(lib.hasSuffix "default.nix" file);
    in
    dir: lib.filter filter (map (file: dir + "/${file}") (getFiles dir));

  relativeToRoot = lib.path.append ./.;

  hyprland = rec {
    mkWindowRules = attrs: builtins.map (match: { inherit match; } // attrs);

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
