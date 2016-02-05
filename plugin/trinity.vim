
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" File Name:   Trinity                                                         "
" Abstract:    A (G)Vim plugin for building 'Source Explorer', 'Taglist' and   "
"              'NERD tree' into an IDE which works like the "Source Insignt".  "
" Authors:     Wenlong Che <wenlong.che@gmail.com>                             "
" Homepage:    http://www.vim.org/scripts/script.php?script_id=2347            "
" GitHub:      https://github.com/wesleyche/Trinity                            "
" Version:     2.1                                                             "
" Last Change: March 21th, 2013                                                "
" Licence:     This program is free software; you can redistribute it and / or "
"              modify it under the terms of the GNU General Public License as  "
"              published by the Free Software Foundation; either version 2, or "
"              any later version.                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Avoid reloading {{{

if exists('loaded_trinity')
    finish
endif

let loaded_trinity = 1
let s:save_cpo = &cpoptions

set cpoptions&vim

" }}}

" VIM version control {{{

" The VIM version control for running the Trinity

if v:version < 700
    " Tell the user what has happened
    echohl ErrorMsg
        echo "Require VIM 7.0 or above for running the Trinity."
    echohl None
    finish
endif

" }}}

" User interfaces {{{

" User interface for switching all the three plugins

command! -nargs=0 -bar TrinityToggleAll
    \ call <SID>Trinity_Toggle()

" User interface for switching the TagList

command! -nargs=0 -bar TrinityToggleTagList
    \ call <SID>Trinity_ToggleTagList()

" User interface for switching the Source Explorer

command! -nargs=0 -bar TrinityToggleSourceExplorer
    \ call <SID>Trinity_ToggleSourceExplorer()

" User interface for switching the NERD tree

command! -nargs=0 -bar TrinityToggleNERDTree
    \ call <SID>Trinity_ToggleNERDTree()

" User interface for updating window positions
" e.g. open/close Quickfix

command! -nargs=0 -bar TrinityUpdateWindow
    \ call <SID>Trinity_UpdateWindow()

" }}}

" Global variables {{{

let s:Trinity_switch         = 0
let s:Trinity_tabPage        = 0
let s:Trinity_isDebug        = 0
let s:Trinity_logPath        = '~/trinity.log'

let s:tag_list_switch        = 0
let s:tag_list_title         = "__Tag_List__"

let s:nerd_tree_switch       = 0
let s:nerd_tree_title        = "_NERD_tree_"

let s:source_explorer_switch = 0
let s:source_explorer_title  = "Source_Explorer"

" }}}

" Trinity_InitTagList() {{{

" Initialize the parameters of the 'TagList' plugin

function! <SID>Trinity_InitTagList()

    " Split to the right side of the screen
    let g:Tlist_Use_Right_Window = 1
    " Set the window width
    let g:Tlist_WinWidth = 40
    " Sort by the order
    let g:Tlist_Sort_Type = "order"
    " Do not display the help info
    let g:Tlist_Compact_Format = 1
    " If you are the last, kill yourself
    let g:Tlist_Exit_OnlyWindow = 1
    " Do not close tags for other files
    let g:Tlist_File_Fold_Auto_Close = 1
    " Do not show folding tree
    let g:Tlist_Enable_Fold_Column = 0
    " Always display one file tags
    let g:Tlist_Show_One_File = 1

endfunction " }}}

" Trinity_InitSourceExplorer() {{{

" Initialize the parameters of the 'Source Explorer' plugin

function! <SID>Trinity_InitSourceExplorer()

    " // Set the height of Source Explorer window                                  "
    if has("unix")
        let g:SrcExpl_winHeight = 13
    else
        let g:SrcExpl_winHeight = 8
    endif
    " // Set 1 ms for refreshing the Source Explorer                               "
    let g:SrcExpl_refreshTime = 1
    " // Set "Enter" key to jump into the exact definition context                 "
    let g:SrcExpl_jumpKey = "<ENTER>"
    " // Set "Space" key for back from the definition context                      "
    let g:SrcExpl_gobackKey = "<SPACE>"
    " // In order to Avoid conflicts, the Source Explorer should know what plugins "
    " // are using buffers. And you need add their bufname into the list below     "
    " // according to the command ":buffers!"                                      "
    let g:SrcExpl_pluginList = [
        \ s:tag_list_title,
        \ s:nerd_tree_title,
        \ s:source_explorer_title
    \ ]
    " // Enable/Disable the local definition searching, and note that this is not  "
    " // guaranteed to work, the Source Explorer doesn't check the syntax for now. "
    " // It only searches for a match with the keyword according to command 'gd'   "
    let g:SrcExpl_searchLocalDef = 1
    " // Do not let the Source Explorer update the tags file when opening          "
    let g:SrcExpl_isUpdateTags = 0
    " // Use program 'ctags' with argument '--sort=foldcase -R' to create or       "
    " // update a tags file                                                        "
    " let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
    " // Set "<F12>" key for updating the tags file artificially                   "
    " let g:SrcExpl_updateTagsKey = "<F12>"
    " // Set "<F3>" key for displaying the previous definition in the jump list    "
    let g:SrcExpl_prevDefKey = "<F3>"
    " // Set "<F4>" key for displaying the next definition in the jump list        "
    let g:SrcExpl_nextDefKey = "<F4>"

endfunction " }}}

" Trinity_InitNERDTree() {{{

" Initialize the parameters of the 'NERD tree' plugin

function! <SID>Trinity_InitNERDTree()

    " Set the window width
    let g:NERDTreeWinSize = 23
    " Set the window position
    let g:NERDTreeWinPos = "left"
    " Auto centre
    let g:NERDTreeAutoCenter = 0
    " Not Highlight the cursor line
    let g:NERDTreeHighlightCursorline = 0

endfunction " }}}

" Trinity_Debug() {{{

" Log the supplied debug information along with the time

function! <SID>Trinity_Debug(log)

    " Debug switch is on
    if s:Trinity_isDebug == 1
        " Log file path is valid
        if s:Trinity_logPath != ''
            " Output to the log file
            exe "redir >> " . s:Trinity_logPath
            " Add the current time
            silent echon strftime("%H:%M:%S") . ": " . a:log . "\r\n"
            redir END
        endif
    endif

endfunction " }}}

" Trinity_GetEditWin() {{{

" Get the edit window number

function! <SID>Trinity_GetEditWin()

    let l:i = 1
    let l:j = 1

    let l:srcexplWin = 0
    let l:pluginList = [
            \ s:tag_list_title,
            \ s:source_explorer_title,
            \ s:nerd_tree_title
        \]

    try
        let l:srcexplWin = g:SrcExpl_GetWin()
    catch
    finally
        while 1
            " compatible for Named Buffer Version and Preview Window Version
            for item in l:pluginList
                if (bufname(winbufnr(l:i)) ==# item)
                \ || (l:srcexplWin == 0 && getwinvar(l:i, '&previewwindow'))
                \ || (l:srcexplWin == l:i)
                    break
                else
                    let l:j += 1
                endif
            endfor

            if l:j >= len(l:pluginList)
                return l:i
            else
                let l:i += 1
                let l:j = 0
            endif

            if l:i > winnr("$")
                return -1
            endif
        endwhile
    endtry

endfunction " }}}

" Trinity_UpdateWindow() {{{

" Update the postions of the whole IDE windows

function! <SID>Trinity_UpdateWindow()

    let l:source_explorer_winnr = 0
    try
        " For Named Buffer Version
        let l:source_explorer_winnr = g:SrcExpl_GetWin()
    catch
    finally
        " For Preview Window Version
        if l:source_explorer_winnr == 0
            let l:i = 1
            while 1
                if bufname(winbufnr(l:i)) ==# s:source_explorer_title
                        \ || getwinvar(l:i, '&previewwindow')
                    let l:source_explorer_winnr = l:i
                    break
                endif
                let l:i += 1
                if l:i > winnr("$")
                    break
                endif
            endwhile
        endif

        if l:source_explorer_winnr > 0
            silent! exe l:source_explorer_winnr . "wincmd " . "w"
            silent! exe "wincmd " . "J"
            silent! exe g:SrcExpl_winHeight . " wincmd " . "_"
        endif

        let l:rtn = <SID>Trinity_GetEditWin()
        if l:rtn < 0
            return
        endif

        silent! exe l:rtn . "wincmd w"
    endtry

endfunction " }}}

" Trinity_UpdateStatus() {{{

" Update status according to the status of the three plugins

function! <SID>Trinity_UpdateStatus()

    if s:tag_list_switch == 1 ||
        \ s:source_explorer_switch == 1 ||
    \ s:nerd_tree_switch == 1
        let s:Trinity_switch = 1
    endif

    if s:tag_list_switch == 0 &&
        \ s:source_explorer_switch == 0 &&
    \ s:nerd_tree_switch == 0
        let s:Trinity_switch = 0
    endif

endfunction " }}}

" Trinity_ToggleNERDTree() {{{

" Initialize the parameters of the 'NERD tree' plugin

function! <SID>Trinity_ToggleNERDTree()

    if s:Trinity_tabPage == 0
        let s:Trinity_tabPage = tabpagenr()
    endif

    if s:Trinity_tabPage != tabpagenr()
        echohl ErrorMsg
            echo "Trinity: Not support multiple tab pages for now."
        echohl None
        return
    endif

    call <SID>Trinity_UpdateStatus()
    if s:Trinity_switch == 0
        if s:nerd_tree_switch == 0
            call <SID>Trinity_InitNERDTree()
            NERDTree
            let s:nerd_tree_switch = 1
        endif
    else
        if s:nerd_tree_switch == 1
            NERDTreeClose
            let s:nerd_tree_switch = 0
        else
            call <SID>Trinity_InitNERDTree()
            NERDTree
            let s:nerd_tree_switch = 1
        endif
    endif

    call <SID>Trinity_UpdateStatus()
    call <SID>Trinity_UpdateWindow()

    if s:Trinity_switch == 0
        let s:Trinity_tabPage = 0
    endif

endfunction " }}}

" Trinity_ToggleSourceExplorer() {{{

" The User Interface function to open / close the Source Explorer

function! <SID>Trinity_ToggleSourceExplorer()

    if s:Trinity_tabPage == 0
        let s:Trinity_tabPage = tabpagenr()
    endif
    if s:Trinity_tabPage != tabpagenr()
        echohl ErrorMsg
            echo "Trinity: Not support multiple tab pages for now."
        echohl None
        return
    endif
    call <SID>Trinity_UpdateStatus()
    if s:Trinity_switch == 0
        if s:source_explorer_switch == 0
            call <SID>Trinity_InitSourceExplorer()
            SrcExpl
            let s:source_explorer_switch = 1
        endif
    else
        if s:source_explorer_switch == 1
            SrcExplClose
            let s:source_explorer_switch = 0
        else
            call <SID>Trinity_InitSourceExplorer()
            SrcExpl
            let s:source_explorer_switch = 1
        endif
    endif

    call <SID>Trinity_UpdateStatus()
    call <SID>Trinity_UpdateWindow()

    if s:Trinity_switch == 0
        let s:Trinity_tabPage = 0
    endif

endfunction " }}}

" Trinity_ToggleTagList() {{{

" The User Interface function to open / close the TagList

function! <SID>Trinity_ToggleTagList()

    if s:Trinity_tabPage == 0
        let s:Trinity_tabPage = tabpagenr()
    endif
    if s:Trinity_tabPage != tabpagenr()
        echohl ErrorMsg
            echo "Trinity: Not support multiple tab pages for now."
        echohl None
        return
    endif
    call <SID>Trinity_UpdateStatus()
    if s:Trinity_switch == 0
        if s:tag_list_switch == 0
            call <SID>Trinity_InitTagList()
            Tlist
            let s:tag_list_switch = 1
        endif
    else
        if s:tag_list_switch == 1
            TlistClose
            let s:tag_list_switch = 0
        else
            call <SID>Trinity_InitTagList()
            Tlist
            let s:tag_list_switch = 1
        endif
    endif

    call <SID>Trinity_UpdateStatus()
    call <SID>Trinity_UpdateWindow()

    if s:Trinity_switch == 0
        let s:Trinity_tabPage = 0
    endif

endfunction " }}}

" Trinity_Toggle() {{{

" The User Interface function to open / close the Trinity of
" TagList, Source Explorer and NERD tree

function! <SID>Trinity_Toggle()

    if s:Trinity_tabPage == 0
        let s:Trinity_tabPage = tabpagenr()
    endif

    if s:Trinity_tabPage != tabpagenr()
        echohl ErrorMsg
            echo "Trinity: Not support multiple tab pages for now."
        echohl None
        return
    endif

    if s:Trinity_switch == 1
        if s:tag_list_switch == 1
            TlistClose
            let s:tag_list_switch = 0
        endif
        if s:source_explorer_switch == 1
            SrcExplClose
            let s:source_explorer_switch = 0
        endif
        if s:nerd_tree_switch == 1
            NERDTreeClose
            let s:nerd_tree_switch = 0
        endif
        let s:Trinity_switch = 0
        let s:Trinity_tabPage = 0
    else
        call <SID>Trinity_InitTagList()
        Tlist
        let s:tag_list_switch = 1
        call <SID>Trinity_InitSourceExplorer()
        SrcExpl
        let s:source_explorer_switch = 1
        call <SID>Trinity_InitNERDTree()
        NERDTree
        let s:nerd_tree_switch = 1
        let s:Trinity_switch = 1
    endif

    call <SID>Trinity_UpdateWindow()

endfunction " }}}

" Avoid side effects {{{

set cpoptions&
let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:foldmethod=marker:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

