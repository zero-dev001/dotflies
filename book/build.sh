#!/bin/bash
cd "$(dirname "$0")"
pandoc metadata.yaml \
  src/00-introduction.md \
  src/PART-1-FOUNDATIONS/*.md \
  src/PART-2-NAVIGATION/*.md \
  src/PART-3-EDITOR/*.md \
  src/PART-4-TMUX/*.md \
  src/PART-5-GIT/*.md \
  src/PART-6-WINDOW-MANAGEMENT/*.md \
  src/PART-7-CLI-TOOLBOX/*.md \
  src/PART-8-DEV-ENVIRONMENT/*.md \
  src/PART-9-WORKFLOWS/*.md \
  src/APPENDIX/*.md \
  -o zero-dev-environment.pdf \
  --toc --toc-depth=3 \
  --listings \
  --pdf-engine=xelatex \
  -V geometry:margin=1in \
  -V documentclass=report \
  -V fontsize=11pt \
  -V colorlinks=true \
  -V linkcolor=blue
echo "Built: book/zero-dev-environment.pdf"
