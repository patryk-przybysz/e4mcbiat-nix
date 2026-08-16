{
  description = "Nix packaging for e4mcbiat (e4mc but it's a tool)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
      packageFor =
        pkgs:
        let
          inherit (pkgs)
            stdenv
            gradle
            makeWrapper
            temurin-bin-17
            temurin-jre-bin-17
            ;

          jdk = temurin-bin-17;
          jre = temurin-jre-bin-17;

          gradleWithJdk = gradle.override { java = jdk; };

          swingLibs = with pkgs; [
            libGL
            libx11
            libxext
            libxrender
            libxtst
            libxi
            fontconfig
            freetype
            zlib
          ];

          e4mcbiat = stdenv.mkDerivation (finalAttrs: {
            pname = "e4mcbiat";
            version = "0.2.2";

            src = pkgs.fetchFromGitHub {
              owner = "DuncanRuns";
              repo = "e4mcbiat";
              rev = "v${finalAttrs.version}";
              hash = "sha256-H4LvTKuP3IOo2anAVm+Ekq4yxAS1o734O8D9dzKs9Tc=";
            };

            nativeBuildInputs = [
              gradleWithJdk
              makeWrapper
            ];

            mitmCache = gradle.fetchDeps {
              pkg = e4mcbiat;
              data = ./deps.json;
            };

            gradleBuildTask = "shadowJar";
            gradleFlags = [ "-Dorg.gradle.java.home=${jdk}" ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/e4mcbiat $out/bin
              cp build/libs/e4mcbiat-${finalAttrs.version}-all.jar $out/share/e4mcbiat/e4mcbiat.jar

              makeWrapper ${lib.getExe jre} $out/bin/e4mcbiat \
                --add-flags "-Dawt.useSystemAAFontSettings=on" \
                --add-flags "-jar $out/share/e4mcbiat/e4mcbiat.jar" \
                --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath swingLibs}

              runHook postInstall
            '';

            meta = with lib; {
              description = "e4mc as a standalone tool for opening LAN worlds";
              homepage = "https://github.com/DuncanRuns/e4mcbiat";
              license = licenses.mit;
              mainProgram = "e4mcbiat";
              platforms = [
                "x86_64-linux"
                "aarch64-linux"
              ];
              maintainers = [
                {
                  name = "Patryk Przybysz";
                  github = "patryk-przybysz";
                }
              ];
              sourceProvenance = with sourceTypes; [
                fromSource
                binaryBytecode
              ];
            };
          });
        in
        e4mcbiat;
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          e4mcbiat = packageFor pkgs;
        in
        {
          inherit e4mcbiat;
          default = e4mcbiat;
        }
      );

      apps = eachSystem (
        system:
        let
          e4mcbiat = self.packages.${system}.e4mcbiat;
        in
        {
          default = {
            type = "app";
            program = "${e4mcbiat}/bin/e4mcbiat";
            meta.description = "Open a Minecraft LAN world to friends via e4mc";
          };
        }
      );
    };
}
