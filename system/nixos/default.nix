{
  lib,
  pkgs,
  userDetails,
  config,
  ...
}: {
  config.nixpkgs.overlays = [
  ];

  imports = [
    ./nix.nix
    ./openssh.nix
    ./display-manager.nix
    ./cli.nix
    ./x11.nix
    ./wayland.nix
  ];

  options.machine.role = lib.mkOption {
    type = lib.types.enum ["server" "pc" "mac_pc"];
    default = "pc";
    description = "Specify the role of the machine as either 'server', 'pc' or 'mac_pc'";
  };

  config = {
    # SECURITY
    security.polkit.enable = true;
    security.rtkit.enable = true;

    security.sudo.wheelNeedsPassword = !(config.machine.role == "pc");

    # USER SETUP
    users.users = {
      ${userDetails.userName} = {
        createHome   = true;
        description  = "${userDetails.fullName}";
        isNormalUser = true;
        extraGroups  = [ "wheel" "docker" "networkmanager" "lp" "scanner" "libvirtd" "video" "input" ];
        hashedPassword = "$6$o.L7F4k50YnTvon9$13uBF8yNvy5NqEGq1QTJ3RfMS6mRXx9oqdKXY2s2kiKkYkSzURHZQseh2xCne2pgDqBirLSTkzDrAE17t86190";
      };

      root = {
        hashedPassword = "$6$o.L7F4k50YnTvon9$13uBF8yNvy5NqEGq1QTJ3RfMS6mRXx9oqdKXY2s2kiKkYkSzURHZQseh2xCne2pgDqBirLSTkzDrAE17t86190";
      };
    };

    users.mutableUsers = false;

    documentation.man.mandoc.enable = true;
    documentation.man.generateCaches = false;
    documentation.man.man-db.enable = false;

    #KERNEL
    boot.kernelPackages = pkgs.linuxPackages_zen;

    boot.kernel.sysctl = {
      "vm.overcommit_memory" = 1;
    };

    #LOCALE
    time.timeZone = "America/Denver";
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEFONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    security.pki.certificateFiles = lib.mkIf (config.machine.role == "pc") [
      ./certs/avayaitrootca2.pem
      ./certs/avayaitrootca.pem
      ./certs/avayaitserverca2.pem
      ./certs/zscalerrootcertificate-2048-sha256.pem
    ];

    services.fwupd.enable = true;

    fonts = lib.mkIf (config.machine.role == "pc") {
      packages = with pkgs; [
        (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode" "DroidSansMono" "Hack" "RobotoMono" "Terminus"];})
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        terminus_font
        roboto
        roboto-mono
        roboto-slab
        hasklig
        inter
        material-design-icons
        material-icons
        source-code-pro
        source-sans-pro
        weather-icons
        fira-code
        font-awesome
        corefonts
        vistafonts
      ];

      enableDefaultPackages = true;

      fontconfig = {
        hinting = {
          enable = true;
          style = "slight";
        };
        subpixel.rgba = "rgb";
        subpixel.lcdfilter = "default";
        includeUserConf = false;
        antialias = true;
        enable = true;
        defaultFonts = {
          monospace = ["Roboto Mono"];
          sansSerif = ["Roboto"];
          serif = ["Roboto Slab"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };

    system.stateVersion = "24.05"; # Do not change this number
  };
}
