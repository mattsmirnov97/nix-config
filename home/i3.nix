{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  rose-pine-wallpaper = pkgs.callPackage ./wallpapers.nix {} + "/" + osConfig.machine.x11.wallpaper;
in {
  imports = [
    ./rofi.nix
    ./polybar.nix
    ./picom.nix
    ./redshift.nix
    ./dunst.nix
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  xsession.windowManager.i3 = {
    enable = osConfig.machine.x11.enable;

    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod1";
      bars = [];
      colors = {
        focused = {
          background = "#191724";
          #border = "#c4a7e7";
          border = "#9ccfd8";
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
        outer = 5;
        bottom = 5;
        top = 5;
        left = 5;
        right = 5;
      };

      focus.followMouse = false;
      #gaps.smartBorders = "off";
      #window.hideEdgeBorders = "smart";
      defaultWorkspace = "workspace number 1";

      floating.criteria = [
        {class = "pavucontrol";}
        {class = "1Password";}
        {class = "Bitwarden";}
        {class = "qutebrowser_edit";}
        {class = "Pinta";}
        {class = "Xdaliclock";}
      ];

      floating.titlebar = false;

      fonts = {
        names = ["RobotoMono"];
        style = "Medium";
        size = 10.0;
      };

      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        "F8" = "exec amixer set Master 4%-";
        #"${modifier}+Return" = " exec ${pkgs.alacritty}/bin/alacritty msg create-window || ${pkgs.alacritty}/bin/alacritty";
        #"${modifier}+Return" = " exec ${pkgs.mlterm}/bin/mlterm -e fish";
        "${modifier}+Return" = "exec st -e fish";
        "${modifier}+Shift+Return" = "exec ${pkgs.chromium}/bin/chromium";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -show-icons -dpi ${toString osConfig.machine.x11.dpi}";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+b" = "split h";
        "Mod4+c" = "exec --no-startup-id xdaliclock";
        "${modifier}+Shift+s" = "exec --no-startup-id screenshot-x11 select";
        "${modifier}+Shift+Print" = "exec --no-startup-id screenshot-x11 select";
        "Print" = "exec --no-startup-id screenshot-x11 full";
        "${modifier}+backslash" = "exec --no-startup-id rofi-rbw --no-folder";
        "Mod4+b" = "exec polybar-toggle";
      };

      assigns = {
        "1" = [
          {
            class = "Alacritty";
            instance = "default-tmux";
          }
        ];
        "2" = [
          {class = "^firefox$";}
          {
            instance = "chromium-browser";
            class = "Chromium-browser";
          }
          {
            instance = "brave-browser";
            class = "Brave-browser";
          }
        ];
        "3" = [
          {
            instance = "teams.microsoft.com";
            class = "Brave-browser";
          }
          {
            instance = "teams-for-linux";
            class = "teams-for-linux";
          }
        ];
        "4" = [
          {
            instance = "outlook.office.com";
            class = "Brave-browser";
          }
          {
            instance = "mail.google.com";
            class = "Brave-browser";
          }
        ];
        "5" = [{class = "jetbrains-goland";} {class = "jetbrains-idea";}];
        "7" = [
          {
            instance = "music.youtube.com";
            class = "Brave-browser";
          }
          {
            instance = "youtube.com";
            class = "Brave-browser";
          }
          {
            instance = "www.amazon.com__gp_video_storefront";
            class = "Brave-browser";
          }
        ];
        "8" = [
          {
            instance = "chat.openai.com";
            class = "Brave-browser";
          }
        ];
        "10" = [
          {
            instance = "x.com";
            class = "Brave-browser";
          }
          {
            instance = "reddit.com";
            class = "Brave-browser";
          }
          {
            instance = "web.whatsapp.com";
            class = "Brave-browser";
          }
        ];
      };
      focus.newWindow = "focus";
      startup = [
        {
          command = "xset s 600 dpms 1800 1800 1800";
          always = false;
          notification = false;
        }
        {
          command = "xrdb -merge ~/.Xresources";
          always = false;
          notification = false;
        }
        #     {
        #       command = "xscreensaver --no-splash";
        #       always = false;
        #       notification = false;
        #     }
        {
          command = "unclutter";
          always = true;
          notification = false;
        }

        {
          command = "xss-lock -n ${pkgs.xsecurelock}/libexec/xsecurelock/dimmer -l -- ${pkgs.xsecurelock}/bin/xsecurelock";
          always = false;
          notification = false;
        }

        #{
        #command = "xautolock -time 10 -locker 'i3lock -c 000000' -detectsleep";
        #always = false;
        #notification = false;
        #}

        {
          command = "i3-msg workspace 1";
          always = false;
          notification = false;
        }
        #        {
        #          command = "exec spice-vdagent";
        #          always = false;
        #          notification = true;
        #        }
        {
          command = "${pkgs.feh}/bin/feh --no-fehbg --bg-max ${rose-pine-wallpaper}";
          always = true;
          notification = false;
        }
      ];
    };
    extraConfig = ''
      # Center a specific dialog horizontally and position it 45px from the top
      for_window [class="^my-calendar-class$"] floating enable
    '';
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "polybar-toggle" ''
      #!/usr/bin/env bash
      if pgrep -x ".polybar-wrappe" > /dev/null; then
          pkill -x ".polybar-wrappe"
      else
          polybar -q -r top &
      fi
    '')
  ];
}
