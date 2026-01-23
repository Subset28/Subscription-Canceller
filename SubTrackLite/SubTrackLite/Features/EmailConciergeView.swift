//
//  EmailConciergeView.swift
//  SubTrackLite
//
//  Generates a legal cancellation email template for services that require manual contact.
//  Part of the "Smart Concierge" feature set.
//

import SwiftUI

struct EmailConciergeView: View {
    @Environment(\.dismiss) private var dismiss
    
    let serviceName: String
    
    @State private var accountNumber = ""
    @State private var emailBody = ""
    @State private var useLegalTone = true
    
    private var generatedEmail: String {

        let accountLine = accountNumber.isEmpty ? "" : "Account/Member Number: \(accountNumber)\n"
        
        if useLegalTone {
            return """
            To whom it may concern,
            
            I am writing to formally request the immediate cancellation of my subscription to \(serviceName).
            
            \(accountLine)
            Please process this cancellation immediately and confirm via email when it has been completed. Please also confirm that no further charges will be applied to my payment method.
            
            If my subscription is under a minimum term contract, please inform me of the end date and ensure this cancellation is processed effectively on that date.
            
            Thank you,
            [Your Name]
            """
        } else {
            return """
            Hi Support,
            
            I'd like to cancel my subscription to \(serviceName).
            
            \(accountLine)
            Can you please cancel this for me and let me know when it's done? I would also like to confirm there will be no future charges.
            
            Thanks,
            [Your Name]
            """
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Account Number (Optional)", text: $accountNumber)
                } header: {
                    Text("Details")
                }
                
                Section {
                    Toggle("Use Formal Legal Tone", isOn: $useLegalTone)
                } header: {
                    Text("Tone")
                }
                
                Section {
                    TextEditor(text: .constant(generatedEmail))
                        .frame(height: 300)
                        .font(.body)
                } header: {
                    Text("Generated Email")
                }
                
                Section {
                    Button {
                        UIPasteboard.general.string = generatedEmail
                    } label: {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                    }
                    
                    ShareLink(item: generatedEmail, subject: Text("Cancellation Request - \(serviceName)")) {
                        Label("Share / Send Email", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle("Email Concierge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
