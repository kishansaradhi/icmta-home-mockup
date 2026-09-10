# How to apply this — step by step

Four files. Nothing existing is deleted; the new CSS loads after `style.css`
and overrides it. To revert, remove one `<link>` line.

---

## Step 1 — add the stylesheet

Copy `icmta-2026.css` into `css/`.

Then in **every** `.html` page, immediately after the existing style.css line:

```html
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/icmta-2026.css">   <!-- add this -->
```

And add the fonts, in `<head>`:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,300;0,400;0,700;1,400&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600;8..60,700&display=swap" rel="stylesheet">
```

Nothing will look different yet except the header turning white and the
footer turning dark. That is expected — see section 2a of the CSS.

## Step 2 — replace the header on every page

Use `header-snippet.html`. It replaces **both** the old
`<div class="site-welcome-banner">` **and** the `<header class="header">`
block.

Change only which `nav-item` carries `class="active"`:

| Page | Active item |
|---|---|
| index.html | Home |
| about-us.html | About |
| public-directory.html, members.html, member-profile.html, faculty.html | Directory |
| events.html | Events |
| membership.html | Membership |
| everything else | none |

## Step 3 — replace the footer on every page

Use `footer-snippet.html`. Identical on all pages, nothing to change.

## Step 4 — replace index.html

Use the supplied `index.html` wholesale.

Add `<div class="icm-watermark" aria-hidden="true"></div>` as the first
element after `<body>` on any other page where you want the seal watermark.
Leave it off the directory and admin pages — it competes with tables.

---

## Anchors the dropdowns expect

The menus link to sections that need `id` attributes adding:

| Page | Add these ids |
|---|---|
| about-us.html | `#vision`, `#founders`, `#conduct` |
| events.html | `#upcoming`, `#past` |
| membership.html | `#why`, `#categories`, `#apply` |

For example: `<div class="section-block" id="why">`.

Until they exist the links still work — they just land at the top of the page.

## Still to build

**Site search** posts to `search.html?q=…`, which does not exist yet.
Either build it against a small JSON index of page text, or point the form
at Google with `site:icmta.in` until then.

**Newsletter form** posts nowhere. Wire it to whatever list you use, or
remove the form and leave the social icons.

**Directory search and the expertise chips** link to
`public-directory.html?q=…` and `?expertise=…`. The directory page needs to
read those query parameters on load and apply them as filters.

---

## Verified

Rendered at 1440px and 390px against the real `style.css` and the real image
files: no horizontal overflow, no console errors, no broken image or link
references, all three dropdowns present, all figures matching the member
database.
