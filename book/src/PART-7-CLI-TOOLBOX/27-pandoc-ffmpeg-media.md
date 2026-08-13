# Media and Documents: pandoc, ffmpeg, and Friends

> Command-line tools for converting documents, processing video and audio, downloading media, and manipulating images -- all installed and ready in your Brewfile.

## Your Setup

All of the following tools are installed via Homebrew in the master Brewfile:

```ruby
brew "pandoc"
brew "ffmpeg"
brew "ffmpegthumbnailer"
brew "yt-dlp"
brew "aria2"
brew "imagemagick"
brew "ghostscript"    # PDF rendering backend for imagemagick
brew "poppler"        # PDF utilities, used by Yazi for previews
brew "mermaid-cli"    # Diagram generation from Markdown-style syntax
```

Notable integrations in your environment:

- **ffmpegthumbnailer** is used by **Yazi** to generate video preview thumbnails in the file manager
- **poppler** provides `pdftotext` and `pdftoppm`, used by Yazi for PDF previews
- **ghostscript** is a dependency for imagemagick's PDF operations
- **pandoc** is used to build this very book from Markdown sources
- **mermaid-cli** generates diagrams from `.mmd` files, useful in documentation workflows

## Core Concepts

### pandoc -- Universal Document Converter

pandoc reads markup in one format and writes it in another. It understands Markdown, HTML, LaTeX, DOCX, EPUB, reStructuredText, Org-mode, and dozens more. The key insight is that pandoc uses an internal abstract syntax tree, so any input format can be converted to any output format. For PDF output, pandoc uses LaTeX as an intermediate step (requires a TeX distribution like MacTeX or TinyTeX).

### ffmpeg -- The Swiss Army Knife of Media

ffmpeg is a complete framework for decoding, encoding, transcoding, muxing, demuxing, streaming, filtering, and playing almost any media format. Its command-line syntax follows a pattern: input options, `-i input`, output options, output file.

### yt-dlp -- Media Downloader

yt-dlp is a feature-rich command-line downloader forked from youtube-dl. It supports thousands of sites and offers fine-grained control over format selection, subtitles, and metadata.

### aria2 -- High-Speed Downloader

aria2 is a multi-protocol download utility that can use multiple connections per download and supports HTTP, FTP, BitTorrent, and Metalink.

### imagemagick -- Image Processing

ImageMagick provides a suite of commands (`convert`, `identify`, `mogrify`, `composite`) for image manipulation from the command line.

## Essential Commands -- pandoc

| Command | Purpose |
|---|---|
| `pandoc file.md -o file.pdf` | Markdown to PDF (requires LaTeX) |
| `pandoc file.md -o file.html` | Markdown to standalone HTML |
| `pandoc file.md -o file.docx` | Markdown to Word document |
| `pandoc file.docx -o file.md` | Word document to Markdown |
| `pandoc file.md -o file.epub` | Markdown to EPUB ebook |
| `pandoc --toc file.md -o file.pdf` | Include auto-generated table of contents |
| `pandoc -V geometry:margin=1in file.md -o file.pdf` | Set PDF margins |
| `pandoc -s file.md -o file.html` | Standalone HTML (full document with head) |
| `pandoc --template=tmpl.tex file.md -o file.pdf` | Use a custom LaTeX template |
| `pandoc --highlight-style=tango file.md -o file.pdf` | Set code highlight theme |
| `pandoc --list-highlight-styles` | Show available highlight styles |
| `pandoc -f gfm -t html file.md` | Explicit input/output format (GitHub Markdown) |
| `pandoc --pdf-engine=xelatex file.md -o file.pdf` | Use XeLaTeX for Unicode/font support |
| `pandoc --filter pandoc-crossref file.md -o file.pdf` | Use a filter for cross-references |

## Essential Commands -- ffmpeg

| Command | Purpose |
|---|---|
| `ffmpeg -i in.mp4 out.gif` | Convert video to GIF |
| `ffmpeg -i in.mp4 -vn out.mp3` | Extract audio track (drop video) |
| `ffmpeg -i in.mp4 -an out.mp4` | Remove audio track (keep video) |
| `ffmpeg -i in.mp4 -ss 00:01:00 -t 30 out.mp4` | Trim clip: start at 1:00, 30 seconds |
| `ffmpeg -i in.mp4 out.webm` | Convert format (container/codec auto-detected) |
| `ffmpeg -i in.mp4 -vf scale=1280:720 out.mp4` | Scale video to 720p |
| `ffmpeg -i in.mp4 -vf scale=-1:720 out.mp4` | Scale height to 720, auto width |
| `ffmpeg -i in.mp4 -r 30 out.mp4` | Change frame rate to 30 fps |
| `ffmpeg -i in.mp4 -crf 23 out.mp4` | Control quality (lower = better, 18-28 typical) |
| `ffmpeg -i in.mp4 -vf "fps=10,scale=320:-1" out.gif` | Optimized GIF (lower fps, small) |
| `ffmpeg -i in.mp4 -c copy out.mkv` | Remux without re-encoding (fast) |
| `ffmpeg -i in.mp4 -ss 00:00:30 -frames:v 1 thumb.png` | Extract a single frame as image |
| `ffmpeg -i in.mp4 -vf drawtext="text='Hello':fontsize=24:x=10:y=10" out.mp4` | Overlay text |
| `ffmpeg -f concat -i list.txt -c copy out.mp4` | Concatenate multiple video files |

## Essential Commands -- yt-dlp

| Command | Purpose |
|---|---|
| `yt-dlp URL` | Download video in best available quality |
| `yt-dlp -f best URL` | Explicitly select best single-file format |
| `yt-dlp -x --audio-format mp3 URL` | Extract audio only, convert to MP3 |
| `yt-dlp -x --audio-format flac URL` | Extract audio as FLAC |
| `yt-dlp --list-formats URL` | List all available formats |
| `yt-dlp -f 'bestvideo[height<=720]+bestaudio' URL` | Download 720p max with best audio |
| `yt-dlp --write-sub --sub-lang en URL` | Download with English subtitles |
| `yt-dlp --write-auto-sub URL` | Download with auto-generated subtitles |
| `yt-dlp -o '%(title)s.%(ext)s' URL` | Custom output filename template |
| `yt-dlp --playlist-items 1-5 URL` | Download first 5 items from a playlist |
| `yt-dlp --download-archive done.txt URL` | Skip already-downloaded videos |
| `yt-dlp --cookies-from-browser firefox URL` | Use browser cookies for auth |

## Essential Commands -- aria2

| Command | Purpose |
|---|---|
| `aria2c URL` | Download a file |
| `aria2c -x 16 URL` | Download with 16 connections (much faster) |
| `aria2c -x 16 -s 16 URL` | 16 connections, 16 segments |
| `aria2c -i urls.txt` | Download all URLs from a file |
| `aria2c file.torrent` | Download a torrent |
| `aria2c file.metalink` | Download from a metalink file |
| `aria2c -d /path/to/dir URL` | Save to a specific directory |
| `aria2c -o filename URL` | Save with a custom filename |
| `aria2c --max-overall-download-limit=1M URL` | Limit download speed |

## Essential Commands -- imagemagick

| Command | Purpose |
|---|---|
| `convert in.png out.jpg` | Convert between image formats |
| `convert in.jpg -resize 50% out.jpg` | Resize by percentage |
| `convert in.jpg -resize 800x600 out.jpg` | Resize to fit within dimensions |
| `convert in.jpg -resize 800x600! out.jpg` | Force exact dimensions (may distort) |
| `identify image.jpg` | Show image dimensions, format, size |
| `identify -verbose image.jpg` | Detailed image metadata |
| `convert in.jpg -quality 80 out.jpg` | Set JPEG quality (0-100) |
| `convert in.png -trim out.png` | Auto-crop whitespace borders |
| `convert -append top.png bottom.png out.png` | Stack images vertically |
| `convert +append left.png right.png out.png` | Place images side by side |
| `mogrify -resize 50% *.jpg` | Resize all JPEGs in place (batch) |
| `convert in.pdf[0] out.png` | Convert first page of PDF to PNG |

## Practical Recipes

### Build a PDF book from multiple Markdown files

```bash
pandoc --toc \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  --highlight-style=tango \
  chapter1.md chapter2.md chapter3.md \
  -o book.pdf
```

This is the pattern used to build the book you are reading. pandoc concatenates the input files in order, generates a table of contents, and produces a single PDF.

### Create a high-quality GIF from a screen recording

```bash
# Step 1: Generate a colour palette for better quality
ffmpeg -i recording.mp4 -vf "fps=10,scale=640:-1:flags=lanczos,palettegen" palette.png

# Step 2: Use the palette to create the GIF
ffmpeg -i recording.mp4 -i palette.png \
  -filter_complex "fps=10,scale=640:-1:flags=lanczos[x];[x][1:v]paletteuse" \
  output.gif
```

### Download a playlist as MP3 files

```bash
yt-dlp -x --audio-format mp3 -o '%(playlist_index)s-%(title)s.%(ext)s' \
  'https://youtube.com/playlist?list=PLAYLIST_ID'
```

### Batch convert images for web

```bash
mkdir -p web
for img in *.jpg; do
  convert "$img" -resize 1200x1200 -quality 85 "web/$img"
done
```

### Create a contact sheet from video

```bash
ffmpeg -i video.mp4 -vf "select='not(mod(n,300))',scale=320:-1,tile=4x4" \
  -frames:v 1 contact_sheet.png
```

This extracts every 300th frame, scales them, and tiles them in a 4x4 grid.

### Fast download with aria2 (16 connections)

```bash
aria2c -x 16 -s 16 https://example.com/large-file.iso
```

This is significantly faster than curl or wget for large files from servers that allow multiple connections.

## Advanced Usage

### pandoc Metadata and YAML Front Matter

pandoc reads YAML metadata blocks at the top of Markdown files:

```yaml
---
title: "My Document"
author: "zero.dev001"
date: 2025-01-15
---
```

These variables populate the title page and headers in PDF output.

### ffmpeg Filter Chains

ffmpeg's `-filter_complex` allows chaining multiple video/audio filters:

```bash
# Overlay a watermark in the bottom-right corner
ffmpeg -i video.mp4 -i watermark.png \
  -filter_complex "overlay=W-w-10:H-h-10" \
  output.mp4
```

### Automating with a Makefile

For a document project, a Makefile ties everything together:

```makefile
book.pdf: $(wildcard chapters/*.md)
	pandoc --toc -V geometry:margin=1in $^ -o $@

diagrams/%.png: diagrams/%.mmd
	mmdc -i $< -o $@
```

The `mmdc` command is mermaid-cli, installed in your Brewfile, which renders Mermaid diagram syntax to PNG or SVG.

### ImageMagick for Screenshots

```bash
# Add a shadow and border to a screenshot (great for documentation)
convert screenshot.png \
  \( +clone -background black -shadow 60x10+0+10 \) \
  +swap -background none -layers merge +repage \
  screenshot-styled.png
```

\newpage
