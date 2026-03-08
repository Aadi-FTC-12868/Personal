import SceneKit
import UIKit

class MolecularRenderer {
    let scene: SCNScene
    private let moleculeNode: SCNNode
    private var atomNodes: [AtomNode] = []
    private var bondNodes: [BondNode] = []
    private var residueGroups: [SCNNode] = []

    init() {
        scene = SCNScene()
        moleculeNode = SCNNode()
        moleculeNode.name = "molecule"
        scene.rootNode.addChildNode(moleculeNode)
        setupLighting()
        setupEnvironment()
    }

    private func setupLighting() {
        // Key light - warm, slightly directional
        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.color = UIColor(white: 0.9, alpha: 1.0)
        keyLight.light?.intensity = 800
        keyLight.light?.castsShadow = true
        keyLight.light?.shadowMode = .deferred
        keyLight.light?.shadowSampleCount = 8
        keyLight.light?.shadowRadius = 3.0
        keyLight.light?.shadowColor = UIColor(white: 0, alpha: 0.3)
        keyLight.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/6, 0)
        scene.rootNode.addChildNode(keyLight)

        // Fill light - cooler blue
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.color = UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0)
        fillLight.light?.intensity = 400
        fillLight.eulerAngles = SCNVector3(Float.pi/6, -Float.pi/4, 0)
        scene.rootNode.addChildNode(fillLight)

        // Rim light from behind
        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .directional
        rimLight.light?.color = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        rimLight.light?.intensity = 300
        rimLight.eulerAngles = SCNVector3(Float.pi/8, Float.pi, 0)
        scene.rootNode.addChildNode(rimLight)

        // Ambient
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.15, green: 0.12, blue: 0.2, alpha: 1.0)
        ambient.light?.intensity = 200
        scene.rootNode.addChildNode(ambient)
    }

    private func setupEnvironment() {
        scene.background.contents = UIColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1.0)
        scene.fogStartDistance = 20
        scene.fogEndDistance = 40
        scene.fogColor = UIColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1.0)

        addParticleField()
    }

    private func addParticleField() {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleSize = 0.01
        particleSystem.particleColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.3)
        particleSystem.birthRate = 20
        particleSystem.particleLifeSpan = 8
        particleSystem.spreadingAngle = 180
        particleSystem.emittingDirection = SCNVector3(0, 1, 0)
        particleSystem.particleVelocity = 0.05
        particleSystem.particleVelocityVariation = 0.02
        particleSystem.emitterShape = SCNSphere(radius: 10)
        particleSystem.blendMode = .additive
        particleSystem.isLightingEnabled = false

        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem)
        scene.rootNode.addChildNode(particleNode)
    }

    func clearScene() {
        moleculeNode.childNodes.forEach { $0.removeFromParentNode() }
        atomNodes.removeAll()
        bondNodes.removeAll()
        residueGroups.removeAll()
    }

    func renderSingleAminoAcid(_ aminoAcid: AminoAcid) {
        clearScene()

        let group = SCNNode()
        group.name = aminoAcid.threeLetterCode

        let allAtoms = aminoAcid.backboneAtoms + aminoAcid.sideChainAtoms
        let allBonds = aminoAcid.backboneBonds + aminoAcid.sideChainBonds

        for atom in allAtoms {
            let atomNode = AtomNode(atom: atom, scale: 1.2)
            group.addChildNode(atomNode)
            atomNodes.append(atomNode)
        }

        for bond in allBonds {
            guard bond.from < allAtoms.count && bond.to < allAtoms.count else { continue }
            let fromPos = allAtoms[bond.from].position
            let toPos = allAtoms[bond.to].position
            let bondNode = BondNode(from: fromPos, to: toPos, order: bond.order)
            group.addChildNode(bondNode)
            bondNodes.append(bondNode)
        }

        // Add OH at C-terminus and extra H at N-terminus for standalone view
        let ohAtom = Atom3D(.oxygen, x: 1.8, y: -0.8, z: 0.0, label: "OH")
        let ohNode = AtomNode(atom: ohAtom, scale: 1.2)
        group.addChildNode(ohNode)
        atomNodes.append(ohNode)

        let ohBond = BondNode(
            from: allAtoms[2].position,
            to: ohAtom.position
        )
        group.addChildNode(ohBond)

        let hAtom = Atom3D(.hydrogen, x: -1.8, y: -0.5, z: 0.0, label: "H")
        let hNode = AtomNode(atom: hAtom, scale: 1.2)
        group.addChildNode(hNode)
        atomNodes.append(hNode)

        let hBond = BondNode(
            from: allAtoms[0].position,
            to: hAtom.position
        )
        group.addChildNode(hBond)

        moleculeNode.addChildNode(group)
        residueGroups.append(group)

        animateAppearance(group)
    }

    func renderPeptideChain(_ aminoAcids: [AminoAcid]) {
        clearScene()
        guard !aminoAcids.isEmpty else { return }

        let spacing: Float = 3.2

        for (index, aa) in aminoAcids.enumerated() {
            let group = SCNNode()
            group.name = "\(aa.threeLetterCode)_\(index)"

            let offset = SCNVector3(Float(index) * spacing, 0, 0)

            let allAtoms = aa.backboneAtoms + aa.sideChainAtoms

            for atom in allAtoms {
                let adjustedAtom = Atom3D(
                    atom.element,
                    x: atom.position.x + offset.x,
                    y: atom.position.y + offset.y,
                    z: atom.position.z + offset.z,
                    label: atom.label
                )
                let atomNode = AtomNode(atom: adjustedAtom)
                group.addChildNode(atomNode)
                atomNodes.append(atomNode)
            }

            let allBonds = aa.backboneBonds + aa.sideChainBonds
            for bond in allBonds {
                guard bond.from < allAtoms.count && bond.to < allAtoms.count else { continue }
                let fromPos = SCNVector3(
                    allAtoms[bond.from].position.x + offset.x,
                    allAtoms[bond.from].position.y + offset.y,
                    allAtoms[bond.from].position.z + offset.z
                )
                let toPos = SCNVector3(
                    allAtoms[bond.to].position.x + offset.x,
                    allAtoms[bond.to].position.y + offset.y,
                    allAtoms[bond.to].position.z + offset.z
                )
                let bondNode = BondNode(from: fromPos, to: toPos, order: bond.order)
                group.addChildNode(bondNode)
                bondNodes.append(bondNode)
            }

            // Peptide bond to previous residue
            if index > 0 {
                let prevCPos = SCNVector3(
                    1.2 + Float(index - 1) * spacing,
                    0,
                    0
                )
                let currentNPos = SCNVector3(
                    -1.2 + Float(index) * spacing,
                    0,
                    0
                )
                let peptideBondNode = BondNode(
                    from: prevCPos,
                    to: currentNPos,
                    order: 1,
                    isPeptideBond: true
                )
                peptideBondNode.glowAnimation()
                moleculeNode.addChildNode(peptideBondNode)
                bondNodes.append(peptideBondNode)
            }

            moleculeNode.addChildNode(group)
            residueGroups.append(group)

            animateAppearance(group, delay: Double(index) * 0.15)
        }

        centerMolecule(count: aminoAcids.count, spacing: spacing)
    }

    private func centerMolecule(count: Int, spacing: Float) {
        let totalWidth = Float(count - 1) * spacing
        moleculeNode.position = SCNVector3(-totalWidth / 2, 0, 0)
    }

    private func animateAppearance(_ node: SCNNode, delay: Double = 0) {
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        node.opacity = 0

        let scaleAction = SCNAction.scale(to: 1.0, duration: 0.5)
        scaleAction.timingMode = .easeOut

        let fadeAction = SCNAction.fadeIn(duration: 0.4)
        let group = SCNAction.group([scaleAction, fadeAction])
        let delayed = SCNAction.sequence([SCNAction.wait(duration: delay), group])
        node.runAction(delayed)
    }

    func setupCamera() -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.wantsDepthOfField = true
        cameraNode.camera?.focusDistance = 8
        cameraNode.camera?.focalBlurSampleCount = 4
        cameraNode.camera?.fStop = 5.6
        cameraNode.camera?.bloomIntensity = 0.3
        cameraNode.camera?.bloomThreshold = 0.8
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.minimumExposure = -2
        cameraNode.camera?.maximumExposure = 2
        cameraNode.position = SCNVector3(0, 1, 8)
        cameraNode.look(at: SCNVector3Zero)
        return cameraNode
    }

    func atomAt(position: SCNVector3, in scnView: SCNView) -> AtomNode? {
        let hitResults = scnView.hitTest(
            CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)),
            options: [.searchMode: SCNHitTestSearchMode.all.rawValue]
        )
        for result in hitResults {
            if let atomNode = result.node as? AtomNode {
                return atomNode
            }
            if let parent = result.node.parent as? AtomNode {
                return parent
            }
        }
        return nil
    }

    func addWaterMolecule(at position: SCNVector3) {
        let waterGroup = SCNNode()
        waterGroup.name = "water"

        let oxygen = AtomNode(atom: Atom3D(.oxygen, x: position.x, y: position.y, z: position.z, label: "O"), scale: 0.8)
        let h1 = AtomNode(atom: Atom3D(.hydrogen, x: position.x - 0.5, y: position.y + 0.4, z: position.z, label: "H"), scale: 0.8)
        let h2 = AtomNode(atom: Atom3D(.hydrogen, x: position.x + 0.5, y: position.y + 0.4, z: position.z, label: "H"), scale: 0.8)

        waterGroup.addChildNode(oxygen)
        waterGroup.addChildNode(h1)
        waterGroup.addChildNode(h2)

        let bond1 = BondNode(from: oxygen.position, to: h1.position)
        let bond2 = BondNode(from: oxygen.position, to: h2.position)
        waterGroup.addChildNode(bond1)
        waterGroup.addChildNode(bond2)

        moleculeNode.addChildNode(waterGroup)
        animateAppearance(waterGroup)

        // Float away animation
        let moveUp = SCNAction.move(by: SCNVector3(0, 3, 0), duration: 2.0)
        moveUp.timingMode = .easeIn
        let fadeOut = SCNAction.fadeOut(duration: 1.5)
        let group = SCNAction.group([moveUp, fadeOut])
        let sequence = SCNAction.sequence([
            SCNAction.wait(duration: 1.0),
            group,
            SCNAction.removeFromParentNode()
        ])
        waterGroup.runAction(sequence)
    }

    func slowRotation() {
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 30)
        moleculeNode.runAction(SCNAction.repeatForever(rotation), forKey: "autoRotate")
    }

    func stopRotation() {
        moleculeNode.removeAction(forKey: "autoRotate")
    }
}
