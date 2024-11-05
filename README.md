# Configure

_A barebones, productive working environment._

## Getting Started

Easy as:

1. Install Neovim

2. Download and run the config:
```bash
mkdir -p ~/.config/nvim
wget https://raw.githubusercontent.com/mikepjb/configure/refs/heads/main/init.lua
nvim +Dots +qall
```

3. Install the external dependencies (things like `ripgrep`) using the `./install` command. This
   will use your package manager (e.g brew for Mac OS, pacman for Arch) to get what you need.
   
### Extra housekeeping when setting up a new machine

1. Set caps lock as control.
2. Disable audible/visual bell.

### Development environment inside Docker.

This project also has a small docker image ready to go, again for working environments (e.g
ephemeral ones where your changes get reset).

```bash
docker pull hypalynx/box:latest # Get the latest version:
docker run --rm -it hypalynx/box /bin/bash # Try out the box with:
```

### Remove Servers

- just use regular vim
- set `export PAGER="less -S"` if you are going to be using `psql` to stop the results wrapping and
  making everything unreadable.
- this section should probably be placed in a link instead of having it's own section on this
  README.

## How to use these tools

While we can't list _everything_ you can do, it's worth pointing out a few highlights:

- Using (neo)vim to merge conflicts with `git mergetool`.
    - This is a great built-in diff resolution with 4 panes, the top 3 are local (your changes),
      base (the original commonality version between the conflicts) & remote (their changes). The
      bottom pane is where you manually resolve the conflicts yourself.
- ssh-agent
    - `sa` will kill all ssh-agents and create a new one, including your main key.
    - `sk` will kill the current ssh-agent
    - The reasoning here is that you will work in a single terminal most of the time and we don't
      want multiple ssh-agents to hang around, so at the start of a session you just type `sa`,
      enter your password once and do your work.
    - There is a default lifetime for keys of 8 hours, so if for some reason your computer is
      compromised the agent will expire around the end of a working day.

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

_Make each program do one thing well. To do a new job, build afresh rather than complicate old
programs by adding new "features"_ ~ Doug McIlroy documenting the Unix Philospohy.

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
- `emacs` - I have used Emacs quite a few times for a long while and even enjoy writing elisp!
  However it must be said that the size of this program brings about enough instability that stops
  be relying on it. I say this as someone who strives to use as few packages as possible to avoid
  conflicts, the standout problem for me last time was GTK conflicting with Emacs where the editor
  will shutdown if a display is lost to avoid an infinite loop. The practical result meant that
  creating new frames could not have their size defined normally and even if you use daemon mode,
  it wouldn't persist if your display server broke (happens very occasionally). At the end of the
  day (neo)vim is a really small tool that works in a large environment of micro tools, which not
  only produces more stable (less chance of stuff going wrong) but is easier to change
  versions/tools (e.g revert neovim version or even use regular vim as a backup) without affecting
  the rest of the system.

## Useful Commands you might have forgotten (and may only be available on Linux)

- `lsof -ti :8080` looks for processes listening on the given port.

## Reference / Minor Detail / Commentary

- You shouldn't set your own `TERM` value, unless you are logging into a remote
  system where the local and remote machines have different terminal databases.
- Vim can use `COLORFGBG` or `t_BG` to determine whether background should be
  light or dark. This can be important as changing the background value
  retriggers loading the current theme and `default` calls `bg&` which will set
  background to light when left to it's own devices.
- Arch Linux breaks in unexpected ways, despite me being a very long term user it does just keep
  happening. The latest break I've had with Gnome where after an update many of the gtk4/libadwaita
  apps (e.g Gnome Console + Gnome Settings) have a large black box around them, looking online it
  seems some other people have experienced this in other DEs with Gnome apps where their compositor
  was not working properly. This leads me to suspect that there's some kind of bug with my
  workstation graphics (AMD iGPU)
  - actually https://gitlab.gnome.org/GNOME/gtk/-/issues/6890 
  - this highlighted that I'm using amdvlk > vulkan-radeon (the open source driver)
  - Debian only provides RADV.. so this wouldn't be a problem?
