set number
set ff=unix
set hidden                     " allow switching buffers without saving
if has('clipboard')
    set clipboard+=unnamedplus   " yank/paste to system clipboard
endif
set undofile                   " keep undo history across sessions
if has('termguicolors')
    set termguicolors           " true color support
endif
syntax on                      " syntax highlighting (slow on very large files)
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>
