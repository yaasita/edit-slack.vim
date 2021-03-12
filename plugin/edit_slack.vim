augroup EditSlack
  autocmd!
  autocmd BufReadCmd slack://* call edit_slack#Open(expand("<amatch>"))
  autocmd BufWriteCmd slack://* call edit_slack#Write(expand("<amatch>"))
augroup END
command! -nargs=0 EditSlackJoin call edit_slack#Join(bufname("%"))
command! -nargs=0 EditSlackLeave call edit_slack#Leave(bufname("%"))
command! -nargs=0 EditSlackOpenReplies call edit_slack#OpenReplies(getline("."))
command! -nargs=1 -complete=file EditSlackUploadFile call edit_slack#UploadFile(fnamemodify(<q-args>, ":p"), bufname("%"))
command! -nargs=1 -complete=file EditSlackDownloadFile call edit_slack#DownloadFile(getline("."), fnamemodify(<q-args>, ":p"))
command! -nargs=1 EditSlackSearch call edit_slack#Search(<q-args>)
