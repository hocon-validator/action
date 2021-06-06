#!/bin/bash
set -e
file="$1"

if [ -n "$VERBOSE" ]; then
    printf "\nChecking Syntax of $file:"
fi

error_message=$(parse-hocon $file 2>&1 > /dev/null | sed -e 's/, file.*/)/g' | tr -d '\n')
if [ -z "$error_message" ]; then
    if [ -n "$VERBOSE" ]; then
        echo -ne "${success_symbol}"
    fi
    exit 0
fi
if [ -n "$VERBOSE" ]; then
    echo -ne "${failure_symbol}"
fi
echo -e "\nFile: $file\n$error_message"
failed_file=$(mktemp)
rm -f "$NO_PROBLEMS" 2> /dev/null
echo "$file" > "$failed_file"
mv "$failed_file" "$PROBLEM_FILES_DIR"
exit 0
