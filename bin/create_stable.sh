#!/usr/bin/env bash

set -e

main(){
    parse_args $@
    prepare_repo
    copy_stable
    copy_repo
    remove_files
    update_imports
}

show_help(){
    echo "
Syntax is: $0 [-ohv] stable_repo

Gets all stable code and puts it in a new repo.

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

    REPO_DST=$1
    git config alias.exec '!exec '
    local p=$( git exec pwd )
    REPO_SRC=${p#$GOPATH/src/}
}

prepare_repo(){
    if [ ! "$REPO_DST" ]; then
        show_help
    fi

    REPO_DST_PATH="$GOPATH/src/$REPO_DST"

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
    if [ ! -f directories ]; then
        echo "Didn't find file 'directories' - so I don't know what to do."
        exit 1
    fi

    mkdir -p "$REPO_DST_PATH"
    local reposrc=$( cd ..; pwd )
    for d in $( cat directories ); do
        echo "Adding directory '$d' to stable"
        local dir="$reposrc/$d"
        local repodir="$REPO_DST_PATH/$d"
        mkdir -p "$repodir"
        if [ -d "$dir" ]; then
            (
            cd $dir
            for f in $( git ls-files .); do
                if [ "$f" = "${f%/*}" ]; then
                    cp $f "$repodir"
                fi
            done
            )
        else
            echo "Directory '$dir' is not present - please update your directories-file. Aborting"
            exit 1
        fi
    done
}

copy_repo(){
    if [ -d overwrite ]; then
        cp -av overwrite/* "$REPO_DST_PATH"
    fi
}

remove_files(){
    if [ -f remove_files ]; then
        for f in $( cat remove_files ); do
            rm "$REPO_DST_PATH"/$f
        done
    fi
}

update_imports(){
	if ! which goimports 2>&1 > /dev/null; then
		go get golang.org/x/tools/cmd/goimports
	fi
    echo "updating imports from $REPO_SRC to $REPO_DST"
    find "$REPO_DST_PATH" -name "*go" -exec perl -pi -e "s:$REPO_SRC:$REPO_DST:" "{}" \;
    find "$REPO_DST_PATH" -name "*go" -exec goimports -w "{}" \;
}

main $@
