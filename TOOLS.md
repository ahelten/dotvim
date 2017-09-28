Executables and Libraries
=========================

1. Find RPATH used by an executable:
   * readelf -d <executable> | grep RPATH
   * objdump -x <executable> | grep RPATH
