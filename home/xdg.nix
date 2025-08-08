{
  config,
  pkgs,
  lib,
  ...
}: let
  chatGptIcon = pkgs.fetchurl {
    url = "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/chatgpt-icon.png";
    sha256 = "157xbcxzlfjb9ls7vja9vq8zb4i8nkd33qk58qva7yavn71zzxay";
  };
  #redditIcon = pkgs.fetchurl {
  #  url = "https://cdn.icon-icons.com/icons2/1195/PNG/512/1490889653-reddit_82537.png";
  #  sha256 = "01ja74q5i797s0cfhr8byqq1bzzix23hswimij663ylm864w7lna";
  #};
  #twitterIcon = pkgs.fetchurl {
  #  url = "https://cdn.icon-icons.com/icons2/836/PNG/512/Twitter_icon-icons.com_66803.png";
  #  sha256 = "1mlqxxj2rwwv439lvdv4k4djhmwk92lv1riywk94r9hcmk5bbs92";
  #};
  #vimCheatSheetIcon = pkgs.fetchurl {
  #  url = "https://cdn.icon-icons.com/icons2/1381/PNG/512/vim_94609.png";
  #  sha256 = "0fnrcrsrrnchrgjbg0hszynj2g2m674b3nc4ky8pdb3zgc1490sc";
  #};
  #youtubeMusicIcon = pkgs.fetchurl {
  #  url = "https://cdn.icon-icons.com/icons2/3132/PNG/512/youtube_music_social_network_song_multimedia_icon_192250.png";
  #  sha256 = "0hxwh8x4xmpa9rpmscds9sip08a6xz9s58xncd2mlnyzh8pa447b";
  #};
in {
  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
  ];

  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.local/cache";

    # manage $XDG_CONFIG_HOME/mimeapps.list
    # xdg search all desktop entries from $XDG_DATA_DIRS, check it by command:
    #  echo $XDG_DATA_DIRS
    # the system-level desktop entries can be list by command:
    #   ls -l /run/current-system/sw/share/applications/
    # the user-level desktop entries can be list by command(user ryan):
    #  ls /etc/profiles/per-user/ryan/share/applications/
    mimeApps = {
      enable = true;
      defaultApplications = let
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
      name = "Teams";
      genericName = "Microsoft Teams";
      exec = "brave -app=https://teams.microsoft.com";
      icon = "teams";
    };

    music = {
      name = "Youtube Music";
      genericName = "Youtube Music";
      exec = "brave -app=https://music.youtube.com";
      icon = "youtube-music"; #youtubeMusicIcon;
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
      icon = "twitter"; #twitterIcon;
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
      icon = chatGptIcon;
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
    createXdgCacheAndDataDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
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

    #TODO remove this from here - should be in the java.nix file
    createJavaCertificates = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f $HOME/.config/java-cacerts ]; then
        $DRY_RUN_CMD ${pkgs.p11-kit.bin}/bin/trust extract --format=java-cacerts --purpose=server-auth $HOME/.config/java-cacerts
      fi
    '';
  };
}
