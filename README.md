# fbhto


> `fbhto` is a flexible Bash script to help you organize your files, such as: images, videos, docs and texts.
```
How it works
------------
```
> `fbhto` = From BlackHole To Organized.
```
fbhto uses Linux inotify events to implement what we will call a blackhole: it is a directory that will suck the files it receives, and moves them to another place, in a organized manner.
```
The idea is to have a place where we can move our new files, and then fbhto work as necessary to organize these files for us. It is strongly recommended to make some tests before starting your regular and serious use of fbhto.
```
Usage
-----
```
usage: fbhto.sh


all the options are in the configuration files inside
  /etc/fbhto/

```
The file /usr/share/doc/fbhto/INSTALL contains instructions on how to automatically call fbhto.sh by the init.
```

TODO
----

`fbhto` can be improved to incorporate these features, and maybe others you suggest:

* [ ] deduplicate the files processed by fbhto
* [ ] allow regular users have their own configuration files at ~/fbhto/ and interpret them
    * run another instance of fbhto to each user
    * monitor (using inotify as well) a signal from the user, asking for reading her/his conf files
    * protect the user instance against privilege scalation

Contributing
------------

Feel free to improve `fbhto`. Your pull-requests are welcome.

LICENSE
------

`fbhto` is licensed under GNU GPL 3.0
