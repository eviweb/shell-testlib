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
LOAD="${MAINDIR}/src/load.sh"

if [ ! -e "${ENVBUILDER}" ]; then
    echo "Fails to load ${ENVBUILDER}, abort"
    exit 1
fi


if [ ! -e "${LOAD}" ]; then
    echo "Fails to load ${LOAD}, abort"
    exit 1
fi

. "${ENVBUILDER}"
. "${LOAD}"

################ Unit tests ################
testLoadFile()
{
    assertNull "simpleTrue function does not exist" "$(type -t simpleTrue)"
    loadFile "${DIR}/fixtures/simplelib.sh"
    assertEquals "simpleTrue function is loaded" "function" "$(type -t simpleTrue)"
    unset simpleTrue
}

testLoadFileShouldDieIfFileDoesNotExist()
{
    local undeffile="${DIR}/fixtures/undefined"
    local expected_msg="Failed to load ${undeffile}, abort"
    
    assertFalse "should exit" "loadFile ${undeffile} >${FSTDOUT} 2>${FSTDERR}"
    assertNull "no message to FSTDOUT" "$(cat ${FSTDOUT})"
    assertSame "expected FSTDERR message" "${expected_msg}" "$(cat ${FSTDERR})"
}

testLoadFilesUsingAllPattern()
{
    local pattern="${DIR}/fixtures/*"
    load "${pattern}"
    assertEquals "simpleTrue function is loaded" "function" "$(type -t simpleTrue)"
    assertEquals "anotherTrue function is loaded" "function" "$(type -t anotherTrue)"
    unset simpleTrue
    unset anotherTrue
}

testLoadFilesUsingAFilteringPattern()
{
    local pattern="${DIR}/fixtures/an*lib.sh"
    load "${pattern}"
    assertNull "simpleTrue function should not be loaded" "$(type -t simpleTrue)"
    assertEquals "anotherTrue function is loaded" "function" "$(type -t anotherTrue)"
    unset anotherTrue
}

testLoadUniqueFile()
{
    load "${DIR}/fixtures/anotherlib.sh"
    assertNull "simpleTrue function should not be loaded" "$(type -t simpleTrue)"
    assertEquals "anotherTrue function is loaded" "function" "$(type -t anotherTrue)"
    unset anotherTrue
}

testLoadWithWrongPathShouldDie()
{
    local pattern="${DIR}/undefined/*"
    local expected_msg="Failed to load from ${DIR}/undefined, abort"
    
    assertFalse "should exit" "load ${pattern} >${FSTDOUT} 2>${FSTDERR}"
    assertNull "no message to FSTDOUT" "$(cat ${FSTDOUT})"
    assertSame "expected FSTDERR message" "${expected_msg}" "$(cat ${FSTDERR})"
}

testUseShouldLoadOneFileFromSrcDirectory()
{
    assertNull "existsOrDie function should not be loaded" "$(type -t existsOrDie)"
    use "file"
    assertEquals "existsOrDie function is loaded" "function" "$(type -t existsOrDie)"
    unset existsOrDie
}

testUseShouldLoadManyFilesFromSrcDirectoryUsingAllPattern()
{
    unset prepareTestEnvironment
    assertNull "prepareTestEnvironment function should not be loaded" "$(type -t prepareTestEnvironment)"
    assertNull "existsOrDie function should not be loaded" "$(type -t existsOrDie)"
    use "*"
    assertEquals "prepareTestEnvironment function is loaded" "function" "$(type -t prepareTestEnvironment)"
    assertEquals "anotherTrue function is loaded" "function" "$(type -t existsOrDie)"
    unset existsOrDie
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
path=$(findShunit2 "$0")
code=$?
if [ ${code} -ne 0 ]; then
    exitOnError ${code} "${path}"
fi
. "${path}"/source/2.1/src/shunit2
#

# version: 0.2.0
