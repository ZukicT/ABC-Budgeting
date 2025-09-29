import SwiftUI

// MARK: - Export Data View
struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportService = DataExportService()
    @State private var selectedExportType: ExportDataType = .transactions
    @State private var showingShareSheet = false
    @State private var exportFileURL: URL?
    
    // ViewModels for data access
    let transactionViewModel: TransactionViewModel
    let budgetViewModel: BudgetViewModel
    let loanViewModel: LoanViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.UI.Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                    Text("Export Data")
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Choose what data you want to export to CSV format")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .accessibilityLabel("Choose what data you want to export to CSV format")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Export Type Selection
                VStack(spacing: Constants.UI.Spacing.medium) {
                    ForEach(ExportDataType.allCases, id: \.self) { exportType in
                        ExportTypeCard(
                            exportType: exportType,
                            isSelected: selectedExportType == exportType,
                            action: {
                                selectedExportType = exportType
                            }
                        )
                    }
                }
                
                Spacer()
                
                // Export Button
                VStack(spacing: Constants.UI.Spacing.medium) {
                    if exportService.isExporting {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Exporting...")
                                .font(Constants.Typography.Body.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                        .padding()
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(Constants.UI.CornerRadius.secondary)
                    } else {
                        Button(action: {
                            Task {
                                await performExport()
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export \(selectedExportType.displayName)")
                            }
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Constants.UI.Padding.cardInternal)
                            .background(Constants.Colors.primaryBlue)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        }
                        .disabled(exportService.isExporting)
                    }
                    
                    if let error = exportService.exportError {
                        Text(error)
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(Constants.UI.Padding.screenMargin)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
            .onAppear {
                exportService.setViewModels(
                    transactionViewModel: transactionViewModel,
                    budgetViewModel: budgetViewModel,
                    loanViewModel: loanViewModel
                )
            }
            .sheet(isPresented: $showingShareSheet) {
                if let fileURL = exportFileURL {
                    ShareSheet(activityItems: [fileURL])
                }
            }
        }
    }
    
    private func performExport() async {
        exportFileURL = await exportService.createShareableFile(type: selectedExportType)
        if exportFileURL != nil {
            showingShareSheet = true
        }
    }
}

// MARK: - Export Type Card
private struct ExportTypeCard: View {
    let exportType: ExportDataType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.Spacing.medium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exportType.displayName)
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(.h3)
                    
                    Text(exportType.description)
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .accessibilityLabel(exportType.description)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.textSecondary)
                    .accessibilityLabel(isSelected ? "Selected" : "Not selected")
            }
            .padding(Constants.UI.Padding.cardInternal)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                    .fill(isSelected ? Constants.Colors.primaryBlue.opacity(0.1) : Constants.Colors.textPrimary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                            .stroke(isSelected ? Constants.Colors.primaryBlue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(exportType.displayName). \(exportType.description). \(isSelected ? "Selected" : "Not selected")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure for better iOS compatibility
        controller.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .postToTwitter,
            .postToFacebook
        ]
        
        // Ensure proper presentation on iPad
        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window.rootViewController?.view
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
