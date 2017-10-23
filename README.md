# fbhto

> `fbhto` is a flexible Bash script to help you organize your files, such as:
> images, videos, docs and texts.


## How it works

*fbhto* = From BlackHole To Organized.

fbhto uses Linux inotify events to implement what we will call a blackhole: it
is a directory that will suck the files it receives, and moves them to another
place, in a organized manner.

The idea is to have a place where we can move our new files, and then fbhto do 
whatever is necessary to organize these files for us.

*It is strongly recommended that you make some tests and carefully observe the
results BEFORE YOU START your regular and serious use of fbhto.*


## Usage

usage: fbhto.sh

all options are in the configuration files inside /etc/fbhto/ directory.

The file /usr/share/doc/fbhto/INSTALL will contain the instructions on how to
automatically call fbhto.sh by the init (at least for the systemd init).


## TODO

*fbhto* is expected to be improved to incorporate those new features, and
maybe others you suggest:

* [ ] deduplicate the files moved to the blackhole
* [ ] allow regular users have their own configuration files at ~/fbhto/ and
interpret them
    * run another instance of fbhto for each user
    * monitor (using inotify as well) a signal from the user, asking for
reading and interpreting her/his conf files
    * protect the user instance against privilege scalation


## Contributing

Feel free to improve *fbhto*. Your pull-requests are welcome.

## LICENSE

*fbhto* is licensed under [GNU GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.txt)
