{
  config,
  pkgs,
  ...
}: {
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.sudo.rules.auth = {
    fprintd-only-if-lid-open = {
      enable = true;
      order = config.security.pam.services.sudo.rules.auth.fprintd.order - 1;
      control = "[success=ok default=1]";
      modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
      args = [
        "quiet"
        "${pkgs.writeShellScript "is-lid-open" ''
          ${pkgs.gnugrep}/bin/grep -q "^state:.*open" "/proc/acpi/button/lid/LID/state"
        ''}"
      ];
    };
  };
}
