import SwiftUI

// MARK: - Paywall View
// Etik freemium paywall. Karanlık desen yok.
// Değer anlarında gösterilir, ilk açılışta değil.

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService

    let feature: PaywallFeature

    enum PaywallFeature {
        case secondVehicle
        case documentLimit
        case saleFile
        case advancedReports

        var title: String {
            switch self {
            case .secondVehicle: return "İkinci Aracını da Ekle"
            case .documentLimit: return "Belge Limitini Kaldır"
            case .saleFile: return "Satış Dosyası Oluştur"
            case .advancedReports: return "Gelişmiş Raporlar"
            }
        }

        var description: String {
            switch self {
            case .secondVehicle:
                return "Birden fazla aracın varsa hepsini tek yerden takip et."
            case .documentLimit:
                return "Poliçe, fatura ve ekspertiz raporlarını sınırsız sakla."
            case .saleFile:
                return "Aracının eksiksiz satış dosyasını PDF olarak oluştur ve paylaş."
            case .advancedReports:
                return "Yıllık trend, araç karşılaştırma ve detaylı maliyet analizi."
            }
        }
    }

    @State private var selectedProductIndex = 1 // Varsayılan: yıllık
    @State private var isPurchasing = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Hero
                    heroSection

                    // Neden Pro?
                    proBenefits

                    // Fiyatlandırma
                    pricingSection

                    // CTA
                    ctaSection

                    // Güven mesajları
                    trustSection
                }
                .padding(.vertical, AppSpacing.xl)
            }
            .background(Color.appBackground)
            .navigationTitle("Pro'ya Geç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Gradyan hero (tasarım anayasası izinli: paywall hero)
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xlarge)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.vehicle, AppColors.accentPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)

                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.9))
                    Text(feature.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(feature.description)
                        .font(AppTypography.secondary)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.screenMarginH)
        }
    }

    // MARK: - Benefits
    private var proBenefits: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Pro ile Gelenler")

            VStack(spacing: 0) {
                ForEach(PaywallService.proFeatures, id: \.title) { feature in
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: feature.icon)
                            .font(.body)
                            .foregroundColor(AppColors.accentPrimary)
                            .frame(width: 28)

                        Text(feature.title)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(AppColors.success)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)

                    if feature.title != PaywallService.proFeatures.last?.title {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.appSurface)
            )
        }
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    // MARK: - Pricing
    private var pricingSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Plan Seç")

            // Dev mode: sabit fiyatlar
            VStack(spacing: AppSpacing.sm) {
                pricingOption(
                    index: 0,
                    title: "Aylık",
                    price: "₺79",
                    period: "/ay",
                    isSelected: selectedProductIndex == 0
                )
                pricingOption(
                    index: 1,
                    title: "Yıllık",
                    price: "₺599",
                    period: "/yıl",
                    badge: "En Avantajlı",
                    isSelected: selectedProductIndex == 1
                )
                pricingOption(
                    index: 2,
                    title: "Ömür Boyu",
                    price: "₺1.499",
                    period: "",
                    badge: "Tek Seferlik",
                    isSelected: selectedProductIndex == 2
                )
            }
        }
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    private func pricingOption(
        index: Int,
        title: String,
        price: String,
        period: String,
        badge: String? = nil,
        isSelected: Bool
    ) -> some View {
        Button {
            selectedProductIndex = index
        } label: {
            HStack(spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text(title)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.textPrimary)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppColors.success)
                                .padding(.horizontal, AppSpacing.xxs)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(AppColors.successBackground)
                                )
                        }
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(price)
                            .font(AppTypography.amount)
                            .foregroundColor(AppColors.textPrimary)
                        if !period.isEmpty {
                            Text(period)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.accentPrimary : AppColors.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(AppColors.accentPrimary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium)
                            .stroke(isSelected ? AppColors.accentPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA
    private var ctaSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Button {
                performPurchase()
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    }
                    Text(isPurchasing ? "İşlem yapılıyor..." : "Pro'ya Geç")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
            .disabled(isPurchasing || isRestoring)
            .padding(.horizontal, AppSpacing.screenMarginH)

            Button {
                performRestore()
            } label: {
                HStack {
                    if isRestoring {
                        ProgressView()
                    }
                    Text(isRestoring ? "Kontrol ediliyor..." : "Satın Almaları Geri Yükle")
                }
                .font(AppTypography.secondary)
                .foregroundColor(AppColors.accentPrimary)
            }
            .disabled(isPurchasing || isRestoring)
        }
    }

    // MARK: - Trust
    private var trustSection: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("İstediğin zaman iptal edebilirsin.")
            }
            .font(AppTypography.caption)
            .foregroundColor(AppColors.textSecondary)

            Text("Satın alımlar Apple hesabın üzerinden yönetilir. Kullanmadığın süre için ücret iadesi Apple politikalarına tabidir.")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xxl)
        }
    }

    // MARK: - Actions
    private func performPurchase() {
        guard !paywallService.isDevMode else {
            paywallService.enableProForDev()
            dismiss()
            return
        }

        guard selectedProductIndex < paywallService.products.count else {
            paywallService.purchaseError = "Ürün bulunamadı."
            return
        }

        isPurchasing = true
        Task {
            let product = paywallService.products[selectedProductIndex]
            let success = await paywallService.purchase(product)
            await MainActor.run {
                isPurchasing = false
                if success {
                    dismiss()
                }
            }
        }
    }

    private func performRestore() {
        isRestoring = true
        Task {
            await paywallService.restorePurchases()
            await MainActor.run {
                isRestoring = false
                if paywallService.isPro {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Paywall — 2. Araç") {
    PaywallView(feature: .secondVehicle)
        .environmentObject(PaywallService.shared)
}
