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
    
    static let colorThemes: [ColorTheme] = [
        .init(name: "Ocean", accentColor: .blue, backgroundColors: [
            .white,
            .blue,
        ], waveColors: [
            .blue,
            .blue,
            .blue,
            .blue,
        ]),
        .init(name: "Lava", accentColor: .red, backgroundColors: [.black], waveColors: [.yellow, .red]),
        .init(name: "Cotton", accentColor: .pink, backgroundColors: [.pink], waveColors: [.cyan]),
        .init(name: "Ocean Dawn",
              accentColor: Color(hex: "#FF6F61"),
              backgroundColors: [Color(hex: "#FFDAB9"), Color(hex: "#87CEFA")],
              waveColors: [Color(hex: "#ADD8E6"), Color(hex: "#66CDAA"), Color(hex: "#F0FFFF")]),
        
            .init(name: "Midnight Abyss",
                  accentColor: Color(hex: "#00BFFF"),
                  backgroundColors: [Color(hex: "#000080"), Color(hex: "#191970")],
                  waveColors: [Color(hex: "#004F4F"), Color(hex: "#001F3F"), Color(hex: "#000000")]),
        
            .init(name: "Tropical Sunset",
                  accentColor: Color(hex: "#FFD700"),
                  backgroundColors: [Color(hex: "#FF69B4"), Color(hex: "#FF4500")],
                  waveColors: [Color(hex: "#FF7F7F"), Color(hex: "#DA70D6"), Color(hex: "#FFA07A")]),
        
            .init(name: "Glacial Calm",
                  accentColor: Color(hex: "#00FFFF"),
                  backgroundColors: [Color(hex: "#E0FFFF"), Color(hex: "#D3D3D3")],
                  waveColors: [Color(hex: "#C0C0C0"), Color(hex: "#FFFFFF"), Color(hex: "#B0E0E6")]),
        
            .init(name: "Stormfront",
                  accentColor: Color(hex: "#FFBF00"),
                  backgroundColors: [Color(hex: "#36454F"), Color(hex: "#708090")],
                  waveColors: [Color(hex: "#2F4F4F"), Color(hex: "#6A5ACD"), Color(hex: "#A9A9A9")]),
        
            .init(name: "Emerald Bay",
                  accentColor: Color(hex: "#32CD32"),
                  backgroundColors: [Color(hex: "#98FF98"), Color(hex: "#E0FFFF")],
                  waveColors: [Color(hex: "#90EE90"), Color(hex: "#00FFFF"), Color(hex: "#20B2AA")]),
        
            .init(name: "Serenity",
                  accentColor: .pink,
                  backgroundColors: [.blue],
                  waveColors: [
                    Color(hex: "#5BCEFA"),
                    Color(hex: "#F5A9B8"),
                    .white,
                    Color(hex: "#F5A9B8"),
                    Color(hex: "#5BCEFA")
                  ]),

        
            .init(name: "Desert Mirage",
                  accentColor: Color(hex: "#CC5500"),
                  backgroundColors: [Color(hex: "#FFE4B5"), Color(hex: "#B0E0E6")],
                  waveColors: [Color(hex: "#F5F5DC"), Color(hex: "#D2B48C"), Color(hex: "#ADD8E6")]),
        
            .init(name: "Aurora Dream",
                  accentColor: Color(hex: "#FF1493"),
                  backgroundColors: [Color(hex: "#800080"), Color(hex: "#00FF7F")],
                  waveColors: [Color(hex: "#8A2BE2"), Color(hex: "#00FFFF"), Color(hex: "#FF69B4")]),
        
            .init(name: "Zen Lagoon",
                  accentColor: Color(hex: "#008080"),
                  backgroundColors: [Color(hex: "#B0E0E6"), Color(hex: "#AFEEEE")],
                  waveColors: [Color(hex: "#00CED1"), Color(hex: "#2E8B57"), Color(hex: "#F8F8FF")]),
        
            .init(name: "Crimson Tide",
                  accentColor: Color(hex: "#DC143C"),
                  backgroundColors: [Color(hex: "#8B0000"), Color(hex: "#FFC0CB")],
                  waveColors: [Color(hex: "#800020"), Color(hex: "#C71585"), Color(hex: "#FFDAB9")]),
        
            .init(name: "Pride Spectrum",
                  accentColor: Color(hex: "#FF7F7F"),
                  backgroundColors: [Color(hex: "#FF7F7F"), Color(hex: "#FFD580"), Color(hex: "#87CEFA")],
                  waveColors: [Color(hex: "#FF6F61"), Color(hex: "#FFFACD"), Color(hex: "#AFEEEE")]),
        
            .init(name: "Trans Serenity",
                  accentColor: Color(hex: "#FFB6C1"),
                  backgroundColors: [Color(hex: "#ADD8E6"), Color(hex: "#FFFFFF")],
                  waveColors: [Color(hex: "#FFB6C1"), Color(hex: "#FFFFFF"), Color(hex: "#ADD8E6")]),
        
            .init(name: "Bi Horizon",
                  accentColor: Color(hex: "#D60270"),
                  backgroundColors: [Color(hex: "#D60270"), Color(hex: "#9B4F96"), Color(hex: "#0038A8")],
                  waveColors: [Color(hex: "#D66DBD"), Color(hex: "#B48FD6"), Color(hex: "#5A7DB3")]),
        
            .init(name: "Earthbound",
                  accentColor: Color(hex: "#228B22"),
                  backgroundColors: [Color(hex: "#87CEFA"), Color(hex: "#98FB98")],
                  waveColors: [Color(hex: "#20B2AA"), Color(hex: "#8FBC8F"), Color(hex: "#B0E0E6")]),
        
            .init(name: "Pink Ribbon",
                  accentColor: Color(hex: "#FF69B4"),
                  backgroundColors: [Color(hex: "#FFC0CB"), Color(hex: "#FFF5F5")],
                  waveColors: [Color(hex: "#FFB6C1"), Color(hex: "#FFFFFF"), Color(hex: "#E6E6E6")]),
        
            .init(name: "Neurodivergent Glow",
                  accentColor: Color(hex: "#00BFFF"),
                  backgroundColors: [Color(hex: "#00BFFF"), Color(hex: "#8A2BE2"), Color(hex: "#FFFACD")],
                  waveColors: [Color(hex: "#4682B4"), Color(hex: "#F0E68C"), Color(hex: "#D8BFD8")]),
        
            .init(name: "Mental Health Calm",
                  accentColor: Color(hex: "#50C878"),
                  backgroundColors: [Color(hex: "#BDFCC9"), Color(hex: "#ADD8E6")],
                  waveColors: [Color(hex: "#66CDAA"), Color(hex: "#E0FFFF"), Color(hex: "#B0E0E6")]),
        
            .init(name: "Black & Proud",
                  accentColor: Color(hex: "#FFD700"),
                  backgroundColors: [Color(hex: "#2E2E2E"), Color(hex: "#1C1C1C")],
                  waveColors: [Color(hex: "#1A1A1A"), Color(hex: "#3D3D3D"), Color(hex: "#FFD700")]),
        
            .init(name: "Panlight",
                  accentColor: Color(hex: "#FFD700"),
                  backgroundColors: [Color(hex: "#FF218C"), Color(hex: "#FFD700"), Color(hex: "#21B1FF")],
                  waveColors: [Color(hex: "#FF69B4"), Color(hex: "#FFFACD"), Color(hex: "#B2FFFF")]),
        
            .init(name: "Peaceflow",
                  accentColor: Color(hex: "#B57EDC"),
                  backgroundColors: [Color(hex: "#A0DFF0"), Color(hex: "#E6E6FA")],
                  waveColors: [Color(hex: "#C8A2C8"), Color(hex: "#B0E0E6"), Color(hex: "#F5FFFA")])
    ]
    
    static let customColorPalettes2: [ColorPalette] = [
        ColorPalette(
            name: "Ocean",
            colors: [
                Color(hex: "#1f8fff"),
                Color(hex: "#00bfff"),
                Color(hex: "#81cefe"),
                Color(hex: "#0989f1"),
                Color(hex: "#0434af")
            ]
        ),
        ColorPalette(
            name: "Lava",
            colors: [
                Color(hex: "#ff4500"),
                Color(hex: "#ff6347"),
                Color(hex: "#ff7f50"),
                Color(hex: "#ff8c00"),
                Color(hex: "#ff0000")
            ]
        ),
        ColorPalette(
            name: "Acid",
            colors: [
                Color(hex: "#b0bf1a"),
                Color(hex: "#CBE315"),
                Color(hex: "#FFFE2F"),
                Color(hex: "#FFE52F")
            ]
        ),
        ColorPalette(
            name: "Pastel",
            colors: [
                Color(hex: "#ffadad"),
                Color(hex: "#ffd6a5"),
                Color(hex: "#fdffb6"),
                Color(hex: "#caffbf"),
                Color(hex: "#9bf6ff"),
                Color(hex: "#a0c4ff"),
                Color(hex: "#bdb2ff"),
                Color(hex: "#ffc6ff")
            ]
        ),
        ColorPalette(
            name: "Spectrum",
            colors: [
                Color(hex: "#00A86B"),
                Color(hex: "#FFD700"),
                Color(hex: "#FF7F00"),
                Color(hex: "#FF0000"),
                Color(hex: "#8B00FF"),
                Color(hex: "#0000FF")
            ]
        )
    ]
}
