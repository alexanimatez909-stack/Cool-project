"""Builds journal-icon.png (512x512): a thick leather journal held up at about 60 degrees and turned
towards the viewer, in real 3D perspective, on a brass frame that follows the book's outline.

How it works:
1. The book is a 3D box (front board, page block, back board). Every corner is rotated and projected
   with perspective, so the top of the book is further away and narrower.
2. The front cover design is drawn FLAT (cover-flat.svg), rendered to an image, then warped onto the
   projected cover with a perspective transform (SVG itself can't do perspective).
3. The frame is the book's outline pushed outwards, with a gold double line, beads and curls at the corners.
Run: python3 make_journal_icon.py   (needs headless Chromium, numpy and Pillow)
"""
import math, subprocess, os
import numpy as np
from PIL import Image

CHROME = "/opt/pw-browsers/chromium-1194/chrome-linux/chrome"
HERE = os.path.dirname(os.path.abspath(__file__))
S = 1024                          # working canvas (shrunk to 512 at the end for smooth edges)

# ---------- the book in 3D ----------
W, H, T = 150, 196, 46            # cover width, height, thickness
BOARD = 4                         # leather board thickness
LIFT = 60                         # degrees up from lying flat (90 would be standing straight up)
TURN = 24                         # degrees turned towards the viewer (the page edges come round to face you)
DIST = 520                        # camera distance (smaller = stronger perspective)

lean = math.radians(90 - LIFT)
turn = math.radians(TURN)

def rot(p):
    # book space: x right, y down, z away from the viewer; centred on the book
    x, y, z = p[0] - W / 2, p[1] - H / 2, p[2] - T / 2
    y, z = y * math.cos(lean) + z * math.sin(lean), z * math.cos(lean) - y * math.sin(lean)  # top leans away
    x, z = x * math.cos(turn) + z * math.sin(turn), z * math.cos(turn) - x * math.sin(turn)  # spine swings back, page edge towards you
    return (x, y, z + DIST)

def proj(p):
    x, y, z = rot(p)
    return (x * DIST / z, y * DIST / z)

def box(x0, x1, y0, y1, z0, z1):
    c = lambda i, j, k: ((x0, x1)[i], (y0, y1)[j], (z0, z1)[k])
    return {  # each face: 4 corners and the name used for colouring
        "front": [c(0,0,0), c(1,0,0), c(1,1,0), c(0,1,0)],
        "back": [c(0,0,1), c(1,0,1), c(1,1,1), c(0,1,1)],
        "left": [c(0,0,0), c(0,1,0), c(0,1,1), c(0,0,1)],
        "right": [c(1,0,0), c(1,1,0), c(1,1,1), c(1,0,1)],
        "top": [c(0,0,0), c(1,0,0), c(1,0,1), c(0,0,1)],
        "bottom": [c(0,1,0), c(1,1,0), c(1,1,1), c(0,1,1)],
    }

def facing(face, centre):
    # a face is visible if its outward normal points towards the camera
    a, b, c = (np.array(rot(p)) for p in face[:3])
    n = np.cross(b - a, c - a)
    mid = np.mean([rot(p) for p in face], axis=0)
    if np.dot(n, mid - np.array(rot(centre))) < 0:
        n = -n
    return np.dot(n, mid) < 0

centre = (W / 2, H / 2, T / 2)
back_board = box(0, W, 0, H, T - BOARD, T)
pages = box(0, W - 5, 5, H - 5, BOARD, T - BOARD)
front_board = box(0, W, 0, H, 0, BOARD)

# the frame's size around the book (book units)
RING_INNER, RING_OUTER, PLATE = 22, 30, 36
ZF = T / 2   # the frame sits at the book's middle depth, so it wraps round it evenly

# fit the frame into the middle of the canvas (leaving room for the curls and the J)
all_pts = [proj(p) for m in (PLATE,) for p in
           [(-m, -m, ZF), (W + m, -m, ZF), (W + m, H + m, ZF), (-m, H + m, ZF)]]
all_pts += [proj(p) for b in (back_board, front_board) for f in b.values() for p in f]
xs, ys = [p[0] for p in all_pts], [p[1] for p in all_pts]
room = S - 2 * 88
scale = min(room / (max(xs) - min(xs)), room / (max(ys) - min(ys)))
ox = S / 2 - scale * (max(xs) + min(xs)) / 2
oy = S / 2 - scale * (max(ys) + min(ys)) / 2 - 18
def P(p):
    x, y = proj(p)
    return (ox + x * scale, oy + y * scale)
def poly(pts):
    return " ".join("%.1f,%.1f" % p for p in pts)

# ---------- faces behind the cover ----------
FILL = {
    ("back", "front"): "#2c1007", ("back", "right"): "url(#boardEdge)", ("back", "bottom"): "url(#boardEdge)",
    ("back", "top"): "#3a1608", ("back", "left"): "url(#spine)",
    ("pages", "right"): "url(#pageSide)", ("pages", "bottom"): "url(#pageBottom)", ("pages", "top"): "url(#pageSide)",
    ("front", "right"): "url(#boardEdge)", ("front", "bottom"): "url(#boardEdge)", ("front", "top"): "#6a2e1b",
    ("front", "left"): "url(#spine)",
}
layers = []
for name, b in (("back", back_board), ("pages", pages), ("front", front_board)):
    for fname, face in b.items():
        if name == "front" and fname == "front":
            continue  # the cover image goes here
        if not facing(face, centre) or (name, fname) not in FILL:
            continue
        stroke = "#8a6a3a" if name == "pages" else "#170701"
        layers.append('<polygon points="%s" fill="%s" stroke="%s" stroke-width="3" stroke-linejoin="round"/>'
                      % (poly([P(p) for p in face]), FILL[(name, fname)], stroke))
        if name == "pages":  # lines for the pages
            for i in range(1, 9):
                z = BOARD + (T - 2 * BOARD) * i / 9
                if fname == "right":
                    a, c = P((W - 5, 5, z)), P((W - 5, H - 5, z))
                elif fname == "bottom":
                    a, c = P((0, H - 5, z)), P((W - 5, H - 5, z))
                else:
                    continue
                layers.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#b09160" stroke-width="1.6" opacity="0.8"/>'
                              % (*a, *c))
    if name == "pages":  # the ribbon bookmark hangs out of the bottom of the pages
        top = P((W * 0.84, H - 5, T * 0.5))
        top2 = P((W * 0.84 + 16, H - 5, T * 0.5))
        L = 150
        layers.append('<path d="M%.1f,%.1f L%.1f,%.1f L%.1f,%.1f L%.1f,%.1f L%.1f,%.1f Z" fill="url(#ribbon)" stroke="#3a0708" stroke-width="3" stroke-linejoin="round"/>'
                      % (top[0], top[1], top2[0], top2[1], top2[0] + 6, top2[1] + L, (top[0] + top2[0]) / 2 + 3, top2[1] + L - 22, top[0] + 6, top[1] + L))

# ---------- the frame: a board in 3D just behind the book, so it has exactly the book's angle ----------
def frame_rect(m):
    # corners of a rectangle m units bigger than the book on every side, in a plane behind the back cover
    zf = ZF
    return [(-m, -m, zf), (W + m, -m, zf), (W + m, H + m, zf), (-m, H + m, zf)]

def hull(points):
    pts = sorted(set(points))
    def half(seq):
        out = []
        for p in seq:
            while len(out) >= 2 and (out[-1][0] - out[-2][0]) * (p[1] - out[-2][1]) - (out[-1][1] - out[-2][1]) * (p[0] - out[-2][0]) <= 0:
                out.pop()
            out.append(p)
        return out
    lower, upper = half(pts), half(reversed(pts))
    return lower[:-1] + upper[:-1]

book_outline = [P(p) for b in (back_board, front_board) for f in b.values() for p in f]
h = hull([(round(x, 1), round(y, 1)) for x, y in book_outline])   # used for the book's shadow

plate3d, ring_outer3d, ring_inner3d = frame_rect(PLATE), frame_rect(RING_OUTER), frame_rect(RING_INNER)
plate = [P(p) for p in plate3d]
ring_outer = [P(p) for p in ring_outer3d]
ring_inner = [P(p) for p in ring_inner3d]
centroid = np.mean(np.array(plate), axis=0)

beads = []
for i in range(4):
    a, b = np.array(ring_outer3d[i], float), np.array(ring_outer3d[(i + 1) % 4], float)
    count = int(np.linalg.norm(b - a) // 9)
    for k in range(1, count):
        t = k / count
        if 0.13 < t < 0.87 and not (i == 2 and 0.3 < t < 0.7):  # room for the curls and the J
            x, y = P(tuple(a + (b - a) * t))
            beads.append('<circle cx="%.1f" cy="%.1f" r="6"/>' % (x, y))
curls = []
for p in plate:
    d = np.array(p) - centroid
    ang = math.degrees(math.atan2(d[1], d[0]))
    q = np.array(p) - d / np.linalg.norm(d) * 8
    curls.append('<use href="#curlPair" transform="translate(%.1f %.1f) rotate(%.1f) scale(3.4)"/>' % (q[0], q[1], ang + 90))

# the fancy J on a brass cartouche in the middle of the bottom edge
jx, jy = P((W / 2, H + RING_OUTER, ZF))
jy += 4

defs = '''
    <linearGradient id="boardEdge" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#4a1d0c"/><stop offset="1" stop-color="#220b03"/>
    </linearGradient>
    <linearGradient id="spine" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#2e1106"/><stop offset="0.5" stop-color="#6a2e1b"/><stop offset="1" stop-color="#3a1608"/>
    </linearGradient>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#f6df9c"/><stop offset="0.45" stop-color="#cfa24c"/><stop offset="1" stop-color="#7a5219"/>
    </linearGradient>
    <linearGradient id="goldSide" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#6b4716"/><stop offset="0.5" stop-color="#e2bb67"/><stop offset="1" stop-color="#6b4716"/>
    </linearGradient>
    <linearGradient id="pageSide" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#f3e9cf"/><stop offset="1" stop-color="#c9b07c"/>
    </linearGradient>
    <linearGradient id="pageBottom" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#ece0bf"/><stop offset="1" stop-color="#b99f69"/>
    </linearGradient>
    <radialGradient id="plate" cx="0.45" cy="0.4" r="0.75">
      <stop offset="0" stop-color="#3a2a1c"/><stop offset="1" stop-color="#140f0a"/>
    </radialGradient>
    <radialGradient id="ball" cx="0.35" cy="0.3" r="0.8">
      <stop offset="0" stop-color="#fff1c2"/><stop offset="0.45" stop-color="#cfa24c"/><stop offset="1" stop-color="#553611"/>
    </radialGradient>
    <linearGradient id="ribbon" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#5e0f12"/><stop offset="0.5" stop-color="#a02226"/><stop offset="1" stop-color="#5e0f12"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="150%" height="150%">
      <feDropShadow dx="8" dy="14" stdDeviation="12" flood-color="#000" flood-opacity="0.6"/>
    </filter>
    <filter id="blur" x="-20%" y="-20%" width="150%" height="150%"><feGaussianBlur stdDeviation="10"/></filter>
    <g id="curlPair" fill="none" stroke-linecap="round">
      <path d="M0,0 C-4,-10 -16,-13 -21,-6 C-24,-1 -18,3 -15,-1" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,0 C-4,-10 -16,-13 -21,-6 C-24,-1 -18,3 -15,-1" stroke="url(#goldSide)" stroke-width="2.6"/>
      <path d="M0,0 C4,-10 16,-13 21,-6 C24,-1 18,3 15,-1" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,0 C4,-10 16,-13 21,-6 C24,-1 18,3 15,-1" stroke="url(#goldSide)" stroke-width="2.6"/>
      <circle cx="0" cy="-2" r="3" fill="url(#ball)" stroke="#2a1806" stroke-width="0.8"/>
    </g>'''

back_svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" viewBox="0 0 {S} {S}">
  <defs>{defs}</defs>
  <style>@font-face {{ font-family: Pinyon; src: url("PinyonScript-Regular.ttf"); }}</style>
  <!-- brass frame, at the same angle as the book -->
  <g filter="url(#shadow)">
    <polygon points="{poly(plate)}" fill="url(#plate)" stroke="#2a1806" stroke-width="10" stroke-linejoin="round"/>
    <polygon points="{poly(ring_outer)}" fill="none" stroke="#2a1806" stroke-width="22" stroke-linejoin="round"/>
    <polygon points="{poly(ring_outer)}" fill="none" stroke="url(#gold)" stroke-width="15" stroke-linejoin="round"/>
    <polygon points="{poly(ring_inner)}" fill="none" stroke="url(#gold)" stroke-width="5" stroke-linejoin="round"/>
    <g fill="url(#ball)" stroke="#2a1806" stroke-width="2">{"".join(beads)}</g>
    {"".join(curls)}
  </g>
  <!-- the book's shadow on the frame -->
  <polygon points="{poly(h)}" fill="#000" opacity="0.55" filter="url(#blur)" transform="translate(10 16)"/>
  {"".join(layers)}
  <!-- the J cartouche -->
  <g filter="url(#shadow)" transform="translate({jx:.1f} {jy:.1f}) scale(1.2)">
    <use href="#curlPair" transform="translate(-58 6) rotate(-90) scale(2.6)"/>
    <use href="#curlPair" transform="translate(58 6) rotate(90) scale(2.6)"/>
    <ellipse rx="62" ry="70" fill="url(#plate)" stroke="#2a1806" stroke-width="18"/>
    <ellipse rx="62" ry="70" fill="none" stroke="url(#gold)" stroke-width="10"/>
    <ellipse rx="50" ry="58" fill="none" stroke="url(#gold)" stroke-width="3"/>
    <text x="4" y="40" text-anchor="middle" font-family="Pinyon" font-size="132" fill="#2a1806" stroke="#2a1806" stroke-width="10" stroke-linejoin="round">J</text>
    <text x="4" y="40" text-anchor="middle" font-family="Pinyon" font-size="132" fill="url(#gold)">J</text>
  </g>
</svg>'''

# ---------- the front cover, drawn flat ----------
CS = 8  # render the flat cover 8x so the warp stays sharp
cover_svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W * CS}" height="{H * CS}" viewBox="0 0 {W} {H}">
  <defs>{defs}
    <linearGradient id="leather" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#7c3820"/><stop offset="0.55" stop-color="#57240f"/><stop offset="1" stop-color="#3a1608"/>
    </linearGradient>
    <filter id="grain" x="0" y="0" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="1.6" numOctaves="2" seed="3"/>
      <feColorMatrix type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.3 0"/>
      <feComposite in2="SourceGraphic" operator="in"/>
    </filter>
    <g id="corner" fill="none" stroke-linecap="round">
      <path d="M0,26 C0,11 11,0 26,0" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,26 C0,11 11,0 26,0" stroke="url(#gold)" stroke-width="3"/>
      <path d="M26,0 C34,0 37,6 33,10 C30,12 27,9 29,7" stroke="url(#gold)" stroke-width="2"/>
      <path d="M0,26 C0,34 6,37 10,33 C12,30 9,27 7,29" stroke="url(#gold)" stroke-width="2"/>
      <path d="M8,20 C8,13 13,8 20,8 C15,11 12,14 11,19 Z" fill="url(#gold)" stroke="#2a1806" stroke-width="1"/>
    </g>
  </defs>
  <rect x="0" y="0" width="{W}" height="{H}" rx="3" fill="url(#leather)" stroke="#220c04" stroke-width="2"/>
  <rect x="0" y="0" width="{W}" height="{H}" rx="3" filter="url(#grain)" fill="#000"/>
  <rect x="0" y="0" width="22" height="{H}" rx="3" fill="url(#spine)"/>
  <g stroke="url(#gold)" stroke-width="3">
    <line x1="2" y1="28" x2="20" y2="28"/><line x1="2" y1="{H - 28}" x2="20" y2="{H - 28}"/>
  </g>
  <rect x="30" y="10" width="{W - 40}" height="{H - 20}" rx="4" fill="none" stroke="url(#gold)" stroke-width="2.5"/>
  <rect x="36" y="16" width="{W - 52}" height="{H - 32}" rx="3" fill="none" stroke="#cfa24c" stroke-width="0.9" opacity="0.8"/>
  <use href="#corner" transform="translate(34,14)"/>
  <use href="#corner" transform="translate({W - 14},14) scale(-1,1)"/>
  <use href="#corner" transform="translate(34,{H - 14}) scale(1,-1)"/>
  <use href="#corner" transform="translate({W - 14},{H - 14}) scale(-1,-1)"/>
  <g stroke-linecap="round">
    <line x1="104" y1="118" x2="122" y2="138" stroke="#2a1806" stroke-width="10"/>
    <line x1="104" y1="118" x2="122" y2="138" stroke="url(#gold)" stroke-width="6"/>
    <circle cx="88" cy="100" r="23" fill="none" stroke="#2a1806" stroke-width="10"/>
    <circle cx="88" cy="100" r="23" fill="none" stroke="url(#gold)" stroke-width="6"/>
    <circle cx="88" cy="100" r="18" fill="#caa55a" opacity="0.18"/>
    <path d="M75,91 C79,84 86,81 93,82" fill="none" stroke="#fff3cf" stroke-width="2" opacity="0.8"/>
  </g>
  <path d="M6,1.5 H{W - 6}" stroke="#c07a52" stroke-width="1.2" opacity="0.6"/>
</svg>'''

def render(svg, w, h, out):
    html = os.path.join(HERE, "_render.html")
    open(html, "w").write(f'<html><body style="margin:0;background:transparent">{svg}</body></html>')
    subprocess.run([CHROME, "--headless", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
                    "--default-background-color=00000000", "--virtual-time-budget=3000", f"--window-size={w},{h + 200}",
                    f"--screenshot={out}", "file://" + html], check=True, capture_output=True)
    os.remove(html)
    return Image.open(out).convert("RGBA").crop((0, 0, w, h))

open(os.path.join(HERE, "journal-icon.svg"), "w").write(back_svg)
open(os.path.join(HERE, "journal-icon-cover.svg"), "w").write(cover_svg)
base = render(back_svg, S, S, "/tmp/_icon_back.png")
cover = render(cover_svg, W * CS, H * CS, "/tmp/_icon_cover.png")

# warp the flat cover onto the projected front face
dst = [P(p) for p in front_board["front"]]            # top-left, top-right, bottom-right, bottom-left
src = [(0, 0), (W * CS, 0), (W * CS, H * CS), (0, H * CS)]
A, rhs = [], []
for (x, y), (u, v) in zip(dst, src):                  # solve output -> input mapping for PIL
    A.append([x, y, 1, 0, 0, 0, -u * x, -u * y]); rhs.append(u)
    A.append([0, 0, 0, x, y, 1, -v * x, -v * y]); rhs.append(v)
coeffs = np.linalg.solve(np.array(A, float), np.array(rhs, float))
warped = cover.transform((S, S), Image.PERSPECTIVE, tuple(coeffs), Image.BICUBIC)

icon = Image.alpha_composite(base, warped).resize((512, 512), Image.LANCZOS)
icon.save(os.path.join(HERE, "journal-icon.png"))
print("saved journal-icon.png")
