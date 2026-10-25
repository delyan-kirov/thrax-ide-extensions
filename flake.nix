{
  description = "Thrax editor tooling: build the tree-sitter grammar for Helix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # Kept out of the root dev shell: only regenerating the editor grammar
      # needs these. tools/editors/TREE_SITTER_GEN.thx writes grammar.js from
      # documentation/thrax.y, and `tree-sitter generate` turns it into the C
      # parser that Helix compiles (`hx --grammar build`). tree-sitter runs
      # grammar.js under node.
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.tree-sitter
          pkgs.nodejs
          pkgs.gcc
        ];
      };
    };
}
