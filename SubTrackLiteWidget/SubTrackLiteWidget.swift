//
//  SubTrackLiteWidget.swift
//  SubTrackLiteWidget
//
//  Widget showing upcoming renewals
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry
struct UpcomingRenewalsEntry: TimelineEntry {
    let date: Date
    let subscriptions: [WidgetSubscription]
}

// MARK: - Widget Subscription Model
struct WidgetSubscription: Identifiable {
    let id: UUID
    let name: String
    let renewalDate: Date
    let daysUntil: Int
    let price: String
}

// MARK: - Timeline Provider
struct UpcomingRenewalsProvider: TimelineProvider {
    typealias Entry = UpcomingRenewalsEntry
    
    func placeholder(in context: Context) -> UpcomingRenewalsEntry {
        UpcomingRenewalsEntry(
            date: Date(),
            subscriptions: [
                WidgetSubscription(
                    id: UUID(),
                    name: "Netflix",
                    renewalDate: Date(),
                    daysUntil: 3,
                    price: "$15.99"
                )
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (UpcomingRenewalsEntry) -> Void) {
        let entry = UpcomingRenewalsEntry(
            date: Date(),
            subscriptions: fetchUpcomingSubscriptions()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingRenewalsEntry>) -> Void) {
        let currentDate = Date()
        let subscriptions = fetchUpcomingSubscriptions()
        
        let entry = UpcomingRenewalsEntry(
            date: currentDate,
            subscriptions: subscriptions
        )
        
        // Refresh every 6 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func fetchUpcomingSubscriptions() -> [WidgetSubscription] {
        // Access SwiftData from widget
        do {
            let schema = Schema([Subscription.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<Subscription>(
                sortBy: [SortDescriptor(\Subscription.nextRenewalDate)]
            )
            let subscriptions = try context.fetch(descriptor)
            
            let formatter = CurrencyFormatter()
            
            return subscriptions
                .filter { $0.isRenewingWithin(days: 30) }
                .prefix(3)
                .map { sub in
                    WidgetSubscription(
                        id: sub.id,
                        name: sub.name,
                        renewalDate: sub.nextRenewalDate,
                        daysUntil: sub.daysUntilRenewal,
                        price: formatter.format(sub.price, currencyCode: sub.currencyCode)
                    )
                }
        } catch {
            print("Widget failed to fetch subscriptions: \(error)")
            return []
        }
    }
}

// MARK: - Widget View
struct UpcomingRenewalsWidgetView: View {
    let entry: UpcomingRenewalsEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.headline)
                Text("Upcoming Renewals")
                    .font(.headline)
                Spacer()
            }
            .foregroundStyle(.secondary)
            
            if entry.subscriptions.isEmpty {
                Spacer()
                Text("No upcoming renewals")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(entry.subscriptions) { subscription in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(subscription.name)
                                .font(.subheadline.bold())
                            Text(subscription.price)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(subscription.renewalDate, style: .date)
                                .font(.caption.bold())
                            Text(daysText(subscription.daysUntil))
                                .font(.caption2)
                                .foregroundStyle(daysColor(subscription.daysUntil))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func daysText(_ days: Int) -> String {
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }
    
    private func daysColor(_ days: Int) -> Color {
        if days <= 3 { return .red }
        if days <= 7 { return .orange }
        return .secondary
    }
}

// MARK: - Widget Configuration
struct UpcomingRenewalsWidget: Widget {
    let kind: String = "UpcomingRenewalsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingRenewalsProvider()) { entry in
            UpcomingRenewalsWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Renewals")
        .description("See your upcoming subscription renewals at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle
@main
struct SubTrackLiteWidgets: WidgetBundle {
    var body: some Widget {
        UpcomingRenewalsWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    UpcomingRenewalsWidget()
} timeline: {
    UpcomingRenewalsEntry(
        date: Date(),
        subscriptions: [
            WidgetSubscription(id: UUID(), name: "Netflix", renewalDate: Date(), daysUntil: 2, price: "$15.99"),
            WidgetSubscription(id: UUID(), name: "Spotify", renewalDate: Date(), daysUntil: 5, price: "$9.99"),
            WidgetSubscription(id: UUID(), name: "iCloud", renewalDate: Date(), daysUntil: 10, price: "$2.99")
        ]
    )
}
