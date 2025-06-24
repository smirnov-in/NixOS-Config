{
  services.flatpak = {
    packages = [
      "com.valvesoftware.Steam"
    ];

    overrides."com.valvesoftware.Steam".Context = {
      nofilesystem = "/home";
    };
  };
}
