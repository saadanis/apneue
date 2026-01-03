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
              backgroundColors: [
                Color(hex: "B5E7FF"),
                .white
              ],
              waveColors: [
                Color(hex: "74B7FF"),
                Color(hex: "49A2FF"),
                Color(hex: "1082FF"),
                Color(hex: "0056D8")
              ]),
        .init(name: "Arctic",
              accentColor: .cyan,
              backgroundColors: [.cyan, .clear],
              waveColors: [.blue, .teal]),
        .init(name: "Mint",
              accentColor: Color(hex: "#50C878"),
              backgroundColors: [Color(hex: "#55E670"), .clear],
              waveColors: [Color(hex: "#00E99A"), Color(hex: "009BB0")]),
        .init(name: "Abyss",
              accentColor: .gray,
              backgroundColors: [.white, .clear],
              waveColors: [.black]),
        .init(name: "Cappuccino",
              accentColor: Color(hex: "9D511F"),
              backgroundColors: [Color(hex: "EAB082"), .clear],
              waveColors: [Color(hex: "917358"), Color(hex: "644937")]),
        .init(name: "Coral",
              accentColor: Color(hex: "E36C6D"),
              backgroundColors: [Color(hex: "DD916E"), .clear],
              waveColors: [Color(hex: "E36C6D")]),
        
        
        //        A Little Less Simple
        
            .init(
                name: "Crimson",
                accentColor: Color(hex: "#C60000"),
                backgroundColors: [Color(hex: "#D10000"), Color(hex: "#960000")],
                waveColors: [Color(hex: "#B30000"), Color(hex: "#FE0000")]),
        .init(
            name: "Orange",
            accentColor: Color(hex: "#FF5D14"),
            backgroundColors: [Color(hex: "#CD4F15"), Color(hex: "#A63200")],
            waveColors: [Color(hex: "#FF6A1A"), Color(hex: "#CC3A00")]),
        .init(name: "Gold",
              accentColor: Color(hex: "CA9702"),
              backgroundColors: [Color(hex: "FFC700"), Color(hex: "A66A00"), Color(hex: "828282")],
              waveColors: [Color(hex: "D4AC35"), Color(hex: "CA9702")]),
        .init(name: "Matcha",
              accentColor: Color(hex: "6AAE23"),
              backgroundColors: [Color(hex: "DBE84E")],
              waveColors: [
                Color(hex: "A4DD62"),
                Color(hex: "89C247")
              ]),
        .init(
            name: "Teal",
            accentColor: Color(hex: "027F80"),
            backgroundColors: [Color(hex: "04E3E5"), Color(hex: "9FDA00")],
            waveColors: [Color(hex: "03BCBE"),Color(hex: "016B6C")]
        ),
        .init(
            name: "Indigo",
            accentColor: Color(hex: "9C06FF"),
            backgroundColors: [Color(hex: "47E9FF"), Color(hex: "0048BF")],
            waveColors: [Color(hex: "9C06FF"),Color(hex: "5C00CC")]
        ),
        //        Definitely Not Simple
        .init(name: "Retro",
              accentColor: Color(hex: "ff4281"),
              backgroundColors: [Color(hex: "08E2FF"), Color(hex: "2941CC")],
              waveColors: [Color(hex: "ff4281"), Color(hex: "ffec3d")]),
        .init(name: "Peaceful",
              accentColor: Color(hex: "#B86EEC"),
              backgroundColors: [Color(hex: "#37D4FF"), Color(hex: "#6363F4")],
              waveColors: [Color(hex: "#B86EEC"), Color(hex: "#1AD6ED"), Color(hex: "#54F5A5"), Color(hex: "6CF47D")]),
        .init(name: "Bloom",
              accentColor: Color(hex: "FF6B88"),
              backgroundColors: [Color(hex: "01B9FF"), Color(hex: "74CEE9")],
              waveColors: [Color(hex: "FFC2CE"), Color(hex: "FF476C")]),
        .init(name: "Draft",
              accentColor: Color(hex: "#DE2BB3"),
              backgroundColors: [Color(hex: "#D60270"), Color(hex: "#C722BC"), Color(hex: "#0038A8")],
              waveColors: [Color(hex: "#DE2BB3"), Color(hex: "#9143DA"), Color(hex: "#0012EF"), Color(hex: "#1890FF")]),
        .init(name: "Acid",
              accentColor: Color(hex: "9B59D0"),
              backgroundColors: [
                Color(hex: "#3EF1FF"),
                Color(hex: "#9B59D0")
              ],
              waveColors: [
                Color(hex: "#FFF9A5"),
                Color(hex: "#F1FF00"),
                Color(hex: "#20ff00"),
                .black,
              ]),
        .init(name: "Lava",
              accentColor: Color(hex: "ff0000"),
              backgroundColors: [
                Color(hex: "#000000")
              ],
              waveColors: [
                Color(hex: "#ff0000"),
                Color(hex: "#ffcc00")
              ]),
    ]
}
