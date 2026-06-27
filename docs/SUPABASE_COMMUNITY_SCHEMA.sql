-- ============================================================================
-- Garajım — Topluluk Supabase Database Schema
-- ============================================================================
-- Bu dosya uygulamanın ihtiyaç duyduğu tüm tabloları, indexleri,
-- Row Level Security (RLS) politikalarını ve trigger fonksiyonlarını içerir.
--
-- Kullanım: Supabase Dashboard → SQL Editor → bu dosyayı yapıştır → Run
-- ============================================================================

-- UUID extension'ını aktif et
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. TABLOLAR
-- ============================================================================

-- 1.1 Kullanıcı Profilleri
-- Not: id = auth.users.id (Sign in with Apple ile oluşan Supabase auth user)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL
    CHECK (char_length(username) >= 3 AND char_length(username) <= 20),
  display_name TEXT
    CHECK (display_name IS NULL OR char_length(display_name) <= 50),
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user'
    CHECK (role IN ('user', 'moderator', 'admin')),
  is_verified BOOLEAN NOT NULL DEFAULT false,
  is_banned BOOLEAN NOT NULL DEFAULT false,
  is_pro BOOLEAN NOT NULL DEFAULT false,
  default_vehicle_brand TEXT,
  default_vehicle_model TEXT,
  default_vehicle_year INTEGER,
  show_vehicle_on_posts BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 1.2 Topluluk Gönderileri
CREATE TABLE IF NOT EXISTS community_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL
    CHECK (char_length(title) >= 5 AND char_length(title) <= 120),
  body TEXT NOT NULL
    CHECK (char_length(body) >= 20 AND char_length(body) <= 5000),
  post_type TEXT NOT NULL
    CHECK (post_type IN ('news', 'announcement', 'advice', 'problem', 'experience', 'question')),
  tags TEXT[] NOT NULL DEFAULT '{}',
  vehicle_brand TEXT,
  vehicle_model TEXT,
  vehicle_year INTEGER,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  is_hidden BOOLEAN NOT NULL DEFAULT false,
  like_count INTEGER NOT NULL DEFAULT 0,
  comment_count INTEGER NOT NULL DEFAULT 0,
  save_count INTEGER NOT NULL DEFAULT 0,
  -- Soft delete
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES profiles(id),
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 1.3 Yorumlar
CREATE TABLE IF NOT EXISTS community_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL
    CHECK (char_length(body) >= 1 AND char_length(body) <= 2000),
  is_hidden BOOLEAN NOT NULL DEFAULT false,
  -- Soft delete
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES profiles(id),
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 1.4 Beğeniler (Post)
CREATE TABLE IF NOT EXISTS community_post_likes (
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

-- 1.5 Kaydedilenler (Post)
CREATE TABLE IF NOT EXISTS community_post_saves (
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

-- 1.6 Şikayet / Bildirim
CREATE TABLE IF NOT EXISTS community_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL
    CHECK (target_type IN ('post', 'comment')),
  target_id UUID NOT NULL,
  reason TEXT NOT NULL
    CHECK (reason IN ('spam', 'harassment', 'misleading', 'personal_info', 'inappropriate', 'other')),
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'reviewed', 'dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  reviewer_id UUID REFERENCES profiles(id)
);

-- 1.7 Engellemeler
CREATE TABLE IF NOT EXISTS community_blocks (
  blocker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

-- ============================================================================
-- 2. INDEXLER
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_posts_author ON community_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_type ON community_posts(post_type);
CREATE INDEX IF NOT EXISTS idx_posts_created ON community_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_pinned ON community_posts(is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_visible ON community_posts(is_hidden, deleted_at)
  WHERE is_hidden = false AND deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_comments_post ON community_comments(post_id, created_at);
CREATE INDEX IF NOT EXISTS idx_reports_status ON community_reports(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_blocks_blocker ON community_blocks(blocker_id);

-- ============================================================================
-- 3. TRIGGER — updated_at otomatik güncelleme
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_posts_updated_at
  BEFORE UPDATE ON community_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_comments_updated_at
  BEFORE UPDATE ON community_comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_post_saves ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_blocks ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------------------------------------
-- 4.1 PROFILES
-- --------------------------------------------------------------------------

-- Herkes tüm profilleri okuyabilir
CREATE POLICY "Profiles_are_public" ON profiles
  FOR SELECT USING (true);

-- Kullanıcı kendi profilini oluşturabilir (banned bile olsa — ilk profil)
CREATE POLICY "Users_can_insert_own_profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Kullanıcı kendi profilini güncelleyebilir (banned değilse)
CREATE POLICY "Users_can_update_own_profile" ON profiles
  FOR UPDATE USING (
    auth.uid() = id
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

-- --------------------------------------------------------------------------
-- 4.2 COMMUNITY POSTS — SELECT
-- --------------------------------------------------------------------------

-- Herkes silinmemiş ve gizli olmayan gönderileri görebilir
-- Admin/mod moderator gizli gönderileri de görebilir
CREATE POLICY "Visible_non_deleted_posts" ON community_posts
  FOR SELECT USING (
    deleted_at IS NULL
    AND (
      is_hidden = false
      OR auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
    )
  );

-- --------------------------------------------------------------------------
-- 4.3 COMMUNITY POSTS — INSERT
-- Kural: auth.uid() mevcut, is_banned = false,
--        (is_pro = true VEYA role IN ('admin','moderator')),
--        VE author_id = auth.uid() (başkası adına post atılamaz)
-- --------------------------------------------------------------------------

CREATE POLICY "Pro_or_admin_can_create_posts" ON community_posts
  FOR INSERT WITH CHECK (
    author_id = auth.uid()
    AND auth.uid() IN (
      SELECT id FROM profiles
      WHERE is_banned = false
      AND (is_pro = true OR role IN ('admin', 'moderator'))
    )
  );

-- --------------------------------------------------------------------------
-- 4.4 COMMUNITY POSTS — UPDATE
-- Yazar: kendi silinmemiş postunu güncelleyebilir (banned değilse)
-- Admin/moderator: tüm postları güncelleyebilir (hide, pin, soft-delete)
-- --------------------------------------------------------------------------

CREATE POLICY "Author_can_update_own_post" ON community_posts
  FOR UPDATE USING (
    auth.uid() = author_id
    AND deleted_at IS NULL
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Admin_can_update_any_post" ON community_posts
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- --------------------------------------------------------------------------
-- 4.5 COMMUNITY POSTS — DELETE (Hard delete — sadece admin/moderator)
-- --------------------------------------------------------------------------

CREATE POLICY "Admin_can_hard_delete_posts" ON community_posts
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- --------------------------------------------------------------------------
-- 4.6 COMMUNITY COMMENTS — SELECT
-- --------------------------------------------------------------------------

CREATE POLICY "Visible_non_deleted_comments" ON community_comments
  FOR SELECT USING (
    deleted_at IS NULL
    AND (
      is_hidden = false
      OR auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
    )
  );

-- --------------------------------------------------------------------------
-- 4.7 COMMUNITY COMMENTS — INSERT
-- Kural: auth.uid() mevcut, is_banned = false,
--        (is_pro = true VEYA role IN ('admin','moderator'))
-- --------------------------------------------------------------------------

CREATE POLICY "Pro_or_admin_can_create_comments" ON community_comments
  FOR INSERT WITH CHECK (
    author_id = auth.uid()
    AND auth.uid() IN (
      SELECT id FROM profiles
      WHERE is_banned = false
      AND (is_pro = true OR role IN ('admin', 'moderator'))
    )
  );

-- --------------------------------------------------------------------------
-- 4.8 COMMUNITY COMMENTS — UPDATE
-- Yazar: kendi yorumunu güncelleyebilir (banned değilse)
-- Admin/moderator: tüm yorumları güncelleyebilir
-- --------------------------------------------------------------------------

CREATE POLICY "Author_can_update_own_comment" ON community_comments
  FOR UPDATE USING (
    auth.uid() = author_id
    AND deleted_at IS NULL
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Admin_can_update_any_comment" ON community_comments
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- --------------------------------------------------------------------------
-- 4.9 COMMUNITY COMMENTS — DELETE (Hard delete — sadece admin/moderator)
-- --------------------------------------------------------------------------

CREATE POLICY "Admin_can_hard_delete_comments" ON community_comments
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- --------------------------------------------------------------------------
-- 4.10 LIKES — banned kullanıcı beğenemez
-- --------------------------------------------------------------------------

CREATE POLICY "Likes_are_public" ON community_post_likes
  FOR SELECT USING (true);

CREATE POLICY "Users_can_like" ON community_post_likes
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Users_can_unlike" ON community_post_likes
  FOR DELETE USING (auth.uid() = user_id);

-- --------------------------------------------------------------------------
-- 4.11 SAVES — banned kullanıcı kaydedemez
-- --------------------------------------------------------------------------

CREATE POLICY "Saves_are_public" ON community_post_saves
  FOR SELECT USING (true);

CREATE POLICY "Users_can_save" ON community_post_saves
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Users_can_unsave" ON community_post_saves
  FOR DELETE USING (auth.uid() = user_id);

-- --------------------------------------------------------------------------
-- 4.12 REPORTS — banned kullanıcı bildirim yapamaz
-- --------------------------------------------------------------------------

CREATE POLICY "Users_can_create_reports" ON community_reports
  FOR INSERT WITH CHECK (
    auth.uid() = reporter_id
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Admins_can_view_reports" ON community_reports
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

CREATE POLICY "Admins_can_update_reports" ON community_reports
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- --------------------------------------------------------------------------
-- 4.13 BLOCKS — banned kullanıcı engelleme yapamaz
-- --------------------------------------------------------------------------

CREATE POLICY "Users_can_view_own_blocks" ON community_blocks
  FOR SELECT USING (
    auth.uid() = blocker_id
    OR auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

CREATE POLICY "Users_can_block" ON community_blocks
  FOR INSERT WITH CHECK (
    auth.uid() = blocker_id
    AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = false
    )
  );

CREATE POLICY "Users_can_unblock" ON community_blocks
  FOR DELETE USING (auth.uid() = blocker_id);

-- ============================================================================
-- TODO: Pro Entitlement Sync
-- ============================================================================
-- Şu an `profiles.is_pro` MANUEL olarak admin tarafından güncellenir:
--   UPDATE profiles SET is_pro = true WHERE id = '<user-id>';
--
-- Gelecekte: StoreKit 2 Transaction listener → Supabase Edge Function →
--   UPDATE profiles SET is_pro = true/false
-- Bu pipeline kurulana kadar Pro yetkisi manuel yönetilir. Bkz: ADMIN_SETUP.md
--
-- Server-side RLS policy yukarıda hazır — sync pipeline kurulduğunda
-- ek değişiklik gerekmez.
-- ============================================================================
