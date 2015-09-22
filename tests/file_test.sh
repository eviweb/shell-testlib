#! /bin/bash
DIR=$(dirname $(readlink -f "$0"))
MAINDIR=$(dirname "${DIR}")
ENVBUILDER="${MAINDIR}/src/envbuilder.sh"
FILE="${MAINDIR}/src/file.sh"

if [ ! -e "${ENVBUILDER}" ]; then
    echo "Fails to load ${ENVBUILDER}, abort"
    exit 1
fi


if [ ! -e "${FILE}" ]; then
    echo "Fails to load ${FILE}, abort"
    exit 1
fi

. "${ENVBUILDER}"
. "${FILE}"

################ Unit tests ################
testExistsOrDie()
{    
    local afile="${HOME}/afile"
    local expected_msg="'${afile}' does not exists, abort"
    touch "${afile}"

    assertTrue "a file exists ${afile}" "existsOrDie ${afile}"
    unlink "${afile}"
    assertFalse "should exit" "existsOrDie ${afile} >${FSTDOUT} 2>${FSTDERR}"
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