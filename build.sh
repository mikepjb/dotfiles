#!/bin/bash
# This file is included to make it possible to compile neovim minimal
# dependencies. If you follow the instructions on the project, there is an
# assumption that you have an internet connection and in some cases, we don't
# have a direct line to the outside world.

set +e

echo 'Building new neovim'

# if you want to build neovim without direct internet access.. good luck!

# 1. download neovim
# 2. make sure branch is correct (v0.10?)
# 3. configure..

export nvim_src="$HOME/src/neovim"
export nvim_deps="$HOME/src/neovim-deps"

! command -v cmake && echo '!!!!!!!!!!!cmake is required'

if [[ ! -d $nvim_src ]]; then
    echo 'neovim not downloaded'
    echo '!!! download it'
    exit 1
fi

if [[ ! -d $nvim_deps ]]; then
    echo 'neovim deps not downloaded'
    echo '!!! download it'
    exit 1
fi

if [[ -d "$nvim_src/.deps/build" ]]; then
    rm -rf "$nvim_src/.deps/build"
fi


# N.B on RHEL, needed lua, lua-luv, lua-luv-devel installed
# still doesn't work! lol
# luarocks

# https://github.com/neovim/deps

cd $nvim_src

make distclean # wipe out old build files

mkdir -p "$nvim_src/.deps/build"
cp -r $nvim_deps/* "$nvim_src/.deps/build"

git checkout stable

export CMAKE_BUILD_TYPE=Release
export CMAKE_INSTALL_PREFIX="$HOME/.local"
export DEPS_CMAKE_FLAGS="-DUSE_EXISTING_SRC_DIR=ON -DUSE_BUNDLED_LUAROCKS=OFF -DUSE_BUNDLED_LUAJIT=OFF -DUSE_BUNDLED_LUV=OFF"
make && make install
