let s:config     = ctrlspace#context#Configuration()
let s:modes      = ctrlspace#modes#Modes()
let s:sizes      = ctrlspace#context#SymbolSizes()
let s:textBuffer = []

let s:helpMap = {
      \ "Search":    {},
      \ "Nop":       {},
      \ "Buffer":    {},
      \ "File":      {},
      \ "Tab":       {},
      \ "Workspace": {},
      \ "Bookmark":  {}
      \ }

let s:descriptions = {
      \ "ctrlspace#keys#common#ToggleHelp":                   "Toggle the Help view",
      \ "ctrlspace#keys#common#Down":                         "Move the selection bar down",
      \ "ctrlspace#keys#common#Up":                           "Move the selection bar up",
      \ "ctrlspace#keys#common#Previous":                     "Move the selection bar to the previously opened item",
      \ "ctrlspace#keys#common#PreviousCR":                   "Move the selection bar to the previously opened item and open it",
      \ "ctrlspace#keys#common#Next":                         "Move the selection bar to the next opened item",
      \ "ctrlspace#keys#common#Top":                          "Move the selection bar to the top of the list",
      \ "ctrlspace#keys#common#Bottom":                       "Move the selection bar to the bottom of the list",
      \ "ctrlspace#keys#common#ScrollDown":                   "Move the selection bar one screen down",
      \ "ctrlspace#keys#common#ScrollUp":                     "Move the selection bar one screen up",
      \ "ctrlspace#keys#common#HalfScrollDown":               "Move the selection bar a half screen down",
      \ "ctrlspace#keys#common#HalfScrollUp":                 "Move the selection bar a half screen up",
      \ "ctrlspace#keys#common#Close":                        "Close the list",
      \ "ctrlspace#keys#common#Quit":                         "Quit Vim with a prompt if unsaved changes found",
      \ "ctrlspace#keys#common#EnterSearchMode":              "Enter Search Mode",
      \ "ctrlspace#keys#common#RestorePreviousSearch":        "Bring back the previous searched text",
      \ "ctrlspace#keys#common#RestoreNextSearch":            "Bring the next searched text",
      \ "ctrlspace#keys#common#BackOrClearSearch":            "Return to the previous list (if any) or clear the searched text",
      \ "ctrlspace#keys#common#ToggleFileMode":               "Toggle File List ([O]pen List) view",
      \ "ctrlspace#keys#common#ToggleFileModeAndSearch":      "Enter the File List ([O]pen List) in Search Mode",
      \ "ctrlspace#keys#common#ToggleBufferMode":             "Toggle Buffer List view ([H]ome List)",
      \ "ctrlspace#keys#common#ToggleBufferModeAndSearch":    "Enter the Buffer List ([H]ome List) in Search Mode",
      \ "ctrlspace#keys#common#ToggleWorkspaceMode":          "Toggle Workspace List view",
      \ "ctrlspace#keys#common#ToggleWorkspaceModeAndSearch": "Enter the Workspace List in Search Mode",
      \ "ctrlspace#keys#common#ToggleTabMode":                "Toggle Tab List view (Tab [L]ist)",
      \ "ctrlspace#keys#common#ToggleTabModeAndSearch":       "Enter the Tab List (Tab [L]ist) in Search Mode",
      \ "ctrlspace#keys#common#ToggleBookmarkMode":           "Toggle Bookmark List view",
      \ "ctrlspace#keys#common#ToggleBookmarkModeAndSearch":  "Enter the Bookmark List in Search Mode",
      \ "ctrlspace#keys#nop#ClearLetters":                    "Clear search phrase",
      \ "ctrlspace#keys#nop#BackOrClearSearch":               "Go back or remove search phrase",
      \ "ctrlspace#keys#nop#ToggleFileMode":                  "Toggle File List ([O]pen List) view",
      \ "ctrlspace#keys#nop#ToggleFileModeAndSearch":         "Enter the File List ([O]pen List) in Search Mode",
      \ "ctrlspace#keys#nop#ToggleBufferMode":                "Toggle Buffer List view ([H]ome List)",
      \ "ctrlspace#keys#nop#ToggleBufferModeAndSearch":       "Enter the Buffer List ([H]ome List) in Search Mode",
      \ "ctrlspace#keys#nop#ToggleWorkspaceMode":             "Toggle Workspace List view",
      \ "ctrlspace#keys#nop#ToggleWorkspaceModeAndSearch":    "Enter the Workspace List in Search Mode",
      \ "ctrlspace#keys#nop#ToggleTabMode":                   "Toggle Tab List view (Tab [L]ist)",
      \ "ctrlspace#keys#nop#ToggleTabModeAndSearch":          "Enter the Tab List (Tab [L]ist) in Search Mode",
      \ "ctrlspace#keys#nop#ToggleBookmarkMode":              "Toggle Bookmark List view",
      \ "ctrlspace#keys#nop#ToggleBookmarkModeAndSearch":     "Enter the Bookmark List in Search Mode",
      \ "ctrlspace#keys#nop#Close":                           "Close the list",
      \ "ctrlspace#keys#nop#Quit":                            "Quit Vim with a prompt if unsaved changes found",
      \ "ctrlspace#keys#nop#RestorePreviousSearch":           "Bring back the previous searched text",
      \ "ctrlspace#keys#nop#RestoreNextSearch":               "Bring the next searched text",
      \ "ctrlspace#keys#search#ClearOrRemoveLetter":          "Remove a previously entered character",
      \ "ctrlspace#keys#search#AddLetter":                    "Add a character to search",
      \ "ctrlspace#keys#search#SwitchOff":                    "Exit Search Mode",
      \ "ctrlspace#keys#search#SwitchOffCR":                  "Exit Search Mode and go to first result",
      \ "ctrlspace#keys#search#ClearLetters":                 "Clear search phrase",
      \ }

function! ctrlspace#help#AddMapping(funcName, mapName, entry)
    if has_key(s:helpMap, a:mapName)
        let s:helpMap[a:mapName][a:entry] = a:funcName
    endif
endfunction

function! ctrlspace#help#HelpMap()
    return s:helpMap
endfunction

function! ctrlspace#help#Descriptions()
    return s:descriptions
endfunction

function! s:init()
    call extend(s:descriptions, s:config.Help)
endfunction

call s:init()

function! ctrlspace#help#DisplayHelp(fill)
    if s:modes.Nop.Enabled
        let mapName = "Nop"
    elseif s:modes.Search.Enabled
        let mapName = "Search"
    else
        let mapName = ctrlspace#modes#CurrentListView().Name
    endif

    call s:collectKeysInfo(mapName)

    let mi = s:modeInfo()

    call s:puts("Context help for " . mi[0] . " list (modes: " . join(mi[1:], ", ") . ")")
    call s:puts("")

    for info in b:helpKeyDescriptions
        call s:puts(info.key . " | " . info.description)
    endfor

    call s:puts("")
    call s:puts(s:config.Symbols.CS . " CtrlSpace 5.0.0 (c) 2013-2015 Szymon Wrozynski and Contributors")

    setlocal modifiable

    let b:size = len(s:textBuffer)

    if b:size > s:config.Height
        let maxHeight = ctrlspace#window#MaxHeight()

        if b:size < maxHeight
            silent! exe "resize " . b:size
        else
            silent! exe "resize " . maxHeight
        endif
    endif

    silent! put! =s:flushTextBuffer()
    normal! GkJ

    while winheight(0) > line(".")
        silent! put =a:fill
    endwhile

    normal! 0
    normal! gg

    setlocal nomodifiable
endfunction

function! s:puts(str)
    let str = "  " . a:str

    if &columns < (strwidth(str) + 2)
        let str = strpart(str, 0, &columns - 2 - s:sizes.Dots) . s:config.Symbols.Dots
    endif

    while strwidth(str) < &columns
        let str .= " "
    endwhile

    call add(s:textBuffer, str)
endfunction

function! s:flushTextBuffer()
    let text = join(s:textBuffer, "\n")
    let s:textBuffer = []
    return text
endfunction

function! s:keyHelp(key, description)
    if !exists("b:helpKeyDescriptions")
        let b:helpKeyDescriptions = []
        let b:helpKeyWidth = 0
    endif

    call add(b:helpKeyDescriptions, { "key": a:key, "description": a:description })

    if strwidth(a:key) > b:helpKeyWidth
        let b:helpKeyWidth = strwidth(a:key)
    else
        for keyInfo in b:helpKeyDescriptions
            while strwidth(keyInfo.key) < b:helpKeyWidth
                let keyInfo.key .= " "
            endwhile
        endfor
    endif
endfunction

function! s:collectKeysInfo(mapName)
    for key in sort(keys(s:helpMap[a:mapName]))
        let fn = s:helpMap[a:mapName][key]

        if has_key(s:descriptions, fn) && !empty(s:descriptions[fn])
            call s:keyHelp(key, s:descriptions[fn])
        endif
    endfor
endfunction

function! s:modeInfo()
    let info = []
    let clv  = ctrlspace#modes#CurrentListView()

    if clv.Name ==# "Workspace"
        call add(info, "WORKSPACE")
        if clv.Data.SubMode ==# "load"
            call add(info, "LOAD")
        elseif clv.Data.SubMode ==# "save"
            call add(info, "SAVE")
        endif
    elseif clv.Name ==# "Tab"
        call add(info, "TAB LIST")
    elseif clv.Name ==# "Bookmark"
        call add(info, "BOOKMARK")
    else
        if clv.Name ==# "File"
            call add(info, "FILE")
        elseif clv.Name ==# "Buffer"
            call add(info, "BUFFER")
            if clv.Data.SubMode == "visual"
                call add(info, "VISUAL")
            elseif clv.Data.SubMode == "single"
                call add(info, "SINGLE")
            elseif clv.Data.SubMode == "all"
                call add(info, "ALL")
            endif
        endif

        if s:modes.NextTab.Enabled
            call add(info, "NEXT TAB")
        endif
    endif

    if s:modes.Search.Enabled
        call add(info, "SEARCH")
    endif

    if s:modes.Zoom.Enabled
        call add(info, "ZOOM")
    endif

    return info
endfunction
