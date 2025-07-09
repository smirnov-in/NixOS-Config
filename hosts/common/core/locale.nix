{
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "shift:both_capslock_cancel,caps:escape,grp:shift_caps_toggle";
  };
}
