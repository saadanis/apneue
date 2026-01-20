//
//  AboutView.swift
//  Apneue
//
//  Created by Saad Anis on 17/07/2025.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    
    @Environment(\.openURL) var openURL

    var version: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
    
    var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }
    
    @State var themeIndex: Int
    
    var body: some View {
        ThemedList(themeIndex: themeIndex) {
            Section {
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        Image(
                            UIApplication.shared.alternateIconName ?? "ApneueIcon"
                        )
                            .resizable()
                            .frame(width: 70, height: 70)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                        VStack(alignment: .leading) {
                            Text("Apneue")
                                .font(.headline)
                            Text("Version \(version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("by Saad Anis")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Apneue is a free app for static-apnea training, with a breath-hold timer, guided box breathing, and CO₂ and O₂ table sessions.")
                        .padding(.top, 4)
                }
            }
            .listRowSeparator(.hidden)
            Section {
                Text("Apneue is developed and maintained by one person: me. All feedback, complaints, suggestions, love, and criticism are welcome through the channels listed below.")
                LabelAndLinkView(labelText: "Website", labelImage: "globe", bodyText: "saadanis.com", linkText: "https://saadanis.com", themeIndex: themeIndex)
                LabelAndLinkView(labelText: "Email", labelImage: "envelope", bodyText: "me@saadanis.com", linkText: "mailto:me@saadanis.com", themeIndex: themeIndex)
                LabelAndLinkView(labelText: "Mastodon", labelImage: "bubbles.and.sparkles", bodyText: "@saadanis", linkText: "https://mastodon.social/@saadanis", themeIndex: themeIndex)
            } footer: {
                HStack {
                    Spacer()
                    Text("Copyright © \(currentYear) Saad Anis\nAll rights reserved.")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 25)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LabelAndLinkView: View {
    
    let labelText: String
    let labelImage: String
    let bodyText: String
    let linkText: String
    let themeIndex: Int
    
    var body: some View {
        HStack {
            ThemedLabel(labelText, systemImage: labelImage, themeIndex: themeIndex)
            Spacer()
            Link(bodyText, destination: URL(string: linkText)!)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView(themeIndex: 0)
    }
}
