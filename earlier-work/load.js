#!/usr/bin/env node
// Builds icmta.db from the cleaned 343 records. node load.js [modelDir]
const fs = require("fs"), path = require("path"), cp = require("child_process");
const MODEL = process.argv[2] || "/home/claude/icmt-data-model";
const rd = f => JSON.parse(fs.readFileSync(f, "utf8"));
const V = f => rd(path.join(MODEL, "vocab", f));
const O = f => rd(path.join(MODEL, "out", f));

const q = v => (v === null || v === undefined || v === "" ? "NULL"
  : "'" + String(v).replace(/'/g, "''") + "'");

const members = O("members.json").filter(m => m.provenance.sourceBatch.startsWith("legacy-"));
const insts = O("institutions.json");
const L = [];

L.push("PRAGMA foreign_keys=ON;", "BEGIN;");

for (const t of V("states.json").terms)
  L.push(`INSERT INTO state VALUES(${q(t.code)},${q(t.label)},${t.sortOrder});`);
for (const t of V("designations.json").terms)
  L.push(`INSERT INTO designation VALUES(${q(t.code)},${q(t.label)},${t.sortOrder});`);
for (const t of V("expertise.json").terms)
  L.push(`INSERT INTO expertise VALUES(${q(t.code)},${q(t.label)},${t.sortOrder});`);

for (const i of insts) {
  const id = +i.institutionId.replace(/\D/g, "");
  L.push(`INSERT INTO institution VALUES(${id},${q(i.name)},${q(i.address.city)},${q(i.address.stateCode)},${q(i.address.pincode)},${q(i.address.line)});`);
}

for (const m of members) {
  const id = +m.memberId.replace(/\D/g, "");
  const inst = m.affiliation.institutionId ? +m.affiliation.institutionId.replace(/\D/g, "") : null;
  L.push(`INSERT INTO member (member_id,member_no,legacy_no,title,full_name,institution_id,department,designation_code,qualifications,email,phone,whatsapp,photo_path,membership_type,membership_status,is_listed) VALUES(` +
    `${id},${q(m.memberId)},${q(m.legacyMemberId)},${q(m.person.title)},${q(m.person.fullName)},` +
    `${inst === null ? "NULL" : inst},${q(m.affiliation.department)},${q(m.affiliation.designationCode)},` +
    `${q(m.academic.qualifications.join(", "))},${q(m.contact.professionalEmail)},` +
    `${q(m.contact.mobile[0] || null)},${q(m.contact.whatsapp[0] || null)},` +
    `${q(m.photo ? m.photo.path : null)},'legacy','pending',1);`);
  for (const e of m.academic.expertise)
    L.push(`INSERT INTO member_expertise VALUES(${id},${q(e)});`);
}

// A couple of announcements so the page has something to render on day one.
L.push(`INSERT INTO announcement (title,body,kind,is_public,is_pinned,posted_by) VALUES(
  'National Seminar — Siddhartha Academy, 2026',
  'Registration is open for the national seminar. Details and the concept note are attached.',
  'conference',1,1,'Secretariat');`);
L.push(`INSERT INTO announcement (title,body,kind,is_public,posted_by) VALUES(
  'Member directory now searchable by expertise',
  'Members can be found by research area, designation and state. Sign in to view contact details.',
  'notice',1,'Secretariat');`);

L.push("COMMIT;");
fs.writeFileSync(path.join(__dirname, "data.sql"), L.join("\n"));

const db = path.join(__dirname, "icmta.db");
fs.rmSync(db, { force: true });
cp.execSync(`sqlite3 ${db} < ${path.join(__dirname, "schema.sql")}`);
cp.execSync(`sqlite3 ${db} < ${path.join(__dirname, "data.sql")}`);
console.log("built", db, (fs.statSync(db).size / 1024).toFixed(0) + " KB");
