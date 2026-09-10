# ICMTA home page — final mockup spec

For Kishan. Everything below is settled and reflected in `icmta-home-mockup.html`.

---

## 1. What changed, and why

Every item was raised by Anand during review.

### Navigation

| # | Change | Why |
|---|---|---|
| 1 | Top nav cut from 10 items to 5 — **Home · About · Directory · Events · Membership** | Ten items is more than anyone scans |
| 2 | "Members ▾" dropdown deleted; **Directory** links straight to `public-directory.html` | The directory was two clicks from the front page |
| 3 | **Admin Login** removed from the public nav | Members don't need it; footer only |
| 4 | Our Initiatives, ICMTA Resources, Contact Us moved to the footer | Already linked from every page's footer |
| 5 | Dropdowns added to **About, Events, Membership** only | Home and Directory are destinations, not categories |
| 6 | Header layout kept exactly as approved — white bar, logo left, links right, gold underline on the active item, Sign in at the end | An alternative navy button-bar version was rejected |

**Second-level menus** (9 of the 12 are anchors on pages that already exist):

```
About        → Vision & Mission        about-us.html#vision
                Founders & Mentors      about-us.html#founders
                Our Initiatives         initiatives.html
                Code of Conduct         about-us.html#conduct
                Contact Us              contact.html

Events       → Upcoming Events         events.html#upcoming
                Past Events & Archives  events.html#past
                Call for Papers         events.html#cfp   (later)

Membership   → Why Join                membership.html#why
                Categories & Fees       membership.html#categories
                How to Apply            membership.html#apply
                Renew Membership        (needs login, later)
```

Items marked *later* are greyed and non-clickable — visible structure, no dead links.

### Page structure

| # | Change | Why |
|---|---|---|
| 7 | Order set as **About ICMTA → What's happening → Directory → What we do → Join** | The home page must not open with the directory |
| 8 | Hero is a write-up about the association; no search, no member list | It's a landing page |
| 9 | Search moved out of the hero into the Directory section | Same reason |
| 10 | **Spotlight** band added under the hero — two time-bound items | Borrowed from AIMA; keeps the page alive between conferences |
| 11 | Secretariat contact band **removed entirely** | Belongs on the contact page; the footer carries the email |
| 12 | Notices strip replaced by one *All events and notices →* link | Landing page points, doesn't contain |
| 13 | Expertise chips cut 10 → 6; five role boxes became one line of text | Same |
| 14 | Initiative cards cut 6 → 4, with *All ICMTA initiatives →* below them | Same |
| 15 | **Join band** rebuilt as a slim horizontal strip | Was three times taller than its content justified |
| 16 | **Fees removed from the home page** | They live on `membership.html`; one place to maintain |
| 17 | Section padding reduced 62px → 48px throughout | Page was too long |

### Search — two different things

| # | Change |
|---|---|
| 18 | **Site search** in the header — expands from the magnifier icon, searches pages: events, membership, resources |
| 19 | **Directory search** in the Directory section — labelled *Search the member directory*, button reads *Search 343 members* |

Labelling them differently matters: someone typing "membership fees" into the directory box gets nothing and concludes the site is broken.

### Identity and copy

| # | Change | Why |
|---|---|---|
| 20 | Palette extended with **gold `#c49b4b`**, sampled from Lahari's logo | The site used the logo's blue and ignored its gold |
| 21 | Seal moved from a side image to a **centred, fixed watermark** at 5.5% opacity | Visible the whole way down the page; the header already carries the logo |
| 22 | Headline reduced to `clamp(22px, 2.9vw, 33px)`, weight 600, on one line | Was too large and out of step with the section headings |
| 23 | Headline changed to **"Connecting Commerce and Management teachers across India"** | The old one restated the association's name |
| 24 | Eyebrow back to **"Built by academicians, for academicians"** | *Academicians / scholars / teachers* were three words for the same people in two lines |
| 25 | Every eyebrow/heading pair de-duplicated | *What's happening* over *Upcoming events*, and *What we do* over *Our initiatives*, each said one thing twice |
| 26 | *"See all six initiatives"* → *"All ICMTA initiatives →"*, moved below the cards | It named a count that contradicted what was on screen |
| 27 | **Students** deliberately not mentioned | No student membership category exists yet |
| 28 | Footer credit reads **"Logo and tagline by Lahari"** | *Connecting Excellence* is hers |

Final eyebrow/heading rule — the eyebrow is the category, the heading is the plain-English version:

```
Events            → What's happening
Member directory  → Find a resource person
Initiatives       → What we do
```

### Footer

| # | Change |
|---|---|
| 29 | **Quick links** column added, first after the brand |
| 30 | Links cut 16 → 11 across three columns; column gaps widened |
| 31 | Privacy notice and Administrator moved to the bottom bar |
| 32 | Newsletter signup added (AIMA); map **not** added — ICMTA has no campus to visit |

---

## 2. Verified before release

- Section order, all five nav items, all three dropdowns present
- `<div>` balance correct — one stray closing tag found and fixed
- All dead CSS from earlier drafts removed (`hero-grid`, `.roles`, `.notices`, `.fees`, `secretariat`, `contact-list`, `navmap`, `.seal`, navy nav bar)
- No horizontal overflow at 1440px or 390px — the Join buttons were overflowing on mobile and now wrap
- No JavaScript errors
- **Every number checked against the member database**: 343 members, 310 institutions, 26 states, 46 Professors, 22 Deans, 19 HoDs, 9 Principals, and all six expertise chip counts

---

## 3. Notes for implementation

**This is a mockup, not drop-in code.** It's a standalone file with its own CSS and the logo embedded as base64. Port the decisions into `css/style.css` and `index.html`; don't paste the file.

**Remove before going live:** the dark `.note` banner at the top of the page — it's a review annotation.

**The logo file is 807 KB at 1024×1024.** Use the 240px version supplied earlier (60 KB) for the header and footer.

**Site search needs an index.** For twelve pages, a JSON file of page titles and text built at deploy time is enough — no server, no service.

**Order of work:** nav and footer first (structural, low risk), then the palette in `style.css` (first change members will notice), then the home page sections.

Test on the staging copy before it goes live.
