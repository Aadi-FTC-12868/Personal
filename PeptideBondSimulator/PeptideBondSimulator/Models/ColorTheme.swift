import SwiftUI
import SceneKit

enum MolecularColorTheme {
    // CPK coloring standard for atoms
    static func color(for element: Element) -> UIColor {
        switch element {
        case .carbon:    return UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.0)
        case .nitrogen:  return UIColor(red: 0.18, green: 0.32, blue: 0.96, alpha: 1.0)
        case .oxygen:    return UIColor(red: 0.94, green: 0.16, blue: 0.16, alpha: 1.0)
        case .hydrogen:  return UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
        case .sulfur:    return UIColor(red: 0.90, green: 0.78, blue: 0.20, alpha: 1.0)
        case .phosphorus: return UIColor(red: 1.00, green: 0.50, blue: 0.00, alpha: 1.0)
        }
    }

    static func radius(for element: Element) -> CGFloat {
        switch element {
        case .carbon:    return 0.30
        case .nitrogen:  return 0.28
        case .oxygen:    return 0.27
        case .hydrogen:  return 0.18
        case .sulfur:    return 0.36
        case .phosphorus: return 0.34
        }
    }

    // Bond colors
    static let singleBond = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    static let doubleBond = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    static let peptideBond = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 1.0)

    // UI gradient colors
    static let backgroundTop = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let backgroundBottom = Color(red: 0.06, green: 0.04, blue: 0.14)

    static let accentPrimary = Color(red: 0.30, green: 0.50, blue: 1.0)
    static let accentSecondary = Color(red: 0.60, green: 0.20, blue: 0.90)
    static let accentTertiary = Color(red: 0.20, green: 0.85, blue: 0.70)

    // Amino acid category colors
    static func categoryColor(_ category: AminoAcidCategory) -> Color {
        switch category {
        case .nonpolar:   return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .polar:      return Color(red: 0.3, green: 0.9, blue: 0.5)
        case .positive:   return Color(red: 0.9, green: 0.3, blue: 0.4)
        case .negative:   return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .aromatic:   return Color(red: 0.7, green: 0.4, blue: 0.9)
        }
    }

    static func categoryGlow(_ category: AminoAcidCategory) -> Color {
        categoryColor(category).opacity(0.4)
    }
}

enum Element: String, CaseIterable {
    case carbon = "C"
    case nitrogen = "N"
    case oxygen = "O"
    case hydrogen = "H"
    case sulfur = "S"
    case phosphorus = "P"
}
