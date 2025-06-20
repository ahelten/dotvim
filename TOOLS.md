Software Development
====================

1. Find RPATH used by an executable:
   * `readelf -d <executable> | grep RPATH`
   * `objdump -x <executable> | grep RPATH`

2. Compilers:
   * Display all predefined *GNU compiler* macros:

           # Linux:
         gcc -dM -E -x c - < /dev/null
         g++ -dM -E -x c++ - < /dev/null
           # Windows:
         echo | ccppc -dM -E -

   * Determine whether a GCC compiler uses signed or unsigned `char` (no lines displayed by
     `grep` means `signed char`):

         gcc -dM -E -x c /dev/null | grep CHAR_UNSIGNED

3. Clang Static Analyzer and updated Clang Compiler on RHEL 7.x
   * See "Clang Static Analyzer" section below

4. Build clang-tags (did not finish getting this to work):

         yum install boost boost-devel
         yum install llvm-toolset-7-clang-devel
         yum install jsoncpp-devel
         yum install libsqlite3x-devel
         yum install socat

         cmake -DLIBCLANG_ROOT=/opt/rh/llvm-toolset-7/root/usr ../src/

5. GDB
   * List functions:

         info functions <regex>

   * Handle/block a signal:

         handle <signal> nostop
         handle SIGKILL nostop
         handle SIGKILL         # Display settings for SIGKILL
         handle all             # Display settings for all signals

   * To apply a thread-level command to all threads (optionally disable pagination):
         set pagination off
         thread apply all <command>
          -- For example:
         thread apply all bt

6. Running a test/script/application repeatedly until an error occurs:

      # Count successful runs until failure:
      count=0; while (./test.sh) do count=$((count+1)); echo -e "\n\nSUCCESSFUL ITERATIONS: $count\n\n"; sleep 2; done 
      # Or count failed runs until success:
      count=0; while ! (./test.sh) do count=$((count+1)); echo -e "\n\nFAILED ITERATIONS: $count\n\n"; sleep 2; done 

7. Rsync:

      # Syncing only specific files (note trailing `/` in `amh_devel/weedbot/` path!):
      rsync -zarv --include="*/" --include="*.cpp" --include="*.h" --exclude="*" ubuntu@robot2:amh_devel/weedbot/ .

8. Git
   * Merge and ignore line endings and tab/space differences:

        git merge -s recursive -Xignore-space-at-eol
        # Or:
        git merge master -s recursive -X renormalize
        # With cherry-picking:
        git cherry-pick abcd123456 --strategy=recursive --strategy-option=renormalize

   * Specify a non-default SSH key (also see 'Setup on a shared system' below):

          # Add to local repo config:
        git config core.sshCommand "ssh -i ~/.ssh/amh_id_rsa"
          # Or on command line:
        git -c core.sshCommand="ssh -i ~/.ssh/amh_id_rsa" clone blah.git

   * Setup on a shared system with multiple github SSH keys:
     * Add a custom host entry in `.ssh/config`:

            Host amhgithub
            Hostname github.com
            IdentityFile /home/gfr/.ssh/id_rsa
            IdentitiesOnly yes

     * Clone using this custom hostname:

            git clone git@amhgithub:ahelten/dotvim.git

9. nm - inspect library symbols
    * Display symbols in a shared library:

            nm -gDC <lib.so>



Linux Tips and Tricks
=====================

1. Display all loaded libraries in a running process (this is better than `ldd` because it shows
   libraries dynamically loaded by other shared libraries):

        sudo lsof -P -T -p <pid>

2. Monitor IRQs (interrupts):

        # From https://unix.stackexchange.com/a/8702/604146:
        watch -n0.1 --no-title cat /proc/interrupts

        # From https://unix.stackexchange.com/a/331954/604146:
        # mpstat N M -I ?
        #   N is polling interval, in seconds
        #   M is number of times to report (leave it out for unlimited)
        #   ? can be ALL or a list of interrupts
        mpstat 1 -I ALL
        
        # From https://unix.stackexchange.com/a/331969/604146:
        # example (lots of options):
        dstat -tif 60

2. Sending UDP packets from the command line:
    * Capture data with `tcpdump` or Wireshark
    * Copy the UDP packet payload data text. On Wireshark right-click the packet of interest and
      select 'Copy ...as HEX Dump'
    * Paste HEX dump into a text file
    * Edit the HEX dump (text) file and remove all spaces and newlines
    * Convert the text file to binary:

        cat udp_payload.txt | xxd -r -p > udp_payload.bin

    * Send the binary file using `netcat`:

        cat udp_payload.bin | nc -u -w1 10.10.0.222 12345

    * Send using `bash`:

        cat udp_payload.bin >/dev/udp/10.10.0.222/12345

    * Send text using `netcat`:

        nc -uq0 10.10.0.222 8101 <<<hello?

    * Receive that text using `netcat`:

        nc -ul 8101

3. Use keychain to start ssh-agent for managing SSH keys:

    eval $(keychain --eval --agents ssh id_rsa)


Git Tips and Tricks
============


1. On Linux, merge a file that was committed with Windows line endings:
   * Set `core.autocrlf = input` in `~/.gitconfig`
   * Merge:  `git merge -X renormalize <branch>`

2. Commit without setting global or local user name and email:
```
git -c user.name='<name>' -c user.email='<email>' commit -m"Add git tip" ./TOOLS.md
```
3. Ignore Added and Deleted files in diff:
```
  # Upper case (M)odified indicates to only list modified files
git diff --diff-filter=M
  # -- OR use lower-case to indicate *ignore* (A)dded and (D)eleted files
git diff --diff-filter=ad
```

3. Remove a submodule (Git 2.8+):
```
git submodule deinit -f vendor/rainbow_csv
git rm -f vendor/rainbow_csv
git commit -m "Remove rainbow_csv submodule"
```


Hardware Troubleshooting
========================

1. Serial terminals:
```
  # Check settings:
sudo stty -a -F /dev/ttyS0
  # Dump RX data:
sudo od -v -tx1z /dev/ttyS0
```

Check clock rate of CPU
---

```
watch -n 1 vcgencmd measure_clock arm
lscpu
sudo inxi -C
sudo hwinfo --cpu
sudo auto-cpufreq --monitor
sudo dmidecode -t processor | grep "Speed"
cat /proc/cpuinfo | grep MHz
```


Raspberry Pi Tips & Tricks
==========================

Current Kernel Config
---------------------

Get the kernel config on an ARM-based linux distro, like Raspberry Pi OS:

```
sudo modprobe configs
zcat /proc/config.gz > .config
```

Build the Pi Kernel
-------------------

Below are snippets from the [official build
page](https://www.raspberrypi.com/documentation/computers/linux_kernel.html). Visit that web page
for more information, such as, how to build a 64-bit kernel or cross-compiling the kernel.

Set up the Pi 4 build environment:

    sudo apt install git bc bison flex libssl-dev make
    sudo apt install libncurses5-dev

Get the code:

    git clone --depth=1 https://github.com/raspberrypi/linux

Configure a 32-bit kernel (enable Peak CAN bus and PREEMPT features) for Pi 4:

    KERNEL=kernel7l
    make bcm2711_defconfig

Build the kernel:

    make -j4 zImage modules dtbs

Install the kernel and modules:

    sudo make modules_install
    sudo cp arch/arm/boot/dts/*.dtb /boot/
    sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
    sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/
    sudo cp arch/arm/boot/zImage /boot/$KERNEL.img



Platform Setup
==============

0. Generic

```
cd ~
git clone https://ahelten@github.com/ahelten/dotvim .vim
ln -s .vim/.vimrc
ln -s .vim/.screenrc
cp .vim/gitconfig .gitconfig

# Not using `--recursive` here to avoid full setup of some plugins, like clang_complete, that most
# likely will not be used on all platforms
cd .vim
git submodule update --init

# To install vim-plug plugins, start `vim` and run `:PlugInstall`. You will need something like
# `ssh-agent` (e.g. via `keychain`) if your SSH key has a passphrase (because `:PlugInstall` cannot
# or at least does not prompt for the passphrase so the plugin installation fails).
```

1. Raspian OS Buster

```
sudo apt update -y
sudo apt install build-essential git cmake exuberant-ctags vim-nox
```

3. Ubuntu 20.04 and 22.04: setup core dumps

When it is working correctly, core files can be found here:

```
/var/lib/apport/coredump/
```

Add a convenient env var to `.bashrc`:

```
echo "export CORES=/var/lib/apport/coredump/" >> ~/.bashrc

# Then use it like this:
ll $CORES
sudo gdb ./<appname> --core=$CORES/<filename>
```

If core files aren't being generated, edit `/etc/apport/crashdb.conf` and comment out this line by
inserting a `#` at the beginning of the line, like this:

```
#        'problem_types': ['Bug', 'Package'],
```

Double check that `core_pattern` is set to something like this (if it isn't, fix it to create a
local core file or fix it for `apport`:

```
$ cat /proc/sys/kernel/core_pattern
|/usr/share/apport/apport %p %s %c
```

Make sure the service is enabled and running:

```
sudo systemctl enable apport.service
sudo service apport start
sudo service apport status  # It may show up as "active (exited)", which appears to be normal




Package Managers
================

1. YUM
   * Find packages that will install the specified file (with optional wildcards):

         yum whatprovides '*/valgrind'

2. APT
   * Display the package that provided the specified file:

         dpkg -S /bin/ls

   * Search APT package management system (not just installed) for packages that provide a
     specified file:

         sudo apt-get install apt-file
         sudo apt-file update

         apt-file search accumulators.hpp

   * List files installed by a specified package:

            # When <package> is *NOT* installed (see above item for install/init of apt-file):
         apt-file list <package>
            # When <package> is installed:
         dpkg -L <package>
            # When <package> is a deb file:
         dpkg -c <package.deb>

   * List and search *installed* packages:

         apt list --installed | grep <package>

   * Search all *available* packages:

         apt search <package>

   * List files installed by a package

         dpkg -L <package>

   * Show information about the package

         apt-cache policy <package>

3. RPM
   * Find which package provides an *installed* file:

         rpm -qf /bin/ls


Using screen
============

1. Create a new named `screen` session (name is optional but more human-readable):

       screen -S MyName

2. Detach from a `screen` session (the one you are currently in):

       Ctrl-a d

3. List existing `screen` session:

       screen -ls

4. Reattach to a `screen` session (using a screen session listed above in step 3):

       screen -r -S MyName       # Reattach to a detached screen process.
       screen -d -S MyName       # Detach the elsewhere running screen.
       screen -dr -S MyName      # Detach the elsewhere running screen (and reattach here).
       screen -x -S MyName       # Attach to a not detached screen. (Multi display mode).
       screen -aAxR -S MyName    # Multi-mode with other settings
                                 # After connecting multi-mode use 'Ctrl-a F' to resize window

5. End a `screen` session (attach and then `exit` the shell):

       screen -d -S MyName       # Detach the elsewhere running screen.
       exit


Networking
==========

1. Display network ports and associated processes:
   * Windows:  `netstat -a -b`
   * Linux:
     * Everything:            `netstat -pa` 
     * UDP only (numeric):    `netstat -punta` 
     * UDP+Multicast Groups:  `netstat -puntag` 

2. Troubleshoot WiFi problems on Linux:
   * `ifconfig`
   * `cat /proc/net/wireless`
   * `ethtool -S wlan0`
   * `iwconfig wlan0`    (to install: `sudo apt-get install ethtool`)



Clang Static Analyzer
=====================

The [Clang Static Analyzer](https://clang-analyzer.llvm.org/) is part of the Clang project but it
does require a more modern version than provided with RHEL 7.4. Installing an updated version on
RHEL 7.4 is discussed in the next section followed by a description of running the analyzer.

The available checks are summarized [here](https://clang-analyzer.llvm.org/available_checks.html).
A script called [scan-build](https://clang-analyzer.llvm.org/scan-build.html) simplifies running the
analyzer on projects that support common build platforms, like `make` builds (which includes CMake
builds).


Installing Clang-Analyzer
-------------------------

Setup and install newer clang packages using RHEL Developer Toolset on RHEL 7.4:

* Follow instructions for [Getting Access to Red Hat Developer Toolset](https://access.redhat.com/documentation/en-us/red_hat_developer_toolset/7/html/user_guide/chap-red_hat_developer_toolset#sect-Red_Hat_Developer_Toolset-Subscribe)
* Follow instructions for [Installing Red Hat Developer Toolset](https://access.redhat.com/documentation/en-us/red_hat_developer_toolset/7/html/user_guide/chap-red_hat_developer_toolset#sect-Red_Hat_Developer_Toolset-Install)
* Actual steps will be something like the following (on RHEL 7.4):

      su -
      cd /etc/pki/rpm-gpg/
      wget -O RPM-GPG-KEY-redhat-devel https://www.redhat.com/security/data/a5787476.txt
      rpm --import RPM-GPG-KEY-redhat-devel
      subscription-manager list --available
      subscription-manager repos --list|grep rhscl     /* To find the correct repo */
      subscription-manager repos --list|grep devtools  /* To find the correct repo */
        /* Find qualifying subscription and grab pool id for attach command: */
      subscription-manager attach --pool=8a85f98b635f3e6d0163cb7ca3a3442c
      subscription-manager repos --enable rhel-7-workstation-optional-rpms \
            --enable rhel-workstation-rhscl-7-rpms --enable rhel-7-workstation-devtools-rpms
      yum install devtoolset-7 llvm-toolset-7
        /* Optional: */
      yum install llvm-toolset-7-clang-analyzer llvm-toolset-7-clang-tools-extra
      clang --version
      scl enable devtoolset-7 llvm-toolset-7 bash
      clang --version
      exit /* to exit the shell opened by above 'scl' command */

* Other useful installation info regarding clang-analyzer (scan-build) is provided in
  [this blog post](https://developers.redhat.com/blog/2018/07/07/yum-install-gcc7-clang/)


Using Clang-Analyzer
--------------------

Some notes before using the tool:

1. Compilation is slower, maybe 3x (not sure), because this tool analyzes the code as it compiles
2. Once the code is built with the `scan-build` compiler front-end, it must always be recompiled
   with this front-end (i.e. must use `scan-build make` and not just `make`)
3. Clang-analyzer suggests always using a "debug" build when doing an analysis

It is possible to overload various compile related environment variables, like `CC` and `CCC_CC`
(the analyzer's compiler front-end), but all of this ugliness is handled by the convenient
`scan-build` script that is packaged with the analyzer. Setup and building the code with the
analyzer is as simple as this:

    cd <toplevel>
    mkdir Debug
    cd Debug
    scan-build cmake ..
    scan-build make

When the build completes, it will point to the directory containing the analyzer report and should
also display a `scan-view` command that opens a browser with the reports.


Valgrind
========

[Valgrind](http://http://valgrind.org/) is an instrumentation framework for building dynamic
analysis tools. There are Valgrind tools that can automatically detect many memory management and
threading bugs, and profile your programs in detail. You can also use Valgrind to build new tools.

The Valgrind distribution currently includes six production-quality tools:

1. memory error detector
2. two thread error detectors
3. cache and branch-prediction profiler
4. call-graph generating cache
5. branch-prediction profiler
6. heap profiler.

It also includes three experimental tools:

1. stack/global array overrun detector
2. second heap profiler that examines how heap blocks are used
3. SimPoint basic block vector generator.


Installing Valgrind
-------------------

Valgrind is most likely already installed if your system is setup for development. If it isn't, the
package is called `valgrind` so would install with:

    sudo yum install valgrind


Using Valgrind
--------------

Some notes before using the tool:

1. Enable `-g` debug flag (use our Debug build)
2. Consider enabling `-fno-inline` to improve C++ function call chains
   * Our current Debug build does not use this option (i.e. it does not disable inline)
   * Valgrind provides the `--read-inline-info=yes` argument to read debug info that describes
     function inlining (use this when `-fno-inline` is not used in the build)

Running the tool:

1. Simply call `valgrind` and specify the executable to analyze:

       valgrind [valgrind-options] your-prog [your-prog-options]

2. An example for `IcsMgrService`:

       valgrind --tool=memcheck --log-file=valgrind.icsmgr.log \
            --leak-check=full -v --xtree-memory=full \
            /home/ahelten/amh_devel/ccs/Debug/services/icsmgr/appl/icsmgr/IcsMgrService \
            /home/ahelten/amh_devel/ccs/Debug/services/icsmgr/config/icsmgr/icsmgr.cfg \
            --hams-domain=11 --hams-partition=HAMS-service --heartbeat-rate=1 \
            --system-app-domain=11 --system-app-partition=SYSTEM-app  --vehicle-id=168001 \
            --payload-id=0 --log-level=LEVEL_INFO --dds-debug-level=DEBUG_ALL

3. View the output in the file specified in `--log-file` argument

4. Available Valgrind `--tool=<tool1>,<tool2>,<etc>` options:
   * memcheck - memory error detector (the default tool)
   * cachegrind - cache and branch-prediction profiler
   * callgrind - call-graph generating cache and branch-prediction profiler
   * helgrind - thread error detector
   * drd - thread error detector
   * massif - heap profiler
   * exp-sgcheck - experimental stack and global array overrun detector
   * exp-bbv - experimental basic block vector generation
   * exp-dhat - experimental dynamic heap analysis
   * none - enables Nulgrind, the minimal Valgrind tool
   * lackey - an example tool (good starting point for developing new tools)

5. See http://valgrind.org/docs/manual/manual-core.html for more information

