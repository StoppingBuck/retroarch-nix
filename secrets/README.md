# 🔐 secrets/README.md – RetroAchievements secret setup

This guide helps you securely inject your `cheevos_username` and `cheevos_password` into `retroarch.cfg` using [agenix](https://github.com/ryantm/agenix).

---

## Step 1: Generate an SSH key (if needed)

If you don’t already have one:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your@email.com"
```

This creates:

- `~/.ssh/id_ed25519` (private key – DO NOT share)
- `~/.ssh/id_ed25519.pub` (public key – used for encryption)

---

## Step 2: Add public key to `secrets.nix`

Example:

```nix
{
  "secrets/retroarch-username.age".publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
  ];

  "secrets/retroarch-password.age".publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
  ];
}
```

---

## Step 3: Add host to `secrets/hosts.nix`

This maps a hostname (like your machine) to a specific public SSH key:

```nix
{
  "donkey" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
}
```

---

## Step 4: Create encrypted secrets

Install agenix:

```bash
nix run github:ryantm/agenix
```

Then create the secrets:

```bash
agenix -e secrets/retroarch-username.age
agenix -e secrets/retroarch-password.age
```

Each command opens your `$EDITOR`. Write just the raw value:
```
YourRetroAchievementsUsername
```

Save and exit – the file is now encrypted.

---

## Step 5: Enable secrets in NixOS config

In your `configuration.nix` (system level):

```nix
age.identityPaths = [ "/home/YOURUSER/.config/age/identity.txt" ];

age.secrets.retroarch-username = {
  file = ../../secrets/retroarch-username.age;
  owner = "YOURUSER";
};

age.secrets.retroarch-password = {
  file = ../../secrets/retroarch-password.age;
  owner = "YOURUSER";
  mode = "0440";
};
```

---

## That’s it! ✅

Your secrets will now be injected securely into `~/.config/retroarch/retroarch.cfg` by the module – never in plain text anywhere in your repo.

