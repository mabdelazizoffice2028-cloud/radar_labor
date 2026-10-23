# DESIGN.md — Radar Labor V1 visual spec

Source of truth for all visual values. Implement as tokens in `core/ui` (ThemeData + a tokens class). Widgets never hardcode any value from this file.

## Direction
Blue is the primary identity color. Surfaces are a soft blend of blue and white (airy, clean, high contrast for outdoor sun use). Light theme only in V1 (no dark theme). Arabic RTL. Big, simple, glove-friendly controls.

## Brand and surface colors
| Token | Hex | Use |
|---|---|---|
| `primary` | `#1D4ED8` | App bar, primary buttons, selected states, links |
| `primaryDark` | `#1E3A8A` | Pressed state, status bar |
| `primarySoft` | `#DBE7FB` | Selected row background, chips, subtle fills (blue-white blend) |
| `background` | `#F3F7FE` | Screen background (very light blue-white) |
| `surface` | `#FFFFFF` | Cards, sheets, dialogs, input fields |
| `outline` | `#C9D6EC` | Dividers, borders |
| `textPrimary` | `#0F172A` | Main text |
| `textSecondary` | `#475569` | Secondary text (must keep contrast >= 4.5:1 on background) |
| `onPrimary` | `#FFFFFF` | Text/icons on primary |

App bar: solid `primary`, `onPrimary` title and icons. Bottom navigation (admin): `surface` background, selected item `primary` with `primarySoft` indicator.

## Semantic status colors (fixed by PRD §9, always paired with an icon and a text label, never color alone)
| Status | Color | Hex | Soft background |
|---|---|---|---|
| On site | Green | `#15803D` | `#DCFCE7` |
| Housing only | Yellow/amber | `#B45309` (text/icon) | `#FEF3C7` |
| Unknown | Red | `#B91C1C` | `#FEE2E2` |
| Justified | Cyan-blue | `#0E7490` | `#CFFAFE` |
| Not recorded yet | Gray | `#64748B` | `#E2E8F0` |

Justified uses cyan-blue so it stays visually distinct from the brand `primary`. Never use `primary` as a status color.

## Typography
- Font: **Cairo**, bundled as an asset (weights 400, 600, 700; downloaded once while online, listed under `flutter: fonts:`). No font package. Fallback: system Arabic sans.
- Scale (sp): body 16, bodySmall 14 (minimum anywhere), label 14/600, button 18/700, title 20/700, headline 24/700, big counters 32/700.
- Line height 1.4. Respect system font scaling up to 1.3x without overflow.
- Numbers use Western digits (0-9) everywhere.

## Layout
- Spacing scale (dp): 4, 8, 12, 16, 24, 32. Default screen padding 16.
- Corner radius: 12 (cards, buttons, inputs), 999 (chips).
- Minimum tap target 56dp height; list rows 64dp; primary action buttons full width, 56dp.
- Elevation: cards 1, sheets/dialogs 3. Prefer outline borders over heavy shadows.
- Sticky counter bar (site registration) and primary save button pinned at the bottom, above the system navigation bar.

## Components
- **Primary button:** filled `primary`, `onPrimary` text, 56dp. Secondary: outlined `primary`. Destructive (e.g. clear): outlined red.
- **Worker row:** name (16/600) + code and team (14, secondary); trailing tap area is the whole row. Marked-absent state: `unknown` soft background + red icon + text "غائب".
- **Status chip:** soft background + status color text + leading icon.
- **Dashboard cards (4):** `surface`, status-colored top accent strip, large counter (32/700), label below.
- **SLA timer:** neutral until limit, then red with text (not color alone).
- **Banners** ("you are recording for day X", "pending send"): `primarySoft` background with `primaryDark` text; warnings use amber soft background.
- **Snackbar/undo (8s):** dark `textPrimary` background, white text, action in `primarySoft`.
- **Empty/loading/error/offline states:** centered icon + one Arabic sentence + (if relevant) one action button. Offline is a calm informational banner, not an error.
- Icons: built-in Material icons only. Each status has a fixed icon (on site: check_circle, housing only: home, unknown: help/warning, justified: verified, not recorded: schedule).

## App identity
- App display name and `applicationId`: see `DECISIONS.md` (pending). Launcher icon: simple radar/location mark in white on `primary`, adaptive icon.
- Splash: `background` color with the icon centered.

## Motion
Minimal. 150-200ms standard transitions. No decorative animation.
