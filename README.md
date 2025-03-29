# retroarch-nix

🎮 **Declarative RetroArch module for Home Manager** – with core selection and secure secret handling (RetroAchievements).

This module lets you configure RetroArch **fully declaratively** in your NixOS + Home Manager setup:
- Choose which emulator cores you want
- Inject your `cheevos_username` and `cheevos_password` safely via [agenix](https://github.com/ryantm/agenix)
- Generate `~/.config/retroarch/retroarch.cfg` on the fly, fully controlled by your configuration

No manual RetroArch fiddling required. Ever.

---

## ✅ Features

- 📦 Declarative install of RetroArch and libretro cores
- 🔐 Secrets handled via agenix, not hardcoded
- 📝 Generates a working `retroarch.cfg` for you
- 🤓 Designed for both Nix veterans *and* new users

---

## 📦 How to use

### Step 1: Add flake input

In your `flake.nix`:

```nix
{
  inputs.retroarch-nix.url = "github:StoppingBuck/retroarch-nix";
}
```

### Step 2: Import the module

In your `home.nix` (or wherever you define Home Manager config):

```nix
{
  imports = [ inputs.retroarch-nix.hmModules.retroarch ];

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
```

---

## 🔐 Secrets (RetroAchievements login)

You’ll need to provide two secrets:
- `cheevos_username`
- `cheevos_password`

This is done using [agenix](https://github.com/ryantm/agenix) – see [`secrets/README.md`](secrets/README.md) for full guide.

---

## 🧠 Want to explore?

- See `modules/retroarch.nix` to understand the module
- See `examples/home.nix` for a full working config

---

## ❓ Need help?

Open an issue or PR – contributions welcome!
