{ pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
    commandLineArgs = [
      "--password-store=gnome"
      "--test-type"
      "--no-default-browser-check"
      "--enable-gpu-rasterization"
      "--enable-parallel-downloading"
      "--ozone-platform-hint=auto"
    ];
    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "noimedcjdohhokijigpfcbjcfcaaahej"; } # rose-pine theme
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "ljjmnbjaapnggdiibfleeiaookhcodnl"; } # Dark theme
    ];
  };
}
