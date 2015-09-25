#! /bin/bash
# Shell Test Library Boostraper
# provides all base necessary features to work with this library

me()
{
    echo "$(readlink -f $BASH_SOURCE)"
}

mydir()
{
    echo "$(dirname $(me))"
}

######################################
. "$(mydir)/src/load.sh"