## 🛠️ Tokenlist Utilities

A lightweight Bash utility script for inspecting and transforming ERC-20 token lists into contract metadata and icons compatible with MetaMask and similar projects.

No install required. Just **curl and run**.

---

## 🚀 Quickstart

```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/tokenlist-utils.sh | bash -s <command> [options]
```

Replace `<command>` and `[options]` as described below.

---

## 🔧 Commands

### `check-structure`

Validate that each token has the required fields:

```bash
bash tokenlist-utils.sh check-structure --file tokenlist.json
```

Or with curl:

```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/tokenlist-utils.sh | bash -s check-structure --url https://example.com/tokenlist.json
```

---

### `print-structure`

Print the JSON path structure (for introspection/debugging):

```bash
bash tokenlist-utils.sh print-structure --file tokenlist.json
```

---

### `extract-token-metadata`

Generate metadata and icons for each ERC-20 token in the list.

> **📍 Important:** This must be run from the root of the [MetaMask `contract-metadata`](https://github.com/MetaMask/contract-metadata) repository.

```bash
bash tokenlist-utils.sh extract-token-metadata --file tokenlist.json
```

This command will:

- ✅ Create metadata files under `metadata/eip155:<CHAIN_ID>/erc20:<ADDRESS>.json`
- 🖼️ Download logos to `icons/eip155:<CHAIN_ID>/erc20:<ADDRESS>.EXT`
- 🔍 Automatically infer image MIME type using `file`
- 🧙 Convert all image types (e.g. SVG, JPG) to **PNG** if `magick` (ImageMagick) or `convert` is available

The generated JSON files follow MetaMask's metadata schema and reference the correct relative icon path in PNG format.


---

### `print-pr-description`

Generate a PR description in **Markdown format** inside a code block, with links to tokens using a block explorer:

```bash
bash tokenlist-utils.sh print-pr-description --file tokenlist.json "https://evm.flowscan.io" "https://example.com/tokenlist.json"
```

---

## 📁 Output Structure

- `metadata/eip155:[CHAIN_ID]/erc20:[ADDRESS].json` – contract metadata  
- `icons/eip155:[CHAIN_ID]/erc20:[ADDRESS].svg|.png|.jpg` – downloaded token icons

---

## 📝 Requirements

- Bash 4+  
- `jq`, `curl`, `file`

---

## ✅ Supported Fields (per token)

Each token must have the following fields:

```json
{
  "name": "TokenName",
  "symbol": "TKN",
  "decimals": 18,
  "address": "0x...",
  "chainId": 1,
  "logoURI": "https://..."
}
```

---

## 🤝 Contributions

Feel free to submit PRs or open issues for improvements like parallel downloads, EIP-55 validation, or CI-ready output.
