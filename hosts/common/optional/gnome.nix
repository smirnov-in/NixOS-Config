{lib, ...}: {
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  programs.dconf = {
    enable = true;
    profiles = {
      gdm.databases = [
        {settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 2;}
      ];
    };
  };
}
