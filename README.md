# e4mcbiat-nix

Nix flake packaging for [e4mcbiat](https://github.com/DuncanRuns/e4mcbiat) (e4mc but it's a tool).

Builds from source using nixpkgs `gradle.fetchDeps` for reproducible Gradle dependency resolution.

## Usage

```bash
# Run directly
nix run .
nix run github:patryk-przybysz/e4mcbiat-nix

# Build only
nix build .

# No-GUI mode (after install/build)
e4mcbiat nogui
e4mcbiat nogui port=25566
```

## Flake input

```nix
{
  inputs.e4mcbiat.url = "github:patryk-przybysz/e4mcbiat-nix";

  outputs = { e4mcbiat, ... }: {
    # e4mcbiat.packages.${system}.default
  };
}
```

## Updating Gradle dependencies

When upstream dependencies change:

```bash
$(nix build .#e4mcbiat.mitmCache.updateScript --no-link --print-out-paths)
```

## Updating e4mcbiat version

1. Bump `version` in `flake.nix`
2. Update `fetchFromGitHub` `rev` and `hash`
3. Regenerate `deps.json` if needed
