augroup Slack
  autocmd!
  autocmd BufReadCmd slack://* call edit_slack#OpenCh(expand("<amatch>"))
  autocmd BufWriteCmd slack://* call edit_slack#WriteCh(expand("<amatch>"))
augroup END
