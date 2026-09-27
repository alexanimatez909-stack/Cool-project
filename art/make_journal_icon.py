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

# the frame's distance from the book, in canvas pixels (the same all the way round)
GAP_INNER, GAP_OUTER, GAP_PLATE = 30, 48, 62

# fit the book into the middle of the canvas, leaving room for the frame, curls and the J
all_pts = [proj(p) for b in (back_board, front_board) for f in b.values() for p in f]
xs, ys = [p[0] for p in all_pts], [p[1] for p in all_pts]
room = S - 2 * 185
scale = min(room / (max(xs) - min(xs)), room / (max(ys) - min(ys)))
ox = S / 2 - scale * (max(xs) + min(xs)) / 2
oy = S / 2 - scale * (max(ys) + min(ys)) / 2
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
        top = P((W * 0.58, H - 5, T * 0.5))
        top2 = P((W * 0.58 + 16, H - 5, T * 0.5))
        L = 95
        layers.append('<path d="M%.1f,%.1f L%.1f,%.1f L%.1f,%.1f L%.1f,%.1f L%.1f,%.1f Z" fill="url(#ribbon)" stroke="#3a0708" stroke-width="3" stroke-linejoin="round"/>'
                      % (top[0], top[1], top2[0], top2[1], top2[0] + 6, top2[1] + L, (top[0] + top2[0]) / 2 + 3, top2[1] + L - 22, top[0] + 6, top[1] + L))

# ---------- the frame: the book's outline pushed out by the same distance on every side ----------
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
h = hull([(round(x, 1), round(y, 1)) for x, y in book_outline])   # the book's outline on screen

# the book's 4 main sides (the 4 longest edges of its outline, in order); the short corner bits are skipped
n = len(h)
edges = [(np.array(h[i]), np.array(h[(i + 1) % n])) for i in range(n)]
longest = sorted(range(n), key=lambda i: -np.linalg.norm(edges[i][1] - edges[i][0]))[:4]
sides = [edges[i] for i in sorted(longest)]
area = sum(h[i][0] * h[(i + 1) % n][1] - h[(i + 1) % n][0] * h[i][1] for i in range(n))
outward = 1 if area > 0 else -1

def frame_quad(d):
    # move each side outwards by d pixels and find where neighbouring sides meet
    lines = []
    for a, b in sides:
        e = (b - a) / np.linalg.norm(b - a)
        lines.append((a + np.array([e[1], -e[0]]) * outward * d, e))
    out = []
    for i in range(4):
        (p1, d1), (p2, d2) = lines[i - 1], lines[i]
        t = np.linalg.solve(np.array([d1, -d2]).T, p2 - p1)[0]
        out.append(tuple(p1 + d1 * t))
    return out

plate, ring_outer, ring_inner = frame_quad(GAP_PLATE), frame_quad(GAP_OUTER), frame_quad(GAP_INNER)
centroid = np.mean(np.array(plate), axis=0)
jcorner = max(range(4), key=lambda i: plate[i][0] + plate[i][1])   # bottom-right corner gets the J

beads = []
for i in range(4):
    a, b = np.array(ring_outer[i]), np.array(ring_outer[(i + 1) % 4])
    count = int(np.linalg.norm(b - a) // 30)
    for k in range(1, count):
        t = k / count
        near_j = (i == jcorner and t < 0.3) or ((i + 1) % 4 == jcorner and t > 0.7)
        if 0.14 < t < 0.86 and not near_j:  # room for the curls and the J
            x, y = a + (b - a) * t
            beads.append('<circle cx="%.1f" cy="%.1f" r="6"/>' % (x, y))
curls = []
for i, p in enumerate(plate):
    if i == jcorner:
        continue
    d = np.array(p) - centroid
    ang = math.degrees(math.atan2(d[1], d[0]))
    q = np.array(p) - d / np.linalg.norm(d) * 8
    curls.append('<use href="#curlPair" transform="translate(%.1f %.1f) rotate(%.1f) scale(3.4)"/>' % (q[0], q[1], ang + 90))

# the J on a brass medallion in the bottom-right corner
jx, jy = ring_outer[jcorner][0] - 10, ring_outer[jcorner][1] - 60
jy = min(jy, S - 12 - 110 * 1.55)   # keep the curl inside the picture

J_PATHS = [('M-30,-92 C-14,-100 18,-84 40,-94', 16), ('M14,-88 L14,26', 30), ('M14,26 C14,82 -24,104 -58,86', 24), ('M-58,86 C-86,70 -80,34 -52,34', 16), ('M-52,34 C-38,34 -32,48 -42,56', 11)]
J_DARK = "".join('<path d="%s" stroke="#1e1004" stroke-width="%d"/>' % (d, w + 14) for d, w in J_PATHS)
J_GOLD = "".join('<path d="%s" stroke="url(#goldJ)" stroke-width="%d"/>' % (d, w) for d, w in J_PATHS)

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
    <linearGradient id="goldJ" gradientUnits="userSpaceOnUse" x1="-60" y1="-100" x2="40" y2="100">
      <stop offset="0" stop-color="#fbe7a8"/><stop offset="0.5" stop-color="#d6a94f"/><stop offset="1" stop-color="#8a5d1c"/>
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
  <style>@font-face {{ font-family: Playfair; src: url("PlayfairDisplay.ttf"); font-weight: 400 900; }}</style>
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
  <!-- the fancy J in the bottom-right corner: drawn as brush strokes, dark outline first, then gold -->
  <g filter="url(#shadow)" transform="translate({jx:.1f} {jy:.1f}) scale(1.55)" fill="none" stroke-linecap="round" stroke-linejoin="round">
    {J_DARK}
    <circle cx="-44" cy="52" r="15" fill="#1e1004"/><circle cx="-30" cy="-92" r="13" fill="#1e1004"/><circle cx="40" cy="-94" r="12" fill="#1e1004"/>
    {J_GOLD}
    <circle cx="-44" cy="52" r="9" fill="url(#ball)"/><circle cx="-30" cy="-92" r="8" fill="url(#ball)"/><circle cx="40" cy="-94" r="7" fill="url(#ball)"/>
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
