{
  config,
  userDetails,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${userDetails.userName} = {
    home.username = "${userDetails.userName}";
    home.homeDirectory = "/home/${userDetails.userName}";
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
    fonts.fontconfig.enable = false;
    imports = [
      ./firefox-webapp.nix
      ./i3.nix
      ./sway.nix
      ./waybar.nix
      ./alacritty.nix
      ./packages.nix
      ./vscode.nix
      ./shell.nix
      ./chromium.nix
      ./firefox.nix
      ./gtk.nix
      ./git.nix
      ./xdg.nix
      ./xresources.nix
      ./screen-capture.nix
      ./qt.nix
      ./zathura.nix
      ./go.nix
      ./gpg.nix
      ./file-managers.nix
      ./mail.nix
    ];
    xsession.enable = config.machine.x11.enable;
    home.sessionVariables = {
      JAVAX_NET_SSL_TRUSTSTORE = "$HOME/.config/java-cacerts";
      MINIKUBE_HOME = "$HOME/.config";
      DOCKER_CONFIG = "$HOME/.config/docker";
      AZURE_CONFIG_DIR = "$HOME/.config/azure";
    };

    xdg.configFile.".minikube/certs" = {
      source = ../system/nixos/certs;
      recursive = true;
    };
    services.blueman-applet.enable = false;

    programs.eww = {
      enable = true;
      configDir = ./eww;
    };

    services.playerctld.enable = false;
  };
}
