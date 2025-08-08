{ pkgs, lib, config, ... }:
with lib; {
  options.machine.wayland.enable = lib.mkEnableOption "enables sway and desktop packages for this machine";

  options.machine.wayland.scale = lib.mkOption {
    type = lib.types.float;
    default = 1.0;
    description = "default scale to be used for wayland outputs";
  };

  options.machine.wayland.wallpaper = lib.mkOption {
    type = lib.types.str;
    default = "os/nix-magenta-blue-1920x1080.png";
    description = "wallpaper to be used, based on the rose-pine list https://github.com/rose-pine/wallpapers";
  };

  config = lib.mkIf config.machine.wayland.enable {
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      extraSessionCommands = ''
         export SDL_VIDEODRIVER=wayland
         export QT_QPA_PLATFORM=wayland
         export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
         export _JAVA_AWT_WM_NONREPARENTING=1
         export XDG_SESSION_TYPE=wayland
         export XDG_CURRENT_DESKTOP=sway
         export QT_AUTO_SCREEN_SCALE_FACTOR=0
         export QT_SCALE_FACTOR=1
         export GDK_SCALE=1
         export GDK_DPI_SCALE=1
         export MOZ_ENABLE_WAYLAND=1
         export NIXOS_OZONE_WL=1
      '';
      xwayland.enable = false;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        rofi
        brightnessctl
        sway-contrib.grimshot
        wlr-randr
        wdisplays
        qt5.qtwayland
        qt6.qtwayland
        glxinfo
        pavucontrol
        chromium
        libreoffice
        zathura
        neovide
        font-manager
        evince
        wl-color-picker
        wf-recorder
        wl-clipboard
      ];
    };
    security.pam.services.swaylock = {};
    xdg.portal = {
      enable = true;
      configPackages = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };

    services = {
      gnome.gnome-keyring.enable = true;
      dbus.enable = true;
      gvfs.enable = false;
      tumbler.enable = false;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    programs = {
      dconf.enable = true;
      foot = {
        enable = true;
        theme = "paper-color-dark";
        enableFishIntegration = true;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font:size=10";
            shell = "${pkgs.fish}/bin/fish";
            term = "xterm-256color";
            selection-target = "both";
            pad = "5x5 center";
          };
          colors = { alpha = 0.92; };
          mouse = { hide-when-typing = true; };
          scrollback.lines = 100000;
          tweak.font-monospace-warn = false;
        };
      };
    };
  };
}
