catatan() {
  local dir="$HOME/dotfiles/cheatsheet"
  local topic="$1"

  mkdir -p "$dir"

  if [[ ! -d "$dir" ]]; then
    echo "folder $dir gak ada"
    return 1
  fi

  # list topik kalau tanpa argumen
  if [[ -z "$topic" ]]; then
    echo "Topik yang ada:"
    # ambil basename tanpa ekstensi, urut
    for f in "$dir"/*.{txt,md} "$dir"/*; do
      [[ -f "$f" ]] || continue
      basename "${f%.*}"
    done | sort -u | tr '[:upper:]' '[:lower:]'
    return
  fi

  # trim spasi + lower
  topic=$(echo "$topic" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')

  # 1. cari exact match: bash.txt, Bash.TXT, bash.md
  local file=$(find "$dir" -maxdepth 1 -type f \( -iname "${topic}.txt" -o -iname "${topic}.md" \) | head -n1)

  # 2. kalau gak ketemu, cari yang mengandung: my-bash-notes.txt
  if [[ -z "$file" ]]; then
    file=$(find "$dir" -maxdepth 1 -type f -iname "*${topic}*.txt" -o -iname "*${topic}*.md" | head -n1)
  fi

  if [[ -z "$file" ]]; then
    echo "Topik '$topic' gak ketemu. Yang ada:"
    catatan
    return 1
  fi

  cat "$file"
}

# biar cheatsheet tetep jalan (alias lama)
# cheatsheet() { catatan "$@"; }


_catatan_complete() {
  local cur dir topics
  dir="$HOME/cheatsheet"
  cur="${COMP_WORDS[COMP_CWORD]}"
  
  # ambil semua nama file tanpa ekstensi, jadiin lowercase
  topics=$(for f in "$dir"/*.txt "$dir"/*.md; do
    [[ -f "$f" ]] || continue
    f=$(basename "$f")
    echo "${f%.*}"
  done | tr '[:upper:]' '[:lower:]' | sort -u)

  COMPREPLY=( $(compgen -W "$topics" -- "$cur") )
}

# daftarin ke 2 nama, biar cheatsheet juga auto
complete -F _catatan_complete catatan