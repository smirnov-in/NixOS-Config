{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];

  home.persistence = {
    "/persist/${config.home.homeDirectory}" = {
      defaultDirectoryMethod = "symlink";
      allowOther = true;

      directories = [
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Videos"
      ];
    };
  };
}
