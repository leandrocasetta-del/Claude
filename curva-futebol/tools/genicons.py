#!/usr/bin/env python3
"""Gera os icones PNG do Curva sem dependencias externas (zlib stdlib)."""
import zlib, struct, math, os

BG = (6, 18, 31)          # #06121F
GREEN = (46, 230, 166)    # #2ee6a6
CYAN = (41, 194, 255)     # #29c2ff
WHITE = (245, 250, 255)
DARK = (29, 39, 51)

def lerp(a, b, t): return tuple(int(a[i] + (b[i]-a[i])*t) for i in range(3))

def png(path, size, transparent_bg=False, safe=0.0):
    """safe: fracao de margem (icone adaptativo/maskable usa conteudo menor)."""
    W = H = size
    px = bytearray()
    cx = cy = size/2
    ball_r = size*0.20*(1-safe*0.6)
    # bola posicionada um pouco acima-direita
    bx, by = size*0.58, size*0.42
    for y in range(H):
        px.append(0)  # filter byte
        for x in range(W):
            r = g = b = 0; a = 255
            # fundo
            if transparent_bg:
                a = 0
            else:
                t = (x+y)/(2*size)
                r, g, b = lerp(BG, (10, 34, 54), t)
            # swoosh em curva (faixa que curva)
            # parametriza uma curva de bezier-ish: distancia a um arco
            ang = math.atan2(y-cy, x-cx)
            dist = math.hypot(x-cx, y-cy)
            arc_r = size*0.34*(1-safe*0.5)
            band = abs(dist - arc_r)
            in_arc = (-2.6 < ang < 0.5)
            if in_arc and band < size*0.055:
                tt = (ang+2.6)/3.1
                col = lerp(GREEN, CYAN, max(0,min(1,tt)))
                edge = 1 - band/(size*0.055)
                if a == 0: a = int(255*edge)
                r, g, b = col if a==255 else lerp((r,g,b), col, edge)
                if a != 255: r,g,b = col; a = int(255*min(1,edge*1.4))
            # bola
            db = math.hypot(x-bx, y-by)
            if db < ball_r:
                shade = 1 - (db/ball_r)*0.35
                col = tuple(int(c*shade) for c in WHITE)
                r, g, b = col; a = 255
                # pentagono central
                if db < ball_r*0.34:
                    r, g, b = DARK
            px += bytes((r, g, b, a))
    raw = bytes(px)
    comp = zlib.compress(raw, 9)
    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        return c + struct.pack(">I", zlib.crc32(typ+data) & 0xffffffff)
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0)  # RGBA
    with open(path, "wb") as f:
        f.write(sig + chunk(b'IHDR', ihdr) + chunk(b'IDAT', comp) + chunk(b'IEND', b''))
    print("wrote", path, size)

here = os.path.dirname(os.path.abspath(__file__))
www = os.path.join(here, "..", "www", "icons")
assets = os.path.join(here, "..", "assets")
os.makedirs(www, exist_ok=True); os.makedirs(assets, exist_ok=True)

png(os.path.join(www, "icon-192.png"), 192)
png(os.path.join(www, "icon-512.png"), 512)
png(os.path.join(www, "icon-512-maskable.png"), 512, safe=0.18)
png(os.path.join(assets, "icon_master_1024.png"), 1024)
png(os.path.join(assets, "icon_foreground_1024.png"), 1024, transparent_bg=True, safe=0.22)
