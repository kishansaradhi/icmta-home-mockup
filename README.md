# ICMTA — handover pack

Everything for the revised icmta.in. September 2026.

```
mockup/
  icmta-home-mockup.html      the approved home page mockup — open in a browser
  HOME-PAGE-SPEC.md           all 32 agreed changes. START HERE.
  final-desktop.png           full-page render, 1440px
  final-mobile.png            390px
  membership-pullquote.html   drop-in block for membership.html

site/
  icmta-site-cleaned.zip      the live site with cleanup steps 1-3 applied
  CLEANUP-CHANGES.txt         what those steps changed
  fix-nav.py                  the script that reduced the nav across all pages

assets/
  logo-240.png                header/footer logo, 60 KB  (the live one is 807 KB)
  logo-512.png                larger version if needed
  member-data.public.js       343 records, no contact details, 96 KB

earlier-work/
  schema.sql, icmta.db        SQLite schema and loaded database (343 members)
  load.js                     rebuilds the database from source
  BLUEPRINT.html              the backend/architecture plan
```

## Order of work

1. **Deploy `site/icmta-site-cleaned.zip`** to the staging copy first.
   Nav cut to five items across all 14 pages, three orphan duplicate pages
   removed, 92 images recompressed, 43 images set to lazy-load.
   Site size 31 MB → 18 MB. Upload the whole folder, not just the HTML.

2. **Read `mockup/HOME-PAGE-SPEC.md`.** It lists every change, why it was made,
   and the three rules that came out of review.

3. **Port the mockup into `css/style.css` and `index.html`.**
   The mockup is a standalone file with its own CSS and an embedded logo —
   do not paste it in. Take the decisions, not the file.

4. **Swap the logo** for `assets/logo-240.png` everywhere.

5. **Delete the dark `.note` banner** at the top of the mockup before anything
   goes live. It is a review annotation.

6. Test on staging, then publish.

## Two things that are not in the mockup

**Site search needs an index.** For twelve pages, a JSON file of page titles and
text built at deploy time is enough. No server, no service.

**`members.html` is now orphaned from the nav.** It is a landing page with three
cards and a button to the directory — an extra click in front of what people
want. Retire it or redirect it to `public-directory.html`.
