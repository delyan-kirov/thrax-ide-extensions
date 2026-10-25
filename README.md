# Thrax editor support

Editor integrations for [Thrax](https://github.com/delyan-kirov/Thrax), kept as
the `tools/editors` submodule of the compiler repository. Everything here talks
to the compiler's language server, `thrax lsp`; see `documentation/lsp.md` in
the Thrax repository for what it provides.

| Directory | Editor |
|---|---|
| `vscode/` | VS Code: `nix run path:tools/editors#vscode` (unpacked), or `npm install && npx vsce package --allow-missing-repository` |
| `zed/` | Zed: `nix run path:tools/editors#zed`, then `zed: install dev extension` |
| `neovim/` | Neovim 0.10+: `require("thrax").setup()` |
| `helix/` | Helix: `languages.toml` and highlight queries |
| `tree-sitter-thrax/` | the tree-sitter grammar Helix and Zed parse with, generated |

`TREE_SITTER_GEN.thx` generates the grammar from the Bison spec
`documentation/thrax.y` (`thxdo tree-sitter` from the Thrax root, with the
tree-sitter CLI from `flake.nix`). The output is committed because Zed loads a
grammar only from a git revision.

`flake.nix` also starts Zed with what building its extension needs: a Rust
toolchain with the `wasm32-wasip2` target (Zed uses the first `cargo` on PATH,
and nixpkgs' rustc cannot build for it), and, under NixOS's nix-ld, the
libraries the wasi-sdk clang Zed downloads to compile grammars expects
(`libtinfo`, `libstdc++`).

`TAGS.thx` writes a ctags file for Vim and Neovim: `thxdo tags [-o FILE] [PATH...]`.
