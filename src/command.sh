#! /bin/bash
# utilities to deal with external commands

# run a given command
# @param string $1 the command name
# @param string $@ the command options if needed
runCmd()
{
    local cmd="$1"
    local fullcmd="$(which ${cmd})"
    shift

    if [ -z "${fullcmd}" ]; then
        echo "Command not found '${cmd}', abort" >&2
        exit 1
    fi

    ${fullcmd} $@
}