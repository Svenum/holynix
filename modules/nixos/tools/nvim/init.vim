""""""""""""""""""""""""""""""
"         Nvim-Tree          "
""""""""""""""""""""""""""""""

" Plugin Config
lua << EOF
  -- Disable netrw
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- enable termguicolors highlights
  vim.opt.termguicolors = true

  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    filters = {
      dotfiles = true,
      custom = { "^.git$" },
    }
  })
  -- Autostart
  local function open_nvim_tree(data)

    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

      -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if not directory and not no_name then
      return
    end

    -- change to the directory
    if directory then
      vim.cmd.cd(data.file)
    end

    -- open the tree
    require("nvim-tree.api").tree.open()
  end

  vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
EOF

" Shortcuts
nnoremap <silent> <C-n> :NvimTreeToggle<CR>


""""""""""""""""""""""""""""""
"         tmux-nvim          "
""""""""""""""""""""""""""""""
" Plugin Config
lua << EOF
  require("tmux").setup()
EOF

""""""""""""""""""""""""""""""
"          airline           "
""""""""""""""""""""""""""""""
" Plugin Config
let g:airline_theme='luna'

" Enable line number
set number relativenumber
set laststatus=2

""""""""""""""""""""""""""""""
"          rainbow           "
""""""""""""""""""""""""""""""
let g:rainbow_active=1

""""""""""""""""""""""""""""""
"            coc             "
""""""""""""""""""""""""""""""
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col -1] =~# '\s'
endfunction

" Set Alt+Enter
inoremap <silent><expr> <A-CR> coc#pum#visible() ? coc#pum#confirm()
          \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

""""""""""""""""""""""""""""""
"      catppuccin-nvim       "
""""""""""""""""""""""""""""""
lua << EOF
  require("catppuccin").setup({
    term_colors = true,
    transparent_background = true,
    integrations = {
      coc_nvim = true,
      gitgutter,
    },
  })
EOF

""""""""""""""""""""""""""""""
"         gitgutter          "
""""""""""""""""""""""""""""""
" Plugin Config
let g:gitgutter_highlight_linenrs=1
let g:gitgutter_highlight_lines=1
let g:gitgutter_highlight_lines=1
let g:gitgutter_enabled=1
let g:gitgutter_signs=1

" shotcuts
nnoremap <silent> <C-g> <Nop>
nnoremap <silent> <C-g>p :GitGutterPreviewHunk<CR>
nnoremap <silent> <C-g>n :GitGutterNextHunk<CR>
nnoremap <silent> <C-g>N :GitGutterPrevHunk<CR>
nnoremap <silent> <C-g>u :GitGutterUndoHunk<CR>
nnoremap <silent> <C-g>t :GitGutterToggle<CR>

""""""""""""""""""""""""""""""
"         gitgutter          "
""""""""""""""""""""""""""""""
" Plugin Config
let g:mkdp_auto_close = 0

" shotcuts
nnoremap <M-m> :MarkdownPreview<CR>

""""""""""""""""""""""""""""""
"            other           "
""""""""""""""""""""""""""""""
" Cursor
set tabstop=2
set shiftwidth=2
set expandtab
  
" Add CTRL+D
nmap <expr> <silent> <C-d> <SID>select_current_word()
function! s:select_current_word()
  if !get(b:, 'coc_cursors_activated', 0)
    return "\<Plug>(coc-cursors-word)"
  endif
  return "*\<Plug>(coc-cursors-word):nohlsearch\<CR>"
endfunc

" Shortcuts
nnoremap <n> <Nop>
nnoremap <silent> <C-Right> :tabnext<CR>
nnoremap <silent> <C-Left> :tabprevious<CR>
nnoremap <silent> <C-Down> :tabclose<CR> 
tnoremap <silent> <C-Right> <C-\><C-n> :tabnext<CR>
tnoremap <silent> <C-Left> <C-\><C-n> :tabprevious<CR>
tnoremap <silent> <C-Down> <C-\><C-n> :tabclose<CR> 

nnoremap <silent> <C-f> <Esc> /

nnoremap <silent> <C-S-Right> :vert res +5 <CR>
nnoremap <silent> <C-S-Left> :vert res -5 <CR>
nnoremap <silent> <C-S-Up> :res +5 <CR>
nnoremap <silent> <C-S-Down> :res -5 <CR>
tnoremap <silent> <C-S-Right> <C-\><C-n> :vert res +5 <CR> i
tnoremap <silent> <C-S-Left> <C-\><C-n> :vert res -5 <CR> i
tnoremap <silent> <C-S-Up> <C-\><C-n> :res +5 <CR> i
tnoremap <silent> <C-S-Down> <C-\><C-n> :res -5 <CR> i

nnoremap <C-c> :quitall<CR>

nnoremap <C-q> :q<CR>
inoremap <C-q> <Esc>:q<CR>
tnoremap <C-q> <C-\><C-n>:q<CR>

nnoremap <A-w> :w<CR>
inoremap <A-w> <Esc>:w<CR>

nnoremap <silent> <A-Down> :split<CR>
nnoremap <silent> <A-Right> :vsplit<CR>

inoremap <C-h> <C-w>

" Functions
if has('nvim')
    augroup terminal_setup | au!
        autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i
    augroup end
endif

" Open on last line opened before closed
autocmd BufRead * autocmd FileType <buffer> ++once
  \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

autocmd BufWinEnter,WinEnter term://* startinsert
