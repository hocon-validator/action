#!/bin/bash
set -e
export start_bold='\033[1m'
export end_bold='\033[00m'
export success_symbol=' \xE2\x9C\x94'
export failure_symbol=' \xE2\x9D\x8C'
log_error_list=()

PATH="$(
cd $(dirname $0)
npm ci >/dev/null 2>/dev/null
npm bin
):$PATH"

echo "::add-matcher::$GITHUB_ACTION_PATH/match-syntax.json"

if [ -z "$FILES" ] && [ ! -s "$LIST" ]; then
    echo "No files configured" >&2
    exit 1
fi

export NO_PROBLEMS=$(mktemp)
export PROBLEM_FILES_DIR=$(mktemp -d)

for file in $FILES; do
    $GITHUB_ACTION_PATH/check-file.sh "$file"
done

if [ -n "$LIST" ]; then
    cat $LIST | xargs -P 2 -0 -n1 $GITHUB_ACTION_PATH/check-file.sh
fi

if [ -e $NO_PROBLEMS ]; then
    if [ -n "$VERBOSE" ]; then
        printf "\n${start_bold}## No Syntax errors detected. ##${end_bold}\n"
    fi
    exit 0
fi
printf "\n\n${start_bold}## Syntax errors found in the following files ##${end_bold}\n\n"
find "$PROBLEM_FILES_DIR" -type f |xargs -P 2 cat
echo "If you believe there to be an error, note that this script expects files to be in HOCON format and utilizes hocon-parser."
exit 1
