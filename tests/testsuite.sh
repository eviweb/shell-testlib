#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$0"))
res=0
failures=0
declare -a failing_testfiles=()

for unittest in $(find ${TESTDIR} -type f \( -iname "*_test.sh" ! -path "*/fixtures/*" \)); do
    echo "************ Run unit test ************"
    echo "test file: $unittest"
    echo "***************************************"
    $unittest
    ret=$?
    if [[ $res -eq 0 ]] && [[ $ret -eq 0 ]]; then
        res=0
    else
        res=1
        failures=$(( failures + $ret ))
        if [[ $ret -ne 0 ]]; then
            failing_testfiles=( "${failing_testfiles[@]}" "$unittest" )
        fi
    fi
    echo "*************** Done... ***************"
    echo ""
done

if [[ $res -eq 0 ]]; then
    echo "Test Suite PASSED"
else
    message="
Test Suite FAILED (failures=${failures})
> Failing Test Files:
"
    files=$(echo -e "${failing_testfiles[@]}" | tr " " "\n")
    echo -e "${message}$files" >&2
fi
echo ""
exit $res
# version: 0.2.0
