//
//  WaveView.swift
//  Apneue
//
//  Created by Saad Anis on 03/07/2025.
//

import SwiftUI
import CoreMotion

struct WaterView<Primary: View, Secondary: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let colors: [Color]
    let skyGradient: LinearGradient
    let offset: CGFloat
    
    let primaryContent: Primary
    let secondaryContent: Secondary?
    
    let initialPhases: [CGFloat] = [0.5, 2.0, 4.1, 5.8, 1.3, 3.7, 6.2, 0.9, 2.8, 5.0]
    let offsets: [CGFloat]
    let bobAmounts: [CGFloat] = [7, 8, 6, 9, 7.5, 8.2, 6.8, 9.1, 7.3, 8.7]
    let bobDurations: [Double] = [15.0, 17.5, 12.0, 18.0, 16.2, 14.8, 19.0, 13.5, 17.0, 15.5]
    let phaseSpeeds: [Double] = [4.2, 3.8, 5.0, 4.5, 4.7, 3.9, 5.2, 4.0, 4.8, 3.6]
    
    static func interpolateColors(colorA: Color, colorB: Color, steps: Int) -> [Color] {
        let uiColorA = UIColor(colorA)
        let uiColorB = UIColor(colorB)
        
        print(uiColorA, uiColorB)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColorA.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColorB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        print(r1, g1, b1, a1)
        print(r2, g2, b2, a2)
        
//        print((0...steps+1).map { i in
//            let t = CGFloat(i) / CGFloat(steps + 1)
//            return Double(r1 + (r2 - r1) * t)
//        })
        
        return (0...steps+1).map { i in
            let t = CGFloat(i) / CGFloat(steps + 1)
            return Color(
                red: Double(r1 + (r2 - r1) * t),
                green: Double(g1 + (g2 - g1) * t),
                blue: Double(b1 + (b2 - b1) * t),
                opacity: Double(a1 + (a2 - a1) * t)
            )
        }
    }
    
    init(
        waveColors: [Color] = K.colorThemes[0].waveColors,
        skyColors: [Color] = K.colorThemes[0].backgroundColors,
        offset: CGFloat = K.initialOffset,
        spacing: CGFloat = K.initialSpacing,
        numberOfWaves: Int = 4,
        @ViewBuilder primaryContent: () -> Primary,
        @ViewBuilder secondaryContent: () -> Secondary? = { nil }
    ) {
        
        self.primaryContent = primaryContent()
        self.secondaryContent = secondaryContent()
        
        var numberOfWaves = max(3, min(numberOfWaves, 10))
        
        numberOfWaves = max(numberOfWaves, min(waveColors.count, 10))
//
//        if numberOfWaves < waveColors.count {
//            numberOfWaves = waveColors.count
//        }
        
        let stepSize = (2 * spacing) / Double(numberOfWaves - 1)
        self.offsets = (0..<numberOfWaves).map {
            CGFloat(-spacing + CGFloat($0) * stepSize)
        }
        
        if waveColors.count == 1 {
            self.colors = Array(repeating: waveColors[0], count: numberOfWaves)
        } else if waveColors.count == 2 {
            self.colors = WaterView.interpolateColors(
                colorA: waveColors[0],
                colorB: waveColors[1],
                steps: numberOfWaves-2
            )
        } else {
            self.colors = waveColors
        }
        
        self.skyGradient = LinearGradient(gradient: Gradient(colors: skyColors), startPoint: .top, endPoint: .center)
        
        self.offset = offset
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let midWave = colors.count / 2
            ZStack {
                ForEach(colors.enumerated(), id: \.offset) { index, color in
                    let amplitude = CGFloat(10 * Double(index + 1) / Double(colors.count))
                    let frequency = 2 * Double(colors.count - index) / Double(colors.count)
                    let phase = initialPhases[index] + CGFloat(time / phaseSpeeds[index] * .pi * 2)
                    let bobbing = bobAmounts[index] * CGFloat(sin(time / bobDurations[index] * .pi * 2))
                    
//                    if index == colors.count - 1 {
//                        content
//                            .offset(y: initialOffset + offsets[index] + bobbing - 10)
//                    }
                    
                    if index == midWave {
                        
                        let tilt1 = sin(phase - 0.5) * 0.02
                        let tilt2 = sin(phase - 0.25) * 0.03
                        
                        VStack {
                            primaryContent
                                .rotationEffect(.radians(-tilt1))
                                .offset(y: max(bobbing, offset + offsets[index] + bobbing) + 15)
                            if let secondary = secondaryContent {
                                secondary
                                    .rotationEffect(.radians(-tilt2))
                                    .offset(y: max(bobbing*1.1, offset + offsets[index] + bobbing*1.1) + 20)
                            }
                        }
         
                        
                    }
                    
                    let colorInScheme = colorScheme == .light ? color : color.darker(by: 50)
                    
                    WaveView(amplitude: amplitude, frequency: frequency, phase: phase)
                        .fill(
                            LinearGradient(
                                colors: index >= midWave ? [
                                    colorInScheme.opacity(0.3),
                                    colorInScheme.darker(by: 20)
                                ] : [
                                    colorInScheme.opacity(0.3),
                                    colorInScheme,
                                    colorInScheme
                                ],
                                startPoint: .center, endPoint: .bottom
                            )
                        )
                        .stroke(
                            RadialGradient(
                                colors: [.white, color.opacity(Double(index + 1) / Double(colors.count) * 0.9)], center: .topLeading, startRadius: 700, endRadius: 1000
                            ),
                            lineWidth: 1
                        )
                        .offset(y: offset + offsets[index] + bobbing)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 2)
                }
            }
            .ignoresSafeArea()
            .background(skyGradient.opacity(0.2))
        }
        .drawingGroup(opaque: false, colorMode: .extendedLinear)
    }
}

struct WaveView: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        let extendedWidth = rect.width * 3 // 3 times wider than the visible rect
        
        path.move(to: CGPoint(x: -extendedWidth, y: midHeight))
        
        for x in stride(from: -extendedWidth, through: extendedWidth, by: 1) {
            let relativeX = x / rect.width
            let y = midHeight + sin(relativeX * frequency * .pi * 2 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: extendedWidth, y: rect.height))
        path.addLine(to: CGPoint(x: -extendedWidth, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    WaterView() {
        Text("primary")
            .font(.system(size: 100))
            .fontWeight(.bold)
            .foregroundStyle(.white)
        
    } secondaryContent: {
        Text("secondary")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
    }
}
