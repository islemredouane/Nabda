# 🤖 ANIR — Content Pipeline + Support
> NABDA · EcoHack '26 · 23h Sprint

**Your tools:** ChatGPT / Claude / Copilot to generate content · Canva / PowerPoint for pitch  
**Your domain:** All data files, all translations, pitch deck, docs, simple isolated components

---

## 🎯 YOUR MISSION
You are **Islam's content pipeline**. He builds the UI — you make sure the data he needs is always ready BEFORE he needs it. Your work doesn't require deep coding knowledge. Use AI tools to generate everything. Your job is to **copy, paste, verify, and deliver**.

---

## ⚠️ THE GOLDEN RULE
> **Never block Islam.** If he's building something and needs data or a translation — it must already be ready. You are always one step ahead of him.

---

## ⏱️ H0 → H1 | SETUP

- [ ] Open Claude / ChatGPT — keep it open the whole session
- [ ] Create the empty JSON files (Islam will tell you exact paths)
- [ ] Start generating activities JSON immediately (see Task 1 below)

---

## ⏱️ H1 → H3 | DATA FILES — PRIORITY #1

These are needed by H4. Do these FIRST, FAST.

---

### Task 1 — `src/data/activities-light.json`

**Paste this prompt into Claude/ChatGPT:**

> *Generate a JSON array of exactly 50 Algerian ODEJ youth activities. Each object must have EXACTLY these fields: id (act_001 to act_050), lat (realistic Algerian latitude 18–37), lng (realistic Algerian longitude -9 to 9), cat (one of: sport, art, tech, eco, volunteer, camp, formation), title (short Arabic title, realistic), wilaya (one of: alger, oran, constantine, bejaia, tizi-ouzou, setif, batna, annaba, blida, msila — distribute evenly), startDate (between 2026-06-10 and 2026-08-30), spotsLeft (random 1–30), isFree (true for 80% of them). Return ONLY the JSON array, no explanation.*

Copy the output into `src/data/activities-light.json`. Verify it looks correct (valid JSON, 50 items).

---

### Task 2 — `src/data/activities-detail.json`

**Paste this prompt into Claude/ChatGPT:**

> *Take the following activities-light.json and expand each entry into a full activity object. Add these fields to EACH entry: title_i18n (object with ar, fr, tz — translate the title to French and basic Tamazight), description (object with ar, fr, tz — write 2 sentences about the activity in each language), tags (array of 3–4 relevant strings in English like "outdoor", "summer", "teamwork"), centerId (format center_[wilaya]_001), endDate (3–7 days after startDate), ageMin (14 or 16), ageMax (25 or 30), capacity (spotsLeft + random 5–20), registered (capacity - spotsLeft), image (null), contact (null), createdAt ("2026-06-01"). Keep all original fields. Return ONLY the JSON array.*
>
> [paste your activities-light.json here]

Copy output into `src/data/activities-detail.json`.

> ⚠️ **IMPORTANT:** Every `id` in activities-detail.json must match activities-light.json exactly.

---

### Task 3 — `src/data/wilayas.json`

**Paste this prompt:**

> *Generate a JSON array of all 58 Algerian wilayas. Each object: id (two-digit string "01" to "58"), name (object with ar and fr), lat (wilaya capital latitude), lng (wilaya capital longitude). Return ONLY the JSON array.*

Save to `src/data/wilayas.json`.

---

### Task 4 — `src/data/centers.json`

**Paste this prompt:**

> *Generate a JSON array of 25 realistic Algerian ODEJ "Maison des Jeunes" youth centers. Each object: id (format center_[wilaya]_001), name (realistic French name like "Maison des Jeunes [city]"), wilaya (use these: alger, oran, constantine, bejaia, tizi-ouzou, setif, batna, annaba, blida, msila, bouira, medea, jijel, skikda, guelma — 1-3 centers per wilaya), wilayaId (two-digit string), lat, lng (realistic coordinates in that wilaya), address (realistic Algerian street address), phone (format +213 XX XX XX XX), activePrograms (number 1–6). Return ONLY the JSON array.*

Save to `src/data/centers.json`.

---

### Task 5 — `src/data/categories.json`

```json
[
  { "id": "sport",     "emoji": "⚽", "ar": "رياضة",    "fr": "Sport",        "color": "#00897B" },
  { "id": "art",       "emoji": "🎨", "ar": "فن وثقافة","fr": "Art & Culture", "color": "#E64A19" },
  { "id": "tech",      "emoji": "💻", "ar": "تقنية",    "fr": "Technologie",  "color": "#1565C0" },
  { "id": "eco",       "emoji": "🌱", "ar": "بيئة",     "fr": "Environnement","color": "#2E7D32" },
  { "id": "volunteer", "emoji": "🤝", "ar": "تطوع",     "fr": "Bénévolat",    "color": "#AD1457" },
  { "id": "camp",      "emoji": "🏕️","ar": "مخيمات",   "fr": "Camps",        "color": "#6A1B9A" },
  { "id": "formation", "emoji": "📚", "ar": "تكوين",    "fr": "Formation",    "color": "#F9A825" }
]
```

---

### Task 6 — `src/data/registrations.json`

Just create this file with:
```json
[]
```

---

## ⏱️ H4 → H8 | TRANSLATION FILES — PRIORITY #2

Islam needs these for H7.

---

### Task 7 — `src/i18n/ar.json`

```json
{
  "nav": {
    "home": "الرئيسية",
    "explore": "استكشاف",
    "map": "الخريطة",
    "assistant": "نبضة AI",
    "profile": "ملفي"
  },
  "onboarding": {
    "step1": "اختر لغتك",
    "step2": "في أنهي ولاية تسكن؟",
    "step3": "كم عمرك؟",
    "step4": "واش تحب تدير؟",
    "step5": "امتى تكون حر؟",
    "step6": "شنو تبغي تحقق؟",
    "result": "نبضتك جاهزة! ✨",
    "next": "التالي →",
    "skip": "تخطي",
    "selectAll": "اختر كل اللي يعجبك"
  },
  "feed": {
    "greeting": "أهلاً",
    "subtitle": "اكتشف فرصتك اليوم",
    "perfectForYou": "🔥 مثالي لك هذا الأسبوع",
    "fillingFast": "🔴 يمتلئ بسرعة",
    "inYourWilaya": "📍 في ولايتك",
    "seeAll": "عرض كل الفرص ←",
    "mood": "كيفاش حالك اليوم؟ 😊"
  },
  "activity": {
    "register": "سجّل الآن",
    "spotsLeft": "مكان متبقي",
    "free": "مجاني",
    "match": "تطابق مع اهتماماتك",
    "registered": "تم التسجيل ✅"
  },
  "explore": {
    "title": "استكشاف",
    "all": "الكل",
    "mapView": "🗺️ خريطة",
    "listView": "☰ قائمة",
    "noResults": "ما لقيناش نتائج",
    "askAi": "اسأل نبضة AI ←"
  },
  "assistant": {
    "title": "نبضة AI",
    "placeholder": "اسألني عن الأنشطة...",
    "suggested": [
      "واش كاين قريب مني؟",
      "أنشطة مجانية هذا الأسبوع؟",
      "معسكرات صيفية؟",
      "أنشطة بيئية؟"
    ],
    "ecoStats": "إحصائيات البيئة"
  },
  "profile": {
    "title": "ملفي",
    "points": "نقطة",
    "rank": "في ولايتي",
    "myDna": "نبضتي 🧬",
    "badges": "الشارات",
    "history": "سجل النشاطات",
    "upcoming": "قادمة ⏳",
    "completed": "مكتملة ✅",
    "browseMore": "استكشف المزيد ←",
    "editPrefs": "✏️ تعديل الاهتمامات"
  },
  "categories": {
    "sport": "رياضة",
    "art": "فن وثقافة",
    "tech": "تقنية",
    "eco": "بيئة",
    "volunteer": "تطوع",
    "camp": "مخيمات",
    "formation": "تكوين"
  },
  "carbon": {
    "label": "صفحة خضراء 🌱",
    "saved": "وفرنا 98% من الكربون"
  },
  "admin": {
    "title": "لوحة ODEJ",
    "addActivity": "إضافة نشاط",
    "publish": "نشر",
    "translate": "✨ ترجمة تلقائية",
    "published": "✅ تم النشر! يظهر في التطبيق الآن"
  }
}
```

---

### Task 8 — `src/i18n/fr.json`

```json
{
  "nav": {
    "home": "Accueil",
    "explore": "Explorer",
    "map": "Carte",
    "assistant": "Nabda AI",
    "profile": "Profil"
  },
  "onboarding": {
    "step1": "Choisissez votre langue",
    "step2": "Dans quelle wilaya habitez-vous?",
    "step3": "Quel âge avez-vous?",
    "step4": "Qu'est-ce que vous aimez faire?",
    "step5": "Quand êtes-vous disponible?",
    "step6": "Quel est votre objectif?",
    "result": "Votre Nabda est prête! ✨",
    "next": "Suivant →",
    "skip": "Passer",
    "selectAll": "Sélectionnez tout ce qui vous intéresse"
  },
  "feed": {
    "greeting": "Bonjour",
    "subtitle": "Découvrez votre opportunité du jour",
    "perfectForYou": "🔥 Parfait pour vous cette semaine",
    "fillingFast": "🔴 Presque complet",
    "inYourWilaya": "📍 Dans votre wilaya",
    "seeAll": "Voir toutes les opportunités →",
    "mood": "Comment tu te sens aujourd'hui? 😊"
  },
  "activity": {
    "register": "S'inscrire maintenant",
    "spotsLeft": "places restantes",
    "free": "Gratuit",
    "match": "Correspond à votre profil",
    "registered": "Inscrit ✅"
  },
  "explore": {
    "title": "Explorer",
    "all": "Tout",
    "mapView": "🗺️ Carte",
    "listView": "☰ Liste",
    "noResults": "Aucun résultat trouvé",
    "askAi": "Demander à Nabda AI →"
  },
  "assistant": {
    "title": "Nabda AI",
    "placeholder": "Posez une question sur les activités...",
    "suggested": [
      "Activités près de moi?",
      "Activités gratuites cette semaine?",
      "Camps d'été disponibles?",
      "Activités environnementales?"
    ],
    "ecoStats": "Statistiques écologiques"
  },
  "profile": {
    "title": "Mon Profil",
    "points": "points",
    "rank": "dans ma wilaya",
    "myDna": "Mon ADN 🧬",
    "badges": "Badges",
    "history": "Historique",
    "upcoming": "À venir ⏳",
    "completed": "Terminé ✅",
    "browseMore": "Explorer plus →",
    "editPrefs": "✏️ Modifier mes préférences"
  },
  "categories": {
    "sport": "Sport",
    "art": "Art & Culture",
    "tech": "Technologie",
    "eco": "Environnement",
    "volunteer": "Bénévolat",
    "camp": "Camps",
    "formation": "Formation"
  },
  "carbon": {
    "label": "Page verte 🌱",
    "saved": "98% moins de CO₂"
  },
  "admin": {
    "title": "Tableau de bord ODEJ",
    "addActivity": "Ajouter une activité",
    "publish": "Publier",
    "translate": "✨ Traduction automatique",
    "published": "✅ Publié! Visible sur l'application maintenant"
  }
}
```

---

### Task 9 — `src/i18n/tz.json`

**Paste this prompt into AI:**

> *Translate this JSON file from French to Tamazight (use Latin Tamazight script, not Tifinagh, keep it simple and readable). Keep all JSON keys exactly the same. Only translate the string values. Return ONLY the JSON.*
>
> [paste fr.json here]

Save output to `src/i18n/tz.json`. Don't worry if it's not perfect — basic Tamazight is enough.

---

## ⏱️ H8 → H14 | PITCH DECK — PRIORITY #3

Islam is building the complex parts. You build the pitch deck now.

---

### Task 10 — Pitch Deck (15 slides)

Use Canva, PowerPoint, or Google Slides. Dark green theme (#0a0f0a background, #22c55e green accents).

**Slide structure:**

| # | Title | Content |
|---|---|---|
| 1 | **NABDA نبضة** | Tagline: "Algeria's Youth Opportunity Navigator" + team names |
| 2 | **The Problem** | "Millions of Algerian youth don't know what ODEJ offers near them" — stat/visual |
| 3 | **The Solution** | Simple diagram: Youth ↔ Nabda ↔ ODEJ |
| 4 | **How It Works** | 5 steps: Sign up → Onboarding → Personalized feed → Discover → Register |
| 5 | **Intelligent Onboarding** | Screenshot or mockup of DNA profile card |
| 6 | **AI Assistant** | "Grounded RAG — zero hallucination" — show chat example |
| 7 | **Interactive Map** | Map screenshot — markers, clusters, Near Me |
| 8 | **Admin Dashboard** | "ODEJ staff publishes in 30 seconds — no code" |
| 9 | **Green Tech — Eco Architecture** | The 3-layer diagram (DB/LLM routing) |
| 10 | **Eco Numbers** | Table: Naive vs Nabda vs Gain % (fill from MASTER_TIMELINE eco targets) |
| 11 | **Live CO₂ Dashboard** | Screenshot of eco stats widget in chat |
| 12 | **Tech Stack** | Next.js · Tailwind · shadcn · Leaflet · Claude Haiku · JSON KB |
| 13 | **Multilingual** | Show AR + FR + Tamazight side by side |
| 14 | **Evaluation Criteria** | Score table — how we address each criterion |
| 15 | **Demo + Thank You** | Live URL + GitHub link + team |

**For eco numbers on slide 10, use these:**

| Criterion | Naive approach | Nabda | Gain |
|---|---|---|---|
| Initial data | 5MB (all markers) | ~10KB (visible only) | −99.8% |
| API calls (map scroll) | 1/sec | 1/400ms debounced | −80% |
| AI calls | 100% questions | ~32% (rest = DB/cache) | −68% |
| Marker images | PNG downloads | SVG inline | −100% |
| Tile revisit | Reload each time | Cache 24h | −90% |
| Distance calc | External API | geolib client-side | −100% |

---

## ⏱️ H14 → H18 | DOCS + SIMPLE COMPONENTS

---

### Task 11 — README.md

**Paste into AI:**

> *Write a professional GitHub README.md for a project called Nabda (نبضة) — Algeria's Youth Opportunity Navigator, built for EcoHack '26. Include: project description, the problem it solves, key features (intelligent onboarding, DNA profile, RAG AI assistant, interactive eco-map, admin dashboard), tech stack (Next.js 14, Tailwind, shadcn/ui, Leaflet, Claude Haiku), eco-efficiency highlights (real numbers from our architecture), setup instructions (npm install, .env.local, npm run dev), team (Islam, Anir, Yanis), license (MIT). Make it look professional with badges and emojis.*

Save as `README.md` in project root.

---

### Task 12 — Eco Efficiency Report

**Paste into AI:**

> *Write a 1-page technical eco-efficiency report for a hackathon project called Nabda. The report should cover: 1) Architecture choices that minimize carbon footprint, 2) Data loading strategy (3-level: L1 markers only 50B, L2 viewport bbox, L3 on-click), 3) AI usage optimization (DB/LLM routing saves 68% of AI calls, in-memory cache, history compression), 4) Map optimizations (Leaflet 42KB vs Google Maps 500KB, SVG markers, debounce 400ms, clustering), 5) Static generation (SSG+ISR, zero server compute per request), 6) Quantified gains table. Format as a proper technical document.*

Save as `ECO_REPORT.md` or give to Yanis to convert to PDF.

---

### Task 13 — `src/components/shared/DnaMatchBadge.tsx`

Simple isolated component. Copy-paste this exactly:

```tsx
export default function DnaMatchBadge({ score }: { score: number }) {
  const color = score >= 80 ? '#22c55e' : score >= 60 ? '#f59e0b' : '#6b7280'
  return (
    <span style={{ color, background: `${color}18` }}
      className="text-xs font-bold px-2 py-0.5 rounded-full">
      ★ {score}% match
    </span>
  )
}
```

---

### Task 14 — `src/components/profile/BadgeGrid.tsx`

```tsx
const BADGES = [
  { id: 'first-pulse',    emoji: '🌱', ar: 'النبضة الأولى',  fr: 'Première Nabda',    unlocked: true },
  { id: 'green-warrior',  emoji: '🌍', ar: 'المحارب الأخضر', fr: 'Guerrier Vert',      unlocked: false },
  { id: 'three-streak',   emoji: '🔥', ar: '3 أسابيع متواصلة',fr: '3 semaines actif', unlocked: false },
  { id: 'champ',          emoji: '🏆', ar: 'بطل الولاية',    fr: 'Champion Wilaya',   unlocked: false },
]

export default function BadgeGrid({ earnedIds = [] }: { earnedIds?: string[] }) {
  return (
    <div className="grid grid-cols-4 gap-3">
      {BADGES.map(b => {
        const unlocked = earnedIds.includes(b.id)
        return (
          <div key={b.id}
            className={`flex flex-col items-center gap-1.5 p-3 rounded-2xl border ${
              unlocked ? 'border-[var(--primary)]/40 bg-[var(--primary)]/5' : 'border-[var(--border)] opacity-40'
            }`}>
            <span className="text-2xl">{b.emoji}</span>
            <span className="text-[9px] text-[var(--muted)] text-center leading-tight">{b.fr}</span>
          </div>
        )
      })}
    </div>
  )
}
```

---

## ⏱️ H18 → H20 | TESTING SUPPORT

Help Islam test:

- [ ] Open the app and go through the full onboarding in Arabic
- [ ] Go through onboarding in French
- [ ] Verify every activity card shows a title (not undefined)
- [ ] Check all 3 language switches work in nav
- [ ] Test the AI chat — type 3 questions in Arabic and check answers make sense
- [ ] Take screenshots of each screen for the pitch deck

---

## ⏱️ H20 → H23 | PITCH FINALIZATION

- [ ] Add real screenshots from the app to pitch deck
- [ ] Add real eco numbers from Yanis to slide 10
- [ ] Add live Vercel URL to slide 15
- [ ] Add GitHub URL to slide 15
- [ ] Print or open pitch deck on a second screen
- [ ] Rehearse the 2-minute demo script with team

---

## ✅ YOUR FULL CHECKLIST

**Data files (6 files):**
- [ ] `activities-light.json` — 50 activities ✅
- [ ] `activities-detail.json` — same 50, full data ✅
- [ ] `wilayas.json` — all 58 wilayas ✅
- [ ] `centers.json` — 25+ centers ✅
- [ ] `categories.json` — 7 categories ✅
- [ ] `registrations.json` — empty `[]` ✅

**Translations (3 files):**
- [ ] `ar.json` — complete ✅
- [ ] `fr.json` — complete ✅
- [ ] `tz.json` — basic ✅

**Docs:**
- [ ] `README.md`
- [ ] `ECO_REPORT.md`
- [ ] Pitch deck (15 slides, dark green theme)

**Simple components:**
- [ ] `DnaMatchBadge.tsx`
- [ ] `BadgeGrid.tsx`

**Testing:**
- [ ] Onboarding tested in AR + FR
- [ ] All JSON files verified (valid, no undefined)
- [ ] Screenshots taken for pitch deck

---

## 💡 HOW TO USE AI TO HELP YOU

For any task you're unsure about:
1. Copy the task description
2. Paste into Claude/ChatGPT with: *"I'm building a Next.js app called Nabda for a hackathon. [task description]. Give me exactly what I need to copy-paste, no explanation."*
3. Copy the output
4. Tell Islam what you've done

**Never guess on JSON structure.** If a field name is unclear, ask Islam first. Wrong IDs = broken app.
