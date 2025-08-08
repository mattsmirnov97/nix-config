{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  wallpaper = pkgs.callPackage ./wallpapers.nix {} + "/" + osConfig.machine.wayland.wallpaper + " fill #000000";
in {
  wayland.windowManager.sway = {
    checkConfig = false;
    package = null;
    enable = true;
    config = rec {
      terminal = "footclient";

      output = {
        "*" = {
          bg = wallpaper;
          scale = "${toString osConfig.machine.wayland.scale}";
        };
        "DP-1" = {
          position = "0,0";
          adaptive_sync = "yes";
          subpixel = "rgb";
          modeline = "1339.630 3840 3888 3920 4200 2160 2163 2168 2215 +hsync -vsync";
          #modeline = "870.20 2560 2800 3096 3728 1440 1441 1444 1621 -hsync +vsync";
          #mode = "2560x1440@120Hz";
          render_bit_depth = "8";
          max_render_time = "7";
        };
        "Virtual-1" = {
          position = "0,0";
          mode = "3456x2160";
          adaptive_sync = "no";
        };
      };
      focus.followMouse = false;
      modifier = "Mod1";
      bars = [];
      colors = {
        focused = {
          background = "#191724";
          #border = "#c4a7e7";
          border = "#5b96b2";
          text = "#e0def4";
          indicator = "#eb6f92";
          #childBorder = "#c4a7e7";
          childBorder = "#5b96b2";
        };
        "background" = "#191724";
      };
      window.border = 4;
      window.titlebar = false;
      gaps = {
        inner = 5;
        outer = 0;
      };
      #window.hideEdgeBorders = "smart";
      focus.newWindow = "focus";
      defaultWorkspace = "workspace number 1";
      fonts = {
        names = ["RobotoMono"];
        style = "Bold";
        size = 10.0;
      };

      startup = [
        {
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' timeout 150 '${pkgs.sway}/bin/swaymsg \"output * dpms off\"' resume '${pkgs.sway}/bin/swaymsg \"output * dpms on\"' before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'";
          always = false;
        }
        {
          command = "foot --server";
          always = false;
        }
      ];

      floating.criteria = [
        {app_id = "org.pulseaudio.pavucontrol";}
        {app_id = "1Password";}
        {app_id = "Bitwarden";}
        {app_id = "xdaliclock";}
        {app_id = "pinta";}
      ];

      floating.titlebar = false;

      assigns = {
        "2" = [
          {app_id = "^firefox$";}
        ];
        "3" = [
          {
            app_id = "brave-teams.microsoft.com";
          }
        ];
        "4" = [
          {
            app_id = "brave-outlook.office.com";
          }
          {
            app_id = "brave-mail.google.com";
          }
        ];
        "7" = [
          {
            app_id = "brave-music.youtube.com";
          }
          {
            app_id = "brave-youtube.com";
          }
        ];
        "8" = [
          {
            app_id = "brave-chat.openai.com";
          }
        ];
        "10" = [
          {
            app_id = "brave-x.com";
          }
          {
            app_id = "brave-reddit.com";
          }
          {
            app_id = "brave-web.whatsapp.com";
          }
        ];
      };
      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        #"${modifier}+Return" = " exec ${pkgs.alacritty}/bin/alacritty msg create-window || ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+Shift+Return" = "exec ${pkgs.chromium}/bin/chromium";
        "${modifier}+d" = "exec rofi -dpi -show drun -show-icons";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+b" = "split h";
        "Mod4+c" = "exec --no-startup-id xdaliclock";
        "${modifier}+Shift+s" = "exec --no-startup-id screenshot-sway select";
        "${modifier}+Shift+Print" = "exec --no-startup-id screenshot-sway select";
        "Print" = "exec --no-startup-id screenshot-sway full";
        "${modifier}+backslash" = "exec --no-startup-id rofi-rbw --no-folder";
        "${modifier}+Shift+r" = "reload";
      };
    };
    extraConfig = ''
      blur enable
      for_window [shell="xwayland"] title_format "[XWayland] %title"
      corner_radius 10
      shadows enable
      default_dim_inactive 0.1
      bar {
        swaybar_command waybar
        position top
        hidden_state hide
        mode hide
        modifier Mod4
      }
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };
}
