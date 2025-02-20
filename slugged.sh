#!/bin/bash
#: Name        : slugged
#: Date        : 2025-02-20
#: Author      : gallo-s-chingon, adapted from Benjamin Linton's slugify with help from StackOverflow, ChatGPT, Perplexity, and Grok
#: Version     : 0.1b
#: Description : Convert filenames to a slug format: lowercase alphanumeric with single delimiters,
#:               removing non-ASCII, punctuation, and emojis, preserving extensions.
#: Options     : -h (help), -v (verbose), -n (dry run), -u (use underscores instead of hyphens)

# Print usage information
print_usage() {
  echo "usage: slugged [-hvn] [-u] source_file ..."
  echo "  -h: show this help"
  echo "  -v: verbose mode (show rename actions)"
  echo "  -n: dry run mode (no changes, implies -v)"
  echo "  -u: use underscores instead of hyphens as delimiter"
}

# Slugify a single filename, preserving extension
slugify_file() {
  local input="$1"
  local delimiter="$2" # Either "-" or "_"
  local base_name
  local extension
  local result

  # Split into base name and extension
  if [[ "$input" =~ \. ]]; then
    extension="${input##*.}"
    base_name="${input%.*}"
  else
    base_name="$input"
    extension=""
  fi

  # Convert to lowercase using tr (portable alternative to ${var,,})
  result=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')

  # Replace all non-alphanumeric with delimiter
  result="${result//[^a-z0-9]/$delimiter}"

  # Collapse multiple delimiters into one
  while [[ "$result" =~ $delimiter$delimiter ]]; do
    result="${result//$delimiter$delimiter/$delimiter}"
  done

  # Trim leading/trailing delimiters
  result="${result#$delimiter}"
  result="${result%$delimiter}"

  # Reattach extension if present
  if [ -n "$extension" ]; then
    result="$result.$extension"
  fi

  echo "$result"
}

# Main processing loop
main() {
  local verbose=0
  local dry_run=0
  local delimiter="-" # Default delimiter

  # Parse options
  while getopts "hvnu" opt; do
    case $opt in
    h)
      print_usage
      exit 0
      ;;
    v) verbose=1 ;;
    n)
      dry_run=1
      verbose=1
      ;;
    u) delimiter="_" ;;
    ?)
      print_usage
      exit 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check if arguments are provided
  if [ $# -eq 0 ]; then
    print_usage
    exit 1
  fi

  # Process each file
  for file in "$@"; do
    if [ ! -e "$file" ]; then
      echo "not found: $file" >&2
      continue
    fi

    local slugified=$(slugify_file "$file" "$delimiter")

    if [ "$file" != "$slugified" ]; then
      if [ "$dry_run" -eq 1 ]; then
        echo "rename: $file -> $slugified"
      else
        if [ "$verbose" -eq 1 ]; then
          mv -v "$file" "$slugified"
        else
          mv "$file" "$slugified"
        fi
      fi
    elif [ "$verbose" -eq 1 ]; then
      echo "ignore: $file (already slugified)"
    fi
  done
}

# Handle dry run preamble/postamble
if [[ "$*" =~ -n ]]; then
  echo "--- Begin dry run mode ---"
  main "$@"
  echo "--- End dry run mode ---"
else
  main "$@"
fi
