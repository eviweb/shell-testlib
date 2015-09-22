#! /bin/bash
# utilities to deal with files and directories

# check if a file or directory exists, exit if not
# @param string $1 path of the subject to check
existsOrDie()
{    
    if [ ! -e "$1" ]; then
        echo "'$1' does not exists, abort" >&2
        exit 1
    fi

    return 0
}