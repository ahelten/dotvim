Custom setup/install/config for different distros/platforms (not strictly vim related setup):

Ubuntu 16.04 Desktop
====================

* Install sshd:
  - sudo apt install openssh-server
* Install vim, ctags, clang, git:
  - sudo apt install vim
  - sudo apt install ctags
  - sudo apt install clang
  - sudo apt install git
* Add python2 support to vim (needed by clang_complete):
  - sudo apt install vim-nox-py2
* Create a libclang.so link that clang_complete can find:
  - cd /usr/lib/x86_64-linux-gnu
    sudo ln -s libclang-3.8.so.1 libclang.so


Debian
======

* Add python2 support to vim (needed by clang_complete):
  - sudo apt install vim-nox
