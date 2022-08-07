# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# allows config pathing for gsimplecal
XDG_CONFIG_HOME=~/.config

#PATH="$HOME/.nodejs/bin:$PATH"
PATH="$PATH:$HOME/.dotfiles"
PATH="$HOME/tools/Qt/5.12.5/gcc_64/bin:$PATH"
PATH="$HOME/tools/Qt/Tools/QtCreator/bin:$PATH"
# PATH="$PATH:$HOME/.gem/ruby/2.4.0/bin"
# PATH="$PATH:$HOME/.gem/ruby/2.5.0/bin"

# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5

export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

export PATH="$HOME/.cargo/bin:$PATH"
