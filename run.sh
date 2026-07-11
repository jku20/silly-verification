#!/bin/bash

# Put the names of the test .sv files here.
tests=""

# Put any verilator flags here, for example -Ipath/to/src/file/dir or -Ipath/to/test/file/dir
# Remember that this should include a -Ipath/to/test/bench/library/dir
verilator_flags=""

test() {
  printf "\033[32mRunning $1\033[39m\n"
  res=$(verilator --binary -j 0 $verilator_flags $2.sv)
  if [ $? -eq "0" ]; then
    test_out=$(./obj_dir/V$2 | head -n -4)
    echo "$test_out"
    if [[ $test_out == *"FAILED"* ]]; then
      return 1
    else
      return 0
    fi
  else
    echo $res
    return 1
  fi
}

ret=0

if [[ -z $1 ]]; then
  for t in $tests; do
    test $t $t
    if [[ $? -eq 1 ]]; then
      ret=1
    fi
    echo ""
  done
else
  test $1 $1
  ret=$?
fi

exit $ret
