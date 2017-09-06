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

    REPO_DSTPATH="$GOPATH/src/$REPO_DST"

    if [ -e "$REPO_DSTPATH" ]; then
        if [ "$overwrite" ]; then
            echo "Going to overwrite '$REPO_DSTPATH'"
            rm -rf "$REPO_DSTPATH"/*
        else
            echo "'$REPO_DSTPATH' exists - either delete it or use '-o'"
            exit 1
        fi
    fi
}

copy_stable(){
    if [ ! -f directories ]; then
        echo "Didn't find file 'directories' - so I don't know what to do."
        exit 1
    fi

    mkdir -p "$REPO_DSTPATH"
    local reposrc=$( cd ..; pwd )
    for d in $( cat directories ); do
        echo "Adding directory '$d' to stable"
        local dir="$reposrc/$d"
        local repodir="$REPO_DSTPATH/$d"
        mkdir -p "$repodir"
        if [ -d "$dir" ]; then
            find "$dir" -maxdepth 1 -type f | xargs -I {} cp {} "$repodir"
        else
            echo "Directory '$dir' is not present - please update your directories-file. Aborting"
            exit 1
        fi
    done
}

copy_repo(){
    if [ -d overwrite ]; then
        cp -av overwrite/* "$REPO_DSTPATH"
    fi
}

remove_files(){
    if [ -f remove_files ]; then
        for f in $( cat remove_files ); do
            rm "$REPO_DSTPATH"/$f
        done
    fi
}

update_imports(){
    echo "updating imports from $REPO_SRC to $REPO_DST"
    find "$REPO_DSTPATH" -name "*go" -exec perl -pi -e "s:$REPO_SRC:$REPO_DST:" "{}" \;
    find "$REPO_DSTPATH" -name "*go" -exec goimports -w "{}" \;
}

main $@
