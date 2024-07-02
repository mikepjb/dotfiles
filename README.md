# Configure

_A barebones, productive working environment._

## Getting Started

Either clone this repo and:
```
mkdir -p ~/.configu/nvim/init.lua
ln -sv $PWD/init.lua ~/.config/nvim/init.lua
```

Or, if you are in a working environment where this is difficult copy the
`init.lua` -> `~/.config/nvim/init.lua` directly.

Finally run `nvim +Dots +qall` or just run the `Dots` command when you open neovim.

## Tools Used

- neovim

[this readme is in progress]

## old readme below

A minimal, optimised configuration for working on Linux.

This runs without any vim plugins, and assumes a minimal set of tools namely:

- `vim` (anything 8+ but 9.1+ is preferred and quite easy to compile)
- `bash`
- `git`
- rust runtime e.g `rustc`/`rustup`/`cargo`
- javascript runtime e.g `npm`/`node`
- `sqlite3`
- `docker`? `postgres`?

## Getting Started


1. Download (or copy/paste the vimrc file):  
`wget -O ~/.vimrc https://raw.githubusercontent.com/mikepjb/configure/main/vimrc`
or
`git clone` and `ln -sfv`
2. `vim +Dots +qall` or just run the `Dots` command when you open vim.
3. `mkdir -p ~/.vim/pack/x/start && git clone --depth 1 https://github.com/dense-analysis/ale.git !$/ale`

## How to use

- `vim` for text editing
- `nohup ./a_script.sh &` for running a background process during development.
- Inside vim `:grep <search-term> <location/*>`

## Manual Steps

You will need to:
1. setup your name/email on git as this can change via work/home/different environments.
2. add rust tools:
```
rustup component add rust-src # include rust source code for jumping
```
3. add javascript tools
4. compile vim if your OS package manager doesn't include 9.1+:
```bash
# git clone/source the vim source code a cd into the directory
./configure --with-features=huge --prefix=$HOME/.local
make VMRUNTIMEDIR=$HOME/.local/share/vim/vim9
make install
```
8. Run these only if you are using Gnome:
```bash
# Set your npm registry if need be (e.g Artifactory/in protected environment)
npm config set registry <registry-url>
# Set caps lock as control on Gnome Wayland
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
# prefer dark/light mode as you like
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
# Remap Ctrl+Alt+Delete logout binding that is easy to press when switching spaces.
gsettings set org.gnome.settings-daemon.plugins.media-keys logout "['<Control><Alt><Shift>Delete']"
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

## Why?

_Some decisions may seem strange, some decisions are documented here_

### Not included

- `tmux` - I used to use tmux frequently with splits and windows and 'live
  inside' the multiplexer but actually this great power just grew the mess I
  could create, I would have multiple tabs for different strands of work
  because I didn't have to close down anything. Instead I find it better to be
  forced into a singular workflow running something like a local server + text
  editor at max with the ability to drop into bash for some quick interactive
  work.
- a color scheme - Do not bother modifying the colorscheme, most terminals
  support 256+/truecolor. This means that you can just use a basic black
  terminal with a theme in Vim without extra config.

## Useful Commands you might have forgotten

- `lsof -ti :8080` looks for processes listening on the given port.

## Reference / Minor Detail

- You shouldn't set your own `TERM` value, unless you are logging into a remote
  system where the local and remote machines have different terminal databases.
- Vim can use `COLORFGBG` or `t_BG` to determine whether background should be
  light or dark. This can be important as changing the background value
  retriggers loading the current theme and `default` calls `bg&` which will set
  background to light when left to it's own devices.
