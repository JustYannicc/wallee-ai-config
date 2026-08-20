---
name: Wallee AI Config
description: A public one-command Mac setup for Wallee's AI tools
colors:
  leaf-green: "#667A3D"
  deep-olive: "#34452B"
  rust-crown: "#B85C38"
  warm-cream: "#E8DFC4"
  charcoal: "#17201C"
  twig-brown: "#8A694D"
typography:
  display:
    fontFamily: "Menlo, Monaco, Consolas, monospace"
    fontWeight: 700
    lineHeight: 1
  body:
    fontFamily: "system-ui, sans-serif"
    fontWeight: 400
    lineHeight: 1.5
spacing:
  cell: "1px"
---

# Design system: Wallee AI Config

## Overview

**Creative North Star: "The stitched tool kit"**

The identity uses the Wallee ordered-dither family to turn the common tailorbird's construction behavior into a setup metaphor. The mark stays compact and recognizable. The wordmark carries the public product name without competing with instructions.

Key characteristics:

- Every visible bird cell comes from the canonical 4 by 4 Bayer matrix.
- The long upright tail, rust crown, green back, pale underside, and fine bill identify the species.
- The mark has no background and works on light and dark surfaces.

## Colors

The palette follows the common tailorbird's observed plumage. Leaf green and deep olive form the body, rust marks the crown, warm cream forms the underside, and charcoal anchors the eye and bill.

## Typography

The stored six-line ANSI Shadow wordmark uses Menlo with platform monospace fallbacks that keep box-drawing glyphs aligned. Documentation uses the host platform's reading font.

## Layout

The bird mark remains square. The wordmark is a separate wide asset. Documentation gives setup commands priority over branding.

## Shapes

The bird uses toy-family proportions: an oversized rounded head, plump upright body, glossy eye, simplified wing and feet, fine bill, and a long raised tail.

## Components

The compact mark is for repository and small brand contexts. The wordmark is for README and presentation-scale moments. They are never fused into one asset.

## Do's and don'ts

### Do

- Do preserve the transparent background and crisp cell edges.
- Do regenerate assets from `tools/generate-brand.mjs`.
- Do keep setup instructions above decorative detail in narrow layouts.

### Don't

- Don't replace ordered cells with smooth fills or a solid underbody.
- Don't use the wide wordmark where it crowds instructions.
- Don't copy another Wallee bird's silhouette or palette.
