#!/usr/bin/env bash

set -e

gopath=`go env GOPATH`

# To avoid warnings from Perl
export LANG=C

main(){
    parse_args $@
    prepare_repo
    copy_stable
    copy_repo
    remove_files
    update_all_imports
    exec_script
}

show_help(){
    echo "
Syntax is: $0 [-ohv] stable_dir stable_repo

Reads stable_dir to know which directories it should copy to
stable_repo. The following files and directories in stable_dir
are use:

- directories - one directory per line that will be copied to stable_repo
- overwrite/ - a directory that will be copied to stable_repo
- remove_files - files to be removed from stable repo
- script - will be sourced after imports are rewritten with REPO_SRC_PATH
  and REPO_DST_PATH as arguments

After copying, overwriting and removing files, the path of the
current repo will be adjusted to the stable_repo path.

Flags:

    -h      help
    -v      verbose
    -o      overwrite
"
    exit 1
}

parse_args(){
    OPTIND=1
    overwrite=""
    verbose=0

    while getopts ":oh?v" opt; do
        case "$opt" in
        o)
            overwrite="yes"
            ;;
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=1
            ;;
        esac
    done

    shift $((OPTIND-1))

	STABLE_DIR=$1
	DIRECTORIES=$STABLE_DIR/directories
	OVERWRITE_DIR=$STABLE_DIR/overwrite
	REMOVE_FILES=$STABLE_DIR/remove_files
	SCRIPT=$STABLE_DIR/script

    REPO_DST=$2
    git config alias.exec '!exec '
    REPO_SRC_PATH=$( git exec pwd )
    REPO_SRC=${REPO_SRC_PATH#$gopath/src/}
}

prepare_repo(){
    if [ ! "$REPO_DST" ]; then
        show_help
    fi

    REPO_DST_PATH="$gopath/src/$REPO_DST"

    if [ -e "$REPO_DST_PATH" ]; then
        if [ "$overwrite" ]; then
            echo "Going to overwrite '$REPO_DST_PATH'"
            rm -rf "$REPO_DST_PATH"/*
        else
            echo "'$REPO_DST_PATH' exists - either delete it or use '-o'"
            exit 1
        fi
    fi
}

copy_stable(){
    if [ ! -f "$DIRECTORIES" ]; then
        echo "Didn't find file 'directories' - so I don't know what to do."
        exit 1
    fi

    mkdir -p "$REPO_DST_PATH"
    for d in $( cat "$DIRECTORIES" ); do
        echo "Adding directory '$d' to stable"
        local srcdir="$REPO_SRC_PATH/$d"
        local dstdir="$REPO_DST_PATH/$d"
        mkdir -p "$dstdir"
        if [ -d "$srcdir" ]; then
            # Copy only files that are stored in git. Unfortunately git
            # prints recursively all files when doing `git ls-files`, so
            # the output has to be filtered.
            (
                cd $srcdir
                for f in $( git ls-files . | grep -v "/"); do
                    cp $f "$dstdir"
                done
            )
        else
            echo "Directory '$srcdir' is not present - please update your directories-file. Aborting"
            exit 1
        fi
    done
}

copy_repo(){
    if [ -d "$OVERWRITE_DIR" ]; then
        cp -av $( find stable/overwrite -type f ) "$REPO_DST_PATH"
    fi
}

remove_files(){
    if [ -f "$REMOVE_FILES" ]; then
        echo "Removing files:"
        for f in $( cat "$REMOVE_FILES" ); do
            rm -v "$REPO_DST_PATH"/$f
        done
    fi
}

update_all_imports(){
    if ! which goimports 2>&1 > /dev/null; then
	go get golang.org/x/tools/cmd/goimports
    fi
    
    update_imports $REPO_SRC $REPO_DST

    # Additional, hacky, updates
    if [ "$REPO_SRC" = "github.com/dedis/onet" ]; then
	update_imports github.com/dedis/kyber gopkg.in/dedis/kyber.v2
    fi
    if [ "$REPO_SRC" = "github.com/dedis/cothority" ]; then
	update_imports github.com/dedis/kyber gopkg.in/dedis/kyber.v2
	update_imports github.com/dedis/onet gopkg.in/dedis/onet.v2
    fi
}

update_imports() {
    echo "updating imports from $1 to $2"
    find "$REPO_DST_PATH" -name "*.go" -exec perl -pi -e "s:$1:$2:" "{}" \;
    find "$REPO_DST_PATH" -name "*.go" -exec goimports -w "{}" \;
}

exec_script(){
	if [ -f "$SCRIPT" ]; then
		. $SCRIPT "$REPO_SRC_PATH" "$REPO_DST_PATH"
    fi
}

main $@
