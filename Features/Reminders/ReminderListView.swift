import SwiftUI
import SwiftData

// MARK: - Reminder List View
// Gruplandırılmış hatırlatıcı listesi.
// Gruplar: Gecikenler → Bugün → Yaklaşanlar → Daha Sonra

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Reminder.dueDate) private var allReminders: [Reminder]
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var showAddReminder = false
    @State private var notificationPermissionRequested = false

    // Gruplandırılmış ve filtrelenmiş
    private var activeReminders: [Reminder] {
        allReminders.filter {
            $0.statusRaw != ReminderStatus.completed.rawValue &&
            $0.statusRaw != ReminderStatus.archived.rawValue
        }
    }

    private var overdueReminders: [Reminder] {
        activeReminders.filter { r in
            if r.isOverdue { return true }
            // Km eşiği geçilmiş olanlar da gecikenler grubuna
            if let vehicle = vehicleFor(r), r.isKmOverdue(vehicleOdometer: vehicle.currentOdometer) {
                return true
            }
            return false
        }
    }

    private var todayReminders: [Reminder] {
        activeReminders.filter { $0.isToday && !$0.isOverdue && !isKmOverdue($0) }
    }

    private var upcomingReminders: [Reminder] {
        activeReminders.filter { $0.isUpcoming && !$0.isToday && !$0.isOverdue && !isKmOverdue($0) }
    }

    private var laterReminders: [Reminder] {
        activeReminders.filter { !$0.isOverdue && !$0.isToday && !$0.isUpcoming && !isKmOverdue($0) }
    }

    private func isKmOverdue(_ reminder: Reminder) -> Bool {
        guard let vehicle = vehicleFor(reminder) else { return false }
        return reminder.isKmOverdue(vehicleOdometer: vehicle.currentOdometer)
    }

    var body: some View {
        Group {
            if activeReminders.isEmpty {
                emptyState
            } else {
                reminderListContent
            }
        }
        .sheet(isPresented: $showAddReminder) { ReminderFormView() }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: "bell.badge",
            title: "Önemli tarihleri takip et",
            description: "Muayene, sigorta ve bakım tarihlerini unutmamak için hatırlatıcı ekle.",
            actionTitle: "Hatırlatıcı Ekle",
            action: { showAddReminder = true }
        )
    }

    // MARK: - List Content
    private var reminderListContent: some View {
        List {
            if !overdueReminders.isEmpty {
                reminderGroup(
                    title: "Gecikenler",
                    icon: "exclamationmark.triangle.fill",
                    color: AppColors.critical,
                    reminders: overdueReminders
                )
            }

            if !todayReminders.isEmpty {
                reminderGroup(
                    title: "Bugün",
                    icon: "clock.fill",
                    color: AppColors.warning,
                    reminders: todayReminders
                )
            }

            if !upcomingReminders.isEmpty {
                reminderGroup(
                    title: "Yaklaşanlar",
                    icon: "bell.fill",
                    color: AppColors.accentPrimary,
                    reminders: upcomingReminders
                )
            }

            if !laterReminders.isEmpty {
                reminderGroup(
                    title: "Daha Sonra",
                    icon: "calendar",
                    color: AppColors.textTertiary,
                    reminders: laterReminders
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
    }

    // MARK: - Group Section
    private func reminderGroup(
        title: String,
        icon: String,
        color: Color,
        reminders: [Reminder]
    ) -> some View {
        Section {
            ForEach(reminders) { reminder in
                ReminderRow(reminder: reminder, vehicle: vehicleFor(reminder))
                    .swipeActions(edge: .trailing) {
                        Button {
                            completeReminder(reminder)
                        } label: {
                            Label("Tamamla", systemImage: "checkmark")
                        }
                        .tint(AppColors.success)
                    }
                    .swipeActions(edge: .leading) {
                        Button(role: .destructive) {
                            deleteReminder(reminder)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
            }
        } header: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                Text("· \(reminders.count)")
                    .foregroundColor(AppColors.textTertiary)
            }
            .font(AppTypography.captionMedium)
            .foregroundColor(color)
        }
    }

    // MARK: - Actions
    private func completeReminder(_ reminder: Reminder) {
        // Tekrar kuralını tamamlamadan önce al (completedAt set edildikten sonra da erişilebilir).
        let rule = reminder.repeatRule
        let oldDueDate = reminder.dueDate
        let oldDueOdometer = reminder.dueOdometer

        reminder.statusRaw = ReminderStatus.completed.rawValue
        reminder.completedAt = Date()
        try? modelContext.save()

        // Bildirimleri iptal et
        NotificationService.shared.cancelReminder(reminder)

        // Tekrarlayan hatırlatıcı ise bir sonraki oluşumu yarat
        if rule != .none, let baseDate = oldDueDate ?? reminder.completedAt {
            if let nextDate = ReminderRepeatEngine.shared.nextDueDate(from: baseDate, rule: rule) {
                let next = Reminder(
                    vehicleId: reminder.vehicleId,
                    type: reminder.type,
                    title: reminder.title,
                    dueDate: nextDate,
                    dueOdometer: oldDueOdometer,
                    repeatRule: reminder.repeatRuleRaw,
                    priority: reminder.priority,
                    status: .active,
                    notes: reminder.notes
                )
                modelContext.insert(next)
                try? modelContext.save()

                // Yeni oluşum için bildirim planla
                Task {
                    await NotificationService.shared.scheduleReminder(next)
                }
            }
        }
    }

    private func deleteReminder(_ reminder: Reminder) {
        NotificationService.shared.cancelReminder(reminder)
        modelContext.delete(reminder)
        try? modelContext.save()
    }

    // MARK: - Helpers
    private func vehicleFor(_ reminder: Reminder) -> Vehicle? {
        vehicles.first { $0.id == reminder.vehicleId }
    }
}

// MARK: - Reminder Row
struct ReminderRow: View {
    let reminder: Reminder
    let vehicle: Vehicle?

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // İkon
            Image(systemName: reminder.type.defaultIcon)
                .font(.body)
                .foregroundColor(statusColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(statusColor.opacity(0.12))
                )

            // İçerik
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: AppSpacing.xxs) {
                    if let vehicle {
                        Text(vehicle.plate.isEmpty ? vehicle.fullName : vehicle.plate)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }

                    if let dueDate = reminder.dueDate {
                        if vehicle != nil {
                            Text("·")
                                .foregroundColor(AppColors.textTertiary)
                        }
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }

                    if let dueKm = reminder.dueOdometer {
                        Text("·")
                            .foregroundColor(AppColors.textTertiary)
                        Text("\(dueKm.formatted()) km")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }

            Spacer()

            // Durum etiketi
            statusBadge
        }
        .padding(.vertical, AppSpacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.title), \(statusText)")
    }

    private var statusColor: Color {
        if reminder.statusRaw == ReminderStatus.completed.rawValue {
            return AppColors.success
        }
        if reminder.isOverdue {
            return AppColors.critical
        }
        if let vehicle, reminder.isKmOverdue(vehicleOdometer: vehicle.currentOdometer) {
            return AppColors.critical
        }
        if reminder.isToday {
            return AppColors.warning
        }
        if let vehicle, reminder.isKmUpcoming(vehicleOdometer: vehicle.currentOdometer) {
            return AppColors.warning
        }
        return AppColors.accentPrimary
    }

    private var statusText: String {
        if reminder.statusRaw == ReminderStatus.completed.rawValue {
            return "Tamamlandı"
        }
        if reminder.isOverdue {
            return "\(reminder.daysOverdue) gün gecikti"
        }
        if let vehicle, reminder.isKmOverdue(vehicleOdometer: vehicle.currentOdometer) {
            let exceeded = vehicle.currentOdometer - (reminder.dueOdometer ?? 0)
            return "\(exceeded.formatted()) km gecikti"
        }
        if reminder.isToday {
            return "Bugün"
        }
        if let vehicle, reminder.isKmUpcoming(vehicleOdometer: vehicle.currentOdometer) {
            let remaining = (reminder.dueOdometer ?? 0) - vehicle.currentOdometer
            return "\(remaining.formatted()) km kaldı"
        }
        return "\(reminder.daysRemaining) gün kaldı"
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.12))
            )
    }
}

// MARK: - Preview
#Preview("Hatırlatıcı Listesi — Dolu") {
    ReminderListView()
        .modelContainer(MockDataProvider.previewContainer)
}

#Preview("Hatırlatıcı Listesi — Dark Mode") {
    ReminderListView()
        .modelContainer(MockDataProvider.previewContainer)
        .preferredColorScheme(.dark)
}
