{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.x11.enable = lib.mkEnableOption "enables x11, i3 and desktop packages for this machine";
  options.machine.x11.dpi = lib.mkOption {
    type = lib.types.int;
    default = 96;
    description = "default dpi to be used for X11";
  };

  options.machine.x11.wallpaper = lib.mkOption {
    type = lib.types.str;
    default = "landscapes/Clearday.jpg";
    description = "wallpaper to be used, based on the rose-pine list https://github.com/rose-pine/wallpapers";
  };

  config = lib.mkIf config.machine.x11.enable {
    services = {
      #displayManager.autoLogin.enable = true;
      #displayManager.autoLogin.user = "${userDetails.userName}";
      displayManager.defaultSession = "none+i3";
      xserver = {
        displayManager = {
          startx.enable = true;
          sessionCommands = ''
            ${pkgs.xrandr}/bin/xrandr
            ${pkgs.xorg.xrdb}/bin/xrdb -merge ~/.Xresources
            # export XSECURELOCK_SAVER=saver_xscreensaver XSECURELOCK_DISCARD_FIRST_KEYPRESS=0 xsecurelock
          '';
        };
        dpi = config.machine.x11.dpi;
        enable = true;
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            xsecurelock
            xorg.libxcvt
            rofi
            pavucontrol
            xcolor
            xclip
            xdo
            xdotool
            xsel
            firefox
            font-manager
            neovide
            pavucontrol
            obsidian
            zathura
            flameshot
            evince
            foliate
            inkscape-with-extensions
            i3lock
            xautolock
            xss-lock
            libreoffice
            xorg.xdpyinfo
            libsForQt5.qt5ct
            libsForQt5.qtstyleplugin-kvantum
            kdePackages.qt6ct
            graphite-kde-theme
            catppuccin-kvantum
            feh
            picom-pijulius
            unclutter-xfixes
            xscreensaver
          ];
        };
        xkb.layout = "us";
      };

      gnome.gnome-keyring.enable = true;
      dbus.enable = true;
      gvfs.enable = false;
      tumbler.enable = false;
    };

    #    security.wrappers.xscreensaver-auth = {xscreensaver
    #      setuid = true;
    #      owner = "root";
    #      group = "root";
    #      source = "${pkgs.xscreensaver}/libexec/xscreensaver/xscreensaver-auth";
    #    };

    services.libinput = {
      enable = true;
      touchpad.tapping = true;
      touchpad.naturalScrolling = false;
      touchpad.scrollMethod = "twofinger";
      touchpad.disableWhileTyping = true;
      touchpad.clickMethod = "clickfinger";
    };

    programs = {
      thunar = {
        enable = true;
        plugins = with pkgs; [
          xfce.thunar-archive-plugin
          xfce.thunar-volman
          xfce.thunar-media-tags-plugin
          file-roller
        ];
      };
      seahorse.enable = true;
      dconf.enable = true;
    };

    xdg.portal = {
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config = {
        common = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        };
      };
    };

    xdg.mime.defaultApplications = let
      browser = ["chromium.desktop"];
      lf = ["lf.desktop"];
      nvim = ["nvim.desktop"];
    in {
      "application/json" = nvim;
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop";

      "text/html" = browser;
      "text/xml" = nvim;
      "text/plain" = nvim;
      "text/markdown" = nvim;
      "text/x-go" = nvim;
      "text/x-java" = nvim;
      "text/x-python" = nvim;
      "application/x-shellscript" = nvim;
      "application/yaml" = nvim;
      "application/xml" = browser;
      "application/xhtml+xml" = browser;
      "application/xhtml_xml" = browser;
      "application/rdf+xml" = browser;
      "application/rss+xml" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/x-extension-shtml" = browser;
      "application/x-extension-xht" = browser;
      "application/x-extension-xhtml" = browser;

      "x-scheme-handler/about" = browser;
      "x-scheme-handler/ftp" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/unknown" = nvim;
      "inode/directory" = "thunar.desktop";
      "image/*" = "feh.desktop";
      "image/png" = "feh.desktop";
    };

    xdg.mime.removedAssociations = {
      "image/png" = "brave-browser.desktop";
    };

    #TERMINAL
    environment.systemPackages = with pkgs; [
      (st.overrideAttrs (oldAttrs: rec {
        #        src = fetchFromGitHub {
        #          owner = "LukeSmithxyz";
        #          repo = "st";
        #          rev = "8ab3d03681479263a11b05f7f1b53157f61e8c3b";
        #          sha256 = "1brwnyi1hr56840cdx0qw2y19hpr0haw4la9n0rqdn0r2chl8vag";
        #        };
        src = fetchgit {
          url = "https://git.suckless.org/st";
          rev = "refs/tags/0.9.2";
          sha256 = "pFyK4XvV5Z4gBja8J996zF6wkdgQCNVccqUJ5+ejB/w=";
        };
        # ligatures dependency
        buildInputs = oldAttrs.buildInputs ++ [harfbuzz xorg.libXrandr];
        patches = [
          # ligatures patch
          (fetchpatch {
            url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-20200430-0.8.3.diff";
            sha256 = "vKiYU0Va/iSLhhT9IoUHGd62xRD/XtDDjK+08rSm1KE=";
          })

          # alpha
          (fetchpatch {
            url = "https://st.suckless.org/patches/alpha/st-alpha-osc11-20220222-0.8.5.diff";
            sha256 = "Y8GDatq/1W86GKPJWzggQB7O85hXS0SJRva2atQ3upw=";
          })

          # bold is not bright
          (fetchpatch {
            url = "https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff";
            sha256 = "IhrTgZ8K3tcf5HqSlHm3GTacVJLOhO7QPho6SCGXTHw=";
          })

          # xrandrfontsize
          (fetchpatch {
            url = "https://st.suckless.org/patches/xrandrfontsize/xrandrfontsize-0.8.4-20211224-2f6e597.diff";
            sha256 = "CBgRsdA2c0XcBYpjpMPSIQG07iBHLpxLEXCqfgWFl7Y=";
          })

          # desktop entry
          (fetchpatch {
            url = "https://st.suckless.org/patches/desktopentry/st-desktopentry-0.8.5.diff";
            sha256 = "JUFRFEHeUKwtvj8OV02CqHFYTsx+pvR3s+feP9P+ezo=";
          })

          # w3m
          (fetchpatch {
            url = "https://st.suckless.org/patches/w3m/st-w3m-0.8.3.diff";
            sha256 = "nVSG8zuRt3oKQCndzm+3ykuRB1NMYyas0Ne3qCG59ok=";
          })

          # undercurl
          (fetchpatch {
            url = "https://st.suckless.org/patches/undercurl/st-undercurl-0.9-20240103.diff";
            sha256 = "9ReeNknxQJnu4l3kR+G3hfNU+oxGca5agqzvkulhaCg=";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile ./st/config.h);
        postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
      }))
    ];
  };
}
