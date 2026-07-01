-- ============================================================================
-- Garajım — Supabase Community Moderation V2 Migration
-- ============================================================================
-- Tarih: 1 Temmuz 2026
--
-- KULLANIM:
--   1. Supabase Dashboard → SQL Editor
--   2. Bu dosyanın TAMAMINI yapıştır
--   3. "Run" butonuna tıkla
--
-- Bu SQL idempotent'tir — tekrar tekrar çalıştırılabilir.
-- Mevcut tablo/policy'leri bozmaz, eksikleri ekler.
-- ============================================================================

-- ============================================================================
-- BÖLÜM 1: community_posts tablosuna moderasyon kolonları ekle
-- ============================================================================

ALTER TABLE community_posts
  ADD COLUMN IF NOT EXISTS pinned_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS pinned_by UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS hidden_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS hidden_by UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS moderation_status TEXT NOT NULL DEFAULT 'published';

-- moderation_status CHECK constraint (idempotent: önce drop, sonra add)
DO $$
BEGIN
  ALTER TABLE community_posts DROP CONSTRAINT IF EXISTS community_posts_moderation_status_check;
  ALTER TABLE community_posts
    ADD CONSTRAINT community_posts_moderation_status_check
    CHECK (moderation_status IN ('published', 'flagged', 'hidden'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Index for moderation queries
CREATE INDEX IF NOT EXISTS idx_posts_pinned ON community_posts(pinned_at DESC) WHERE is_pinned = true;
CREATE INDEX IF NOT EXISTS idx_posts_hidden ON community_posts(hidden_at DESC) WHERE is_hidden = true;
CREATE INDEX IF NOT EXISTS idx_posts_mod_status ON community_posts(moderation_status);

-- ============================================================================
-- BÖLÜM 2: community_reports.reason CHECK constraint düzeltmesi
-- ============================================================================
-- Swift ReportReason.personalInfo rawValue = "personal_info" (snake_case)
-- Mevcut DB'de "personalInfo" (camelCase) — uyuşmazlık hataya yol açar.
-- Önce mevcut veriyi migrate et, sonra constraint'i güncelle.

UPDATE community_reports SET reason = 'personal_info' WHERE reason = 'personalInfo';

ALTER TABLE community_reports DROP CONSTRAINT IF EXISTS community_reports_reason_check;
ALTER TABLE community_reports
  ADD CONSTRAINT community_reports_reason_check
  CHECK (reason IN ('spam', 'harassment', 'misleading', 'personal_info', 'inappropriate', 'other'));

-- ============================================================================
-- BÖLÜM 3: community_moderation_actions (moderasyon log tablosu)
-- ============================================================================

CREATE TABLE IF NOT EXISTS community_moderation_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID NOT NULL REFERENCES profiles(id),
  action TEXT NOT NULL
    CHECK (action IN (
      'post_pinned', 'post_unpinned',
      'post_hidden', 'post_unhidden',
      'post_deleted', 'post_restored',
      'comment_hidden', 'comment_unhidden',
      'comment_deleted',
      'user_banned', 'user_unbanned',
      'report_reviewed', 'report_dismissed'
    )),
  target_type TEXT
    CHECK (target_type IS NULL OR target_type IN ('post', 'comment', 'user')),
  target_id UUID,
  post_id UUID REFERENCES community_posts(id) ON DELETE SET NULL,
  comment_id UUID REFERENCES community_comments(id) ON DELETE SET NULL,
  reason TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for querying moderation actions
CREATE INDEX IF NOT EXISTS idx_mod_actions_actor ON community_moderation_actions(actor_id);
CREATE INDEX IF NOT EXISTS idx_mod_actions_created ON community_moderation_actions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mod_actions_post ON community_moderation_actions(post_id) WHERE post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mod_actions_comment ON community_moderation_actions(comment_id) WHERE comment_id IS NOT NULL;

-- Enable RLS on the new table
ALTER TABLE community_moderation_actions ENABLE ROW LEVEL SECURITY;

-- RLS: Only admins/moderators can read moderation actions
DROP POLICY IF EXISTS "Mods_can_read_actions" ON community_moderation_actions;
CREATE POLICY "Mods_can_read_actions" ON community_moderation_actions
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- RLS: Only admins/moderators can insert directly (RPC functions bypass this via SECURITY DEFINER)
DROP POLICY IF EXISTS "Mods_can_insert_actions" ON community_moderation_actions;
CREATE POLICY "Mods_can_insert_actions" ON community_moderation_actions
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'moderator'))
  );

-- ============================================================================
-- BÖLÜM 4: RPC Fonksiyonları (Stored Procedures)
-- ============================================================================
-- Tüm fonksiyonlar SECURITY DEFINER ile çalışır (RLS'i bypass eder)
-- ve çağıran kullanıcının admin/moderator olduğunu sunucu tarafında kontrol eder.

-- ----------------------------------------------------------------------------
-- 4.1: pin_community_post — Post'u sabitle ve log'a kaydet
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pin_community_post(post_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role TEXT;
BEGIN
  -- Yetki kontrolü
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role IS NULL OR caller_role NOT IN ('admin', 'moderator') THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler post sabitleyebilir.';
  END IF;

  -- Post'u güncelle
  UPDATE community_posts
  SET is_pinned = true,
      pinned_at = now(),
      pinned_by = auth.uid(),
      updated_at = now()
  WHERE id = post_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post bulunamadı veya silinmiş: %', post_id;
  END IF;

  -- Aksiyonu logla
  INSERT INTO community_moderation_actions (actor_id, action, target_type, target_id, post_id)
  VALUES (auth.uid(), 'post_pinned', 'post', post_id, post_id);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.2: unpin_community_post — Post sabitlemeyi kaldır ve log'a kaydet
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION unpin_community_post(post_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role TEXT;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role IS NULL OR caller_role NOT IN ('admin', 'moderator') THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler sabitlemeyi kaldırabilir.';
  END IF;

  UPDATE community_posts
  SET is_pinned = false,
      pinned_at = NULL,
      pinned_by = NULL,
      updated_at = now()
  WHERE id = post_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post bulunamadı veya silinmiş: %', post_id;
  END IF;

  INSERT INTO community_moderation_actions (actor_id, action, target_type, target_id, post_id)
  VALUES (auth.uid(), 'post_unpinned', 'post', post_id, post_id);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.3: hide_community_post — Post'u gizle ve log'a kaydet
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION hide_community_post(post_id UUID, reason TEXT DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role TEXT;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role IS NULL OR caller_role NOT IN ('admin', 'moderator') THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler post gizleyebilir.';
  END IF;

  UPDATE community_posts
  SET is_hidden = true,
      hidden_at = now(),
      hidden_by = auth.uid(),
      moderation_status = 'hidden',
      updated_at = now()
  WHERE id = post_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post bulunamadı veya silinmiş: %', post_id;
  END IF;

  INSERT INTO community_moderation_actions (actor_id, action, target_type, target_id, post_id, reason)
  VALUES (auth.uid(), 'post_hidden', 'post', post_id, post_id, reason);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.4: unhide_community_post — Post gizlemeyi kaldır ve log'a kaydet
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION unhide_community_post(post_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role TEXT;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role IS NULL OR caller_role NOT IN ('admin', 'moderator') THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler gizlemeyi kaldırabilir.';
  END IF;

  UPDATE community_posts
  SET is_hidden = false,
      hidden_at = NULL,
      hidden_by = NULL,
      moderation_status = 'published',
      updated_at = now()
  WHERE id = post_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post bulunamadı veya silinmiş: %', post_id;
  END IF;

  INSERT INTO community_moderation_actions (actor_id, action, target_type, target_id, post_id)
  VALUES (auth.uid(), 'post_unhidden', 'post', post_id, post_id);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.5: delete_community_post — Admin soft-delete ve log'a kaydet
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION delete_community_post(post_id UUID, reason TEXT DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role TEXT;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role IS NULL OR caller_role NOT IN ('admin', 'moderator') THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler post silebilir.';
  END IF;

  UPDATE community_posts
  SET deleted_at = now(),
      deleted_by = auth.uid(),
      updated_at = now()
  WHERE id = post_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post bulunamadı veya zaten silinmiş: %', post_id;
  END IF;

  INSERT INTO community_moderation_actions (actor_id, action, target_type, target_id, post_id, reason)
  VALUES (auth.uid(), 'post_deleted', 'post', post_id, post_id, reason);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.6: fetch_moderation_actions — Moderasyon log'unu sayfalandırarak getir
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fetch_moderation_actions(
  limit_count INTEGER DEFAULT 50,
  offset_count INTEGER DEFAULT 0
)
RETURNS SETOF community_moderation_actions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Yetki kontrolü
  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role IN ('admin', 'moderator')
  ) THEN
    RAISE EXCEPTION 'Yetkisiz işlem. Sadece admin ve moderatörler aksiyon logunu görebilir.';
  END IF;

  RETURN QUERY
  SELECT *
  FROM community_moderation_actions
  ORDER BY created_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$;

-- ----------------------------------------------------------------------------
-- 4.7: delete_community_account_full — Kullanıcıyı tamamen sil (auth + tüm veriler)
-- ----------------------------------------------------------------------------
-- Kullanıcı "Hesabı ve Verileri Sil" dediğinde:
--   - Tüm postları, yorumları, beğenileri, kayıtları, şikayetleri, engellemeleri
--   - community_moderation_actions kayıtlarını
--   - Profili
--   - auth.users kaydını siler (Apple ile tekrar girişte sıfırdan başlar)

CREATE OR REPLACE FUNCTION delete_community_account_full()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Oturum bulunamadı.';
  END IF;

  DELETE FROM community_moderation_actions WHERE actor_id = v_uid;
  DELETE FROM community_blocks WHERE blocker_id = v_uid OR blocked_id = v_uid;
  DELETE FROM community_reports WHERE reporter_id = v_uid;
  UPDATE community_reports SET reviewer_id = NULL WHERE reviewer_id = v_uid;
  DELETE FROM community_post_likes WHERE user_id = v_uid;
  DELETE FROM community_post_saves WHERE user_id = v_uid;
  UPDATE community_moderation_actions
    SET comment_id = NULL
    WHERE comment_id IN (SELECT id FROM community_comments WHERE author_id = v_uid);
  DELETE FROM community_comments WHERE author_id = v_uid;
  UPDATE community_moderation_actions
    SET post_id = NULL
    WHERE post_id IN (SELECT id FROM community_posts WHERE author_id = v_uid);
  DELETE FROM community_posts WHERE author_id = v_uid;
  DELETE FROM profiles WHERE id = v_uid;
  DELETE FROM auth.users WHERE id = v_uid;
END;
$$;

-- ============================================================================
-- BÖLÜM 5: Tablo bazında UPDATE yetkisi (RLS güvenlik ağı)
-- ============================================================================
-- Admin/moderatörler topluluk postlarını düzenleyebilir.
-- Bu policy mevcut Admin_can_update_any_post ile aynı işi yapar,
-- ancak yeni moderasyon kolonları için açık yetki sağlar.

-- (Mevcut Admin_can_update_any_post policy'si zaten tüm kolonları kapsar.
--  Bu ek policy opsiyoneldir; kodun okunabilirliği için eklenmiştir.)

-- ============================================================================
-- DOĞRULAMA SORGULARI
-- ============================================================================

-- 1. Yeni kolonlar eklendi mi?
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'community_posts'
--   AND column_name IN ('pinned_at', 'pinned_by', 'hidden_at', 'hidden_by', 'moderation_status');

-- 2. community_moderation_actions tablosu oluştu mu?
-- SELECT table_name FROM information_schema.tables
-- WHERE table_name = 'community_moderation_actions';

-- 3. RPC fonksiyonları çalışıyor mu?
-- SELECT pin_community_post('<bir-post-uuid>');

-- 4. CHECK constraint düzeltildi mi?
-- SELECT conname, pg_get_constraintdef(oid)
-- FROM pg_constraint
-- WHERE conname = 'community_reports_reason_check';

-- 5. RLS policy'ler aktif mi?
-- SELECT tablename, policyname, cmd
-- FROM pg_policies
-- WHERE tablename = 'community_moderation_actions';

-- ============================================================================
