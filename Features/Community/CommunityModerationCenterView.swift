import SwiftUI

// MARK: - Community Moderation Center View
// Admin/moderatör için moderasyon merkezi.
// Sabitlenen postlar, şikayetler, gizlenen postlar ve son işlemler sekmeleri.

struct CommunityModerationCenterView: View {
    @EnvironmentObject private var communityAuth: CommunityAuthService
    @Environment(\.dismiss) private var dismiss

    enum ModTab: String, CaseIterable {
        case pinned
        case reports
        case hidden
        case actions

        var displayName: String {
            switch self {
            case .pinned: return "Sabitlenenler"
            case .reports: return "Şikayetler"
            case .hidden: return "Gizlenenler"
            case .actions: return "Son İşlemler"
            }
        }

        var icon: String {
            switch self {
            case .pinned: return "pin.fill"
            case .reports: return "flag"
            case .hidden: return "eye.slash"
            case .actions: return "clock"
            }
        }
    }

    @State private var selectedTab: ModTab = .reports
    @State private var pinnedPosts: [CommunityPost] = []
    @State private var hiddenPosts: [CommunityPost] = []
    @State private var moderationActions: [CommunityModerationAction] = []
    @State private var isLoadingPinned = false
    @State private var isLoadingHidden = false
    @State private var isLoadingActions = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("Sekme", selection: $selectedTab) {
                    ForEach(ModTab.allCases, id: \.self) { tab in
                        Label(tab.displayName, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.screenMarginH)
                .padding(.vertical, AppSpacing.sm)

                // Tab content
                Group {
                    switch selectedTab {
                    case .pinned:
                        pinnedPostsList
                    case .reports:
                        CommunityModerationView()
                    case .hidden:
                        hiddenPostsList
                    case .actions:
                        actionsList
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(Color.appBackground)
            .navigationTitle("Moderasyon Merkezi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .onChange(of: selectedTab) { _, newTab in
                Task { await loadTabContent(newTab) }
            }
            .task {
                await loadTabContent(selectedTab)
            }
        }
    }

    // MARK: - Pinned Posts List

    private var pinnedPostsList: some View {
        Group {
            if isLoadingPinned {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if pinnedPosts.isEmpty {
                CommunityEmptyStateView(state: .noPosts)
                    .padding(.top, AppSpacing.xl)
            } else {
                List {
                    ForEach(pinnedPosts) { post in
                        pinnedPostRow(post)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func pinnedPostRow(_ post: CommunityPost) -> some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(post.title)
                    .font(AppTypography.secondaryMedium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(post.authorEffectiveName)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)

                    Text("·")
                        .foregroundColor(AppColors.textTertiary)

                    Text(post.relativeTime)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            Button {
                Task { await handleUnpin(post) }
            } label: {
                Label("Sabiti Kaldır", systemImage: "pin.slash")
                    .font(AppTypography.captionMedium)
                    .foregroundColor(AppColors.accentPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.screenMarginH)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Hidden Posts List

    private var hiddenPostsList: some View {
        Group {
            if isLoadingHidden {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if hiddenPosts.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(AppColors.textTertiary)
                    Text("Gizlenen post yok")
                        .font(AppTypography.secondary)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xl)
            } else {
                List {
                    ForEach(hiddenPosts) { post in
                        hiddenPostRow(post)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func hiddenPostRow(_ post: CommunityPost) -> some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(post.title)
                    .font(AppTypography.secondaryMedium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(post.authorEffectiveName)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)

                    if let hiddenAt = post.hiddenAt {
                        Text("·")
                            .foregroundColor(AppColors.textTertiary)
                        Text(hiddenAt.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }

            Spacer()

            Button {
                Task { await handleUnhide(post) }
            } label: {
                Label("Yayına Al", systemImage: "eye")
                    .font(AppTypography.captionMedium)
                    .foregroundColor(AppColors.accentPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.screenMarginH)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Actions List

    private var actionsList: some View {
        Group {
            if isLoadingActions {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if moderationActions.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "clock")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(AppColors.textTertiary)
                    Text("Henüz işlem yapılmadı")
                        .font(AppTypography.secondary)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xl)
            } else {
                List {
                    ForEach(moderationActions) { action in
                        actionRow(action)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func actionRow(_ action: CommunityModerationAction) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: action.actionIcon)
                .font(.subheadline)
                .foregroundColor(AppColors.accentPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(action.actionDisplayName)
                    .font(AppTypography.secondaryMedium)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 4) {
                    if let actorName = action.actorDisplayName ?? action.actorUsername {
                        Text(actorName)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }

                    Text("·")
                        .foregroundColor(AppColors.textTertiary)

                    Text(action.relativeTime)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.screenMarginH)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Helpers

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Yükleniyor...")
                .font(AppTypography.secondary)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(AppColors.warning)
            Text(message)
                .font(AppTypography.secondary)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Tekrar Dene") {
                Task { await loadTabContent(selectedTab) }
            }
            .buttonStyle(.bordered)
            .tint(AppColors.accentPrimary)
            Spacer()
        }
    }

    // MARK: - Data Loading

    private func loadTabContent(_ tab: ModTab) async {
        switch tab {
        case .pinned:
            await loadPinnedPosts()
        case .hidden:
            await loadHiddenPosts()
        case .actions:
            await loadActions()
        case .reports:
            break // CommunityModerationView handles its own loading
        }
    }

    private func loadPinnedPosts() async {
        isLoadingPinned = true
        errorMessage = nil
        do {
            pinnedPosts = try await CommunityModerationService.shared.fetchPinnedPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingPinned = false
    }

    private func loadHiddenPosts() async {
        isLoadingHidden = true
        errorMessage = nil
        do {
            hiddenPosts = try await CommunityModerationService.shared.fetchHiddenPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingHidden = false
    }

    private func loadActions() async {
        isLoadingActions = true
        errorMessage = nil
        do {
            moderationActions = try await CommunityModerationService.shared.fetchModerationActions()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingActions = false
    }

    // MARK: - Actions

    private func handleUnpin(_ post: CommunityPost) async {
        do {
            try await CommunityModerationService.shared.unpinPost(post.id)
            pinnedPosts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleUnhide(_ post: CommunityPost) async {
        do {
            try await CommunityModerationService.shared.unhidePost(post.id)
            hiddenPosts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview("Moderation Center") {
    CommunityModerationCenterView()
        .environmentObject(CommunityAuthService.shared)
}
