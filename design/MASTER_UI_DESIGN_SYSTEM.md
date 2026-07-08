# MASTER UI DESIGN SYSTEM
## CampusMitra — Reverse-Engineered Frontend Architecture & Design Language
### Version 1.0 | Complete SaaS UI Kit Reference

---

## PART 1 — PROJECT OVERVIEW

### Overall Frontend Architecture
CampusMitra is a **React 19 + Vite 7** SPA built with a component-based architecture. It is a multi-role SaaS platform with role-based navigation, per-role dashboards, and a unified design language.

**Key Architectural Traits:**
- Flat component hierarchy — no dedicated shared component library; components are co-located in page files
- Pages are self-contained `.jsx` files that define sub-components at the top of the same file
- Shared style objects (plain JS objects) are declared at module scope at the **bottom** of page files
- Dual styling: **Tailwind CSS v4 utility classes** for some pages, **inline `style={{}}` JSX props** for layout-critical/themed elements
- CSS custom properties (`var(--token)`) used for all theme tokens

### Frameworks & Libraries
| Layer | Technology | Version |
|-------|-----------|---------|
| UI Framework | React | 19.x |
| Build Tool | Vite | 7.x |
| Routing | React Router DOM | 7.x |
| CSS Framework | Tailwind CSS | v4.x |
| Primary Charts | react-plotly.js | 2.x |
| Secondary Charts | Recharts | 3.x |
| Custom Charts | Hand-drawn SVG inline | — |
| Icons (primary) | Iconify web component | 6.x |
| Icons (secondary) | lucide-react named imports | 0.574 |
| Maps | Leaflet + Mapbox GL | 1.9 / 3.18 |
| PDF | jsPDF + jsPDF-AutoTable | 4.x |
| Excel | XLSX | 0.18 |
| HTTP | Axios | 1.x |
| Font | Inter (Google Fonts) | — |

### State Management
- **React Context only** — no Redux, Zustand, or external store
- 4 global contexts: `ThemeContext`, `AuthContext`, `DataContext`, `EventsContext`
- All contexts persist to `localStorage`
- Page-level state: `useState` / `useMemo` / `useEffect`

### Routing
- React Router v7 with nested routes
- `AppLayout.jsx` is the **single route manifest** — all 60+ routes declared here
- Route protection: `ProtectedRoute` (auth), `RoleProtectedRoute` (role)
- Public routes: `/`, `/login`, `/judge/login`, `/judge/dashboard`, `/auth/callback`
- Authenticated routes wrapped in `MainLayout` (sidebar + navbar shell)
- Role-based dashboard: `RoleBasedDashboard` component dispatches to role-specific dashboard

### Theme Management
- Toggle: `light` / `dark` via `ThemeProvider`
- Stored in `localStorage["campus_theme"]`
- Applied to `document.documentElement` as `data-theme="light"|"dark"`
- Tailwind v4 maps `dark:` prefix to `[data-theme=dark]` via `@variant dark`
- All theme transitions: `background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease`

### Responsiveness
- **Desktop-first** — no mobile-first approach
- Main sidebar always visible at 260px (no collapse)
- Only breakpoint: 840px (login page collapses left panel)
- All grids use fixed column counts (no CSS responsive `auto-fit`)

### Styling Approach — Two Co-existing Systems
1. **CSS Custom Properties + inline JSX styles**: Sidebar, Navbar, MainLayout, Dashboard, Settings — uses `var(--token)` exclusively
2. **Tailwind CSS v4 utility classes**: Analytics, Students, Support, many admin pages — uses Tailwind `bg-white`, `text-slate-*`, `rounded-*`, etc.

> ⚠️ **Critical**: Never mix `var(--token)` inline styles with Tailwind utilities in the same card/component. Pick one approach per page.

### Animations
- **No external animation library** (no Framer Motion, GSAP)
- All animations via CSS `transition` on hover/active
- Entry animations: class toggling (e.g., `mounted` state → add `.in` class with opacity/transform transition)
- Dark mode transitions: applied globally via `[data-theme="dark"] *`

---

## PART 2 — FOLDER STRUCTURE

```
client/src/
├── App.jsx                    # Root: ThemeProvider > BrowserRouter > AuthProvider > DataProvider > EventsProvider > AppLayout
├── App.css                    # Empty file
├── main.jsx                   # Vite entry — renders <App> in StrictMode
├── index.css                  # Global: @import leaflet + tailwindcss, font, CSS tokens, dark mode, scrollbar
├── layout/
│   ├── AppLayout.jsx          # All routes (60+). ProtectedRoute, RoleProtectedRoute, RoleBasedDashboard
│   └── MainLayout.jsx         # Auth shell: flex row (Sidebar + flex column (Navbar + <main><Outlet>))
├── components/
│   ├── Sidebar.jsx            # Role-aware sidebar (navConfig per role, NavLink, user avatar, logout)
│   ├── Navbar.jsx             # Top bar (institution switcher, search 320px, theme toggle, bell)
│   ├── RepoCard.jsx           # GitHub repo card widget
│   └── CertificateTemplate.jsx # Certificate PDF visual
├── context/
│   ├── ThemeContext.jsx       # theme state + toggleTheme() → data-theme on <html>
│   ├── AuthContext.jsx        # user object, login/logout, ROLES constant, judge auth
│   ├── DataContext.jsx        # importedStudents array
│   └── EventsContext.jsx      # Full events CRUD (localStorage-backed, largest context)
├── pages/
│   ├── Dashboard.jsx          # Student dashboard (107KB — largest page file)
│   ├── Login.jsx              # Role-selection + GitHub OAuth login
│   ├── Analytics.jsx          # Institutional analytics (Tailwind + custom SVG charts)
│   ├── Students.jsx           # Student table (Tailwind)
│   ├── Support.jsx            # Support ticket form (Tailwind)
│   ├── Leaderboard.jsx        # Leaderboard cards + table
│   ├── Certificates.jsx       # Certificate cards + viewer
│   ├── [many more...]
│   ├── admin/                 # College admin pages (AdminDashboard, CreateEventPage, etc.)
│   ├── teacher/               # Faculty pages (TeacherDashboard, MyStudents, etc.)
│   ├── recruiter/             # Recruiter pages (14 pages)
│   ├── judge/                 # Judge login + dashboard
│   ├── events/                # Student event pages
│   ├── landing/               # Public landing page
│   └── portfolio/             # Student portfolio
├── services/
│   ├── githubApi.js           # GitHub REST calls
│   ├── githubOAuth.js         # OAuth helpers
│   └── leetcodeApi.js         # LeetCode stats
├── data/
│   ├── projectStore.js        # localStorage projects
│   └── seeds.js               # Seed student data
└── utils/
    ├── reportGenerators.js    # PDF/Excel generation (50KB)
    ├── eventReportExcel.js    # Event Excel export
    └── collegeKPIReport.js    # KPI PDF
```

### How Folders Interact
- `AppLayout.jsx` imports ALL page components and defines routes; pages are lazy-loaded implicitly
- Pages import from `context/` for state, `services/` for API, `data/` for seed data, `utils/` for exports
- `MainLayout.jsx` composes `Sidebar` + `Navbar` and renders page via `<Outlet>`
- Contexts wrap the entire app in `App.jsx` in this order: Theme > Router > Auth > Data > Events

---

## PART 3 — LAYOUT SYSTEM

### Shell Layout Diagram
```
┌────────────────────────────────────────────────────────────┐
│  Sidebar (260px, sticky)    │  Content Column (flex:1)      │
│  ┌────────────────────────┐ │  ┌──────────────────────────┐ │
│  │ Logo zone (h:60px)     │ │  │ Navbar (h:60px, z:30)    │ │
│  │ padding: 0 24px        │ │  │ padding: 0 24px          │ │
│  ├────────────────────────┤ │  ├──────────────────────────┤ │
│  │ Nav (flex:1,           │ │  │ <main> flex:1,           │ │
│  │  overflow-y:auto,      │ │  │  overflow-y:auto         │ │
│  │  padding:16px 12px,    │ │  │                          │ │
│  │  gap:4px)              │ │  │  <Outlet /> → page       │ │
│  ├────────────────────────┤ │  │  content starts with     │ │
│  │ User footer            │ │  │  padding:24px wrapper    │ │
│  │  padding:16px          │ │  │                          │ │
│  └────────────────────────┘ │  └──────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### MainLayout (shell code)
```jsx
// layout/MainLayout.jsx
<div style={{ display:"flex", height:"100vh", overflow:"hidden",
              backgroundColor:"var(--muted)", fontFamily:"var(--font-family-body)",
              color:"var(--foreground)" }}>
  <Sidebar />
  <div style={{ flex:1, display:"flex", flexDirection:"column",
                overflow:"hidden", backgroundColor:"var(--muted)" }}>
    <Navbar />
    <main style={{ flex:1, overflowY:"auto" }}>
      <Outlet />
    </main>
  </div>
</div>
```

### Sidebar Spec
```jsx
<aside style={{
  width: "260px",
  backgroundColor: "var(--background)",
  borderRight: "1px solid var(--border)",
  display: "flex",
  flexDirection: "column",
  flexShrink: 0,
  height: "100vh",
  position: "sticky",
  top: 0,
}}>
```

**Sidebar Logo Block** (height 60px, padding 0 24px):
- Icon box: 24×24px, `background: var(--primary)`, `borderRadius: 6px`, white iconify-icon 16px
- App name: 18px, fontWeight 700, color `var(--primary)`, gap 10px from icon

**Sidebar Nav Section Labels**:
- `fontSize: "11px"`, `textTransform: "uppercase"`, `letterSpacing: "0.5px"`
- `color: "var(--muted-foreground)"`, `fontWeight: 600`, `padding: "16px 12px 8px"`

**Sidebar NavLink**:
- `padding: "8px 12px"`, `borderRadius: "var(--radius-md)"`, `fontSize: "14px"`, `fontWeight: 500`
- Active: `color: var(--primary)`, `backgroundColor: var(--secondary)`
- Hover: `backgroundColor: var(--secondary)`, `color: var(--foreground)`
- `transition: "all 0.2s"`
- Icon: `iconify-icon` at `fontSize: "16px"`, gap 10px from label

**Sidebar User Footer** (padding 16px, borderTop 1px var(--border)):
- Avatar: `img` 32×32px, `borderRadius: 50%`, DiceBear thumbs SVG URL
- Username: 13px, fontWeight 500, color `var(--foreground)`
- Role: 11px, color `var(--muted-foreground)`
- Logout button: full-width, flex center, gap 8px, padding 8px 12px, 1px border, 13px
  - Hover: bg `#fef2f2`, color `#dc2626`, border `#fecaca`

### Navbar Spec
```jsx
<header style={{
  height: "60px",
  backgroundColor: "var(--background)",
  borderBottom: "1px solid var(--border)",
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
  padding: "0 24px",
  flexShrink: 0,
  position: "sticky",
  top: 0,
  zIndex: 30,
}}>
```

**Navbar Left — Institution Switcher**:
- `fontSize: "14px"`, fontWeight 500, padding `6px 10px`, border `1px solid var(--border)`, radius `var(--radius-md)`
- Contains `iconify-icon` `"lucide:building-2"` at 16px + institution name text

**Navbar Center — Search Bar**:
- Container: `position: "relative"`, `width: "320px"`
- Icon: absolute, left 10px, vertically centered, color `var(--muted-foreground)`, pointerEvents none
- Input: `height: "36px"`, `paddingLeft: "36px"`, `paddingRight: "12px"`, `border: "1px solid var(--border)"`, `borderRadius: "var(--radius-md)"`, `fontSize: "13px"`, `backgroundColor: "var(--muted)"`, `color: "var(--foreground)"`, `outline: "none"`

**Navbar Right — Actions** (gap 16px):
- Theme toggle: icon-only button (`background:none`, `border:none`, padding 6px, radius `var(--radius-md)`, icon 20px)
  - Hover: `background: var(--muted)`, `color: var(--foreground)`
- Notification bell: icon-only button, icon 20px, with red dot (8×8px absolute, border 2px `var(--background)`)

### Content Wrapper (inside `<main>`)
| Page Type | Padding | Max Width | Margin |
|-----------|---------|-----------|--------|
| Student pages (Dashboard, Certificates, etc.) | `24px` | none | none |
| Admin pages (AdminDashboard, SuperAdmin) | `24px 32px` | `1400px` | `0 auto` |
| Tailwind pages (Students, Analytics) | `p-6` / `min-h-screen bg-slate-50 p-6` | `max-w-7xl mx-auto` | none |

### Grid Patterns
| Layout | Template Columns | Gap |
|--------|-----------------|-----|
| 2-col KPI row | `repeat(2, 1fr)` | `16px` |
| 4-col KPI row | `repeat(4, 1fr)` | `16px` |
| 3-col Quick Actions | `repeat(3, 1fr)` | `14px` |
| 4-col Overview Cards (Tailwind) | `grid-cols-4` | `gap-4` |
| Main + Sidebar | `2fr 1fr` | `20px` or `24px` |
| 3-col Content | `2fr 1fr 1fr` | `24px` |

---

## PART 4 — DESIGN TOKENS

### CSS Custom Properties (index.css)

#### Light Mode (`:root`)
| Token | Value | Semantic Usage |
|-------|-------|---------------|
| `--background` | `#ffffff` | Sidebar, Navbar, Cards, Input backgrounds |
| `--foreground` | `#0f172a` | Primary body text |
| `--card` | `#ffffff` | Card surface backgrounds |
| `--card-foreground` | `#0f172a` | Text inside cards |
| `--primary` | `#2b4ed6` | Brand: CTAs, active nav, links, progress fill |
| `--primary-foreground` | `#ffffff` | Text on primary buttons |
| `--secondary` | `#f1f5f9` | Nav hover/active bg, secondary button bg |
| `--secondary-foreground` | `#0f172a` | Text on secondary surfaces |
| `--muted` | `#f8fafc` | Page background, input bg |
| `--muted-foreground` | `#64748b` | Captions, labels, subtitles, icon button color |
| `--accent` | `#f1f5f9` | Accent surfaces |
| `--accent-foreground` | `#0f172a` | Text on accent |
| `--destructive` | `#ef4444` | Delete, error, notification dot |
| `--border` | `#e2e8f0` | All borders, dividers, table rows |
| `--radius-lg` | `8px` | Cards (standard) |
| `--radius-md` | `6px` | Inputs, nav links, buttons |
| `--radius-sm` | `4px` | Small pills, inline badges |
| `--font-family-body` | `"Inter", system-ui, -apple-system, sans-serif` | All text |

#### Dark Mode (`[data-theme="dark"]`)
| Token | Value |
|-------|-------|
| `--background` | `#0f172a` |
| `--foreground` | `#e2e8f0` |
| `--card` | `#1e293b` |
| `--card-foreground` | `#e2e8f0` |
| `--primary` | `#818cf8` (indigo-400) |
| `--primary-foreground` | `#ffffff` |
| `--secondary` | `#1e293b` |
| `--secondary-foreground` | `#e2e8f0` |
| `--muted` | `#1e293b` |
| `--muted-foreground` | `#94a3b8` |
| `--accent` | `#334155` |
| `--accent-foreground` | `#e2e8f0` |
| `--destructive` | `#f87171` |
| `--border` | `#334155` |

### Hardcoded Semantic Accent Colors (NOT in CSS vars — used directly in JSX)
These are used with inline `style={{}}` or Tailwind and are NOT affected by dark mode:

| Semantic | Color Hex | Background Hex | Tailwind Equiv |
|----------|----------|----------------|---------------|
| Admin Blue | `#1e3a8a` | `#eff6ff` | blue-900 / blue-50 |
| Info Blue | `#2563eb` | `#eff6ff` | blue-600 / blue-50 |
| Success Green | `#16a34a`, `#15803d` | `#dcfce7`, `#ecfdf5` | green-600 / green-50 |
| Active Green (chart) | `#22C55E` | `rgba(34,197,94,0.2)` | green-500 |
| Warning Amber | `#b45309`, `#d97706` | `#fef3c7` | amber-700 / amber-50 |
| Gold (chart) | `#FFD700` | `rgba(255,215,0,0.2)` | — |
| Purple | `#7c3aed`, `#6366f1` | `#f3e8ff`, `#eef2ff` | violet-700 / violet-50 |
| Cyan | `#0891b2` | `#ecfeff` | cyan-600 / cyan-50 |
| Danger Red | `#dc2626`, `#ef4444` | `#fef2f2` | red-600 / red-50 |
| Text Primary | `#1e293b` | — | slate-800 |
| Text Secondary | `#64748b` | — | slate-500 |
| Text Muted | `#94a3b8` | — | slate-400 |

### Badge / Status Colors
| Status | Background | Text | Tailwind |
|--------|-----------|------|---------|
| Active/Success | `#dcfce7` | `#15803d` | `bg-green-100 text-green-700` |
| Warning/Pending | `#fef3c7` | `#b45309` | `bg-yellow-100 text-yellow-700` |
| Error/Critical | `#fef2f2` | `#dc2626` | `bg-red-100 text-red-700` |
| Info/Imported | `#dbeafe` | `#1d4ed8` | `bg-blue-100 text-blue-700` |
| Purple/AI | gradient `#4f46e5→#9333ea` | `white` | — |
| Neutral | `#f1f5f9` | `#475569` | `bg-slate-100 text-slate-700` |

### Typography Scale
| Name | Size | Weight | Usage |
|------|------|--------|-------|
| Page H1 | 26–28px | 700 | Page titles |
| Section H2 | 16px | 600 | "Quick Actions", section labels |
| Card H3 | 15px | 600 | Card section headers |
| Body | 14px | 400–500 | Nav links, general text |
| Label | 13px | 500 | Usernames, form labels |
| Meta | 12px | 400–500 | Card subtitles, dates, chart labels |
| Small | 11px | 500–600 | Badges, timestamps, nav group headers |
| XSmall | 10px | 600 | Uppercase tracking labels, chart ticks |
| KPI Value | 28px | 600 | Large metric numbers (letter-spacing -0.5px) |
| Admin Stat | 24px | 700 | Admin stat card values |
| Large Stat | 32px | 700 | Profile completion percentage |
| Hero Text | clamp(28px,3vw,46px) | 900 | Login hero headline |

**Font weights imported**: 100, 200, 300, 400, 500, 600, 700, 800, 900

**Section Label Style** (sidebar nav group headers):
```css
font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;
color: var(--muted-foreground); font-weight: 600; padding: 16px 12px 8px;
```

**Form Label Style**:
```css
font-size: 12px; font-weight: 600; color: var(--muted-foreground);
text-transform: uppercase; letter-spacing: 0.4px;
```

### Spacing Scale (4px base grid)
| Value | Common Uses |
|-------|-------------|
| 2px | Notification dot border |
| 4px | Badge padding, tiny gaps |
| 6px | Icon button padding, pill padding |
| 8px | Compact gaps (button icon gap, card sub-items) |
| 10px | Sidebar item horizontal padding, nav icon-label gap |
| 12px | Nav item padding, input margin-bottom |
| 14px | Card inner row gaps, header margins |
| 16px | Section heading margin-bottom, card padding unit |
| 20px | Card padding (standard for all cards) |
| 24px | Page padding, main grid gaps |
| 28px | Page section margin-bottom (admin pages) |
| 32px | Admin page horizontal padding (wider feel) |
| 44px | Icon container size in stat/action cards |

### Border Radius
| Value | Source | Usage |
|-------|--------|-------|
| `4px` = `var(--radius-sm)` | CSS var | Small inline badges |
| `6px` = `var(--radius-md)` | CSS var | Inputs, nav links, most buttons |
| `8px` = `var(--radius-lg)` | CSS var | Standard content cards |
| `10px` | Hardcoded | Admin stat cards, quick action icon containers |
| `11px` | Hardcoded | Login role selection buttons |
| `12px` | Hardcoded | Larger admin cards, event list items |
| `50%` | — | All avatars, notification dots |
| `100px` / `999px` | — | Pill badges, scrollbar thumb |

### Shadows
| Level | Value | Usage |
|-------|-------|-------|
| Subtle card | `0 1px 2px rgba(0,0,0,0.03)` | KPI cards in student dashboard |
| Card hover | `0 4px 12px {accentColor}15` | Quick action card hover |
| Logo glow | `0 6px 18px rgba(99,102,241,0.36)` | Login page logo icon |
| Tooltip | `0 3px 10px rgba(0,0,0,0.06)` | Tooltip/popover shadow |
| Tailwind shadow-sm | Tailwind | Students page overview cards |
| Tailwind shadow-md | Tailwind | Students directory table container |

---

## PART 5 — COMPONENT LIBRARY

### 5.1 Buttons

#### Primary Button (CSS var approach — themed pages)
```jsx
<button style={{
  background: "var(--primary)",
  color: "var(--primary-foreground)",
  border: "none",
  padding: "10px 16px",
  borderRadius: "var(--radius-md)",
  fontSize: "13px",
  fontWeight: 500,
  cursor: "pointer",
  display: "flex",
  alignItems: "center",
  gap: "8px",
}}>
  <iconify-icon icon="lucide:upload" style={{ fontSize: "16px" }}></iconify-icon>
  Button Label
</button>
```

#### Admin Primary Button (hardcoded blue)
```jsx
<button style={{
  display: "flex", alignItems: "center", gap: "8px",
  padding: "10px 18px",
  background: "#1e3a8a", color: "white",
  border: "none", borderRadius: "8px",
  fontSize: "13px", fontWeight: 600, cursor: "pointer",
}}>
  <iconify-icon icon="lucide:plus" style={{ fontSize: "16px" }}></iconify-icon>
  Create Event
</button>
```

#### Outline / Secondary Button
```jsx
<button style={{
  background: "var(--background)",
  border: "1px solid var(--border)",
  color: "var(--muted-foreground)",
  padding: "8px 12px",
  borderRadius: "var(--radius-md)",
  fontSize: "13px", fontWeight: 500,
  cursor: "pointer", transition: "all 0.2s",
}}>
```

#### Logout Button (destructive hover)
- Default: bg `var(--background)`, color `var(--muted-foreground)`, border `var(--border)`
- `onMouseEnter`: bg `#fef2f2`, color `#dc2626`, border `#fecaca`
- `onMouseLeave`: revert to defaults

#### Icon-Only Button (navbar actions)
```jsx
<button style={{
  background: "none", border: "none", cursor: "pointer",
  color: "var(--muted-foreground)", padding: "6px",
  borderRadius: "var(--radius-md)",
  transition: "color 0.2s, background 0.2s",
}}>
  <iconify-icon icon="lucide:moon" style={{ fontSize: "20px" }}></iconify-icon>
</button>
// Hover: background: "var(--muted)", color: "var(--foreground)"
```

#### Tailwind Buttons (used in Tailwind-styled pages)
```jsx
// Outline
<button className="flex items-center gap-2 px-4 py-2 border border-slate-300 text-slate-700 rounded-lg font-medium text-sm hover:bg-slate-50 transition-colors">
// Primary
<button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg font-medium text-sm hover:bg-blue-700 transition-colors">
// Danger icon button
<button className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600 transition-colors">
```

#### Quick Action Card (navigational, styled as button)
```jsx
<Link to={action.path} style={{
  textDecoration: "none",
  background: "white",
  borderRadius: "12px",
  padding: "18px 20px",
  border: "1px solid #e2e8f0",
  display: "flex", alignItems: "center", gap: "14px",
  transition: "all 0.2s", cursor: "pointer",
}}
onMouseOver={e => {
  e.currentTarget.style.borderColor = action.color;
  e.currentTarget.style.boxShadow = `0 4px 12px ${action.color}15`;
}}
onMouseOut={e => {
  e.currentTarget.style.borderColor = "#e2e8f0";
  e.currentTarget.style.boxShadow = "none";
}}>
  <div style={{ width:"44px", height:"44px", borderRadius:"10px",
                background: action.bg, display:"flex", alignItems:"center",
                justifyContent:"center", flexShrink:0 }}>
    <iconify-icon icon={action.icon} style={{ fontSize:"22px", color: action.color }}></iconify-icon>
  </div>
  <div>
    <div style={{ fontSize:"14px", fontWeight:600, color:"#1e293b", marginBottom:"2px" }}>{action.label}</div>
    <div style={{ fontSize:"12px", color:"#64748b" }}>{action.description}</div>
  </div>
</Link>
```

### 5.2 Cards

#### Standard Card (CSS variable-based — used in Dashboard)
```jsx
// Module-scope constants at bottom of page file:
const card = {
  background: "var(--card)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-lg)",   // 8px
  padding: "20px",
  display: "flex",
  flexDirection: "column",
};
const cardHeaderRow = {
  display: "flex", justifyContent: "space-between",
  alignItems: "center", marginBottom: "16px",
};
const cardTitle = { fontSize: "15px", fontWeight: 600, margin: 0 };
```

#### KPI Card (Student Dashboard)
```jsx
const kpiCard = {
  background: "var(--card)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-lg)",
  padding: "20px",
  boxShadow: "0 1px 2px rgba(0,0,0,0.03)",
  position: "relative", overflow: "hidden",
};
const kpiLabel = {
  fontSize: "13px", fontWeight: 500,
  color: "var(--muted-foreground)",
  display: "flex", justifyContent: "space-between",
  alignItems: "center", marginBottom: "12px",
};
const kpiValue = {
  fontSize: "28px", fontWeight: 600,
  color: "var(--foreground)", letterSpacing: "-0.5px",
};
const kpiSubtext = {
  fontSize: "12px", marginTop: "8px",
  color: "var(--muted-foreground)",
  display: "flex", alignItems: "center", gap: "4px",
};
```

#### Admin Stat Card (hardcoded colors — AdminDashboard, SuperAdminDashboard)
```jsx
// Structure: flex row, gap 14px
// Icon container: 44×44px, borderRadius 10px, bg:stat.bg
// Icon: 22px iconify-icon, color:stat.color
// Content:
//   Label: 12px, #64748b, fontWeight 500, mb 4px
//   Value: 24px, fontWeight 700, #1e293b, mb 2px
//   Trend (optional): 12px, #16a34a, fontWeight 600 + TrendingUp icon 12px
//   Subtitle: 12px, #94a3b8
<div style={{
  background: "white", borderRadius: "12px", padding: "20px",
  border: "1px solid #e2e8f0",
  display: "flex", alignItems: "flex-start", gap: "14px",
}}>
```

#### Analytics Stat Card (Tailwind, top-border accent)
```jsx
function StatCard({ label, value, sub, icon: Icon, trend, accentColor, iconBg, iconColor }) {
  return (
    <div className={`bg-white border border-slate-200 rounded-xl p-5 flex flex-col gap-2.5 border-t-4 ${accentColor}`}>
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium text-slate-500 uppercase tracking-wide">{label}</span>
        <span className={`w-8 h-8 rounded-lg flex items-center justify-center ${iconBg} ${iconColor}`}>
          <Icon size={16} />
        </span>
      </div>
      <p className="text-3xl font-bold text-slate-900 leading-none">{value}</p>
      {trend && <span className="inline-flex items-center gap-0.5 text-[11px] font-semibold text-emerald-600">
        <ArrowUpRight size={11} />{trend}
      </span>}
      {sub && <p className="text-xs text-slate-400">{sub}</p>}
    </div>
  );
}
```

#### Student Overview Card (Tailwind, simple)
```jsx
<div className="bg-white rounded-lg p-6 shadow-sm">
  <p className="text-slate-600 text-sm font-medium mb-2">{label}</p>
  <p className="text-3xl font-bold text-slate-900 mb-2">{value}</p>
  <p className="text-sm text-green-600">{subtext}</p>
</div>
```

### 5.3 Inputs

#### Standard Input (inline styles — themed pages)
```jsx
<input style={{
  width: "100%", height: "40px",
  padding: "0 12px",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-md)",
  background: "var(--muted)",
  color: "var(--foreground)",
  fontFamily: "var(--font-family-body)",
  fontSize: "13px", outline: "none",
  marginBottom: "12px",
}} />
```

#### Tailwind Input
```jsx
<input className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg
                  focus:outline-none focus:ring-2 focus:ring-blue-500" />
```

#### Select (inline)
```jsx
<select style={{
  padding: "6px 14px", fontSize: "12px",
  border: "1px solid var(--border)", borderRadius: "6px",
  background: "white", cursor: "pointer",
}}>
```

#### Select (Tailwind)
```jsx
<select className="px-4 py-2 border border-slate-300 rounded-lg
                   focus:outline-none focus:ring-2 focus:ring-blue-500">
```

### 5.4 Avatar
```jsx
// DiceBear API (always used for person avatars):
<img
  src={`https://api.dicebear.com/9.x/thumbs/svg?seed=${seed}&backgroundColor=${bgColor}`}
  style={{ width: "32px", height: "32px", borderRadius: "50%", objectFit: "cover" }}
/>
// Background colors: ffd5dc (pink), b6e3f4 (blue), c0aede (purple)

// Tailwind fallback (color-initial avatar):
<div className={`w-8 h-8 rounded-full flex items-center justify-center text-white text-sm font-bold ${colorClass}`}>
  {initial}
</div>
```

### 5.5 Badge / Chip
```jsx
// Inline style — inline badge (small):
<span style={{
  color: "#15803d", background: "#dcfce7",
  padding: "2px 6px", borderRadius: "4px",
  fontWeight: 600, fontSize: "11px",
}}>Active</span>

// Inline style — larger status badge:
<span style={{
  background: "#fef3c7", color: "#b45309",
  padding: "4px 10px", borderRadius: "6px",
  fontSize: "11px", fontWeight: 600,
}}>Pending</span>

// Tailwind — rounded-full pill:
<span className="inline-block px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-700">
  Active
</span>
```

### 5.6 AI/Live Badge
```jsx
const aiBadge = {
  background: "linear-gradient(135deg, #4f46e5 0%, #9333ea 100%)",
  color: "white", fontSize: "10px",
  padding: "2px 6px", borderRadius: "4px",
  fontWeight: 600, display: "inline-flex",
  alignItems: "center", gap: "4px",
};
// Usage: <span style={aiBadge}>Live</span>
```

### 5.7 Progress Bar
```jsx
// Track:
<div style={{ height:"6px", background:"var(--secondary)", borderRadius:"3px", overflow:"hidden" }}>
  // Fill:
  <div style={{ height:"100%", width:`${percent}%`, background:"var(--primary)", borderRadius:"3px" }} />
</div>
```

### 5.8 Notification Dot
```jsx
<span style={{
  position: "absolute", top: "-2px", right: "-2px",
  width: "8px", height: "8px",
  background: "var(--destructive)", borderRadius: "50%",
  border: "2px solid var(--background)",
}} />
```

### 5.9 NavLink (Sidebar)
```jsx
<NavLink
  to={item.path}
  style={({ isActive }) => ({
    display: "flex", alignItems: "center", gap: "10px",
    padding: "8px 12px",
    borderRadius: "var(--radius-md)",
    color: isActive ? "var(--primary)" : "var(--foreground)",
    backgroundColor: isActive ? "var(--secondary)" : "transparent",
    textDecoration: "none",
    fontSize: "14px", fontWeight: 500,
    transition: "all 0.2s",
  })}
  onMouseEnter={e => { e.currentTarget.style.backgroundColor = "var(--secondary)"; }}
  onMouseLeave={e => { if (!e.currentTarget.getAttribute("aria-current")) e.currentTarget.style.backgroundColor = ""; }}
>
  <iconify-icon icon={item.icon} style={{ fontSize: "16px" }}></iconify-icon>
  {item.label}
</NavLink>
```

### 5.10 Tabs
```jsx
// Container: flex, gap 4px-8px, overflow-x auto, marginBottom 16px
// Active tab:
<button style={{ padding:"8px 16px", borderRadius:"6px",
                  background:"var(--primary)", color:"white",
                  fontSize:"14px", fontWeight:600, border:"none", cursor:"pointer" }}>
// Inactive tab:
<button style={{ padding:"8px 16px", borderRadius:"6px",
                  background:"var(--secondary)", color:"var(--muted-foreground)",
                  fontSize:"14px", fontWeight:500, border:"none", cursor:"pointer",
                  transition:"all 0.2s" }}>
```

### 5.11 Table (Tailwind approach — see Part 7 for full spec)
```jsx
<div className="overflow-x-auto mb-6">
  <table className="w-full">
    <thead>
      <tr className="border-b border-slate-200">
        <th className="text-left py-3 px-4 font-medium text-slate-600">Column</th>
      </tr>
    </thead>
    <tbody>
      <tr className="border-b border-slate-100 hover:bg-slate-50">
        <td className="py-3 px-4">content</td>
      </tr>
    </tbody>
  </table>
</div>
```

### 5.12 Pagination
```jsx
<div className="flex items-center justify-between">
  {/* Left: rows per page */}
  <div className="flex items-center gap-2">
    <span className="text-sm text-slate-600">Rows per page</span>
    <select className="px-3 py-1 border border-slate-300 rounded text-sm">
      <option value={10}>10</option><option value={25}>25</option>
    </select>
  </div>
  {/* Center: count */}
  <div className="text-sm text-slate-600">Showing {start}-{end} of {total}</div>
  {/* Right: prev/next */}
  <div className="flex items-center gap-2">
    <button className="p-2 border border-slate-300 rounded disabled:opacity-50 hover:bg-slate-50">
      <ChevronLeft size={18} />
    </button>
    <span className="text-sm text-slate-600">Page {current} of {total}</span>
    <button className="p-2 border border-slate-300 rounded disabled:opacity-50 hover:bg-slate-50">
      <ChevronRight size={18} />
    </button>
  </div>
</div>
```

### 5.13 Feature Pills (Login page hero)
```jsx
<div style={{
  display:"flex", alignItems:"center", gap:6,
  padding:"6px 13px",
  background:"rgba(255,255,255,0.05)",
  border:"1px solid rgba(255,255,255,0.09)",
  borderRadius:100, fontSize:12, color:"#94a3b8",
  backdropFilter:"blur(8px)",
}}>
  <Icon size={12} color="#818cf8" />{text}
</div>
```

---

## PART 6 — FORMS

### Form Container
```jsx
// Inline style (Settings page):
<div style={{
  maxWidth: "560px",
  background: "var(--background)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-md)",
  padding: "20px",
}}>
  <h1 style={{ margin:0, fontSize:"22px", color:"var(--foreground)" }}>Title</h1>
  <p style={{ margin:"8px 0 20px", fontSize:"13px", color:"var(--muted-foreground)" }}>Subtitle</p>
  {/* Fields */}
  <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", gap:"12px" }}>
    <span style={{ fontSize:"12px", color:"var(--muted-foreground)" }}>Helper text</span>
    <button type="button" /* primary save button */ />
  </div>
</div>
```

### Label Pattern
```jsx
<label style={{
  display: "block", marginBottom: "8px",
  fontSize: "12px", fontWeight: 600,
  color: "var(--muted-foreground)",
  textTransform: "uppercase", letterSpacing: "0.4px",
}}>
  Field Name
</label>
```

### Input Field Pattern
```jsx
<input style={{
  width: "100%", height: "40px", padding: "0 12px",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-md)",
  background: "var(--muted)", color: "var(--foreground)",
  outline: "none", marginBottom: "12px",
}} />
```

### Validation & Feedback
- **No form library** (no React Hook Form, Formik)
- Validate via `if (!form.field.trim()) return;` before submit
- Success: `saved` boolean state → inline green text (`color: "#16a34a"`)
- Reset after: `setTimeout(() => setSaved(false), 1500)`
- Error: inline red text below field or contextual message

### Multi-Category Form (Support page pattern — Tailwind)
```jsx
// Category buttons: array of icon+label+color, render as clickable tiles
// Priority: color-coded badge-style radio buttons
// Screen: native <select>
// Submit: "flex w-full items-center justify-center gap-2 py-3 px-5 rounded-xl bg-blue-600 text-white font-semibold"
// Success state: replace entire form with centered confirmation card
```

---

## PART 7 — TABLES

### Full Table Page Structure
```jsx
<div className="min-h-screen bg-slate-50 p-6">
  <div className="max-w-7xl mx-auto">

    {/* Page Header */}
    <div className="mb-8">
      <h1 className="text-3xl font-bold text-slate-900 mb-1">Title</h1>
      <p className="text-slate-600">N total • N active</p>
    </div>

    {/* Overview Stat Cards */}
    <div className="grid grid-cols-4 gap-4 mb-8">
      <div className="bg-white rounded-lg p-6 shadow-sm">
        <p className="text-slate-600 text-sm font-medium mb-2">Label</p>
        <p className="text-3xl font-bold text-slate-900 mb-2">Value</p>
        <p className="text-sm text-green-600">Trend</p>
      </div>
    </div>

    {/* Table Container */}
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-bold text-slate-900 mb-4">Directory Title</h2>
      <p className="text-slate-600 text-sm mb-4">Description</p>

      {/* Search + Filters (grid) */}
      <div className="grid grid-cols-4 gap-4 mb-4">
        {/* Search — col-span-2 with icon */}
        <div className="relative col-span-2">
          <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg
                             focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        {/* Dimension filters */}
        <select className="px-4 py-2 border border-slate-300 rounded-lg
                           focus:outline-none focus:ring-2 focus:ring-blue-500">
      </div>

      {/* Action Bar */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-4">
          <button className="flex items-center gap-2 px-4 py-2 border border-slate-300
                              text-slate-700 rounded-lg font-medium text-sm hover:bg-slate-50">
            Export CSV
          </button>
        </div>
        <div className="flex items-center gap-2 text-sm text-slate-600">
          <span className="px-3 py-1 bg-slate-100 rounded">Bulk Actions</span>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto mb-6">
        <table className="w-full">
          <thead>
            <tr className="border-b border-slate-200">
              <th className="text-left py-3 px-4 font-medium text-slate-600">
                <input type="checkbox" className="rounded" />
              </th>
              <th className="text-left py-3 px-4 font-medium text-slate-600">Student</th>
              <th className="text-left py-3 px-4 font-medium text-slate-600">Status</th>
              <th className="text-left py-3 px-4 font-medium text-slate-600">Actions</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row, idx) => (
              <tr key={row.id} className="border-b border-slate-100 hover:bg-slate-50">
                <td className="py-3 px-4"><input type="checkbox" className="rounded" /></td>
                <td className="py-3 px-4">
                  {/* Avatar + name + email column */}
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center
                                     text-white text-sm font-bold ${colorClass}`}>
                      {initial}
                    </div>
                    <div>
                      <p className="font-medium text-slate-900">{row.name}</p>
                      <p className="text-sm text-slate-600">{row.email}</p>
                    </div>
                  </div>
                </td>
                <td className="py-3 px-4">
                  <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${statusClass}`}>
                    {row.status}
                  </span>
                </td>
                <td className="py-3 px-4">
                  <button className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600 transition-colors">
                    <Trash2 size={15} />
                  </button>
                  <button className="p-1.5 rounded hover:bg-slate-100 text-slate-600 hover:text-slate-900 transition-colors">
                    <MoreVertical size={18} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between">...</div>
    </div>
  </div>
</div>
```

### Status Color Helper (always a function)
```jsx
const getStatusColor = (status) => {
  if (status === "Active") return "bg-green-100 text-green-700";
  if (status === "Onboard Pending") return "bg-yellow-100 text-yellow-700";
  if (status === "Flagged for low activity") return "bg-red-100 text-red-700";
  return "bg-slate-100 text-slate-700";
};
```

### Avatar Color Rotation (Tailwind table fallback)
```jsx
const getAvatarColor = (index) => {
  const colors = ["bg-blue-500","bg-purple-500","bg-pink-500","bg-orange-500",
                  "bg-green-500","bg-red-500","bg-indigo-500","bg-cyan-500"];
  return colors[index % colors.length];
};
```

---

## PART 8 — CARDS

### Card Hierarchy
1. **Page Container Card** (table/form wrapper): `bg-white rounded-lg shadow-md p-6`
2. **KPI Stat Card** (numeric): `kpiCard` (CSS vars) or `bg-white rounded-lg p-6 shadow-sm` (Tailwind)
3. **Admin Stat Card** (icon + metric): white bg, 12px radius, border, icon container 44×44
4. **Analytics Stat Card** (top-border accent): `rounded-xl border-t-4` (Tailwind)
5. **Content Card** (charts, lists): `card` object (CSS vars) — flex column, 8px radius, 20px padding
6. **Quick Action Card** (navigation): white bg, 12px radius, colored border on hover
7. **Event List Item** (inside content card): muted bg, border, 12px padding, flex row
8. **Person/Teammate Row** (inside content card): borderBottom divider, avatar + info + action
9. **Certificate Card**: template-colored bg, QR code, credential ID, verified badge
10. **Leaderboard Hero Card**: gradient bg, colored border, crown icon, avatar + pts + badge

### Event List Item Template
```jsx
<div style={{
  display:"flex", gap:"16px", padding:"12px",
  border:"1px solid var(--border)", borderRadius:"var(--radius-md)",
  background:"var(--muted)", alignItems:"center",
}}>
  {/* Date block: 50×50px flex-column center, white bg, border, borderRadius var(--radius-md) */}
  <div style={{ display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center",
                width:"50px", height:"50px", background:"#fff", border:"1px solid var(--border)",
                borderRadius:"var(--radius-md)", flexShrink:0 }}>
    <span style={{ fontSize:"10px", textTransform:"uppercase", color:"var(--muted-foreground)", fontWeight:600 }}>
      {month}
    </span>
    <span style={{ fontSize:"18px", fontWeight:700, color:"var(--foreground)" }}>{day}</span>
  </div>
  {/* Content */}
  <div style={{ flex:1 }}>
    <div style={{ fontSize:"14px", fontWeight:600, marginBottom:"4px" }}>{title}</div>
    <div style={{ fontSize:"12px", color:"var(--muted-foreground)", display:"flex", gap:"12px", alignItems:"center" }}>
      <span>{meta}</span>
      <span style={{ color:"#15803d", background:"#dcfce7", padding:"2px 6px",
                     borderRadius:"4px", fontWeight:600, fontSize:"11px" }}>
        {matchScore}
      </span>
    </div>
  </div>
  {/* Arrow button: 32×32px, borderRadius 6px */}
  <button style={{ background:"var(--background)", border:"1px solid var(--border)",
                   width:"32px", height:"32px", borderRadius:"6px", cursor:"pointer",
                   display:"flex", alignItems:"center", justifyContent:"center" }}>
    <iconify-icon icon="lucide:chevron-right" style={{ color:"var(--foreground)" }}></iconify-icon>
  </button>
</div>
```

### Person/Teammate Row Template
```jsx
<div style={{ display:"flex", alignItems:"center", gap:"12px",
              padding:"8px 0", borderBottom:"1px solid var(--border)" }}>
  <img src={avatarUrl} style={{ width:"32px", height:"32px", borderRadius:"50%" }} />
  <div>
    <div style={{ margin:0, fontSize:"13px", fontWeight:500 }}>{name}</div>
    <div style={{ margin:"2px 0 0", fontSize:"11px", color:"var(--muted-foreground)" }}>{role}</div>
  </div>
  <button style={{ marginLeft:"auto", background:"white", border:"1px solid var(--border)",
                   color:"var(--foreground)", fontSize:"11px", padding:"4px 8px",
                   borderRadius:"4px", cursor:"pointer", fontWeight:500 }}>
    Connect
  </button>
</div>
```

---

## PART 9 — CHARTS & ANALYTICS

### Plotly.js (Line/Area Chart)
```jsx
import Plot from "react-plotly.js";

<Plot
  data={[{
    x: dates,
    y: scores,
    customdata: deltas,
    type: "scatter",
    mode: "lines",
    line: { color, width: 3, shape: "spline", smoothing: 1.2 },
    marker: { size: 4, color },
    fill: "tozeroy",
    fillcolor: fill,   // rgba(r,g,b,0.2)
    showlegend: false,
    hovertemplate: "<b>Date</b>: %{x|%b %d, %Y}<br><b>Score</b>: %{y}<br><b>Gained</b>: %{customdata}<extra></extra>",
  }]}
  layout={{
    autosize: true,
    margin: { l: 30, r: 20, t: 10, b: 30 },
    paper_bgcolor: "rgba(0,0,0,0)",
    plot_bgcolor: "rgba(0,0,0,0)",
    dragmode: true,
    xaxis: { type:"date", showgrid:false, zeroline:false,
             tickfont: { family:"Inter, sans-serif", size:10, color:"#64748b" } },
    yaxis: { showgrid:true, gridcolor:"#eee", zeroline:false,
             tickfont: { family:"Inter, sans-serif", size:10, color:"#64748b" } },
    hovermode: "x unified",
    hoverlabel: { bgcolor:"#ffffff", bordercolor:color,
                  font: { family:"Inter, sans-serif", size:12 } },
    shapes: [
      // Reference line (dashed dot):
      { type:"line", x0:0, x1:1, xref:"paper", y0:90, y1:90,
        line: { color:"rgba(34,197,94,0.3)", width:1, dash:"dot" } }
    ],
  }}
  config={{ responsive:true, displayModeBar:false }}
  style={{ width:"100%", height:"100%" }}
  useResizeHandler={true}
/>
```

**Plotly Color Logic (by score range)**:
- ≥90: `color="#22C55E"`, `fill="rgba(34,197,94,0.2)"`
- ≥80: `color="#FFD700"`, `fill="rgba(255,215,0,0.2)"`
- <80: `color="#DC2626"`, `fill="rgba(220,38,38,0.2)"`

### Custom SVG Bar Chart
```jsx
function BarChart({ data, height=160, color="#bfdbfe", hoverColor="#2563eb" }) {
  const [hovered, setHovered] = useState(null);
  const max = Math.max(...data.map(d => d.value));
  const innerH = height - 28;
  return (
    <div className="relative" style={{ height: height + 8 }}>
      {/* Grid lines: border-t border-dashed border-slate-100, absolutely positioned */}
      <div className="flex items-end gap-2 relative z-10" style={{ height }}>
        {data.map((d, i) => {
          const barH = Math.max(4, (d.value / max) * innerH);
          return (
            <div key={i} className="flex flex-col items-center flex-1 cursor-pointer relative group"
                 onMouseEnter={() => setHovered(i)} onMouseLeave={() => setHovered(null)}>
              {/* Tooltip: absolute -top-9 bg-slate-800 text-white text-[11px] rounded-lg px-2.5 py-1.5 */}
              <span className={`text-[10px] font-semibold mb-0.5 ...`}>{d.value}</span>
              <div className="w-full rounded-t transition-all duration-200"
                   style={{ height: barH, background: hovered === i ? hoverColor : color }} />
              <p className="text-[9px] text-slate-400 mt-1.5 truncate">{d.label}</p>
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

### Custom SVG Donut Chart
```jsx
function DonutChart({ segments, title }) {
  const [hovered, setHovered] = useState(null);
  const total = segments.reduce((s, d) => s + d.value, 0);
  const R = 34, C = 2 * Math.PI * R;
  // SVG with stroke-dasharray, -rotate-90, strokeWidth 11 (or 14 on hover)
  // Center: absolute positioned label (shows total or hovered segment)
  // Legend: color dot (w-2 h-2 rounded-sm) + label + value + percentage
}
```

### Analytics Color Palette
- Default bar/line: `#3b82f6` (blue-500), hover `#2563eb` (blue-600)
- Area gradient: `#3b82f6` at 18% opacity → 0%
- Trend green: `#10b981`
- Tooltip bg: `#1e293b` (slate-800), text: white
- Grid lines: `#eee` (Plotly) / `border-slate-100` (SVG)

---

## PART 10 — ICONS

### Primary Method: Iconify Web Component
```jsx
// Always used as a web component — NOT as a React import
<iconify-icon icon="lucide:layout-dashboard" style={{ fontSize: "16px" }}></iconify-icon>
// Sizing: always via style.fontSize, never width/height attributes
// Self-closing INVALID — must use open+close tags
```

**String-based icon names (Iconify format)**:
- Sidebar: `"lucide:layout-dashboard"`, `"lucide:users"`, `"lucide:calendar"`, `"lucide:trophy"`, `"lucide:bar-chart-3"`, `"lucide:file-text"`, `"lucide:settings"`, `"lucide:life-buoy"`, `"lucide:graduation-cap"`, `"lucide:building-2"`, `"lucide:user-check"`, `"lucide:brain"`, `"lucide:zap"`, `"lucide:folder-kanban"`, `"lucide:medal"`, `"lucide:scroll-text"`, `"lucide:search"`, `"lucide:star"`, `"lucide:map-pin"`, `"lucide:shield-check"`, `"lucide:credit-card"`, `"lucide:globe"`, `"lucide:trending-up"`, `"lucide:award"`, `"lucide:cpu"`, `"lucide:network"`, `"lucide:book-open"`, `"lucide:plus-circle"`, `"lucide:bell"`, `"lucide:calendar-check"`, `"lucide:scale"`, `"lucide:flag"`, `"lucide:link"`, `"lucide:bookmark"`, `"lucide:plus"`

### Secondary Method: Lucide React Named Imports
```jsx
import { Trophy, Calendar, Search, Filter, Download, ChevronLeft, ChevronRight,
         MoreVertical, Trash2, Upload, UserPlus, LifeBuoy, Bug, Lightbulb,
         MessageCircle, Zap, Lock, ChevronDown, ChevronUp, Send, CheckCircle,
         Clock, AlertCircle, MessageSquare, ArrowUpRight, X } from "lucide-react";
<Trophy size={16} />
<Calendar size={16} color="#1e3a8a" />
```

### Icon Size Reference
| Context | Size |
|---------|------|
| Sidebar nav items | 16px |
| Navbar buttons (theme, bell) | 20px |
| Stat card icons | 22px |
| Quick action card icons | 22px |
| Button icons | 14–16px |
| Logo box icon | 16px |
| Card section icons | 14–16px |
| Trend/inline icons | 12px |
| Lucide in Tailwind pages | 16–18px (via `size` prop) |

### Placement Rules
- **Sidebar**: icon always LEFT of label, gap 10px
- **Buttons**: icon LEFT of label, gap 8px
- **Card titles**: optional icon LEFT of title, gap 8px, color matches section accent
- **KPI cards**: icon RIGHT of label text (via justify-between header row)
- **Stat cards**: icon in 44×44 container, LEFT of text content

---

## PART 11 — ANIMATIONS

### Hover Transitions (all interactive elements)
```css
/* Most elements */
transition: all 0.2s;
/* Color-only elements */
transition: color 0.2s, background 0.2s;
/* Chart elements */
transition: stroke-width 0.15s, opacity 0.15s;
```

### Quick Action Card Hover
```jsx
onMouseOver={e => {
  e.currentTarget.style.borderColor = action.color;
  e.currentTarget.style.boxShadow = `0 4px 12px ${action.color}15`;
}}
onMouseOut={e => {
  e.currentTarget.style.borderColor = "#e2e8f0";
  e.currentTarget.style.boxShadow = "none";
}}
```

### Page Mount Animations (Login page — `<style>` tag injection)
```css
.lp { opacity: 0; transform: translateX(-16px);
      transition: opacity 0.55s, transform 0.55s; }
.lp.in { opacity: 1; transform: translateX(0); }

.rp { opacity: 0; transform: translateY(12px);
      transition: opacity 0.5s 0.07s, transform 0.5s 0.07s; }
.rp.in { opacity: 1; transform: translateY(0); }

.fp { opacity: 0; transform: translateY(6px);
      transition: opacity 0.36s, transform 0.36s; }
.fp.in { opacity: 1; transform: translateY(0); }
```
Triggered: `mounted` useState(false) → `setTimeout(() => setMounted(true), 60)` in useEffect
Stagger: `transitionDelay: 0.26 + i * 0.06 + "s"` per pill

### Login Role Button Hover (via `<style>` injection + CSS vars)
```css
.role-btn {
  all: unset; display: flex; align-items: center; gap: 11px;
  padding: 10px 13px; border-radius: 11px; cursor: pointer; width: 100%;
  border: 1.5px solid #f1f5f9; background: white;
  transition: border-color 0.17s, box-shadow 0.17s, transform 0.17s;
}
.role-btn:hover {
  border-color: var(--c);            /* CSS var set per role card */
  transform: translateX(3px);
  box-shadow: -3px 0 0 0 var(--c) inset, 0 3px 14px rgba(0,0,0,0.07);
}
.role-btn:active { transform: translateX(1px) scale(0.99); }
```

### Constellation SVG Background (Login page)
```jsx
// Pure declarative SVG animation — no JS
<circle cx="..." cy="..." r="..." fill="...">
  <animate attributeName="opacity" values="0.1;0.65;0.1"
           dur="4.5s" repeatCount="indefinite" />
</circle>
// Duration per circle varies 3.5s–7.5s for organic feel
```

### Dark Mode Transitions (global, index.css)
```css
[data-theme="dark"] * {
  transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}
body {
  transition: background-color 0.2s ease, color 0.2s ease;
}
```

### Chart-Specific Interactions
- Donut hover: `strokeWidth` 11→14, other segments `opacity` 0.4
- Line chart circle hover: `r` 3→5
- Bar chart hover: fill color change via `hovered` state

---

## PART 12 — RESPONSIVE DESIGN

### Coverage
- **Desktop-only** for authenticated app (≥1200px viewport assumed)
- **One breakpoint**: 840px — login page only

### Login Breakpoint
```css
@media (max-width: 840px) {
  .left-col { display: none !important; }
  .right-col { width: 100% !important; }
}
```

### Main App Layout (Fixed Desktop)
- Sidebar: always 260px, `position: sticky, top: 0`
- No sidebar collapse, no hamburger menu
- Content: `flex: 1`, `overflowY: auto`
- All grids: fixed column counts (2, 3, 4 columns — no `auto-fill/auto-fit`)

### Overflow Strategy
| Element | Strategy |
|---------|---------|
| Root layout div | `height: 100vh; overflow: hidden` |
| Main content area | `overflowY: auto` |
| Sidebar nav | `overflowY: auto` (in case of many nav items) |
| Tables | `overflow-x: auto` wrapper div |

> **AI rule**: Build for ≥1200px viewport. If responsive behavior is needed, use only `@media (max-width: 840px)` as the breakpoint.

---

## PART 13 — STANDARD PAGE TEMPLATE

### Page Anatomy (Admin/Dashboard Style)
```jsx
export default function PageName() {
  /* ─── State ─────────────────────────────────────────────── */
  const [state, setState] = useState();
  const context = useAuth();

  /* ─── Derived ──────────────────────────────────────────── */
  const computed = useMemo(() => { /* ... */ }, [deps]);

  /* ─── Handlers ─────────────────────────────────────────── */
  function handleAction() { /* ... */ }

  /* ─── Data ──────────────────────────────────────────────── */
  const quickActions = [
    { icon: "lucide:plus-circle", label: "Action", description: "...",
      path: "/path", color: "#1e3a8a", bg: "#eff6ff" },
  ];
  const statsCards = [
    { icon: "lucide:calendar", label: "Total Events", value: n,
      subtitle: "N active", color: "#1e3a8a", bg: "#eff6ff" },
  ];

  return (
    <div style={{ padding:"24px 32px", maxWidth:"1400px", margin:"0 auto",
                  fontFamily:"Inter, sans-serif" }}>

      {/* ── 1. PAGE HEADER ───────────────────────────────── */}
      <div style={{ display:"flex", justifyContent:"space-between",
                    alignItems:"flex-start", marginBottom:"28px" }}>
        <div>
          <h1 style={{ fontSize:"26px", fontWeight:700,
                        margin:"0 0 8px 0", color:"#1e293b" }}>
            Page Title
          </h1>
          <p style={{ fontSize:"14px", color:"#64748b", margin:0 }}>
            Contextual subtitle
          </p>
        </div>
        <div style={{ display:"flex", alignItems:"center", gap:"12px" }}>
          {/* CTA button(s) */}
          <button style={{ display:"flex", alignItems:"center", gap:"8px",
                           padding:"10px 18px", background:"#1e3a8a",
                           color:"white", border:"none", borderRadius:"8px",
                           fontSize:"13px", fontWeight:600, cursor:"pointer" }}>
            <iconify-icon icon="lucide:plus" style={{ fontSize:"16px" }}></iconify-icon>
            Primary Action
          </button>
        </div>
      </div>

      {/* ── 2. STAT CARDS (4-col) ────────────────────────── */}
      <div style={{ display:"grid", gridTemplateColumns:"repeat(4, 1fr)",
                    gap:"16px", marginBottom:"28px" }}>
        {statsCards.map((stat, i) => (
          <div key={i} style={{ background:"white", borderRadius:"12px",
                                 padding:"20px", border:"1px solid #e2e8f0",
                                 display:"flex", alignItems:"flex-start", gap:"14px" }}>
            <div style={{ width:"44px", height:"44px", borderRadius:"10px",
                          background:stat.bg, display:"flex", alignItems:"center",
                          justifyContent:"center", flexShrink:0 }}>
              <iconify-icon icon={stat.icon}
                            style={{ fontSize:"22px", color:stat.color }}>
              </iconify-icon>
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontSize:"12px", color:"#64748b",
                            fontWeight:500, marginBottom:"4px" }}>
                {stat.label}
              </div>
              <div style={{ fontSize:"24px", fontWeight:700,
                            color:"#1e293b", marginBottom:"2px" }}>
                {stat.value}
              </div>
              <div style={{ fontSize:"12px", color:"#94a3b8" }}>
                {stat.subtitle}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* ── 3. QUICK ACTIONS (3-col) ─────────────────────── */}
      <div style={{ marginBottom:"28px" }}>
        <h2 style={{ fontSize:"16px", fontWeight:600,
                      color:"#1e293b", margin:"0 0 16px 0" }}>
          Quick Actions
        </h2>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)",
                      gap:"14px" }}>
          {quickActions.map((action, i) => (
            <Link key={i} to={action.path} style={{
              textDecoration:"none", background:"white", borderRadius:"12px",
              padding:"18px 20px", border:"1px solid #e2e8f0",
              display:"flex", alignItems:"center", gap:"14px", transition:"all 0.2s",
            }}
            onMouseOver={e => {
              e.currentTarget.style.borderColor = action.color;
              e.currentTarget.style.boxShadow = `0 4px 12px ${action.color}15`;
            }}
            onMouseOut={e => {
              e.currentTarget.style.borderColor = "#e2e8f0";
              e.currentTarget.style.boxShadow = "none";
            }}>
              <div style={{ width:"44px", height:"44px", borderRadius:"10px",
                            background:action.bg, display:"flex", alignItems:"center",
                            justifyContent:"center", flexShrink:0 }}>
                <iconify-icon icon={action.icon}
                              style={{ fontSize:"22px", color:action.color }}>
                </iconify-icon>
              </div>
              <div>
                <div style={{ fontSize:"14px", fontWeight:600,
                              color:"#1e293b", marginBottom:"2px" }}>
                  {action.label}
                </div>
                <div style={{ fontSize:"12px", color:"#64748b" }}>
                  {action.description}
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* ── 4. MAIN CONTENT (2:1 split) ─────────────────── */}
      <div style={{ display:"grid", gridTemplateColumns:"2fr 1fr", gap:"20px" }}>
        {/* Left column — primary content */}
        <div style={{ display:"flex", flexDirection:"column", gap:"20px" }}>
          <div style={{ background:"white", borderRadius:"12px",
                        border:"1px solid #e2e8f0", padding:"20px" }}>
            <div style={{ display:"flex", justifyContent:"space-between",
                          alignItems:"center", marginBottom:"16px" }}>
              <h3 style={{ fontSize:"15px", fontWeight:600,
                           color:"#1e293b", margin:0,
                           display:"flex", alignItems:"center", gap:"8px" }}>
                <iconify-icon icon="lucide:calendar"
                              style={{ fontSize:"16px", color:"#1e3a8a" }}>
                </iconify-icon>
                Section Title
              </h3>
              <Link to="/page" style={{ fontSize:"12px", color:"#1e3a8a",
                                        textDecoration:"none", fontWeight:500 }}>
                View All →
              </Link>
            </div>
            {/* Content — list, table, chart */}
          </div>
        </div>
        {/* Right column — secondary content */}
        <div style={{ display:"flex", flexDirection:"column", gap:"20px" }}>
          {/* Alerts, activity feed, deadlines */}
        </div>
      </div>

    </div>
  );
}
```

### Empty State
```jsx
{items.length === 0 && (
  <div style={{ textAlign:"center", padding:"40px",
                color:"var(--muted-foreground)", fontSize:"14px" }}>
    No items to display.
  </div>
)}
```

### Loading State
```jsx
{isLoading && (
  <div style={{ padding:"24px", color:"var(--muted-foreground)", textAlign:"center" }}>
    Loading...
  </div>
)}
```

---

## PART 14 — CODING CONVENTIONS

### Naming
| Element | Convention | Example |
|---------|-----------|---------|
| Components | PascalCase | `AdminDashboard`, `TeacherDashboard` |
| Sub-components (same file) | PascalCase | `StatCard`, `BarChart`, `TicketForm` |
| Functions/handlers | camelCase | `handleDelete`, `getStatusColor`, `formatDate` |
| State variables | camelCase | `searchTerm`, `currentPage`, `isLoading` |
| Data constants | SCREAMING_SNAKE_CASE | `SEED_STUDENTS`, `ROLE_OPTIONS`, `CATEGORIES` |
| Style objects | camelCase | `kpiCard`, `cardHeaderRow`, `aiBadge` |
| Icon string names | `"library:icon-name"` | `"lucide:building-2"` |
| Context hooks | `use` + ContextName | `useAuth()`, `useTheme()`, `useData()`, `useEvents()` |
| Route paths | kebab-case | `/admin/my-events`, `/recruiter/skill-heatmap` |

### File Naming
- Component files: PascalCase `.jsx` (e.g., `AdminDashboard.jsx`)
- Service files: camelCase `.js` (e.g., `githubApi.js`)
- Context files: PascalCase + `Context.jsx` (e.g., `AuthContext.jsx`)
- Utility files: camelCase `.js` (e.g., `reportGenerators.js`)

### Import Order (observed pattern)
```jsx
// 1. React + hooks
import { useState, useEffect, useMemo } from "react";
// 2. Router
import { Link, useNavigate } from "react-router-dom";
// 3. Chart libraries (if used)
import Plot from "react-plotly.js";
// 4. Icon libraries
import { Trophy, Calendar } from "lucide-react";
// 5. Context imports
import { useAuth, ROLES } from "../context/AuthContext";
import { useData } from "../context/DataContext";
import { useEvents } from "../context/EventsContext";
// 6. Services / data
import { getGithubStats } from "../services/githubApi";
import { SEED_STUDENTS } from "../data/seeds";
```

### File Structure (within a `.jsx` file)
```
1. Named imports (libraries → internal)
2. Module-scope DATA constants (arrays, config objects)
3. Sub-component function definitions (e.g., StatCard, BarChart)
4. Default export — main page component:
   a. useState/useContext/useMemo declarations
   b. Event handlers and helper functions
   c. Data arrays (quickActions, statsCards) derived from state
   d. return JSX
5. Module-scope STYLE objects (at the very bottom)
```

### JSX Props Conventions
- Inline styles: `style={{ camelCase: "value" }}`
- Iconify: `<iconify-icon icon="lucide:name" style={{ fontSize: "16px" }}></iconify-icon>` (open+close tags required)
- Lucide: `<Icon size={16} color="#hex" className="..."  />`
- Event handlers: `onClick={handler}`, `onMouseEnter`, `onMouseLeave`
- Hover via inline mutation: `e.currentTarget.style.backgroundColor = "..."`

### State Patterns
```jsx
// Filter state per dimension:
const [searchTerm, setSearchTerm] = useState("");
const [departmentFilter, setDepartmentFilter] = useState("All");
const [currentPage, setCurrentPage] = useState(1);
const [rowsPerPage, setRowsPerPage] = useState(10);

// Derived filtered list (always useMemo or inline):
const filtered = allItems.filter(item =>
  item.name.toLowerCase().includes(searchTerm.toLowerCase()) &&
  (departmentFilter === "All" || item.department === departmentFilter)
);
const totalPages = Math.ceil(filtered.length / rowsPerPage);
const displayed = filtered.slice((currentPage - 1) * rowsPerPage, currentPage * rowsPerPage);
```

---

## PART 15 — UI/UX RULES

### Button Hierarchy
1. **Primary CTA**: `var(--primary)` or `#1e3a8a` bg, white text, top-right of header
2. **Secondary action**: outline style, `var(--border)`, `var(--muted-foreground)` text
3. **Icon-only action**: no border, no bg, `var(--muted-foreground)`, hover bg
4. **Destructive**: only revealed on hover (no always-visible red buttons)
5. **Navigation as button**: `<Link>` with card styling, no text-decoration

### Color Semantics (enforced)
| Color | Meaning | Never Use For |
|-------|---------|--------------|
| `var(--primary)` / `#2b4ed6` | Brand, CTAs, active state | Errors, warnings |
| `#16a34a` / green | Success, active, positive | Neutral actions |
| `#b45309` / amber | Warning, pending, achievements | Errors |
| `#dc2626` / red | Error, destructive hover, critical | Success |
| `#64748b` / slate | Secondary text, labels | Headings |
| `#1e293b` / slate-800 | Headings, primary content text | Labels |

### Spacing Consistency Rules
- Page outer padding: always `24px` (student pages) or `24px 32px` (admin pages)
- Card internal padding: always `20px` on all sides — never mixed
- Grid gaps: `16px` (dense stat cards), `14px` (action cards), `20px` (content grid)
- Section margin-bottom: `24px` (student) or `28px` (admin)

### Information Hierarchy (strict enforcement)
1. `h1` 26–28px/700 → page title
2. `h2` 16px/600 → section title
3. `h3` 15px/600 → card header
4. Item title 14px/600 → list item name
5. Label 13px/500 → username, meta label
6. Caption 12px/400–500 → date, subtitle, icon label
7. Badge 11px/600 → status tag
8. Tick 10px/600 → chart axis, uppercase tracking label

### Action Placement
- Primary CTA: always top-right of page header section
- Secondary actions: right side of card header (as link or small button)
- Row actions: last column of table (16–18px icon buttons)
- Success/error feedback: immediately below the triggering element (no toasts)

---

## PART 16 — COMPONENT INVENTORY

| Component | File Location | Reusable | Styling Method | Dependencies |
|-----------|--------------|----------|----------------|-------------|
| `Sidebar` | `components/Sidebar.jsx` | ✅ Global | CSS vars + inline | AuthContext, Iconify |
| `Navbar` | `components/Navbar.jsx` | ✅ Global | CSS vars + inline | ThemeContext, Iconify |
| `MainLayout` | `layout/MainLayout.jsx` | ✅ Global | CSS vars + inline | Sidebar, Navbar |
| `AppLayout` | `layout/AppLayout.jsx` | ✅ Global | — | All pages |
| `ProtectedRoute` | Inside AppLayout.jsx | ✅ Global | — | AuthContext |
| `RoleProtectedRoute` | Inside AppLayout.jsx | ✅ Global | — | AuthContext |
| `RoleBasedDashboard` | Inside AppLayout.jsx | ✅ Global | — | AuthContext |
| `ComingSoon` | Inside AppLayout.jsx | ✅ Global | CSS vars + inline | — |
| `RepoCard` | `components/RepoCard.jsx` | ✅ | CSS vars + inline | — |
| `CertificateTemplate` | `components/CertificateTemplate.jsx` | ✅ | inline | jsPDF |
| `ThemeProvider` | `context/ThemeContext.jsx` | ✅ | — | localStorage |
| `AuthProvider` | `context/AuthContext.jsx` | ✅ | — | localStorage |
| `DataProvider` | `context/DataContext.jsx` | ✅ | — | localStorage |
| `EventsProvider` | `context/EventsContext.jsx` | ✅ | — | localStorage |
| `StatCard` | Inline in `Analytics.jsx` | ⚠️ Page-scoped | Tailwind | lucide-react |
| `BarChart` | Inline in `Analytics.jsx` | ⚠️ Page-scoped | Tailwind | — |
| `LineChart` | Inline in `Analytics.jsx` | ⚠️ Page-scoped | Tailwind + SVG | — |
| `DonutChart` | Inline in `Analytics.jsx` | ⚠️ Page-scoped | Tailwind + SVG | — |
| `TicketForm` | Inline in `Support.jsx` | ⚠️ Page-scoped | Tailwind | DataContext, AuthContext |
| `QRBlock` | Inline in `Certificates.jsx` | ⚠️ Page-scoped | inline | — |
| `ConstellationBg` | Inline in `Login.jsx` | ⚠️ Page-scoped | SVG + style tag | — |

---

## PART 17 — MASTER DESIGN RULES (AI Generation Guide)

These are the non-negotiable rules for generating new pages in this design system.

### Rule 1: Shell is Never Recreated
New pages are `<Outlet>` children. Never add a second sidebar, navbar, or layout wrapper. Routes belong in `AppLayout.jsx` inside the `ProtectedRoute → MainLayout` group.

### Rule 2: CSS Custom Properties for Theme-Sensitive Colors
```jsx
// ✅ CORRECT (themed pages)
background: "var(--card)"
color: "var(--foreground)"
border: "1px solid var(--border)"

// ❌ WRONG — breaks dark mode
background: "#ffffff"
color: "#0f172a"
```

### Rule 3: Card is the Primary Layout Unit
Wrap every content section in a card — never leave content floating. Choose one approach per page:
```jsx
// Inline style approach:
<div style={{ background:"var(--card)", border:"1px solid var(--border)",
              borderRadius:"var(--radius-lg)", padding:"20px" }}>
// Tailwind approach:
<div className="bg-white rounded-xl border border-slate-200 p-5">
```

### Rule 4: 4-Column Stat Row is Mandatory on Dashboards
All dashboard-style pages start with a 4-column grid of metric cards before charts/tables.

### Rule 5: One Icon Method Per Page
- Pages using `var(--token)` styles → Iconify web component
- Pages using Tailwind → Lucide React named imports
- **Never mix both in the same page file**

### Rule 6: Inter is the Only Font
`fontFamily: "var(--font-family-body)"` — never use any other font. Sora/DM Sans are login-only.

### Rule 7: Single Styling Approach Per Card
Never mix `var(--token)` inline styles with Tailwind utilities in the same element tree.

### Rule 8: All Interactions Need Transitions
```jsx
// Inline: transition: "all 0.2s"
// Tailwind: className="transition-colors" or "transition-all"
```

### Rule 9: Status Colors Follow the Semantic System
| Status | BG | Text |
|--------|----|----|
| Active/Success | `#dcfce7` / `bg-green-100` | `#15803d` / `text-green-700` |
| Warning/Pending | `#fef3c7` / `bg-yellow-100` | `#b45309` / `text-yellow-700` |
| Error/Critical | `#fef2f2` / `bg-red-100` | `#dc2626` / `text-red-700` |
| Info | `#dbeafe` / `bg-blue-100` | `#1d4ed8` / `text-blue-700` |
| Neutral | `#f1f5f9` / `bg-slate-100` | `#475569` / `text-slate-700` |

### Rule 10: Every Page Has a Standard Header
```jsx
<div style={{ display:"flex", justifyContent:"space-between",
              alignItems:"flex-start", marginBottom:"28px" }}>
  <div>
    <h1 style={{ fontSize:"26px", fontWeight:700,
                  margin:"0 0 8px 0", color:"#1e293b" }}>Title</h1>
    <p style={{ fontSize:"14px", color:"#64748b", margin:0 }}>Subtitle</p>
  </div>
  {/* CTA buttons */}
</div>
```

### Rule 11: No New CSS Files for Pages
Use inline `style={{}}` or Tailwind. If CSS classes are required, inject via `<style>` tag inside the component (like Login.jsx does).

### Rule 12: CSS Grid Over Flexbox for Multi-Column Layouts
```jsx
display: "grid"
gridTemplateColumns: "repeat(4, 1fr)"    // stats
gridTemplateColumns: "repeat(3, 1fr)"    // actions
gridTemplateColumns: "2fr 1fr"           // main + sidebar
```

### Rule 13: Quick Action Cards Always 3-Column
All quick navigation cards use `repeat(3, 1fr)` grid with the icon-container + label + description pattern.

### Rule 14: Main Content Uses 2:1 Split
Primary panel (`2fr`) + secondary panel (`1fr`) — both are `flex column, gap 20px` of cards.

### Rule 15: Avatars Always Use DiceBear
```jsx
`https://api.dicebear.com/9.x/thumbs/svg?seed=${seed}&backgroundColor=${bgHex}`
// Bg colors: ffd5dc, b6e3f4, c0aede
```

### Rule 16: Data is Always Defined in the Component File
Mock data arrays declared at module scope. No global store except the 4 contexts.

### Rule 17: All New Routes Are Protected
Inside `<Route element={<ProtectedRoute><MainLayout /></ProtectedRoute>}>` in AppLayout.jsx.

### Rule 18: Card Content Sections Have Consistent Header Pattern
```jsx
// Card section header:
<div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:"16px" }}>
  <h3 style={{ fontSize:"15px", fontWeight:600, color:"#1e293b", margin:0 }}>
    Section Title
  </h3>
  <Link style={{ fontSize:"12px", color:"#1e3a8a", textDecoration:"none" }}>View All →</Link>
</div>
```

### Rule 19: Icon Containers for Stat Cards Are 44x44
```jsx
<div style={{ width:"44px", height:"44px", borderRadius:"10px",
              background:stat.bg, display:"flex", alignItems:"center",
              justifyContent:"center", flexShrink:0 }}>
  <iconify-icon icon={stat.icon} style={{ fontSize:"22px", color:stat.color }}></iconify-icon>
</div>
```

### Rule 20: No TODOs, No Placeholders, No Incomplete Code
- All mock data arrays must contain ≥3 realistic entries
- All handler functions must be implemented (even if as stubs)
- All card padding must be uniform: `20px` all sides
- Always include `marginBottom` on every major section
- Never use placeholder text like "Lorem ipsum" or `undefined`

---

## APPENDIX A — CSS Variable Quick Reference

```
/* Light / Dark */
var(--background)       #ffffff  /  #0f172a
var(--foreground)       #0f172a  /  #e2e8f0
var(--card)             #ffffff  /  #1e293b
var(--card-foreground)  #0f172a  /  #e2e8f0
var(--primary)          #2b4ed6  /  #818cf8
var(--primary-foreground) #ffffff / #ffffff
var(--secondary)        #f1f5f9  /  #1e293b
var(--muted)            #f8fafc  /  #1e293b
var(--muted-foreground) #64748b  /  #94a3b8
var(--border)           #e2e8f0  /  #334155
var(--destructive)      #ef4444  /  #f87171

/* Radius */
var(--radius-lg)   8px
var(--radius-md)   6px
var(--radius-sm)   4px

/* Font */
var(--font-family-body)  "Inter", system-ui, -apple-system, sans-serif
```

## APPENDIX B — Hardcoded Colors (not in CSS vars)

```
/* Admin & section accents (always used hardcoded) */
Admin Blue:      #1e3a8a (bg: #eff6ff)
Info Blue:       #2563eb (bg: #eff6ff)
Success Green:   #16a34a, #15803d (bg: #dcfce7, #ecfdf5)
Positive Trend:  #22C55E (chart fill)
Warning Amber:   #b45309, #d97706 (bg: #fef3c7)
Purple:          #7c3aed, #6366f1 (bg: #f3e8ff)
Cyan:            #0891b2 (bg: #ecfeff)
Danger Red:      #dc2626, #ef4444 (bg: #fef2f2)
Text Dark:       #1e293b
Text Mid:        #64748b
Text Light:      #94a3b8
Border:          #e2e8f0

/* Tailwind equivalents */
slate-800: #1e293b | slate-600: #475569 | slate-500: #64748b | slate-400: #94a3b8
blue-900: #1e3a8a | green-600: #16a34a | amber-700: #b45309 | red-600: #dc2626
```

## APPENDIX C — Tailwind Classes Most Commonly Used

```
Layout:   min-h-screen, p-6, max-w-7xl, mx-auto, grid, grid-cols-4, gap-4, gap-8
          flex, items-center, justify-between, flex-col, gap-2, gap-4
Cards:    bg-white, rounded-lg, rounded-xl, shadow-sm, shadow-md, p-6, p-5, border, border-slate-200
Text:     text-slate-900, text-slate-600, text-slate-500, text-slate-400, text-slate-300
          text-sm, text-xs, font-bold, font-semibold, font-medium, uppercase, tracking-wide
Status:   bg-green-100, text-green-700, bg-yellow-100, text-yellow-700, bg-red-100, text-red-700
          bg-blue-100, text-blue-700, bg-slate-100, text-slate-700, rounded-full
Inputs:   border-slate-300, focus:outline-none, focus:ring-2, focus:ring-blue-500
Table:    border-b, border-slate-200, border-slate-100, hover:bg-slate-50, py-3, px-4
Buttons:  px-4, py-2, bg-blue-600, hover:bg-blue-700, text-white, rounded-lg, transition-colors
          hover:bg-slate-50, hover:bg-red-50, hover:text-red-600, transition-colors
Charts:   overflow-hidden, rounded-t, transition-all, duration-200, absolute, relative, z-10
```

## APPENDIX D — Page-by-Page Styling Method

| Page | Method | Notes |
|------|--------|-------|
| `Dashboard.jsx` | CSS vars + inline | Style objects at bottom of file |
| `Login.jsx` | `<style>` tag injection + inline | Dark bg `#080d1a`, SVG constellation |
| `Analytics.jsx` | Tailwind | Custom SVG charts inline |
| `Students.jsx` | Tailwind | Table page, DiceBear avatars |
| `Support.jsx` | Tailwind | Ticket form with constants |
| `Settings.jsx` | CSS vars + inline | Minimal form |
| `Certificates.jsx` | CSS vars + inline | Card-heavy |
| `Leaderboard.jsx` | CSS vars + inline | Top-3 hero cards + table rows |
| `AdminDashboard.jsx` | Inline hardcoded hex | Uses `#1e293b`, `#64748b` directly |
| `SuperAdminDashboard.jsx` | Inline hardcoded hex | Same as AdminDashboard |
| `admin/*` | Mix of inline + Tailwind | Per page |
| `teacher/*` | Mix of inline + Tailwind | Per page |
| `recruiter/*` | Mix of inline + Tailwind | Per page |

---

*Reverse-engineered from the CampusMitra frontend codebase as of 2026-07-07.*
*Use this document as the authoritative source of truth when generating new pages in this design system.*
