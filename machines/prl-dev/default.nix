{ lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "prl-dev";

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa.drivers
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; wireplumber.enable = true;
  };

  services.upower.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "virtio" ];
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;
  services.greetd.enable = lib.mkForce false;
}
