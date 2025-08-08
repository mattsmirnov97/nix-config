{pkgs, ...}: {
  ## NIX #########################
  nix = {
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      #interval = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;

  ## USERS ##########################
  users.users.aragao = {
    home = "/Users/aragao";
    shell = pkgs.fish;
  };

  programs = {
    zsh.enable = true;
  };

  environment = {
    shells = with pkgs; [fish];
    loginShell = "${pkgs.fish}/bin/fish -l";
    pathsToLink = ["/Applications"];
  };

  ## FONTS ##########################
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = ["JetBrainsMono" "FiraCode" "DroidSansMono"];
    })
    dejavu_fonts
    fira-code
    roboto
    roboto-mono
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      /opt/homebrew/bin/brew shellenv|source
      source (/etc/profiles/per-user/aragao/bin/starship init fish --print-full-init | psub)
      zoxide init fish | source
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      fish_vi_key_bindings
      function fish_greeting
         fastfetch --logo-height 10 -s os:kernel:wm:terminal:cpu:gpu:memory:disk:localip:dns:battery:uptime
         fortune|lolcat
      end

      function cd --description 'Change directory smartly with tmux sessions'
           if set -q TMUX && [ (count $argv) -eq 0 ]
               set -l tmux_root_dir (tmux show-environment TMUX_SESSION_ROOT_DIR 2>/dev/null | sed -n 's/^TMUX_SESSION_ROOT_DIR=//p')
               if test -n "$tmux_root_dir" -a -d "$tmux_root_dir"
                   z $tmux_root_dir
                   # echo "Changed to TMUX session root directory: $tmux_root_dir"
               else
                   # echo "TMUX_SESSION_ROOT_DIR is not set or is not a valid directory."
                   z
               end
           else
               # If arguments are provided or not in a tmux session, use regular cd
               z $argv
               # echo "Changed to directory: $argv"
           end
       end

      function y
       set tmp (mktemp -t "yazi-cwd.XXXXXX")
       yazi $argv --cwd-file="$tmp"
       if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
       end
       rm -f -- "$tmp"
      end
    '';

    shellAliases = {
      ls = "eza --icons";
      ll = "eza --icons --group-directories-first -al";
      v = "nvim";
      fz = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      cd = "z";
    };
  };

  programs.tmux = {
    enable = true;
    enableFzf = true;
    enableMouse = true;
    enableSensible = true;
    enableVim = true;
    /*
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.resurrect
      tmuxPlugins.tmux-fzf
      tmuxPlugins.continuum
    ];
    */
    extraConfig = builtins.readFile ../tmux/tmux.conf;
  };

  ## PACKAGES
  environment.systemPackages = with pkgs; [
    (
      let
        scriptContent = builtins.readFile ../tmux/tmux-sessionizer;
      in
        writeShellScriptBin "tmux-sessionizer" scriptContent
    )
    (
      let
        scriptContent = builtins.readFile ../tmux/tmux-window-icons;
      in
        writeShellScriptBin "tmux-window-icons" scriptContent
    )
    (
      let
        scriptContent = builtins.readFile ../tmux/tmux-right-status;
      in
        writeShellScriptBin "tmux-right-status" scriptContent
    )
    (
      let
        scriptContent = builtins.readFile ../tmux/tmux-git-status;
      in
        writeShellScriptBin "tmux-git-status" scriptContent
    )
    tenki
    ripgrep
    fd
    less
    curl
    speedtest-cli
    coreutils
    nixfmt
    jq
    nodePackages.bash-language-server
    nixd
    gdu
    inetutils
    unzip
    zip
    unrar
    p7zip
    tree
    fzf
    fortune
    lolcat
    cowsay
    dwt1-shell-color-scripts
    curl
    wget
    killall
    htop
    btop
    bottom
    gdu
    entr
    nixd
    lua-language-server
    p11-kit
    nix-prefetch-github
    onefetch
    bc
    cmatrix
    ripgrep
    entr
    openssl
    git
    dig.dnsutils
    bat
    alejandra
    nixfmt-classic
    zoxide
    fastfetch

    lazygit

    # cloud
    kubectl
    stern
    kubelogin
    kubernetes-helm
    k9s
    azure-cli
    lazydocker
  ];

  ## HOMEBREW
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };
    global.brewfile = true;
    caskArgs.no_quarantine = true;
    taps = [
      "FelixKratz/formulae"
    ];
    casks = [
      "stats"
      "brave-browser"
      "1password"
      "sf-symbols"
      "parallels"
      "utm"
      "obsidian"
      "flameshot"
      "alacritty"
      "raycast"
      #"qutebrowser"
      #"bitwarden"
      "nikitabobko/tap/aerospace"
    ];
  };

  ## MAC OS X #######################
  system.startup.chime = false;
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.LaunchServices.LSQuarantine = false;
  system.defaults.NSGlobalDomain.AppleFontSmoothing = 2;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  #system.defaults.universalaccess.reduceMotion = true;
  #system.defaults.universalaccess.mouseDriverCursorSize = 2.0;

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "bottom";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.launchanim = false;
  system.defaults.dock.mineffect = null; # suck, genie, scale, null
  system.defaults.dock.tilesize = 16;
  system.defaults.dock.static-only = true;
  system.defaults.dock.autohide-delay = 1000.0;

  system.defaults.dock.appswitcher-all-displays = true;
  system.defaults.dock.show-recents = false;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.finder.CreateDesktop = false;
  system.defaults.finder.FXPreferredViewStyle = "nlsv";
  system.defaults.finder._FXSortFoldersFirst = true;

  system.defaults.WindowManager.StandardHideDesktopIcons = true;
  system.defaults.dock.wvous-bl-corner = 1;
  system.defaults.dock.wvous-br-corner = 1;
  system.defaults.dock.wvous-tl-corner = 1;
  system.defaults.dock.wvous-tr-corner = 1;

  system.defaults.screencapture.location = "~/screenshots";

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  security.pam.enableSudoTouchIdAuth = true;

  services.jankyborders.enable = true;
  services.jankyborders.inactive_color = "0x00FFFFFF";
  services.jankyborders.blacklist = [
    "System Settings"
    "App Store"
  ];
  system.stateVersion = 5;

  #https://github.com/FelixKratz/dotfiles/tree/e6288b3f4220ca1ac64a68e60fced2d4c3e3e20b
}
