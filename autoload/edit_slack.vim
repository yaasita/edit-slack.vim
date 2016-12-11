" vim: set sw=4 et fdm=marker:
"
" edit-slack.vim - Open slack, like a file
"
" Version: 0.01
" Maintainer:	yaasita < https://github.com/yaasita/edit-slack.vim >
" Last Change:	2016/12/09.

let g:yaasita_slack_cache = tempname()
let s:yaasita_slack_go_path = expand('<sfile>:p:h:h') . "/edit-slack"
let g:yaasita_slack_debug = get(g:, 'yaasita_slack_debug', 0)

function! edit_slack#OpenCh(slack_url) "{{{
    let l:url = substitute(a:slack_url,"\/$","","")
    if g:yaasita_slack_debug
        echomsg "edit_slack#OpenCh = " . l:url
    endif
    if l:url ==# "slack://ch"
        let l:tmpfile = s:List('channels.list')
    elseif l:url ==# "slack://dm"
        let l:tmpfile = s:List('users.list')
    elseif l:url ==# "slack://pg"
        let l:tmpfile = s:List('groups.list')
    elseif match(l:url,'\v^slack\:\/\/ch') > -1
        let l:tmpfile = s:History('channels.history', l:url)
    elseif match(l:url,'\v^slack\:\/\/dm') > -1
        let l:tmpfile = s:History('users.history', l:url)
    elseif match(l:url,'\v^slack\:\/\/pg') > -1
        let l:tmpfile = s:History('groups.history', l:url)
    endif
    setlocal nomod
    exe "e "  . l:tmpfile
    exe "bw! ". l:url
    exe "f "  . l:url
    exe "bw! ". l:tmpfile
    if match(l:url,'\v^slack://../[a-zA-Z0-9\-_]+$') > -1
        call append(line('$'), "=== Message ===")
    endif
    redr!
    normal! G
    setlocal nomod
endfunction "}}}
function! edit_slack#WriteCh(slack_url) "{{{
    let l:url = substitute(a:slack_url,"\/$","","")
    call cursor(1,1)
    call search("^=== Message ===$","W")
    let l:postdata = getline(line(".")+1,"$")
    if match(l:url,'\v^slack\:\/\/ch') > -1
        call s:Post('channels.post', l:url, l:postdata)
    elseif match(l:url,'\v^slack\:\/\/dm') > -1
        call s:Post('users.post', l:url, l:postdata)
    elseif match(l:url,'\v^slack\:\/\/pg') > -1
        call s:Post('groups.post', l:url, l:postdata)
    endif
    call edit_slack#OpenCh(l:url)
endfunction "}}}
function! s:List(cmd) "{{{
    if g:yaasita_slack_debug
        echomsg "s:List = " . a:cmd
    endif
    let l:tmpfile = tempname()
    let l:cmd = [ s:yaasita_slack_go_path, 
                \ '-cache', g:yaasita_slack_cache,
                \ '-token', g:yaasita_slack_token,
                \ '-outfile', l:tmpfile,
                \ a:cmd ]
    call s:Exec_cmd(l:cmd)
    return l:tmpfile
endfunction "}}}
function! s:History(cmd, target_url) "{{{
    let l:target = matchstr(a:target_url,'\v[a-zA-Z0-9\-_\.]+$')
    let l:tmpfile = tempname()
    let l:cmd = [ s:yaasita_slack_go_path, 
                \ '-cache', g:yaasita_slack_cache,
                \ '-token', g:yaasita_slack_token,
                \ '-outfile', l:tmpfile,
                \ a:cmd, l:target ]
    call s:Exec_cmd(l:cmd)
    return l:tmpfile
endfunction "}}}
function! s:Post(cmd, target_url, postdata) "{{{
    let l:tmpfile = tempname()
    let l:target = matchstr(a:target_url,'\v[a-zA-Z0-9\-_\.]+$')
    let l:cmd = [ s:yaasita_slack_go_path, 
                \ '-cache', g:yaasita_slack_cache,
                \ '-token', g:yaasita_slack_token,
                \ '-outfile', l:tmpfile,
                \ a:cmd, l:target ]
    call s:Exec_cmd(l:cmd, a:postdata)
endfunction "}}}
function! s:Exec_cmd(clist, ...) "{{{
    let l:cmd = join(a:clist," ")
    if g:yaasita_slack_debug
        echomsg "s:Exec_cmd = " . l:cmd
    endif
    if a:0 > 0
        call system(l:cmd, a:1)
    else
        call system(l:cmd)
    endif
endfunction "}}}
