//
//  CircularProgressView.swift
//  Apneue
//
//  Created by Saad Anis on 26/06/2025.
//

import SwiftUI

struct CircularProgressView: View {
    
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.5),
                    lineWidth: lineWidth
                )
//                .glassEffect(.regular.tint(.clear), in: Circle().inset(by: -15))
                .foregroundStyle(.clear)
//                .glassEffect(.regular.tint(color.opacity(0.2)), in: Circle().stroke(
//                    lineWidth: lineWidth
//                ))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .foregroundStyle(.clear)
//                .glassEffect(.regular.tint(color), in: Circle().trim(from: 0, to: progress).stroke(style: StrokeStyle(
//                    lineWidth: lineWidth,
//                    lineCap: .round
//                )))
                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 1), value: progress)
        }
        .padding(lineWidth / 2)
    }
}

#Preview {
    CircularProgressView(progress: 0.3, lineWidth: 50, color: .accent)
//        .frame(width: 200, height: 200)
}
