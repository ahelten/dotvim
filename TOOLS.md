Software Development
====================

1. Find RPATH used by an executable:
   * `readelf -d <executable> | grep RPATH`
   * `objdump -x <executable> | grep RPATH`
2. Display all predefined GNU compiler macros:
   * Linux:    `gcc -dM -E - < /dev/null`
   * Windows:  `echo | ccppc -dM -E -`


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
