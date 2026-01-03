//
//  Extensions.swift
//  Apneue
//
//  Created by Saad Anis on 06/06/2025.
//

import Foundation
import SwiftUI

extension TimeInterval {
    var formattedTime: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func darker(by percentage: CGFloat = 20.0) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(max(brightness - percentage/100, 0.0)), opacity: Double(alpha))
    }
    
    func flattened(over background: Color, alpha: CGFloat) -> Color {
        let fg = UIColor(self)
        let bg = UIColor(background)
        
        var fr: CGFloat = 0, fgC: CGFloat = 0, fb: CGFloat = 0, _ : CGFloat = 0
        var br: CGFloat = 0, bgC: CGFloat = 0, bb: CGFloat = 0, _ : CGFloat = 0
        
        fg.getRed(&fr, green: &fgC, blue: &fb, alpha: nil)
        bg.getRed(&br, green: &bgC, blue: &bb, alpha: nil)
        
        let r = fr * alpha + br * (1 - alpha)
        let g = fgC * alpha + bgC * (1 - alpha)
        let b = fb * alpha + bb * (1 - alpha)
        
        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}
