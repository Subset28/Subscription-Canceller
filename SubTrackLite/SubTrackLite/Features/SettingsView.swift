//
//  SettingsView.swift
//  SubTrackLite
//
//  App settings including notifications, export, and about info
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var container: DependencyContainer
    @Query private var allSubscriptions: [Subscription]
    
    @AppStorage("defaultReminderDays") private var defaultReminderDays = 3
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingDebugView = false
    @State private var showingPaywall = false
    @State private var exportFileURL: URL?
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        if container.entitlementManager.canUseNotifications {
                            Text(notificationStatusText)
                                .foregroundStyle(notificationStatusColor)
                        } else {
                            Text("Locked")
                                .foregroundStyle(DesignSystem.Colors.textTertiary)
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .contentShape(Rectangle()) // Make entire row tappable
                    .onTapGesture {
                        if !container.entitlementManager.canUseNotifications {
                            showingPaywall = true
                        }
                    }
                    
                    if container.entitlementManager.canUseNotifications {
                        if container.notificationScheduler.authorizationStatus != .authorized {
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        
                        Picker("Default Reminder", selection: $defaultReminderDays) {
                            Text("1 day before").tag(1)
                            Text("3 days before").tag(3)
                            Text("7 days before").tag(7)
                            Text("14 days before").tag(14)
                        }
                    }
                } header: {
                    Text("Notifications")
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                } footer: {
                    Text(container.entitlementManager.canUseNotifications ? "Choose the default reminder timing for new subscriptions." : "Upgrade to unlock renewal notifications.")
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
                .listRowBackground(DesignSystem.Colors.cardBackground)
                
                // Data Management Section
                Section {
                    Button {
                        if container.entitlementManager.canExportData {
                            exportData()
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        HStack {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                            Spacer()
                            if !container.entitlementManager.canExportData {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                    .disabled(allSubscriptions.isEmpty)
                    
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Import CSV", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Data Management")
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                } footer: {
                    Text(container.entitlementManager.canExportData ? "Export your subscription data to CSV or import from a previous export." : "Upgrade to export your data.")
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
                .listRowBackground(DesignSystem.Colors.cardBackground)
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink("Privacy & Data") {
                        PrivacyView()
                    }
                    
                    #if DEBUG
                    Button {
                        showingDebugView = true
                    } label: {
                        Label("Debug Notifications", systemImage: "ladybug")
                    }
                    #endif
                } header: {
                    Text("About")
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                .listRowBackground(DesignSystem.Colors.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportFileURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingDebugView) {
                NotificationDebugView()
            }
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
        }
    }
    
    private var notificationStatusText: String {
        switch container.notificationScheduler.authorizationStatus {
        case .authorized: return "Enabled"
        case .denied: return "Disabled"
        case .notDetermined: return "Not Set"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private var notificationStatusColor: Color {
        switch container.notificationScheduler.authorizationStatus {
        case .authorized: return .green
        case .denied: return .red
        default: return .orange
        }
    }
    
    private func exportData() {
        exportFileURL = container.csvExportService.exportToCSV(subscriptions: allSubscriptions)
        if exportFileURL != nil {
            showingExportSheet = true
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            if let importedSubscriptions = container.csvExportService.importFromCSV(url: url) {
                for subscription in importedSubscriptions {
                    modelContext.insert(subscription)
                    container.notificationScheduler.scheduleNotification(for: subscription)
                }
                try? modelContext.save()
            }
        case .failure(let error):
            print("Import failed: \(error)")
        }
    }
}

// MARK: - Privacy View
// MARK: - Privacy View
struct PrivacyView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Privacy Matters")
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text("Unsub is designed with your privacy in mind:")
                        .font(DesignSystem.Typography.subheadline())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        PrivacyPoint(text: "No account required")
                        PrivacyPoint(text: "No data collection or tracking")
                        PrivacyPoint(text: "All data stored locally on your device")
                        PrivacyPoint(text: "No internet connection required")
                        PrivacyPoint(text: "No third-party analytics or SDKs")
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(DesignSystem.Colors.cardBackground)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Colors.success)
                .font(.body)
            Text(text)
                .font(DesignSystem.Typography.subheadline())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Debug View
struct NotificationDebugView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DependencyContainer
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Authorization")
                        Spacer()
                        Text("\(container.notificationScheduler.authorizationStatus.rawValue)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Scheduled")
                        Spacer()
                        Text("\(scheduledNotifications.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Status")
                }
                
                Section {
                    ForEach(scheduledNotifications, id: \.identifier) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.content.title)
                                .font(.headline)
                            Text(notification.content.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
                               let nextTriggerDate = trigger.nextTriggerDate() {
                                Text("Triggers: \(nextTriggerDate, style: .relative)")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Scheduled Notifications")
                }
            }
            .navigationTitle("Debug Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                scheduledNotifications = await container.notificationScheduler.getAllScheduledNotifications()
            }
        }
    }
}
