#! /bin/bash

################ Utilities #################
# get the full name of this script
me()
{
    echo "$(readlink -f $BASH_SOURCE)"
}

# get the path of parent directory of this script
mydir()
{
    echo "$(dirname $(me))"
}

# get the path of the project main directory
maindir()
{
    local curdir="$(mydir)"

    while \
        [ ! -e "${curdir}/lib" ] && \
        [ ! -e "${curdir}/src" ] && \
        [ ! -e "${curdir}/tests" ] && \
        [ "${curdir}" != "/" ]; do

        curdir="$(dirname ${curdir})"
    done

    echo "${curdir}"
}

# get the path of the source directory
srcdir()
{
    echo "$(maindir)/src"
}

# get the path of the test directory
qatestdir()
{
    echo "$(maindir)/tests"
}

# get the path of the main lib directory
libdir()
{
    echo "$(maindir)/lib"
}

############## End Utilities ###############
DIR="$(mydir)"
MAINDIR=$(dirname "${DIR}")
ENVBUILDER="${MAINDIR}/src/envbuilder.sh"
COMMAND="${MAINDIR}/src/command.sh"

if [ ! -e "${ENVBUILDER}" ]; then
    echo "Fails to load ${ENVBUILDER}, abort"
    exit 1
fi

if [ ! -e "${COMMAND}" ]; then
    echo "Fails to load ${COMMAND}, abort"
    exit 1
fi

. "${ENVBUILDER}"
. "${COMMAND}"
################ Unit tests ################

testRunCmd()
{
    local afile="${HOME}/afile"

    touch "${afile}"
    result="$(runCmd ls ${afile})"
    assertSame "command result should be the file fullname" "${afile}" "${result}"
}

testRunCmdShouldDieIfCommandDoesNotExist()
{
    local cmd="nonexistingcommand"
    local expected_msg="Command not found '${cmd}', abort"
    
    assertFalse "should exit" "runCmd ${cmd} >${FSTDOUT} 2>${FSTDERR}"
    assertNull "no message to FSTDOUT" "$(cat ${FSTDOUT})"
    assertSame "expected FSTDERR message" "${expected_msg}" "$(cat ${FSTDERR})"
}

###### Setup / Teardown #####
oneTimeSetUp()
{
    newTestDir
    changeHomeDir "${ENVBUILDER_TEMPDIR}"
}

oneTimeTearDown()
{
    removeTestDir
    revertHomeDir
}

setUp()
{    
    OLDPWD="$PWD"
    prepareTestEnvironment
}

tearDown()
{
    cd "$OLDPWD"
}

################ RUN shunit2 ################
findShunit2()
{
    local curdir=$(dirname $(readlink -f "$1"))
    while [ ! -e "${curdir}/lib/shunit2" ] && [ "${curdir}" != "/" ]; do
        curdir=$(dirname ${curdir})
    done

    if [ "${curdir}" == "/" ]; then
        echo "Error Shunit2 not found !" >&2
        exit 1
    fi

    echo "${curdir}/lib/shunit2"
}

exitOnError()
{
    echo "$2" >&2
    exit $1
}
#
path=$(findShunit2 "$BASH_SOURCE")
code=$?
if [ ${code} -ne 0 ]; then
    exitOnError ${code} "${path}"
fi
. "${path}"/source/2.1/src/shunit2
#
# version: 0.2.0
