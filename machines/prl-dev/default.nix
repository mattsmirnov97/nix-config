# Parallels VM (aarch64) — GNOME на Wayland, без i3
{ lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "prl-dev";

  machine.x11.enable = lib.mkForce false;

  # Графика
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa.drivers
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  # Загрузчик
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Аудио: PipeWire
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.upower.enable = true;

  ############################
  # GUI: GDM + GNOME (Wayland)
  ############################
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "virtio" ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.displayManager.defaultSession = "gnome";

  services.greetd.enable = lib.mkForce false;
  services.gvfs.enable  = lib.mkForce true;
  programs.dconf.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
}
