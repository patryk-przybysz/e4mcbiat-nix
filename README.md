# e4mcbiat-nix

Nix flake for [e4mcbiat](https://github.com/DuncanRuns/e4mcbiat) — share a singleplayer Minecraft world with friends over the internet, no port forwarding or e4mc mod required.

Friends join using a public domain (e.g. `something.eu.e4mc.link`) instead of your home IP. Java is bundled.

## Quick start

1. **Open to LAN** in Minecraft — load your world and open it to LAN.
2. **Run e4mcbiat:**
   ```bash
   nix run github:patryk-przybysz/e4mcbiat-nix
   ```
   The relay connects automatically. Wait until status shows **Connected**.
3. **Set MC Port** to match your Minecraft LAN port (usually `25565`), then **Copy IP** and share the domain.
4. **Friends join** via Multiplayer → **Direct Connect**.

### No GUI

```bash
nix run github:patryk-przybysz/e4mcbiat-nix -- nogui
nix run github:patryk-przybysz/e4mcbiat-nix -- nogui port=25565
```

Type `stop` to quit nogui mode.

## Install

```bash
nix profile install github:patryk-przybysz/e4mcbiat-nix
e4mcbiat
```

Or as a flake input in home-manager:

```nix
{
  inputs.e4mcbiat.url = "github:patryk-przybysz/e4mcbiat-nix";

  home.packages = [
    inputs.e4mcbiat.packages.${pkgs.system}.default
  ];
}
```

More details: [upstream README](https://github.com/DuncanRuns/e4mcbiat).
