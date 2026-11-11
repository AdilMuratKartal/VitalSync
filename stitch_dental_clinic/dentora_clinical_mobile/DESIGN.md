---
name: Dentora Clinical Mobile
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3e494b'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6e797c'
  outline-variant: '#bdc8cb'
  surface-tint: '#006877'
  primary: '#006574'
  on-primary: '#ffffff'
  primary-container: '#008092'
  on-primary-container: '#f8fdff'
  inverse-primary: '#76d4e7'
  secondary: '#2c6480'
  on-secondary: '#ffffff'
  secondary-container: '#a9deff'
  on-secondary-container: '#2b637f'
  tertiary: '#4c616c'
  on-tertiary: '#ffffff'
  tertiary-container: '#647a86'
  on-tertiary-container: '#00060b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3eeff'
  primary-fixed-dim: '#76d4e7'
  on-primary-fixed: '#001f25'
  on-primary-fixed-variant: '#004e5a'
  secondary-fixed: '#c3e8ff'
  secondary-fixed-dim: '#98cded'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#084c67'
  tertiary-fixed: '#cfe6f3'
  tertiary-fixed-dim: '#b3cad6'
  on-tertiary-fixed: '#071e27'
  on-tertiary-fixed-variant: '#344a54'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 41px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.005em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-sm: 0.75rem
  margin-lg: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered specifically for modern, clinical iOS environments with an emphasis on dental care and patient transparency. It strikes an intentional balance between pristine medical sterility and warm, empathetic hospitality. 

### Aesthetic Direction: Modern Clinical Precision
The style blends Human Interface Guidelines (HIG) clarity with soft, tactile modernism. Instead of an intimidating institutional clinical appearance, the interface communicates hygiene, technical excellence, and serene reassurance through:
- **Clean surfaces**: Crisp white and glacial cyan backdrops that evoke clinical purity without clinical coldness.
- **Micro-tactility**: Compact, finger-friendly touch targets with subtle elastic spring transitions tailored for mobile thumb zones.
- **Deep Marine Tones**: Anchored by deep teal and slate for immediate authority, calm, and legible contrast in critical health data.

## Colors

The color palette centers on clinical serenity and diagnostic clarity.

- **Primary (`#088395`)**: Deep Medical Teal. Used for key interaction points, primary CTAs, active appointment alerts, and highlighted milestones.
- **Secondary (`#0A4D68`)**: Deep Marine. Reserved for prominent section headers, navigation bars, and critical clinical status elements requiring deep contrast.
- **Tertiary (`#D4EBF8` & `#EBF4F6`)**: Soft Cyan & Glacial Water. Utilized for interactive chip containers, active selection rings, surface tints, and appointment status pills.
- **Neutral & Structural (`#64748B`, `#1E293B`)**: Slate Gray shades ensure precise typographic contrast without harsh absolute blacks.
- **Canvas (`#F8FAFC`, `#FFFFFF`)**: Muted Ice canvas provides gentle contrast underneath pristine white elevation cards.

## Typography

Typography relies on **Inter** (closely aligning with Apple's native San Francisco layout metrics) to ensure native iOS familiarity and optical legibility at high data densities.

- **Headlines**: Set in tighter negative letter-spacing for clinical authority and visual stability across appointment agendas and patient profile headers.
- **Body Text**: Tuned for maximum legibility in prescription records, treatment summaries, and doctor notes. Never use weights below `400`.
- **Labels & Microcopy**: Medium (`500`) and SemiBold (`600`) weights enforce scannability across time slots, dental procedure codes, tooth chart indices, and pill chips.

## Layout & Spacing

The layout is built for native iOS ergonomics with a strict 4pt/8pt rhythmic grid tailored for dynamic touch interaction.

### Grid and Margins
- **Base Canvas Margin**: `1rem` (16px) standard padding on iPhone screens, transitioning to `1.25rem` (20px) on Max/Plus form factors.
- **Safe Area Insets**: Layout conforms to standard iOS safe areas (Dynamic Island and home indicator zones), floating sticky CTAs with an additional `space-md` safe cushion.
- **Column Structure**: Fluid 4-column layout for small mobile cards; unified single-column flow for patient dossiers, appointment scheduling flows, and treatment roadmaps.

## Elevation & Depth

This system avoids aggressive drop shadows, utilizing quiet, airy elevation layers that mirror pristine clinical surfaces.

- **Ambient Layering**: Elevation is established by placing pure white `#FFFFFF` cards atop the `#F8FAFC` (Muted Ice) background canvas.
- **Soft Shadows (shadow-sm)**: 
  - `box-shadow: 0 2px 8px -2px rgba(10, 77, 104, 0.06), 0 1px 3px 0 rgba(10, 77, 104, 0.04)`
  - Uses an intentional marine-tinted shadow (`#0A4D68`) rather than flat gray or black, providing an illuminated, soft-focus physical presence.
- **Interactive Focus & Floating**: Modals, dental date pickers, and sticky bottom navigation bars use frosted background blurs (`backdrop-filter: blur(20px)`) combined with a 1px border tinted in `rgba(212, 235, 248, 0.6)`.

## Shapes

The geometric language balances organic comfort with clinical precision.

- **Standard Containers & Cards**: Defined with `rounded-2xl` (1rem / 16px) to soften visual density while retaining efficient content capacity.
- **Interactive Controls & Inputs**: Form fields, compact buttons, and inline media containers use `rounded-xl` (0.75rem / 12px).
- **Chips, Badges & Pills**: Capsule shapes (`rounded-full` / 9999px) for patient statuses, treatment tags, and quick-filter items.

## Components

### Buttons
- **Primary Action**: Solid `#088395` background, white text (`label-lg`), minimum touch height of `50px`, `rounded-xl`. Active state uses a slight scale transform (`0.98`) with subtle haptic tap feedback.
- **Secondary / Action Tonal**: Background `#EBF4F6` with text in `#0A4D68`. Used for ancillary actions like "Randevu Değiştir" or "Reçete Detayı".
- **Destructive**: Soft red surface (`#FEE2E2`) with `#B91C1C` typography for cancelations and emergency record resets.

### Cards (iOS Medical Card)
- **Structure**: Pure `#FFFFFF` background, `rounded-2xl` curvature, wrapped with a 1px hairline border (`#E2E8F0` or `#EBF4F6`), finished with soft cyan-marine `shadow-sm`.
- **Anatomy**: Top meta-row (doctor badge, date chip), central body (procedure title in `headline-sm`, clinic room), and footer action link or progress bar.

### Chips & Selectable Tags
- **Default State**: Background `#F8FAFC`, border 1px solid `#E2E8F0`, typography `#64748B` (`label-md`), full pill curvature (`rounded-full`), height `36px`.
- **Selected State**: Background `#D4EBF8`, border 1px solid `#088395`, typography `#0A4D68` (SemiBold).

### Input Fields
- **Container**: Minimalist enclosed input with a height of `48px`, background `#FFFFFF`, border 1px solid `#CBD5E1`, `rounded-xl`.
- **Focus State**: Border transitions to `#088395` with a subtle focus glow (`0 0 0 3px rgba(8, 131, 149, 0.15)`). Floating label in `#0A4D68`.

### Checkboxes & Radios
- **Form**: `20px` compact rounded boxes (`rounded-md` for checkboxes, `rounded-full` for radios).
- **Colorway**: Inactive border `#94A3B8`; active state fills with `#088395` housing a crisp white SVG checkmark.

### Domain-Specific Components
- **Interactive Odontogram (Teeth Map)**: Minimalist vector diagram of adult/child dentition. Unaffected teeth display in white with `#CBD5E1` strokes; planned procedures highlight in `#D4EBF8` with `#088395` outlines; completed procedures in solid `#088395`.
- **Appointment Timeline Step**: Vertical connecting spine with `#E2E8F0` rule and teal pulse indicator (`#088395`) for real-time clinic arrival and queue progress tracking.