#!/usr/bin/env python3

from __future__ import annotations

import subprocess
import email.utils
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path


# ---- config ----

SITE_TITLE = "Simone Lungarella"
SITE_URL = "https://simone-lungarella.github.io"
SITE_DESCRIPTION = "Notes, experiments, and thoughts."

MD_DIR = Path("md")
OUTPUT_FILE = Path("docs/feed.xml")


# ---- helpers ----

def read_front_matter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")

    if not text.startswith("---\n"):
        return {}

    end = text.find("\n---\n", 4)
    if end == -1:
        return {}

    raw = text[4:end]
    meta = {}

    for line in raw.splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip()] = value.strip().strip('"').strip("'")

    return meta


def parse_date(value: str) -> datetime:
    dt = datetime.strptime(value, "%Y-%m-%d")
    return dt.replace(tzinfo=timezone.utc)


def rfc822(dt: datetime) -> str:
    return email.utils.format_datetime(dt)


def article_url(md_path: Path) -> str:
    slug = md_path.stem
    return f"{SITE_URL}/articles/{slug}.html"


def render_html_fragment(md_path: Path) -> str:
    """
    Use pandoc to convert Markdown → HTML fragment (no full page)
    """
    result = subprocess.run(
        [
            "pandoc",
            str(md_path),
            "-t", "html",
            "--no-highlight",
        ],
        check=True,
        capture_output=True,
    )
    return result.stdout.decode("utf-8")


# ---- main ----

def main():
    articles = []

    for path in MD_DIR.glob("*.md"):
        meta = read_front_matter(path)

        title = meta.get("title")
        date_str = meta.get("date")

        if not title or not date_str:
            raise SystemExit(f"Missing title or date in {path}")

        date = parse_date(date_str)

        description = meta.get("description", "")

        html_content = render_html_fragment(path)

        articles.append({
            "title": title,
            "date": date,
            "date_str": date_str,
            "description": description,
            "url": article_url(path),
            "content": html_content,
        })

    # newest first
    articles.sort(key=lambda x: x["date"], reverse=True)

    # ---- RSS building ----

    rss = ET.Element(
        "rss",
        version="2.0",
        attrib={"xmlns:content": "http://purl.org/rss/1.0/modules/content/"},
    )

    channel = ET.SubElement(rss, "channel")

    ET.SubElement(channel, "title").text = SITE_TITLE
    ET.SubElement(channel, "link").text = SITE_URL + "/"
    ET.SubElement(channel, "description").text = SITE_DESCRIPTION
    ET.SubElement(channel, "language").text = "en"
    ET.SubElement(channel, "lastBuildDate").text = rfc822(datetime.now(timezone.utc))

    for a in articles:
        item = ET.SubElement(channel, "item")

        ET.SubElement(item, "title").text = a["title"]
        ET.SubElement(item, "link").text = a["url"]
        ET.SubElement(item, "guid").text = a["url"]
        ET.SubElement(item, "pubDate").text = rfc822(a["date"])

        if a["description"]:
            ET.SubElement(item, "description").text = a["description"]

        # full content (CDATA required)
        content = ET.SubElement(item, "content:encoded")
        content.text = f"<![CDATA[{a['content']}]]>"

    # pretty print
    tree = ET.ElementTree(rss)
    ET.indent(tree, space="  ", level=0)

    # write file
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    OUTPUT_FILE.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n',
        encoding="utf-8"
    )

    with OUTPUT_FILE.open("ab") as f:
        tree.write(f, encoding="utf-8", xml_declaration=False)

    print(f"Generated {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
