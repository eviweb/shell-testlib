#! /bin/bash
# Shell Test Library Boostraper
# provides all base necessary features to work with this library

STL_Boot()
{
    local src="$(dirname $(readlink -f $BASH_SOURCE))/src"

    . ${src}/load.sh
}

######################################
STL_Boot