import SwiftUI
import BashboxCore

/// Colors and type modelled on HashiCorp's Helios design system (the Vault UI):
/// a near-black side nav, white content surfaces, light grey borders, and
/// blue for actions.
enum Theme {
    // Side navigation
    static let navBackground = Color(hex: 0x0C0C0E)
    static let navText = Color(hex: 0xDEDFE3)
    static let navMuted = Color(hex: 0x8C909C)
    static let navHover = Color(hex: 0x1F2024)
    static let navActive = Color(hex: 0x2C2E33)
    static let brand = Color(hex: 0xFFD814)          // Vault yellow

    // Content
    static let page = Color(hex: 0xFAFAFA)
    static let surface = Color.white
    static let border = Color(hex: 0xDEDFE3)
    static let borderStrong = Color(hex: 0xC2C5CB)
    static let text = Color(hex: 0x3B3D45)
    static let textStrong = Color(hex: 0x0C0C0E)
    static let textFaint = Color(hex: 0x656A76)
    static let action = Color(hex: 0x1060FF)
    static let actionSurface = Color(hex: 0xF2F8FF)
    static let success = Color(hex: 0x008A22)
    static let successSurface = Color(hex: 0xF2FBF6)
    static let successBorder = Color(hex: 0xCCEEDA)
    static let warning = Color(hex: 0xBB5A00)
    static let warningSurface = Color(hex: 0xFFF9E8)
    static let warningBorder = Color(hex: 0xFDDEA4)
    static let highlight = Color(hex: 0x911CED)
    static let highlightSurface = Color(hex: 0xF9F2FF)
    static let code = Color(hex: 0x0C0C0E)
    static let codeText = Color(hex: 0xEFEFF1)
    static let terminal = Color(hex: 0x0E0F12)

    static let mono = Font.system(size: 12.5, design: .monospaced)
    static let monoSmall = Font.system(size: 11.5, design: .monospaced)

    static func color(for kind: Diagram.Node.Kind) -> Color {
        switch kind {
        case .actor: return Color(hex: 0x911CED)
        case .shell: return Color(hex: 0x1060FF)
        case .process: return Color(hex: 0x3B3D45)
        case .file: return Color(hex: 0x008A22)
        case .stream: return Color(hex: 0xD35400)
        case .system: return Color(hex: 0x656A76)
        case .network: return Color(hex: 0x0B8BC0)
        }
    }

    static func label(for kind: Diagram.Node.Kind) -> String {
        switch kind {
        case .actor: return "Person"
        case .shell: return "Shell"
        case .process: return "Program"
        case .file: return "File / folder"
        case .stream: return "Stream"
        case .system: return "System"
        case .network: return "Network"
        }
    }

    /// Pastel fills for diagram groups, in the style of HashiCorp architecture diagrams.
    static let groupFills: [(fill: Color, stroke: Color)] = [
        (Color(hex: 0xEEF4FF), Color(hex: 0xC6D8FF)),
        (Color(hex: 0xF9F2FF), Color(hex: 0xE4CCFA)),
        (Color(hex: 0xF2FBF6), Color(hex: 0xC4E9D2)),
        (Color(hex: 0xFFF9E8), Color(hex: 0xF5DFA6)),
    ]
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
