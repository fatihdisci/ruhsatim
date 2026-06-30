import SwiftUI

// MARK: - Arvia Guide Card
// Calm, local guidance card for the rule-based Rehber foundation.

struct ArviaGuideCard: View {
    let insight: VehicleInsight
    let primaryAction: () -> Void
    let dismissAction: (() -> Void)?

    init(
        insight: VehicleInsight,
        primaryAction: @escaping () -> Void,
        dismissAction: (() -> Void)? = nil
    ) {
        self.insight = insight
        self.primaryAction = primaryAction
        self.dismissAction = dismissAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: iconName)
                    .font(.body)
                    .foregroundColor(priorityColor)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.small)
                            .fill(priorityColor.opacity(0.12))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(insight.title)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(insight.body)
                        .font(AppTypography.secondarySmall)
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.xs)
            }

            HStack(spacing: AppSpacing.sm) {
                Button(action: primaryAction) {
                    Label(insight.action.title, systemImage: actionIconName)
                        .font(AppTypography.captionMedium)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
                .foregroundColor(AppColors.accentPrimary)
                .frame(minHeight: AppSpacing.minimumTapTarget, alignment: .leading)

                Spacer()

                if let dismissAction {
                    Button("Daha sonra", action: dismissAction)
                        .font(AppTypography.captionMedium)
                        .foregroundColor(AppColors.textTertiary)
                        .frame(minHeight: AppSpacing.minimumTapTarget)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(priorityColor.opacity(insight.priority == .info ? 0.14 : 0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(insight.title). \(insight.body). \(insight.action.title)")
    }

    private var iconName: String {
        switch insight.type {
        case .maintenance:
            return "wrench.and.screwdriver"
        case .missingDocument:
            return "doc.text"
        case .saleFileReadiness:
            return "doc.richtext"
        case .odometerUpdate:
            return "gauge.with.needle"
        case .overdueReminder:
            return "bell.badge"
        }
    }

    private var actionIconName: String {
        switch insight.action {
        case .addServiceRecord:
            return "plus.circle"
        case .addDocument:
            return "doc.badge.plus"
        case .openSaleFile:
            return "doc.richtext"
        case .updateOdometer:
            return "gauge.with.needle"
        case .openTodos:
            return "checklist"
        case .addInspectionReport:
            return "magnifyingglass"
        }
    }

    private var priorityColor: Color {
        switch insight.priority {
        case .info:
            return AppColors.accentPrimary
        case .warning:
            return AppColors.warning
        case .important:
            return AppColors.critical
        }
    }
}

