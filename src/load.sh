#! /bin/bash
# loading library facilities

# load a file
# @param string $1 path of the file to load
loadFile()
{
    if [ ! -e "$1" ]; then
        echo "Failed to load $1, abort" >&2
        exit 1
    fi

    . "$1"
}

# load one or many files
# @param string $1 file name or a path using the star wildcard to load all files
load()
{
    local filename=${1##*/}
    local dir=${1%/*}
    
    if [ ! -e "${dir}" ]; then
        echo "Failed to load from ${dir}, abort" >&2
        exit 1
    fi

    for file in $1; do
        loadFile "${file}"
    done
}

# load one or many files from the shell-testlib/src directory
# just use relative path without extension
# @param string $1 file name or a path using the star wildcard to load all files
use()
{
    local srcdir="$(dirname $(readlink -f $BASH_SOURCE))"
    local file="${srcdir}/${1%.*}.sh"

    load "${file}"
}