"""Build 1280x640 Open Graph banner for Tonkatsu Box."""
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1280, 640
OUT = '/work/docs/assets/og-image.png'

BG = (18, 18, 22)
ACCENT = (239, 123, 68)
WHITE = (245, 245, 245)
DIM = (200, 200, 210)

# Base canvas with a soft vertical gradient (top slightly darker than bottom)
canvas = Image.new('RGB', (W, H), BG)
grad = Image.new('RGB', (1, H), BG)
gpix = grad.load()
for y in range(H):
    t = y / (H - 1)
    # ease towards a slightly warmer / lighter tone at the bottom
    r = int(18 + (32 - 18) * t)
    g = int(18 + (24 - 18) * t)
    b = int(22 + (28 - 22) * t)
    gpix[0, y] = (r, g, b)
canvas = grad.resize((W, H), Image.BICUBIC)

# Tiled background pattern, very faint
tile = Image.open('/work/raw/background_tile.png').convert('RGBA')
# Reduce to ~7% alpha so it's a subtle texture
tile_a = tile.split()[-1]
tile_a = tile_a.point(lambda p: int(p * 0.07))
tile.putalpha(tile_a)
# Tile it
tw, th = tile.size
for y in range(0, H, th):
    for x in range(0, W, tw):
        canvas.paste(tile, (x, y), tile)

# Diagonal accent wash bottom-right
overlay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
od = ImageDraw.Draw(overlay)
od.polygon([(W * 0.6, H), (W, H * 0.4), (W, H)], fill=ACCENT + (40,))
canvas.paste(overlay, (0, 0), overlay)

draw = ImageDraw.Draw(canvas)

FONT_BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
FONT_REG = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
title_font = ImageFont.truetype(FONT_BOLD, 64)
tagline_font = ImageFont.truetype(FONT_REG, 24)
pill_font = ImageFont.truetype(FONT_BOLD, 16)
footer_font = ImageFont.truetype(FONT_BOLD, 20)

# Logo + title
logo = Image.open('/work/assets/images/logo.png').convert('RGBA')
logo.thumbnail((84, 84), Image.LANCZOS)
canvas.paste(logo, (56, 50), logo)
draw.text((158, 56), 'Tonkatsu Box', font=title_font, fill=WHITE)
draw.text((158, 132), 'Your media collection manager', font=tagline_font, fill=DIM)

# Feature list — two lines, accent bullets between items
feature_font = ImageFont.truetype(FONT_BOLD, 20)
rows = [
    ['Games', 'Movies & TV', 'Anime & Manga'],
    ['Visual Novels', 'Tier Lists', 'Mood Grids'],
]
y = 208
gap_y = 14
for row in rows:
    # Compute total width to draw with explicit colored bullets
    parts = []  # list of (text, color)
    for i, label in enumerate(row):
        if i > 0:
            parts.append(('  •  ', ACCENT))
        parts.append((label, WHITE))
    cx = 56
    bbox = draw.textbbox((0, 0), ''.join(p[0] for p in parts), font=feature_font)
    line_h = bbox[3] - bbox[1]
    for text, color in parts:
        draw.text((cx, y), text, font=feature_font, fill=color)
        w = draw.textbbox((0, 0), text, font=feature_font)[2]
        cx += w
    y += line_h + gap_y

# Integration icons row near the bottom of the left half
icon_names = [
    'icon_igdb_color.png',
    'icon_tmdb_color.png',
    'icon_anilist_color.png',
    'icon_myanimelist_color.png',
    'icon_steam_color.png',
    'icon_trakt_color.png',
    'ra_logo.png',
    'icon_vndb_color.png',
    'icon_steamgriddb_color.png',
    'icon_scrapper_color.png',
]
icon_size = 36
icon_gap = 14
icon_y = H - 130
icon_x = 56
draw.text((56, icon_y - 30), 'Powered by', font=ImageFont.truetype(FONT_REG, 16), fill=DIM)
for name in icon_names:
    p = f'/work/assets/images/{name}'
    try:
        ic = Image.open(p).convert('RGBA')
    except FileNotFoundError:
        continue
    ic.thumbnail((icon_size, icon_size), Image.LANCZOS)
    # Centre vertically against icon_size box
    yoff = icon_y + (icon_size - ic.height) // 2
    canvas.paste(ic, (icon_x, yoff), ic)
    icon_x += ic.width + icon_gap
    if icon_x > 560 - icon_size:
        break

draw.text((56, H - 50), 'Free  ·  Open Source  ·  MIT', font=footer_font, fill=ACCENT)


# Right-side app screenshots
def rounded(im, radius=14):
    mask = Image.new('L', im.size, 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([(0, 0), im.size], radius=radius, fill=255)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def shadowed(img, blur=22, offset=(0, 16), alpha=170):
    sh = Image.new('RGBA', (img.width + blur * 4, img.height + blur * 4), (0, 0, 0, 0))
    shape = Image.new('RGBA', img.size, (0, 0, 0, alpha))
    sh.paste(shape, (blur * 2 + offset[0], blur * 2 + offset[1]))
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    sh.paste(img, (blur * 2, blur * 2), img if img.mode == 'RGBA' else None)
    return sh


def load_app(path, target_w):
    im = Image.open(path).convert('RGBA')
    ratio = target_w / im.width
    return im.resize((target_w, int(im.height * ratio)), Image.LANCZOS)


# Three angled cards fanned across the right half (back → front).
# Cards pulled leftward to remove the gap between the left text block
# and the screenshots.
# Desktop back-cards
desktop_cards = [
    ('/work/raw/collection_desck.jpg', 620, -7, (W - 720, -110)),
    ('/work/raw/search_desck.jpg',     600, 2,  (W - 760, 130)),
]
for path, width, angle, anchor in desktop_cards:
    img = rounded(load_app(path, width), radius=18)
    img_s = shadowed(img, blur=32, alpha=200)
    rot = img_s.rotate(angle, resample=Image.BICUBIC, expand=True)
    canvas.paste(rot, anchor, rot)


# Mobile foreground card — sized by height, narrow portrait
def load_app_by_height(path, target_h):
    im = Image.open(path).convert('RGBA')
    ratio = target_h / im.height
    return im.resize((int(im.width * ratio), target_h), Image.LANCZOS)


phone = rounded(load_app_by_height('/work/raw/collection_mob.jpg', 540), radius=28)
phone_s = shadowed(phone, blur=34, offset=(0, 20), alpha=220)
phone_rot = phone_s.rotate(6, resample=Image.BICUBIC, expand=True)
# Anchor near the bottom-right, overlapping both desktop cards
canvas.paste(phone_rot, (W - phone_rot.width + 30, H - phone_rot.height + 40),
             phone_rot)

canvas.save(OUT, 'PNG', optimize=True)
print(f'wrote {OUT} ({W}x{H})')
