{ config, ... }:
let htop = config.lib.htop;
in {
  programs.htop = {
    enable = true;

    settings = {
      fields = [
        htop.fields.PID
        htop.fields.USER
        htop.fields.PRIORITY
        htop.fields.PERCENT_CPU
        htop.fields.PERCENT_MEM
        htop.fields.TIME
        htop.fields.COMM
      ];
      sort_key = htop.fields.PERCENT_CPU;
      sort_direction = 1;
      tree_sort_key = htop.fields.PID;
      tree_sort_direction = 1;
      hide_kernel_threads = 1;
      hide_userland_threads = 0;
      shadow_other_users = 0;
      show_thread_names = 0;
      show_program_path = 1;
      highlight_base_name = 1;
      highlight_megabytes = 1;
      highlight_threads = 1;
      highlight_changes = 0;
      highlight_changes_delay_secs = 5;
      find_comm_in_cmdline = 1;
      strip_exe_from_cmdline = 1;
      show_merged_command = 0;
      tree_view = 1;
      tree_view_always_by_pid = 0;
      header_margin = 1;
      detailed_cpu_time = 0;
      cpu_count_from_one = 1;
      show_cpu_usage = 1;
      show_cpu_frequency = 0;
      update_process_names = 0;
      account_guest_in_cpu_meter = 0;
      color_scheme = 6;
      enable_mouse = 1;
      delay = 10;
      hide_function_bar = 0;
    } // (htop.leftMeters [ (htop.bar "LeftCPUs2") htop.blank (htop.bar "Memory") htop.blank (htop.text "NetworkIO") (htop.text "DiskIO") ])
      // (htop.rightMeters [ (htop.bar "RightCPUs2") htop.blank (htop.bar "Swap") htop.blank (htop.text "Uptime") ]);
  };
}
