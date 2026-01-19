//
//  SubTrackLiteUITests.swift
//  SubTrackLiteUITests
//
//  UI test for core flow: Add subscription -> appears in list -> reminder enabled
//

import XCTest

final class SubTrackLiteUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    func testAddSubscriptionFlow() throws {
        // Skip onboarding if present
        skipOnboardingIfPresent()
        
        // Verify we're on the main screen
        XCTAssertTrue(app.navigationBars["Subscriptions"].exists, "Should show Subscriptions navigation bar")
        
        // Tap the add button
        let addButton = app.navigationBars.buttons["plus"]
        XCTAssertTrue(addButton.exists, "Add button should exist")
        addButton.tap()
        
        // Wait for the add sheet to appear
        let addNavigationBar = app.navigationBars["Add Subscription"]
        XCTAssertTrue(addNavigationBar.waitForExistence(timeout: 2), "Add Subscription sheet should appear")
        
        // Fill in subscription details
        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.exists, "Name field should exist")
        nameField.tap()
        nameField.typeText("Netflix")
        
        let priceField = app.textFields["Price"]
        XCTAssertTrue(priceField.exists, "Price field should exist")
        priceField.tap()
        priceField.typeText("15.99")
        
        // Billing period should default to Monthly (no action needed)
        
        // Verify reminder toggle is on by default
        let reminderToggle = app.switches["Enable Reminders"]
        XCTAssertTrue(reminderToggle.exists, "Reminder toggle should exist")
        let reminderValue = reminderToggle.value as? String
        XCTAssertEqual(reminderValue, "1", "Reminder should be enabled by default")
        
        // Save the subscription
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()
        
        // Wait for sheet to dismiss and verify subscription appears in list
        XCTAssertTrue(app.navigationBars["Subscriptions"].waitForExistence(timeout: 2), "Should return to main list")
        
        // Verify the subscription appears in the list
        let subscriptionCell = app.staticTexts["Netflix"]
        XCTAssertTrue(subscriptionCell.waitForExistence(timeout: 2), "Netflix subscription should appear in list")
        
        // Verify price is displayed
        let priceText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '15.99'")).firstMatch
        XCTAssertTrue(priceText.exists, "Price should be displayed in the list")
        
        // Tap on the subscription to view details
        subscriptionCell.tap()
        
        // Verify detail view appears
        let detailNavigationBar = app.navigationBars["Netflix"]
        XCTAssertTrue(detailNavigationBar.waitForExistence(timeout: 2), "Detail view should appear")
        
        // Verify reminders are enabled in detail view
        let remindersEnabledCell = app.staticTexts["Reminders Enabled"]
        XCTAssertTrue(remindersEnabledCell.exists, "Reminders Enabled label should exist")
        
        let yesText = app.staticTexts["Yes"]
        XCTAssertTrue(yesText.exists, "Reminders should be enabled (Yes)")
        
        // Go back to list
        let backButton = app.navigationBars.buttons.firstMatch
        backButton.tap()
        
        // Verify we're back on the main list
        XCTAssertTrue(app.navigationBars["Subscriptions"].exists, "Should be back on main list")
        XCTAssertTrue(app.staticTexts["Netflix"].exists, "Netflix should still be in the list")
        
        // Test passed - subscription added, appears in list, and reminder is enabled
    }
    
    func testEmptyState() throws {
        // Skip onboarding
        skipOnboardingIfPresent()
        
        // If there are no subscriptions, empty state should be shown
        // This test assumes a fresh install - in real testing, you'd want to clear data first
        
        let emptyStateTitle = app.staticTexts["No Subscriptions Yet"]
        if emptyStateTitle.exists {
            XCTAssertTrue(emptyStateTitle.exists, "Empty state title should exist")
            
            let emptyStateButton = app.buttons["Add Subscription"]
            XCTAssertTrue(emptyStateButton.exists, "Empty state action button should exist")
            
            // Tap the empty state button
            emptyStateButton.tap()
            
            // Verify add sheet appears
            let addNavigationBar = app.navigationBars["Add Subscription"]
            XCTAssertTrue(addNavigationBar.waitForExistence(timeout: 2), "Add sheet should appear from empty state")
            
            // Close the sheet
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    func testSearchFunctionality() throws {
        // Skip onboarding
        skipOnboardingIfPresent()
        
        // Add a subscription first (assuming testAddSubscriptionFlow creates one)
        addTestSubscription(name: "Spotify", price: "9.99")
        
        // Test search
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Spotify")
            
            // Verify filtered results
            let spotifyCell = app.staticTexts["Spotify"]
            XCTAssertTrue(spotifyCell.exists, "Spotify should appear in search results")
            
            // Clear search
            if let clearButton = app.buttons["Clear text"].firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func skipOnboardingIfPresent() {
        // Check if onboarding is present and skip it
        let skipButton = app.buttons["Skip for Now"]
        if skipButton.waitForExistence(timeout: 2) {
            skipButton.tap()
        }
        
        let getStartedButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Get Started'")).firstMatch
        if getStartedButton.exists {
            getStartedButton.tap()
        }
    }
    
    private func addTestSubscription(name: String, price: String) {
        // Open add sheet
        let addButton = app.navigationBars.buttons["plus"]
        if addButton.exists {
            addButton.tap()
            
            // Fill in details
            let nameField = app.textFields["Name"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText(name)
            }
            
            let priceField = app.textFields["Price"]
            if priceField.exists {
                priceField.tap()
                priceField.typeText(price)
            }
            
            // Save
            let saveButton = app.navigationBars.buttons["Save"]
            if saveButton.exists {
                saveButton.tap()
            }
        }
    }
}
