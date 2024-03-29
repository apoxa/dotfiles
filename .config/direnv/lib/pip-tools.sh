#!/bin/bash
function use_pip-tools() {
    requirements_file=${1:?"a requirements file must be provided as the first argument"}
    shift
    local has_pip=0
    if has pip; then
        if [[ $(which pip) = $PWD/* ]]; then
            has_pip=1
        fi
    fi
    if [ $has_pip -eq 0 ]; then
        echo "[use pip-tools] No pip installed via layout; try layout pyenv or layout python"
        return 1
    fi

    if ! test -f $requirements_file; then
        echo "[use pip-tools] No requirements file $requirements_file"
        return 1
    fi

    if ! has pip-compile; then
        echo "[use pip-tools] pip-tools missing; installing"
        pip install pip-tools
    fi

    requirements_txt=$(echo "$requirements_file" | cut -f 1 -d '.').txt
    if [ $requirements_file -nt $requirements_txt ]; then
        echo "[use pip-tools] resyncing requirements"
        pip-compile "$@" $requirements_file
        pip-sync $requirements_txt
    fi

    watch_file $requirements_file
}
