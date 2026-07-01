import Foundation

// MARK: - Community Post
// Supabase community_posts tablosuna karşılık gelen Codable model.

struct CommunityPost: Codable, Identifiable, Equatable {
    let id: UUID
    let authorId: UUID
    var title: String
    var body: String
    var postType: PostType
    var tags: [String]
    var vehicleBrand: String?
    var vehicleModel: String?
    var vehicleYear: Int?
    var isPinned: Bool
    var isHidden: Bool
    var likeCount: Int
    var commentCount: Int
    var saveCount: Int
    var deletedAt: Date?
    var deletedBy: UUID?
    var pinnedAt: Date?
    var pinnedBy: UUID?
    var hiddenAt: Date?
    var hiddenBy: UUID?
    var moderationStatus: String?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Joined (profiles tablosundan)

    var authorUsername: String?
    var authorDisplayName: String?
    var authorAvatarURL: String?
    var authorIsVerified: Bool?
    var authorRole: CommunityRole?

    // MARK: - Client-only (Supabase'de saklanmaz)

    var isLikedByCurrentUser: Bool = false
    var isSavedByCurrentUser: Bool = false

    // MARK: - Computed

    var authorEffectiveName: String {
        if let displayName = authorDisplayName, !displayName.isEmpty {
            return displayName
        }
        return authorUsername ?? "Bilinmeyen"
    }

    var authorAtUsername: String? {
        guard let username = authorUsername else { return nil }
        return "@\(username)"
    }

    var isDeleted: Bool { deletedAt != nil }

    var isCurrentlyPinned: Bool { isPinned && pinnedAt != nil }

    var isModerationHidden: Bool { isHidden && hiddenAt != nil }

    var vehicleLabel: String? {
        guard let brand = vehicleBrand, !brand.isEmpty else { return nil }
        var parts: [String] = [brand]
        if let model = vehicleModel, !model.isEmpty {
            parts.append(model)
        }
        if let year = vehicleYear {
            parts.append(String(year))
        }
        return parts.joined(separator: " ")
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
        case authorId = "author_id"
        case title, body
        case postType = "post_type"
        case tags
        case vehicleBrand = "vehicle_brand"
        case vehicleModel = "vehicle_model"
        case vehicleYear = "vehicle_year"
        case isPinned = "is_pinned"
        case isHidden = "is_hidden"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case saveCount = "save_count"
        case deletedAt = "deleted_at"
        case deletedBy = "deleted_by"
        case pinnedAt = "pinned_at"
        case pinnedBy = "pinned_by"
        case hiddenAt = "hidden_at"
        case hiddenBy = "hidden_by"
        case moderationStatus = "moderation_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        // Joined fields
        case authorUsername = "author_username"
        case authorDisplayName = "author_display_name"
        case authorAvatarURL = "author_avatar_url"
        case authorIsVerified = "author_is_verified"
        case authorRole = "author_role"
    }

    // MARK: - Validate

    struct ValidationErrors {
        var title: String?
        var body: String?
        var postType: String?
        var tags: String?

        var isValid: Bool {
            title == nil && body == nil && postType == nil && tags == nil
        }

        var allErrors: [String] {
            [title, body, postType, tags].compactMap { $0 }
        }
    }

    static func validate(
        title: String,
        body: String,
        postType: PostType?,
        tags: [String]
    ) -> ValidationErrors {
        var errors = ValidationErrors()

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errors.title = "Başlık zorunludur."
        } else if trimmedTitle.count < 5 {
            errors.title = "Başlık en az 5 karakter olmalı."
        } else if trimmedTitle.count > 120 {
            errors.title = "Başlık en fazla 120 karakter olabilir."
        }

        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedBody.isEmpty {
            errors.body = "İçerik zorunludur."
        } else if trimmedBody.count < 20 {
            errors.body = "İçerik en az 20 karakter olmalı."
        } else if trimmedBody.count > 5000 {
            errors.body = "İçerik en fazla 5000 karakter olabilir."
        }

        if postType == nil {
            errors.postType = "Gönderi türü seçmelisin."
        }

        if tags.isEmpty {
            errors.tags = "En az bir etiket seçmelisin."
        }

        return errors
    }
}
