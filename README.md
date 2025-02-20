# Slugged

A revised version of [benlinton/slugify](https://github.com/benlinton/slugify) to convert filenames into a clean, lowercase, alphanumeric slug format with single delimiters (hyphens or underscores), stripping out emojis, non-ASCII characters, and punctuation while preserving file extensions.

---

## Why Slugged?

I’m mostly a prose writer, but nerdy enough to tinker with tools, LLMs, and distro-hopping to kill time. Years ago (sometime after 2014), I stumbled upon [benlinton/slugify](https://github.com/benlinton/slugify). It was a lifesaver for turning blog titles into filenames for my static site—cut, paste, slugify, done. But there was a catch: it didn’t handle emojis, non-ASCII characters, or punctuation. I’d roll with it until a deploy failed, then realize some funky character in the title broke everything. Back to the drawing board—manually renaming files or using Name Mangler on macOS to clean up the mess.

Like any *nix user, I’d spend months tweaking scripts to save 46 seconds later. I started with a function wrapping `slugify`, added a script to scrub the rest (thanks, Stack Overflow!), refined it with ChatGPT and Perplexity, and then Grok (from xAI) helped me slap it all together, push it to GitHub, and even get it into Homebrew. Now, `slugged` is my one-stop shop for filename slugification, and I figured—why not share it?

**TL;DR**: Started with `slugify` + Name Mangler, built a function and script, got LLM help to refine it, and now it’s a Homebrew-installable tool for everyone.

---

## Features

- Converts filenames to lowercase alphanumeric (0-9, a-z) strings.
- Replaces non-ASCII, punctuation, and emojis with a single delimiter (default: `-`).
- Supports underscores (`-u`) as an alternative delimiter.
- Preserves file extensions.
- Options for verbose output (`-v`), dry run (`-n`), and help (`-h`).

---

## Installation

### Via Homebrew (Recommended)

```bash
brew tap gallo-s-chingon/slugged
brew install slugged# Rename with hyphens (default)
```
## Manual Installation
Download and make executable

```bash
curl -L https://github.com/gallo-s-chingon/slugged/raw/main/slugged.sh -o slugged
chmod +x slugged
mv slugged /usr/local/bin/  # Or another directory in your $PATH
```

## Usage
```bash
slugged [options] <file> …
```
run `slugged -h` for a full list of options

## Examples
```bash
slugged -v "test --    _ __ --_- file    name 😂.txt"
# Output: renamed 'test --    _ __ --_- file    name 😂.txt' -> 'test-file-name.txt'

# Rename with underscores
slugged -u "test --    _ __ --_- file    name 😂.txt"
# Output: renamed 'test --    _ __ --_- file    name 😂.txt' -> 'test_file_name.txt'

# Dry run (no changes)
slugged -n "My File! 😊.docx"
# Output: rename: My File! 😊.docx -> my-file.docx
```

## Options

- `-h`: Show help
- `-v`: Verbose mode (show rename actions)
- `-n`: Dry run (no changes, implies `-v`)
- `-u`: Use underscores instead of hyphens as a delimiter

## Contributing
Feel free to fork, tweak, or submit pull requests! Issues and suggestions are welcome too. Here’s how to get started:

1. Fork the repo: https://github.com/gallo-s-chingon/slugged
2. Clone your fork: git clone https://github.com/your-username/slugged.git
3. Make changes and test locally.
4. Push and submit a PR.

## Credits
- [https://github.com/benlinton/slugify](benlinton/slugify) for the original inspiration.
- Stack Overflow for countless script snippets.
- ChatGPT and Perplexity for early refinements.
- Grok (xAI) for putting it all together and guiding me to Homebrew.

## License
MIT License

Copyright (c) 2025 Gallo Chingon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
