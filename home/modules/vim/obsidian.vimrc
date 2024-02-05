" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" Yank to system clipboard
set clipboard=unnamed

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back
exmap forward obcommand app:go-forward
nmap <C-i> :forward
"

nmap - /

unmap <Space>

" https://github.com/esm7/obsidian-vimrc-support

exmap wq obcommand workspace:close
exmap q obcommand workspace:close
nmap <Space>w :w
nmap <Space>q :q
nmap <Space>x :q

" keep visual does not work, but tab + shift-tab does
" vmap < <gv
" vmap > >gv

exmap only obcommand workspace:close-others
nmap <Space>bX :only

exmap focusRight obcommand editor:focus-right
nmap <C-l> :focusRight

exmap focusLeft obcommand editor:focus-left
nmap <C-h> :focusLeft

exmap focusTop obcommand editor:focus-top
nmap <C-k> :focusTop

exmap focusBottom obcommand editor:focus-bottom
nmap <C-j> :focusBottom

exmap splitHorizontal obcommand workspace:split-horizontal
nmap <Space>sh :splitHorizontal

exmap splitVertical obcommand workspace:split-vertical
nmap <Space>sv :splitVertical

exmap nextTab obcommand workspace:next-tab
nmap <Tab> :nextTab

exmap prevTab obcommand workspace:previous-tab
nmap <S-Tab> :prevTab

exmap liveGrep obcommand obsidian-another-quick-switcher:grep
nmap <Space>fs :liveGrep

exmap openFile obcommand switcher:open
nmap <Space>ff :openFile

exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nmap <Space>, :quickSwitcher

exmap followNextLink obcommand editor:follow-link
nmap gd :followNextLink

exmap followNextLinkTab obcommand editor:open-link-in-new-leaf
nmap gD :followNextLinkTab

exmap toggleChecklist obcommand editor:toggle-checklist-status
nmap <Space>c :toggleChecklist
"vmap <Space>t :toggleChecklist

exmap taskEdit obcommand obsidian-tasks-plugin:edit-task
exmap taskToggle obcommand obsidian-tasks-plugin:toggle-done
nmap <Space>tt :taskEdit
nmap <Space>td :taskToggle


exmap toggleCode surround ` `
vmap ` :toggleCode


exmap daily obcommand daily-notes
nmap <Space>fd :daily