"""Builds journal-icon.svg: a thick journal seen at an angle, on a round brass medallion.
The book is drawn flat and then placed with a 2D transform; its thickness (page edges and back
cover) is computed from the transformed corners so everything lines up."""
import math

W, H = 150, 196                       # flat cover size
theta = math.radians(-12)             # tilt
skew = math.radians(-9)               # turn (skewY)
sx = 0.86
T = (58, 44)                          # where the cover's top-left lands
t = (24, 13)                          # thickness direction (towards the page edges)

def M(x, y):
    x *= sx
    y = y + math.tan(skew) * x
    xr = x * math.cos(theta) - y * math.sin(theta)
    yr = x * math.sin(theta) + y * math.cos(theta)
    return (xr + T[0], yr + T[1])

a, b = math.cos(theta), math.sin(theta)
# matrix for the flat cover group: rotate * skewY * scale
k = math.tan(skew)
m = (sx * (a - b * k), sx * (b + a * k), -b, a, T[0], T[1])
matrix = "matrix(%.4f %.4f %.4f %.4f %.2f %.2f)" % m

TL, TR, BR, BL = M(0, 0), M(W, 0), M(W, H), M(0, H)
add = lambda p, d=1.0: (p[0] + t[0] * d, p[1] + t[1] * d)
def poly(pts):
    return " ".join("%.2f,%.2f" % p for p in pts)

# back cover (a little bigger than the pages, so leather shows past them)
back = [add(TL), add(TR), add(BR), add(BL)]
# page block faces (inset slightly from the covers)
inset = 0.1
pr = [TR, BR, add(BR, 0.92), add(TR, 0.92)]
pb = [BL, BR, add(BR, 0.92), add(BL, 0.92)]
page_lines = []
for i in range(1, 7):
    d = i / 7 * 0.92
    page_lines.append('<line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f"/>' % (*add(TR, d), *add(BR, d)))
    page_lines.append('<line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f"/>' % (*add(BL, d), *add(BR, d)))

# medallion ornaments
beads = []
for i in range(40):
    ang = i / 40 * 2 * math.pi
    beads.append('<circle cx="%.2f" cy="%.2f" r="1.7"/>' % (128 + 108 * math.cos(ang), 128 + 108 * math.sin(ang)))
curls = []
for ang in (45, 135, 225, 315):
    r = math.radians(ang)
    cx, cy = 128 + 116 * math.cos(r), 128 + 116 * math.sin(r)
    curls.append('<use xlink:href="#curlPair" transform="translate(%.2f %.2f) rotate(%d)"/>' % (cx, cy, ang + 90))

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="512" height="512" viewBox="0 0 256 256">
  <defs>
    <linearGradient id="leather" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#74331e"/><stop offset="0.55" stop-color="#57240f"/><stop offset="1" stop-color="#3a1608"/>
    </linearGradient>
    <linearGradient id="backLeather" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#3f170a"/><stop offset="1" stop-color="#240c04"/>
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
      <stop offset="0" stop-color="#f3e9cf"/><stop offset="1" stop-color="#cdb584"/>
    </linearGradient>
    <linearGradient id="pageBottom" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#e9dcb9"/><stop offset="1" stop-color="#bda571"/>
    </linearGradient>
    <radialGradient id="medallion" cx="0.45" cy="0.4" r="0.7">
      <stop offset="0" stop-color="#3a2a1c"/><stop offset="1" stop-color="#15100b"/>
    </radialGradient>
    <radialGradient id="ball" cx="0.35" cy="0.3" r="0.8">
      <stop offset="0" stop-color="#fff1c2"/><stop offset="0.45" stop-color="#cfa24c"/><stop offset="1" stop-color="#553611"/>
    </radialGradient>
    <linearGradient id="ribbon" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#5e0f12"/><stop offset="0.5" stop-color="#9c1f22"/><stop offset="1" stop-color="#5e0f12"/>
    </linearGradient>
    <filter id="grain" x="0" y="0" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="1.6" numOctaves="2" seed="3"/>
      <feColorMatrix type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.3 0"/>
      <feComposite in2="SourceGraphic" operator="in"/>
    </filter>
    <filter id="shadow" x="-20%" y="-20%" width="150%" height="150%">
      <feDropShadow dx="3" dy="5" stdDeviation="4" flood-color="#000" flood-opacity="0.6"/>
    </filter>
    <g id="corner" fill="none" stroke-linecap="round">
      <path d="M0,26 C0,11 11,0 26,0" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,26 C0,11 11,0 26,0" stroke="url(#gold)" stroke-width="3"/>
      <path d="M26,0 C34,0 37,6 33,10 C30,12 27,9 29,7" stroke="url(#gold)" stroke-width="2"/>
      <path d="M0,26 C0,34 6,37 10,33 C12,30 9,27 7,29" stroke="url(#gold)" stroke-width="2"/>
      <path d="M8,20 C8,13 13,8 20,8 C15,11 12,14 11,19 Z" fill="url(#gold)" stroke="#2a1806" stroke-width="1"/>
    </g>
    <g id="curlPair" fill="none" stroke-linecap="round">
      <path d="M0,0 C-4,-10 -16,-13 -21,-6 C-24,-1 -18,3 -15,-1" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,0 C-4,-10 -16,-13 -21,-6 C-24,-1 -18,3 -15,-1" stroke="url(#goldSide)" stroke-width="2.6"/>
      <path d="M0,0 C4,-10 16,-13 21,-6 C24,-1 18,3 15,-1" stroke="#2a1806" stroke-width="5"/>
      <path d="M0,0 C4,-10 16,-13 21,-6 C24,-1 18,3 15,-1" stroke="url(#goldSide)" stroke-width="2.6"/>
      <circle cx="0" cy="-2" r="3" fill="url(#ball)" stroke="#2a1806" stroke-width="0.8"/>
    </g>
  </defs>

  <!-- brass medallion behind the book -->
  <g filter="url(#shadow)">
    <circle cx="128" cy="128" r="116" fill="url(#medallion)" stroke="#2a1806" stroke-width="2"/>
    <circle cx="128" cy="128" r="113" fill="none" stroke="url(#gold)" stroke-width="5"/>
    <circle cx="128" cy="128" r="102" fill="none" stroke="url(#gold)" stroke-width="1.6"/>
    <g fill="url(#ball)" stroke="#2a1806" stroke-width="0.6">{"".join(beads)}</g>
    {"".join(curls)}
  </g>

  <g filter="url(#shadow)" transform="translate(126 128) scale(0.74) translate(-152 -122)">
    <!-- back cover, page edges, ribbon -->
    <polygon points="{poly(back)}" fill="url(#backLeather)" stroke="#1a0802" stroke-width="1.5" stroke-linejoin="round"/>
    <polygon points="{poly(pr)}" fill="url(#pageSide)" stroke="#8a6a3a" stroke-width="1" stroke-linejoin="round"/>
    <polygon points="{poly(pb)}" fill="url(#pageBottom)" stroke="#8a6a3a" stroke-width="1" stroke-linejoin="round"/>
    <g stroke="#b59a68" stroke-width="0.6" opacity="0.8">{"".join(page_lines)}</g>
    <g transform="{matrix}">
      <path d="M104,{H - 4} L118,{H - 4} L118,{H + 34} L111,{H + 27} L104,{H + 34} Z" fill="url(#ribbon)" stroke="#3a0708" stroke-width="1.2"/>
    </g>

    <!-- front cover, drawn flat and placed at an angle -->
    <g transform="{matrix}">
      <rect x="0" y="0" width="{W}" height="{H}" rx="7" fill="url(#leather)" stroke="#220c04" stroke-width="2"/>
      <rect x="0" y="0" width="{W}" height="{H}" rx="7" filter="url(#grain)" fill="#000"/>
      <rect x="0" y="0" width="22" height="{H}" rx="7" fill="url(#spine)"/>
      <g stroke="url(#gold)" stroke-width="3">
        <line x1="2" y1="28" x2="20" y2="28"/><line x1="2" y1="{H - 28}" x2="20" y2="{H - 28}"/>
      </g>
      <rect x="30" y="10" width="{W - 40}" height="{H - 20}" rx="4" fill="none" stroke="url(#gold)" stroke-width="2.5"/>
      <rect x="36" y="16" width="{W - 52}" height="{H - 32}" rx="3" fill="none" stroke="#cfa24c" stroke-width="0.9" opacity="0.8"/>
      <use xlink:href="#corner" transform="translate(34,14)"/>
      <use xlink:href="#corner" transform="translate({W - 14},14) scale(-1,1)"/>
      <use xlink:href="#corner" transform="translate(34,{H - 14}) scale(1,-1)"/>
      <use xlink:href="#corner" transform="translate({W - 14},{H - 14}) scale(-1,-1)"/>
      <g stroke-linecap="round">
        <line x1="104" y1="118" x2="122" y2="138" stroke="#2a1806" stroke-width="10"/>
        <line x1="104" y1="118" x2="122" y2="138" stroke="url(#gold)" stroke-width="6"/>
        <circle cx="88" cy="100" r="23" fill="none" stroke="#2a1806" stroke-width="10"/>
        <circle cx="88" cy="100" r="23" fill="none" stroke="url(#gold)" stroke-width="6"/>
        <circle cx="88" cy="100" r="18" fill="#caa55a" opacity="0.18"/>
        <path d="M75,91 C79,84 86,81 93,82" fill="none" stroke="#fff3cf" stroke-width="2" opacity="0.8"/>
      </g>
      <!-- light catching the top edge of the cover -->
      <path d="M8,1.5 H{W - 8}" stroke="#c07a52" stroke-width="1.2" opacity="0.6"/>
    </g>
  </g>
</svg>'''
open("journal-icon.svg", "w").write(svg)
open("render-icon.html", "w").write(f'<html><body style="margin:0;background:transparent">{svg}</body></html>')
