syntax match ThreadUri /\C\v^slack:\/\/ch\/([^\S/]+)\/([0-9\.]+) / conceal
setlocal concealcursor=nvic
setlocal conceallevel=3
let b:current_syntax = "slack"
