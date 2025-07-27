//
//  AboutView.swift
//  Apneue
//
//  Created by Saad Anis on 17/07/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("Saad Anis was here, July 17, 2025.")
            } footer: {
                HStack(alignment: .firstTextBaseline) {
                    Text("⋆˙⟡ made with lots of")
                    Image(systemName: "drop.halffull")
                    Text("on planet")
                    Image(systemName: "globe.asia.australia.fill")
                    Text("✧˖°.")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .font(.footnote)
                .listRowBackground(Color.clear)
            }
        }
        .fontDesign(.rounded)
        .navigationTitle("About")
        .scrollContentBackground(.hidden)
        .background(Color.accentColor.opacity(0.08))
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
