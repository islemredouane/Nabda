ALTER TABLE public.events ADD COLUMN IF NOT EXISTS lat double precision;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS lng double precision;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS wilaya text;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS center text;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS dna_reward integer DEFAULT 100;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS is_free boolean DEFAULT true;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS image_url text;

ALTER TABLE public.events ALTER COLUMN organizer_id DROP NOT NULL;

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  lang text DEFAULT 'fr',
  wilaya text,
  age_range text,
  interests text[] DEFAULT '{}',
  availability text DEFAULT 'flexible',
  goal text,
  dna_points integer DEFAULT 0,
  onboarding_done boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  pref_sport real DEFAULT 0.0,
  pref_cultural real DEFAULT 0.0,
  pref_workshop real DEFAULT 0.0,
  pref_volunteer real DEFAULT 0.0,
  pref_program real DEFAULT 0.0,
  pref_event real DEFAULT 0.0,
  pref_tech real DEFAULT 0.0,
  pref_health real DEFAULT 0.0,
  part_sport integer DEFAULT 0,
  part_cultural integer DEFAULT 0,
  part_workshop integer DEFAULT 0,
  part_volunteer integer DEFAULT 0,
  part_program integer DEFAULT 0,
  part_event integer DEFAULT 0,
  part_tech integer DEFAULT 0,
  part_health integer DEFAULT 0,
  total_participations integer DEFAULT 0
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_tag_relations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Events are viewable by everyone" ON public.events;
CREATE POLICY "Events are viewable by everyone" ON public.events FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can insert events" ON public.events;
CREATE POLICY "Authenticated can insert events" ON public.events FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users view own profile" ON public.user_profiles;
CREATE POLICY "Users view own profile" ON public.user_profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users insert own profile" ON public.user_profiles;
CREATE POLICY "Users insert own profile" ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users update own profile" ON public.user_profiles;
CREATE POLICY "Users update own profile" ON public.user_profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can join events" ON public.event_participants;
CREATE POLICY "Users can join events" ON public.event_participants FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Participation is viewable" ON public.event_participants;
CREATE POLICY "Participation is viewable" ON public.event_participants FOR SELECT USING (true);

DROP POLICY IF EXISTS "Comments are viewable" ON public.event_comments;
CREATE POLICY "Comments are viewable" ON public.event_comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can add comments" ON public.event_comments;
CREATE POLICY "Users can add comments" ON public.event_comments FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Tags are viewable" ON public.event_tags;
CREATE POLICY "Tags are viewable" ON public.event_tags FOR SELECT USING (true);

DROP POLICY IF EXISTS "Tag relations viewable" ON public.event_tag_relations;
CREATE POLICY "Tag relations viewable" ON public.event_tag_relations FOR SELECT USING (true);

CREATE OR REPLACE FUNCTION public.update_user_preferences()
RETURNS TRIGGER AS $$
DECLARE
  event_cat text;
  col_part text;
  total_val integer;
  int_count integer;
BEGIN
  SELECT category INTO event_cat FROM public.events WHERE id = NEW.event_id;
  IF event_cat IS NULL THEN RETURN NEW; END IF;
  col_part := 'part_' || event_cat;
  EXECUTE format('UPDATE public.user_profiles SET %I = %I + 1, total_participations = total_participations + 1, updated_at = now() WHERE id = $1', col_part, col_part) USING NEW.user_id;
  SELECT total_participations, COALESCE(array_length(interests, 1), 1) INTO total_val, int_count FROM public.user_profiles WHERE id = NEW.user_id;
  IF total_val > 0 THEN
    UPDATE public.user_profiles SET
      pref_sport = (part_sport + CASE WHEN 'sport' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_cultural = (part_cultural + CASE WHEN 'cultural' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_workshop = (part_workshop + CASE WHEN 'workshop' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_volunteer = (part_volunteer + CASE WHEN 'volunteer' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_program = (part_program + CASE WHEN 'program' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_event = (part_event + CASE WHEN 'event' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_tech = (part_tech + CASE WHEN 'tech' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      pref_health = (part_health + CASE WHEN 'health' = ANY(interests) THEN 0.3 * total_val ELSE 0 END) / (total_val + 0.3 * int_count),
      updated_at = now()
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_event_participation ON public.event_participants;
CREATE TRIGGER on_event_participation AFTER INSERT ON public.event_participants FOR EACH ROW EXECUTE FUNCTION public.update_user_preferences();

CREATE OR REPLACE FUNCTION public.get_recommended_events(p_user_id uuid, p_limit integer DEFAULT 20)
RETURNS SETOF public.events AS $$
  SELECT e.*
  FROM public.events e
  LEFT JOIN public.user_profiles u ON u.id = p_user_id
  WHERE e.is_active = true
  ORDER BY
    CASE e.category
      WHEN 'sport' THEN COALESCE(u.pref_sport, 0)
      WHEN 'cultural' THEN COALESCE(u.pref_cultural, 0)
      WHEN 'workshop' THEN COALESCE(u.pref_workshop, 0)
      WHEN 'volunteer' THEN COALESCE(u.pref_volunteer, 0)
      WHEN 'program' THEN COALESCE(u.pref_program, 0)
      WHEN 'event' THEN COALESCE(u.pref_event, 0)
      WHEN 'tech' THEN COALESCE(u.pref_tech, 0)
      WHEN 'health' THEN COALESCE(u.pref_health, 0)
      ELSE 0
    END DESC,
    CASE WHEN e.wilaya = u.wilaya THEN 0 ELSE 1 END,
    e.start_date ASC
  LIMIT p_limit;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

DELETE FROM public.events WHERE organizer_id IS NULL;

INSERT INTO public.events (title, description, category, start_date, end_date, max_participants, current_participants, is_active, lat, lng, wilaya, center, dna_reward, is_free) VALUES
('Tournoi de Football Jeunesse', 'Competition de football inter-wilayas pour les 16-25 ans.', 'sport', '2026-06-15 09:00+01', '2026-06-15 18:00+01', 22, 0, true, 36.7538, 3.0588, 'Alger', 'ODEJ Alger Centre', 150, true),
('Atelier Solaire DIY', 'Construisez un panneau solaire de 50W avec des materiaux recycles.', 'workshop', '2026-06-18 10:00+01', '2026-06-18 17:00+01', 15, 0, true, 35.6969, -0.6331, 'Oran', 'ODEJ Oran', 200, true),
('Nettoyage des Plages de Tipaza', 'Operation de nettoyage de la plage de Tipaza.', 'volunteer', '2026-06-20 08:00+01', '2026-06-20 14:00+01', 45, 0, true, 36.5894, 2.4476, 'Tipaza', 'ODEJ Tipaza', 180, true),
('Festival Culturel Amazigh', 'Celebration de la culture amazighe.', 'cultural', '2026-06-22 10:00+01', '2026-06-22 22:00+01', 200, 0, true, 36.7169, 4.0497, 'Tizi Ouzou', 'Maison de Culture TO', 80, true),
('Hackathon Eco-Tech 48h', '48h pour concevoir une solution numerique eco-responsable.', 'workshop', '2026-06-25 09:00+01', '2026-06-27 18:00+01', 30, 0, true, 36.3650, 6.6147, 'Constantine', 'ODEJ Constantine', 500, false),
('Marathon Vert de Setif', '10km a travers les parcs verts de Setif.', 'sport', '2026-06-28 07:00+01', '2026-06-28 12:00+01', 150, 0, true, 36.1898, 5.4108, 'Setif', 'Stade du 8 Mai', 250, false),
('Cours de Poterie Traditionnelle', 'Initiation a la poterie avec un maitre artisan.', 'cultural', '2026-06-30 14:00+01', '2026-06-30 18:00+01', 12, 0, true, 36.9000, 7.7667, 'Annaba', 'Centre Culturel Annaba', 120, true),
('Reboisement Foret du Chrea', 'Plantation de 1000 cedres en partenariat avec la DGF.', 'volunteer', '2026-07-05 08:00+01', '2026-07-05 16:00+01', 60, 0, true, 36.4700, 2.8300, 'Blida', 'Foret du Chrea', 300, true),
('Programme Leadership National', 'Formation intensive sur 5 jours en leadership.', 'program', '2026-07-08 09:00+01', '2026-07-12 17:00+01', 25, 0, true, 36.7638, 3.0988, 'Alger', 'ODEJ Ben Aknoun', 600, false),
('Journee Benevolat Bejaia', 'Actions solidaires dans 5 quartiers de Bejaia.', 'volunteer', '2026-07-10 08:00+01', '2026-07-10 17:00+01', 80, 0, true, 36.7515, 5.0560, 'Bejaia', 'ODEJ Bejaia', 200, true),
('Atelier Photo et Environnement', 'Photographier la nature et environnement urbain.', 'cultural', '2026-07-12 09:00+01', '2026-07-12 17:00+01', 20, 0, true, 35.6669, -0.5831, 'Oran', 'Centre Jeunesse Oran', 100, true),
('Tournoi Handball Inter-Wilayas', 'Championnat de handball jeunes U21.', 'sport', '2026-07-15 09:00+01', '2026-07-15 18:00+01', 40, 0, true, 36.8050, 3.0788, 'Alger', 'ODEJ Bab Ezzouar', 150, true),
('Formation Entrepreneuriat', '4 jours de formation business plan et financement.', 'program', '2026-07-18 09:00+01', '2026-07-21 17:00+01', 30, 0, true, 34.8500, 5.7333, 'Biskra', 'ODEJ Biskra', 400, false),
('Camp Decouverte Sahara', '7 jours exploration du desert.', 'event', '2026-07-20 06:00+01', '2026-07-26 20:00+01', 50, 0, true, 32.4800, 3.6700, 'Ghardaia', 'ODEJ Ghardaia', 350, false),
('Musique Malouf Constantinois', 'Initiation au malouf avec des musiciens.', 'cultural', '2026-07-22 16:00+01', '2026-07-22 20:00+01', 25, 0, true, 36.3850, 6.6547, 'Constantine', 'Institut Culturel Cst', 90, true),
('Yoga et Meditation Tipaza', 'Seance de yoga face aux ruines romaines.', 'sport', '2026-07-25 07:00+01', '2026-07-25 09:00+01', 30, 0, true, 36.5994, 2.4876, 'Tipaza', 'Parc Archeologique', 60, true),
('Eco-Conscience Tamanrasset', 'Sensibilisation au Hoggar.', 'volunteer', '2026-07-28 09:00+01', '2026-07-28 17:00+01', 40, 0, true, 22.7851, 5.5228, 'Tamanrasset', 'ODEJ Tamanrasset', 280, true),
('Exposition Arts Plastiques', 'Exposition artistes algeriens emergents.', 'cultural', '2026-07-30 10:00+01', '2026-07-30 20:00+01', 100, 0, true, 36.7269, 4.0897, 'Tizi Ouzou', 'Galerie des Arts TO', 70, true),
('Stage Cinema Jeunesse', '10 jours de cinema realisation et montage.', 'program', '2026-08-02 09:00+01', '2026-08-11 17:00+01', 15, 0, true, 36.7438, 3.0488, 'Alger', 'Cine-Club Alger', 450, false),
('Championnat National Echecs', 'Tournoi open tous niveaux format suisse 9 rondes.', 'event', '2026-08-05 09:00+01', '2026-08-07 18:00+01', 64, 0, true, 36.1698, 5.4008, 'Setif', 'ODEJ Setif', 120, true);
