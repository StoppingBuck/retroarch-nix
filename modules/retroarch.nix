{ config, lib, pkgs, ... }:

let
  cfg = config.programs.retroarch;

  configFilePath = "${config.xdg.configHome}/retroarch/retroarch.cfg";

  # Secrets (read from agenix)
  usernamePath = "/run/agenix/retroarch-username";
  passwordPath = "/run/agenix/retroarch-password";
in {
  options.programs.retroarch = {
    enable = lib.mkEnableOption ''
      Enable RetroArch with core selection and config generation.
    '';

    cores = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.enable = lib.mkEnableOption "Enable this libretro core";
      });
      default = {};
      description = ''
        Specify which libretro cores to install and activate.
        Example:
          cores.snes9x.enable = true;
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Key-value pairs to include in retroarch.cfg (except username/password).
        The values are written as strings.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # Cores (only evaluated when enabled)
      availableCores = {
        # 🟥 Atari
        stella = { package = pkgs.libretro.stella; producer = "Atari"; systems = [ "2600" ]; };
        atari800 = { package = pkgs.libretro.atari800; producer = "Atari"; systems = [ "5200" ]; };
        prosystem = { package = pkgs.libretro.prosystem; producer = "Atari"; systems = [ "7800" ]; };
        virtualjaguar = { package = pkgs.libretro.virtualjaguar; producer = "Atari"; systems = [ "Jaguar" ]; };
        beetle-lynx = { package = pkgs.libretro.beetle-lynx; producer = "Atari"; systems = [ "Lynx" ]; };
        hatari = { package = pkgs.libretro.hatari; producer = "Atari"; systems = [ "ST" ]; };

        # 🟦 Nintendo
        mesen = { package = pkgs.libretro.mesen; producer = "Nintendo / Bandai"; systems = [ "NES" "Famicom" "Bandai WonderSwan" ]; };
        sameboy = { package = pkgs.libretro.sameboy; producer = "Nintendo"; systems = [ "Game Boy" "Game Boy Color" ]; };
        snes9x = { package = pkgs.libretro.snes9x; producer = "Nintendo"; systems = [ "SNES" "Super Famicom" ]; };
        beetle-vb = { package = pkgs.libretro.beetle-vb; producer = "Nintendo"; systems = [ "Virtual Boy" ]; };
        mupen64plus = { package = pkgs.libretro.mupen64plus; producer = "Nintendo"; systems = [ "Nintendo 64" ]; };
        mgba = { package = pkgs.libretro.mgba; producer = "Nintendo"; systems = [ "Game Boy Advance" ]; };
        dolphin = { package = pkgs.libretro.dolphin; producer = "Nintendo"; systems = [ "GameCube" "Wii" ]; };

        # 🟩 Sega
        genesis-plus-gx = {
          package = pkgs.libretro.genesis-plus-gx;
          producer = "Sega";
          systems = [ "Master System" "Mark III" "Game Gear" "Mega Drive" "Genesis" "Pico" "SG-1000" ];
        };

        # 🟨 Sony
        beetle-psx = { package = pkgs.libretro.beetle-psx; producer = "Sony"; systems = [ "PlayStation" ]; };
        pcsx2 = { package = pkgs.libretro.pcsx2; producer = "Sony"; systems = [ "PlayStation 2" ]; };

        # 🟪 Diverse
        fbneo = { package = pkgs.libretro.fbneo; producer = "Coleco"; systems = [ "ColecoVision" ]; };
        puae = { package = pkgs.libretro.puae; producer = "Commodore"; systems = [ "Amiga" ]; };
        vecx = { package = pkgs.libretro.vecx; producer = "GCE"; systems = [ "Vectrex" ]; };
        freeintv = { package = pkgs.libretro.freeintv; producer = "Mattel"; systems = [ "Intellivision" ]; };
        bluemsx = { package = pkgs.libretro.bluemsx; producer = "Microsoft"; systems = [ "MSX" ]; };
        beetle-supergrafx = { package = pkgs.libretro.beetle-supergrafx; producer = "NEC"; systems = [ "TurboGrafx 16" "PC Engine" ]; };
        o2em = { package = pkgs.libretro.o2em; producer = "Philips / Magnavox"; systems = [ "Videopac+" "Odyssey²" ]; };
        fuse = { package = pkgs.libretro.fuse; producer = "Sinclair"; systems = [ "ZX Spectrum" ]; };
        beetle-ngp = { package = pkgs.libretro.beetle-ngp; producer = "SNK"; systems = [ "Neo Geo Pocket" "Neo Geo Pocket Color" ]; };
      };

      enabledCores = lib.filterAttrs (name: _: cfg.cores ? ${name} && cfg.cores.${name}.enable) availableCores;
      corePackages = lib.mapAttrsToList (_: v: v.package) enabledCores;
    in {
      home.packages = [ (pkgs.retroarch-bare.wrapper { cores = corePackages; }) ];

      home.activation.generateRetroarchCfg = lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -euo pipefail

        mkdir -p "${config.xdg.configHome}/retroarch"

        if [[ -f "${usernamePath}" && -f "${passwordPath}" ]]; then
          cheevos_username=$(cat "${usernamePath}")
          cheevos_password=$(cat "${passwordPath}")
        else
          echo "RetroArch secrets not found; skipping injection" >&2
          cheevos_username=""
          cheevos_password=""
        fi

        cat > "${configFilePath}" <<EOF
${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") (
  cfg.settings // {
    cheevos_username = "$cheevos_username";
    cheevos_password = "$cheevos_password";
  }
))}
EOF

        chmod 600 "${configFilePath}"
      '';
    }
  );
}