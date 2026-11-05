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
in

pkgs.mkShell {
  name = "dodwell-us-blog";

  buildInputs = with pkgs; [
    # Site generation (keep in sync with HUGO_VERSION in .github/workflows/hugo.yaml)
    unstable.hugo
    git
    nodejs        # only needed if a package.json is ever added (CI runs `npm ci`)

    # Utilities
    jq
    git-filter-repo
    claude-code
  ];

  shellHook = ''
    echo "hugo $(hugo version | cut -d' ' -f2)  —  serve: hugo server -D   build: hugo --gc --minify"
  '';
}
