//
//  SubscriptionTests.swift
//  SubTrackLiteTests
//
//  Unit tests for Subscription model and calculations
//

import XCTest
import SwiftData
@testable import SubTrackLite

final class SubscriptionTests: XCTestCase {
    
    // MARK: - Renewal Date Calculations
    
    func testWeeklyRenewalDateCalculation() {
        let startDate = Date()
        let period = BillingPeriod.weekly
        let nextDate = period.nextRenewalDate(from: startDate)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: nextDate)
        
        XCTAssertEqual(components.day, 7, "Weekly renewal should be 7 days later")
    }
    
    func testMonthlyRenewalDateCalculation() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let period = BillingPeriod.monthly
        let nextDate = period.nextRenewalDate(from: startDate)
        
        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 2, day: 15))!
        
        XCTAssertEqual(
            calendar.compare(nextDate, to: expectedDate, toGranularity: .day),
            .orderedSame,
            "Monthly renewal should be one month later"
        )
    }
    
    func testQuarterlyRenewalDateCalculation() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let period = BillingPeriod.quarterly
        let nextDate = period.nextRenewalDate(from: startDate)
        
        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 4, day: 1))!
        
        XCTAssertEqual(
            calendar.compare(nextDate, to: expectedDate, toGranularity: .day),
            .orderedSame,
            "Quarterly renewal should be 3 months later"
        )
    }
    
    func testYearlyRenewalDateCalculation() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15))!
        let period = BillingPeriod.yearly
        let nextDate = period.nextRenewalDate(from: startDate)
        
        let expectedDate = calendar.date(from: DateComponents(year: 2025, month: 3, day: 15))!
        
        XCTAssertEqual(
            calendar.compare(nextDate, to: expectedDate, toGranularity: .day),
            .orderedSame,
            "Yearly renewal should be one year later"
        )
    }
    
    func testCustomDaysRenewalDateCalculation() {
        let startDate = Date()
        let customDays = 45
        let period = BillingPeriod.custom(days: customDays)
        let nextDate = period.nextRenewalDate(from: startDate)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: nextDate)
        
        XCTAssertEqual(components.day, customDays, "Custom renewal should be \(customDays) days later")
    }
    
    // MARK: - Cost Calculations
    
    func testWeeklyMonthlyCostCalculation() {
        let subscription = Subscription(
            name: "Test Weekly",
            price: 10.0,
            billingPeriod: .weekly,
            nextRenewalDate: Date()
        )
        
        let expectedMonthlyCost = Decimal(10.0) * (Decimal(52) / Decimal(12))
        XCTAssertEqual(
            subscription.estimatedMonthlyCost,
            expectedMonthlyCost,
            accuracy: 0.01,
            "Weekly subscription monthly cost should be price * (52/12)"
        )
    }
    
    func testMonthlyMonthlyCostCalculation() {
        let subscription = Subscription(
            name: "Test Monthly",
            price: 15.99,
            billingPeriod: .monthly,
            nextRenewalDate: Date()
        )
        
        XCTAssertEqual(
            subscription.estimatedMonthlyCost,
            Decimal(15.99),
            "Monthly subscription monthly cost should equal price"
        )
    }
    
    func testQuarterlyMonthlyCostCalculation() {
        let subscription = Subscription(
            name: "Test Quarterly",
            price: 30.0,
            billingPeriod: .quarterly,
            nextRenewalDate: Date()
        )
        
        let expectedMonthlyCost = Decimal(30.0) / Decimal(3)
        XCTAssertEqual(
            subscription.estimatedMonthlyCost,
            expectedMonthlyCost,
            accuracy: 0.01,
            "Quarterly subscription monthly cost should be price / 3"
        )
    }
    
    func testYearlyMonthlyCostCalculation() {
        let subscription = Subscription(
            name: "Test Yearly",
            price: 120.0,
            billingPeriod: .yearly,
            nextRenewalDate: Date()
        )
        
        let expectedMonthlyCost = Decimal(120.0) / Decimal(12)
        XCTAssertEqual(
            subscription.estimatedMonthlyCost,
            expectedMonthlyCost,
            "Yearly subscription monthly cost should be price / 12"
        )
    }
    
    func testYearlyCostCalculation() {
        let subscription = Subscription(
            name: "Test",
            price: 9.99,
            billingPeriod: .monthly,
            nextRenewalDate: Date()
        )
        
        let expectedYearlyCost = subscription.estimatedMonthlyCost * 12
        XCTAssertEqual(
            subscription.estimatedYearlyCost,
            expectedYearlyCost,
            "Yearly cost should be monthly cost * 12"
        )
    }
    
    // MARK: - Days Until Renewal
    
    func testDaysUntilRenewal() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.0,
            billingPeriod: .monthly,
            nextRenewalDate: futureDate
        )
        
        XCTAssertEqual(subscription.daysUntilRenewal, 5, "Should calculate correct days until renewal")
    }
    
    func testIsRenewingWithinSevenDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let subscription = Subscription(
            name: "Test",
            price: 10.0,
            billingPeriod: .monthly,
            nextRenewalDate: futureDate
        )
        
        XCTAssertTrue(subscription.isRenewingWithin(days: 7), "Should be renewing within 7 days")
        XCTAssertFalse(subscription.isRenewingWithin(days: 3), "Should not be renewing within 3 days")
    }
    
    // MARK: - Upcoming Renewal Dates
    
    func testUpcomingRenewalDates() {
        let startDate = Date()
        let subscription = Subscription(
            name: "Test",
            price: 10.0,
            billingPeriod: .monthly,
            nextRenewalDate: startDate
        )
        
        let upcomingDates = subscription.upcomingRenewalDates(count: 3)
        
        XCTAssertEqual(upcomingDates.count, 3, "Should return 3 upcoming dates")
        XCTAssertEqual(upcomingDates[0], startDate, "First date should be the next renewal date")
        
        let calendar = Calendar.current
        for i in 1..<upcomingDates.count {
            let expectedDate = BillingPeriod.monthly.nextRenewalDate(from: upcomingDates[i-1])
            XCTAssertEqual(
                calendar.compare(upcomingDates[i], to: expectedDate, toGranularity: .day),
                .orderedSame,
                "Subsequent dates should be one billing period apart"
            )
        }
    }
    
    // MARK: - Notification Identifier
    
    func testNotificationIdentifier() {
        let uuid = UUID()
        let subscription = Subscription(
            id: uuid,
            name: "Test",
            price: 10.0,
            billingPeriod: .monthly,
            nextRenewalDate: Date()
        )
        
        let expectedIdentifier = "subscription-\(uuid.uuidString)"
        XCTAssertEqual(subscription.notificationIdentifier, expectedIdentifier, "Notification identifier should be deterministic")
    }
}

// MARK: - Currency Formatter Tests

final class CurrencyFormatterTests: XCTestCase {
    var formatter: CurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CurrencyFormatter()
    }
    
    func testFormatDecimal() {
        let amount = Decimal(15.99)
        let formatted = formatter.format(amount, currencyCode: "USD")
        
        XCTAssertTrue(formatted.contains("15.99"), "Should format decimal with correct amount")
    }
    
    func testFormatDouble() {
        let amount = 9.99
        let formatted = formatter.format(amount, currencyCode: "USD")
        
        XCTAssertTrue(formatted.contains("9.99"), "Should format double with correct amount")
    }
    
    func testFormatTotalMonthly() {
        let subscriptions = [
            Subscription(name: "Sub1", price: 10.0, billingPeriod: .monthly, nextRenewalDate: Date()),
            Subscription(name: "Sub2", price: 15.0, billingPeriod: .monthly, nextRenewalDate: Date())
        ]
        
        let formatted = formatter.formatTotal(subscriptions, period: .monthly)
        XCTAssertTrue(formatted.contains("25"), "Should calculate total monthly cost correctly")
    }
    
    func testFormatTotalYearly() {
        let subscriptions = [
            Subscription(name: "Sub1", price: 10.0, billingPeriod: .monthly, nextRenewalDate: Date())
        ]
        
        let formatted = formatter.formatTotal(subscriptions, period: .yearly)
        XCTAssertTrue(formatted.contains("120"), "Should calculate total yearly cost correctly")
    }
    
    func testFormatEmptySubscriptions() {
        let formatted = formatter.formatTotal([], period: .monthly)
        XCTAssertTrue(formatted.contains("0"), "Should return 0 for empty subscriptions")
    }
}

// MARK: - Billing Period Tests

final class BillingPeriodTests: XCTestCase {
    
    func testDisplayNames() {
        XCTAssertEqual(BillingPeriod.weekly.displayName, "Weekly")
        XCTAssertEqual(BillingPeriod.monthly.displayName, "Monthly")
        XCTAssertEqual(BillingPeriod.quarterly.displayName, "Quarterly")
        XCTAssertEqual(BillingPeriod.yearly.displayName, "Yearly")
        XCTAssertEqual(BillingPeriod.custom(days: 45).displayName, "45 Days")
    }
    
    func testMonthlyMultipliers() {
        XCTAssertEqual(BillingPeriod.weekly.monthlyMultiplier, Decimal(52) / Decimal(12), accuracy: 0.01)
        XCTAssertEqual(BillingPeriod.monthly.monthlyMultiplier, 1)
        XCTAssertEqual(BillingPeriod.quarterly.monthlyMultiplier, Decimal(1) / Decimal(3), accuracy: 0.01)
        XCTAssertEqual(BillingPeriod.yearly.monthlyMultiplier, Decimal(1) / Decimal(12), accuracy: 0.01)
        XCTAssertEqual(BillingPeriod.custom(days: 30).monthlyMultiplier, 1, accuracy: 0.01)
    }
}

// Helper extension for Decimal comparison
extension XCTAssertEqual where T == Decimal {
    static func XCTAssertEqual(_ expression1: @autoclosure () throws -> Decimal,
                               _ expression2: @autoclosure () throws -> Decimal,
                               accuracy: Decimal,
                               _ message: @autoclosure () -> String = "",
                               file: StaticString = #filePath,
                               line: UInt = #line) {
        do {
            let value1 = try expression1()
            let value2 = try expression2()
            let difference = abs(value1 - value2)
            XCTAssertTrue(difference <= accuracy, message(), file: file, line: line)
        } catch {
            XCTFail("Threw error: \(error)", file: file, line: line)
        }
    }
}
