---
name: grab
description: Capture the most recent Claude response as image, Slack text, or rich text and copy to clipboard
---

Capture the most recent assistant response and copy it to clipboard.

| Mode | Command | Speed | Output |
|------|---------|-------|--------|
| Fast image | `/grab` | ~2s | Raw markdown → Dracula PNG |
| Polished image | `/grab img` | ~0.7s | Pandoc HTML + qlmanage → Dracula PNG |
| Slack | `/grab slack` | instant | Slack mrkdwn text |
| Docs | `/grab docs` | ~1s | Rich text (RTF) |

## Instructions

1. Identify the assistant's most recent response (the message immediately before `/grab`).

2. Content rules (all modes):
   - Include the full response text exactly as written
   - Do NOT include tool calls, tool results, or system messages — only visible text
   - Do NOT include preamble like "Here is the capture" — just the raw content
   - If >100 lines, include only the most substantive section and note what was trimmed

### Mode: `/grab` (fast image, default)

ONE Bash call — heredoc + silicon on raw markdown:
```
cat <<'GRAB_EOF' > /tmp/claude-grab.md
CONTENT
GRAB_EOF
silicon /tmp/claude-grab.md -o /tmp/claude-grab.png \
  --no-round-corner --no-window-controls --no-line-number \
  --background '#00000000' --shadow-blur-radius 0 \
  --pad-horiz 40 --pad-vert 30 --theme Dracula 2>/dev/null \
  && H=$(sips -g pixelHeight /tmp/claude-grab.png 2>/dev/null | tail -1 | awk '{print $2}') \
  && W=$(sips -g pixelWidth /tmp/claude-grab.png 2>/dev/null | tail -1 | awk '{print $2}') \
  && [ "$H" -lt 400 ] \
  && sips --padToHeightWidth 400 $W --padColor 282a36 /tmp/claude-grab.png \
       -o /tmp/claude-grab.png >/dev/null 2>&1; \
  osascript -e 'set the clipboard to (read (POSIX file "/tmp/claude-grab.png") as «class PNGf»)' \
  && sips -g pixelWidth -g pixelHeight /tmp/claude-grab.png
```
Respond: **Copied to clipboard.** (dimensions)

### Mode: `/grab img` (polished image)

ONE Bash call — heredoc writes content, wrapper script runs pandoc→qlmanage→autocrop→clipboard:
```
cat <<'GRAB_EOF' > /tmp/claude-grab.md
CONTENT
GRAB_EOF
~/.claude/bin/grab-img.sh /tmp/claude-grab.md
```
Respond: **Copied to clipboard.** (dimensions)

### Mode: `/grab slack` (text)

ONE Bash call:
```
cat <<'GRAB_EOF' > /tmp/claude-grab.md
CONTENT
GRAB_EOF
sed -E \
  -e 's/^### (.+)$/*\1*/g' \
  -e 's/^## (.+)$/*\1*/g' \
  -e 's/^# (.+)$/*\1*/g' \
  -e 's/\*\*([^*]+)\*\*/*\1*/g' \
  /tmp/claude-grab.md | pbcopy
```
Respond: **Copied to clipboard (Slack format).**

### Mode: `/grab docs` (rich text)

ONE Bash call:
```
cat <<'GRAB_EOF' > /tmp/claude-grab.md
CONTENT
GRAB_EOF
pandoc /tmp/claude-grab.md -f markdown -t rtf -o /tmp/claude-grab.rtf \
  && osascript -e '
    set rtfData to read (POSIX file "/tmp/claude-grab.rtf") as «class RTF »
    set the clipboard to rtfData
  '
```
Respond: **Copied to clipboard (rich text).**

## Important
- Be FAST. No extra commentary, no re-reading files, no exploration.
- ALL modes are now ONE Bash call. No glow, no PTY hacks.
- If silicon missing: `brew install silicon`. If pandoc missing: `brew install pandoc`.
- If grab-crop missing: `swiftc -O -o ~/.claude/bin/grab-crop ~/.claude/bin/grab-crop.swift`
