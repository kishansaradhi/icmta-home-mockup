-- ICMTA — SQLite schema
-- 9 tables, 3 views. Sized for ~1000 members.
--
-- Contact rule: email and phone are stored in full. They are masked to
-- everyone except the owner and an admin, and the masking happens in the
-- database views — not in the browser. If the API sends the full value and
-- the page hides it, it is not masked.

PRAGMA foreign_keys = ON;      -- OFF by default in SQLite. Must be set per connection.
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 5000;

-- ---------------------------------------------------------------- lookups

CREATE TABLE state (
  code       TEXT PRIMARY KEY,          -- IN-KA
  label      TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

CREATE TABLE designation (
  code       TEXT PRIMARY KEY,          -- professor
  label      TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

CREATE TABLE expertise (
  code       TEXT PRIMARY KEY,          -- finance
  label      TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

-- ---------------------------------------------------------------- core

CREATE TABLE institution (
  institution_id INTEGER PRIMARY KEY,
  name           TEXT NOT NULL,
  city           TEXT,
  state_code     TEXT REFERENCES state(code),
  pincode        TEXT CHECK (pincode IS NULL OR pincode GLOB '[1-9][0-9][0-9][0-9][0-9][0-9]'),
  address        TEXT
);
CREATE INDEX ix_inst_state ON institution(state_code);
CREATE INDEX ix_inst_name  ON institution(name);

CREATE TABLE member (
  member_id        INTEGER PRIMARY KEY,
  member_no        TEXT UNIQUE NOT NULL CHECK (member_no GLOB 'ICMT[0-9][0-9][0-9][0-9][0-9]'),
  legacy_no        TEXT UNIQUE,
  title            TEXT CHECK (title IN ('Dr.','Prof.','Mr.','Mrs.','Ms.')),
  full_name        TEXT NOT NULL,
  institution_id   INTEGER REFERENCES institution(institution_id),
  department       TEXT,
  designation_code TEXT NOT NULL REFERENCES designation(code),
  qualifications   TEXT,                          -- "M.Com, MBA, Ph.D"

  -- Essential, stored in full, never sent unmasked to anyone but the owner
  -- or an admin. Email is UNIQUE where present: it is the only reliable
  -- guard against the same person being entered twice.
  email            TEXT UNIQUE,
  phone            TEXT CHECK (phone IS NULL OR phone GLOB '+[0-9]*'),
  whatsapp         TEXT,

  photo_path       TEXT,
  membership_type  TEXT NOT NULL DEFAULT 'legacy'
                     CHECK (membership_type IN ('life','annual','scholar','institutional','legacy')),
  membership_status TEXT NOT NULL DEFAULT 'pending'
                     CHECK (membership_status IN ('pending','active','lapsed','resigned')),
  member_since     TEXT,                          -- YYYY-MM-DD
  valid_till       TEXT,                          -- NULL for life members
  is_listed        INTEGER NOT NULL DEFAULT 1,    -- shown in the directory at all
  notes            TEXT,
  created_at       TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX ix_member_name   ON member(full_name);
CREATE INDEX ix_member_inst   ON member(institution_id);
CREATE INDEX ix_member_desig  ON member(designation_code);
CREATE INDEX ix_member_status ON member(membership_status);

CREATE TRIGGER trg_member_updated AFTER UPDATE ON member
BEGIN
  UPDATE member SET updated_at = datetime('now') WHERE member_id = NEW.member_id;
END;

-- The reason the directory exists: finding a resource person by subject.
CREATE TABLE member_expertise (
  member_id      INTEGER NOT NULL REFERENCES member(member_id) ON DELETE CASCADE,
  expertise_code TEXT    NOT NULL REFERENCES expertise(code),
  PRIMARY KEY (member_id, expertise_code)
);
CREATE INDEX ix_mex_code ON member_expertise(expertise_code);

-- ---------------------------------------------------------------- login

CREATE TABLE user_account (
  user_id       INTEGER PRIMARY KEY,
  member_id     INTEGER UNIQUE REFERENCES member(member_id),
  login_email   TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member','admin')),
  status        TEXT NOT NULL DEFAULT 'invited' CHECK (status IN ('invited','active','suspended')),
  last_login    TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ---------------------------------------------------------------- content

CREATE TABLE announcement (
  announcement_id INTEGER PRIMARY KEY,
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  kind            TEXT NOT NULL DEFAULT 'notice'
                    CHECK (kind IN ('notice','event','circular','conference','obituary')),
  is_public       INTEGER NOT NULL DEFAULT 1,     -- 0 = members only
  is_pinned       INTEGER NOT NULL DEFAULT 0,
  published_at    TEXT NOT NULL DEFAULT (datetime('now')),
  expires_on      TEXT,
  posted_by       TEXT,
  attachment_path TEXT
);
CREATE INDEX ix_ann_live ON announcement(is_public, published_at DESC);

-- ---------------------------------------------------------------- money

CREATE TABLE payment (
  payment_id   INTEGER PRIMARY KEY,
  member_id    INTEGER NOT NULL REFERENCES member(member_id),
  -- The gateway's payment id. UNIQUE so a retried webhook cannot charge or
  -- credit the same payment twice. This one line is the whole guard.
  gateway_ref  TEXT UNIQUE,
  amount_paise INTEGER NOT NULL CHECK (amount_paise > 0),
  currency     TEXT NOT NULL DEFAULT 'INR',
  method       TEXT CHECK (method IN ('upi','card','netbanking','neft','cheque','cash','waiver')),
  status       TEXT NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','paid','failed','refunded')),
  paid_on      TEXT,
  covers_till  TEXT,                              -- renewal period this paid for
  remarks      TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX ix_pay_member ON payment(member_id);

-- ---------------------------------------------------------------- views
-- Three levels of access. The API picks the view; it never selects from
-- `member` directly except for the owner's own row or for an admin.

-- 1. Anonymous visitors. No contact columns exist in this view at all,
--    so there is nothing to leak even by accident.
CREATE VIEW v_public AS
SELECT
  m.member_id,
  m.member_no,
  TRIM(COALESCE(m.title,'') || ' ' || m.full_name) AS name,
  d.label      AS designation,
  m.department,
  i.name       AS institution,
  i.city,
  s.label      AS state,
  m.photo_path
FROM member m
JOIN designation d ON d.code = m.designation_code
LEFT JOIN institution i ON i.institution_id = m.institution_id
LEFT JOIN state s ON s.code = i.state_code
WHERE m.is_listed = 1;

-- 2. Signed-in members. Contact shown masked — enough to confirm it exists
--    and to recognise your own, not enough to harvest.
--    +919440121943  ->  +91944••••43
--    sathish@gmail.com -> sa•••@gmail.com
CREATE VIEW v_member AS
SELECT
  p.*,
  CASE WHEN m.email IS NULL THEN NULL ELSE
    substr(m.email,1,2) || '•••' || substr(m.email, instr(m.email,'@'))
  END AS email_masked,
  CASE WHEN m.phone IS NULL THEN NULL ELSE
    substr(m.phone,1,6) || '••••' || substr(m.phone,-2)
  END AS phone_masked,
  (SELECT group_concat(e.label, ', ')
     FROM member_expertise me JOIN expertise e ON e.code = me.expertise_code
    WHERE me.member_id = m.member_id) AS expertise,
  m.qualifications
FROM v_public p
JOIN member m ON m.member_id = p.member_id;

-- 3. Owner and admin. Full contact. The API must supply the viewer's own
--    member_id, or 0 with an admin session:
--      SELECT * FROM v_full WHERE :is_admin = 1 OR member_id = :viewer_id;
CREATE VIEW v_full AS
SELECT
  p.*,
  m.email,
  m.phone,
  m.whatsapp,
  m.qualifications,
  m.membership_type,
  m.membership_status,
  m.member_since,
  m.valid_till,
  (SELECT group_concat(e.label, ', ')
     FROM member_expertise me JOIN expertise e ON e.code = me.expertise_code
    WHERE me.member_id = m.member_id) AS expertise
FROM v_public p
JOIN member m ON m.member_id = p.member_id;
