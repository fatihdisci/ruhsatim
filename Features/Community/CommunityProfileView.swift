import SwiftUI
import SwiftData

// MARK: - Community Profile View
// Profil oluşturma ve düzenleme ekranı.

struct CommunityProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var communityAuth: CommunityAuthService
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var username: String
    @State private var displayName: String
    @State private var selectedVehicleId: UUID?
    @State private var showVehicleOnPosts: Bool
    @State private var validationError: String?
    @State private var isSaving = false
    @State private var isCheckingUsername = false
    @State private var usernameAvailable: Bool?
    @State private var usernameCheckTask: Task<Void, Never>?

    private let carCatalog = CarCatalogService.shared

    init() {
        let profile = CommunityAuthService.shared.profile
        _username = State(initialValue: profile?.username ?? "")
        _displayName = State(initialValue: profile?.displayName ?? "")
        _selectedVehicleId = State(initialValue: Self.loadSelectedVehicleId())
        _showVehicleOnPosts = State(initialValue: profile?.showVehicleOnPosts ?? false)
    }

    // MARK: - Vehicle Selection Persistence

    private static let selectedVehicleIdKey = "community_selected_vehicle_id"

    private static func loadSelectedVehicleId() -> UUID? {
        guard let uuidString = UserDefaults.standard.string(forKey: selectedVehicleIdKey) else { return nil }
        return UUID(uuidString: uuidString)
    }

    private static func saveSelectedVehicleId(_ id: UUID?) {
        UserDefaults.standard.set(id?.uuidString, forKey: selectedVehicleIdKey)
    }

    private var selectedVehicleLabel: String? {
        guard let id = selectedVehicleId,
              let vehicle = vehicles.first(where: { $0.id == id }) else { return nil }
        var parts = [vehicle.brand, vehicle.model]
        if let year = vehicle.year { parts.append(String(year)) }
        return parts.filter { !$0.isEmpty }.joined(separator: " ")
    }

    /// Picker'da gösterilecek güvenli araç etiketi (plaka içermez).
    private func vehicleLabel(for vehicle: Vehicle) -> String {
        var parts = [vehicle.brand, vehicle.model]
        if let year = vehicle.year { parts.append(String(year)) }
        return parts.filter { !$0.isEmpty }.joined(separator: " ")
    }

    var body: some View {
        NavigationStack {
            Form {
                // Validation
                if let error = validationError {
                    Section {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.critical)
                    }
                    .listRowBackground(AppColors.criticalBackground)
                }

                // Username
                Section {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "at")
                            .font(.body)
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 24)
                        TextField("kullanici_adin", text: $username)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: username) { _, _ in
                                checkUsername()
                            }

                        if isCheckingUsername {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else if let available = usernameAvailable {
                            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(available ? AppColors.success : AppColors.critical)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Kullanıcı Adı")
                } footer: {
                    Text("Kullanıcı adın toplulukta herkese açık görünecek. Plaka bilgini paylaşma.")
                        .foregroundColor(AppColors.textTertiary)
                }

                // Display name
                Section {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "person.text.rectangle")
                            .font(.body)
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 24)
                        TextField("Görünen ad (isteğe bağlı)", text: $displayName)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                } header: {
                    Text("Görünen Ad")
                }

                // Vehicle defaults — kayıtlı araçlardan seçim
                Section {
                    if vehicles.isEmpty {
                        // Hiç araç yok — bilgi mesajı
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "car")
                                .font(.body)
                                .foregroundColor(AppColors.textTertiary)
                                .frame(width: 24)
                            Text("Henüz araç eklenmemiş")
                                .font(AppTypography.secondary)
                                .foregroundColor(AppColors.textTertiary)
                        }

                        Text("Araç etiketi göstermek için önce Garaj'dan araç ekle.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)

                        Toggle("Aracımı gönderilerimde göster", isOn: $showVehicleOnPosts)
                            .disabled(true)
                    } else {
                        // Araç seçimi
                        Picker("Varsayılan Araç", selection: $selectedVehicleId) {
                            Text("Araç gösterme").tag(nil as UUID?)
                            ForEach(vehicles) { vehicle in
                                Text(vehicleLabel(for: vehicle))
                                    .tag(vehicle.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.accentPrimary)

                        Toggle("Aracımı gönderilerimde göster", isOn: $showVehicleOnPosts)
                    }
                } header: {
                    Text("Varsayılan Araç (isteğe bağlı)")
                } footer: {
                    Text("Profilinde görünen araç etiketi yalnızca marka/model/yıl içerir; plaka bilgisi asla paylaşılmaz.")
                        .foregroundColor(AppColors.textTertiary)
                }

                // Hesap işlemleri
                Section {
                    // Çıkış ve hesap silme işlemleri artık Ayarlar sayfasında.
                    // Topluluk profili yalnızca profil düzenleme içindir.
                } header: {
                    Text("Hesap")
                } footer: {
                    Text("Çıkış yapmak ve hesabını silmek için Ayarlar sayfasını kullan.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .onChange(of: vehicles.count) { _, _ in
                // Seçili araç silinmişse seçimi sıfırla
                if let selectedId = selectedVehicleId,
                   !vehicles.contains(where: { $0.id == selectedId }) {
                    selectedVehicleId = nil
                    Self.saveSelectedVehicleId(nil)
                }
            }
            .navigationTitle(communityAuth.profile == nil ? "Profil Oluştur" : "Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(isSaving)
                }
            }
        }
    }

    private func checkUsername() {
        usernameCheckTask?.cancel()
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            usernameAvailable = nil
            return
        }

        // Don't re-check own username
        if trimmed == communityAuth.profile?.username {
            usernameAvailable = true
            return
        }

        usernameCheckTask = Task {
            isCheckingUsername = true
            do {
                let available = try await CommunityProfileService.shared.checkUsernameAvailability(trimmed)
                if !Task.isCancelled {
                    usernameAvailable = available
                }
            } catch {
                if !Task.isCancelled {
                    usernameAvailable = nil
                }
            }
            if !Task.isCancelled {
                isCheckingUsername = false
            }
        }
    }

    private func save() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = CommunityProfile.validateUsername(trimmedUsername) {
            validationError = error
            return
        }

        if let error = CommunityProfile.validateDisplayName(
            displayName.isEmpty ? nil : displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        ) {
            validationError = error
            return
        }

        validationError = nil
        isSaving = true

        Task {
            do {
                guard let session = communityAuth.currentSession else {
                    validationError = "Oturum bulunamadı."
                    isSaving = false
                    return
                }

                let userId = session.user.id
                let dn = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

                // Seçili araçtan marka/model/yıl türet
                let selectedVehicle = selectedVehicleId.flatMap { id in vehicles.first { $0.id == id } }

                if communityAuth.profile == nil {
                    // Create
                    _ = try await CommunityProfileService.shared.createProfile(
                        userId: userId,
                        username: trimmedUsername,
                        displayName: dn.isEmpty ? nil : dn
                    )
                } else {
                    // Update
                    _ = try await CommunityProfileService.shared.updateProfile(
                        userId: userId,
                        username: trimmedUsername,
                        displayName: dn.isEmpty ? nil : dn,
                        defaultVehicleBrand: showVehicleOnPosts ? selectedVehicle?.brand : nil,
                        defaultVehicleModel: showVehicleOnPosts ? selectedVehicle?.model : nil,
                        defaultVehicleYear: showVehicleOnPosts ? selectedVehicle?.year : nil,
                        showVehicleOnPosts: showVehicleOnPosts
                    )
                }

                // Seçimi persist et
                Self.saveSelectedVehicleId(selectedVehicleId)

                await communityAuth.fetchProfile(userId: userId)
                dismiss()
            } catch {
                validationError = "Kaydedilemedi: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }
}

// MARK: - Preview

#Preview("Create Profile") {
    CommunityProfileView()
        .environmentObject(CommunityAuthService.shared)
}
