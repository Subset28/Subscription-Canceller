//
//  CalendarView.swift
//  SubTrackLite
//
//  Monthly view of subscription renewals.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @EnvironmentObject private var container: DependencyContainer
    @Query(sort: \Subscription.nextRenewalDate) private var subscriptions: [Subscription]
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showingPaywall = false
    
    // Calendar Layout
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // Computed Properties
    private var monthlyTotal: Decimal {
        subscriptions.reduce(0) { $0 + ($1.price * $1.billingPeriod.monthlyMultiplier) }
    }
    
    private var weeklyTotal: Decimal {
        monthlyTotal / 4.33 // Approx
    }
    
    private var yearlyTotal: Decimal {
        monthlyTotal * 12
    }
    
    private var subscriptionsForSelectedDate: [Subscription] {
        subscriptions.filter { sub in
            calendar.isDate(sub.nextRenewalDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                ZStack {
                    ScrollView {
                        VStack(spacing: DesignSystem.Layout.spacingL) {
                            
                            // 1. Cost Breakdown (Scrollable)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    CostStatCard(title: "Weekly", amount: weeklyTotal, container: container)
                                    CostStatCard(title: "Monthly", amount: monthlyTotal, container: container)
                                    CostStatCard(title: "Yearly", amount: yearlyTotal, container: container)
                                }
                                .padding(.horizontal, DesignSystem.Layout.spacingM)
                            }
                            .padding(.top, DesignSystem.Layout.spacingM)
                            
                            // 2. Calendar Component
                            VStack(spacing: DesignSystem.Layout.spacingM) {
                                // Month Navigation
                                HStack {
                                    Button {
                                        changeMonth(by: -1)
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(monthYearString(from: currentMonth))
                                        .font(DesignSystem.Typography.headline())
                                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        changeMonth(by: 1)
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Days Header
                                HStack {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .font(DesignSystem.Typography.caption())
                                            .foregroundStyle(DesignSystem.Colors.textTertiary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                // Days Grid
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(daysInMonth(), id: \.self) { date in
                                        if let date = date {
                                            DayCell(
                                                date: date,
                                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                                hasEvent: hasEvents(on: date),
                                                isToday: calendar.isDateInToday(date)
                                            )
                                            .onTapGesture {
                                                selectedDate = date
                                            }
                                        } else {
                                            Color.clear.frame(height: 30)
                                        }
                                    }
                                }
                            }
                            .padding(DesignSystem.Layout.spacingM)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                                    .fill(DesignSystem.Colors.cardBackground)
                                    .modifier(DesignSystem.Shadows.soft())
                            )
                            .padding(.horizontal, DesignSystem.Layout.spacingM)
                            
                            // 3. Selected Date Details
                            VStack(alignment: .leading, spacing: DesignSystem.Layout.spacingM) {
                                Text(dateDetailString(from: selectedDate))
                                    .font(DesignSystem.Typography.headline())
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    .padding(.horizontal, DesignSystem.Layout.spacingM)
                                
                                if subscriptionsForSelectedDate.isEmpty {
                                    Text("No renewals due.")
                                        .font(DesignSystem.Typography.body())
                                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                                        .padding(.horizontal, DesignSystem.Layout.spacingM)
                                } else {
                                    ForEach(subscriptionsForSelectedDate) { sub in
                                        SubscriptionCard(subscription: sub)
                                            .padding(.horizontal, DesignSystem.Layout.spacingM)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Bottom Padding
                            Color.clear.frame(height: 100)
                        }
                    }
                    .blur(radius: container.entitlementManager.isCalendarUnlocked ? 0 : 8)
                    .disabled(!container.entitlementManager.isCalendarUnlocked)
                    
                    // Premium Lock Overlay
                    if !container.entitlementManager.isCalendarUnlocked {
                        VStack(spacing: 20) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(DesignSystem.Colors.tint)
                            
                            Text("Upgrade to Calendar")
                                .font(DesignSystem.Typography.headline())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Visualize your renewal schedule and avoid surprise charges.")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button {
                                showingPaywall = true
                            } label: {
                                Text("Unlock Premium")
                                    .font(DesignSystem.Typography.headline())
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(DesignSystem.Colors.tint)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(DesignSystem.Colors.cardBackground)
                                .shadow(radius: 20)
                        )
                        .padding(32)
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dateDetailString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let monthStart = monthInterval.start
        
        // Calculate offset for first weekday
        let weekday = calendar.component(.weekday, from: monthStart)
        let offset = weekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasEvents(on date: Date) -> Bool {
        subscriptions.contains { sub in
            calendar.isDate(sub.nextRenewalDate, inSameDayAs: date)
        }
    }
}

struct CostStatCard: View {
    let title: String
    let amount: Decimal
    let container: DependencyContainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
            
            Text(container.currencyFormatter.format(amount, currencyCode: "USD"))
                .font(DesignSystem.Typography.headline())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .padding(12)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool
    let isToday: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(DesignSystem.Colors.textPrimary)
                    .frame(width: 32, height: 32)
            } else if isToday {
                Circle()
                    .stroke(DesignSystem.Colors.textTertiary, lineWidth: 1)
                    .frame(width: 32, height: 32)
            } else if hasEvent {
                // Highlight renewal days with a subtle background
                Circle()
                    .fill(DesignSystem.Colors.tint.opacity(0.2))
                    .frame(width: 32, height: 32)
            }
            
            Text("\(calendar.component(.day, from: date))")
                .font(DesignSystem.Typography.body())
                .foregroundStyle(isSelected ? DesignSystem.Colors.cardBackground : (hasEvent ? DesignSystem.Colors.tint : DesignSystem.Colors.textPrimary))
                .fontWeight(hasEvent ? .bold : .regular)
        }
        .frame(height: 32)
    }
}
