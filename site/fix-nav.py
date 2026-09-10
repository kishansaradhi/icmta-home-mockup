#!/usr/bin/env python3
"""
ICMTA — reduce the top navigation from 10 items to 5.

Replaces the <nav class="nav-links"> block in every page and sets the
"active" state from the filename. Everything removed from the nav is
already in the footer, so nothing becomes unreachable.

  Home · About Us · Directory · Events · Membership

Removed from the nav:
  Our Initiatives   -> footer
  ICMTA Resources   -> footer
  Contact Us        -> footer
  Admin Login       -> footer only. It was advertising a door
                       members do not need.
  Members ▾         -> dropdown deleted. "Directory" now links
                       straight to public-directory.html, which is
                       what people were looking for anyway.

Usage:  python3 fix-nav.py /path/to/site        (writes .bak files)
        python3 fix-nav.py /path/to/site --dry  (preview only)
"""

import re, sys, os, glob, shutil

NAV_ITEMS = [
    ("index.html",            "Home"),
    ("about-us.html",         "About Us"),
    ("public-directory.html", "Directory"),
    ("events.html",           "Events"),
    ("membership.html",       "Membership"),
]

# Pages that should light up a nav item other than their own filename.
ALIAS = {
    "members.html":        "public-directory.html",
    "member-profile.html": "public-directory.html",
    "faculty.html":        "public-directory.html",
    "our-initiatives.html": None,
    "initiatives.html":     None,
    "resources.html":       None,
    "icmt-resources.html":  None,
    "contact.html":         None,
    "contact-us.html":      None,
}

NAV_RE = re.compile(r'<nav class="nav-links">.*?</nav>', re.S)


def build_nav(current):
    rows = []
    for href, label in NAV_ITEMS:
        cls = "nav-item active" if href == current else "nav-item"
        rows.append(f'      <a href="{href}" class="{cls}">{label}</a>')
    return '<nav class="nav-links">\n' + "\n".join(rows) + "\n    </nav>"


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    dry = "--dry" in sys.argv
    changed = skipped = 0

    for path in sorted(glob.glob(os.path.join(root, "*.html"))):
        name = os.path.basename(path)
        html = open(path, encoding="utf-8").read()
        if not NAV_RE.search(html):
            print(f"  skip   {name}  (no nav block found)")
            skipped += 1
            continue

        current = ALIAS.get(name, name)
        new_html = NAV_RE.sub(lambda m: build_nav(current), html, count=1)

        if new_html == html:
            print(f"  same   {name}")
            continue

        if not dry:
            shutil.copyfile(path, path + ".bak")
            open(path, "w", encoding="utf-8").write(new_html)
        print(f"  {'would fix' if dry else 'fixed  '} {name}"
              f"{'  -> active: ' + current if current else ''}")
        changed += 1

    print(f"\n{changed} page(s) {'to change' if dry else 'updated'}, {skipped} skipped.")
    if not dry and changed:
        print("Originals saved as *.html.bak — delete them once you are happy.")


if __name__ == "__main__":
    main()
