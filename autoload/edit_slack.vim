" vim: set sw=4 et fdm=marker:
"
" edit-slack.vim - Open slack, like a file
"
" Version: 1.0.1
" Maintainer:	yaasita < https://github.com/yaasita/edit-slack.vim >

let g:edit_slack_cache = get(g:, 'edit_slack_cache', tempname())
let g:edit_slack_debug = get(g:, 'edit_slack_debug', 0)
let g:edit_slack_search_word = get(g:, 'edit_slack_search_word', "")
let s:edit_slack_go_path = expand('<sfile>:p:h:h') . "/edit-slack"
let s:edit_slack_outfile = tempname()
let s:edit_slack_common_options = '--cache ' . g:edit_slack_cache . ' --token ' . g:edit_slack_token

function! edit_slack#Open(slack_uri) abort "{{{
    let l:slack = s:ParseURI(a:slack_uri)
    if l:slack['kind'] == 'list'
        call s:List()
    elseif l:slack['kind'] == 'conversations'
        call s:ChannelsHistory(l:slack['chname'])
    elseif l:slack['kind'] == 'replies'
        call s:RepliesHistory(l:slack['chname'], l:slack['ts'])
    elseif l:slack['kind'] == 'search'
        call s:ExecSearch()
    else
        return
    endif
    setlocal nomod
    exe "e "  . s:edit_slack_outfile
    if a:slack_uri !=# l:slack['uri']
        exe "silent! bw! " . a:slack_uri
    endif
    exe "silent! bw! " . l:slack['uri']
    exe "f "  . l:slack['uri']
    exe "bw! " . s:edit_slack_outfile
    if s:IsReadOnly(l:slack['kind'])
        setlocal noma
        setlocal ro
    endif
    if l:slack['kind'] == 'conversations' || l:slack['kind'] == 'replies'
        call cursor(line('$'),1)
    endif
    redr!
    setlocal nomod
    setlocal ft=slack
endfunction "}}}
function! edit_slack#Write(slack_uri) abort "{{{
    call cursor(1,1)
    if search("^=== Message ===$","W") == 0
        call edit_slack#Open(a:slack_uri)
        return
    endif
    let l:postdata = getline(line(".")+1,"$")
    if empty(l:postdata)
        echo "no post data"
        return
    endif
    let l:slack = s:ParseURI(a:slack_uri)
    if l:slack['kind'] == 'conversations'
        call s:ChannelsPost(l:slack['chname'], l:postdata)
    elseif l:slack['kind'] == 'replies'
        call s:RepliesPost(l:slack['chname'], l:slack['ts'], l:postdata)
    endif
    call edit_slack#Open(a:slack_uri)
endfunction "}}}
function! edit_slack#Join(slack_uri) abort "{{{
    let l:slack = s:ParseURI(a:slack_uri)
    if ! has_key(l:slack, 'chname')
        echo "cannot join this channel"
        return
    endif
    let l:cmd = [ s:edit_slack_go_path,
                \ 'conversations join',
                \ s:edit_slack_common_options,
                \ '--chname', l:slack['chname'],
                \ ]
    call s:Exec_cmd(l:cmd)
    call edit_slack#Open(a:slack_uri)
endfunction "}}}
function! edit_slack#Leave(slack_uri) abort "{{{
    let l:slack = s:ParseURI(a:slack_uri)
    if ! has_key(l:slack, 'chname')
        echo "cannot leave this channel"
        return
    endif
    let l:cmd = [ s:edit_slack_go_path,
                \ 'conversations leave',
                \ s:edit_slack_common_options,
                \ '--chname', l:slack['chname'],
                \ ]
    call s:Exec_cmd(l:cmd)
    call edit_slack#Open('slack://ch')
endfunction "}}}
function! edit_slack#OpenReplies(str) abort "{{{
    let l:slack_uri = matchstr(a:str, '\v\C^slack://ch/[^\S/]+/[0-9\.]+')
    if l:slack_uri !=# ""
        call edit_slack#Open(l:slack_uri)
        return
    endif
    let l:slack_uri = matchstr(a:str, '\v\C^\=\> replies \(\d+\): \zsslack://ch/[^\S/]+/[0-9\.]+$')
    if l:slack_uri !=# ""
        call edit_slack#Open(l:slack_uri)
        return
    endif
    echo "replies uri is not found"
    return
endfunction "}}}
function! edit_slack#UploadFile(filepath, slack_uri) abort "{{{
    let l:slack = s:ParseURI(a:slack_uri)
    if l:slack['kind'] == 'conversations'
        let l:ts = '""'
    elseif l:slack['kind'] == 'replies'
        let l:ts = l:slack['ts']
    else
        echo "can not upload to this channel"
        return
    endif
    let l:cmd = [ s:edit_slack_go_path,
                \ 'files upload',
                \ s:edit_slack_common_options,
                \ '--chname', l:slack['chname'],
                \ '--file', shellescape(a:filepath),
                \ '--ts', l:ts,
                \ ]
    call s:Exec_cmd(l:cmd)
    call edit_slack#Open(a:slack_uri)
endfunction "}}}
function! edit_slack#DownloadFile(line, filepath) abort "{{{
    let l:url = matchstr(a:line, '\v^\=\> file: \zshttps://files\.slack\.com/.+')
    if l:url == ""
        echo "download url is not found"
        return
    endif
    let l:cmd = [ s:edit_slack_go_path,
                \ 'files download',
                \ s:edit_slack_common_options,
                \ '--furl', l:url,
                \ '--out', shellescape(a:filepath),
                \ ]
    call s:Exec_cmd(l:cmd)
endfunction "}}}
function! edit_slack#Search(word) abort "{{{
    let g:edit_slack_search_word = a:word
    call edit_slack#Open("slack://search")
endfunction "}}}
function! s:ExecSearch() "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'search all',
                \ s:edit_slack_common_options,
                \ '--word', shellescape(g:edit_slack_search_word),
                \ '--out', s:edit_slack_outfile,
                \ ]
    call s:Exec_cmd(l:cmd)
endfunction "}}}
function! s:List() "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'conversations list',
                \ s:edit_slack_common_options,
                \ '--out', s:edit_slack_outfile,
                \ ]
    call s:Exec_cmd(l:cmd)
endfunction "}}}
function! s:ChannelsHistory(ch) "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'conversations history',
                \ s:edit_slack_common_options,
                \ '--out', s:edit_slack_outfile,
                \ '--chname', a:ch,
                \ ]
    call s:Exec_cmd(l:cmd)
endfunction "}}}
function! s:RepliesHistory(ch, ts) "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'replies history',
                \ s:edit_slack_common_options,
                \ '--out', s:edit_slack_outfile,
                \ '--chname', a:ch,
                \ '--ts', a:ts,
                \ ]
    call s:Exec_cmd(l:cmd)
endfunction "}}}
function! s:ChannelsPost(ch, postdata) "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'conversations post',
                \ s:edit_slack_common_options,
                \ '--chname', a:ch,
                \ ]
    call s:Exec_cmd(l:cmd, a:postdata)
endfunction "}}}
function! s:RepliesPost(ch, ts, postdata) "{{{
    let l:cmd = [ s:edit_slack_go_path,
                \ 'replies post',
                \ s:edit_slack_common_options,
                \ '--chname', a:ch,
                \ '--ts', a:ts,
                \ ]
    call s:Exec_cmd(l:cmd, a:postdata)
endfunction "}}}
function! s:IsReadOnly(kind) "{{{
    if a:kind == 'list'
        return 1
    elseif a:kind == 'search'
        return 1
    elseif getline(line('$')) ==# "=== Not in member ==="
        return 1
    elseif getline(line('$')-1) ==# "=== Not in member ==="
        return 1
    else
        return 0
    endif
endfunction "}}}
function! s:ParseURI(target_uri) "{{{
    let l:uri = substitute(a:target_uri,"\/$","","")
    let l:result = {"uri": l:uri, "kind": ""}
    if l:uri ==# "slack://ch"
        let l:result['kind'] = 'list'
        return l:result
    elseif l:uri ==# "slack://search"
        let l:result['kind'] = 'search'
        return l:result
    endif
    let l:m = matchlist(l:uri,'\v\Cslack://ch/([^\S/]+)$')
    if !empty(l:m)
        let l:result['kind'] = 'conversations'
        let l:result['chname'] = l:m[1]
        return l:result
    endif
    let l:m = matchlist(a:target_uri,'\v\Cslack://ch/([^\S/]+)/([0-9\.]+)$')
    if !empty(l:m)
        let l:result['kind'] = 'replies'
        let l:result['chname'] = l:m[1]
        let l:result['ts'] = l:m[2]
        return l:result
    endif
    return l:result
endfunction "}}}
function! s:Exec_cmd(clist, ...) "{{{
    let l:cmd = join(a:clist," ")
    if g:edit_slack_debug
        let l:cmd_debug = substitute(l:cmd, '\v--token \S+', '--token xxxxx', '')
        echomsg "s:Exec_cmd = " . l:cmd_debug
    endif
    if a:0 > 0
        call system(l:cmd, a:1)
    else
        call system(l:cmd)
    endif
    if v:shell_error
        throw "command error: " . l:cmd_debug
    endif
endfunction "}}}
