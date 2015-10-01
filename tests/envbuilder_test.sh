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

if [ ! -e "${ENVBUILDER}" ]; then
    echo "Fails to load ${ENVBUILDER}, abort"
    exit 1
fi

. "${ENVBUILDER}"

################ Unit tests ################
testNewTestDir()
{
    assertNull "ENVBUILDER_TEMPDIR should not be initialized" "${ENVBUILDER_TEMPDIR}"
    newTestDir
    assertTrue "ENVBUILDER_TEMPDIR should be initialized with the path of the temp directory" "[ -d ${ENVBUILDER_TEMPDIR} ]"
    rmdir "${ENVBUILDER_TEMPDIR}"
    unset -v ENVBUILDER_TEMPDIR
}

testRemoveTestDir()
{
    newTestDir
    touch "${ENVBUILDER_TEMPDIR}/afile"
    dirtemp="${ENVBUILDER_TEMPDIR}"
    removeTestDir
    assertFalse "the temp directory is removed" "[ -e ${dirtemp} ]"
    assertNull "ENVBUILDER_TEMPDIR is cleared" "${ENVBUILDER_TEMPDIR}"
}

testChangeHomeDir()
{
    local current="${HOME}"
    local newvalue="/a/new/home/dir"

    changeHomeDir "${newvalue}"
    assertEquals "OLDHOME should be initialized with the previous HOME value" "${current}" "${OLDHOME}"
    assertEquals "HOME value has changed" "${newvalue}" "${HOME}"
    HOME="${current}"
}

testRevertHomeDir()
{
    local current="${HOME}"
    local newvalue="/a/new/home/dir"

    changeHomeDir "${newvalue}"
    revertHomeDir
    assertEquals "HOME value has been successfully reset" "${current}" "${HOME}"
}

testInitOutputs()
{
    local out="dev/fstdout"
    local err="dev/fstderr"

    newTestDir
    initOutputs
    assertTrue "${out} file exists" "[ -f ${ENVBUILDER_TEMPDIR}/${out} ]"
    assertTrue "${err} file exists" "[ -f ${ENVBUILDER_TEMPDIR}/${err} ]"
    assertNull "${out} should be empty" "$(cat ${ENVBUILDER_TEMPDIR}/${out})"
    assertNull "${err} should be empty" "$(cat ${ENVBUILDER_TEMPDIR}/${err})"
    assertEquals "FSTDOUT should be initialized with correct path" "${ENVBUILDER_TEMPDIR}/${out}" "${FSTDOUT}"
    assertEquals "FSTDERR should be initialized with correct path" "${ENVBUILDER_TEMPDIR}/${err}" "${FSTDERR}"
    removeTestDir
}

testPrepareEnvironmentRemoveAllTestDirContent()
{
    local path="sub/path"
    local file="file"

    newTestDir
    mkdir -p "${ENVBUILDER_TEMPDIR}/${path}"
    touch "${ENVBUILDER_TEMPDIR}/${file}"
    prepareTestEnvironment

    assertFalse "all content has been removed" "[ -e ${ENVBUILDER_TEMPDIR}/${path} ] && [ -e ${ENVBUILDER_TEMPDIR}/${file} ]"
    removeTestDir
}

testPrepareEnvironment()
{
    newTestDir
    prepareTestEnvironment

    assertTrue "FSTDOUT file exists" "[ -f ${FSTDOUT} ]"
    assertTrue "FSTDERR file exists" "[ -f ${FSTDERR} ]"
    removeTestDir
}

# fix issue #1
testPrepareEnvironmentShouldRemoveHiddenFiles()
{
    newTestDir
    local hiddenfile="${ENVBUILDER_TEMPDIR}/.hiddenfile"    
    touch "${hiddenfile}"
    prepareTestEnvironment

    assertFalse "the hiddenfile has been removed" "[ -e ${hiddenfile} ]"
    removeTestDir
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
