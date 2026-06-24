import SwiftUI
import SwiftData
import UIKit

// MARK: - Vehicle Edit View
// Mevcut araç bilgilerini düzenleme sheet'i.

struct VehicleEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let vehicle: Vehicle

    @State private var plate: String
    @State private var brand: String
    @State private var model: String
    @State private var nickname: String
    @State private var yearText: String
    @State private var odometerText: String
    @State private var fuelType: FuelType
    @State private var transmissionType: TransmissionType
    @State private var usageType: VehicleUsageType
    @State private var purchaseDate: Date
    @State private var purchaseOdometerText: String
    @State private var purchasePriceText: String
    @State private var notes: String

    @State private var validationErrors: [String] = []
    @State private var showErrors = false

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _plate = State(initialValue: vehicle.plate)
        _brand = State(initialValue: vehicle.brand)
        _model = State(initialValue: vehicle.model)
        _nickname = State(initialValue: vehicle.nickname)
        _yearText = State(initialValue: vehicle.year.map { String($0) } ?? "")
        _odometerText = State(initialValue: vehicle.currentOdometer > 0 ? String(vehicle.currentOdometer) : "")
        _fuelType = State(initialValue: vehicle.fuelType)
        _transmissionType = State(initialValue: vehicle.transmissionType ?? .manual)
        _usageType = State(initialValue: vehicle.usageType)
        _purchaseDate = State(initialValue: vehicle.purchaseDate ?? Date())
        _purchaseOdometerText = State(initialValue: vehicle.purchaseOdometer.map { String($0) } ?? "")
        _purchasePriceText = State(initialValue: vehicle.purchasePrice.map { String(Int($0)) } ?? "")
        _notes = State(initialValue: vehicle.notes)
    }

    private var year: Int? { Int(yearText.trimmingCharacters(in: .whitespaces)) }
    private var odometer: Int? { Int(odometerText.trimmingCharacters(in: .whitespaces)) }
    private var purchaseOdometer: Int? {
        let t = purchaseOdometerText.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : Int(t)
    }
    private var purchasePrice: Double? {
        let t = purchasePriceText.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : Double(t)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Temel bilgiler
                Section {
                    labeledField("Plaka", icon: "number", text: $plate)
                        .textInputAutocapitalization(.characters)
                    labeledField("Marka", icon: "car", text: $brand)
                    labeledField("Model", icon: "tag", text: $model)
                    labeledField("Yıl", icon: "calendar", text: $yearText, keyboard: .numberPad)
                    labeledField("Güncel Km", icon: "gauge.with.needle", text: $odometerText, keyboard: .numberPad)
                    labeledField("Takma ad", icon: "heart", text: $nickname)
                } header: {
                    Text("Temel Bilgiler")
                }

                // Tip bilgileri
                Section {
                    enumPicker("Yakıt Tipi", icon: "fuelpump", selection: $fuelType)
                    enumPicker("Vites", icon: "gearshift", selection: $transmissionType)
                    enumPicker("Kullanım", icon: "person", selection: $usageType)
                } header: {
                    Text("Araç Özellikleri")
                }

                // Satın alma bilgileri
                Section {
                    DatePicker(selection: $purchaseDate, displayedComponents: .date) {
                        Label("Satın Alma Tarihi", systemImage: "cart")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    labeledField("Satın Alma Km", icon: "gauge.with.needle", text: $purchaseOdometerText, keyboard: .numberPad)
                    labeledField("Satın Alma Fiyatı (₺)", icon: "banknote", text: $purchasePriceText, keyboard: .decimalPad)
                } header: {
                    Text("Satın Alma Bilgileri")
                }

                // Notlar
                Section {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(3...6)
                } header: {
                    Text("Notlar")
                }

                // Validasyon hataları
                if showErrors && !validationErrors.isEmpty {
                    Section {
                        ForEach(validationErrors, id: \.self) { error in
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(AppColors.critical)
                                Text(LocalizedStringKey(error))
                                    .font(AppTypography.secondary)
                                    .foregroundColor(AppColors.critical)
                            }
                        }
                    } header: {
                        Text("Düzeltilmesi Gerekenler")
                            .foregroundColor(AppColors.critical)
                    }
                    .listRowBackground(AppColors.criticalBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet", action: saveChanges)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.accentPrimary)
                }
            }
        }
    }

    // MARK: - Form helpers
    private func labeledField(_ label: String, icon: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 24)
            TextField(label, text: text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(keyboard)
        }
    }

    private func enumPicker<T: CaseIterable & Hashable>(
        _ label: String, icon: String, selection: Binding<T>
    ) -> some View where T.AllCases: RandomAccessCollection, T: RawRepresentable, T.RawValue == String {
        Picker(selection: selection) {
            ForEach(T.allCases as! [T], id: \.self) { item in
                Text(item.rawValue).tag(item)
            }
        } label: {
            Label(label, systemImage: icon)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Save
    private func saveChanges() {
        let errors = validate()
        if errors.isEmpty {
            applyChanges()
            dismiss()
        } else {
            validationErrors = errors
            showErrors = true
        }
    }

    private func validate() -> [String] {
        var errors: [String] = []

        let p = plate.trimmingCharacters(in: .whitespaces)
        if p.isEmpty {
            errors.append("Plaka zorunludur.")
        } else if p.count < 6 {
            errors.append("Plaka geçerli bir plaka numarası olmalıdır.")
        }

        if brand.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Marka zorunludur.")
        }
        if model.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Model zorunludur.")
        }

        if let y = year {
            let currentYear = Calendar.current.component(.year, from: Date())
            if y < 1900 || y > currentYear + 1 {
                errors.append("Yıl 1900 ile \(currentYear + 1) arasında olmalıdır.")
            }
        }

        if let odo = odometer, odo < 0 {
            errors.append("Km sıfırdan küçük olamaz.")
        }

        return errors
    }

    private func applyChanges() {
        vehicle.plate = plate.trimmingCharacters(in: .whitespaces).uppercased()
        vehicle.brand = brand.trimmingCharacters(in: .whitespaces)
        vehicle.model = model.trimmingCharacters(in: .whitespaces)
        vehicle.nickname = nickname.trimmingCharacters(in: .whitespaces)
        vehicle.year = year
        vehicle.currentOdometer = odometer ?? vehicle.currentOdometer
        vehicle.fuelType = fuelType
        vehicle.transmissionType = transmissionType
        vehicle.usageType = usageType
        vehicle.purchaseDate = purchaseDate
        vehicle.purchaseOdometer = purchaseOdometer
        vehicle.purchasePrice = purchasePrice
        vehicle.notes = notes

        try? modelContext.save()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Preview
#Preview("Düzenleme") {
    VehicleEditView(vehicle: MockDataProvider.previewVehicle())
}
