{ pkgs, lib, config, ... }:
let
  buildCommand = let pattern = ''.*BUILD_ID="[0-9]+\.[0-9]+(pre|\.)(\S*)".*'';
  in "cat /etc/os-release | tr '\\n' '\\r' | sed --regexp-extended 's/${pattern}/\\2/'";

  fileSystemLines = let
    paths = lib.filter (path: path != "/boot") (lib.attrNames config.fileSystems);
    sortedPaths = lib.sort (a: b: a < b) paths;

    lines = map (path:
      [
        "\${goto 24}\${color1}${path}: \${color2}\${fs_used ${path}}/\${fs_size ${path}} \${alignr}\${fs_used_perc ${path}}% \${color1}\${fs_bar 6, 124 ${path}}"
      ]) sortedPaths;
  in lib.concatStringsSep "\n  " (lib.flatten lines);

  interfaceLines = let
    interfaces = lib.filter (interface: interface != "vboxnet0") (lib.attrNames config.networking.interfaces);
    sortedInterfaces = lib.sort (a: b: a < b) interfaces;

    lines = map (interface: [
      "\${goto 24}\${color1}${interface}"
      "\${goto 24}\${color1}Speed Up: \${color2}\${upspeed ${interface}} \${alignr}\${color1}Speed Down: \${color2}\${downspeed ${interface}}\${voffset 8}"
      "\${goto 24}\${color1}\${upspeedgraph ${interface} 16, 175} \${alignr}\${downspeedgraph ${interface} 16, 175}"
      ""
    ]) sortedInterfaces;
  in lib.concatStringsSep "\n  " (lib.flatten lines);

  memoryLines = let
    lines = [ "\${goto 24}\${color1}RAM: \${color2}\${mem}/\${memmax} \${alignr}\${memperc}% \${color1}\${membar 6, 124}" ]
      ++ lib.optional (lib.length config.swapDevices > 0)
      "\${goto 24}\${color1}Swap: \${color2}\${swap}/\${swapmax} \${alignr}$swapperc% \${color1}\${swapbar 6, 124}";
  in lib.concatStringsSep "\n  " (lib.flatten lines);

  configFile = pkgs.writeText "conky.conf" ''
    conky.config = {
      alignment = 'top_right',
      gap_x = 30,
      gap_y = 60,
      border_inner_margin = 15,
      background = false,
      border_width = 1,
      own_window = true,
      own_window_class = 'Conky',
      own_window_type = 'desktop',
      own_window_transparent = false,
      own_window_argb_visual = true,
      own_window_argb_value = 200,
      own_window_colour = '#121214',
      font = 'RobotoMono Nerd Font:size=10',
      default_color = 'white',
      default_outline_color = 'white',
      default_shade_color = 'white',
      double_buffer = true,
      draw_borders = false,
      draw_graph_borders = true,
      draw_outline = false,
      draw_shades = false,
      extra_newline = false,
      update_interval = 1.0,
      cpu_avg_samples = 4,
      net_avg_samples = 4,
      no_buffers = true,
      out_to_console = false,
      out_to_ncurses = false,
      out_to_stderr = false,
      out_to_x = true,
      show_graph_range = false,
      show_graph_scale = false,
      stippled_borders = 0,
      uppercase = false,
      use_spacer = 'none',
      use_xft = true,

      color1 = '#F3F3F3',
      color2 = '#C8C8C8',
    }

    conky.text = [[
      ''${voffset 0}
      ''${goto 24}''${color1} OS ''${voffset 8}
      ''${goto 24}''${color1}Version: ''${color2}${lib.versions.majorMinor lib.version}
      ''${goto 24}''${color1}Build:   ''${color2}''${exec ${buildCommand}}
      ''${goto 24}''${color1}Kernel:  ''${color2}''${kernel}
      ''${goto 24}''${color1}Uptime:  ''${color2}''${uptime}


      ''${goto 24}''${color1} File system ''${voffset 8}
      ${fileSystemLines}


      ''${goto 24}''${color1} CPU''${voffset 8}
      ''${goto 24}''${color1}Frequency: ''${color2}''${freq_g}GHz ''${alignr}''${cpu}% ''${color1}''${cpubar 6, 124}''${voffset 8}
      ''${goto 24}''${color1}''${top name 1}''${color2}''${top cpu 1}% ''${alignr}''${color1}''${top name 4}''${color2}''${top cpu 4}%
      ''${goto 24}''${color1}''${top name 2}''${color2}''${top cpu 2}% ''${alignr}''${color1}''${top name 5}''${color2}''${top cpu 5}%
      ''${goto 24}''${color1}''${top name 3}''${color2}''${top cpu 3}% ''${alignr}''${color1}''${top name 6}''${color2}''${top cpu 6}%


      ''${goto 24}''${color1} Memory''${voffset 8}
      ${memoryLines}''${voffset 8}
      ''${goto 24}''${color1}''${top_mem name 1}''${color2}''${top_mem mem 1}% ''${alignr}''${color1}''${top_mem name 4}''${color2}''${top_mem mem 4}%
      ''${goto 24}''${color1}''${top_mem name 2}''${color2}''${top_mem mem 2}% ''${alignr}''${color1}''${top_mem name 5}''${color2}''${top_mem mem 5}%
      ''${goto 24}''${color1}''${top_mem name 3}''${color2}''${top_mem mem 2}% ''${alignr}''${color1}''${top_mem name 6}''${color2}''${top_mem mem 6}%


      ''${goto 24}''${color1}說 Network''${voffset 8}
      ${interfaceLines}
    ]]
  '';

  script = pkgs.writeShellScript "conky.sh" ''
    export PATH=${lib.makeBinPath [ pkgs.conky pkgs.coreutils pkgs.gnused ]}

    sleep 5

    conky --daemonize -c ${configFile}
  '';

  desktopItem = pkgs.makeDesktopItem rec {
    name = "Conky";
    desktopName = name;
    exec = "${script}";
    noDisplay = true;
    terminal = false;
  };
in {
  fonts.fonts = [ pkgs.nerdfonts ];

  home-manager.users.rhoriguchi.xdg.configFile."autostart/conky.desktop".source = "${desktopItem}/share/applications/Conky.desktop";
}
