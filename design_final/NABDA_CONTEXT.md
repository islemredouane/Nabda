# NABDA — Context Complet du Projet

## 1. Vue d'ensemble

**Nabda** (en arabe : **نبضة**, signifiant "impulsion/battement") est une plateforme web de type **Youth Opportunity Navigator** destinée à la jeunesse algérienne (16-30 ans). Développée pour **EcoHack'26**, elle centralise les événements, activités bénévoles, formations et programmes ODEJ (Office des Établissements de Jeunes) à travers les 48 wilayas d'Algérie.

**Pitch** : Une seule plateforme pour découvrir, s'inscrire et participer aux opportunités jeunesse en Algérie, avec un système de récompenses (DNA tokens) et des recommandations personnalisées basées sur le comportement de l'utilisateur.

---

## 2. Stack technique

| Composant | Technologie |
|---|---|
| **Frontend** | HTML/CSS/JS monofichier SPA (`index.html`, ~280KB) |
| **CSS** | Tailwind CSS (CDN) + CSS custom properties (dark/light theming) |
| **Typographie** | Bebas Neue (titres éditoriaux) + Inter (corps) + Cairo (sous-titres arabes) |
| **Icons** | Google Material Symbols Outlined |
| **Carte** | Leaflet.js + CartoDB DarkMatter tiles + MarkerCluster |
| **Backend/Auth** | Supabase (PostgreSQL + Auth + RLS) |
| **Hébergement dev** | Python `http.server` sur port 5500 |
| **IA chatbot** | Page dédiée Nabda AI (interface style Gemini, réponses simulées) |

---

## 3. Architecture SPA

Le site est une **Single Page Application** — toutes les pages sont des `<div class="page">` dans un seul fichier HTML. La navigation est gérée par JavaScript (`navigate(pageId)`).

### Pages existantes

| Page ID | Nom | Description |
|---|---|---|
| `auth` | Connexion | Login / Signup / Social auth (Google, Apple) |
| `onboarding` | Questionnaire | 6 étapes de préférences (première connexion uniquement) |
| `home` | Accueil | Landing page éditoriale avec hero, stats, ticker, activités |
| `explore` | Explorer | Grille d'événements avec filtres et cartes de détail |
| `map` | Carte | Carte Leaflet plein écran avec markers, filtres, recherche, panels |
| `assistant` | Nabda AI | Chatbot IA avec suggestions chips et interface conversationnelle |
| `profile` | Profil | Dashboard utilisateur avec badges, activités, stats |
| `event-detail` | Détail événement | Page détaillée d'un événement (hero, galerie, infos, mini-map) |
| `location-map` | Carte lieu | Vue carte centrée sur un lieu spécifique |

### Routing

```
navigate(pageId) :
  1. Si pas connecté → force 'auth'
  2. Si connecté mais onboarding incomplet → force 'onboarding'
  3. Sinon → affiche la page demandée
  4. Cache toutes les autres pages (.page { display:none })
  5. Met à jour la navbar (active link, scroll behavior)
```

---

## 4. Flow utilisateur

```
┌─────────────┐     ┌──────────────────┐     ┌──────────┐
│  AUTH        │────▸│  ONBOARDING      │────▸│  HOME    │
│  (login/    │     │  (1ère fois)      │     │          │
│   signup)   │     │                  │     │          │
└─────────────┘     │  Étape 1: Langue │     └────┬─────┘
                    │  Étape 2: Wilaya │          │
                    │  Étape 3: Âge    │     ┌────▼─────┐
                    │  Étape 4: Intérêts│    │ EXPLORE  │
                    │  Étape 5: Dispo  │     │ MAP      │
                    │  Étape 6: Objectif│    │ ASSISTANT│
                    │  → Carte DNA     │     │ PROFILE  │
                    └──────────────────┘     └──────────┘
```

### Vérification onboarding

La fonction `isOnboardingDone()` vérifie `localStorage.nabda_profile.onboardingComplete === true`. Tant que ce flag n'est pas `true`, l'utilisateur est bloqué sur la page onboarding, même s'il essaie de naviguer ailleurs.

---

## 5. Supabase — Base de données

### Connexion

- **URL** : `https://erupgynmbgjnpqyzpwcz.supabase.co`
- **Clé anon** (frontend) : JWT avec `role: "anon"` — respecte les politiques RLS
- **Client** : `@supabase/supabase-js` v2 (CDN), initialisé dans `<head>` comme variable globale `_sb`

### Tables

#### `events`
Événements/activités disponibles sur la plateforme.

| Colonne | Type | Description |
|---|---|---|
| `id` | uuid (PK) | Identifiant unique |
| `title` | text | Titre de l'événement |
| `description` | text | Description détaillée |
| `category` | text | Catégorie : `sport`, `cultural`, `workshop`, `volunteer`, `program`, `event`, `tech`, `health` |
| `start_date` | timestamptz | Date/heure de début |
| `end_date` | timestamptz | Date/heure de fin |
| `max_participants` | integer | Nombre max de places |
| `current_participants` | integer | Places prises |
| `is_active` | boolean | Événement actif ou archivé |
| `lat` | double precision | Latitude GPS |
| `lng` | double precision | Longitude GPS |
| `wilaya` | text | Nom de la wilaya (ex: "Alger", "Oran") |
| `center` | text | Nom du lieu/centre (ex: "ODEJ Alger Centre") |
| `dna_reward` | integer | Points DNA gagnés en participant |
| `is_free` | boolean | Gratuit ou payant |
| `image_url` | text | URL image (optionnel) |
| `organizer_id` | uuid (nullable) | FK vers organizers |

#### `user_profiles`
Profil utilisateur avec préférences et poids de recommandation.

| Colonne | Type | Description |
|---|---|---|
| `id` | uuid (PK) | FK vers `auth.users(id)` |
| `display_name` | text | Nom affiché |
| `lang` | text | Langue : `fr`, `ar`, `tz` |
| `wilaya` | text | Wilaya de résidence |
| `age_range` | text | Tranche d'âge |
| `interests` | text[] | Tableau de catégories d'intérêt |
| `availability` | text | `weekend`, `evening`, `fulltime`, `flexible` |
| `goal` | text | `apprendre`, `benevolat`, `competition`, `social` |
| `dna_points` | integer | Total de points DNA |
| `onboarding_done` | boolean | Onboarding complété |
| `pref_sport` | real (0-1) | Poids de préférence sport |
| `pref_cultural` | real (0-1) | Poids de préférence culture |
| `pref_workshop` | real (0-1) | Poids de préférence ateliers |
| `pref_volunteer` | real (0-1) | Poids de préférence bénévolat |
| `pref_program` | real (0-1) | Poids de préférence formations |
| `pref_event` | real (0-1) | Poids de préférence événements |
| `pref_tech` | real (0-1) | Poids de préférence tech |
| `pref_health` | real (0-1) | Poids de préférence santé |
| `part_sport` ... `part_health` | integer | Compteurs de participation par catégorie |
| `total_participations` | integer | Total participations |

#### `event_participants`
Table de jointure utilisateur ↔ événement.

| Colonne | Type |
|---|---|
| `event_id` | uuid (FK events) |
| `user_id` | uuid (FK auth.users) |
| `created_at` | timestamptz |

#### `event_comments`
Commentaires sur les événements.

| Colonne | Type |
|---|---|
| `id` | uuid (PK) |
| `event_id` | uuid (FK events) |
| `user_id` | uuid (FK auth.users) |
| `content` | text |
| `created_at` / `updated_at` | timestamptz |

#### `event_tags` / `event_tag_relations`
Système de tags pour catégoriser les événements.

#### `organizers`
Organisateurs d'événements (liés à auth.users).

#### `user_roles`
Rôles utilisateurs (admin, organizer, user).

### Politiques RLS

| Table | SELECT | INSERT | UPDATE |
|---|---|---|---|
| `events` | Tout le monde | Authenticated | — |
| `user_profiles` | Son propre profil | Son propre profil | Son propre profil |
| `event_participants` | Tout le monde | `auth.uid() = user_id` | — |
| `event_comments` | Tout le monde | `auth.uid() = user_id` | — |
| `event_tags` | Tout le monde | — | — |

---

## 6. Système de recommandation adaptative

### Principe

Le système combine **préférences déclarées** (onboarding) et **comportement réel** (participations) pour personnaliser l'affichage des événements.

### Initialisation (onboarding)

Quand l'utilisateur choisit ses intérêts (ex: sport + tech), les poids sont initialisés :
```
pref_sport = 1/2 = 0.5
pref_tech  = 1/2 = 0.5
tous les autres = 0
```

### Mise à jour automatique (trigger SQL)

Quand l'utilisateur rejoint un événement sport :
1. Le trigger `on_event_participation` se déclenche
2. `part_sport` est incrémenté, `total_participations` aussi
3. **Tous** les poids sont recalculés :

```
pref_X = (part_X + bonus_onboarding) / (total + 0.3 * nb_intérêts)
```

- `bonus_onboarding` = 0.3 × total SI la catégorie est dans les intérêts déclarés, sinon 0
- Les intérêts déclarés gardent un **bonus de 30%**, mais le comportement réel **domine progressivement**

### Tri côté client

```javascript
sortEventsByPreference(events) :
  - Récupère userPrefs depuis user_profiles
  - Trie par pref_X descendant (catégorie de l'event)
  - Bonus +0.5 pour les events de la même wilaya
```

### Tri côté serveur (disponible)

```sql
get_recommended_events(user_id, limit) :
  - JOIN events + user_profiles
  - ORDER BY pref correspondant DESC, proximité wilaya, date ASC
```

---

## 7. Système DNA (Digital Nabda Achievement)

Les **DNA tokens** sont un système de gamification/récompense :

- Chaque événement donne des points DNA (50-600 selon le type)
- L'onboarding donne des DNA de base (calculés selon nb d'intérêts)
- Un **widget flottant** en bas à droite affiche le solde en temps réel
  - Cercle collapsed au repos avec animation glow
  - Expand en pill au hover (max-width animation GPU-friendly)
  - Click → carte détaillée avec solde, gains du jour, ventilation par source

---

## 8. Authentification

### Email/Password
- Signup : `_sb.auth.signUp({ email, password, options: { data: { display_name } } })`
- Login : `_sb.auth.signInWithPassword({ email, password })`
- Forgot : `_sb.auth.resetPasswordForEmail(email)`
- Logout : `_sb.auth.signOut()`

### Social (Google/Apple)
- `_sb.auth.signInWithOAuth({ provider, options: { redirectTo } })`
- Nécessite activation dans Supabase Dashboard → Authentication → Providers

### Session
- `onAuthStateChange` écoute les changements d'état
- `checkSession()` restaure la session au chargement
- `localStorage` stocke : `nabda_logged_in`, `nabda_user_id`, `nabda_user_email`, `nabda_profile`

---

## 9. Pages — Détails fonctionnels

### Home (Accueil)
- Hero éditorial avec titre Bebas Neue
- Stats animées (120+ activités, 48 wilayas, 15K+ jeunes, 0.03g CO2/page)
- Ticker horizontal défilant
- Cartes d'événements vedettes
- CTA "Découvrir les activités" (animation gap hover)
- Section "Votre Pulse" avec stats personnalisées

### Explore (Explorer)
- Grille d'événements avec images, badges catégorie, prix, DNA
- 6 événements détaillés avec galeries, conseils, organisateurs
- Boutons d'inscription et de navigation vers la carte
- `EVENTS_DETAIL[]` — tableau hardcodé (6 events avec images, galeries, tips)

### Map (Carte)
- Leaflet.js plein écran avec tiles CartoDB DarkMatter
- 20 marqueurs avec clustering
- Barre de recherche flottante (ville, catégorie, événement)
- Filtres par catégorie (pills colorées)
- Panel de résultats (slide-in droite)
- Panel de détail événement (slide-in droite)
- Bouton "Près de moi" (géolocalisation)
- Badge éco (tracking CO2 de la carte)
- `MAP_EVENTS[]` — fetch Supabase avec fallback hardcodé (20 events)

### Assistant (Nabda AI)
- Interface chatbot style Gemini
- Welcome state avec logo, titre éditorial, 4 chips de suggestion
- Messages user (bulles vertes) / bot (bulles sombres avec avatar)
- Indicateur de streaming (3 dots bouncing)
- Input pill avec textarea auto-resize + bouton send circulaire
- Réponses simulées (pas de vrai LLM connecté)

### Profile
- Avatar avec initiales
- Badges et milestones
- Activités enregistrées
- Stats DNA
- Paramètres

### Onboarding
- 6 étapes séquentielles avec animations slide
- Barre de progression
- Sélection de wilaya parmi les 48 (grille filtrable)
- Sélection d'intérêts (toggle multi-sélection, couleurs par catégorie)
- Carte DNA finale avec compteur animé
- Sauvegarde : `localStorage` + Supabase `user_profiles`

---

## 10. Navbar

### Structure
Grille 3 colonnes : Logo | Liens nav | Contrôles droite

| Zone | Contenu |
|---|---|
| Gauche | Logo NABDA (Bebas Neue) + sparkle |
| Centre | Accueil, Explorer, Carte, Nabda AI (dot animé) |
| Droite | Lang dropdown (FR/AR/TZ), Theme toggle, Notifications, Avatar |

### Comportement scroll
- **Top de page (home)** : fond solide `#0a0f0a`, pas de bordure
- **Scroll > 40px ou autre page** : fond frosted glass `rgba(10,15,10,0.94)` + backdrop-blur + bordure verte + shadow

### Visibilité
- **Cachée** sur les pages `auth` et `onboarding`
- **Visible** sur toutes les autres pages

---

## 11. Theming

### Dark mode (défaut)
- Background : `#0a0f0a` / `#10150f`
- Surface : `#111a11` / `#1c211b`
- Borders : `#1f2f1f`
- Primary : `#4be277` (vert Nabda)
- Text : `#f0fdf4` / `#dfe4db` / `#bccbb9` / `#86efac`
- Accent : `#ffb95f` (orange DNA)

### Light mode
- Background : `#f0fdf4`
- Surface : `#ffffff`
- Inversions via `html.light` CSS classes
- Toggle via `toggleTheme()` + `localStorage.nabda_theme`

---

## 12. Internationalisation

3 langues supportées :
- **FR** — Français (défaut)
- **AR** — العربية (Arabe)
- **TZ** — Tamazight

Le switcher est un dropdown dans la navbar. `setLang(lang)` met à jour le label et stocke la préférence. L'interface reste majoritairement en français dans l'implémentation actuelle.

---

## 13. Catégories d'événements

| Clé | Label | Couleur |
|---|---|---|
| `sport` | Sport | `#8b5cf6` (violet) |
| `cultural` | Culture | `#06b6d4` (cyan) |
| `workshop` | Ateliers | `#f59e0b` (ambre) |
| `volunteer` | Bénévolat | `#ec4899` (rose) |
| `program` | Formation | `#f97316` (orange) |
| `event` | Événement | `#22c55e` (vert) |
| `tech` | Tech | `#4be277` (vert clair) |
| `health` | Santé | `#f43f5e` (rouge) |

---

## 14. Fichiers du projet

```
ecohack/
├── design_final/
│   └── index.html          # SPA monofichier (~280KB)
├── .claude/
│   └── launch.json          # Config serveur preview (port 5500)
├── rebuild_assistant.py      # Script rebuild page assistant
├── rebuild_onboarding.py     # Script rebuild page onboarding
├── fix_map_page.py           # Script rebuild page carte
├── dna_widget.py             # Script widget DNA flottant
├── integrate_supabase.py     # Script intégration Supabase
├── fix_dna_smooth.py         # Script animations DNA smooth
├── add_prefs.py              # Script système préférences
└── NABDA_CONTEXT.md          # Ce fichier
```

---

## 15. Fonctions JavaScript clés

### Auth
| Fonction | Rôle |
|---|---|
| `handleAuthSubmit(e)` | Login/signup via Supabase Auth |
| `handleSocialAuth(provider)` | OAuth Google/Apple |
| `handleForgotPassword()` | Reset password email |
| `logout()` | Déconnexion + nettoyage localStorage |
| `showAuthMessage(msg, type)` | Toast notification (success/error) |
| `isOnboardingDone()` | Vérifie `onboardingComplete === true` |

### Navigation
| Fonction | Rôle |
|---|---|
| `navigate(pageId)` | Routing SPA avec guards auth/onboarding |
| `updateNav(activeId)` | Met à jour le lien actif dans la navbar |
| `setLang(lang)` | Change la langue + dropdown |
| `toggleTheme()` | Dark/light mode |

### Carte
| Fonction | Rôle |
|---|---|
| `initNabdaMap()` | Initialise Leaflet + tiles + clusters |
| `renderMapMarkers()` | Affiche les markers (triés par préférence) |
| `mapSelectEvent(id)` | Sélectionne un event → fly to + panel détail |
| `mapSearch(val)` | Recherche textuelle sur les events |
| `mapFilterCat(cat)` | Filtre par catégorie |
| `mapNearMe()` | Géolocalisation + fly to position |
| `getFilteredMapEvents()` | Retourne les events filtrés |

### Données
| Fonction | Rôle |
|---|---|
| `loadEventsFromSupabase()` | Fetch events depuis Supabase (fallback hardcodé) |
| `joinEvent(eventId)` | Inscription à un événement |
| `addEventComment(eventId, content)` | Ajouter un commentaire |
| `loadUserPreferences()` | Charge le profil user depuis Supabase |
| `sortEventsByPreference(events)` | Trie par poids préférence + wilaya |

### Onboarding
| Fonction | Rôle |
|---|---|
| `obGoToStep(n)` | Navigation entre étapes (animation slide) |
| `obSelectLang/Wilaya/Age/Avail/Goal()` | Sélection à chaque étape |
| `obToggleInterest(btn)` | Toggle un intérêt (multi-sélection) |
| `obShowDNACard()` | Carte finale + calcul DNA + sauvegarde Supabase |

### DNA Widget
| Fonction | Rôle |
|---|---|
| `toggleDnaCard()` | Ouvre/ferme la carte DNA flottante |
| `closeDnaCard()` | Ferme la carte |

---

## 16. Données seed (20 événements)

Les 20 événements couvrent 12 wilayas d'Algérie :
- **Alger** (4) : Football, Handball, Leadership, Cinéma
- **Oran** (2) : Solaire DIY, Photo
- **Constantine** (2) : Hackathon, Malouf
- **Tipaza** (2) : Nettoyage plage, Yoga
- **Tizi Ouzou** (2) : Festival Amazigh, Expo arts
- **Sétif** (2) : Marathon, Échecs
- **Blida** (1) : Reboisement Chréa
- **Annaba** (1) : Poterie
- **Béjaïa** (1) : Bénévolat
- **Biskra** (1) : Entrepreneuriat
- **Ghardaïa** (1) : Camp Sahara
- **Tamanrasset** (1) : Éco-conscience

Catégories : sport(4), cultural(5), workshop(2), volunteer(4), program(3), event(2)

---

## 17. Points de vigilance / Limites actuelles

1. **EVENTS_DETAIL** (page Explorer) est un tableau hardcodé de 6 événements avec images et galeries — il n'est PAS encore connecté à Supabase
2. **Nabda AI** retourne des réponses simulées — pas de vrai LLM connecté
3. **Les IDs** Supabase sont des UUID, tandis que certains event handlers utilisent des IDs numériques (1-6) pour EVENTS_DETAIL
4. **Pas de stockage Supabase** pour les images/galeries des événements (juste des URLs Google)
5. **Le social auth** (Google/Apple) nécessite une configuration dans le dashboard Supabase
6. **Pas de notification push** — le bouton notifications est présent mais statique
7. **L'internationalisation** n'est pas complète — l'interface est majoritairement en français
8. **Pas de mode mobile responsive** — optimisé desktop principalement

---

## 18. Variables d'environnement / Config

```javascript
SUPABASE_URL  = 'https://erupgynmbgjnpqyzpwcz.supabase.co'
SUPABASE_ANON = '<JWT anon key>' // role: "anon" — safe côté client
```

**localStorage keys** :
- `nabda_logged_in` — "true" si connecté
- `nabda_user_id` — UUID Supabase user
- `nabda_user_email` — Email user
- `nabda_profile` — JSON complet du profil onboarding (doit contenir `onboardingComplete: true`)
- `nabda_theme` — "light" ou absent (dark par défaut)
