FortressOne Server
==================

Forked from the 1996 Team Fortress Mod, it served as the basis for the fo-progs. It's the source for FortressOne in a way.


Development
------

Compile
------
Compile with [FTEQCC](http://fte.triptohell.info/downloads)

Ensure that `fteqcc64` is available in `$PATH` and:

```
make
```

Generate ctags
------
```
./generate_ctags.sh
```

Note: I got an error in vim:
```
E431: Format error in tags file "tags"
Before byte 364464
```
I just removed the one line at that byte address and it works fine now.

Note: Fixed in fteqcc 6010


List assets
-----

Only works in ssqc

```
fteqcc64 ./ssqc/progs.src -fdumpfilenames
```
