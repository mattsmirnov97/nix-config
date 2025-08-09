{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    xdg-utils
    xdg-user-dirs
  ];

  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.local/cache";

    mimeApps = {
      enable = true;
      defaultApplications = let
        browser = [ "chromium.desktop" ];
        lf = [ "lf.desktop" ];
        nvim = [ "nvim.desktop" ];
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

      associations.removed = {
        "image/png" = "brave-browser.desktop";
      };
    };

    userDirs = {
      download = "${config.home.homeDirectory}/downloads";
      documents = "${config.home.homeDirectory}/projects";
      enable = false;
      createDirectories = false;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs}/screenshots";
      };
    };
  };

  # кладём локальную иконку в стандартную тему hicolor
  xdg.dataFile."icons/hicolor/256x256/apps/chatgpt.png".source = ./icons/chatgpt.png;
  # при желании можно продублировать другие размеры:
  # xdg.dataFile."icons/hicolor/128x128/apps/chatgpt.png".source = ./icons/chatgpt.png;

  xdg.desktopEntries = {
    tmux-default = {
      name = "Tmux Default Session";
      genericName = "Tmux default session";
      exec = "alacritty --class alacritty_default_tmux -e tmux new-session -s default -A";
      icon = "utilities-terminal";
    };

    outlook = {
      name = "Outlook";
      genericName = "Microsoft Outlook";
      exec = "brave -app=https://outlook.office.com";
      icon = "ms-outlook";
    };

    teams = {
      name = "Microsoft Teams";
      genericName = "Microsoft Teams";
      exec = "brave -app=https://teams.microsoft.com";
      icon = "teams";
    };

    music = {
      name = "Youtube Music";
      genericName = "Youtube Music";
      exec = "brave -app=https://music.youtube.com";
      icon = "youtube-music";
    };

    youtube = {
      name = "Youtube";
      genericName = "Youtube";
      exec = "brave -app=https://youtube.com";
      icon = "youtube";
    };

    vimCheatSheet = {
      name = "Vim Cheat Sheet";
      genericName = "Vim Cheat Sheet";
      exec = "brave -app=https://vim.rtorr.com";
      icon = "vim";
    };

    reddit = {
      name = "Reddit";
      genericName = "Reddit";
      exec = "brave -app=https://reddit.com";
      icon = "reddit";
    };

    twitter = {
      name = "Twitter";
      genericName = "Twitter";
      exec = "brave -app=https://x.com";
      icon = "twitter";
    };

    whatsapp = {
      name = "Whatsapp";
      exec = "brave -app=https://web.whatsapp.com";
      icon = "whatsapp";
    };

    chatgpt = {
      name = "ChatGPT";
      genericName = "ChatGPT";
      exec = "brave -app=https://chat.openai.com";
      icon = "chatgpt";  # используем имя из XDG-темы, не URL
    };

    gmail = {
      name = "Gmail";
      exec = "brave -app=https://mail.google.com";
      icon = "gmail";
    };

    primevideo = {
      name = "Amazon Prime Video";
      exec = "brave -app=https://www.amazon.com/gp/video/storefront";
      icon = "amazon";
    };
  };

  home.activation = with config.xdg; {
    createXdgCacheAndDataDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/screenshots

      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/projects

      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/projects/personal

      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/projects/work

      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/screenshots

      $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG \
        ${config.home.homeDirectory}/downloads
    '';

    createJavaCertificates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f $HOME/.config/java-cacerts ]; then
        $DRY_RUN_CMD ${pkgs.p11-kit.bin}/bin/trust extract --format=java-cacerts --purpose=server-auth $HOME/.config/java-cacerts
      fi
    '';
  };
}
