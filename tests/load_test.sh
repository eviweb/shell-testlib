#! /bin/bash
DIR=$(dirname $(readlink -f "$0"))
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