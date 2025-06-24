{inputs, ...}: {
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
  ];

  wayland.desktopManager.cosmic = {
    enable = true;

    compositor = {
      focus_follows_cursor = true;
      # input_touchpad = {
      #   scroll_config = cosmicLib.mkRON "optional" {
      #     natural_scroll = true;
      #   };
      # };
    };
  };
}
