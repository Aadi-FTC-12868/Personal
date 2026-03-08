import Foundation

struct ProteinTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let sequence: [String] // Three-letter codes
    let category: ProteinCategory
    let pdbInfo: String
    let function: String

    var aminoAcids: [AminoAcid] {
        sequence.compactMap { AminoAcidLibrary.find($0) }
    }
}

enum ProteinCategory: String, CaseIterable, Identifiable {
    case enzyme = "Enzymes"
    case structural = "Structural"
    case signaling = "Signaling"
    case transport = "Transport"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .enzyme:     return "bolt.circle.fill"
        case .structural: return "building.2.fill"
        case .signaling:  return "antenna.radiowaves.left.and.right"
        case .transport:  return "arrow.left.arrow.right.circle.fill"
        }
    }
}

struct ProteinLibrary {
    static let templates: [ProteinTemplate] = [
        // Enzymes
        ProteinTemplate(
            name: "Catalytic Triad",
            description: "The classic Ser-His-Asp catalytic triad found in serine proteases like chymotrypsin",
            sequence: ["Ser", "His", "Asp"],
            category: .enzyme,
            pdbInfo: "Found in chymotrypsin (PDB: 4CHA)",
            function: "Catalyzes peptide bond hydrolysis through a charge relay system"
        ),
        ProteinTemplate(
            name: "Zinc Finger Motif",
            description: "Cys₂His₂ zinc finger DNA-binding domain",
            sequence: ["Cys", "Cys", "His", "His"],
            category: .enzyme,
            pdbInfo: "Common in transcription factors",
            function: "Coordinates a zinc ion to create a finger-like structure that binds DNA"
        ),
        ProteinTemplate(
            name: "Trypsin Active Site",
            description: "Active site residues of trypsin with specificity pocket",
            sequence: ["His", "Asp", "Ser", "Asp", "Gly"],
            category: .enzyme,
            pdbInfo: "PDB: 1TRN",
            function: "Cleaves peptide bonds at the C-terminal side of lysine and arginine"
        ),

        // Structural
        ProteinTemplate(
            name: "Collagen Triple Helix",
            description: "Characteristic Gly-Pro-X repeat of collagen",
            sequence: ["Gly", "Pro", "Ala", "Gly", "Pro", "Ala"],
            category: .structural,
            pdbInfo: "Most abundant protein in the body",
            function: "Forms strong triple-helical fibers providing structural support"
        ),
        ProteinTemplate(
            name: "Alpha Helix Segment",
            description: "Classic alpha helix-forming sequence rich in Ala and Leu",
            sequence: ["Ala", "Leu", "Ala", "Leu", "Ala", "Leu"],
            category: .structural,
            pdbInfo: "Common secondary structure",
            function: "Stabilized by i to i+4 hydrogen bonds along the backbone"
        ),
        ProteinTemplate(
            name: "Disulfide Bridge",
            description: "Two cysteines forming a stabilizing disulfide bond",
            sequence: ["Cys", "Gly", "Ala", "Cys"],
            category: .structural,
            pdbInfo: "Found in immunoglobulins and insulin",
            function: "Covalent S-S bond between cysteine residues stabilizes protein folding"
        ),

        // Signaling
        ProteinTemplate(
            name: "Insulin B-Chain (Fragment)",
            description: "Key segment of insulin B-chain with receptor binding residues",
            sequence: ["Phe", "Val", "Asn", "Gln", "His", "Leu"],
            category: .signaling,
            pdbInfo: "PDB: 4INS",
            function: "Binds insulin receptor to regulate blood glucose levels"
        ),
        ProteinTemplate(
            name: "EGF-like Motif",
            description: "Epidermal growth factor receptor binding motif",
            sequence: ["Cys", "His", "Tyr", "Gly", "Cys"],
            category: .signaling,
            pdbInfo: "Found in EGF family",
            function: "Activates cell proliferation and differentiation pathways"
        ),

        // Transport
        ProteinTemplate(
            name: "Hemoglobin Heme Pocket",
            description: "Proximal and distal histidine residues coordinating heme iron",
            sequence: ["Val", "His", "Leu", "Thr", "Pro", "Glu"],
            category: .transport,
            pdbInfo: "PDB: 1HHO",
            function: "Binds and transports O₂ via iron coordination with proximal His"
        ),
        ProteinTemplate(
            name: "Ion Channel Selectivity",
            description: "DEKA selectivity filter of voltage-gated sodium channels",
            sequence: ["Asp", "Glu", "Lys", "Ala"],
            category: .transport,
            pdbInfo: "Nav1.x channels",
            function: "Creates selective pore for Na⁺ ions through charge complementarity"
        ),
    ]

    static func byCategory(_ category: ProteinCategory) -> [ProteinTemplate] {
        templates.filter { $0.category == category }
    }
}
