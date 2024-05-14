# Configure

A minimal, optimised configuration for working on Linux.

This runs without any vim plugins.

## Getting Started

Either:
1. git clone this repo and run `./configure` which will set everything up
2. just copy the vimrc across (useful in instances where you are working in a more secure environment).

vim is the main part, can we include the rest as vim functions e.g:
    - setting bash?
    - setting git aliases?
    - check tools? e.g node/rustc/sqlite3
    - check subtools e.g rust analyzer

## Components

- vim (a.k.a configured editor)
- git (requires? Some nice aliases e.g git ra)
- bash (requires minimal config)
- tmux!
- runtimes (e.g rustc/cargo via rustup & npm/node) ???
    `rustup component add rust-analyzer # lsp`

## Manual Steps

You will need to:
- setup your name/email on git as this can change via work/home/different environments.
- Run these only if you are using Gnome:
```bash
# Set caps lock as control on Gnome Wayland
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
# prefer dark/light mode as you like
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
```

## Philosophy a.k.a Why?

This selection of tools are chosen to keep the common case fast (text editing &
compiling software) whilst keeping anything extra to a minimum. This is
because, like a software system, the more lines of code or in this case the
more tools you have, the more bugs will occur and there is a limit before you
start spending more time fixing your tooling and less on building your current
target.

Extra consideration has been given to making sure this configuration is usable
in any environment (within reason), in the past I've built my own versions of
vim/neovim and installed lists of packages but sometimes neither of these
things are available to you (and they still cost time to maintain), ANY
environment can be like this if you lose access to the internet, whether by
design (travelling on a plane) or otherwise.

(old text)

Configuration script for setting up your Linux work environment.
Aimed at Debian but should also be able to setup the bare minimal install
elsewhere. Once you run this, the script should be available on your path
under `configure`, you can edit this with `viw configure` from anywhere.

There is also a `server` setup script for configuring (again primarily Debian)
Linux servers to be used for running applications with
nginx/https(certbot/cron)/sqlite. (note golang/rust is preferable for single
binary distribution)

Download (or copy/paste the single file):  
`wget -O ~/.local/bin/configure https://raw.githubusercontent.com/mikepjb/configure/main/configure`

## Running in restricted environments

The neovim script is designed to adapt to restricted environments where plugin repos are only available via internal mirrors, you can control this with environment variables like so:

```
PLUGIN_URL_MIDDLE="/" \
PLUGIN_URL_BASE="https://example-internal-repo.com/api/github" \
PLUGIN_EXT="tar.gz" \
./configure
```

## Color Scheme

_No script used for this, it's usually a one time setting change and each terminal stores this information quite differently._

### Hex
```
foreground:     #ffffff
background:     #2c2c2c
cursorColor:    #ffffff
black:          #444444
bright-black:   #5e5e5e
red:            #ffb2b2
bright-red:     #ff8c8c
green:          #cbffb2
bright-green:   #8bff95
yellow:         #ffdfb2
bright-yellow:  #ffd08d
blue:           #b3ccff
bright-blue:    #4fa7ff
magenta:        #ffb3ff
bright-magenta: #ff8dff
cyan:           #b2fff5
bright-cyan:    #8dfff0
white:          #cdcdcd
bright-white:   #e5e5e5
```

### RGB
```
foreground:     255,255,255
background:     44,44,44
cursorColor:    255,255,255
black:          68,68,68
bright-black:   94,94,94
red:            255,178,178
bright-red:     255,140,140
green:          203,255,178
bright-green:   139,255,149
yellow:         255,223,178
bright-yellow:  255,208,141
blue:           179,204,255
bright-blue:    79,167,255
magenta:        255,179,255
bright-magenta: 255,141,255
cyan:           178,255,245
bright-cyan:    141,255,240
white:          205,205,205
bright-white:   229,229,229
```

## Why?

_Some decisions may seem strange, some decisions are documented here_

### Tmux C-q, unergonomic bindings & hidden status

I used to have the tmux prefix bound to M-; with additional M-o+M-O bindings to
quickly and comfortably move between panes and buffers. However I am trying to
prevent myself doing that so easily. The reason for this is that I believe
focusing on a single window leads to more streamlined development. If you find
yourself opening multiple windows, especially one to look through long logs
(perhaps from the entire output of your test suite/running server) then you are
patching up a bad process.

## Useful Commands you might have forgotten


- `lsof -ti :8080` looks for processes listening on the given port.
