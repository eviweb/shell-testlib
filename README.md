Shell Testlib
=============
this library aims to provide some facilities to write shell unit tests.    

##### Health status
[![Travis CI - Build Status](https://travis-ci.org/eviweb/shell-testlib.svg)](https://travis-ci.org/eviweb/shell-testlib)
[![Github - Last tag](https://img.shields.io/github/tag/eviweb/shell-testlib.svg)](https://github.com/eviweb/shell-testlib/tags)

Installation
------------
from within your project directory, run:    
`git submodule add --name shell-testlib https://github.com/eviweb/shell-testlib lib/shell-testlib`   

Usage
-----
source the boostrap file from `./lib/shell-testlib/bootstrap.sh`, then use the loading utilities.    
_ie. from the root of your project it could be something like this:_    
```bash
#! /bin/bash
. "$(dirname $(readlink -f $BASH_SOURCE))/lib/shell-testlib/bootstrap.sh"

use "*" # this will load all the provided libraries

#### Do your stuff ####
```

Libraries
---------
this package currently includes:
* **command:** utilities to deal with external commands
* **envbuilder:** utilities to manage your test environment _(ie. create temp directories, change `$HOME`, clean test directories...)_
* **file:** utilities to deal with files and directories
* **load:** loading facilities

### Loading considerations

the `load` library gives you the choice to:
#### load one unique file
```bash
loadFile "/path/to/my/file"
### OR ###
load "/path/to/my/file"
```
#### load many files
by using some filtering patterns
```bash
load "/path/to/some/files/*-suffix.ext"
```
#### use a provided library
please note that:
* path are relative from the `./lib/shell-testlib/src` directory
* no need to specify the file extension.
```bash
use "file" # to load the file library
### OR ###
use "*" # to load all libraries
```

> by loading a file we mean **source** it.    
> this way the running shell environment is kept.

A shell development stack
-------------------------
this project suits very well with the [shunit2-support](https://github.com/eviweb/shunit2-support) project, which should greatly help you to deal with creating unit tests for your shell projects.

License
-------
this project is licensed under the terms of the [MIT License](/LICENSE)