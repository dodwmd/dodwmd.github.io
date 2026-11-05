{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
    };
  }
}:

let
  claude-code-flake = builtins.getFlake "github:sadjow/claude-code-nix";
  claude-code = claude-code-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Theme (hugo-geekblog v5) needs Hugo >= 0.160; the system nixpkgs is older.
  unstable = (builtins.getFlake "github:NixOS/nixpkgs/nixpkgs-unstable").legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Node module + browser for the unslop skill's scripts (snapshot.mjs, story.mjs).
  # Exposed via NODE_PATH so no package.json / node_modules is needed in the repo.
  playwrightModules = pkgs.runCommand "playwright-node-modules" { } ''
    mkdir -p $out/node_modules
    ln -s ${pkgs.playwright-driver} $out/node_modules/playwright-core
  '';
in

pkgs.mkShell {
  name = "dodwell-us-blog";

  buildInputs = with pkgs; [
    # Site generation (keep in sync with HUGO_VERSION in .github/workflows/hugo.yaml)
    unstable.hugo
    git
    nodejs        # only needed if a package.json is ever added (CI runs `npm ci`)

    # Visual checks and the unslop skill (screenshots, before/after video)
    chromium
    ffmpeg

    # Utilities
    jq
    git-filter-repo
    claude-code
  ];

  NODE_PATH = "${playwrightModules}/node_modules";
  CHROME_PATH = "${pkgs.chromium}/bin/chromium";

  shellHook = ''
    echo "hugo $(hugo version | cut -d' ' -f2)  —  serve: hugo server -D   build: hugo --gc --minify"
  '';
}
