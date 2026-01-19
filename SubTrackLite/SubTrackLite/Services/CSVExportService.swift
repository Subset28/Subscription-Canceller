//
//  CSVExportService.swift
//  SubTrackLite
//
//  Handles CSV export of subscription data
//

import Foundation

class CSVExportService {
    
    func exportToCSV(subscriptions: [Subscription]) -> URL? {
        var csvString = "Name,Price,Currency,Billing Period,Next Renewal Date,Reminder Days,Reminders Enabled,Notes\n"
        
        let dateFormatter = ISO8601DateFormatter()
        
        for subscription in subscriptions {
            let name = escapeCSV(subscription.name)
            let price = "\(subscription.price)"
            let currency = subscription.currencyCode
            let billingPeriod = escapeCSV(subscription.billingPeriod.displayName)
            let renewalDate = dateFormatter.string(from: subscription.nextRenewalDate)
            let reminderDays = "\(subscription.reminderLeadTimeDays)"
            let remindersEnabled = subscription.remindersEnabled ? "Yes" : "No"
            let notes = escapeCSV(subscription.notes ?? "")
            
            csvString += "\(name),\(price),\(currency),\(billingPeriod),\(renewalDate),\(reminderDays),\(remindersEnabled),\(notes)\n"
        }
        
        // Write to temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "SubTrackLite_Export_\(Date().timeIntervalSince1970).csv"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
    
    private func escapeCSV(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
    
    // Basic CSV import (stub for v1 - can be enhanced)
    func importFromCSV(url: URL) -> [Subscription]? {
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines)
            
            guard lines.count > 1 else { return [] }
            
            var subscriptions: [Subscription] = []
            let dateFormatter = ISO8601DateFormatter()
            
            // Skip header
            for i in 1..<lines.count {
                let line = lines[i].trimmingCharacters(in: .whitespaces)
                guard !line.isEmpty else { continue }
                
                let fields = parseCSVLine(line)
                guard fields.count >= 7 else { continue }
                
                // Parse fields
                let name = fields[0]
                guard let price = Decimal(string: fields[1]) else { continue }
                let currencyCode = fields[2]
                
                // Parse billing period (simplified)
                let billingPeriod: BillingPeriod
                switch fields[3].lowercased() {
                case "weekly": billingPeriod = .weekly
                case "monthly": billingPeriod = .monthly
                case "quarterly": billingPeriod = .quarterly
                case "yearly": billingPeriod = .yearly
                default: billingPeriod = .monthly
                }
                
                guard let renewalDate = dateFormatter.date(from: fields[4]) else { continue }
                let reminderDays = Int(fields[5]) ?? 3
                let remindersEnabled = fields[6].lowercased() == "yes"
                let notes = fields.count > 7 ? fields[7] : nil
                
                let subscription = Subscription(
                    name: name,
                    price: price,
                    currencyCode: currencyCode,
                    billingPeriod: billingPeriod,
                    nextRenewalDate: renewalDate,
                    reminderLeadTimeDays: reminderDays,
                    remindersEnabled: remindersEnabled,
                    notes: notes
                )
                
                subscriptions.append(subscription)
            }
            
            return subscriptions
        } catch {
            print("Failed to import CSV: \(error)")
            return nil
        }
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        fields.append(currentField.trimmingCharacters(in: .whitespaces))
        return fields
    }
}
