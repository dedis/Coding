#!/usr/bin/env bash
# Source: https://github.com/h12w/gosweep/blob/master/gosweep.sh

DIR_EXCLUDE="$@"
DIR_SOURCE="$(find . -maxdepth 10 -type f -not -path '*/vendor*' -name '*.go' | xargs -I {} dirname {} | sort | uniq)"

if [ "$TRAVIS_BUILD_DIR" ]; then
  cd $TRAVIS_BUILD_DIR
fi

# Run test coverage on each subdirectories and merge the coverage profile.
all_tests_passed=true

echo "mode: atomic" > profile.cov
tmp=$(mktemp)
for dir in $DIR_SOURCE; do
  if ! echo $DIR_EXCLUDE | grep -q $dir; then
    if ls $dir/*.go >/dev/null 2>&1; then
      if ! grep "// +build experimental" $dir/*.go > /dev/null; then
        DEBUG_TIME=true go test -v -short -race -covermode=atomic -coverprofile=$dir/profile.tmp $dir \
          > $tmp 2>&1
        if [ $? -ne "0" ]; then
          cat $tmp
          all_tests_passed=false
        else
          tail -n 1 $tmp
        fi
        if [ -f $dir/profile.tmp ]; then
          tail -n +2 $dir/profile.tmp >> profile.cov
          rm $dir/profile.tmp
        fi
      else
        echo -e "exp\t$dir"
      fi
    fi
  fi
done

if [ "$all_tests_passed" = true ]; then
  exit 0
else
  exit 1
fi
