# Parallels VM-specific configuration
{ lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "prl-dev";

  # Graphics (renamed from hardware.opengl.*)
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa.drivers
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
    # enable32Bit = true; # нужно только на x86_64, на aarch64 не трогаем
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Audio: PipeWire
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.upower.enable = true;
}
