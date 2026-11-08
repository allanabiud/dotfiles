#!/usr/bin/env python3
"""
Organize unsorted music tracks into ~/Music/Library/Music
matching MusicBrainz Picard's Preset 2 naming scheme and rules:
  ~/Music/Library/Music/<Album Artist>/[<Year>] <Album>/<Track> - <Title>.mp3
  ~/Music/Library/Music/<Album Artist>/[<Year>] <Album>/Disc 01/<Track> - <Title>.mp3  (multi-disc)
  ~/Music/Library/Music/<Album Artist>/[<Year>] <Album>/cover.jpg

Features:
- Sourcing/scraping missing metadata online via iTunes Search API and Deezer fallback.
- Confident-match override (Picard-style clear + apply): a near-exact catalog match
  (title similarity >= 0.85 AND artist >= 0.70) replaces wrong existing tags and takes
  artwork priority; weaker matches only fill fields that are missing.
- DuckDuckGo web fallback: when iTunes/Deezer leave fields empty (niche/YouTube-era
  tracks their catalogs lack), snippet-mined release date/album/genre fill the gaps -
  fill-only, never overwriting an existing tag. Disabled together with --no-online.
- Fetching and formatting high-resolution cover art (strictly >=1200px, standardized to 1200x1200px).
- Embedding 1200x1200px cover art into APIC and saving cover.jpg (always at the album root).
- Enforcing strictly ID3v2.4.0 tags with legacy ID3v1 tags stripped.
- Applying Picard's "Remove junk tags" script (purging comments, downloader tags, encoder info, BPM, key, etc.).
  MusicBrainz frames are KEPT by the pipeline (Album/Artist/Album Artist/Release
  Track Id, Album Status, UFID - only the three MB ids their Picard script itself
  deletes count as junk); full MB removal happens solely via --purge-mb.
- Applying Picard's "One album artist" rule (extracting single primary album artist).
- Dynamic Library Indexing to match Picard's Unicode hyphens and canonical casing.
- Stripping featuring credits ("feat.", "ft.", "featuring", "(with ...)") from album and
  track titles, because MusicBrainz/Picard never carries them in TALB/TIT2.
- Multi-disc support: when totaldiscs > 1, tracks go into a "Disc NN" subfolder, exactly
  like Picard Preset 2's $if($gt(%totaldiscs%,1),Disc $num(%discnumber%,2)/).
- --migrate-discs: one-time pass that moves already-tagged library tracks into disc folders.
- --source accepts a single .mp3 file (processed alone) as well as a folder; when the
  destination equals the source (a library file) tags are written in place, no move.
- Manual last-resort prompt: when iTunes, Deezer AND the web tier all find nothing
  (TTY only, disable with --no-prompt), ask for the essential tags (Title, Artist,
  Album artist, Album, Year, Original year, Track, Disc, Genre) with current values
  as [defaults] - opt-in afterwards for composer/label/ISRC/copyright. Entered values
  flow through the same cleanup pipeline and are saved strictly as ID3v2.4.
- Multi-value TPE1: artist credits are written like Picard's $setmulti(artist, all)
  ("A & B feat. C" -> three TPE1 values), serialized ID3v2.4-style - ONE frame,
  values null-joined ("Alice\0Bob") - so players show "Artist 1 | Artist 2".
  Credit lists split on "; ", ", ", " & ", " + ", "/" and feat markers; singular
  acts whose own name carries a separator (Jack & Jack, Lucas & Steve,
  Royal & the Serpent, ac/dc, AR/CO ...) stay ONE value via KNOWN_ENSEMBLES, and a
  credit equal to the album artist/artist folder is never split. A richer
  title-prefix credit upgrades (never downgrades) an existing TPE1.
- Normalize-on-save: every main-pipeline save re-checks a single-value TPE1 and
  splits it under the same guards, so the library converges to Picard's
  multi-value form as files are reprocessed. --fetch-covers and --purge-mb keep
  their text-tags-untouched contracts and never normalize.
- --split-artists: one-time harmonize pass over --source (a track or folder
  anywhere): rewrites legacy raw credits ("A; B", "A, B") into proper
  null-separated multi-values. Dry run by default with a before->after table;
  --execute writes strictly ID3v2.4 and touches nothing but the TPE1 frame.
- --fetch-covers: art-only pass over the library - promotes 'Disc NN/cover.jpg' to
  the album root, deletes byte-identical per-disc duplicates, and (online) fetches
  higher-res album covers (iTunes album search, Deezer fallback) gated on album +
  artist similarity, accepted only when strictly larger, previewed in the system
  image viewer behind a y/N confirmation (--auto to skip the prompt). Text tags are
  never rewritten; the only MP3 write is the APIC frame of an accepted upgrade.
  Scope the pass with --source pointing at an album/artist folder or an .mp3 inside
  the library; a scoped dry run fetches and opens the candidate for inspection but
  applies nothing (the preview image is kept on disk and its path printed).
- --purge-mb: opt-in MusicBrainz-tag removal - points --source at any track or folder
  (searched recursively) and strips every 'MusicBrainz'-bearing TXXX frame plus the
  UFID MIDI-trigger frames, leaving all other tags, artwork, audio and file names
  untouched. Dry run by default (prints every frame it would remove); add --execute
  to write, strictly ID3v2.4.
"""

import os
import sys
import glob
import shutil
import argparse
import csv
import hashlib
import urllib.request
import urllib.parse
import json
import re
import io
import time
import tempfile
import subprocess
import html
import unicodedata
from difflib import SequenceMatcher
from PIL import Image

import mutagen
from mutagen.id3 import (ID3, TIT2, TPE1, TPE2, TALB, TDRC, TDOR, TXXX, TRCK, TPOS,
                          TCON, TCOM, TPUB, TSRC, TCOP, APIC)

DEFAULT_SOURCE_DIR = os.path.expanduser("~/Music/TO-SORT")
DEFAULT_LIBRARY_DIR = os.path.expanduser("~/Music/Library/Music")

KNOWN_ENSEMBLES = {
    "various artists",
    "ac/dc",
    "mumford & sons",
    "jack & jack",
    "lucas & steve",
    "nico & vinz",
    "gamper & dadoni",
    "selena gomez & the scene",
    # Singular artists whose OWN name contains a credit separator - a split would
    # butcher them. Library-proven (folders, TPE2 or Picard multi-values carry them
    # whole) plus famous ones their patterns predict.
    "royal & the serpent",
    "matisse & sadko",
    "ar/co",
    "au/ra",
    "dimitri vangelis & wyman",
    "lilly wood & the prick",
    "lush & simon",
    "vargas & lagola",
    "zion & lennox",
    "earth, wind & fire",
    "florence + the machine",
    "hall & oates",
    "simon & garfunkel",
    "crosby, stills & nash",
}

def sanitize_component(val: str) -> str:
    """Sanitize directory/file component matching Picard's win_compat rules."""
    s = str(val).strip()
    s = s.replace(":", "_")
    for ch in ['"', '*', '<', '>', '?', '|', '/', '\\']:
        s = s.replace(ch, "_")
    while "  " in s:
        s = s.replace("  ", " ")
    s = s.strip(" ")
    if s.endswith("."):
        s = s[:-1] + "_"
    return s

def clean_search_term(text: str) -> str:
    """Clean text to optimize search engine matching."""
    text = str(text).replace("\x00", " ")   # multi-value frame joins must never query
    text = re.sub(r"\.(?:mp3|flac|m4a|ogg|wav)$", "", text, flags=re.I)
    text = re.sub(r"^\d+\s*[-.]\s*", "", text)
    text = re.sub(r"[\(\[](?:official|lyrics?|video|audio|visualizer|remastered?)[\)\]]", "", text, flags=re.I)
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def normalize_artist_key(s: str) -> str:
    """Normalize artist name for fuzzy/unicode/case comparison."""
    s = unicodedata.normalize("NFKC", str(s))
    s = s.replace("‐", "-").replace("–", "-").replace("—", "-").replace("−", "-")
    s = s.replace("’", "'").replace("‘", "'")
    s = re.sub(r"\s+", " ", s).strip().lower()
    return s

def build_library_artist_index(library_dir: str):
    """Build a mapping from normalized artist name to exact existing folder name in Library."""
    index = {}
    if os.path.exists(library_dir):
        for entry in os.listdir(library_dir):
            full = os.path.join(library_dir, entry)
            if os.path.isdir(full):
                norm = normalize_artist_key(entry)
                index[norm] = entry
    return index

def extract_single_album_artist(raw_artist: str) -> str:
    """Extract single primary album artist matching Picard's 'One album artist' rule."""
    s = str(raw_artist).strip()
    if s.lower() in KNOWN_ENSEMBLES:
        return s

    for sep in (";", "\x00", "/"):
        if sep in s:
            s = s.split(sep)[0].strip()

    s = re.split(r"\s+(?:feat\.?|ft\.?|featuring|with)\s+", s, flags=re.IGNORECASE)[0].strip()

    if "," in s and s.lower() not in KNOWN_ENSEMBLES:
        s = s.split(",")[0].strip()

    if " & " in s and s.lower() not in KNOWN_ENSEMBLES:
        s = s.split(" & ")[0].strip()

    return s

def _int_str(v) -> str:
    """Normalize a tag/API value to a plain integer string, or '' when unusable."""
    try:
        return str(int(str(v).strip()))
    except (TypeError, ValueError):
        return ""

# Parenthesized credit: "(feat. X)", "(ft. X)", "(featuring X)", "(with X)"
FEAT_PAREN_RE = re.compile(
    r"\s*[(\[]\s*(?:feat\.?|ft\.?|featuring|with)\s+[^\])]*[\])]",
    flags=re.IGNORECASE,
)
# Inline credit: "X feat. Y - Title", "Title feat. Y", stopping before " - ", a bracket or EOL
FEAT_INLINE_RE = re.compile(
    r"\s*\b(?:feat\.?|ft\.?|featuring)\s+.*?(?=\s-\s|\s*[(\[]|\s*$|$)",
    flags=re.IGNORECASE,
)
DISC_DIR_RE = re.compile(r"^Disc \d+$")

# Artist-credit splitting: Picard (ID3v2.4) stores every credited artist as its own
# value inside ONE TPE1 frame, serialized null-separated ("Alice\0Bob") - players
# render that as "Artist 1 | Artist 2". Source metadata predates that: ID3v2.3-era
# tags misused ";" and "/" as list separators, so those arrive as ONE raw string.
# Feat marker must be whitespace-preceded ("A feat. B", "A (feat. B)") and must end in
# "." or a space, so words like "Swift" or "Features" never split mid-name.
FEAT_CREDIT_SPLIT_RE = re.compile(r"\s+\(?(?:featuring|feat|ft)(?:\.|\s)\s*\)?",
                                  flags=re.IGNORECASE)
# Credit-list separators between artists ("A; B", "A, B"). ';' never occurs inside a
# name; ',' is guarded by KNOWN_ENSEMBLES and the album-artist equality rule.
CREDIT_LIST_SPLIT_RE = re.compile(r"\s*;\s*|\s*,\s*")
# Collaboration separators between artists ("A & B", "A + B", "A / B"). Note "\" is
# deliberately NOT a separator - no split can ever touch a backslash artist name.
# Singular acts whose own name contains one of these ("ac/dc", "Royal & the Serpent")
# are protected by KNOWN_ENSEMBLES (checked around every split below).
COLLAB_SPLIT_RE = re.compile(r"\s*&\s*|\s*\+\s*|\s*/\s*")

# Separator inside a filename-style "Artist - Title" title (ASCII and unicode dashes)
TITLE_SEP_RE = re.compile(r"\s[-‐–—]\s")

def _prefix_matches_artist(prefix: str, hints) -> bool:
    """True when `prefix` is exactly an artist, or an artist plus a list separator."""
    p = normalize_artist_key(prefix)
    if not p:
        return False
    for hint in hints:
        a = normalize_artist_key(hint)
        if not a:
            continue
        if p == a:
            return True
        remainders = []
        if p.startswith(a):
            remainders.append(p[len(a):])
        if a.startswith(p):
            remainders.append(a[len(p):])
        for rest in remainders:
            # "artist & x", "artist, x", "artist feat. x", "artist ft x", ...
            if re.match(r"^\s*[&,+/|]", rest) or re.match(r"^\s+(?:feat\.?|ft\.?|featuring|with)\b", rest):
                return True
    return False

def split_artist_prefix(title: str, artist_hints) -> tuple:
    """Split a filename-style "Artist - Title" TIT2 into (title, artist_credit).

    Ripped files often store the whole "Artist - Title" filename inside the title tag,
    while MusicBrainz/Picard titles never contain the artist. The split only happens when
    the text before a separator matches a known artist (track/album artist tag or source
    folder), so genuine titles containing " - " are left alone. Returns
    (original_title, "") when no artist-like prefix is found.
    """
    if not title or not artist_hints:
        return title, ""
    for m in TITLE_SEP_RE.finditer(title):
        prefix = title[:m.start()].strip()
        rest = title[m.end():].strip()
        if prefix and rest and _prefix_matches_artist(prefix, artist_hints):
            return rest, prefix
    return title, ""

def split_artist_credit(value) -> list:
    """Split an artist credit into Picard-style multi-value TPE1 entries.

    Picard writes every credited artist as its own value inside one ID3v2.4 frame
    (null-serialized: "Alice\\0Bob"), e.g. ['G‐Eazy', 'Marc E. Bassy'], so source
    separators ("; ", ", ", " & ", " + ", "/" and feat markers) become separate
    values here too. Singular acts whose OWN name contains a separator
    ("Royal & the Serpent", "ac/dc", "AR/CO", "Lilly Wood & The Prick") stay ONE
    value via KNOWN_ENSEMBLES - checked at every level: whole credit, feat segment,
    list piece. Already-multi values pass through untouched (idempotent).
    """
    if isinstance(value, (list, tuple)):
        return [str(v).strip() for v in value if str(v).strip()]
    s = str(value).strip()
    if not s:
        return []
    if normalize_artist_key(s) in KNOWN_ENSEMBLES:
        return [s]
    parts = []
    for seg in FEAT_CREDIT_SPLIT_RE.split(s):
        seg = seg.strip().strip("()[]").strip()
        if not seg:
            continue
        if normalize_artist_key(seg) in KNOWN_ENSEMBLES:
            parts.append(seg)
            continue
        for piece in CREDIT_LIST_SPLIT_RE.split(seg):
            piece = piece.strip().strip("()[]").strip()
            if not piece:
                continue
            if normalize_artist_key(piece) in KNOWN_ENSEMBLES:
                parts.append(piece)
                continue
            parts.extend(p.strip() for p in COLLAB_SPLIT_RE.split(piece) if p.strip())
    return parts or [s]


def normalized_tpe1_values(current, guard_texts) -> list:
    """Multi-value rewrite for a single-value TPE1 frame, or None to leave it alone.

    Returns the proper ID3v2.4 multi-value list when `current` holds exactly one
    value that splits into several artists - unless the whole credit equals one of
    `guard_texts` (the album artist / artist folder: a credit identical to the
    album artist is ONE act, e.g. an unlisted duo headlining its own album).
    Already-multi frames, plain single names, ensembles (inside the split) and
    guard matches all return None so callers never touch the frame.
    """
    if current is None:
        return None
    vals = [str(v).strip() for v in current.text if str(v).strip()]
    if len(vals) != 1:
        return None
    credit = vals[0]
    parts = split_artist_credit(credit)
    if len(parts) <= 1:
        return None
    ck = normalize_artist_key(credit)
    for g in guard_texts:
        if not g:
            continue
        gk = normalize_artist_key(g)
        # folder names sanitize '/' to '_' ("ac_dc"), credit keeps it ("ac/dc")
        if ck == gk or ck.replace("/", "_") == gk:
            return None
    return parts


def artist_folder_name(path: str) -> str:
    """Album-artist folder for a track path, or '' when the layout has no album dir.

    '<Artist>/<Album>/[Disc NN/]<file>' -> '<Artist>'; flat layouts (inbox files,
    loose tracks) return '' so guards never compare against a bogus folder.
    """
    album_dir = os.path.dirname(os.path.abspath(path))
    if re.match(r"^Disc \d+$", os.path.basename(album_dir), re.I):
        album_dir = os.path.dirname(album_dir)
    if not re.match(r"^\[\d{4}\]", os.path.basename(album_dir)):
        return ""   # no year-bracket album folder -> not a library album layout
    parent = os.path.dirname(album_dir)
    return os.path.basename(parent) if parent else ""

def _credit_is_richer(current: str, credit: str) -> bool:
    """True when `credit` is `current` plus additional artists - never fewer.

    Ripped files often keep only the primary artist in TPE1 while the title prefix
    holds the full credit; Picard keeps everyone, so a richer credit must UPGRADE
    TPE1 ("K-391" -> "K-391 & Diviners feat. Anna Yvette") while an already-correct
    or richer TPE1 is never downgraded to a shorter credit.
    """
    if not credit:
        return False
    if not current:
        return True
    c = normalize_artist_key(current)
    n = normalize_artist_key(credit)
    if c == n or not n.startswith(c):
        return False
    rest = n[len(c):]
    # credit must continue with an artist-list separator: "current & x", "current, x",
    # "current feat. x", ...
    return bool(re.match(r"^\s*[&,+/|]", rest)
                or re.match(r"^\s+(?:feat\.?|ft\.?|featuring|with)\b", rest))

def fold_artist_casing(artist: str, library_artist_index) -> str:
    """Fold a credit to the library's existing casing, component by component.

    New files must never disagree with already-sorted tracks ("Ten Times" vs the
    existing folder "TEN TIMES"). Only pure CASE differences are folded; unicode
    character differences (folder "K‐391" vs credit "K-391") are deliberately
    never adopted, so files keep their exact spelling.
    """
    if not artist or not library_artist_index:
        return artist
    folded, changed = [], False
    for comp in split_artist_credit(artist):
        canon = library_artist_index.get(normalize_artist_key(comp))
        if canon and canon != comp and canon.casefold() == comp.casefold():
            folded.append(canon)
            changed = True
        else:
            folded.append(comp)
    if not changed:
        return artist
    return folded[0] if len(folded) == 1 else " & ".join(folded)

def strip_featuring(text: str) -> str:
    """Remove featuring credits from a title/album the way Picard's MusicBrainz data looks.

    Picard never writes "feat." into TALB/TIT2 (credits live in artist tags only), so
    scraped/legacy metadata is cleaned the same way to keep the library consistent.
    Never returns an empty string: if nothing would remain, the original is kept.
    """
    s = str(text).strip()
    if not s:
        return s
    original = s
    s = FEAT_PAREN_RE.sub("", s)
    s = FEAT_INLINE_RE.sub("", s)
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\s+([)\]])", r"\1", s)   # no space before a closing bracket
    s = re.sub(r"[(\[]\s*[)\]]", "", s)   # drop brackets left empty
    s = re.sub(r"\s+", " ", s)
    s = s.strip(" \t,;-")
    return s if s else original

def is_junk_tag(k: str) -> bool:
    """Check if tag is a junk, DJ/analysis, or redundant tag matching Picard's scripts."""
    k_upper = k.upper()
    if (k.startswith("COMM") or k == "TIT3" or k in ("TSSE", "TENC")
            or "MAJOR_BRAND" in k_upper or "MINOR_VERSION" in k_upper
            or "COMPATIBLE_BRANDS" in k_upper or "ASIN" in k_upper
            or "CATALOGNUMBER" in k_upper or "DESCRIPTION" in k_upper):
        return True
    # Downloader/source junk that arrives as TXXX frames rather than COMM frames
    # (Picard's "Remove junk tags" does $delete(comment) / $delete(encoder), and its
    # own output never contains these - verified against the library).
    if k_upper in ("TXXX:COMMENT", "TXXX:ENCODER", "TXXX:SYNOPSIS", "TXXX:PURL", "TXXX:USLT"):
        return True
    # Raw unsynchronised-lyrics frames ("USLT:desc:eng"): this library never keeps
    # wanted lyrics, so every USLT frame - empty or not - is junk. TXXX:USLT above
    # stays: its key prefix is TXXX, not USLT.
    if k_upper.startswith("USLT"):
        return True
    if k_upper in ("TBPM", "TKEY", "TXXX:BPM", "TXXX:KEY") \
            or "KEY_SCALE" in k_upper or "INITIALKEY" in k_upper:
        return True
    if (k_upper in ("TSO2", "TSOP", "TSOT", "TSOA", "TMED", "TXXX:MEDIA")
            or "ARTISTS" in k_upper or "SCRIPT" in k_upper
            or "ALBUMARTISTSORT" in k_upper or "ARTISTSORT" in k_upper
            or "RELEASETYPE" in k_upper or "RELEASECOUNTRY" in k_upper):
        return True
    # MusicBrainz extras their own Picard "Remove junk tags" script deletes. Proven
    # against the post-reimport library: Release Group/Work/Disc Id appear on 0
    # files, while Release Track Id survives on all 1063 - so Release Track Id is
    # NOT junk (it used to be flagged here; the pipeline would have stripped a
    # frame their Picard deliberately writes). Tolerate spaced and underscored
    # spellings of the three deleted ids.
    kn = re.sub(r"[\s_]", "", k_upper)
    if ("MUSICBRAINZRELEASEGROUPID" in kn or "MUSICBRAINZWORKID" in kn
            or "MUSICBRAINZDISCID" in kn):
        return True
    return False

def find_paired_image(audio_path: str) -> str:
    """Find the exact or corresponding image file for an audio track."""
    adir = os.path.dirname(audio_path)
    abase = os.path.splitext(os.path.basename(audio_path))[0]

    cand = os.path.join(adir, abase + ".jpg")
    if os.path.exists(cand):
        return cand

    for name in ("cover.jpg", "cover.png", "folder.jpg", "folder.png"):
        cand = os.path.join(adir, name)
        if os.path.exists(cand):
            return cand

    # glob.escape: audio folders can contain literal '[2019]' brackets, which glob
    # would otherwise parse as a character class and match nothing.
    jpgs = (glob.glob(os.path.join(glob.escape(adir), "*.jpg"))
            + glob.glob(os.path.join(glob.escape(adir), "*.png")))
    if jpgs:
        return jpgs[0]

    return None

def match_similarity(q_title: str, q_primary_artist: str, q_raw_artist: str, cand_title: str, cand_artist: str):
    """Compute (t_sim, a_sim) between a query and a catalog candidate.

    Both sides are normalised the way this library stores data - featuring credits
    removed from titles, single album artist extracted - so a catalog entry like
    'Just a Little (feat. Melanie Wehbe)' by 'Hogland' scores as an exact match for
    the stored 'Just a Little' by 'Hogland' instead of being pushed below the
    confidence gate by credit text that this pipeline strips anyway.
    """
    t_sim = SequenceMatcher(None, strip_featuring(q_title).lower(),
                            strip_featuring(clean_search_term(cand_title)).lower()).ratio()
    c_artist = extract_single_album_artist(clean_search_term(cand_artist))
    a_target = q_primary_artist if q_primary_artist else clean_search_term(q_raw_artist)
    a_sim = SequenceMatcher(None, a_target.lower(), c_artist.lower()).ratio()
    return t_sim, a_sim

def strip_release_suffix(album: str) -> str:
    """Drop storefront release-type suffixes ('X - Single', 'X - EP').

    Apple's catalog appends these to singles; MusicBrainz/Picard - and every album
    folder already in this library - use the plain release title.
    """
    return re.sub(r"\s+-\s+(?:Single|EP)$", "", str(album).strip(), flags=re.IGNORECASE)

def fetch_online_metadata(artist: str, title: str, min_size: int = 1200, target_size: int = 1200, timeout: int = 6):
    """Search online for metadata and high-res cover art (iTunes primary, Deezer fallback)."""
    q_artist = clean_search_term(artist)
    q_title = clean_search_term(title)
    if not q_artist and not q_title:
        return None

    primary_artist = clean_search_term(extract_single_album_artist(artist))
    queries = [f"{q_artist} {q_title}".strip()]
    if primary_artist and primary_artist.lower() != q_artist.lower():
        queries.append(f"{primary_artist} {q_title}".strip())

    for query in queries:
        # 1. Query iTunes Search API
        itunes_url = "https://itunes.apple.com/search?" + urllib.parse.urlencode({
            "term": query,
            "entity": "song",
            "limit": 5
        })
        results = []
        try:
            req = urllib.request.Request(itunes_url, headers={"User-Agent": "MusicOrganizer/2.0"})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                results = data.get("results", [])
        except Exception:
            results = []

        best_match = None
        best_score = 0.0
        best_t_sim = best_a_sim = 0.0

        for item in results:
            cand_title = item.get("trackName", "")
            cand_artist = item.get("artistName", "")
            t_sim, a_sim = match_similarity(q_title, primary_artist, q_artist, cand_title, cand_artist)
            score = (t_sim * 0.6) + (a_sim * 0.4)
            if score > best_score and ((a_sim >= 0.40 and t_sim >= 0.65) or (a_sim >= 0.70 and t_sim >= 0.50)):
                best_score = score
                best_match = item
                best_t_sim, best_a_sim = t_sim, a_sim

        if best_match:
            img_bytes = None
            u100 = best_match.get("artworkUrl100", "")
            if u100:
                u_target = u100.replace("100x100bb.jpg", f"{target_size}x{target_size}bb.jpg").replace("100x100bb.png", f"{target_size}x{target_size}bb.png")
                try:
                    img_req = urllib.request.Request(u_target, headers={"User-Agent": "Mozilla/5.0"})
                    with urllib.request.urlopen(img_req, timeout=timeout) as ir:
                        raw_data = ir.read()
                        img = Image.open(io.BytesIO(raw_data))
                        if img.size[0] >= min_size or img.size[1] >= min_size:
                            if img.size != (target_size, target_size):
                                img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
                                buf = io.BytesIO()
                                img.save(buf, format="JPEG", quality=95)
                                img_bytes = buf.getvalue()
                            else:
                                img_bytes = raw_data
                except Exception:
                    pass

            release_date = best_match.get("releaseDate", "")
            return {
                "source": "iTunes",
                "title": best_match.get("trackName"),
                "artist": best_match.get("artistName"),
                "album": best_match.get("collectionName"),
                "album_artist": best_match.get("collectionArtistName") or "",
                "year": release_date[:4] if release_date else "",
                "date": release_date[:10] if release_date else "",
                "track_num": str(best_match.get("trackNumber", 1)),
                "track_total": str(best_match.get("trackCount", 1)),
                "disc_num": str(best_match.get("discNumber") or ""),
                "disc_total": str(best_match.get("discCount") or ""),
                "genre": best_match.get("primaryGenreName", ""),
                "artwork_bytes": img_bytes,
                "score": best_score,
                "t_sim": best_t_sim,
                "a_sim": best_a_sim,
                # Strict gate: only a near-exact title AND strong artist match may
                # override existing tags (Picard-style clear + apply). Anything weaker
                # is fill-missing-only downstream.
                "confident": best_t_sim >= 0.85 and best_a_sim >= 0.70,
            }

        # 2. Fallback to Deezer API
        try:
            deezer_url = "https://api.deezer.com/search?q=" + urllib.parse.quote(query) + "&limit=4"
            req = urllib.request.Request(deezer_url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                dz_data = json.loads(resp.read().decode("utf-8")).get("data", [])
                for dz_item in dz_data:
                    cand_title = dz_item.get("title", "")
                    cand_artist = dz_item.get("artist", {}).get("name", "")
                    t_sim, a_sim = match_similarity(q_title, primary_artist, q_artist, cand_title, cand_artist)
                    score = (t_sim * 0.6) + (a_sim * 0.4)
                    if (a_sim >= 0.40 and t_sim >= 0.65) or (a_sim >= 0.70 and t_sim >= 0.50):
                        cover_url = dz_item.get("album", {}).get("cover_xl") or dz_item.get("album", {}).get("cover_big")
                        img_bytes = None
                        if cover_url:
                            # Deezer dynamic high-res CDN URL rewrite
                            cover_url_target = re.sub(r"\d+x\d+-000000-80-0-0\.jpg", f"{target_size}x{target_size}-000000-80-0-0.jpg", cover_url)
                            try:
                                with urllib.request.urlopen(urllib.request.Request(cover_url_target, headers={"User-Agent": "Mozilla/5.0"}), timeout=timeout) as ir:
                                    raw = ir.read()
                                    img = Image.open(io.BytesIO(raw))
                                    if img.size[0] >= min_size or img.size[1] >= min_size:
                                        if img.size != (target_size, target_size):
                                            img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
                                            buf = io.BytesIO()
                                            img.save(buf, format="JPEG", quality=95)
                                            img_bytes = buf.getvalue()
                                        else:
                                            img_bytes = raw
                            except Exception:
                                pass
                        return {
                            "source": "Deezer",
                            "title": dz_item.get("title"),
                            "artist": cand_artist,
                            "album": dz_item.get("album", {}).get("title"),
                            "album_artist": dz_item.get("album", {}).get("artist", {}).get("name") or "",
                            "year": "",
                            "date": "",
                            "track_num": str(dz_item.get("track_number") or 1),
                            "track_total": str(dz_item.get("album", {}).get("nb_tracks") or ""),
                            "disc_num": str(dz_item.get("disk_number") or ""),
                            "disc_total": "",
                            "genre": "",
                            "artwork_bytes": img_bytes,
                            "score": score,
                            "t_sim": t_sim,
                            "a_sim": a_sim,
                            "confident": t_sim >= 0.85 and a_sim >= 0.70,
                        }
        except Exception:
            pass

    return None

def _norm_key(s: str) -> str:
    """Alphanumeric-only lowercase key used for snippet relevance checks."""
    return re.sub(r"[^a-z0-9]", "", str(s).lower())

_WEB_MONTHS = {name: i for i, name in enumerate(
    ("January", "February", "March", "April", "May", "June", "July",
     "August", "September", "October", "November", "December"), 1)}

def _web_date(text: str) -> str:
    """Pull a release date out of free text -> 'YYYY-MM-DD', 'YYYY' or ''."""
    # ISO first
    m = re.search(r"(?<!\d)(\d{4})-(\d{2})-(\d{2})(?!\d)", text)
    if m:
        return f"{m.group(1)}-{m.group(2)}-{m.group(3)}"
    # "27 March 2019"
    m = re.search(r"(?<!\d)(\d{1,2})\s+([A-Z][a-z]+)\s*,?\s+(\d{4})(?!\d)", text)
    if m and m.group(2) in _WEB_MONTHS:
        return f"{m.group(3)}-{_WEB_MONTHS[m.group(2)]:02d}-{int(m.group(1)):02d}"
    # "March 27, 2019" / "March27,2019" / "July 8th 2022"
    m = re.search(r"\b([A-Z][a-z]+)\s*(\d{1,2})(?:st|nd|rd|th)?\s*,?\s*(?<!\d)(\d{4})(?!\d)", text)
    if m and m.group(1) in _WEB_MONTHS:
        return f"{m.group(3)}-{_WEB_MONTHS[m.group(1)]:02d}-{int(m.group(2)):02d}"
    # Bare year, only when it follows a release context
    m = re.search(r"(?:released?|release date|℗)[^0-9]{0,30}(\d{4})(?!\d)", text, re.IGNORECASE)
    if m:
        return m.group(1)
    return ""

def _web_album(text: str) -> str:
    """Pull an album name out of free text; '' for both 'not found' and 'non-album'."""
    for pat in (r"\bin the album\s+([^.;|\n]{2,80})",
                r"\b(?:from|off)\s+the album\s+([^.;|\n]{2,80})",
                r"\balbum\s*(?:name)?\s*[:\-]\s*([^.;|\n]{2,80})"):
        m = re.search(pat, text, re.IGNORECASE)
        if m:
            a = m.group(1).strip().strip("\"'“”")
            # Cut at metadata labels even when the source glued them together
            # ("Non- album singleReleased : March27,2019Genre : Electro house").
            a = re.split(r"\s+Released\s", a)[0]
            a = re.split(r"releases?\s*:", a, flags=re.IGNORECASE)[0]
            a = re.split(r"genres?\s*:", a, flags=re.IGNORECASE)[0]
            a = a.strip()
            if re.search(r"non[-\s]+album|not on an album", a, re.IGNORECASE) or a.lower() == "single":
                return ""   # explicitly no album -> title-fallback downstream
            if len(_norm_key(a)) >= 2:
                return a
    return ""

def _web_genre(text: str) -> str:
    """Pull a genre out of free text ('Genre : Electro house')."""
    m = re.search(r"(?<![A-Za-z])genres?\s*[:\-]\s*([A-Za-z][^.;|\n]{1,40})", text, re.IGNORECASE)
    if m:
        g = m.group(1).strip().split(",")[0].split(";")[0].strip()
        if g:
            return g
    return ""

def _web_title_artist(text: str):
    """Extract (title, artist) from credit-style snippets.

    RateYourMusic style: "City of Gold, a Single by K-391 & Diviners. Featured..."
    Generic credit:      "... a song by ehren, released on ..."
    """
    m = re.match(r"(.{2,80}?),\s+a\s+(?:single|album|ep)\s+by\s+([^.]{2,60})", text.strip(), re.IGNORECASE)
    if m:
        return m.group(1).strip(), m.group(2).strip()
    m = re.search(r"\b(?:a|the)\s+(?:single|song|track)\s+by\s+([^.,;|\n]{2,60})", text, re.IGNORECASE)
    if m:
        return "", m.group(1).strip()
    return "", ""

def fetch_web_metadata(artist: str, title: str, timeout: int = 8, max_results: int = 6):
    """Web fallback tier: mine DuckDuckGo result snippets for date/album/genre/title.

    Consulted only when iTunes/Deezer left fields empty (their catalogs simply lack
    many YouTube/download-era tracks). Returns a dict of candidate values ('' where
    nothing was found) or None on any failure - blocked, layout change, no relevant
    result. Downstream is fill-only: none of this ever overwrites an existing tag.
    """
    q_title = clean_search_term(title)
    q_artist = clean_search_term(artist)
    if not q_title:
        return None

    query = f'{q_artist} "{q_title}" album release date'.strip()
    url = "https://html.duckduckgo.com/html/?" + urllib.parse.urlencode({"q": query})
    # DDG intermittently serves an anomaly page or errors on rapid repeat queries
    # from one IP: retry ONCE with a longer pause when the page carried no results
    # at all. A page WITH results that fail the relevance gate below is a
    # deterministic answer and is never retried.
    raw_titles, raw_snips = [], []
    for attempt in range(2):
        try:
            time.sleep(1.5 if attempt == 0 else 6)  # polite pause before scraping
            req = urllib.request.Request(url, headers={
                "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                              "(KHTML, like Gecko) Chrome/124.0 Safari/537.36",
                "Accept-Language": "en-US,en;q=0.9",
            })
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                body = resp.read().decode("utf-8", "ignore")
        except Exception:
            body = ""
        raw_titles = re.findall(r'class="result__a"[^>]*>(.*?)</a>', body, re.S) if body else []
        raw_snips = re.findall(r'class="result__snippet"[^>]*>(.*?)</a>', body, re.S)[:max_results] if body else []
        if raw_snips:
            break
    if not raw_snips:
        return None   # blocked twice / layout change -> fail safe

    def _clean(fragment: str) -> str:
        # Tags become SPACES, never bare concatenation ('...2019Genre...') - entity
        # and tag boundaries must stay word boundaries for the patterns below.
        return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", fragment))).strip()

    # Relevance gate: only trust results whose TITLE or SNIPPET mentions the song or
    # the artist (the paired result title covers snippets that only carry metadata
    # lines like 'album : Non-album single / Genre : Electro house').
    n_title, n_artist = _norm_key(q_title), _norm_key(q_artist)
    relevant = []
    for i, raw in enumerate(raw_snips):
        snippet = _clean(raw)
        if not snippet:
            continue
        hay = _norm_key((_clean(raw_titles[i]) if i < len(raw_titles) else "") + " " + snippet)
        if (len(n_title) >= 4 and n_title in hay) or (len(n_artist) >= 3 and n_artist in hay):
            relevant.append(snippet)
    if not relevant:
        return None   # blocked / layout change / unrelated results -> fail safe

    out = {"source": "Web", "title": "", "artist": "", "album": "", "date": "", "year": "", "genre": ""}
    for s in relevant:
        if not out["date"]:
            out["date"] = _web_date(s)
        if not out["album"]:
            out["album"] = _web_album(s)
        if not out["genre"]:
            out["genre"] = _web_genre(s)
        if not (out["title"] and out["artist"]):
            w_title, w_artist = _web_title_artist(s)
            if w_title and not out["title"]:
                out["title"] = w_title
            if w_artist and not out["artist"]:
                out["artist"] = w_artist
    out["year"] = out["date"][:4] if out["date"] else ""

    if not any(out[k] for k in ("title", "artist", "album", "date", "genre")):
        return None
    return out

def process_artwork(local_path: str, online_bytes: bytes, target_size: int = 1200, min_size: int = 1200, online_first: bool = False) -> bytes:
    """Ensure artwork is strictly formatted to exact 1200x1200px.

    online_first=True (confident catalog match): the fetched art wins over the
    local/paired image, mirroring Picard's provider-first cover handling.
    """
    if online_first and online_bytes:
        return online_bytes

    if local_path and os.path.exists(local_path):
        try:
            img = Image.open(local_path)
            if img.size[0] >= min_size and img.size[1] >= min_size:
                if img.size != (target_size, target_size):
                    img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
                    buf = io.BytesIO()
                    img.save(buf, format="JPEG", quality=95)
                    return buf.getvalue()
                with open(local_path, "rb") as f:
                    return f.read()
        except Exception:
            pass

    if online_bytes:
        return online_bytes

    if local_path and os.path.exists(local_path):
        try:
            img = Image.open(local_path)
            img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=95)
            return buf.getvalue()
        except Exception:
            pass

    return None

def prompt_manual_tags(audio_path: str, current: dict) -> dict:
    """Last-resort interactive tagging when every lookup tier found nothing.

    Asks only for the essential fields - current value shown as [default], Enter keeps
    it, '-' clears - plus an opt-in round for composer/label/ISRC/copyright. Original
    year is always asked (never hidden as an advanced field): it defaults to the year
    and is always written to TXXX:originalyear. Returns None when input runs out
    (EOF), so the caller falls back to the untouched state. Values are applied by the
    caller through the normal cleanup pipeline, saved strictly as ID3v2.4.
    """
    print()
    print("-" * 74)
    print(f" No online match found for:")
    print(f"   {audio_path}")
    print(" Enter keeps [the current value], '-' clears a field.")
    print(" Put the FULL credit in ARTIST (e.g. 'A & B feat. C') - it is stored as")
    print(" multiple TPE1 values exactly like Picard. Title/album stay clean.")
    print("-" * 74)

    year_re = re.compile(r"\d{4}|\d{4}-\d{2}-\d{2}")
    oy_re = re.compile(r"\d{4}")
    num_re = re.compile(r"\d+(?:/\d+)?")

    def ask(label: str, default, hint: str, validator=None, err: str = ""):
        d = str(default or "")
        while True:
            try:
                raw = input(f"  {label:<14}[{d}] {hint}: ").strip()
            except EOFError:
                return None
            if raw == "":
                return d
            if raw == "-":
                return ""
            if validator is None or validator.fullmatch(raw):
                return raw
            print(f"    ! {err}")

    specs = [
        ("title",       "Title",          current["title"],        "(Picard-style, no 'feat.')"),
        ("artist",      "Artist",         current["artist"],       "(full credit: 'A & B feat. C')"),
        ("albumartist", "Album artist",   extract_single_album_artist(current["albumartist"]), "(single primary artist)"),
        ("album",       "Album",          current["album"],        "(empty -> uses title)"),
        ("date",        "Year",           current["date"],         "(YYYY or YYYY-MM-DD)"),
        ("originalyear","Original year",  current["originalyear"], "(YYYY, always written)"),
        ("track",       "Track number",   current["track"],        "(n or n/total)"),
        ("disc",        "Disc",           current["disc"],         "(n or n/total, empty = one disc)"),
        ("genre",       "Genre",          current["genre"],        "(e.g. Electronic, Soundtrack)"),
    ]
    validators = {
        "date":        (year_re, "use YYYY or YYYY-MM-DD"),
        "originalyear":(oy_re,   "use YYYY"),
        "track":       (num_re,  "use n or n/total"),
        "disc":        (num_re,  "use n or n/total"),
    }

    out = {}
    for key, label, default, hint in specs:
        validator, err = validators.get(key, (None, ""))
        v = ask(label, default, hint, validator, err)
        if v is None:
            return None
        out[key] = v

    while True:
        try:
            more = input("  More tags? composer, label, ISRC, copyright [y/N]: ").strip().lower()
        except EOFError:
            return None
        if more in ("", "n", "no", "y", "yes"):
            break
        print("    ! enter y or n")
    if more in ("y", "yes"):
        for key, label in (("composer", "Composer"), ("label", "Label"),
                           ("isrc", "ISRC"), ("copyright", "Copyright")):
            v = ask(label, current.get(key, ""), "")
            if v is None:
                return None
            out[key] = v
    return out

def get_track_plan(audio_path: str, library_artist_index: dict = None, library_dir: str = DEFAULT_LIBRARY_DIR, use_online: bool = True, allow_prompt: bool = True):
    """Inspect tags, source online information, and compute destination paths."""
    if library_artist_index is None:
        library_artist_index = build_library_artist_index(library_dir)
    audio = mutagen.File(audio_path)
    tags = audio.tags or {}

    # mutagen renders multi-value text frames (Picard's $setmulti artist credits) as
    # '\x00'-joined strings - keep the VALUES so null bytes never leak into search
    # queries, prompts or folder names. The space-joined credit feeds search/display;
    # the first value is the album artist seed (one album artist, Picard rule).
    def _frame_vals(key):
        f = tags.get(key)
        return [str(v).strip() for v in (f.text if f else []) if str(v).strip()]
    tpe1_vals, tpe2_vals = _frame_vals("TPE1"), _frame_vals("TPE2")

    title = str(tags.get("TIT2", "")).replace("\x00", " ").strip()
    artist = " ".join(tpe1_vals)
    albumartist = tpe2_vals[0] if tpe2_vals else (tpe1_vals[0] if tpe1_vals else "")
    album = str(tags.get("TALB", "")).replace("\x00", " ").strip()
    orig_title = title
    orig_album = album
    year = str(tags.get("TDRC") or tags.get("TXXX:originalyear", "")).strip()[:4]

    # Track number: trust the tag whenever it is usable (Picard does not second-guess
    # it either); only consult online data when TRCK is missing or unparseable, so a
    # wrong online match can never rename a correctly numbered track.
    trck_tag = str(tags.get("TRCK") or "").strip()
    track_raw = trck_tag.split("/")[0].strip()
    track_num = _int_str(track_raw)
    has_track_num = bool(track_num)

    # Disc position from TPOS ("disc/total") = Picard's %discnumber% / %totaldiscs%
    tpos_tag = str(tags.get("TPOS") or "").strip()
    disc_num, disc_total = "", ""
    if tpos_tag:
        d_raw, _, t_raw = tpos_tag.partition("/")
        disc_num = _int_str(d_raw)
        disc_total = _int_str(t_raw)

    tag_fixes = {}

    # Ripped files often store the whole "Artist - Title" filename inside TIT2.
    # Split it off when the prefix matches a known artist (MusicBrainz/Picard titles
    # never contain the artist) - this cleans the title, the album fallback and the
    # online search query in one go.
    orig_artist = artist
    artist_hints = [h for h in [artist] + tpe1_vals + tpe2_vals if h]
    if not artist_hints:
        artist_hints = [os.path.basename(os.path.dirname(audio_path))]
    title, title_credit = split_artist_prefix(title, artist_hints)
    # The prefix credit must UPGRADE a non-empty TPE1 when it names more artists
    # ("K-391 & Diviners feat. Anna Yvette"), but never downgrade a correct one.
    if _credit_is_richer(artist, title_credit):
        artist = title_credit
    if artist != orig_artist:
        tag_fixes["TPE1"] = artist

    online_info = None
    confident = False
    if use_online:
        search_a = artist or os.path.basename(os.path.dirname(audio_path))
        search_t = title or os.path.splitext(os.path.basename(audio_path))[0]
        online_info = fetch_online_metadata(search_a, search_t)
        confident = bool(online_info and online_info.get("confident"))

    if online_info:
        on_title = str(online_info.get("title") or "").strip()
        on_artist = str(online_info.get("artist") or "").strip()
        on_album = strip_release_suffix(str(online_info.get("album") or ""))
        on_albumartist = str(online_info.get("album_artist") or "").strip()
        release_date = online_info.get("date") or online_info.get("year")

        if confident:
            # Picard-style clear + apply: a near-exact catalog match (strict title AND
            # artist gate) replaces what the file claimed - rip/download junk tags
            # never survive a good match. Every value still runs through the cleanup
            # pipeline below (feat-strip, artist-prefix split, album fallback).
            if on_title:
                title = on_title
                split_hints = [h for h in (on_artist, on_albumartist) if h]
                if split_hints:
                    # catalog titles can still carry an artist prefix
                    title, title_credit = split_artist_prefix(title, split_hints)
                    if not artist and title_credit:
                        artist = title_credit
            if on_artist:
                artist = on_artist
            if on_album:
                album = on_album
            # album artist follows the matched release (Picard's "One album artist")
            release_credit = on_albumartist or on_artist
            if release_credit:
                albumartist = extract_single_album_artist(release_credit)
            # Only emit a fix when the catalog value actually differs from the tag -
            # a confident match on an already-correct file should be a no-op.
            if release_date:
                if release_date != str(tags.get("TDRC") or "").strip():
                    tag_fixes["TDRC"] = release_date
                if release_date != str(tags.get("TDOR") or "").strip():
                    tag_fixes["TDOR"] = release_date
            if online_info.get("year"):
                if online_info["year"] != str(tags.get("TXXX:originalyear") or "").strip():
                    tag_fixes["TXXX:originalyear"] = online_info["year"]
                year = online_info["year"]
            if online_info.get("genre") and online_info["genre"] != str(tags.get("TCON") or "").strip():
                tag_fixes["TCON"] = online_info["genre"]
            on_track = _int_str(online_info.get("track_num"))
            if on_track:
                on_total = _int_str(online_info.get("track_total"))
                new_trck = f"{on_track}/{on_total}" if on_total else on_track
                if new_trck != trck_tag:
                    tag_fixes["TRCK"] = new_trck
                track_num = on_track
                has_track_num = True
            on_dtotal = _int_str(online_info.get("disc_total"))
            if on_dtotal:
                disc_num = _int_str(online_info.get("disc_num")) or "1"
                disc_total = on_dtotal
                new_tpos = f"{disc_num}/{disc_total}"
                if new_tpos != tpos_tag:
                    tag_fixes["TPOS"] = new_tpos
        else:
            # Weak/medium match: fill only what is missing - never overwrite good tags
            if not title and on_title:
                title = on_title
            if not artist and on_artist:
                artist = on_artist
            if (not album or album.lower() in ("single", "unknown", "untitled")) and on_album:
                album = on_album
            if release_date and "TDRC" not in tag_fixes and not tags.get("TDRC"):
                tag_fixes["TDRC"] = release_date
                if "TDOR" not in tag_fixes and not tags.get("TDOR"):
                    tag_fixes["TDOR"] = release_date
                if not year:
                    year = str(release_date)[:4]
            if online_info.get("year") and not year:
                tag_fixes["TXXX:originalyear"] = online_info["year"]
                year = online_info["year"]
            if online_info.get("genre") and "TCON" not in tag_fixes and not tags.get("TCON"):
                tag_fixes["TCON"] = online_info["genre"]
            # Fill in a track number only when the tag has none
            if not has_track_num:
                on_track = _int_str(online_info.get("track_num"))
                if on_track:
                    on_total = _int_str(online_info.get("track_total"))
                    tag_fixes["TRCK"] = f"{on_track}/{on_total}" if on_total else on_track
                    track_num = on_track
            # Fill in disc info only when the tag has no total AND it is genuinely multi-disc
            if not disc_total:
                on_dtotal = _int_str(online_info.get("disc_total"))
                if on_dtotal and int(on_dtotal) > 1:
                    disc_num = _int_str(online_info.get("disc_num")) or "1"
                    disc_total = on_dtotal
                    tag_fixes["TPOS"] = f"{disc_num}/{disc_total}"

    # Web fallback (DuckDuckGo): only when the catalog tier left fields empty - their
    # catalogs lack many YouTube/download-era tracks. Fill-only by design: snippets
    # may ADD a missing album/date/genre/title/artist, never replace a present tag.
    web_info = None
    if use_online:
        placeholders = ("single", "unknown", "untitled")
        needs_web = (
            not title or not artist
            or not album or album.lower() in placeholders
            or not year
            or ("TDRC" not in tag_fixes and not tags.get("TDRC"))
            or ("TCON" not in tag_fixes and not tags.get("TCON"))
        )
        if needs_web:
            web_info = fetch_web_metadata(search_a, search_t)
            if web_info:
                w_title = str(web_info.get("title") or "").strip()
                w_artist = str(web_info.get("artist") or "").strip()
                w_album = strip_release_suffix(str(web_info.get("album") or ""))
                w_date = str(web_info.get("date") or "").strip()
                w_genre = str(web_info.get("genre") or "").strip()

                if not title and w_title:
                    title = w_title
                if not artist and w_artist:
                    artist = w_artist
                if (not album or album.lower() in placeholders) and w_album:
                    album = w_album
                if w_date and "TDRC" not in tag_fixes and not tags.get("TDRC"):
                    tag_fixes["TDRC"] = w_date
                    if "TDOR" not in tag_fixes and not tags.get("TDOR"):
                        tag_fixes["TDOR"] = w_date
                    if not year:
                        year = w_date[:4]
                if w_genre and "TCON" not in tag_fixes and not tags.get("TCON"):
                    tag_fixes["TCON"] = w_genre

    # Total failure (iTunes + Deezer + web tier all found nothing, or --no-online):
    # last resort is asking the user. TTY-only, disabled with --no-prompt;
    # ORGANIZE_PROMPT=1 forces it for scripted/piped runs and tests.
    manual = None
    if online_info is None and web_info is None and allow_prompt:
        env_force = os.environ.get("ORGANIZE_PROMPT", "").strip().lower() in ("1", "true", "yes", "on")
        if sys.stdin.isatty() or env_force:
            manual = prompt_manual_tags(audio_path, {
                "title": title,
                "artist": artist,
                "albumartist": albumartist,
                "album": album,
                "date": str(tags.get("TDRC") or "").strip() or year,
                "originalyear": str(tags.get("TXXX:originalyear") or "").strip() or year,
                "track": trck_tag,
                "disc": tpos_tag,
                "genre": str(tags.get("TCON") or "").replace("\x00", " "),
                "composer": str(tags.get("TCOM") or "").replace("\x00", " "),
                "label": str(tags.get("TPUB") or "").replace("\x00", " "),
                "isrc": str(tags.get("TSRC") or "").replace("\x00", " "),
                "copyright": str(tags.get("TCOP") or "").replace("\x00", " "),
            })
            if manual is None:
                print("  (input ended - keeping current tags)")
    if manual is not None:
        # Text fields: manual values replace the pipeline state below (empty = cleared,
        # with fallbacks like "album -> title" and "title -> filename" applied later).
        title = manual["title"] or clean_search_term(
            os.path.splitext(os.path.basename(audio_path))[0])
        artist = manual["artist"]
        albumartist = manual["albumartist"]
        album = manual["album"]

        # Release dates: an entered/cleared date is explicit user intent (override),
        # while Enter-on-default is a no-op because default == current tag.
        m_date = manual["date"]
        if m_date:
            if m_date != str(tags.get("TDRC") or "").strip():
                tag_fixes["TDRC"] = m_date
            if m_date != str(tags.get("TDOR") or "").strip():
                tag_fixes["TDOR"] = m_date
            year = m_date[:4]
        else:
            year = ""
            if str(tags.get("TDRC") or "").strip():
                tag_fixes["TDRC"] = ""
            if str(tags.get("TDOR") or "").strip():
                tag_fixes["TDOR"] = ""

        # Original year is always set (never an optional/advanced field)
        m_oy = manual["originalyear"]
        if m_oy:
            if m_oy != str(tags.get("TXXX:originalyear") or "").strip():
                tag_fixes["TXXX:originalyear"] = m_oy
        elif str(tags.get("TXXX:originalyear") or "").strip():
            tag_fixes["TXXX:originalyear"] = ""

        m_trck = manual["track"]
        if m_trck:
            m = re.fullmatch(r"(\d+)(?:/(\d+))?", m_trck)
            t_n = _int_str(m.group(1))
            t_t = _int_str(m.group(2)) if m.group(2) else ""
            new_trck = f"{t_n}/{t_t}" if t_t else t_n
            if new_trck != trck_tag:
                tag_fixes["TRCK"] = new_trck
            track_num = t_n
            has_track_num = True
        elif trck_tag:                       # explicit clear deletes TRCK
            tag_fixes["TRCK"] = ""
            track_num = "1"
            has_track_num = True

        m_tpos = manual["disc"]
        if m_tpos:
            d_raw, _, t_raw = m_tpos.partition("/")
            disc_num = _int_str(d_raw)
            disc_total = _int_str(t_raw)
            new_tpos = f"{disc_num}/{disc_total}" if disc_total else disc_num
            if new_tpos != tpos_tag:
                tag_fixes["TPOS"] = new_tpos
        elif tpos_tag:                       # explicit clear deletes TPOS
            tag_fixes["TPOS"] = ""
            disc_num, disc_total = "", ""

        m_genre = manual["genre"]
        if m_genre != str(tags.get("TCON") or "").replace("\x00", " ").strip():
            tag_fixes["TCON"] = m_genre

        # Opt-in advanced tags (only present when the user asked for them)
        for mkey, tkey in (("composer", "TCOM"), ("label", "TPUB"),
                           ("isrc", "TSRC"), ("copyright", "TCOP")):
            mv = manual.get(mkey)
            if (mv is not None
                    and mv != str(tags.get(tkey) or "").replace("\x00", " ").strip()):
                tag_fixes[tkey] = mv

    if year:
        if "TXXX:originalyear" not in tag_fixes and not tags.get("TXXX:originalyear"):
            tag_fixes["TXXX:originalyear"] = year
        if "TDOR" not in tag_fixes and not tags.get("TDOR"):
            tag_fixes["TDOR"] = year

    # Picard never carries featuring credits in album/track titles (MusicBrainz keeps
    # them in artist credits only) - strip them before tagging or naming anything.
    title = strip_featuring(title)

    # YouTube/download rips often set ALBUM to a verbatim copy of the whole title.
    # When that exact raw copy is what we are looking at, re-copy the now-cleaned title
    # so the album folder shows the real title; a genuinely distinct album stays as is.
    if album == orig_title and title != orig_title:
        album = title

    album = strip_featuring(album)

    # Never create an empty "[Year] " album folder
    if not album:
        album = title or "Unknown Album"

    if album != orig_album:
        tag_fixes["TALB"] = album
    else:
        tag_fixes.pop("TALB", None)   # tag already matches the cleaned value
    if title != orig_title:
        tag_fixes["TIT2"] = title
    else:
        tag_fixes.pop("TIT2", None)   # e.g. online offered only a feat-variant
    # One library, one casing: fold each credit component to the existing library
    # folder's spelling when ONLY the case differs ("Ten Times" -> "TEN TIMES"),
    # so new files never disagree with already-sorted tracks.
    artist = fold_artist_casing(artist, library_artist_index)

    # Artist may have changed after the prefix-split (online confident match or web
    # fill) - reconcile TPE1 against the original tag here, as with TIT2/TALB.
    if artist != orig_artist:
        tag_fixes["TPE1"] = artist
    else:
        tag_fixes.pop("TPE1", None)

    # Keep tag and filename in agreement: always end up with a usable number
    if not track_num:
        track_num = "1"
    if not has_track_num and "TRCK" not in tag_fixes:
        tag_fixes["TRCK"] = track_num
    elif has_track_num and track_raw != track_num and "TRCK" not in tag_fixes:
        # Normalise zero padding ("01" -> "1") while preserving "/total"
        total_raw = trck_tag.split("/")[1].strip() if "/" in trck_tag else ""
        tag_fixes["TRCK"] = f"{track_num}/{total_raw}" if total_raw else track_num

    # Extract single primary album artist
    albumartist = extract_single_album_artist(albumartist or artist)

    # Match album artist against existing Library folders
    norm_albumartist = normalize_artist_key(albumartist)
    if norm_albumartist in library_artist_index:
        canonical_albumartist = library_artist_index[norm_albumartist]
        albumartist = canonical_albumartist
        # Compare against the RAW TPE2 tag, not the derived value: the derived album
        # artist can already equal the canonical folder while the tag itself is stale
        # (wrong case "John de Sohn" vs folder "John De Sohn", a trailing space, or
        # missing entirely) - only a raw comparison rewrites it.
        if canonical_albumartist != str(tags.get("TPE2", "")):
            tag_fixes["TPE2"] = canonical_albumartist
    elif albumartist != str(tags.get("TPE2", "")):
        tag_fixes["TPE2"] = albumartist

    # Identify junk tags to remove (the Picard $delete list above - comments,
    # encoder, BPM/key, the three deleted MB ids, USLT ...). Every OTHER
    # MusicBrainz frame (Album/Artist/Album Artist/Release Track Id, Album Status,
    # UFID ...) is NEVER stripped here: keeping MB tags until the user runs the
    # opt-in --purge-mb pass is an explicit directive.
    junk_keys = [k for k in tags.keys() if is_junk_tag(k)]

    # Artwork resolution (strictly >=1200px, formatted to 1200x1200px)
    local_image = find_paired_image(audio_path)
    online_art_bytes = online_info.get("artwork_bytes") if online_info else None
    final_art_bytes = process_artwork(local_image, online_art_bytes, target_size=1200, min_size=1200,
                                      online_first=confident)

    # Sanitize components
    s_albumartist = sanitize_component(albumartist)
    s_album = sanitize_component(album)
    s_title = sanitize_component(title)

    # Disc subfolder, matching Picard Preset 2 exactly:
    #   $if($gt(%totaldiscs%,1),Disc $num(%discnumber%,2)/)
    disc_dirname = ""
    if disc_total and int(disc_total) > 1:
        disc_dirname = f"Disc {int(disc_num or 1):02d}"

    dest_album_root = os.path.join(library_dir, s_albumartist, f"[{year}] {s_album}")
    dest_dir = os.path.join(dest_album_root, disc_dirname) if disc_dirname else dest_album_root
    ext = os.path.splitext(audio_path)[1]
    dest_audio_file = os.path.join(dest_dir, f"{track_num} - {s_title}{ext}")
    # cover.jpg always lives at the album root, even for multi-disc albums
    dest_cover_file = os.path.join(dest_album_root, "cover.jpg")

    return {
        "src_audio": audio_path,
        "src_image": local_image,
        "dest_dir": dest_dir,
        "dest_album_root": dest_album_root,
        "dest_audio": dest_audio_file,
        "dest_cover": dest_cover_file,
        "artist": artist,
        "albumartist": albumartist,
        "album": album,
        "title": title,
        "year": year,
        "track_num": track_num,
        "disc_dirname": disc_dirname,
        "tag_fixes": tag_fixes,
        "junk_keys_to_remove": junk_keys,
        "artwork_bytes": final_art_bytes,
        "online_source": online_info["source"] if online_info else None,
        "confident": confident,
        "confidence": (f"t={online_info['t_sim']:.2f} a={online_info['a_sim']:.2f}"
                       if online_info else None),
        "web_source": web_info["source"] if web_info else None,
        "manual": manual is not None,
    }

def migrate_discs(library_dir: str, execute: bool = False):
    """One-time migration: move already-tagged multi-disc tracks into 'Disc NN' subfolders.

    Mirrors Picard Preset 2's $if($gt(%totaldiscs%,1),Disc $num(%discnumber%,2)/) rule so
    the existing library ends up with the layout Picard itself would produce. Only tracks
    sitting directly in an album folder are considered; tags are never modified, files are
    never renamed, and cover.jpg stays at the album root.
    """
    album_files = sorted(glob.glob(os.path.join(library_dir, "*", "*", "*.mp3")))

    moves = []
    for f in album_files:
        parent = os.path.dirname(f)
        if DISC_DIR_RE.match(os.path.basename(parent)):
            continue  # already organised into a disc folder (e.g. by Picard)
        try:
            tags = ID3(f)
        except Exception:
            continue
        tpos_tag = str(tags.get("TPOS") or "").strip()
        if not tpos_tag:
            continue
        d_raw, _, t_raw = tpos_tag.partition("/")
        disc_num = _int_str(d_raw)
        disc_total = _int_str(t_raw)
        if not disc_total or int(disc_total) <= 1:
            continue
        disc_dirname = f"Disc {int(disc_num or 1):02d}"
        dest = os.path.join(parent, disc_dirname, os.path.basename(f))
        moves.append((f, dest))

    print(f"=== Disc migration: {len(moves)} of {len(album_files)} library tracks need a 'Disc NN' subfolder ===\n")

    if not moves:
        print("Nothing to do: every multi-disc track is already in a disc folder.")
        return

    collisions = []
    seen = set()
    for src, dst in moves:
        if dst in seen or os.path.exists(dst):
            collisions.append((src, dst))
        seen.add(dst)

    if collisions:
        print(f"ERROR: Found {len(collisions)} collision(s) among destination paths!")
        for src, dst in collisions:
            print(f"  Collision: {src} -> {dst}")
        sys.exit(1)

    print(f"{'STATUS':<8} {'SOURCE'}")
    print("-" * 120)
    for idx, (src, dst) in enumerate(moves, 1):
        print(f"[{idx:02d}/{len(moves):02d}] {os.path.relpath(src, library_dir)}")
        print(f"        -> {os.path.relpath(dst, library_dir)}")

    if execute:
        for src, dst in moves:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.move(src, dst)
        print("\n" + "=" * 120)
        print(f"SUCCESS: Moved {len(moves)} track(s) into disc subfolders under {library_dir}!")
    else:
        print("\n" + "=" * 120)
        print(f"DRY RUN COMPLETE: No files were moved. {len(moves)} track(s) would be reorganised.")
        print("Run with '--migrate-discs --execute' to perform the changes.")

def fetch_album_cover(albumartist: str, album: str, target_size: int = 1200,
                      min_t: float = 0.80, min_a: float = 0.60, timeout: int = 6):
    """Fetch a candidate high-res album cover (iTunes album search, Deezer fallback).

    Stricter than the metadata fill gate: BOTH the album title and the album artist
    must match the catalog entry well, because wrong art is worse than no upgrade.
    Returns {"bytes" (exact target_size square JPEG), "source", "url", "src_size",
    "t_sim", "a_sim"} or None when nothing confident is found. The caller decides
    whether the source image is a real upgrade over what the album already has.
    """
    q_album = clean_search_term(strip_release_suffix(album))
    q_artist = clean_search_term(extract_single_album_artist(albumartist))
    if not q_album and not q_artist:
        return None

    def gate(cand_album, cand_artist):
        # Strip Apple's "- Single"/"- EP" suffix on the candidate side too, so a
        # storefront collection still compares against the plain stored album name.
        t_sim, a_sim = match_similarity(strip_release_suffix(q_album), q_artist, q_artist,
                                        strip_release_suffix(cand_album), cand_artist)
        return t_sim >= min_t and a_sim >= min_a, t_sim, a_sim

    def norm(raw, url, source, t_sim, a_sim):
        try:
            img = Image.open(io.BytesIO(raw))
            src = img.size
            if min(src) < 100:
                return None
            if img.mode != "RGB":
                img = img.convert("RGB")
            if src != (target_size, target_size):
                img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
                buf = io.BytesIO()
                img.save(buf, format="JPEG", quality=95)
                data = buf.getvalue()
            elif raw[:2] == b"\xff\xd8":
                data = raw
            else:
                buf = io.BytesIO()
                img.save(buf, format="JPEG", quality=95)
                data = buf.getvalue()
            return {"bytes": data, "source": source, "url": url, "src_size": src,
                    "t_sim": t_sim, "a_sim": a_sim}
        except Exception:
            return None

    def _get(url, ua="Mozilla/5.0"):
        req = urllib.request.Request(url, headers={"User-Agent": ua})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read()

    # 1. iTunes album catalog (artwork URL rewrite 100x100bb -> 1200x1200bb)
    results = []
    try:
        itunes_url = "https://itunes.apple.com/search?" + urllib.parse.urlencode(
            {"term": f"{q_artist} {q_album}".strip(), "entity": "album", "limit": 5})
        results = json.loads(_get(itunes_url, "MusicOrganizer/2.0").decode("utf-8")).get("results", [])
    except Exception:
        results = []
    for item in results:
        ok, t_sim, a_sim = gate(item.get("collectionName", ""), item.get("artistName", ""))
        u100 = item.get("artworkUrl100", "")
        if not ok or not u100:
            continue
        url = (u100.replace("100x100bb.jpg", f"{target_size}x{target_size}bb.jpg")
                   .replace("100x100bb.png", f"{target_size}x{target_size}bb.png"))
        try:
            out = norm(_get(url), url, "iTunes", t_sim, a_sim)
        except Exception:
            out = None
        if out:
            return out

    # 2. Deezer album catalog fallback (CDN URL rewrite to cover_xl 1200x1200)
    dz = []
    try:
        dz_url = ("https://api.deezer.com/search/album?q="
                  + urllib.parse.quote(f"{q_artist} {q_album}".strip()) + "&limit=5")
        dz = json.loads(_get(dz_url).decode("utf-8")).get("data", [])
    except Exception:
        dz = []
    for item in dz:
        artist_obj = item.get("artist") or {}
        ok, t_sim, a_sim = gate(item.get("title", ""), artist_obj.get("name", ""))
        cover = item.get("cover_xl") or item.get("cover_big") or item.get("cover_medium")
        if not ok or not cover:
            continue
        url = re.sub(r"\d+x\d+-000000-80-0-0\.jpg",
                     f"{target_size}x{target_size}-000000-80-0-0.jpg", cover)
        try:
            out = norm(_get(url), url, "Deezer", t_sim, a_sim)
        except Exception:
            out = None
        if out:
            return out
    return None

def promote_disc_covers(album_root: str, execute: bool = False):
    """Make cover.jpg sit at the album root; drop per-disc duplicates.

    The library standard is ONE cover.jpg at the album root (Picard's own layout):
    when only a 'Disc NN' folder has one it is copied up, and per-disc copies are
    deleted ONLY when byte-identical to the root cover - a disc cover that differs
    is reported and kept, never destroyed. Returns (promoted_from_or_None,
    removed_count, [mismatched paths]).
    """
    disc_covers = []
    for entry in sorted(os.listdir(album_root)):
        d = os.path.join(album_root, entry)
        if os.path.isdir(d) and DISC_DIR_RE.match(entry):
            c = os.path.join(d, "cover.jpg")
            if os.path.exists(c):
                disc_covers.append(c)
    if not disc_covers:
        return None, 0, []

    root_cover = os.path.join(album_root, "cover.jpg")
    promoted_from = None
    if not os.path.exists(root_cover):
        promoted_from = disc_covers[0]
        if execute:
            shutil.copy2(promoted_from, root_cover)

    # Bytes the root cover holds (or would hold after the promote) for comparison
    ref = root_cover if os.path.exists(root_cover) else promoted_from
    try:
        with open(ref, "rb") as f:
            root_bytes = f.read()
    except OSError:
        return promoted_from, 0, disc_covers

    removed, mismatches = 0, []
    for c in disc_covers:
        try:
            with open(c, "rb") as f:
                identical = f.read() == root_bytes
        except OSError:
            continue
        if identical:
            removed += 1
            if execute:
                os.remove(c)
        else:
            mismatches.append(c)
    return promoted_from, removed, mismatches

def covers_csv_albums(csv_path: str, library_dir: str):
    """Absolute album roots for the rows of a coverage CSV (e.g. covers_below_1200.csv).

    The CSV must have an 'album' column of library-relative folder paths
    ('Artist/[2020] Album'). Rows that no longer exist in the library are kept
    here and reported by the caller.
    """
    csv_path = os.path.abspath(os.path.expanduser(csv_path))
    if not os.path.isfile(csv_path):
        print(f"ERROR: --covers-csv file not found: {csv_path}")
        sys.exit(1)
    with open(csv_path, newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        if not reader.fieldnames or "album" not in reader.fieldnames:
            print(f"ERROR: {csv_path} has no 'album' column (got: {reader.fieldnames})")
            sys.exit(1)
        roots = []
        for row in reader:
            val = (row.get("album") or "").strip()
            if val:
                roots.append(os.path.join(library_dir, val))
    if not roots:
        print(f"ERROR: {csv_path} lists no albums")
        sys.exit(1)
    return roots

def run_fetch_covers(library_dir: str, execute: bool = False, online: bool = True,
                     auto: bool = False, scope: str = None, min_size: int = 1200,
                     target_size: int = 1200, polite_delay: float = 1.5,
                     review_dir: str = None, only_albums=None):
    """Art-only pass over the library (--fetch-covers).

    Local (always): promote 'Disc NN/cover.jpg' to the album root and delete
    per-disc duplicates that are byte-identical to the root cover.
    Online (skipped with --no-online): album roots whose cover is below min_size get
    a higher-res candidate fetch (iTunes album search, Deezer fallback), accepted
    only when strictly larger than the current art, then previewed in the system
    image viewer behind a y/N confirmation (--auto skips the prompt). 'q' aborts
    the remaining fetches.

    scope (from --source pointing inside the library): limit the pass to the album
    holding that file/folder, or every album beneath that folder. A SCOPED dry run
    still fetches and opens the preview image, but writes nothing - it keeps the
    candidate as a temp file and reports its path (fetch-only inspection).

    review_dir (--review DIR): batch mode for offline confirmation. Every accepted
    candidate is saved into review_dir as a numbered .jpg plus manifest.csv and an
    index.html side-by-side contact sheet; the library is NEVER written (execute is
    forced off), no viewer windows open and no prompt is ever shown. The saved
    image is what --approve later applies byte-for-byte after the user marks rows.

    only_albums (--covers-csv FILE): consider ONLY these album roots (typically
    parsed from a coverage CSV); listed folders that are missing or hold no .mp3
    are reported and skipped.

    Text frames are never rewritten and no file is moved or renamed; the only MP3
    write is the APIC frame of an ACCEPTED upgrade (saved strictly ID3v2.4).
    Fail-safe: network errors, gated-out results, EOF and declines all keep the
    existing cover untouched.
    """
    album_roots = set()
    for root, dirs, files in os.walk(library_dir):
        if not any(f.lower().endswith(".mp3") for f in files):
            continue
        if os.path.relpath(root, library_dir) == ".":
            continue   # loose files directly in the library root have no album folder
        if DISC_DIR_RE.match(os.path.basename(root)):
            album_roots.add(os.path.dirname(root))
        else:
            album_roots.add(root)
    album_roots = sorted(album_roots)

    if scope:
        scope_abs = os.path.abspath(scope)
        base = scope_abs if os.path.isdir(scope_abs) else os.path.dirname(scope_abs)
        album_roots = [r for r in album_roots
                       if r == base or r.startswith(base + os.sep)
                       or base.startswith(r + os.sep)]
        if not album_roots:
            print(f"ERROR: no album found under --source: {scope}")
            sys.exit(1)
        print(f"=== Cover pass scoped to {os.path.relpath(base, library_dir)} "
              f"({len(album_roots)} album(s)) ===")
    if only_albums is not None:
        wset = {os.path.abspath(p) for p in only_albums}
        existing = set(album_roots)
        album_roots = [r for r in album_roots if r in wset]
        for p in sorted(wset - existing):
            print(f"  NOTE: CSV album not found: {os.path.relpath(p, library_dir)}")
        if not album_roots:
            print(f"ERROR: none of the {len(wset)} albums from the CSV exist in this library")
            sys.exit(1)
        print(f"=== Cover pass limited to the CSV list: {len(album_roots)} of "
              f"{len(wset)} listed album(s) ===")
    scoped = scope is not None
    n_total = len(album_roots)

    if review_dir:
        execute = False          # review is read-only by definition
        review_dir = os.path.abspath(os.path.expanduser(review_dir))
        os.makedirs(review_dir, exist_ok=True)
    review_rows = []

    n_promoted = n_removed = n_upgraded = n_declined = 0
    n_nomatch = n_standard = n_untouched = n_aborted = n_reviewed = 0

    def rel(p):
        return os.path.relpath(p, library_dir)

    abort = False
    for i, aroot in enumerate(album_roots, 1):
        # ---- local: one cover at the album root, no per-disc duplicates ----
        promoted, removed, mismatches = promote_disc_covers(aroot, execute=execute)
        if promoted:
            n_promoted += 1
            tagline = "" if execute else " (dry run)"
            print(f"[{i:03d}/{n_total:03d}] PROMOTED {rel(promoted)} -> {rel(aroot)}/cover.jpg{tagline}")
        if removed:
            n_removed += removed
            note = "" if execute else " (dry run)"
            # name the album when no PROMOTED line above identifies it
            where = "" if promoted else f"{rel(aroot)}: "
            print(f"          {where}removed {removed} identical per-disc cover(s){note}")
        for m in mismatches:
            print(f"          KEPT differing disc cover (not deleted): {rel(m)}")

        if abort:
            n_aborted += 1
            continue

        # ---- current root cover size ----
        cover_path = os.path.join(aroot, "cover.jpg")
        size_ref = cover_path if os.path.exists(cover_path) else promoted
        cur_size = None
        if size_ref:
            try:
                cur_size = Image.open(size_ref).size
            except Exception:
                cur_size = None
        if cur_size and min(cur_size) >= min_size:
            n_standard += 1
            continue
        if not online:
            n_untouched += 1
            continue

        # ---- identity from the first track of the album ----
        # os.walk, NOT glob: album folders contain literal '[2020]' brackets which
        # glob would parse as a character class and match nothing.
        mp3s = []
        for r, _d, fs in os.walk(aroot):
            for fn in fs:
                if fn.lower().endswith(".mp3"):
                    mp3s.append(os.path.join(r, fn))
        mp3s.sort()
        if not mp3s:
            continue
        try:
            tags = ID3(mp3s[0])
        except Exception:
            n_nomatch += 1
            continue

        def frame_text(key):
            v = tags.get(key)
            if v is None:
                return ""
            if hasattr(v, "text"):
                return " ".join(str(x) for x in v.text)
            return str(v)

        album = frame_text("TALB").strip()
        albumartist = frame_text("TPE2").strip() or frame_text("TPE1").strip()
        if not album or not albumartist:
            n_nomatch += 1
            print(f"[{i:03d}/{n_total:03d}] {rel(aroot)}: kept (missing album/album-artist tags)")
            continue

        # ---- fetch a gated, strictly larger candidate ----
        try:
            cand = fetch_album_cover(albumartist, album, target_size=target_size)
        except Exception:
            cand = None
        time.sleep(polite_delay)   # politeness: pause after every network attempt
        if not cand:
            n_nomatch += 1
            print(f"[{i:03d}/{n_total:03d}] {rel(aroot)}: kept (no confident larger image found)")
            continue
        cur_min = min(cur_size) if cur_size else 0
        if min(cand["src_size"]) <= cur_min:
            n_nomatch += 1
            cur_desc0 = f"{cur_size[0]}x{cur_size[1]}" if cur_size else "no cover"
            print(f"[{i:03d}/{n_total:03d}] {rel(aroot)}: kept (candidate "
                  f"{cand['src_size'][0]}x{cand['src_size'][1]} not larger than {cur_desc0})")
            continue

        cur_desc = f"{cur_size[0]}x{cur_size[1]}" if cur_size else "no cover.jpg"
        print(f"[{i:03d}/{n_total:03d}] {rel(aroot)}")
        print(f"          {cur_desc} -> candidate 1200x1200 from {cand['source']} "
              f"(source {cand['src_size'][0]}x{cand['src_size'][1]}, "
              f"t={cand['t_sim']:.2f} a={cand['a_sim']:.2f})")
        print(f"          {cand['url']}")

        # ---- review mode: keep the candidate offline, never touch the library ----
        if review_dir:
            idx = len(review_rows) + 1
            fname = (f"{idx:03d} - {sanitize_component(albumartist)} - "
                     f"{sanitize_component(album)}.jpg")
            with open(os.path.join(review_dir, fname), "wb") as vf:
                vf.write(cand["bytes"])
            cover_md5 = ""
            if os.path.exists(cover_path):
                with open(cover_path, "rb") as cf:
                    cover_md5 = hashlib.md5(cf.read()).hexdigest()
            review_rows.append({
                "image": fname,
                "album_root": aroot,
                "current": f"{cur_size[0]}x{cur_size[1]}" if cur_size else "",
                "current_md5": cover_md5,
                "candidate_src": f"{cand['src_size'][0]}x{cand['src_size'][1]}",
                "source": cand["source"],
                "t_sim": f"{cand['t_sim']:.2f}",
                "a_sim": f"{cand['a_sim']:.2f}",
                "url": cand["url"],
                "status": "skip",
            })
            n_reviewed += 1
            print(f"          REVIEW saved {fname}")
            continue

        # ---- preview (opens in the viewer) + confirmation ----
        # Execute: viewer + y/N prompt, temp preview removed after the answer.
        # Scoped dry run: viewer only - no prompt, candidate kept on disk so the
        # fetch can be inspected without anything being applied.
        # Plain dry run: report only (a library-wide sweep must not spawn windows).
        accepted = auto
        tmp_path = None
        if not auto and (execute or scoped):
            tmp_fd, tmp_path = tempfile.mkstemp(suffix=".jpg", prefix="cover_candidate_")
            os.close(tmp_fd)
            with open(tmp_path, "wb") as tf:
                tf.write(cand["bytes"])
            try:
                subprocess.Popen(["xdg-open", tmp_path],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except Exception:
                print(f"          (viewer could not open - view manually: {tmp_path})")

        if not auto and execute:
            try:
                ans = input("          Replace this cover? [y/N/q] ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                ans = ""
            if tmp_path and os.path.exists(tmp_path):
                try:
                    os.remove(tmp_path)
                except OSError:
                    pass
            if ans == "q":
                abort = True
                n_declined += 1
                print("          kept (declined) - aborting remaining fetches")
                continue
            accepted = ans in ("y", "yes")
        elif tmp_path:
            print(f"          DRY RUN - nothing applied; preview kept at {tmp_path}")

        if not accepted:
            if execute and not auto:
                n_declined += 1
                print("          kept (declined)")
            else:
                # dry run (never prompts) or --auto: report what would happen
                n_upgraded += 1
                print("          would upgrade cover.jpg + APIC" + (" (--auto)" if auto else " (dry run)"))
            continue

        if not execute:
            n_upgraded += 1
            print("          would upgrade cover.jpg + APIC (dry run)")
            continue

        with open(cover_path, "wb") as cf:
            cf.write(cand["bytes"])
        for m in mp3s:
            try:
                id3 = ID3(m)
            except Exception:
                continue
            id3.delall("APIC")
            id3["APIC"] = APIC(encoding=3, mime="image/jpeg", type=3,
                               desc="Cover", data=cand["bytes"])
            id3.save(m, v2_version=4, v1=0)
        n_upgraded += 1
        print(f"          UPGRADED {cur_desc} -> 1200x1200 ({cand['source']})")

    print("\n" + "=" * 120)
    if review_dir:
        manifest = write_review_manifest(review_dir, review_rows)
        sheet = write_review_sheet(review_dir, review_rows)
        print(f"Cover review (read-only): {n_total} albums | {n_reviewed} candidate(s) "
              f"saved, already {min_size}px: {n_standard}, no match/too small: {n_nomatch}")
        if not online:
            print(f"Online fetch disabled (--no-online): {n_untouched} album(s) left untouched.")
        print(f"  contact sheet: {sheet}")
        print(f"  manifest:      {manifest}")
        print("  1) open the contact sheet and decide per album")
        print("  2) set the wanted manifest rows to status 'approve'")
        print(f"  3) apply exactly those: organize_music.py --approve {review_dir} --execute")
        return
    mode = "EXECUTE" if execute else "DRY RUN"
    print(f"Cover pass ({mode}): {n_total} albums | root covers promoted: {n_promoted}, "
          f"disc duplicates removed: {n_removed} | upgraded: {n_upgraded}, "
          f"declined: {n_declined}, no match/too small: {n_nomatch}, "
          f"already {min_size}px: {n_standard}")
    if not online:
        print(f"Online fetch disabled (--no-online): {n_untouched} album(s) below "
              f"{min_size}px left untouched.")
    if abort:
        print(f"Aborted after preview decline: {n_aborted} album(s) not considered.")
    if not execute:
        print("DRY RUN: no files were modified. Run with '--fetch-covers --execute' to apply.")

REVIEW_MANIFEST_COLS = ["image", "album_root", "current", "current_md5",
                        "candidate_src", "source", "t_sim", "a_sim", "url", "status"]

def write_review_manifest(review_dir, rows):
    """Write review_dir/manifest.csv (one row per saved candidate)."""
    manifest = os.path.join(review_dir, "manifest.csv")
    with open(manifest, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=REVIEW_MANIFEST_COLS)
        w.writeheader()
        w.writerows(rows)
    return manifest

def write_review_sheet(review_dir, rows):
    """Write review_dir/index.html: side-by-side contact sheet of every candidate.

    Left thumb = the album's current cover.jpg (file:// link, read-only), right
    thumb = the saved candidate; metadata shows sizes, source and match scores.
    """
    esc = html.escape
    parts = [
        "<!doctype html>", '<meta charset="utf-8">', "<title>Cover review</title>",
        "<style>"
        "body{font-family:system-ui,sans-serif;background:#141414;color:#ddd;margin:24px}"
        "h1{font-size:20px}.sub{color:#999;font-size:13px;margin:6px 0 20px;max-width:70em}"
        ".row{display:flex;gap:18px;align-items:flex-start;border-top:1px solid #333;padding:14px 0}"
        ".thumb{width:170px;height:170px;object-fit:cover;background:#000;"
        "border:1px solid #444;border-radius:4px}"
        ".ph{display:flex;align-items:center;justify-content:center;color:#666;font-size:12px}"
        ".old{color:#e88}.new{color:#8c8}"
        ".meta{font-size:13px;line-height:1.6}.path{color:#777}"
        "a{color:#7ab}"
        "</style>",
        f"<h1>Cover review &mdash; {len(rows)} candidate(s)</h1>",
        '<div class="sub">Left: the cover currently in the library. Right: the fetched '
        '1200x1200 candidate. Nothing is written to the library until rows are marked '
        "'approve' in manifest.csv and applied with --approve --execute.</div>",
    ]
    for i, r in enumerate(rows, 1):
        album_root = r.get("album_root", "")
        artist = os.path.basename(os.path.dirname(album_root))
        album = os.path.basename(album_root)
        if r.get("current_md5"):
            cur_uri = "file://" + urllib.parse.quote(
                os.path.join(album_root, "cover.jpg"))
            cur_img = f'<img class="thumb" src="{cur_uri}" alt="current cover">'
        else:
            cur_img = '<div class="thumb ph">no cover</div>'
        cand_uri = urllib.parse.quote(r.get("image", ""))
        url = esc(r.get("url", ""), quote=True)
        cur_desc = esc(r.get("current", "")) or "none"
        parts.append(
            '<div class="row">'
            f'{cur_img}'
            f'<img class="thumb" src="{cand_uri}" alt="candidate">'
            '<div class="meta">'
            f'<b>{i:03d}</b> &mdash; {esc(artist)} / {esc(album)}<br>'
            f'<span class="old">current {cur_desc}</span> &rarr; '
            f'<span class="new">1200x1200 from {esc(r.get("source", ""))} '
            f'(source {esc(r.get("candidate_src", ""))}, '
            f't={esc(r.get("t_sim", ""))} a={esc(r.get("a_sim", ""))})</span><br>'
            f'<a href="{url}">{url}</a><br>'
            f'<span class="path">{esc(album_root)}</span><br>'
            f'status: <b>{esc(r.get("status", ""))}</b>'
            "</div></div>")
    sheet = os.path.join(review_dir, "index.html")
    with open(sheet, "w", encoding="utf-8") as fh:
        fh.write("\n".join(parts))
    return sheet

def approve_cover_review(review_dir: str, library_dir: str, execute: bool = False,
                         min_size: int = 1200):
    """Apply a --review manifest (--approve DIR; dry run by default, --execute writes).

    Reads review_dir/manifest.csv and applies ONLY rows with status 'approve',
    using the SAVED candidate image - the exact bytes that were confirmed, no
    network round-trip. A row is skipped when the album folder or the saved image
    is gone, when the album sits outside the library, when the candidate itself is
    below min_size, or when cover.jpg no longer matches the md5 recorded at review
    time (the album changed under us - re-run --review instead).

    Writes only cover.jpg and the APIC frame of the album's tracks (strictly
    ID3v2.4); text frames are never rewritten and nothing is renamed or moved.
    """
    manifest = os.path.join(os.path.abspath(os.path.expanduser(review_dir)), "manifest.csv")
    review_dir = os.path.dirname(manifest)
    if not os.path.isfile(manifest):
        print(f"ERROR: no manifest.csv in {review_dir} "
              f"(run 'organize_music.py --fetch-covers --review {review_dir}' first)")
        sys.exit(1)
    with open(manifest, newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))

    lib_real = os.path.realpath(library_dir)
    n_rows = len(rows)
    n_applied = n_would = n_approved = n_not = n_skipped = 0

    for i, row in enumerate(rows, 1):
        if (row.get("status") or "").strip().lower() != "approve":
            n_not += 1
            continue
        n_approved += 1
        aroot = (row.get("album_root") or "").strip()
        img = (row.get("image") or "").strip()
        img_path = os.path.join(review_dir, img) if img else ""
        label = aroot or img or "?"

        problems = []
        if not aroot or not os.path.isdir(aroot):
            problems.append("album folder missing")
        elif not os.path.realpath(aroot).startswith(lib_real + os.sep):
            problems.append("album outside the library")
        if not img_path or not os.path.isfile(img_path):
            problems.append("saved candidate missing")
        if not problems:
            try:
                with Image.open(img_path) as im:
                    if min(im.size) < min_size:
                        problems.append(f"candidate only {im.size[0]}x{im.size[1]}")
            except Exception:
                problems.append("saved candidate unreadable")
        cover_path = os.path.join(aroot, "cover.jpg") if aroot else ""
        if not problems:
            cur_md5 = ""
            if os.path.exists(cover_path):
                with open(cover_path, "rb") as cf:
                    cur_md5 = hashlib.md5(cf.read()).hexdigest()
            if cur_md5 != (row.get("current_md5") or "").strip():
                problems.append("cover.jpg changed since review (re-run --review)")
        if problems:
            n_skipped += 1
            print(f"[{i:03d}/{n_rows:03d}] SKIP {label}: {'; '.join(problems)}")
            continue

        if not execute:
            n_would += 1
            print(f"[{i:03d}/{n_rows:03d}] would apply {label}")
            continue

        with open(img_path, "rb") as vf:
            data = vf.read()
        with open(cover_path, "wb") as cf:
            cf.write(data)
        n_mp3 = 0
        for r, _d, fs in os.walk(aroot):
            for fn in sorted(fs):
                if not fn.lower().endswith(".mp3"):
                    continue
                m = os.path.join(r, fn)
                try:
                    id3 = ID3(m)
                except Exception:
                    continue
                id3.delall("APIC")
                id3["APIC"] = APIC(encoding=3, mime="image/jpeg", type=3,
                                   desc="Cover", data=data)
                id3.save(m, v2_version=4, v1=0)
                n_mp3 += 1
        n_applied += 1
        print(f"[{i:03d}/{n_rows:03d}] APPLIED {label}: cover.jpg + APIC x {n_mp3} track(s)")

    print("\n" + "=" * 120)
    mode = "EXECUTE" if execute else "DRY RUN"
    done = n_applied if execute else n_would
    verb = "applied" if execute else "would apply"
    print(f"Cover review ({mode}): {n_rows} row(s) | approved: {n_approved} | "
          f"{verb}: {done} | skipped: {n_skipped} | not approved: {n_not}")
    if not execute:
        print(f"DRY RUN: no files were modified. Run with "
              f"'--approve {review_dir} --execute' to write.")

def purge_mb_tags(source_path: str, execute: bool = False):
    """Remove MusicBrainz metadata (TXXX:MusicBrainz *, UFID) from --source target(s).

    --source may be a single .mp3 or a folder (searched recursively). ONLY MusicBrainz
    frames are touched: every other tag, the audio stream, artwork and file names stay
    exactly as they are. Dry run by default - add --execute to write (strictly ID3v2.4).
    """
    if not os.path.exists(source_path):
        print(f"ERROR: --source does not exist: {source_path}")
        sys.exit(1)
    if os.path.isfile(source_path):
        files = [source_path] if source_path.lower().endswith(".mp3") else []
    else:
        files = sorted(os.path.join(r, f)
                       for r, _d, fs in os.walk(source_path)
                       for f in fs if f.lower().endswith(".mp3"))
    if not files:
        print(f"ERROR: no .mp3 files found under: {source_path}")
        sys.exit(1)

    def mb_keys(tags):
        return [k for k in tags.keys()
                if "musicbrainz" in k.lower() or k.startswith("UFID")]

    dir_mode = os.path.isdir(source_path)
    n_files = n_hits = n_frames = 0
    for i, f in enumerate(files, 1):
        try:
            tags = ID3(f)
        except Exception:
            continue
        n_files += 1
        mb = mb_keys(tags)
        if not mb:
            continue
        n_hits += 1
        n_frames += len(mb)
        disp = os.path.relpath(f, source_path) if dir_mode else os.path.basename(f)
        print(f"[{i:04d}/{len(files):04d}] {disp}: {len(mb)} frame(s)")
        for k in mb:
            print(f"          - {k}")
        if execute:
            for k in mb:
                del tags[k]
            tags.save(f, v2_version=4, v1=0)

    print("\n" + "=" * 120)
    mode = "EXECUTE" if execute else "DRY RUN"
    print(f"MusicBrainz purge ({mode}): {n_files} readable file(s) scanned | "
          f"{n_hits} file(s) carry {n_frames} MB/UFID frame(s).")
    if not execute:
        print("DRY RUN: no files were modified. Run with '--purge-mb --execute' to apply.")


def split_artists_pass(source_path: str, execute: bool = False):
    """Rewrite legacy single-value TPE1 credits into ID3v2.4 null-separated
    multi-values, the way Picard writes them (dry run by default).

    --source may be a single .mp3 or a folder (searched recursively), anywhere on
    disk. Only single-value TPE1 frames whose text carries artist separators are
    rewritten; multi-value frames, plain single names, singular acts
    (KNOWN_ENSEMBLES) and credits equal to the album artist/artist folder are
    reported and left untouched. The dry run prints a before->after table for
    every change; --execute writes strictly ID3v2.4 and touches nothing else -
    all other tags, artwork, audio and file names stay byte-identical.
    """
    if not os.path.exists(source_path):
        print(f"ERROR: --source does not exist: {source_path}")
        sys.exit(1)
    if os.path.isfile(source_path):
        files = [source_path] if source_path.lower().endswith(".mp3") else []
    else:
        files = sorted(os.path.join(r, f)
                       for r, _d, fs in os.walk(source_path)
                       for f in fs if f.lower().endswith(".mp3"))
    if not files:
        print(f"ERROR: no .mp3 files found under: {source_path}")
        sys.exit(1)

    dir_mode = os.path.isdir(source_path)
    n_files = n_rewrite = n_values = n_kept = n_multi = 0
    for i, f in enumerate(files, 1):
        try:
            tags = ID3(f)
        except Exception:
            continue
        n_files += 1
        tpe1 = tags.get("TPE1")
        if tpe1 is None:
            continue
        disp = os.path.relpath(f, source_path) if dir_mode else os.path.basename(f)
        vals = [str(v).strip() for v in tpe1.text if str(v).strip()]
        if len(vals) != 1:
            if len(vals) > 1:
                n_multi += 1   # already proper multi-value: idempotent skip
            continue
        credit = vals[0]
        tpe2 = tags.get("TPE2")
        guards = [" ".join(str(x) for x in tpe2.text) if tpe2 is not None else "",
                  artist_folder_name(f)]
        parts = normalized_tpe1_values(tpe1, guards)
        if parts is None:
            if re.search(r"[;,+/]|\s&\s", credit):
                n_kept += 1
                ck = normalize_artist_key(credit)
                guard_hit = any(ck == g or ck.replace("/", "_") == g
                                for g in (normalize_artist_key(x) for x in guards if x))
                reason = "album artist guard" if guard_hit else "known ensemble"
                print(f"[{i:04d}/{len(files):04d}] {disp}: "
                      f"kept as ONE artist ({reason})  {credit!r}")
            continue
        n_rewrite += 1
        n_values += len(parts)
        print(f"[{i:04d}/{len(files):04d}] {disp}:")
        print(f"          {credit!r}")
        print(f"       -> {parts}")
        if execute:
            tags.setall("TPE1", [TPE1(encoding=3, text=parts)])
            tags.save(f, v2_version=4, v1=0)

    print("\n" + "=" * 120)
    mode = "EXECUTE" if execute else "DRY RUN"
    print(f"Artist split ({mode}): {n_files} readable file(s) scanned | "
          f"{n_rewrite} credit(s) -> {n_values} value(s) | "
          f"{n_kept} singular act(s) kept whole | {n_multi} already multi-value.")
    if not execute:
        print("DRY RUN: no files were modified. Review the table above, then run "
              "with '--split-artists --execute' to apply.")

def main():
    parser = argparse.ArgumentParser(description="Organize unsorted music into ~/Music/Library/Music with online metadata & 1200px artwork")
    parser.add_argument("--source", "-s", default=DEFAULT_SOURCE_DIR, help="Source folder OR a single .mp3 file (default: ~/Music/TO-SORT)")
    parser.add_argument("--library", "-l", default=DEFAULT_LIBRARY_DIR, help="Target library directory (default: ~/Music/Library/Music)")
    parser.add_argument("--dry-run", action="store_true", help="Perform a dry run without modifying files")
    parser.add_argument("--execute", action="store_true", help="Execute the actual reorganization")
    parser.add_argument("--no-online", action="store_true", help="Disable online metadata and artwork scraping")
    parser.add_argument("--no-prompt", action="store_true",
                        help="Never ask for manual tags when no online match is found")
    parser.add_argument("--migrate-discs", action="store_true",
                        help="One-time: move existing multi-disc tracks in the library into 'Disc NN' subfolders (does not touch --source)")
    parser.add_argument("--fetch-covers", action="store_true",
                        help="Art-only pass over the library: promote disc covers to the album root, "
                             "remove identical per-disc duplicates, and fetch higher-res covers behind "
                             "a viewer preview + confirmation (never touches text tags or file paths). "
                             "Scope it with --source pointing at an album/artist folder or an .mp3 "
                             "inside the library; a scoped dry run fetches and shows the candidate "
                             "without applying anything")
    parser.add_argument("--auto", action="store_true",
                        help="With --fetch-covers: skip the preview prompt and accept every candidate "
                             "that passes the automatic similarity gates")
    parser.add_argument("--review", metavar="DIR", default=None,
                        help="Batch-fetch every below-min-size album cover into DIR as numbered "
                             "candidate .jpg files plus manifest.csv and an index.html contact "
                             "sheet, for offline confirmation. Read-only: the library is never "
                             "written, no viewer windows open, no prompt is shown. Open "
                             "DIR/index.html, then mark the wanted manifest rows 'approve'")
    parser.add_argument("--approve", metavar="DIR", default=None,
                        help="Apply the manifest rows marked 'approve' from a --review DIR, using "
                             "the SAVED candidate images (the exact bytes that were confirmed - "
                             "no re-fetch). Dry run by default; --execute writes cover.jpg + the "
                             "APIC frame only (strictly ID3v2.4, text tags never touched)")
    parser.add_argument("--covers-csv", metavar="FILE", default=None,
                        help="With --fetch-covers or --review: consider ONLY the albums listed "
                             "in FILE, a CSV with an 'album' column of library-relative paths "
                             "(e.g. Scripts/covers_below_1200.csv). Listed folders that no "
                             "longer exist are reported and skipped")
    parser.add_argument("--purge-mb", action="store_true",
                        help="Remove MusicBrainz tags (TXXX:MusicBrainz *, UFID) from the .mp3 "
                             "file(s) under --source (a folder is searched recursively). Only MB "
                             "frames are touched; dry run by default, add --execute to write "
                             "(strictly ID3v2.4)")
    parser.add_argument("--split-artists", action="store_true",
                        help="One-time harmonize: rewrite single-value TPE1 credits "
                             "('A; B', 'A, B', 'A & B') into ID3v2.4 null-separated "
                             "multi-values like Picard, scoped to --source (a track or "
                             "folder anywhere). Dry run prints a before->after table; "
                             "--execute writes; singular acts (Royal & the Serpent, "
                             "ac/dc ...) and album-artist credits are never split")
    args = parser.parse_args()

    source_dir = os.path.abspath(os.path.expanduser(args.source))
    library_dir = os.path.abspath(os.path.expanduser(args.library))

    if not args.execute and not args.dry_run:
        args.dry_run = True

    if args.migrate_discs:
        migrate_discs(library_dir, execute=args.execute)
        return

    if args.review and args.approve:
        print("ERROR: --review and --approve are two separate steps "
              "(fetch candidates first, apply them later)")
        sys.exit(1)
    if args.covers_csv and not (args.fetch_covers or args.review):
        print("ERROR: --covers-csv only applies to --fetch-covers or --review")
        sys.exit(1)

    if args.fetch_covers or args.review or args.approve:
        # The cover passes are LIBRARY operations; --source only scopes them when it
        # points inside the library (an album folder, an artist folder or an mp3).
        # The default --source (TO-SORT) means "whole library".
        # --approve takes its scope from the manifest, so --source is ignored there.
        scope = None
        default_src = os.path.abspath(os.path.expanduser(DEFAULT_SOURCE_DIR))
        if not args.approve and source_dir != default_src:
            lib_real = os.path.realpath(library_dir)
            src_real = os.path.realpath(source_dir)
            if src_real != lib_real and not src_real.startswith(lib_real + os.sep):
                print(f"ERROR: --fetch-covers operates on the library; --source must point "
                      f"inside {library_dir} to scope the pass (got: {source_dir})")
                sys.exit(1)
            scope = source_dir
        only_albums = covers_csv_albums(args.covers_csv, library_dir) \
            if args.covers_csv else None
        if args.review:
            run_fetch_covers(library_dir, execute=False, online=(not args.no_online),
                             auto=False, scope=scope, review_dir=args.review,
                             only_albums=only_albums)
            return
        if args.approve:
            approve_cover_review(args.approve, library_dir, execute=args.execute)
            return
        run_fetch_covers(library_dir, execute=args.execute, online=(not args.no_online),
                         auto=args.auto, scope=scope, only_albums=only_albums)
        return

    if args.purge_mb:
        # --purge-mb operates directly on whatever --source points at (a track or a
        # folder anywhere - library, inbox, elsewhere); no library scope needed.
        purge_mb_tags(source_dir, execute=args.execute)
        return

    if args.split_artists:
        # Same scoping as --purge-mb: --source is the track/folder to harmonize.
        split_artists_pass(source_dir, execute=args.execute)
        return

    audio_files = []
    skipped_non_mp3 = []
    source_is_file = False
    if os.path.isfile(source_dir):
        # Single-file source: process just this track (tagging is strictly ID3v2.4 = MP3 only)
        source_is_file = True
        if not source_dir.lower().endswith(".mp3"):
            print(f"ERROR: --source file must be an .mp3 (ID3v2.4 tagging is MP3-only): {source_dir}")
            sys.exit(1)
        audio_files = [source_dir]
    elif os.path.isdir(source_dir):
        for ext in ("*.mp3", "*.flac", "*.m4a", "*.ogg"):
            for f in glob.glob(os.path.join(source_dir, "**", ext), recursive=True):
                # Tagging is strictly ID3v2.4 (MP3 only); never touch other formats
                if f.lower().endswith(".mp3"):
                    audio_files.append(f)
                else:
                    skipped_non_mp3.append(f)
    else:
        print(f"ERROR: --source does not exist: {source_dir}")
        sys.exit(1)

    audio_files.sort()
    print(f"=== Found {len(audio_files)} audio tracks in {source_dir} ===")
    if skipped_non_mp3:
        print(f"=== WARNING: {len(skipped_non_mp3)} non-MP3 track(s) skipped (ID3v2.4 tagging is MP3-only): ===")
        for f in skipped_non_mp3:
            print(f"  - {f}")
        print()
    if not args.no_online:
        print("=== Online Metadata & 1200px Artwork Scraping: ENABLED ===\n")
    else:
        print("=== Online Metadata & 1200px Artwork Scraping: DISABLED ===\n")

    library_artist_index = build_library_artist_index(library_dir)
    plans = [get_track_plan(f, library_artist_index, library_dir, use_online=(not args.no_online),
                            allow_prompt=(not args.no_prompt)) for f in audio_files]

    dest_set = set()
    collisions = []
    for p in plans:
        if p["dest_audio"] in dest_set:
            collisions.append((p["src_audio"], p["dest_audio"]))
        dest_set.add(p["dest_audio"])

    if collisions:
        print(f"ERROR: Found {len(collisions)} collision(s) among destination paths!")
        for src, dst in collisions:
            print(f"  Collision: {src} -> {dst}")
        sys.exit(1)

    print(f"{'STATUS':<8} {'ARTIST / TITLE':<42} -> {'DESTINATION FOLDER & FILE'}")
    print("-" * 120)

    cover_written = set()

    for idx, p in enumerate(plans, 1):
        rel_dest_dir = os.path.relpath(p["dest_dir"], library_dir)
        dest_filename = os.path.basename(p["dest_audio"])
        item_desc = f"{p['artist']} - {p['title']}"
        if len(item_desc) > 39:
            item_desc = item_desc[:36] + "..."

        status_str = f"[{idx:02d}/{len(plans):02d}]"
        print(f"{status_str:<8} {item_desc:<42} -> {rel_dest_dir}/{dest_filename}")

        details = []
        if p.get("online_source"):
            head = "Confident match via" if p.get("confident") else "Matched via"
            conf = f" [{p['confidence']}]" if p.get("confidence") else ""
            details.append(f"{head} {p['online_source']}{conf}")
        if p.get("web_source"):
            details.append("Web fallback filled missing fields (DuckDuckGo)")
        if p.get("manual"):
            details.append("Manual tags applied (ID3v2.4, no online match)")
        if p["tag_fixes"]:
            details.append(f"Tags updated: {list(p['tag_fixes'].keys())}")
        if p.get("artwork_bytes"):
            details.append("1200x1200px Art Ready")
        if details:
            print(f"         * {', '.join(details)}")

        if not args.dry_run and args.execute:
            id3 = ID3(p["src_audio"])

            # Only the Picard junk list is removed; MusicBrainz frames survive
            # (full MB removal = the opt-in --purge-mb pass only)
            for k in p["junk_keys_to_remove"]:
                if k in id3:
                    del id3[k]

            for k, v in p["tag_fixes"].items():
                if v == "" or v == [] or v is None:
                    # manual clear / empty value -> remove the frame entirely
                    if k in id3:
                        del id3[k]
                    continue
                if k == "TPE1":
                    # Picard-style multi-value artist credit ("A & B feat. C" -> 3 values)
                    id3["TPE1"] = TPE1(encoding=3, text=split_artist_credit(v))
                elif k == "TPE2":
                    id3["TPE2"] = TPE2(encoding=3, text=[v])
                elif k == "TALB":
                    id3["TALB"] = TALB(encoding=3, text=[v])
                elif k == "TIT2":
                    id3["TIT2"] = TIT2(encoding=3, text=[v])
                elif k == "TDRC":
                    id3["TDRC"] = TDRC(encoding=3, text=[v])
                elif k == "TDOR":
                    id3["TDOR"] = TDOR(encoding=3, text=[v])
                elif k == "TXXX:originalyear":
                    id3.delall("TXXX:originalyear")
                    id3["TXXX:originalyear"] = TXXX(encoding=3, desc="originalyear", text=[v])
                elif k == "TRCK":
                    id3["TRCK"] = TRCK(encoding=3, text=[v])
                elif k == "TPOS":
                    id3["TPOS"] = TPOS(encoding=3, text=[v])
                elif k == "TCON":
                    id3["TCON"] = TCON(encoding=3, text=[v])
                elif k == "TCOM":
                    id3["TCOM"] = TCOM(encoding=3, text=[v])
                elif k == "TPUB":
                    id3["TPUB"] = TPUB(encoding=3, text=[v])
                elif k == "TSRC":
                    id3["TSRC"] = TSRC(encoding=3, text=[v])
                elif k == "TCOP":
                    id3["TCOP"] = TCOP(encoding=3, text=[v])

            if "TYER" in id3:
                del id3["TYER"]

            # Embed exact 1200x1200px artwork
            if p["artwork_bytes"]:
                id3.delall("APIC")
                id3["APIC"] = APIC(
                    encoding=3,
                    mime="image/jpeg",
                    type=3,
                    desc="Cover",
                    data=p["artwork_bytes"],
                )

            # Normalize-on-save: a legacy single-value TPE1 ("A; B") becomes proper
            # ID3v2.4 null-separated multi-values under the ensemble + album-artist
            # guards, so the library converges to Picard's form on every reprocess.
            # Only the main pipeline saves here; --fetch-covers and --purge-mb keep
            # their text-tags-untouched contracts.
            tpe2_frame = id3.get("TPE2")
            new_tpe1 = normalized_tpe1_values(
                id3.get("TPE1"),
                [" ".join(str(x) for x in tpe2_frame.text) if tpe2_frame is not None else "",
                 artist_folder_name(p["dest_audio"])])
            if new_tpe1:
                id3["TPE1"] = TPE1(encoding=3, text=new_tpe1)

            # Always save strictly as ID3v2.4 and strip legacy ID3v1
            id3.save(p["src_audio"], v2_version=4, v1=0)

            os.makedirs(p["dest_dir"], exist_ok=True)
            # In-place run (single library file as --source): dest == src -> tags are
            # already saved above, nothing to move (shutil.move would raise SameFileError)
            if os.path.abspath(p["src_audio"]) != os.path.abspath(p["dest_audio"]):
                shutil.move(p["src_audio"], p["dest_audio"])

            # Save 1200x1200px cover.jpg at the album root (even when tracks use disc folders)
            if p["dest_album_root"] not in cover_written and not os.path.exists(p["dest_cover"]):
                if p["artwork_bytes"]:
                    os.makedirs(p["dest_album_root"], exist_ok=True)
                    with open(p["dest_cover"], "wb") as cf:
                        cf.write(p["artwork_bytes"])
                    cover_written.add(p["dest_album_root"])

    if args.dry_run:
        print("\n" + "=" * 120)
        print("DRY RUN COMPLETE: No files were moved or modified.")
        print(f"Ready to move all {len(plans)} tracks and their 1200x1200px album art into {library_dir}.")
        print("Run with '--execute' to perform the changes.")
    else:
        if not source_is_file:
            # Folder mode only: paired images were embedded, so drop them from the
            # source tree. A single-file --source keeps its folder untouched.
            for root, dirs, files in os.walk(source_dir, topdown=False):
                for f in files:
                    f_path = os.path.join(root, f)
                    if f.lower().endswith(('.jpg', '.jpeg', '.png')):
                        os.remove(f_path)
                if not os.listdir(root) and root != source_dir:
                    os.rmdir(root)

        print("\n" + "=" * 120)
        print(f"SUCCESS: All {len(plans)} tracks and their 1200x1200px album art have been organized into {library_dir}!")

if __name__ == "__main__":
    main()
