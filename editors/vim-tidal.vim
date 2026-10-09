" Source this file BEFORE loading tidalcycles/vim-tidal.
let s:kit = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
let g:tidal_ghci = shellescape(s:kit . '/bin/tidal-ghci')
let g:tidal_boot = s:kit . '/runtime/BootTidal.hs'
" Audio is owned by `podman compose up`, not by the editor.
let g:tidal_sc_enable = 0
let g:tidal_superdirt_enable = 0
