import SwiftUI
import SwiftData
import Charts

// MARK: - Reports View
// Araç masraf raporları: yıllık toplam, aylık grafik, kategori dağılımı,
// km başı maliyet, en pahalı kayıtlar.
// Tasarım kuralı: Sakin, okunaklı, tek ana metrik.

struct ReportsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var selectedVehicleId: UUID?
    @State private var selectedYear: Int

    private let currentYear = Calendar.current.component(.year, from: Date())

    init() {
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }

    private var filteredExpenses: [Expense] {
        let byVehicle = selectedVehicleId == nil
            ? allExpenses
            : allExpenses.filter { $0.vehicleId == selectedVehicleId }
        return byVehicle.filter { Calendar.current.component(.year, from: $0.date) == selectedYear }
    }

    private var yearlyTotal: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var monthlyData: [(month: String, total: Double)] {
        let months = Calendar.current.shortMonthSymbols
        var result: [(String, Double)] = []
        for (i, name) in months.enumerated() {
            let total = filteredExpenses
                .filter { Calendar.current.component(.month, from: $0.date) == i + 1 }
                .reduce(0) { $0 + $1.amount }
            result.append((name, total))
        }
        return result
    }

    private var categoryData: [(category: ExpenseCategory, total: Double, percentage: Double)] {
        var dict: [ExpenseCategory: Double] = [:]
        for e in filteredExpenses { dict[e.category, default: 0] += e.amount }
        let total = yearlyTotal
        return dict
            .map { ($0.key, $0.value, total > 0 ? ($0.value / total) * 100 : 0) }
            .sorted { $0.total > $1.total }
    }

    private var costPerKm: Double? {
        let totalKm = filteredExpenses.compactMap { $0.odometer }.max() ?? 0
        guard totalKm > 0, yearlyTotal > 0 else { return nil }
        return yearlyTotal / Double(totalKm)
    }

    private var topExpenses: [Expense] {
        Array(filteredExpenses.sorted { $0.amount > $1.amount }.prefix(5))
    }

    private var selectedVehicle: Vehicle? {
        vehicles.first { $0.id == selectedVehicleId }
    }

    var body: some View {
        NavigationStack {
            Group {
                if allExpenses.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "Masraf raporlarını keşfet",
                        description: "Aracını ekleyip masraf kaydettikten sonra yıllık toplam, aylık grafik ve kategori dağılımını burada görebilirsin.",
                        actionTitle: nil, action: nil
                    )
                } else {
                    reportContent
                }
            }
            .navigationTitle("Raporlar")
            .background(Color.appBackground)
        }
    }

    // MARK: - Content
    private var reportContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                filters
                primaryMetric
                monthlyChart
                categorySection
                if costPerKm != nil {
                    costPerKmCard
                }
                topExpensesSection
                Spacer().frame(height: AppSpacing.xxl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color.appBackground)
    }

    // MARK: - Filters
    private var filters: some View {
        HStack(spacing: AppSpacing.md) {
            // Araç filtresi
            if vehicles.count > 1 {
                Picker("Araç", selection: $selectedVehicleId) {
                    Text("Tüm Araçlar").tag(nil as UUID?)
                    ForEach(vehicles) { v in
                        Text(v.plate.isEmpty ? v.fullName : v.plate)
                            .tag(v.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.accentPrimary)
            }

            // Yıl filtresi
            Picker("Yıl", selection: $selectedYear) {
                ForEach(availableYears(), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.accentPrimary)
        }
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    private func availableYears() -> [Int] {
        let years = allExpenses.map { Calendar.current.component(.year, from: $0.date) }
        guard let minYear = years.min(), let maxYear = years.max() else { return [currentYear] }
        return Array(minYear...maxYear).reversed()
    }

    // MARK: - Primary Metric (yıllık toplam)
    private var primaryMetric: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(selectedYear == currentYear ? "Bu Yıl Toplam" : "\(String(selectedYear)) Toplam")
                .font(AppTypography.captionMedium)
                .foregroundColor(AppColors.textSecondary)

            Text(currencyFormat(yearlyTotal))
                .heroNumberStyle()
                .foregroundColor(AppColors.accentPrimary)

            if let vehicle = selectedVehicle {
                Text(vehicle.plate.isEmpty ? vehicle.fullName : "\(vehicle.plate) — \(vehicle.fullName)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
                .subtleShadow()
        )
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    // MARK: - Monthly Chart
    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Aylık Dağılım")

            Chart {
                ForEach(monthlyData, id: \.month) { item in
                    BarMark(
                        x: .value("Ay", item.month),
                        y: .value("Tutar", item.total)
                    )
                    .foregroundStyle(
                        item.total > 0
                            ? AppColors.accentPrimary.opacity(0.8)
                            : AppColors.border
                    )
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .frame(height: 180)
            .padding(.vertical, AppSpacing.xs)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
        )
        .subtleShadow()
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    // MARK: - Category Breakdown
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Kategori Dağılımı")

            VStack(spacing: AppSpacing.xs) {
                ForEach(categoryData.prefix(8), id: \.category) { item in
                    categoryRow(item)
                }

                if categoryData.isEmpty {
                    Text("Bu yıl için veri yok.")
                        .font(AppTypography.secondary)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, AppSpacing.md)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
        )
        .subtleShadow()
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    private func categoryRow(_ item: (category: ExpenseCategory, total: Double, percentage: Double)) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: item.category.defaultIcon)
                    .font(.caption)
                    .foregroundColor(AppColors.accentPrimary)
                    .frame(width: 20)

                Text(item.category.displayName)
                    .font(AppTypography.secondary)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(currencyFormat(item.total))
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.backgroundSecondary)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.accentPrimary.opacity(0.6))
                        .frame(width: max(geo.size.width * CGFloat(item.percentage / 100.0), 4), height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Cost Per Km
    private var costPerKmCard: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "gauge.with.needle")
                .font(.title2)
                .foregroundColor(AppColors.vehicle)
                .frame(width: 40, height: 40)
                .background(Circle().fill(AppColors.vehicle.opacity(0.1)))

            VStack(alignment: .leading, spacing: 2) {
                Text("Km Başı Maliyet")
                    .font(AppTypography.captionMedium)
                    .foregroundColor(AppColors.textSecondary)
                Text(costPerKm.map { currencyFormat($0) } ?? "—")
                    .font(AppTypography.amount)
                    .foregroundColor(AppColors.vehicle)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
        )
        .subtleShadow()
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    // MARK: - Top Expenses
    private var topExpensesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "En Yüksek Masraflar")

            if topExpenses.isEmpty {
                Text("Bu yıl için veri yok.")
                    .font(AppTypography.secondary)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, AppSpacing.md)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(topExpenses.enumerated()), id: \.element.id) { index, expense in
                        topExpenseRow(index: index + 1, expense: expense)
                        if index < topExpenses.count - 1 {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
        )
        .subtleShadow()
        .padding(.horizontal, AppSpacing.screenMarginH)
    }

    private func topExpenseRow(index: Int, expense: Expense) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(String(index))
                .font(AppTypography.captionMedium)
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 20)

            Image(systemName: expense.category.defaultIcon)
                .font(.caption)
                .foregroundColor(AppColors.accentPrimary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category.displayName)
                    .font(AppTypography.secondary)
                    .foregroundColor(AppColors.textPrimary)
                if let vendor = expense.vendorName, !vendor.isEmpty {
                    Text(vendor)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(expense.amountCompactDisplay)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                Text(expense.dateDisplay)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    // MARK: - Helpers
    private func currencyFormat(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: NSNumber(value: value)) ?? "₺0,00"
    }
}

// MARK: - Preview
#Preview("Raporlar — Dolu") {
    ReportsView()
        .modelContainer(MockDataProvider.previewContainer)
}

#Preview("Raporlar — Dark Mode") {
    ReportsView()
        .modelContainer(MockDataProvider.previewContainer)
        .preferredColorScheme(.dark)
}
