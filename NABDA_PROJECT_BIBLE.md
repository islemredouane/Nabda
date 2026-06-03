# NABDA نبضة — PROJECT BIBLE
> **MASTER REFERENCE — READ THIS BEFORE WRITING A SINGLE LINE OF CODE**
> Every decision in this document is FINAL. Do not suggest alternatives. Do not go outside this scope.
> Last confirmed: 2026-06-02 (EcoHack '26 hackathon day)

---

## 0. WHO THIS FILE IS FOR

This file is the single source of truth for the Nabda project. Each team member gives this file to their AI assistant at the start of every session. The AI must:
- Stay strictly within confirmed decisions
- Never suggest replacing confirmed libraries with alternatives
- Never add features not listed here
- Never add a database, backend service, or cloud provider not listed here
- When in doubt, ask the human — do not invent

---

## 1. PROJECT IDENTITY

| Field | Value |
|---|---|
| **Name** | Nabda نبضة |
| **Tagline** | Algeria's Youth Opportunity Navigator |
| **Meaning** | "Heartbeat" in Arabic — the pulse of youth opportunity |
| **Challenge** | Connect Algerian youth with ODEJ programs, activities, and services across Algeria |
| **Event** | EcoHack '26 — organized by Club Origo, Akbou, Béjaïa, Algeria |
| **Theme** | Green Tech / Eco sustainability |
| **Team** | Islam · Anir · Yanis |
| **Deadline** | 23 hours from H0 (hackathon day 2026-06-02) |

**What Nabda IS:**
A personalized Progressive Web App (PWA) that learns who you are (through intelligent onboarding), then surfaces the ODEJ activities and opportunities most relevant to you — via a smart feed, a searchable catalog, an interactive map, and an AI chatbot that only answers from real ODEJ data.

**What Nabda is NOT:**
- Not a social network
- Not a generic directory
- Not a database-backed SaaS
- Not a clone of an existing app

---

## 2. TEAM ROLES — FIXED, NO EXCEPTIONS

| Member | Level | Owns |
|---|---|---|
| **Islam** | Most experienced — Frontend Lead | ALL complex UI, ALL pages, ALL components, map, design system, data architecture wiring |
| **Anir** | AI-assisted — Content Pipeline | All JSON data files (AI-generated), all translations, pitch deck, README, eco report, 2 simple UI components (ImpactCard, BadgeGrid — layout only) |
| **Yanis** | AI Engineer | AI assistant ONLY: /api/chat, RAG, cache, query routing, eco stats API, all /api/* routes |

**The Rule: Islam builds. Anir feeds. Yanis thinks.**
- Anir prepares what Islam needs NEXT — never blocking, never in the critical path
- Yanis never touches frontend code
- Islam never touches AI routes
- Anir never writes logic — only markup/layout for her 2 simple components

---

## 3. TECH STACK — CONFIRMED, NO SUBSTITUTIONS

### Core Framework
| Package | Version | Why |
|---|---|---|
| `next` | 16.2.7 | App Router, SSG+ISR, API routes, Vercel-native |
| `react` | 19.2.4 | Concurrent features |
| `typescript` | latest | Type safety |

### Styling & UI
| Package | Why |
|---|---|
| `tailwindcss` v4 | Utility-first, purges unused CSS (eco) |
| `shadcn/ui` 4.10 | Accessible components, no runtime overhead |
| `framer-motion` 12.x | Page transitions + animations (minimal usage) |

### AI & Chat
| Package | Why |
|---|---|
| `@anthropic-ai/sdk` 0.100.x | Claude Haiku 3.5 API |
| `ai` (Vercel AI SDK) 6.x | Streaming responses to frontend |

**AI Model: `claude-haiku-3-5` — CONFIRMED. Do NOT switch to Groq, GPT, Gemini, or any other model.**
Reason: Better Arabic/Tamazight quality, reliable RAG grounding, recognized by hackathon judges.

### Map
| Package | Why |
|---|---|
| `leaflet` | 42KB vs Google Maps 500KB+ |
| `react-leaflet` | React wrapper |
| `react-leaflet-cluster` | Cluster markers, max ~50 DOM elements |
| `geolib` | Client-side distance calc — zero API calls |

**Map tiles: CartoDB Positron — 30% lighter than standard OpenStreetMap. CONFIRMED.**

### Utilities
| Package | Why |
|---|---|
| `next-intl` | i18n: AR (RTL) + FR + Tamazight |
| `next-pwa` | Offline-first PWA, service worker |
| `date-fns` | Date formatting |
| `zod` | Schema validation |

### NOT USED — DO NOT ADD
- ❌ PostgreSQL / any SQL database
- ❌ Supabase / Firebase / PlanetScale / Turso
- ❌ Prisma / Drizzle / any ORM
- ❌ Redis / any key-value store
- ❌ LangChain / LlamaIndex / any AI framework
- ❌ Groq / OpenAI / Gemini / any other AI provider
- ❌ Google Maps / Mapbox / any paid map service
- ❌ AWS / GCP / Azure / any cloud infra
- ❌ GraphQL / tRPC / any API layer
- ❌ Zustand / Redux / any global state manager (use localStorage + React state)
- ❌ react-query / SWR (use native fetch + ISR)

---

## 4. ARCHITECTURE — CONFIRMED DECISIONS

### Storage: JSON Flat Files (NO DATABASE)
```
public/data/
  activities-light.json   ← map markers + feed cards (minimal fields)
  activities-detail.json  ← full activity data (loaded on click)
  centers.json            ← ODEJ centers
  wilayas.json            ← 58 wilayas + coordinates
  registrations.json      ← user registrations (append-only array)
```
**Why JSON:** Zero cold starts, no DB setup, no server cost, directly satisfies eco mandate. Map bbox queries done in JS array filter — same result as SQL WHERE at hackathon scale (500 activities max).

### Rendering: SSG + ISR
- All pages statically generated at build time
- When admin publishes a new activity → `revalidatePath()` → ISR rebuilds affected pages instantly
- Zero server compute per page visit

### User Data: localStorage Only
- `DnaProfile` stored client-side in localStorage
- Zero server cost, zero privacy risk, zero backend needed
- Key: `nabda_dna_profile`

### Deployment: Vercel (confirmed)
- `npm run build` → `vercel deploy`
- Environment variables: `ANTHROPIC_API_KEY`, `ADMIN_PASSWORD`

---

## 5. DATA SCHEMAS — CONFIRMED, DO NOT MODIFY

### activities-light.json (array of objects)
```typescript
{
  id: string           // "act_001"
  lat: number          // 36.7538
  lng: number          // 3.0588
  cat: string          // "sport" | "culture" | "formation" | "volontariat" | "sante"
  title: string        // Arabic title (primary)
  wilaya: string       // "Alger"
  startDate: string    // ISO "2026-06-15"
  spotsLeft: number    // 12
  isFree: boolean      // true
}
```

### activities-detail.json (array of objects)
```typescript
{
  // all fields from activities-light, PLUS:
  title_i18n: { ar: string, fr: string, tz: string }
  description: { ar: string, fr: string, tz: string }
  tags: string[]
  centerId: string
  endDate: string
  ageMin: number
  ageMax: number
  capacity: number
  registered: number
  image: string        // relative path or placeholder
  contact: string
  createdAt: string    // ISO datetime
}
```
**CRITICAL: IDs in activities-light.json and activities-detail.json MUST match exactly.**

### centers.json (array of objects)
```typescript
{
  id: string
  name: string
  wilaya: string
  wilayaId: number     // 1-58
  lat: number
  lng: number
  address: string
  phone: string
  activePrograms: number
}
```

### wilayas.json (array of objects)
```typescript
{
  id: number           // 1-58
  name: { ar: string, fr: string }
  lat: number
  lng: number
}
```

### DnaProfile (localStorage)
```typescript
{
  userId: string              // uuid generated on first visit
  wilaya: string
  wilayaCoords: { lat: number, lng: number }
  age: number
  language: "ar" | "fr" | "tz"
  interests: string[]         // ["sport", "culture", ...]
  availability: string[]      // ["weekend", "evening", ...]
  goal: string                // "learn" | "volunteer" | "compete" | "socialize"
  mood: number                // 1-5, updated daily
  dnaScores: Record<string, number>   // category → match %
  points: number
  badges: string[]
  registeredIds: string[]
  attendedIds: string[]
  onboardingComplete: boolean
  lastSeen: string            // ISO date
}
```

---

## 6. APP PAGES & NAVIGATION — CONFIRMED

### Bottom Navigation (5 tabs, mobile-first)
```
🏠 Home    🔍 Explore    🗺️ Map    🤖 Nabda AI    👤 Profile
```

### Routes
```
/[locale]/                    → Home Feed (personalized)
/[locale]/onboarding          → 6-step intelligent onboarding + DNA card
/[locale]/explore             → Full catalog + filters
/[locale]/map                 → Interactive map
/[locale]/assistant           → AI chatbot
/[locale]/profile             → DNA profile + gamification
/[locale]/activity/[id]       → Activity detail + register button
/admin                        → ODEJ dashboard (no locale prefix)
/admin/activities/new         → Add activity form
```

### Locales: `ar` (default, RTL) | `fr` | `tz`

---

## 7. API ROUTES — CONFIRMED

```
POST /api/chat              → RAG + cache + routing + streaming
GET  /api/chat              → Live eco stats (tokens saved, CO2)
GET  /api/map/markers       → bbox filter, returns activities-light subset
GET  /api/map/detail/[id]   → Single activity full detail (on click)
POST /api/register          → Activity registration (append to registrations.json)
POST /api/admin/auth        → Password check (returns JWT-like token)
POST /api/admin/translate   → AR input → FR + TZ via Claude Haiku
POST /api/admin/publish     → Write to JSON files + ISR revalidatePath()
GET  /api/carbon            → Eco metrics for Live CO2 Dashboard
```

---

## 8. FEATURES — CONFIRMED COMPLETE LIST

### 8.1 Intelligent Onboarding (6 Steps)
1. **Language picker** — AR / FR / TZ (sets app locale)
2. **Wilaya picker** — searchable dropdown, all 58 wilayas
3. **Age tiles** — visual age range selection
4. **Interest Grid** — visual category tiles (sport, culture, formation, volontariat, santé, art, tech, environnement)
5. **Availability picker** — morning / evening / weekend / flexible
6. **Goal picker** — learn / volunteer / compete / socialize

**Output:** Animated DNA Result Card showing interest bars + top 3 matched activities + "Browse More" button → /explore

### 8.2 DNA Profile Engine
- `dna-engine.ts` — calculates match % per activity based on DNA scores
- Scores stored in `DnaProfile.dnaScores` in localStorage
- Feed + Explore sort by DNA match % descending
- Mood (daily check-in, 1-5) applies ±10% modifier to scores

### 8.3 Home Feed
- Reads `DnaProfile` from localStorage
- Shows personalized activity cards sorted by DNA match %
- MoodCheck widget at top (daily mood, 1-5 emoji scale)
- CarbonBadge on every page showing grams CO2 for current page
- Sections: "For You", "Near You", "This Weekend", "Free Activities"

### 8.4 Explore Page
- Full activity catalog from activities-light.json
- Filters: wilaya, category, date range, free/paid, age group
- Sort: relevance (DNA) / date / distance
- ActivityCard component (reused across feed + explore)

### 8.5 Map Page
**3-level progressive loading:**
- L1: All markers (lat/lng/cat only) — loaded on mount (~50 bytes/marker)
- L2: Viewport bbox filter — only markers in current view
- L3: Click marker → fetch activities-detail entry

**Optimizations:**
- Leaflet.js + CartoDB Positron tiles
- SVG inline markers (zero image downloads, dynamically colored per category)
- react-leaflet-cluster (max ~50 DOM elements regardless of markers count)
- Debounce 400ms on map moveend
- Bbox in-memory cache (Map), 5min TTL
- geolib for client-side "Near Me" radius filter (zero API calls)
- NearMeControl button → gets GPS → filters by radius
- BottomSheet (mobile) / DetailPanel (desktop) on marker click
- SSR: false on MapContainer (Leaflet is browser-only)

### 8.6 AI Assistant (Nabda AI)
**6-gate pipeline (in order):**
1. Empty input → reject immediately, 0 tokens
2. Exact cache hit → return cached answer, 0 tokens
3. DB routing → if simple factual question → answer from JSON, 0 tokens
4. History compression → compress old messages before sending
5. RAG context building → inject relevant activities into prompt
6. Claude Haiku 3.5 → stream response

**Rules enforced in system prompt:**
- ONLY answer from provided context (activities data)
- NEVER invent activities, dates, locations, or contact info
- If no relevant activity found → say so honestly
- Multilingual: detect user language, respond in same language
- AbortController kills stream if user navigates away

**Cache:** In-memory Map, exact match, 2h TTL

### 8.7 Profile Page
- Animated DNA score bars per interest category
- Nabda Points counter
- Badge grid (badges: first registration, 5 activities, wilaya explorer, etc.)
- Wilaya leaderboard (top youth in user's wilaya)
- Registered activities list

### 8.8 Activity Detail Page
- Full activity info (all languages)
- Register button → POST /api/register → updates registrations.json
- SpotsLeft counter (capacity - registered)
- After attendance: ImpactCard (shareable, generated client-side)

### 8.9 Gamification
- **Nabda Points:** earned on registration, attendance, sharing
- **Badges:** milestone-based, stored in DnaProfile.badges
- **Wilaya Leaderboard:** aggregated from localStorage data (client-side, no server)

### 8.10 Live CO2 Dashboard
- Shows in real-time: tokens saved, API calls avoided, grams CO2 saved vs GPT-4 baseline
- Formula: CO2 per page = bytes × 0.0000006 gCO2
- Powered by GET /api/carbon (in-memory counters, reset on server restart)

### 8.11 Carbon Badge
- Small component on every page footer
- Displays gCO2 for current page
- Green color = good, amber = medium

### 8.12 Admin No-Code CMS
- `/admin` — password protected (ADMIN_PASSWORD env var)
- ODEJ staff fills form: title (AR), description (AR), category, date, wilaya, capacity, center, contact
- POST /api/admin/translate → Claude Haiku auto-translates AR→FR+TZ
- Staff reviews translations, confirms
- POST /api/admin/publish → writes to JSON files + triggers ISR revalidation
- Activity appears instantly on feed + map + chatbot knowledge base

### 8.13 PWA / Offline
- next-pwa generates service worker
- Caches: map tiles (24h), activities-light.json, last-visited activity details
- Offline banner when no connection

### 8.14 Internationalization
- next-intl with 3 locales: `ar` (RTL, default), `fr`, `tz`
- Fonts: Cairo (Arabic/Tamazight) + Inter (Latin/French)
- RTL: full layout mirroring for Arabic
- Language detected from onboarding step 1, stored in DnaProfile

---

## 9. DESIGN SYSTEM — CONFIRMED, DO NOT CHANGE

### Colors (CSS variables in globals.css)
```css
--bg:        #0a0f0a   /* page background — deep dark green-black */
--surface:   #111a11   /* cards, panels */
--surface-2: #1a2a1a   /* elevated surfaces, modals */
--primary:   #22c55e   /* green-500 — CTAs, active states, brand */
--accent:    #f59e0b   /* amber-400 — highlights, badges, points */
--text:      #f0fdf4   /* near-white green tint — primary text */
--muted:     #86efac   /* green-300 — secondary text */
--border:    #1f2f1f   /* subtle borders */
```

### Typography
- **Arabic / Tamazight:** Cairo (Google Fonts)
- **French / Latin:** Inter (Google Fonts)
- Base size: 16px
- Scale: Tailwind default (text-sm, text-base, text-lg, text-xl, text-2xl, text-3xl)

### Dark Mode
- **Always dark. No light mode. No toggle.**
- `dark` class on `<html>` tag, never removed

### Motion
- Framer Motion for page transitions (fade + slide, 200ms)
- Framer Motion for DNA Result Card bars (animate from 0 to value)
- No heavy animations elsewhere (eco principle)
- `prefers-reduced-motion` respected

### Mobile-First
- Primary viewport: 375px (iPhone SE)
- Bottom navigation (not sidebar)
- Touch targets: minimum 44×44px
- No hover-only interactions

---

## 10. COMPONENTS — CONFIRMED LIST

### Islam builds (complex):
- `BottomNav.tsx` — 5-tab bottom navigation
- `PageTransition.tsx` — Framer Motion wrapper
- `CarbonBadge.tsx` — per-page CO2 indicator
- `ActivityCard.tsx` — used in feed + explore + search results
- `OnboardingFlow.tsx` — step controller (6 steps)
- `DnaResultCard.tsx` — animated bars + top matches
- `MoodCheck.tsx` — daily mood widget (1-5 emoji)
- `HomeFeed.tsx` — personalized feed with sections
- `ExploreFilters.tsx` — filter sidebar/drawer
- `ActivityList.tsx` — virtualized list of ActivityCard
- `LeafletMap.tsx` (MapContainer, SSR disabled)
- `MarkerLayer.tsx` (SVG inline markers, clustered)
- `NearMeControl.tsx` (GPS + geolib radius filter)
- `BottomSheet.tsx` (mobile marker click detail)
- `DetailPanel.tsx` (desktop marker click detail)
- `ChatInterface.tsx` — streaming chat UI
- `MessageBubble.tsx` — individual message
- `DnaProfile.tsx` — animated score bars
- `PointsCounter.tsx` — animated counter
- `ActivityForm.tsx` (admin — with logic wired to API)
- `TranslationPanel.tsx` (admin — with logic wired to API)

### Anir builds (layout only, no logic):
- `ImpactCard.tsx` — static shareable card layout
- `BadgeGrid.tsx` — static badge display grid

---

## 11. UTILITY LIBRARIES — CONFIRMED

### Islam writes:
- `lib/dna-engine.ts` — DNA scoring algorithm
- `lib/map-markers.ts` — SVG marker generator per category

### Yanis writes:
- `lib/knowledge-base.ts` — loads + indexes activities-detail.json for RAG
- `lib/chat-cache.ts` — in-memory Map cache, 2h TTL
- `lib/query-router.ts` — classifies questions: simple (DB) vs complex (LLM)
- `lib/rag.ts` — builds context string from knowledge base
- `lib/history-compressor.ts` — compresses old messages before sending to Claude

---

## 12. AI PIPELINE — DETAILED (Yanis Reference)

### /api/chat POST — 6 Gates
```
Gate 1: if (!message || message.trim() === '') → return 400
Gate 2: if (cache.has(message)) → return cached, increment cache_hits counter
Gate 3: if (queryRouter.isSimple(message)) → answer from JSON, increment db_hits counter
Gate 4: compress history if messages.length > 6
Gate 5: rag.buildContext(message) → inject top 3 matching activities into system prompt
Gate 6: anthropic.messages.stream({ model: 'claude-haiku-3-5', ... }) → stream to client
        → on complete: cache.set(message, fullResponse); increment llm_calls counter
```

### System Prompt Rules (multilingual, enforced)
```
You are Nabda AI, the official assistant for Nabda, Algeria's youth opportunity navigator.
You ONLY answer questions about ODEJ activities and programs using the provided context.
You NEVER invent activities, dates, locations, phone numbers, or contact information.
If the user asks about something not in the context, say you don't have that information and invite them to explore the map or catalog.
Always respond in the same language the user writes in (Arabic, French, or Tamazight).
Be warm, encouraging, and brief. Maximum 3 short paragraphs per response.
```

### /api/chat GET — Eco Stats
```json
{
  "cache_hits": 142,
  "db_hits": 89,
  "llm_calls": 21,
  "tokens_saved": 284000,
  "co2_saved_grams": 18.4,
  "vs_gpt4_multiplier": "68%"
}
```

---

## 13. ECO STRATEGY — PROVABLE NUMBERS FOR JUDGES

| Optimization | Method | Savings |
|---|---|---|
| Map initial data | 50B/marker vs 2KB standard | **−97.5%** |
| Map API calls on scroll | Debounce 400ms | **−60 to −80%** |
| Map DOM elements | Clustering (max ~50 nodes) | **−90%** |
| Map marker images | SVG inline (zero files) | **−100% network** |
| Map tile revisits | Browser cache 24h | **−90%** |
| Distance calculation | geolib client-side | **−100% network** |
| AI calls | DB routing (68%) + exact cache | **−68%** |
| Database cold starts | No database | **−100%** |
| Page CO2 target | bytes × 0.0000006 | **~0.03g vs 2.1g industry avg** |

**Provable in pitch because:**
- Live CO2 Dashboard shows real-time numbers during demo
- Carbon Badge on every page shows per-page cost
- All numbers are measurable from network tab (DevTools)

---

## 14. MINIMUM VIABLE DEMO (if time runs short)

Must work for judges to evaluate:
1. ✅ Onboarding (all 6 steps) → DNA Result Card
2. ✅ Home Feed (shows personalized activities)
3. ✅ AI Chat (RAG, no hallucination, streaming)
4. ✅ Map (markers visible, click → detail in bottom sheet)
5. ✅ Admin publishes activity → appears on feed + map + chatbot knows about it

**Cut if time runs short (mention in pitch but don't demo):**
- Gamification points/badges
- ImpactCard sharing
- PWA offline mode
- Tamazight (partial is fine, mention it)

---

## 15. PITCH DECK STRUCTURE (15 slides — Anir's responsibility)

1. Cover — Nabda نبضة + tagline
2. The Problem — Algerian youth don't know what ODEJ offers
3. Our Solution — Nabda: personalized, eco-first, multilingual
4. Meet the User — persona: 19yo from Tizi Ouzou, wants a summer opportunity
5. Intelligent Onboarding — screenshot + DNA card
6. Personalized Feed — screenshot
7. AI Assistant — demo GIF or screenshot, highlight RAG + no hallucination
8. Interactive Map — screenshot, highlight eco optimizations
9. Admin CMS — how ODEJ publishes in 2 minutes
10. Tech Stack — visual diagram (Next.js + Leaflet + Claude Haiku + JSON)
11. Eco Impact — the table from section 13 above with real numbers
12. Live CO2 Dashboard — screenshot
13. Green Tech Principles — how every decision was eco-motivated
14. Roadmap — after hackathon: more wilayas, SMS notifications, offline full sync
15. Team + Call to Action — Islam · Anir · Yanis + live demo URL

---

## 16. FOLDER STRUCTURE — CONFIRMED

```
ecohack-app/                          ← project root (C:\Users\AZ\Documents\ecohack-app)
├── app/
│   ├── [locale]/
│   │   ├── page.tsx                  ← Home Feed
│   │   ├── onboarding/page.tsx
│   │   ├── explore/page.tsx
│   │   ├── map/page.tsx
│   │   ├── assistant/page.tsx
│   │   ├── profile/page.tsx
│   │   └── activity/[id]/page.tsx
│   ├── admin/
│   │   ├── page.tsx
│   │   └── activities/new/page.tsx
│   └── api/
│       ├── chat/route.ts
│       ├── map/
│       │   ├── markers/route.ts
│       │   └── detail/[id]/route.ts
│       ├── register/route.ts
│       ├── carbon/route.ts
│       └── admin/
│           ├── auth/route.ts
│           ├── translate/route.ts
│           └── publish/route.ts
├── components/
│   ├── ui/                           ← shadcn/ui components
│   ├── BottomNav.tsx
│   ├── ActivityCard.tsx
│   ├── PageTransition.tsx
│   ├── CarbonBadge.tsx
│   ├── onboarding/
│   │   ├── OnboardingFlow.tsx
│   │   └── DnaResultCard.tsx
│   ├── feed/
│   │   ├── HomeFeed.tsx
│   │   └── MoodCheck.tsx
│   ├── explore/
│   │   ├── ExploreFilters.tsx
│   │   └── ActivityList.tsx
│   ├── map/
│   │   ├── LeafletMap.tsx
│   │   ├── MarkerLayer.tsx
│   │   ├── NearMeControl.tsx
│   │   ├── BottomSheet.tsx
│   │   └── DetailPanel.tsx
│   ├── chat/
│   │   ├── ChatInterface.tsx
│   │   └── MessageBubble.tsx
│   ├── profile/
│   │   ├── DnaProfile.tsx
│   │   ├── PointsCounter.tsx
│   │   ├── BadgeGrid.tsx            ← Anir (layout only)
│   │   └── ImpactCard.tsx           ← Anir (layout only)
│   └── admin/
│       ├── ActivityForm.tsx
│       └── TranslationPanel.tsx
├── lib/
│   ├── dna-engine.ts                 ← Islam
│   ├── map-markers.ts                ← Islam
│   ├── knowledge-base.ts             ← Yanis
│   ├── chat-cache.ts                 ← Yanis
│   ├── query-router.ts               ← Yanis
│   ├── rag.ts                        ← Yanis
│   └── history-compressor.ts         ← Yanis
├── public/
│   └── data/
│       ├── activities-light.json     ← Anir generates
│       ├── activities-detail.json    ← Anir generates
│       ├── centers.json              ← Anir generates
│       ├── wilayas.json              ← Anir generates
│       └── registrations.json        ← starts as []
├── messages/
│   ├── ar.json                       ← Anir generates
│   ├── fr.json                       ← Anir generates
│   └── tz.json                       ← Anir generates
├── styles/
│   └── globals.css                   ← Islam (colors + fonts)
├── .env.local                        ← Yanis creates
│   # ANTHROPIC_API_KEY=sk-ant-...
│   # ADMIN_PASSWORD=nabda2026
├── next.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

---

## 17. ENVIRONMENT VARIABLES

```env
ANTHROPIC_API_KEY=sk-ant-...       # Required — Claude Haiku 3.5
ADMIN_PASSWORD=nabda2026            # Required — Admin CMS login
NEXT_PUBLIC_APP_URL=http://localhost:3000   # Dev
```

---

## 18. SPRINT CHECKPOINTS

| Checkpoint | Time | Must be done |
|---|---|---|
| H1 | +1h | App runs, dark theme visible, 20 activities in JSON |
| H4 | +4h | ActivityCard renders with real data, Yanis's chat returns response |
| H8 | +8h | Full onboarding works end-to-end, DNA card shows, AI answers from data |
| H12 | +12h | Feed personalized, Explore filters work, map renders with markers |
| H16 | +16h | Map fully works (clusters, Near Me, bottom sheet), Chat UI streams |
| H18 | +18h | Admin publishes → appears on feed + map + chatbot |
| H20 | +20h | Polished, Lighthouse > 90, eco numbers documented |
| H22 | +22h | Pitch deck final, Vercel deployed, demo rehearsed |

---

## 19. HOW TO HAND THIS FILE TO AN AI ASSISTANT

Copy this prompt:

```
I'm working on Nabda نبضة, a hackathon project.
Read the attached NABDA_PROJECT_BIBLE.md first.
Every decision in that file is FINAL and CONFIRMED.
Do not suggest alternatives to any confirmed library, tool, or architecture.
Do not add features not listed in the file.
Do not add any database, backend service, or AI provider not listed.
My role on this project is: [Islam / Anir / Yanis]
My current task is: [describe your task]
```

---

*Nabda نبضة — Algeria's Youth Opportunity Navigator*
*EcoHack '26 — Club Origo, Akbou, Béjaïa*
