# Parallels VM‑specific configuration
{ lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Hostname
  networking.hostName = "prl-dev";

  # OpenGL / video acceleration (Parallels exposes virtio‑gpu)
  hardware.opengl = {
    enable         = true;
    extraPackages  = [
      pkgs.mesa.drivers
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };
  # `hardware.opengl.driSupport` was removed in 24.05 → no longer needed.

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Modern audio stack (PipeWire). Old `sound.enable` is deprecated.
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable          = true;
    alsa.enable     = true;
    alsa.support32Bit = true;
    pulse.enable    = true;
    wireplumber.enable = true;
  };

  services.upower.enable = true;
}
