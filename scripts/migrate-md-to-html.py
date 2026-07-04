#!/usr/bin/env python3
"""One-time migration: Markdown posts → standalone HTML pages."""

import html
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

POSTS = [
    {
        "src": "docs/2026/07/04/ai-agent-conference-2026.md",
        "out": "pages/2026-07-04-ai-agent-conference.html",
        "image_map": {"/ai-agent-con-2026/": "/assets/2026-07-04-ai-agent-conference/"},
    },
    {
        "src": "docs/2026/06/02/windows-tmux-claude-code-ssh.md",
        "out": "pages/2026-06-02-windows-tmux-claude-code-ssh.html",
        "image_map": {},
    },
    {
        "src": "docs/2026/05/31/attention-kernel-x-search-2026-05.md",
        "out": "pages/2026-05-31-attention-kernel-x-search.html",
        "image_map": {},
    },
    {
        "src": "docs/2026/05/31/attention-kernel-optimization-report-2026-05.md",
        "out": "pages/2026-05-31-attention-kernel-optimization-report.html",
        "image_map": {},
    },
]

STYLES = Path(ROOT / "templates" / "tech-article.html").read_text(encoding="utf-8")
STYLES = re.search(r"<style>(.*?)</style>", STYLES, re.DOTALL).group(1)


def parse_frontmatter(text: str) -> tuple[dict, str]:
    if not text.startswith("---"):
        return {}, text
    end = text.find("---", 3)
    if end == -1:
        return {}, text
    fm = text[3:end].strip()
    body = text[end + 3 :].lstrip()
    meta: dict = {}
    for line in fm.splitlines():
        if ":" not in line:
            continue
        key, val = line.split(":", 1)
        key = key.strip()
        val = val.strip().strip("'\"").strip("[]")
        if key == "tags":
            tags = re.findall(r"['\"]([^'\"]+)['\"]", line.split(":", 1)[1])
            meta[key] = ", ".join(tags) if tags else val
        else:
            meta[key] = val
    return meta, body


def inline_md(text: str) -> str:
    text = html.escape(text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    return text


def convert_md(body: str, image_map: dict) -> str:
    for old, new in image_map.items():
        body = body.replace(old, new)
    body = re.sub(r"<!--\s*more\s*-->\s*", "", body, count=1)

    lines = body.splitlines()
    out: list[str] = []
    i = 0
    in_code = False
    code_lang = ""
    code_lines: list[str] = []
    in_table = False
    table_rows: list[str] = []

    def flush_table() -> None:
        nonlocal in_table, table_rows
        if not table_rows:
            return
        out.append('<div class="table-wrap"><table>')
        for ri, row in enumerate(table_rows):
            cells = [c.strip() for c in row.strip("|").split("|")]
            tag = "th" if ri == 0 else "td"
            out.append("<tr>" + "".join(f"<{tag}>{inline_md(c)}</{tag}>" for c in cells) + "</tr>")
        out.append("</table></div>")
        table_rows = []
        in_table = False

    while i < len(lines):
        line = lines[i]

        if in_code:
            if line.strip().startswith("```"):
                out.append(f"<pre><code>{html.escape(chr(10).join(code_lines))}</code></pre>")
                code_lines = []
                in_code = False
            else:
                code_lines.append(line)
            i += 1
            continue

        if line.strip().startswith("```"):
            flush_table()
            in_code = True
            code_lang = line.strip()[3:].strip()
            i += 1
            continue

        if "|" in line and line.strip().startswith("|"):
            if re.match(r"^\|[\s\-:|]+\|$", line.strip()):
                i += 1
                continue
            in_table = True
            table_rows.append(line)
            i += 1
            continue
        elif in_table:
            flush_table()

        stripped = line.strip()
        if not stripped:
            i += 1
            continue

        if stripped == "---":
            out.append("<hr>")
        elif stripped.startswith("#### "):
            out.append(f"<h4>{inline_md(stripped[5:])}</h4>")
        elif stripped.startswith("### "):
            out.append(f"<h3>{inline_md(stripped[4:])}</h3>")
        elif stripped.startswith("## "):
            out.append(f"<h2>{inline_md(stripped[3:])}</h2>")
        elif stripped.startswith("# "):
            out.append(f"<h1>{inline_md(stripped[2:])}</h1>")
        elif stripped.startswith("> "):
            out.append(f"<blockquote><p>{inline_md(stripped[2:])}</p></blockquote>")
        elif re.match(r"^!\[([^\]]*)\]\(([^)]+)\)$", stripped):
            m = re.match(r"^!\[([^\]]*)\]\(([^)]+)\)$", stripped)
            out.append(f'<img src="{m.group(2)}" alt="{html.escape(m.group(1))}">')
        elif re.match(r"^[-*] ", stripped):
            items = []
            while i < len(lines) and re.match(r"^[-*] ", lines[i].strip()):
                items.append(f"<li>{inline_md(lines[i].strip()[2:])}</li>")
                i += 1
            out.append("<ul>" + "".join(items) + "</ul>")
            continue
        elif re.match(r"^\d+\. ", stripped):
            items = []
            while i < len(lines) and re.match(r"^\d+\. ", lines[i].strip()):
                items.append(f"<li>{inline_md(re.sub(r'^\d+\.\s*', '', lines[i].strip()))}</li>")
                i += 1
            out.append("<ol>" + "".join(items) + "</ol>")
            continue
        else:
            out.append(f"<p>{inline_md(stripped)}</p>")

        i += 1

    if in_code and code_lines:
        out.append(f"<pre><code>{html.escape(chr(10).join(code_lines))}</code></pre>")
    flush_table()

    result = "\n    ".join(out)
    result = re.sub(r"^<h1>[^<]*</h1>\s*", "", result.strip())
    return result


def first_paragraph(body: str) -> str:
    for line in body.splitlines():
        line = line.strip()
        if line and not line.startswith("#") and not line.startswith("<!--"):
            text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", line)
            text = re.sub(r"[*_`>]", "", text)
            return html.escape(text[:200])
    return ""


def build_page(meta: dict, body: str, image_map: dict) -> str:
    title = html.escape(meta.get("title", "Untitled"))
    date = html.escape(meta.get("date", ""))
    tags = html.escape(meta.get("tags", ""))
    summary = first_paragraph(body)
    content_html = convert_md(body, image_map)
    tags_meta = f'  <meta name="tags" content="{tags}">\n' if tags else ""

    return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <meta name="date" content="{date}">
  <meta name="summary" content="{summary}">
{tags_meta}  <link rel="icon" type="image/svg+xml" href="/public/favicon.svg">
  <style>
{STYLES}
  </style>
</head>
<body>
  <nav class="site-nav">
    <a href="/">← CoolGPU</a>
  </nav>
  <main class="content">
    <h1>{title}</h1>
    <p class="meta"><time datetime="{date}">{date}</time></p>

    {content_html}
  </main>
</body>
</html>
"""


def main() -> None:
    for post in POSTS:
        src = ROOT / post["src"]
        out = ROOT / post["out"]
        text = src.read_text(encoding="utf-8")
        meta, body = parse_frontmatter(text)
        page = build_page(meta, body, post["image_map"])
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(page, encoding="utf-8")
        print(f"✓ {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
