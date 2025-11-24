// keyhook_v4.c — X11 key inspector
// - Affiche dans une fenêtre les événements clavier (KeyPress/KeyRelease)
// - Montre: HW keycode (dépend serveur X), KeySym (dec + name), mods, texte, bytes
// - Mappe TOUT le clavier (min_keycode..max_keycode) avec XGetKeyboardMapping
// Compile: cc -O2 -Wall -Wextra -std=c11 -pthread keyhook_v4.c -o keyhook_v4 -lX11

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>

/* X11 */
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

/* -------------------- Globals -------------------- */
static atomic_int running = 1;

typedef struct {
    KeySym *map;            // contiguous array returned by XGetKeyboardMapping
    int min_kc, max_kc;     // inclusive range [min_kc, max_kc]
    int syms_per_kc;        // number of keysyms per keycode (commonly 1..4)
} KBMap;

#define MAX_LINES 32
#define LINE_W    256

typedef struct {
    char lines[MAX_LINES][LINE_W];
    int count;
} RingBuf;

/* -------------------- Time utils -------------------- */
static struct timespec t0;

static long ms_since_start(void) {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    long ms = (now.tv_sec - t0.tv_sec) * 1000L
            + (now.tv_nsec - t0.tv_nsec) / 1000000L;
    return ms;
}

static void sleep_ms(int ms) {
    struct timespec ts = { ms/1000, (long)(ms%1000)*1000000L };
    nanosleep(&ts, NULL);
}

/* -------------------- Ring buffer -------------------- */
static void rb_push(RingBuf *rb, const char *s) {
    if (rb->count < MAX_LINES) {
        for (int i = rb->count; i > 0; --i) {
            strncpy(rb->lines[i], rb->lines[i-1], LINE_W-1);
            rb->lines[i][LINE_W-1] = '\0';
        }
        strncpy(rb->lines[0], s, LINE_W-1);
        rb->lines[0][LINE_W-1] = '\0';
        rb->count++;
    } else {
        for (int i = MAX_LINES-1; i > 0; --i) {
            strncpy(rb->lines[i], rb->lines[i-1], LINE_W-1);
            rb->lines[i][LINE_W-1] = '\0';
        }
        strncpy(rb->lines[0], s, LINE_W-1);
        rb->lines[0][LINE_W-1] = '\0';
    }
}

/* -------------------- KBMap (full keyboard) -------------------- */
static int kbmap_load(Display *d, KBMap *kb) {
    kb->map = NULL; kb->min_kc = kb->max_kc = kb->syms_per_kc = 0;

    if (!d) return -1;

    int min_kc, max_kc;
    XDisplayKeycodes(d, &min_kc, &max_kc);    // typical 8..255
    int syms_per_kc = 0;
    KeySym *map = XGetKeyboardMapping(d, min_kc, max_kc - min_kc + 1, &syms_per_kc);
    if (!map) return -1;

    kb->map = map;
    kb->min_kc = min_kc;
    kb->max_kc = max_kc;
    kb->syms_per_kc = syms_per_kc;
    return 0;
}

static void kbmap_free(KBMap *kb, Display *d) {
    if (kb->map) XFree(kb->map);
    kb->map = NULL;
    kb->min_kc = kb->max_kc = kb->syms_per_kc = 0;
}

static void kbmap_dump_stdout(const KBMap *kb) {
    if (!kb || !kb->map) return;
    printf("Keyboard mapping (keycodes %d..%d), syms_per_keycode=%d\n",
           kb->min_kc, kb->max_kc, kb->syms_per_kc);
    printf("KC   : [level0] [level1] [level2] [level3] ... (KeySym names)\n");
    for (int kc = kb->min_kc; kc <= kb->max_kc; ++kc) {
        int idx = (kc - kb->min_kc) * kb->syms_per_kc;
        int empty = 1;
        for (int i = 0; i < kb->syms_per_kc; ++i) {
            if (kb->map[idx + i] != NoSymbol) { empty = 0; break; }
        }
        if (empty) continue; // non mappé
        printf("%-4d : ", kc);
        for (int i = 0; i < kb->syms_per_kc; ++i) {
            KeySym ks = kb->map[idx + i];
            const char *nm = (ks == NoSymbol) ? "-" : XKeysymToString(ks);
            printf("[%s]%s", nm ? nm : "-", (i+1<kb->syms_per_kc) ? " " : "");
        }
        printf("\n");
    }
}

/* -------------------- Modifiers -------------------- */
static void format_mods(unsigned int state, char *out, size_t outsz) {
    // Common masks: ShiftMask, LockMask, ControlMask, Mod1Mask(Alt), Mod2Mask(NumLock), Mod4Mask(Super)
    // We build a short string like "S+C+A+Super"
    char buf[64] = {0};
    int first = 1;
    struct { unsigned int mask; const char *name; } mods[] = {
        { ShiftMask,   "Shift" },
        { ControlMask, "Ctrl"  },
        { Mod1Mask,    "Alt"   },
#ifdef Mod3Mask
        { Mod3Mask,    "Mod3"  },
#endif
        { Mod4Mask,    "Super" },
#ifdef Mod5Mask
        { Mod5Mask,    "Mod5"  },
#endif
        { LockMask,    "Caps"  },
        { 0, NULL }
    };
    for (int i = 0; mods[i].name; ++i) {
        if (state & mods[i].mask) {
            if (!first) strncat(buf, "+", sizeof(buf)-strlen(buf)-1);
            strncat(buf, mods[i].name, sizeof(buf)-strlen(buf)-1);
            first = 0;
        }
    }
    if (first) strncpy(buf, "-", sizeof(buf)-1);
    snprintf(out, outsz, "%s", buf);
}

/* -------------------- Draw in window -------------------- */
static void draw_lines(Display *d, Window w, GC gc, XFontStruct *font, const RingBuf *rb) {
    int lh = (font ? (font->ascent + font->descent) : 14);
    int x = 8;
    int y = 8 + lh;
    XClearWindow(d, w);
    const char *hdr = "TIME(ms)  TYPE   HW_KC  KEYSYM(dec)  KEYSYM(name)     MODS        TEXT   BYTES(hex)";
    XDrawString(d, w, gc, x, y, hdr, (int)strlen(hdr));
    y += lh + 2;
    for (int i = rb->count-1; i >= 0; --i) {
        XDrawString(d, w, gc, x, y, rb->lines[i], (int)strlen(rb->lines[i]));
        y += lh;
    }
}

/* -------------------- Format one event line -------------------- */
static void format_event_line(char *out, size_t outsz,
                              const char *type, int hw_kc,
                              KeySym ks, unsigned int state,
                              const char *txt, int txtlen,
                              const unsigned char *raw, int rawlen)
{
    long tms = ms_since_start();
    const char *ksname = XKeysymToString(ks);
    char mods[64]; format_mods(state, mods, sizeof(mods));

    // TEXT: imprimables seulement
    char tb[32] = {0};
    int n = (txtlen > 0 && txtlen < (int)sizeof(tb)) ? txtlen : (txtlen > 0 ? (int)sizeof(tb)-1 : 0);
    if (n > 0) memcpy(tb, txt, n);

    // BYTES(hex)
    char hex[128] = {0};
    for (int i = 0; i < rawlen && (int)strlen(hex) <= (int)sizeof(hex)-3; ++i) {
        char h[4]; snprintf(h, sizeof(h), "%02X", raw[i]);
        strncat(hex, h, sizeof(hex)-strlen(hex)-1);
    }

    snprintf(out, outsz, "%8ld  %-6s %-6d %-12lu %-15s  %-10s  %-5s  %s",
             tms, type, hw_kc, (unsigned long)ks, ksname ? ksname : "unknown",
             mods, n ? tb : "", hex);
}

/* -------------------- Main X11 logic -------------------- */
int main(int argc, char **argv) {
    int dump_map = 0;
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--dump-map")) dump_map = 1;
    }

    clock_gettime(CLOCK_MONOTONIC, &t0);
    XInitThreads();

    Display *d = XOpenDisplay(NULL);
    if (!d) {
        fprintf(stderr, "Error: no X display. Set DISPLAY or run in X11.\n");
        return 1;
    }

    // Load full keyboard map
    KBMap kb;
    if (kbmap_load(d, &kb) == 0 && dump_map) {
        kbmap_dump_stdout(&kb);
        printf("---- end of keyboard map ----\n");
        fflush(stdout);
    }

    int s = DefaultScreen(d);
    unsigned long black = BlackPixel(d, s), white = WhitePixel(d, s);

    // Window
    int W = 820, H = 520;
    Window w = XCreateSimpleWindow(d, RootWindow(d, s), 80, 80, W, H, 0, black, black);
    XSelectInput(d, w, ExposureMask | KeyPressMask | KeyReleaseMask | StructureNotifyMask);
    XStoreName(d, w, "keyhook v4 — press ESC to quit (focus me)");
    XMapWindow(d, w);

    // GC + monospaced font
    GC gc = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, gc, white);
    XSetBackground(d, gc, black);
    XFontStruct *font = XLoadQueryFont(d, "fixed");
    if (font) XSetFont(d, gc, font->fid);

    RingBuf rb = { .count = 0 };
    // Ligne de tête
    rb_push(&rb, "--------------------------------------------------------------------------");

    int mapped = 0;

    while (running) {
        while (XPending(d) > 0) {
            XEvent e; XNextEvent(d, &e);
            if (e.type == MapNotify) {
                mapped = 1;
                draw_lines(d, w, gc, font, &rb);
            } else if (e.type == Expose) {
                if (mapped) draw_lines(d, w, gc, font, &rb);
            } else if (e.type == KeyPress || e.type == KeyRelease) {
                XKeyEvent *ke = (XKeyEvent*)&e;

                // keysym (logique)
                KeySym ks = XLookupKeysym(ke, 0);

                // texte + raw bytes (XLookupString renvoie ISO-8859-1, suffisant pour touches "classiques")
                char txt[32] = {0};
                unsigned char raw[32] = {0};
                XComposeStatus cs; memset(&cs, 0, sizeof(cs));
                int len = XLookupString(ke, (char*)raw, (int)sizeof(raw), NULL, &cs);
                int tlen = 0;
                for (int i = 0; i < len && tlen < (int)sizeof(txt)-1; ++i) {
                    unsigned char c = raw[i];
                    txt[tlen++] = (c >= 32 && c <= 126) ? (char)c : '.';
                }
                txt[tlen] = '\0';

                char line[LINE_W];
                format_event_line(line, sizeof(line),
                                  (e.type == KeyPress) ? "press" : "release",
                                  (int)ke->keycode, ks, ke->state,
                                  txt, tlen, raw, len);
                rb_push(&rb, line);
                draw_lines(d, w, gc, font, &rb);

                if (ks == XK_Escape && e.type == KeyPress) {
                    running = 0;
                }
            }
        }
        if (!running) break;
        sleep_ms(10);
    }

    if (font) XFreeFont(d, font);
    XFreeGC(d, gc);
    XDestroyWindow(d, w);
    XCloseDisplay(d);
    kbmap_free(&kb, d);
    return 0;
}
