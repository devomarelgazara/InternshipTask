#!/bin/bash


usage() {
    echo "Usage: $0 [-n] [-v] search_string file"
    echo "Options:"
    echo "  -n    Print line numbers with matching lines"
    echo "  -v    Invert match (print non-matching lines)"
    echo "  --help Display this help message"
    exit 1
}

if [[ "$1" == "--help" ]]; then
    usage
fi

show_line_numbers=0
invert_match=0
search_string=""
file=""

# معالجة الخيارات باستخدام getopts
while getopts "nv" opt; do
    case $opt in
        n) show_line_numbers=1 ;;
        v) invert_match=1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done


shift $((OPTIND-1))


if [ $# -lt 2 ]; then
    if [ $# -eq 1 ] && [ -n "$1" ]; then
        echo "Error: Missing file name" >&2
    else
        echo "Error: Missing search string and/or file name" >&2
    fi
    usage
fi

search_string="$1"
file="$2"

# التحقق من وجود الملف
if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    echo "Error: File '$file' does not exist or is not readable" >&2
    exit 1
fi


awk -v search="$search_string" -v show_num="$show_line_numbers" -v invert="$invert_match" '
BEGIN {
    IGNORECASE=1
}
{
    match_result = (index($0, search) > 0)
    if (invert) match_result = !match_result
    if (match_result) {
        if (show_num) {
            printf "%d:%s\n", NR, $0
        } else {
            print $0
        }
    }
}' "$file"

exit 0