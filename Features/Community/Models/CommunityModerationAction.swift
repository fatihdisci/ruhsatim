import Foundation

// MARK: - Community Moderation Action
// Supabase community_moderation_actions tablosuna karşılık gelen Codable model.
// Admin/moderatör aksiyonlarını loglamak için kullanılır.

struct CommunityModerationAction: Codable, Identifiable, Equatable {
    let id: UUID
    let actorId: UUID
    let action: String
    let targetType: String?
    let targetId: UUID?
    let postId: UUID?
    let commentId: UUID?
    let reason: String?
    let createdAt: Date

    // MARK: - Joined (profiles tablosundan)

    var actorUsername: String?
    var actorDisplayName: String?
    var actorAvatarURL: String?

    // MARK: - Computed

    var actionDisplayName: String {
        switch action {
        case "post_pinned": return "Post Sabitlendi"
        case "post_unpinned": return "Post Sabiti Kaldırıldı"
        case "post_hidden": return "Post Gizlendi"
        case "post_unhidden": return "Post Gizlemesi Kaldırıldı"
        case "post_deleted": return "Post Silindi"
        case "post_restored": return "Post Geri Getirildi"
        case "comment_hidden": return "Yorum Gizlendi"
        case "comment_unhidden": return "Yorum Gizlemesi Kaldırıldı"
        case "comment_deleted": return "Yorum Silindi"
        case "user_banned": return "Kullanıcı Yasaklandı"
        case "user_unbanned": return "Kullanıcı Yasağı Kaldırıldı"
        case "report_reviewed": return "Şikayet İncelendi"
        case "report_dismissed": return "Şikayet Reddedildi"
        default: return action
        }
    }

    var actionIcon: String {
        switch action {
        case "post_pinned": return "pin.fill"
        case "post_unpinned": return "pin.slash.fill"
        case "post_hidden", "comment_hidden": return "eye.slash"
        case "post_unhidden", "comment_unhidden": return "eye"
        case "post_deleted", "comment_deleted": return "trash"
        case "post_restored": return "arrow.uturn.backward"
        case "user_banned": return "hand.raised"
        case "user_unbanned": return "hand.raised.slash"
        case "report_reviewed": return "checkmark.shield"
        case "report_dismissed": return "xmark.shield"
        default: return "gearshape"
        }
    }

    var relativeTime: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "Az önce" }
        if interval < 3600 { return "\(Int(interval / 60)) dk önce" }
        if interval < 86400 { return "\(Int(interval / 3600)) saat önce" }
        if interval < 604800 { return "\(Int(interval / 86400)) gün önce" }
        return createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case actorId = "actor_id"
        case action
        case targetType = "target_type"
        case targetId = "target_id"
        case postId = "post_id"
        case commentId = "comment_id"
        case reason
        case createdAt = "created_at"
        // Joined fields
        case actorUsername = "actor_username"
        case actorDisplayName = "actor_display_name"
        case actorAvatarURL = "actor_avatar_url"
    }
}
