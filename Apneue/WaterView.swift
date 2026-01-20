//
//  WaveView.swift
//  Apneue
//
//  Created by Saad Anis on 03/07/2025.
//

import SwiftUI

struct WaterView<Primary: View, Secondary: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let colors: [Color]
    let skyGradient: LinearGradient
    let offset: CGFloat
    let isAnimated: Bool
    
    let primaryContent: Primary
    let secondaryContent: (Int) -> Secondary?
    
    let initialPhases: [CGFloat] = [0.5, 2.0, 4.1, 5.8, 1.3, 3.7, 6.2, 0.9, 2.8, 5.0]
    let offsets: [CGFloat]
    let bobAmounts: [CGFloat] = [7, 8, 6, 9, 7.5, 8.2, 6.8, 9.1, 7.3, 8.7]
    let bobDurations: [Double] = [15.0, 17.5, 12.0, 18.0, 16.2, 14.8, 19.0, 13.5, 17.0, 15.5]
    let phaseSpeeds: [Double] = [4.2, 3.8, 5.0, 4.5, 4.7, 3.9, 5.2, 4.0, 4.8, 3.6]
    
    static func interpolateColors(colorA: Color, colorB: Color, steps: Int) -> [Color] {
        let uiColorA = UIColor(colorA)
        let uiColorB = UIColor(colorB)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColorA.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColorB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
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
        skyColors: [Color] = K.colorThemes[0].backgroundColorsLight,
        offset: CGFloat = K.initialOffset,
        spacing: CGFloat = K.initialSpacing,
        numberOfWaves: Int = 4,
        isAnimated: Bool = true,
        @ViewBuilder primaryContent: () -> Primary,
        @ViewBuilder secondaryContent: @escaping (Int) -> Secondary? = { _ in nil }
    ) {
        
        self.isAnimated = isAnimated
        
        self.primaryContent = primaryContent()
        self.secondaryContent = secondaryContent
        
        var numberOfWaves = max(3, min(numberOfWaves, 10))
        
        numberOfWaves = max(numberOfWaves, min(waveColors.count, 10))
        
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
        
        self.skyGradient = LinearGradient(
            gradient: Gradient(colors: skyColors),
            startPoint: UnitPoint(x: 0.5, y: 0.0),
            endPoint: UnitPoint(x: 0.5, y: 0.6)
        )
        
        self.offset = offset
    }
    
    
    func waveParameters(index: Int, time: TimeInterval) -> (amplitude: CGFloat, frequency: CGFloat, phase: CGFloat, bobbing: CGFloat) {
        (
            CGFloat(10 * Double(index + 1) / Double(colors.count)),
            2 * Double(colors.count - index) / Double(colors.count),
            initialPhases[index] + CGFloat(time / phaseSpeeds[index] * .pi * 2),
            isAnimated ? bobAmounts[index] * CGFloat(sin(time / bobDurations[index] * .pi * 2)) : 0
        )
    }
    
    func waveShape(index: Int, time: TimeInterval) -> WaveView {
        let params = waveParameters(index: index, time: time)
        return WaveView(
            amplitude: params.amplitude,
            frequency: params.frequency,
            phase: params.phase
        )
    }
    
    func wave(index: Int, time: TimeInterval, midWave: Int) -> some View {
        let params = waveParameters(index: index, time: time)
        let color = colors[index]
        let colorInScheme = colorScheme == .light ? color : color.darker(by: 30)
        
        return waveShape(index: index, time: time)
            .fill(
                index < midWave
                ? LinearGradient(colors: [colorInScheme], startPoint: .top, endPoint: .bottom)
                : LinearGradient(
//                    colors: [colorInScheme.opacity(0.3), colorInScheme.opacity(0.8)],
                    colors: [colorInScheme, colorInScheme.darker(by: 10)],
                    startPoint: .center,
                    endPoint: UnitPoint(x: 0.5, y: 0.8)
                )
            )
            .saturation(colorScheme == .light ? 1 : 1.5)
            .overlay(
                waveShape(index: index, time: time)
//                    .stroke(
//                        RadialGradient(
//                            colors: [
//                                .white,
//                                color.opacity(Double(index + 1) / Double(colors.count) * 0.9)
//                            ],
//                            center: .topLeading,
//                            startRadius: 700,
//                            endRadius: 1000
//                        ),
//                        lineWidth: 3
//                    )
                    .stroke(colorInScheme.darker(by: -50), lineWidth: 1)
            )
//            .shadow(color: index == 0 ? .clear : colorInScheme, radius: 5, x: 0, y: -1)
            .offset(y: offset + offsets[index] + params.bobbing)
            .frame(height: UIScreen.main.bounds.height * 1.75)
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = isAnimated ? timeline.date.timeIntervalSinceReferenceDate : 0
            let midWave = colors.count / 2
            
            let frontWaveMask =
                ZStack {
                    ForEach(midWave..<colors.count, id: \.self) { i in
                        wave(index: i, time: time, midWave: midWave)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
//                .compositingGroup()
            
            let topMask =
                wave(index: 3, time: time, midWave: midWave)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

            
            ZStack {
                
                // Waves behind the content.
                ForEach(0..<midWave, id: \.self) { index in
                    wave(index: index, time: time, midWave: midWave)
                }
                
                
                let contentParams = waveParameters(index: midWave, time: time)
                let tilt = sin(contentParams.phase - 0.5) * 0.02
                let content: (_ layer: Int) -> some View = { layer in
                ZStack {
                    primaryContent
                        .rotationEffect(.radians(-tilt))
                        .offset(y: max(contentParams.bobbing, offset + offsets[midWave] + contentParams.bobbing) + 15)
                    if let secondary = secondaryContent(layer) {
                        secondary
                            .offset(y: max(contentParams.bobbing*1.1, offset + offsets[midWave] + contentParams.bobbing*1.1) + 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .compositingGroup()
            }
                
                content(0)
                
                wave(index: 2, time: time, midWave: midWave)
                
                content(1)
                    .scaleEffect(1.005)
                    .opacity(0.6)
                    .offset(y: 2)
                    .mask(frontWaveMask)
                
                wave(index: 3, time: time, midWave: midWave)
                
                content(2)
                    .scaleEffect(1.01)
                    .opacity(0.4)
                    .offset(y: 2)
                    .mask(topMask)
            }
            .background {
                skyGradient
            }
        }
        .drawingGroup(opaque: false, colorMode: .extendedLinear)
//        .ignoresSafeArea(edges: .all)
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
    
    let colorScheme: ColorScheme = .light
    let index: Int = 16
    
    WaterView(
        waveColors: K.colorThemes[index].waveColors,
        skyColors: K.colorThemes[index].backgroundColors(for: colorScheme)
    ) {
        Text("00:00")
            .font(.system(size: 120, weight: .semibold, design: .default))
            .fontDesign(.default)
            .fontWeight(.semibold)
            .fontWidth(.compressed)
            .foregroundStyle(.white)
        
    } secondaryContent: { _ in
        VStack(spacing: 100) {
            Text("ROUND 1 OF 10")
                .fontWeight(.bold)
                .frame(height: 50)
                .foregroundStyle(
                    colorScheme == .dark ?
                    Color.white :
                        K.colorThemes[index].accentColor
                )
                .blendMode(
                    colorScheme == .dark ?
                        .lighten :
                            .lighten
                )
            
            Text("INHALE")
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .frame(height: 60)
        }
    }
    .preferredColorScheme(colorScheme)
}
