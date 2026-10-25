{
  description = "Thrax editor tooling: the tree-sitter grammar, and editors set up to build the extensions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      # Zed builds a dev extension with the first `cargo` on PATH, for
      # wasm32-wasip2, which nixpkgs' rustc has no standard library for.
      rust = pkgs.rust-bin.stable.latest.default.override { targets = [ "wasm32-wasip2" ]; };

      # Zed compiles grammars with a wasi-sdk clang it downloads, a generic
      # Linux binary. Under nix-ld it starts but lacks these libraries.
      wasiSdkLibs = pkgs.lib.makeLibraryPath [
        pkgs.ncurses
        pkgs.stdenv.cc.cc.lib
      ];

      zed = pkgs.writeShellScriptBin "zed-thrax" ''
        export PATH=${rust}/bin:$PATH
        export NIX_LD_LIBRARY_PATH=${wasiSdkLibs}''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}
        exec ${pkgs.zed-editor}/bin/zeditor "$@"
      '';

      # VS Code is unfree in nixpkgs, so this uses the `code` on PATH.
      vscode = pkgs.writeShellScriptBin "vscode-thrax" ''
        dir=''${THRAX_EDITORS:-$PWD}/vscode
        [ -d "$dir" ] || dir=$PWD/tools/editors/vscode
        if [ ! -d "$dir/node_modules" ]; then
          ${pkgs.nodejs}/bin/npm --prefix "$dir" install --no-audit --no-fund 1>&2 || exit
        fi
        exec code --extensionDevelopmentPath="$dir" "$@"
      '';
    in
    {
      # `nix run path:tools/editors#zed`: Zed, able to install tools/editors/zed
      # as a dev extension (`zed: install dev extension`).
      # `nix run path:tools/editors#vscode`: VS Code with tools/editors/vscode
      # loaded unpacked; run from the Thrax root or tools/editors, or set
      # THRAX_EDITORS to tools/editors.
      apps.${system} = {
        zed = {
          type = "app";
          program = "${zed}/bin/zed-thrax";
        };
        vscode = {
          type = "app";
          program = "${vscode}/bin/vscode-thrax";
        };
      };

      # Regenerating the grammar: TREE_SITTER_GEN.thx writes grammar.js from
      # documentation/thrax.y, and `tree-sitter generate` (which runs grammar.js
      # under node) turns it into the C parser Helix and Zed compile. Packaging
      # the VS Code extension (`npx vsce package`) needs node too, and building
      # the Zed extension by hand (`cargo build --target wasm32-wasip2`) the
      # Rust toolchain.
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.tree-sitter
          pkgs.nodejs
          pkgs.gcc
          rust
        ];
      };
    };
}
