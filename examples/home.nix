{ config, pkgs, ... }: {
  programs.retroarch = {
    enable = true;

    cores = {
      snes9x.enable = true;
      mupen64plus.enable = true;
    };

    settings = {
      config_save_on_exit = "false";
      cheevos_enable = "true";
    };
  };
}