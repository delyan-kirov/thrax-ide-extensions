# Thrax editor support

Editor integrations for [Thrax](https://github.com/delyan-kirov/Thrax), kept as
the `tools/editors` submodule of the compiler repository. Everything here talks
to the compiler's language server, `thrax lsp`; see `documentation/lsp.md` in
the Thrax repository for what it provides.

| Directory | Editor |
|---|---|
| `vscode/` | VS Code: `npm install && npx vsce package --allow-missing-repository` |
| `zed/` | Zed: install as a dev extension |
| `neovim/` | Neovim 0.10+: `require("thrax").setup()` |
| `helix/` | Helix: `languages.toml` and highlight queries |
| `tree-sitter-thrax/` | the tree-sitter grammar Helix and Zed parse with, generated |

`TREE_SITTER_GEN.thx` generates the grammar from the Bison spec
`documentation/thrax.y` (`thxdo tree-sitter` from the Thrax root, with the
tree-sitter CLI from `flake.nix`). The output is committed because Zed loads a
grammar only from a git revision.

`TAGS.thx` writes a ctags file for Vim and Neovim: `thxdo tags [-o FILE] [PATH...]`.
