import SwiftUI

/// Role: Taper. Named colours and SF Pro. Hex lives only here: #141F1A #1C2B25 #EDF2F0 #69D3A7 #91ACA0.
enum WickInk {
    static let face = "SF Pro"

    enum Hex {
        static let background = "#141F1A"
        static let surface = "#1C2B25"
        static let ink = "#EDF2F0"
        static let accent = "#69D3A7"
        static let muted = "#91ACA0"
    }

    enum Palette {
        static let background = Color("background")
        static let surface = Color("surface")
        static let ink = Color("ink")
        static let accent = Color("wickAccent")
        static let muted = Color("muted")
    }
}
