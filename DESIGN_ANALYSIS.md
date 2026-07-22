# Design Analysis → Doodle Word Quest

This document records the **high-level visual characteristics** observed in the
reference screenshots and translates them into an **original** Flutter design
system. No pixels, paths, characters, text, fonts, or layouts were traced,
cropped, imported, or reused. The screenshots informed *design language only*.

---

## 1. Background texture and grid proportions
- Observation: warm off-white paper with a faint square grid; grid cells are
  small relative to the touch targets so they read as texture, not structure.
- Decision: `NotebookBackground` paints a `#FAF9F3` fill with `~26 logical px`
  grid cells in `#DDDCD5` at low contrast, plus a couple of very subtle margin
  rule lines. Grid never sits behind body text without a card beneath it.

## 2. Approximate spacing rhythm
- Observation: generous vertical breathing room; large elements separated by
  roughly one-and-a-half to two line-heights.
- Decision: an 8pt spacing scale (`xs 4, sm 8, md 12, lg 16, xl 24, xxl 32`)
  centralised in `DoodleMetrics`. Screens use `xl`/`xxl` between major regions.

## 3. Border thickness hierarchy
- Observation: three weights — heavy outlines on primary buttons/scenes, medium
  on cards/tiles, hairline on the grid.
- Decision: `DoodleMetrics.strokeHeavy 3.2`, `strokeMedium 2.2`,
  `strokeHair 1.0`. All hand-drawn strokes use round caps/joins.

## 4. Button interaction states
- Observation: chunky rounded rectangles with an offset drop shadow; pressed
  buttons appear to sink toward the shadow.
- Decision: `DoodleButton` renders an offset shadow slab; on press it animates
  down/right into the shadow (squash) and darkens the fill. Disabled = desatur-
  ated fill + reduced opacity + no shadow. Minimum 48×48 tap target enforced.

## 5. Typography hierarchy
- Observation: playful all-caps display for the logo, rounded handwriting for
  questions, medium weight for controls.
- Decision: two open-source handwritten families via `google_fonts` — a bold
  display face (**Kalam**) for logo/headings and a highly legible hand face
  (**Patrick Hand**) for questions/body/buttons. Falls back to system fonts
  offline. Sizes flow through `DoodleTextStyles`.

## 6. Distribution of visual weight
- Observation: illustration anchors the upper third; primary CTA is the single
  heaviest element near the lower third; secondary actions are lighter.
- Decision: heroes/scenes occupy the upper region inside an `AspectRatio`; the
  primary CTA is the only yellow-filled heavy button per screen; secondary
  actions use paper-fill buttons.

## 7. Keyboard usability
- Observation: a wide alphabet grid with large, well-separated keys; used keys
  are visually struck through / recoloured; unused keys stay dark on paper.
- Decision: responsive `LetterTile` grid (7 columns, auto-sizing) with green
  "correct", red struck-through "wrong", and neutral "unused" states, each with
  a screen-reader label ("Letter A, unused"). Keys never smaller than the tap
  minimum.

## 8. Placement of clue, illustration, and answer
- Observation: illustration + a short speech line at top, the question centred,
  the masked answer above the keyboard.
- Decision: our gameplay column is scene → encouragement bubble → clue card →
  mistakes meter → masked answer → keyboard → hint row. Order is fixed and
  fully scrollable so it never overflows at large text scale.

## 9. Win-screen information hierarchy
- Observation: big celebratory headline, a few labelled stats, a progress row
  of pips toward a chest, and one primary "next" control.
- Decision: `ResultScreen` leads with a headline + star row, then a compact
  stats grid (coins, accuracy, mistakes, streak), then the chest progress
  track, then Continue (primary) / Replay (secondary).

## 10. Aspects deliberately changed to stay original
- New name **"Doodle Word Quest"**; new logo mark (open book + quill spark).
- Original mascot: a round-headed **"Sketch"** doodle explorer — *not* a stick
  figure with balloons over a shark.
- Original danger scenes: **balloon drift**, **stepping stones**, **book
  stack** — multi-stage, none matching the reference balloon/shark composition.
- Original icon set (coin, heart, hints, lock, chest) drawn from scratch in
  `CustomPainter`.
- Original UI composition, button silhouettes, speech-bubble shape, keyboard
  layout, star/streak progression, and encouragement copy.
- Original 60-level question bank; none reproduced from the references.

---

## Resulting design tokens (see `lib/app/theme/`)
| Token file | Contents |
|---|---|
| `doodle_colors.dart` | paper, grid, ink, yellow, green, red, blue, orange + state shades |
| `doodle_text_styles.dart` | display / heading / title / body / label / keycap via google_fonts |
| `doodle_metrics.dart` | spacing scale, stroke weights, radii, tap minimums, durations |
| `app_theme.dart` | assembles a Material 3 `ThemeData` wrapped by the custom look |
