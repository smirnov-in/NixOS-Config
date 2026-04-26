{pkgs, ...}: {
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "duck";

    settings = {
      "download-dir" = "/home/duck/Downloads/transmission";
      "incomplete-dir" = "/home/duck/Downloads/transmission/.incomplete";
      "incomplete-dir-enabled" = true;
    };
  };

  system.activationScripts.transmissionDirs.text = ''
    mkdir -p /home/duck/Downloads/transmission/.incomplete
    chown -R duck:transmission /home/duck/Downloads/transmission
    chmod 750 /home/duck/Downloads/transmission
    chmod 750 /home/duck/Downloads/transmission/.incomplete
  '';
}
