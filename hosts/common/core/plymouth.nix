{
  boot = {
    plymouth = {
      enable = true;
      extraConfig = "DeviceScale=1";
    };
    loader.timeout = 0;

    kernelParams = ["quiet" "splash" "boot.shell_on_fail" "udev.log_priority=3" "rd.systemd.show_status=auto"];
    consoleLogLevel = 3;

    initrd.verbose = false;
  };

  catppuccin.plymouth.enable = false;
}
