{
  description = "Real-time 8D spatial audio for Linux via PipeWire";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    eight-d-src = {
      url = "github:MOHAMEDELWAZANI/8DMusic";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      eight-d-src,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      desktopItem = pkgs.makeDesktopItem {
        name = "8dmusic";
        exec = "8dmusic";
        icon = "8dmusic";
        desktopName = "8D Music";
        genericName = "Real-time 8D Spatial Audio";
        comment = "Spatialise system audio live via PipeWire";
        categories = [
          "AudioVideo"
          "Audio"
        ];
        terminal = false;
      };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "8dmusic";
        version = "unstable";
        src = eight-d-src;
        sourceRoot = "source/cpp";

        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.copyDesktopItems
        ];

        buildInputs = [
          pkgs.pipewire
          pkgs.cairo
          pkgs.libx11
          pkgs.pango
          pkgs.systemd
        ];

        desktopItems = [ desktopItem ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          cp 8dmusic $out/bin/

          mkdir -p $out/share/icons/hicolor/256x256/apps
          find ../assets -maxdepth 2 -type f \( -name "*.png" -o -name "*.svg" \) | head -n 1 | xargs -r -I {} cp {} $out/share/icons/hicolor/256x256/apps/8dmusic.png

          runHook postInstall
        '';
      };
    };
}
