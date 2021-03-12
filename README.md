# edit-slack.vim

open slack, like a file

![demogif](https://i.imgur.com/zYs4XdX.gif)

## installation

### 1. download vim script

*  [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'yaasita/edit-slack.vim'`
*  [Vundle](https://github.com/gmarik/vundle)
  * `Plugin 'yaasita/edit-slack.vim'`
*  [Vim packages](http://vimhelp.appspot.com/repeat.txt.html#packages) (since Vim 7.4.1528)
  * `git clone https://github.com/yaasita/edit-slack.vim ~/.vim/pack/plugins/start/edit-slack.vim`

### 2. download [edit-slack](https://github.com/yaasita/edit-slack) binary

* [Linux 64bit](https://github.com/yaasita/edit-slack/releases/download/v1.0.1/linux-amd64-edit-slack)
* [Windows 64bit](https://github.com/yaasita/edit-slack/releases/download/v1.0.1/windows-amd64-edit-slack.exe)
* [macOS intel64bit](https://github.com/yaasita/edit-slack/releases/download/v1.0.1/darwin-amd64-edit-slack)

save binary to edit-slack.vim directory, and rename to edit-slack (on windows, rename to edit-slack.exe)

example: linux user

    cd /path/to/install/directory/edit-slack.vim
    curl -L -O https://github.com/yaasita/edit-slack/releases/download/v1.0.1/linux-amd64-edit-slack
    mv linux-amd64-edit-slack edit-slack
    chmod +x edit-slack

### 3. settings

get token from [slack app page](https://api.slack.com/apps).

[youtube](https://www.youtube.com/watch?v=z9PD7-UXSbA)

require scope

* identify
* channels:history
* groups:history
* im:history
* mpim:history
* channels:read
* files:read
* groups:read
* im:read
* mpim:read
* search:read
* users:read
* channels:write
* chat:write
* files:write
* groups:write

add the token to vimrc

    syntax on
    let g:edit_slack_token = "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx"

if display unicode characters

    set fileencodings+=utf-8
    set encoding=utf-8

## usage

    # open channels list
    vim slack://ch
    # gf command opens a chat under the cursor

    # post
    # write it under the "=== Message ===" mark
    :w

    # command
    # join channel
    :EditSlackJoin
    # leave channel
    :EditSlackLeave
    # open thread
    :EditSlackOpenReplies
    # upload file
    :EditSlackUploadFile /path/to/upfile
    # download file
    :EditSlackDownloadFile /path/to/savefile
    # search word
    :EditSlackSearch keyword

## more information

https://github.com/yaasita/edit-slack.vim/wiki
