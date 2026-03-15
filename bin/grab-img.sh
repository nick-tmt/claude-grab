#!/bin/bash
set -e
INPUT="$1"
pandoc "$INPUT" -f markdown -t html --standalone \
  --metadata title="" \
  -V "header-includes:<style>html,body{background:#1e1e2e;color:#cdd6f4;font-family:-apple-system,BlinkMacSystemFont,'Helvetica Neue',Arial,sans-serif;font-size:15px;line-height:1.6;padding:44px;margin:0;max-width:none;}h1,h2,h3{color:#89b4fa;margin-top:1.2em;}strong{color:#f5c2e7;}em{color:#a6e3a1;}table{border-collapse:collapse;margin:1em 0;}td,th{border:1px solid #45475a;padding:8px 14px;}th{background:#313244;color:#cba6f7;}code{background:#313244;color:#f5c2e7;padding:2px 6px;border-radius:4px;font-family:'SF Mono',Menlo,monospace;font-size:0.9em;}pre{background:#313244;padding:14px;border-radius:6px;font-family:'SF Mono',Menlo,monospace;font-size:0.9em;}li{margin:4px 0;}a{color:#89b4fa;}</style>" \
  -o /tmp/claude-grab.html
qlmanage -t -s 2000 -o /tmp/ /tmp/claude-grab.html 2>/dev/null
~/.claude/bin/grab-crop /tmp/claude-grab.html.png
osascript -e 'set the clipboard to (read (POSIX file "/tmp/claude-grab.html.png") as «class PNGf»)'
sips -g pixelWidth -g pixelHeight /tmp/claude-grab.html.png
