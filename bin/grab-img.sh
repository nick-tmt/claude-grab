#!/bin/bash
set -e
INPUT="$1"
pandoc "$INPUT" -f markdown -t html --standalone \
  --metadata title="" \
  -V "header-includes:<style>html,body{background:#282a36;color:#f8f8f2;font-family:-apple-system,BlinkMacSystemFont,'Helvetica Neue',Arial,sans-serif;font-size:14px;padding:40px;margin:0;max-width:none;}h1,h2,h3{color:#8be9fd;}strong{color:#ff79c6;}em{color:#50fa7b;}table{border-collapse:collapse;}td,th{border:1px solid #6272a4;padding:6px 12px;}th{color:#bd93f9;}code{background:#44475a;padding:2px 6px;border-radius:3px;font-family:'SF Mono',Menlo,monospace;}pre{background:#44475a;padding:12px;border-radius:6px;font-family:'SF Mono',Menlo,monospace;}</style>" \
  -o /tmp/claude-grab.html
qlmanage -t -s 2000 -o /tmp/ /tmp/claude-grab.html 2>/dev/null
~/.claude/bin/grab-crop /tmp/claude-grab.html.png
osascript -e 'set the clipboard to (read (POSIX file "/tmp/claude-grab.html.png") as «class PNGf»)'
sips -g pixelWidth -g pixelHeight /tmp/claude-grab.html.png
