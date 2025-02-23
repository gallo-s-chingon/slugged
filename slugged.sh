#!/usr/bin/env bash
#: Name        : slugged
#: Date        : 2025-02-23
#: Author      : gallo-s-chingon, adapted from Benjamin Linton's slugify with enhancements
#: Version     : 0.2
#: Description : Convert filenames to a slug format: lowercase alphanumeric with single delimiters,
#:               removing non-ASCII, punctuation, and emojis, preserving extensions.
#: Options     : See print_usage() function.

# Print usage information
print_usage() {
  echo "usage: slugged [options] source_file ..."
  echo "  -h, --help            Show this help"
  echo "  -v, --verbose         Verbose mode (show rename actions)"
  echo "  -n, --dry-run         Dry run mode (no changes, implies -v)"
  echo "  -u, --underscore      Use underscores instead of hyphens as delimiter"
  echo "  -N, --number-duplicates Number duplicates (e.g., file-2)"
  echo "  -d, --delete-all      Delete all duplicates with confirmation"
}

# Slugify a single filename, preserving extension and directory path
slugify_file() {
  local input="$1"
  local delimiter="$2"
  local dir_name="${input%/*}"
  local base_name="${input##*/}"
  local extension
  local result

  if [[ "$base_name" =~ \. ]]; then
    extension="${base_name##*.}"
    base_name="${base_name%.*}"
  else
    extension=""
  fi

  result=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' "$delimiter")
  result="${result#$delimiter}"
  result="${result%$delimiter}"

  if [ -n "$extension" ]; then
    result="$result.$extension"
  fi
  if [ "$dir_name" != "$input" ] && [ "$dir_name" != "." ]; then
    result="$dir_name/$result"
  fi

  echo "$result"
}

# Check if a target filename already exists in the list
check_duplicate() {
  local target="$1"
  local target_slug=$(slugify_file "$target" "$delimiter")
  shift
  local files=("$@")
  for file in "${files[@]}"; do
    if [ "$file" != "$target" ] && [ "$(slugify_file "$file" "$delimiter")" = "$target_slug" ]; then
      return 0
    fi
  done
  return 1
}

# Main processing function
main() {
  local verbose=0
  local dry_run=0
  local delimiter="-"
  local number_duplicates=0
  local delete_all=0

  while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    -v | --verbose) verbose=1 ;;
    -n | --dry-run)
      dry_run=1
      verbose=1
      ;;
    -u | --underscore) delimiter="_" ;;
    -N | --number-duplicates) number_duplicates=1 ;;
    -d | --delete-all) delete_all=1 ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
    *) break ;;
    esac
    shift
  done

  if [ $# -eq 0 ]; then
    print_usage
    exit 1
  fi

  if [ $dry_run -eq 1 ]; then
    echo "--- Begin dry run mode ---"
  fi

  # Collect files and their slugified names
  declare -A slug_map
  local files=("$@")
  local duplicates=()
  for file in "${files[@]}"; do
    if [ ! -e "$file" ]; then
      echo "not found: $file" >&2
      continue
    fi
    local slug=$(slugify_file "$file" "$delimiter")
    if [ -n "${slug_map[$slug]}" ]; then
      duplicates+=("$file")
    else
      slug_map["$slug"]="$file"
    fi
  done

  # Handle duplicates
  if [ ${#duplicates[@]} -gt 0 ]; then
    if [ $number_duplicates -eq 1 ] && [ $delete_all -eq 0 ]; then
      for dup in "${duplicates[@]}"; do
        local slug=$(slugify_file "$dup" "$delimiter")
        local dir_name="${dup%/*}"
        local base_slug_no_dir="${slug##*/}"
        local counter=2
        local new_slug="$dir_name/$base_slug_no_dir-$counter"
        while [ -n "${slug_map[$new_slug]}" ] || [ -e "$new_slug" ]; do
          counter=$((counter + 1))
          new_slug="$dir_name/$base_slug_no_dir-$counter"
        done
        slug_map["$new_slug"]="$dup"
        if [ $verbose -eq 1 ] && [ $dry_run -eq 1 ]; then
          echo "number: $dup -> $new_slug"
        fi
      done
    elif [ $delete_all -eq 1 ]; then
      echo "Duplicates detected:"
      for dup in "${duplicates[@]}"; do
        local slug=$(slugify_file "$dup" "$delimiter")
        echo "  $dup -> $slug"
      done
      read -t 180 -p "Are you sure you want to delete all duplicates found? This cannot be reversed (y/Y/yes/Yes/dry-run/number): " answer
      if [ $? -ne 0 ]; then
        echo "Timed out after 3 minutes." >&2
        exit 1
      fi
      case "$answer" in
      y | Y | yes | Yes)
        for dup in "${duplicates[@]}"; do
          local slug=$(slugify_file "$dup" "$delimiter")
          if [ "$dup" != "${slug_map[$slug]}" ]; then
            if [ $dry_run -eq 0 ]; then
              rm -rf "$dup"
            fi
            if [ $verbose -eq 1 ]; then
              echo "delete: $dup"
            fi
          fi
        done
        ;;
      dry-run)
        dry_run=1
        echo "--- Switching to dry run mode ---"
        for dup in "${duplicates[@]}"; do
          local slug=$(slugify_file "$dup" "$delimiter")
          if [ "$dup" != "${slug_map[$slug]}" ]; then
            echo "delete: $dup"
          fi
        done
        ;;
      number)
        for dup in "${duplicates[@]}"; do
          local slug=$(slugify_file "$dup" "$delimiter")
          local dir_name="${dup%/*}"
          local base_slug_no_dir="${slug##*/}"
          local counter=2
          local new_slug="$dir_name/$base_slug_no_dir-$counter"
          while [ -n "${slug_map[$new_slug]}" ] || [ -e "$new_slug" ]; do
            counter=$((counter + 1))
            new_slug="$dir_name/$base_slug_no_dir-$counter"
          done
          slug_map["$new_slug"]="$dup"
          if [ $verbose -eq 1 ] && [ $dry_run -eq 1 ]; then
            echo "number: $dup -> $new_slug"
          fi
        done
        ;;
      *)
        echo "Aborting deletion. No changes made to duplicates."
        ;;
      esac
    else
      echo "Duplicates detected:"
      for dup in "${duplicates[@]}"; do
        echo "  $dup -> $(slugify_file "$dup" "$delimiter")"
      done
      read -t 180 -p "Handle duplicates by (n)umbering or (d)eleting? (n/d): " choice
      if [ $? -ne 0 ]; then
        echo "Timed out after 3 minutes." >&2
        exit 1
      fi
      case "$choice" in
      n | N)
        for dup in "${duplicates[@]}"; do
          local slug=$(slugify_file "$dup" "$delimiter")
          local dir_name="${dup%/*}"
          local base_slug_no_dir="${slug##*/}"
          local counter=2
          local new_slug="$dir_name/$base_slug_no_dir-$counter"
          while [ -n "${slug_map[$new_slug]}" ] || [ -e "$new_slug" ]; do
            counter=$((counter + 1))
            new_slug="$dir_name/$base_slug_no_dir-$counter"
          done
          slug_map["$new_slug"]="$dup"
          if [ $verbose -eq 1 ] && [ $dry_run -eq 1 ]; then
            echo "number: $dup -> $new_slug"
          fi
        done
        ;;
      d | D)
        echo "Duplicates to delete:"
        for dup in "${duplicates[@]}"; do
          echo "  $dup"
        done
        read -t 180 -p "Delete [D]elete all or [a]bort? (D/a): " del_choice
        if [ $? -ne 0 ]; then
          echo "Timed out after 3 minutes." >&2
          exit 1
        fi
        if [ "$del_choice" = "D" ] || [ "$del_choice" = "d" ]; then
          for dup in "${duplicates[@]}"; do
            local slug=$(slugify_file "$dup" "$delimiter")
            if [ "$dup" != "${slug_map[$slug]}" ]; then
              if [ $dry_run -eq 0 ]; then
                rm -rf "$dup"
              fi
              if [ $verbose -eq 1 ]; then
                echo "delete: $dup"
              fi
            fi
          done
        else
          echo "Aborting deletion. No changes made to duplicates."
        fi
        ;;
      *)
        echo "Invalid choice. Aborting." >&2
        exit 1
        ;;
      esac
    fi
  fi

  # Process renames
  for slug in "${!slug_map[@]}"; do
    local file="${slug_map[$slug]}"
    if [ "$file" != "$slug" ]; then
      if [ $dry_run -eq 1 ]; then
        echo "rename: $file -> $slug"
      else
        if [ $verbose -eq 1 ]; then
          mv -v "$file" "$slug"
        else
          mv "$file" "$slug"
        fi
      fi
    elif [ $verbose -eq 1 ]; then
      echo "ignore: $file (already slugified)"
    fi
  done

  if [ $dry_run -eq 1 ]; then
    echo "--- End dry run mode ---"
  fi
}

main "$@"

