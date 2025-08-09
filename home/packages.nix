{pkgs, ...}:
with pkgs; let
  default-python = python3.withPackages (python-packages:
    with python-packages; [
      pip
      virtualenv
      black
      flake8
      setuptools
      wheel
      twine
      adblock
    ]);
in {
  home.packages = with pkgs; [
    # desktop
    rbw
    rofi-rbw
    pinentry-gnome3
    xdaliclock
    wtype
    alsa-utils
    gnome-clocks

    # TERMINAL
    neofetch
    fastfetch
    escrotum # screen recording
    gnupg
    feh
    bluetuith
    # DEVELOPMENT
    #jetbrains.idea-ultimate
    #jetbrains.goland
    #default-python
    jdk17
    gradle
    maven
    gcc
    m4
    gnumake
    binutils
    gdb
    rustup
    lua-language-server
    nil
    alejandra # nix code formatter
    shellcheck
    lazygit
    stylua
    codespell
    # kafka
    avro-tools
    kcat
    delve
    jdt-language-server
    markdownlint-cli
    shfmt

    # cloud
    kubectl
    stern
    kubelogin
    kubernetes-helm
    k9s
    #azure-cli
    lazydocker

    # SYSADMIN
    remmina

    # DEFAULT
    pavucontrol
    pamixer
    neovide
    fd
    libnotify
    jq
    yq
    gdu
    zathura
    asciinema
    flameshot
    evince
    foliate
    inkscape-with-extensions
    libreoffice
    _1password-gui
    gimp
    #calibre
    cheese
    goldwarden
    #bitwarden-desktop
    cava
    hdparm
  ];
}
