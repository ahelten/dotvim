Software Development
====================

1. Find RPATH used by an executable:
   * readelf -d <executable> | grep RPATH
   * objdump -x <executable> | grep RPATH


Networking
==========

1. Display network ports and associated processes:
   * Windows:  `netstat -a -b`
   * Linux:
     * Everything:            `netstat -pa` 
     * UDP only (numeric):    `netstat -punta` 
     * UDP+Multicast Groups:  `netstat -puntag` 
