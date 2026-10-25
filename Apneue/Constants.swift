//
//  Constants.swift
//  Apneue
//
//  Created by Saad Anis on 15/07/2025.
//

import Foundation
import SwiftUI

struct K {
    
    static let initialOffset: CGFloat = 0
    static let upperOffset: CGFloat = -UIScreen.main.bounds.height*0.3
    static let lowerOffset: CGFloat = UIScreen.main.bounds.height*0.1
    
    static let initialSpacing: CGFloat = 20
    static let upperSpacing: CGFloat = 10
    static let lowerSpacing: CGFloat = 30
    
    static let supporterProductID = "com.saadanis.Apneue.Supporter"
    
    static let appIconNames: [String] = [
        "ApneueIcon",
        "MintIcon",
        "AbyssIcon",
        "CrimsonIcon",
        "OrangeIcon",
        "IndigoIcon",
        "RetroIcon",
        "PeacefulIcon",
        "BloomIcon",
        "NailIcon"
    ]
    
    static let colorThemes: [ColorTheme] = [
        
        //        Simple
        
        .init(name: "Ocean",
              accentColor: .blue,
              backgroundColorsLight: [
                Color(hex: "B5E7FF"),
                .white
              ],
              backgroundColorsDark: [
                .black,
                Color(hex: "003F6C")
              ],
              waveColors: [
                Color(hex: "74B7FF"),
                Color(hex: "49A2FF"),
                Color(hex: "1082FF"),
                Color(hex: "0056D8")
              ]),
        .init(name: "Arctic",
              accentColor: .cyan,
              backgroundColorsLight: [.cyan, .white],
              backgroundColorsDark: [.black, .cyan],
              waveColors: [.teal, .cyan]),
        .init(name: "Mint",
              accentColor: Color(hex: "#50C878"),
              backgroundColorsLight: [Color(hex: "9DF4B0"), .white],
              backgroundColorsDark: [.black, Color(hex: "71AF7E")],
              waveColors: [Color(hex: "#12ED9F"), Color(hex: "009BB0")]),
        .init(name: "Abyss",
              accentColor: .black,
              backgroundColorsLight: [.white, .gray],
              backgroundColorsDark: [.black, .gray],
              waveColors: [.black, .black]),
        .init(name: "Cappuccino",
              accentColor: Color(hex: "9D511F"),
              backgroundColorsLight: [Color(hex: "EAB082"), .white],
              backgroundColorsDark: [.black, Color(hex: "9F6F49")],
              waveColors: [Color(hex: "917358"), Color(hex: "644937")]),
        .init(name: "Coral",
              accentColor: Color(hex: "E36C6D"),
              backgroundColorsLight: [Color(hex: "DD916E"), .white],
              backgroundColorsDark: [.black, Color(hex: "B96742")],
              waveColors: [Color(hex: "E36C6D"), Color(hex: "B94849")]),
        
        
        //        A Little Less Simple
        
            .init(
                name: "Crimson",
                accentColor: Color(hex: "#C60000"),
                backgroundColorsLight: [Color(hex: "#E42E2E"), Color(hex: "FF9D9D")],
                backgroundColorsDark: [.black, Color(hex: "#6B0000")],
                waveColors: [Color(hex: "#E60000"), Color(hex: "#B30000")]),
        .init(
            name: "Orange",
            accentColor: Color(hex: "#FF5D14"),
            backgroundColorsLight: [Color(hex: "FFA074"), Color(hex: "FFECE3")],
            backgroundColorsDark: [.black, Color(hex: "892900")],
            waveColors: [Color(hex: "#FF6A1A"), Color(hex: "#CC3A00")]),
        .init(name: "Gold",
              accentColor: Color(hex: "CA9702"),
              backgroundColorsLight: [Color(hex: "A66A00"), Color(hex: "FFDE68")],
              backgroundColorsDark: [.black, Color(hex: "B38C00")],
              waveColors: [Color(hex: "D4AC35"), Color(hex: "CA9702")]),
        .init(name: "Matcha",
              accentColor: Color(hex: "6AAE23"),
              backgroundColorsLight: [Color(hex: "DBE84E"), Color(hex: "F2F6CC")],
              backgroundColorsDark: [.black, Color(hex: "646C11")],
              waveColors: [
                Color(hex: "A4DD62"),
                Color(hex: "76B231")
              ]),
        .init(
            name: "Teal",
            accentColor: Color(hex: "027F80"),
            backgroundColorsLight: [Color(hex: "04E3E5"), Color(hex: "D6FFF0")],
            backgroundColorsDark: [.black, Color(hex: "026D6E")],
            waveColors: [Color(hex: "03BCBE"),Color(hex: "016B6C")]
        ),
        .init(
            name: "Indigo",
            accentColor: Color(hex: "9C06FF"),
            backgroundColorsLight: [Color(hex: "47E9FF"), .white],
            backgroundColorsDark: [.black, Color(hex: "0048BF")],
            waveColors: [Color(hex: "9C06FF"),Color(hex: "5C00CC")]
        ),
        //        Definitely Not Simple
        .init(name: "Retro",
              accentColor: Color(hex: "ff4281"),
              backgroundColorsLight: [Color(hex: "2941CC"), Color(hex: "6DEEFF")],
              backgroundColorsDark: [.black, Color(hex: "04428B")],
              waveColors: [Color(hex: "ff4281"), Color(hex: "ffec3d")]),
        .init(name: "Peaceful",
              accentColor: Color(hex: "#B86EEC"),
              backgroundColorsLight: [Color(hex: "#43A4FF"), Color(hex: "#C7F3FF")],
              backgroundColorsDark: [.black, Color(hex: "#4343D6")],
              waveColors: [Color(hex: "#B86EEC"), Color(hex: "#1AD6ED"), Color(hex: "#54F5A5"), Color(hex: "6CF47D")]),
        .init(name: "Bloom",
              accentColor: Color(hex: "FF6B88"),
              backgroundColorsLight: [Color(hex: "01B9FF"), .white],
              backgroundColorsDark: [.black, Color(hex: "016E98")],
              waveColors: [Color(hex: "FFC2CE"), Color(hex: "FF476C")]),
        .init(name: "Drift",
              accentColor: Color(hex: "#DE2BB3"),
              backgroundColorsLight: [
                Color(hex: "#C5B1FF"),
                Color(hex: "#FFE9FA")
              ],
              backgroundColorsDark: [.black, Color(hex: "#93198B")],
              waveColors: [Color(hex: "#DE2BB3"), Color(hex: "#9143DA"), Color(hex: "#0012EF"), Color(hex: "#1890FF")]),
        .init(name: "Acid",
              accentColor: Color(hex: "9B59D0"),
              backgroundColorsLight: [
                Color(hex: "#C7B6FF"),
                .white
              ],
              backgroundColorsDark: [
                .black,
                Color(hex: "#483161")
              ],
              waveColors: [
                Color(hex: "#DFF34A"),
                Color(hex: "#B8F34A"),
                Color(hex: "#7ED957"),
                Color(hex: "#2E7D32"),
              ]),
        .init(name: "Vulkan",
              accentColor: Color(hex: "ff0000"),
              backgroundColorsLight: [
                .gray,
                Color(hex: "EFEFEF")
              ],
              backgroundColorsDark: [
                .black,
                .black
              ],
              waveColors: [
                Color(hex: "#ff0000"),
                Color(hex: "#ffcc00")
              ]),
    ]
    
    static func backgroundColor(for themeIndex: Int, colorScheme: ColorScheme) -> Color {
        
        return K.colorThemes[themeIndex]
            .accentColor
            .flattened(over:
                        colorScheme == .dark ?
                .gray.darker(by: 50) :
                    .white, alpha: 0.1
            )
    }
    
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
}
