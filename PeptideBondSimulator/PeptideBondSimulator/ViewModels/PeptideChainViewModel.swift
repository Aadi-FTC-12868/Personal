import SwiftUI
import SceneKit
import Combine

enum SimulatorMode: String, CaseIterable {
    case explore = "Explore"
    case build = "Build Chain"
    case proteins = "Proteins"
}

enum ViewMode: String, CaseIterable {
    case ballAndStick = "Ball & Stick"
    case spaceFilling = "Space Filling"
    case wireframe = "Wireframe"
}

@MainActor
class PeptideChainViewModel: ObservableObject {
    @Published var currentMode: SimulatorMode = .explore
    @Published var viewMode: ViewMode = .ballAndStick
    @Published var selectedAminoAcid: AminoAcid?
    @Published var peptideChain: [AminoAcid] = []
    @Published var isAnimatingBond = false
    @Published var showInfo = false
    @Published var autoRotate = true
    @Published var selectedAtomInfo: String?
    @Published var showWelcome = true
    @Published var chainSequenceText: String = ""
    @Published var selectedProtein: ProteinTemplate?
    @Published var showBondFormation = false

    let renderer: MolecularRenderer
    let animator: PeptideBondAnimator

    init() {
        renderer = MolecularRenderer()
        animator = PeptideBondAnimator(scene: renderer.scene)
        renderer.slowRotation()
    }

    func selectAminoAcid(_ aa: AminoAcid) {
        HapticManager.shared.select()
        selectedAminoAcid = aa
        showWelcome = false

        switch currentMode {
        case .explore:
            renderer.renderSingleAminoAcid(aa)
            if autoRotate { renderer.slowRotation() }
        case .build:
            break
        case .proteins:
            break
        }
    }

    func addToChain(_ aa: AminoAcid) {
        HapticManager.shared.aminoAcidAdded()

        if peptideChain.count >= 1 && showBondFormation {
            let previous = peptideChain.last!
            isAnimatingBond = true

            let moleculeNode = renderer.scene.rootNode.childNode(
                withName: "molecule", recursively: false
            ) ?? renderer.scene.rootNode

            animator.animatePeptideBondFormation(
                between: previous,
                and: aa,
                in: moleculeNode
            ) { [weak self] in
                Task { @MainActor in
                    self?.peptideChain.append(aa)
                    self?.isAnimatingBond = false
                    self?.updateChainText()
                    HapticManager.shared.bondFormed()

                    // After animation, rebuild complete chain
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.renderer.renderPeptideChain(self?.peptideChain ?? [])
                        if self?.autoRotate == true { self?.renderer.slowRotation() }
                    }
                }
            }
        } else {
            peptideChain.append(aa)
            updateChainText()
            renderer.renderPeptideChain(peptideChain)
            if autoRotate { renderer.slowRotation() }
        }
    }

    func removeLastFromChain() {
        guard !peptideChain.isEmpty else { return }
        HapticManager.shared.tap()
        peptideChain.removeLast()
        updateChainText()

        if peptideChain.isEmpty {
            renderer.clearScene()
        } else {
            renderer.renderPeptideChain(peptideChain)
            if autoRotate { renderer.slowRotation() }
        }
    }

    func clearChain() {
        HapticManager.shared.tap()
        peptideChain.removeAll()
        chainSequenceText = ""
        renderer.clearScene()
    }

    func loadProtein(_ template: ProteinTemplate) {
        HapticManager.shared.success()
        selectedProtein = template
        peptideChain = template.aminoAcids
        updateChainText()
        renderer.renderPeptideChain(peptideChain)
        if autoRotate { renderer.slowRotation() }
        currentMode = .build
    }

    func toggleRotation() {
        autoRotate.toggle()
        if autoRotate {
            renderer.slowRotation()
        } else {
            renderer.stopRotation()
        }
    }

    private func updateChainText() {
        chainSequenceText = peptideChain.map { $0.singleLetterCode }.joined()
    }

    var chainMolecularWeight: Double {
        let sum = peptideChain.reduce(0.0) { $0 + $1.molecularWeight }
        // Subtract water lost per peptide bond
        let waterLost = Double(max(0, peptideChain.count - 1)) * 18.015
        return sum - waterLost
    }

    var chainFormula: String {
        guard !peptideChain.isEmpty else { return "" }
        var c = 0, h = 0, n = 0, o = 0, s = 0

        for aa in peptideChain {
            let atoms = aa.backboneAtoms + aa.sideChainAtoms
            for atom in atoms {
                switch atom.element {
                case .carbon: c += 1
                case .hydrogen: h += 1
                case .nitrogen: n += 1
                case .oxygen: o += 1
                case .sulfur: s += 1
                case .phosphorus: break
                }
            }
        }

        // Add terminal groups (NH2 at N-term, OH at C-term)
        h += 2 // extra H on N-terminus
        o += 1 // OH on C-terminus
        h += 1 // H of OH

        // Subtract water per peptide bond
        let bonds = max(0, peptideChain.count - 1)
        h -= 2 * bonds
        o -= bonds

        var formula = ""
        if c > 0 { formula += "C\(subscript(c))" }
        if h > 0 { formula += "H\(subscript(h))" }
        if n > 0 { formula += "N\(subscript(n))" }
        if o > 0 { formula += "O\(subscript(o))" }
        if s > 0 { formula += "S\(subscript(s))" }
        return formula
    }

    private func `subscript`(_ n: Int) -> String {
        let subscripts = "₀₁₂₃₄₅₆₇₈₉"
        return String(n).map { char in
            let index = subscripts.index(subscripts.startIndex, offsetBy: Int(String(char))!)
            return subscripts[index]
        }.map(String.init).joined()
    }
}
