#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  fastfetch logo generator — haru / Artix Linux
#  Reads noctalia's kitty palette and paints the ASCII art with a smooth
#  24-bit vertical gradient. Because the palette is re-read on every run,
#  changing the noctalia theme changes this logo instantly — no hook,
#  no template registration, no cache to invalidate.
#
#  Called from config.jsonc via  "type": "command-raw"
#  Path: ~/.config/fastfetch/logo.sh
# ═══════════════════════════════════════════════════════════════════════

THEME="${HOME}/.config/kitty/themes/noctalia.conf"

# ── GRADIENT STOPS (top → bottom) ──────────────────────────────────────
# Light at the top, deep at the bottom. Interpolated across all 18 rows.
#
# IMPORTANT: color1 is deliberately NOT used. By ANSI convention color1 is
# the "error red" slot, and matugen preserves that meaning, so it stays red
# under every wallpaper — it would clash with any non-warm theme. Every
# other slot follows the theme's own hue.
#
# Palette ordered by lightness (this theme, hue 343 pink line):
#   color7 L95  near-white      color5 L75  pale
#   color2 L65  accent          color8 L42  deepest (low saturation)
#
# Want more contrast? Append color8:   STOPS=(color7 color2 color8)
# Want it flipped?     Reverse it:     STOPS=(color2 color7)
STOPS=(color7 color2)

# Fallbacks, used only if the theme file is missing (fresh machine, etc.)
FALLBACK=(f3f2f2 c18b9a)

# ── read one hex value out of the kitty theme ──────────────────────────
read_hex() {
  [ -r "$THEME" ] || return 1
  # match "color7   #f3f2f2" — first field exact, strip leading #
  awk -v key="$1" '$1 == key { gsub(/^#/, "", $2); print $2; exit }' "$THEME"
}

# ── resolve stops to r,g,b triples ─────────────────────────────────────
declare -a R G B
for idx in "${!STOPS[@]}"; do
  hex="$(read_hex "${STOPS[$idx]}")"
  # accept only a well-formed 6-digit hex, else fall back
  case "$hex" in
  [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) ;;
  *) hex="${FALLBACK[$idx]}" ;;
  esac
  R[$idx]=$((16#${hex:0:2}))
  G[$idx]=$((16#${hex:2:2}))
  B[$idx]=$((16#${hex:4:2}))
done

NSTOP=${#STOPS[@]}
SEGS=$((NSTOP - 1))

# ── the art ────────────────────────────────────────────────────────────
# quoted heredoc: nothing inside is expanded, so $ and ` stay literal
ART=$(
  cat <<'ASCIIART'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
⠀⠀⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⠀⠀
⠀⠀⣿⣿⣿⣿⡟⠛⠛⠛⠛⣿⣿⣿⣿⣿⣿⣿⣿⠛⠛⠛⠛⢻⣿⣿⣿⣿⠀⠀
⠀⠀⣿⣿⡟⠛⠃⠀⠀⠀⠀⠛⠛⣿⣿⣿⣿⠛⠛⠀⠀⠀⠀⠘⠛⢻⣿⣿⠀⠀
⣶⣶⣿⣿⡇⠀⠀⠀⢸⣿⣷⣶⠀⣿⣿⣿⣿⠀⠀⠀⠀⣿⣿⣶⡆⢸⣿⣿⣶⣶
⣿⣿⣿⣿⡇⠀⠀⠀⢸⣿⠿⠿⠀⣿⣿⣿⣿⠀⠀⠀⠀⣿⣿⠿⠇⢸⣿⣿⣿⣿
⣿⣿⣿⣿⣧⣤⡄⠀⠀⠀⠀⣤⣤⣿⣿⣿⣿⣤⣤⠀⠀⠀⠀⢠⣤⣼⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣧⣤⣤⣤⣤⣿⣿⣿⣿⣿⣿⣿⣿⣤⣤⣤⣤⣼⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⠀⢹⣿⣿⣿⣿⣿⣿⡇⠀⠀⠘⣿⣿⣿⣿⣿⣿⡇⠀⣿⣿⣿⣿⣿
⣿⣿⡏⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⠁⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢻⣿⣿
ASCIIART
)

mapfile -t ROWS <<<"$ART"
NROW=${#ROWS[@]}
LAST=$((NROW - 1))

# ── paint each row ─────────────────────────────────────────────────────
# Position along the ramp is computed in fixed point (x1000) because
# bash has no floating point arithmetic.
for i in "${!ROWS[@]}"; do
  if [ "$LAST" -le 0 ]; then
    pos=0
  else
    pos=$((i * SEGS * 1000 / LAST)) # 0 .. SEGS*1000
  fi

  seg=$((pos / 1000))
  frac=$((pos % 1000))

  # clamp the final row into the last segment
  if [ "$seg" -ge "$SEGS" ]; then
    seg=$((SEGS - 1))
    frac=1000
  fi

  nxt=$((seg + 1))
  r=$((R[seg] + (R[nxt] - R[seg]) * frac / 1000))
  g=$((G[seg] + (G[nxt] - G[seg]) * frac / 1000))
  b=$((B[seg] + (B[nxt] - B[seg]) * frac / 1000))

  printf '\033[38;2;%d;%d;%dm%s\033[0m\n' "$r" "$g" "$b" "${ROWS[$i]}"
done
