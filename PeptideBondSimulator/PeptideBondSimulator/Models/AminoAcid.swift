import Foundation
import SceneKit

enum AminoAcidCategory: String, CaseIterable, Identifiable {
    case nonpolar = "Nonpolar"
    case polar = "Polar"
    case positive = "Positive"
    case negative = "Negative"
    case aromatic = "Aromatic"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .nonpolar:  return "drop.fill"
        case .polar:     return "drop.halffull"
        case .positive:  return "plus.circle.fill"
        case .negative:  return "minus.circle.fill"
        case .aromatic:  return "hexagon.fill"
        }
    }
}

struct Atom3D: Identifiable {
    let id = UUID()
    let element: Element
    let position: SCNVector3
    let label: String

    init(_ element: Element, x: Float, y: Float, z: Float, label: String = "") {
        self.element = element
        self.position = SCNVector3(x, y, z)
        self.label = label.isEmpty ? element.rawValue : label
    }
}

struct Bond3D: Identifiable {
    let id = UUID()
    let from: Int
    let to: Int
    let order: Int // 1 = single, 2 = double
    let isPeptideBond: Bool

    init(from: Int, to: Int, order: Int = 1, isPeptideBond: Bool = false) {
        self.from = from
        self.to = to
        self.order = order
        self.isPeptideBond = isPeptideBond
    }
}

struct AminoAcid: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let threeLetterCode: String
    let singleLetterCode: String
    let category: AminoAcidCategory
    let molecularWeight: Double
    let pKa: Double
    let description: String
    let sideChainAtoms: [Atom3D]
    let sideChainBonds: [Bond3D]

    // Backbone atoms are always the same:
    // 0: N (amino), 1: Cα, 2: C (carbonyl), 3: O (carbonyl), 4: H (on N), 5: H (on Cα)
    var backboneAtoms: [Atom3D] {
        [
            Atom3D(.nitrogen, x: -1.2, y: 0.0, z: 0.0, label: "N"),
            Atom3D(.carbon,   x: 0.0,  y: 0.0, z: 0.0, label: "Cα"),
            Atom3D(.carbon,   x: 1.2,  y: 0.0, z: 0.0, label: "C"),
            Atom3D(.oxygen,   x: 1.8,  y: 1.0, z: 0.0, label: "O"),
            Atom3D(.hydrogen, x: -1.8, y: 0.7, z: 0.0, label: "H"),
            Atom3D(.hydrogen, x: 0.0,  y: -0.7, z: 0.6, label: "Hα"),
        ]
    }

    var backboneBonds: [Bond3D] {
        [
            Bond3D(from: 0, to: 1),           // N — Cα
            Bond3D(from: 1, to: 2),           // Cα — C
            Bond3D(from: 2, to: 3, order: 2), // C = O
            Bond3D(from: 0, to: 4),           // N — H
            Bond3D(from: 1, to: 5),           // Cα — Hα
        ]
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(threeLetterCode)
    }

    static func == (lhs: AminoAcid, rhs: AminoAcid) -> Bool {
        lhs.threeLetterCode == rhs.threeLetterCode
    }
}

struct AminoAcidLibrary {
    static let all: [AminoAcid] = [
        // NONPOLAR
        AminoAcid(
            name: "Glycine", threeLetterCode: "Gly", singleLetterCode: "G",
            category: .nonpolar, molecularWeight: 75.03, pKa: 2.34,
            description: "The simplest amino acid with just a hydrogen as its side chain. Provides flexibility to protein structures due to minimal steric hindrance.",
            sideChainAtoms: [
                Atom3D(.hydrogen, x: 0.0, y: 0.7, z: -0.5, label: "H")
            ],
            sideChainBonds: [Bond3D(from: 1, to: 6)]
        ),
        AminoAcid(
            name: "Alanine", threeLetterCode: "Ala", singleLetterCode: "A",
            category: .nonpolar, molecularWeight: 89.09, pKa: 2.34,
            description: "Contains a methyl group side chain. One of the most common amino acids in proteins, often found in alpha-helices.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.8, z: -0.8, label: "Cβ"),
                Atom3D(.hydrogen, x: -0.5, y: 1.4, z: -1.2, label: "H"),
                Atom3D(.hydrogen, x: 0.5, y: 1.4, z: -1.2, label: "H"),
                Atom3D(.hydrogen, x: 0.0, y: 0.2, z: -1.5, label: "H"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 6, to: 8),
                Bond3D(from: 6, to: 9),
            ]
        ),
        AminoAcid(
            name: "Valine", threeLetterCode: "Val", singleLetterCode: "V",
            category: .nonpolar, molecularWeight: 117.15, pKa: 2.32,
            description: "Branched-chain amino acid with an isopropyl side chain. Essential amino acid important for muscle metabolism and tissue repair.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: -0.8, y: 1.6, z: -1.2, label: "Cγ1"),
                Atom3D(.carbon, x: 0.8, y: 1.6, z: -1.2, label: "Cγ2"),
                Atom3D(.hydrogen, x: 0.0, y: 0.3, z: -1.4, label: "H"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 6, to: 8),
                Bond3D(from: 6, to: 9),
            ]
        ),
        AminoAcid(
            name: "Leucine", threeLetterCode: "Leu", singleLetterCode: "L",
            category: .nonpolar, molecularWeight: 131.17, pKa: 2.36,
            description: "Branched-chain amino acid with an isobutyl side chain. Essential for protein synthesis and important in hemoglobin formation.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.carbon, x: -0.8, y: 2.6, z: -1.0, label: "Cδ1"),
                Atom3D(.carbon, x: 0.8, y: 2.6, z: -1.8, label: "Cδ2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 7, to: 9),
            ]
        ),
        AminoAcid(
            name: "Isoleucine", threeLetterCode: "Ile", singleLetterCode: "I",
            category: .nonpolar, molecularWeight: 131.17, pKa: 2.36,
            description: "Branched-chain amino acid essential for blood sugar regulation and energy. Has a branched side chain at the beta carbon.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: -0.8, y: 1.6, z: -1.2, label: "Cγ1"),
                Atom3D(.carbon, x: 0.6, y: 0.5, z: -1.5, label: "Cγ2"),
                Atom3D(.carbon, x: -0.8, y: 2.6, z: -0.6, label: "Cδ1"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 6, to: 8),
                Bond3D(from: 7, to: 9),
            ]
        ),
        AminoAcid(
            name: "Proline", threeLetterCode: "Pro", singleLetterCode: "P",
            category: .nonpolar, molecularWeight: 115.13, pKa: 1.99,
            description: "Unique cyclic structure where the side chain bonds back to the backbone nitrogen. Introduces kinks in protein chains and disrupts helices.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: -0.7, y: 1.4, z: -0.1, label: "Cγ"),
                Atom3D(.carbon, x: -1.2, y: 0.7, z: 0.5, label: "Cδ"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 0), // Cyclic bond back to N
            ]
        ),
        AminoAcid(
            name: "Methionine", threeLetterCode: "Met", singleLetterCode: "M",
            category: .nonpolar, molecularWeight: 149.21, pKa: 2.28,
            description: "Contains a thioether sulfur in its side chain. Serves as the initiator amino acid in protein synthesis (start codon AUG).",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.sulfur, x: 0.0, y: 2.8, z: -0.8, label: "Sδ"),
                Atom3D(.carbon, x: 0.0, y: 3.6, z: -1.6, label: "Cε"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9),
            ]
        ),

        // POLAR
        AminoAcid(
            name: "Serine", threeLetterCode: "Ser", singleLetterCode: "S",
            category: .polar, molecularWeight: 105.09, pKa: 2.21,
            description: "Contains a hydroxyl group that can form hydrogen bonds. Important in enzyme active sites and phosphorylation signaling.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.oxygen,   x: 0.0, y: 1.7, z: -1.3, label: "Oγ"),
                Atom3D(.hydrogen, x: 0.0, y: 2.4, z: -0.9, label: "H"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
            ]
        ),
        AminoAcid(
            name: "Threonine", threeLetterCode: "Thr", singleLetterCode: "T",
            category: .polar, molecularWeight: 119.12, pKa: 2.09,
            description: "Has a hydroxyl group and methyl branch. Essential amino acid that participates in phosphorylation and glycosylation.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.oxygen,   x: -0.7, y: 1.5, z: -1.2, label: "Oγ1"),
                Atom3D(.carbon,   x: 0.7, y: 1.5, z: -1.2, label: "Cγ2"),
                Atom3D(.hydrogen, x: -1.2, y: 2.0, z: -0.8, label: "H"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 6, to: 8),
                Bond3D(from: 7, to: 9),
            ]
        ),
        AminoAcid(
            name: "Asparagine", threeLetterCode: "Asn", singleLetterCode: "N",
            category: .polar, molecularWeight: 132.12, pKa: 2.02,
            description: "Contains an amide group on its side chain. Commonly found at N-glycosylation sites on protein surfaces.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.oxygen,   x: -0.6, y: 2.6, z: -1.2, label: "Oδ1"),
                Atom3D(.nitrogen, x: 0.6, y: 1.8, z: -2.3, label: "Nδ2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8, order: 2),
                Bond3D(from: 7, to: 9),
            ]
        ),
        AminoAcid(
            name: "Glutamine", threeLetterCode: "Gln", singleLetterCode: "Q",
            category: .polar, molecularWeight: 146.15, pKa: 2.17,
            description: "Longer polar side chain with an amide group. Important nitrogen donor in biosynthesis and can be converted to glutamate.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.carbon,   x: 0.0, y: 2.7, z: -0.8, label: "Cδ"),
                Atom3D(.oxygen,   x: -0.6, y: 3.5, z: -1.0, label: "Oε1"),
                Atom3D(.nitrogen, x: 0.6, y: 2.7, z: 0.1, label: "Nε2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9, order: 2),
                Bond3D(from: 8, to: 10),
            ]
        ),
        AminoAcid(
            name: "Cysteine", threeLetterCode: "Cys", singleLetterCode: "C",
            category: .polar, molecularWeight: 121.16, pKa: 1.96,
            description: "Contains a thiol (sulfhydryl) group that can form disulfide bonds between cysteine residues, stabilizing protein structure.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.sulfur,   x: 0.0, y: 1.8, z: -1.5, label: "Sγ"),
                Atom3D(.hydrogen, x: 0.0, y: 2.6, z: -1.0, label: "H"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
            ]
        ),

        // POSITIVE
        AminoAcid(
            name: "Lysine", threeLetterCode: "Lys", singleLetterCode: "K",
            category: .positive, molecularWeight: 146.19, pKa: 2.18,
            description: "Long flexible side chain with a positively charged amino group at physiological pH. Key in ionic bonds and histone modification.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.carbon,   x: 0.0, y: 2.7, z: -0.8, label: "Cδ"),
                Atom3D(.carbon,   x: 0.0, y: 3.6, z: -1.4, label: "Cε"),
                Atom3D(.nitrogen, x: 0.0, y: 4.4, z: -0.8, label: "Nζ"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9),
                Bond3D(from: 9, to: 10),
            ]
        ),
        AminoAcid(
            name: "Arginine", threeLetterCode: "Arg", singleLetterCode: "R",
            category: .positive, molecularWeight: 174.20, pKa: 2.17,
            description: "Contains a guanidinium group that is almost always positively charged. Forms multiple hydrogen bonds and is key in salt bridges.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.carbon,   x: 0.0, y: 2.7, z: -0.8, label: "Cδ"),
                Atom3D(.nitrogen, x: 0.0, y: 3.5, z: -1.4, label: "Nε"),
                Atom3D(.carbon,   x: 0.0, y: 4.3, z: -0.8, label: "Cζ"),
                Atom3D(.nitrogen, x: -0.6, y: 5.0, z: -1.2, label: "Nη1"),
                Atom3D(.nitrogen, x: 0.6, y: 4.6, z: 0.0, label: "Nη2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9),
                Bond3D(from: 9, to: 10),
                Bond3D(from: 10, to: 11, order: 2),
                Bond3D(from: 10, to: 12),
            ]
        ),
        AminoAcid(
            name: "Histidine", threeLetterCode: "His", singleLetterCode: "H",
            category: .positive, molecularWeight: 155.16, pKa: 1.82,
            description: "Contains an imidazole ring that can be protonated near physiological pH. Critical in enzyme catalysis as proton shuttle.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.3, label: "Cγ"),
                Atom3D(.nitrogen, x: -0.5, y: 2.6, z: -1.0, label: "Nδ1"),
                Atom3D(.carbon,   x: -0.3, y: 3.3, z: -1.8, label: "Cε1"),
                Atom3D(.nitrogen, x: 0.3, y: 2.8, z: -2.5, label: "Nε2"),
                Atom3D(.carbon,   x: 0.5, y: 1.9, z: -2.2, label: "Cδ2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9, order: 2),
                Bond3D(from: 9, to: 10),
                Bond3D(from: 10, to: 11, order: 2),
                Bond3D(from: 7, to: 11),
            ]
        ),

        // NEGATIVE
        AminoAcid(
            name: "Aspartate", threeLetterCode: "Asp", singleLetterCode: "D",
            category: .negative, molecularWeight: 133.10, pKa: 1.88,
            description: "Negatively charged carboxylate side chain. Important in enzyme active sites and forms salt bridges with positively charged residues.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.oxygen, x: -0.6, y: 2.6, z: -1.1, label: "Oδ1"),
                Atom3D(.oxygen, x: 0.6, y: 1.8, z: -2.3, label: "Oδ2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8, order: 2),
                Bond3D(from: 7, to: 9),
            ]
        ),
        AminoAcid(
            name: "Glutamate", threeLetterCode: "Glu", singleLetterCode: "E",
            category: .negative, molecularWeight: 147.13, pKa: 2.19,
            description: "Longer negatively charged side chain than Asp. Major excitatory neurotransmitter and key metabolic intermediate.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.4, label: "Cγ"),
                Atom3D(.carbon, x: 0.0, y: 2.7, z: -0.8, label: "Cδ"),
                Atom3D(.oxygen, x: -0.6, y: 3.5, z: -1.0, label: "Oε1"),
                Atom3D(.oxygen, x: 0.6, y: 2.7, z: 0.1, label: "Oε2"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8),
                Bond3D(from: 8, to: 9, order: 2),
                Bond3D(from: 8, to: 10),
            ]
        ),

        // AROMATIC
        AminoAcid(
            name: "Phenylalanine", threeLetterCode: "Phe", singleLetterCode: "F",
            category: .aromatic, molecularWeight: 165.19, pKa: 1.83,
            description: "Contains a benzene ring that participates in hydrophobic interactions and π-π stacking. Essential amino acid.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.3, label: "Cγ"),
                Atom3D(.carbon, x: -0.6, y: 2.6, z: -1.0, label: "Cδ1"),
                Atom3D(.carbon, x: 0.6, y: 2.0, z: -2.2, label: "Cδ2"),
                Atom3D(.carbon, x: -0.6, y: 3.5, z: -1.7, label: "Cε1"),
                Atom3D(.carbon, x: 0.6, y: 2.9, z: -2.9, label: "Cε2"),
                Atom3D(.carbon, x: 0.0, y: 3.6, z: -2.6, label: "Cζ"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8, order: 2),
                Bond3D(from: 7, to: 9),
                Bond3D(from: 8, to: 10),
                Bond3D(from: 9, to: 11, order: 2),
                Bond3D(from: 10, to: 12, order: 2),
                Bond3D(from: 11, to: 12),
            ]
        ),
        AminoAcid(
            name: "Tyrosine", threeLetterCode: "Tyr", singleLetterCode: "Y",
            category: .aromatic, molecularWeight: 181.19, pKa: 2.20,
            description: "Phenol-containing amino acid. The hydroxyl group enables phosphorylation, a critical cell signaling mechanism.",
            sideChainAtoms: [
                Atom3D(.carbon, x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon, x: 0.0, y: 1.8, z: -1.3, label: "Cγ"),
                Atom3D(.carbon, x: -0.6, y: 2.6, z: -1.0, label: "Cδ1"),
                Atom3D(.carbon, x: 0.6, y: 2.0, z: -2.2, label: "Cδ2"),
                Atom3D(.carbon, x: -0.6, y: 3.5, z: -1.7, label: "Cε1"),
                Atom3D(.carbon, x: 0.6, y: 2.9, z: -2.9, label: "Cε2"),
                Atom3D(.carbon, x: 0.0, y: 3.6, z: -2.6, label: "Cζ"),
                Atom3D(.oxygen, x: 0.0, y: 4.4, z: -3.2, label: "OH"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8, order: 2),
                Bond3D(from: 7, to: 9),
                Bond3D(from: 8, to: 10),
                Bond3D(from: 9, to: 11, order: 2),
                Bond3D(from: 10, to: 12, order: 2),
                Bond3D(from: 11, to: 12),
                Bond3D(from: 12, to: 13),
            ]
        ),
        AminoAcid(
            name: "Tryptophan", threeLetterCode: "Trp", singleLetterCode: "W",
            category: .aromatic, molecularWeight: 204.23, pKa: 2.83,
            description: "Largest amino acid with a bicyclic indole ring. Absorbs UV light at 280nm and is important for protein fluorescence studies.",
            sideChainAtoms: [
                Atom3D(.carbon,   x: 0.0, y: 0.9, z: -0.7, label: "Cβ"),
                Atom3D(.carbon,   x: 0.0, y: 1.8, z: -1.3, label: "Cγ"),
                Atom3D(.carbon,   x: -0.5, y: 2.6, z: -1.0, label: "Cδ1"),
                Atom3D(.carbon,   x: 0.3, y: 2.0, z: -2.4, label: "Cδ2"),
                Atom3D(.nitrogen, x: -0.3, y: 3.2, z: -1.8, label: "Nε1"),
                Atom3D(.carbon,   x: 0.2, y: 2.9, z: -2.8, label: "Cε2"),
                Atom3D(.carbon,   x: 0.8, y: 1.5, z: -3.3, label: "Cζ2"),
                Atom3D(.carbon,   x: 0.5, y: 3.4, z: -3.8, label: "Cη2"),
                Atom3D(.carbon,   x: 1.1, y: 2.0, z: -4.3, label: "Cζ3"),
                Atom3D(.carbon,   x: 0.9, y: 2.9, z: -4.5, label: "Cε3"),
            ],
            sideChainBonds: [
                Bond3D(from: 1, to: 6),
                Bond3D(from: 6, to: 7),
                Bond3D(from: 7, to: 8, order: 2),
                Bond3D(from: 7, to: 9),
                Bond3D(from: 8, to: 10),
                Bond3D(from: 10, to: 11),
                Bond3D(from: 9, to: 11, order: 2),
                Bond3D(from: 11, to: 12),
                Bond3D(from: 11, to: 13, order: 2),
                Bond3D(from: 12, to: 14, order: 2),
                Bond3D(from: 13, to: 15),
                Bond3D(from: 14, to: 15, order: 2),
            ]
        ),
    ]

    static func byCategory(_ category: AminoAcidCategory) -> [AminoAcid] {
        all.filter { $0.category == category }
    }

    static func find(_ code: String) -> AminoAcid? {
        all.first { $0.threeLetterCode == code || $0.singleLetterCode == code || $0.name == code }
    }
}
