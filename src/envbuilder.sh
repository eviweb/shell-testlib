#! /bin/bash
# utilities to manage test environment
# provides some global variables:
#   - ENVBUILDER_TEMPDIR: base temp directory
#   - OLDHOME: backup of the $HOME variable before its alteration
#   - FSTDOUT: standard output file
#   - FSTDERR: standard error file

# create a new temp directory
newTestDir()
{
    ENVBUILDER_TEMPDIR=$(mktemp -d -t)
}

# remove the temp directory and all its content
removeTestDir()
{
    if [ -e "${ENVBUILDER_TEMPDIR}" ]; then
        rm -rf "${ENVBUILDER_TEMPDIR}"
    fi
    unset -v ENVBUILDER_TEMPDIR
}

# alter the $HOME variable with a given path
# @param string $1 new path
changeHomeDir()
{
    OLDHOME="${HOME}"
    HOME="$1"
}

# revert the $HOME value
revertHomeDir()
{
    HOME="${OLDHOME}"
}

# initialize output files
initOutputs()
{
    local devdir="${ENVBUILDER_TEMPDIR}/dev"

    FSTDERR="${devdir}/fstderr"
    FSTDOUT="${devdir}/fstdout"

    if [ ! -e "${devdir}" ]; then
        mkdir -p "${devdir}"
    fi

    echo > "${FSTDERR}"
    echo > "${FSTDOUT}"
}

# ensure sanity of the test environment
prepareTestEnvironment()
{
    find ${ENVBUILDER_TEMPDIR} ! -name '.' ! -name '..' -delete
    initOutputs
}