#!/bin/bash

set -e

DEFAULT_FILE="tokenlist.json"
REQUIRED_FIELDS=(name symbol decimals address chainId logoURI)

print_help() {
  cat <<EOF
Usage: $0 <command> [--file <path>] [--url <url>]

Commands:
  check-structure      Validate token metadata structure.
  print-structure      Show all unique JSON paths.
  extract-token-metadata
                       Generate metadata and download icons.
  help                 Show this help message.

Options:
  --file <path>        Input JSON file (default: tokenlist.json)
  --url <url>          URL to download tokenlist (overrides --file)
EOF
}

json_structure() {
  local input="$1"
  if [[ "$input" == http* ]]; then
    curl -s "$input" | jq -r '
      paths | map(if type == "number" then "[]" else tostring end) | join(".")
    ' | sort -u
  else
    jq -r '
      paths | map(if type == "number" then "[]" else tostring end) | join(".")
    ' "$input" | sort -u
  fi
}

print_pr_description() {  local file="${1:-tokenlist.json}"                   
  local explorer_url="${2:-https://evm.flowscan.io}"
  local token_list_url="${3:-(URL not provided)}"

  echo '```markdown'
  echo "## Description"
  echo
  jq -r '.name // "Unnamed Token List"' "$file" | sed 's/^/Adding /; s/$/ icons and metadata/'
  echo
  echo "**Token List**: [$(jq -r '.name' "$file")]($token_list_url)  "
  echo "**Block Explorer**: $explorer_url"
  echo
  echo "**Added Tokens:**"
  echo

  jq -c '.tokens[]' "$file" | while read -r token; do
    symbol=$(echo "$token" | jq -r '.symbol')
    name=$(echo "$token" | jq -r '.name')
    address=$(echo "$token" | jq -r '.address' | tr '[:upper:]' '[:lower:]')
    echo "- **${symbol}**: ${explorer_url}/token/${address}  "
  done

  echo '```'
}

check_structure() {
  local file="$1"
  local total=0
  local failures=0
  local index=0

  jq -c '.tokens[]' "$file" | while IFS= read -r token_json; do
    index=$((index + 1))
    local has_missing=0
    local output=""
    local symbol=$(echo "$token_json" | jq -r '.symbol')

    for field in "${REQUIRED_FIELDS[@]}"; do
      value=$(echo "$token_json" | jq -er ".${field}" 2>/dev/null || echo "null")
      if [[ "$value" == "null" ]]; then
        has_missing=1
        output+="  ❌ Missing field: $field"$'\n'
      fi
    done

    if [[ $has_missing -eq 1 ]]; then
      echo "❌ Token #$index ($symbol) failed validation:"
      echo "$output"
      echo "$token_json" | jq
      echo
    else
      echo "✅ Token #$index ($symbol) is valid"
    fi
  done
}


extract_token_metadata() {
  local file="$1"

  echo "🔍 Checking token structure..."
  if ! check_structure "$file"; then
    echo "❌ Structure validation failed. Fix errors and retry."
    exit 1
  fi

  jq -c '.tokens[]' "$file" | while read -r token; do
    name=$(echo "$token" | jq -r '.name')
    symbol=$(echo "$token" | jq -r '.symbol')
    decimals=$(echo "$token" | jq -r '.decimals')
    address=$(echo "$token" | jq -r '.address')
    chain_id=$(echo "$token" | jq -r '.chainId')
    logo_url=$(echo "$token" | jq -r '.logoURI')

    metadata_dir="metadata/eip155:${chain_id}"
    icons_dir="icons/eip155:${chain_id}"
    mkdir -p "$metadata_dir" "$icons_dir"

    tmpfile=$(mktemp)
    curl -s -L "$logo_url" -o "$tmpfile"

    mime=$(file --brief --mime-type "$tmpfile")
    case "$mime" in
      image/svg+xml) extension="svg" ;;
      image/png) extension="png" ;;
      image/jpeg) extension="jpg" ;;
      *)
        echo "⚠️  Unknown image type ($mime) for $symbol, skipping..."
        rm "$tmpfile"
        continue
        ;;
    esac

    image_path="${icons_dir}/erc20:${address}.${extension}"
    mv "$tmpfile" "$image_path"

    cat <<EOF > "${metadata_dir}/erc20:${address}.json"
{
  "name": "${name}",
  "symbol": "${symbol}",
  "decimals": ${decimals},
  "erc20": true,
  "logo": "./icons/eip155:${chain_id}/erc20:${address}.${extension}"
}
EOF

    echo "✅ Processed $symbol on chain ${chain_id}"
  done
}

# === Main Command Router ===
cmd="$1"
shift || true

input_file="$DEFAULT_FILE"
input_url=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) input_file="$2"; shift 2 ;;
    --url) input_url="$2"; shift 2 ;;
    *) echo "❌ Unknown option: $1"; print_help; exit 1 ;;
  esac
done

if [[ -n "$input_url" ]]; then
  curl -s "$input_url" -o "$input_file"
fi

case "$cmd" in
  help|"") print_help ;;
  print-structure) json_structure "$input_file" ;;
  check-structure) check_structure "$input_file" ;;
  extract-token-metadata) extract_token_metadata "$input_file" ;;
  print-pr-description) print_pr_description "$input_file" "$2" "$3" ;;
  *) echo "❌ Unknown command: $cmd"; print_help; exit 1 ;;
esac
