import SceneKit

class PeptideBondAnimator {
    private let scene: SCNScene
    private var isAnimating = false

    init(scene: SCNScene) {
        self.scene = scene
    }

    func animatePeptideBondFormation(
        between residue1: AminoAcid,
        and residue2: AminoAcid,
        in moleculeNode: SCNNode,
        completion: @escaping () -> Void
    ) {
        guard !isAnimating else { return }
        isAnimating = true

        // Clear existing
        moleculeNode.childNodes.forEach { $0.removeFromParentNode() }

        let leftGroup = SCNNode()
        leftGroup.name = "residue_left"
        let rightGroup = SCNNode()
        rightGroup.name = "residue_right"

        // Position residues apart
        let leftOffset = SCNVector3(-3.0, 0, 0)
        let rightOffset = SCNVector3(3.0, 0, 0)

        // Build left residue (residue1 with OH on C-terminus)
        let leftAtoms = residue1.backboneAtoms + residue1.sideChainAtoms
        for atom in leftAtoms {
            let adjusted = Atom3D(
                atom.element,
                x: atom.position.x + leftOffset.x,
                y: atom.position.y + leftOffset.y,
                z: atom.position.z + leftOffset.z,
                label: atom.label
            )
            leftGroup.addChildNode(AtomNode(atom: adjusted))
        }

        // OH on the C-terminus of left residue
        let ohAtom = Atom3D(.oxygen, x: 1.8 + leftOffset.x, y: -0.8 + leftOffset.y, z: leftOffset.z, label: "OH")
        let ohH = Atom3D(.hydrogen, x: 2.4 + leftOffset.x, y: -1.2 + leftOffset.y, z: leftOffset.z, label: "H-oh")
        let ohNode = AtomNode(atom: ohAtom, scale: 1.0)
        ohNode.name = "oh_leaving"
        let ohHNode = AtomNode(atom: ohH, scale: 1.0)
        ohHNode.name = "h_leaving"
        leftGroup.addChildNode(ohNode)
        leftGroup.addChildNode(ohHNode)

        // Bonds for left residue
        let leftBonds = residue1.backboneBonds + residue1.sideChainBonds
        for bond in leftBonds {
            guard bond.from < leftAtoms.count && bond.to < leftAtoms.count else { continue }
            let from = SCNVector3(
                leftAtoms[bond.from].position.x + leftOffset.x,
                leftAtoms[bond.from].position.y + leftOffset.y,
                leftAtoms[bond.from].position.z + leftOffset.z
            )
            let to = SCNVector3(
                leftAtoms[bond.to].position.x + leftOffset.x,
                leftAtoms[bond.to].position.y + leftOffset.y,
                leftAtoms[bond.to].position.z + leftOffset.z
            )
            leftGroup.addChildNode(BondNode(from: from, to: to, order: bond.order))
        }
        // C-OH bond
        leftGroup.addChildNode(BondNode(
            from: SCNVector3(1.2 + leftOffset.x, leftOffset.y, leftOffset.z),
            to: ohAtom.position
        ))
        leftGroup.addChildNode(BondNode(from: ohAtom.position, to: ohH.position))

        moleculeNode.addChildNode(leftGroup)

        // Build right residue (residue2 with extra H on N-terminus)
        let rightAtoms = residue2.backboneAtoms + residue2.sideChainAtoms
        for atom in rightAtoms {
            let adjusted = Atom3D(
                atom.element,
                x: atom.position.x + rightOffset.x,
                y: atom.position.y + rightOffset.y,
                z: atom.position.z + rightOffset.z,
                label: atom.label
            )
            rightGroup.addChildNode(AtomNode(atom: adjusted))
        }

        // Extra H on N-terminus
        let extraH = Atom3D(.hydrogen, x: -1.8 + rightOffset.x, y: -0.5 + rightOffset.y, z: rightOffset.z, label: "H-leaving")
        let extraHNode = AtomNode(atom: extraH, scale: 1.0)
        extraHNode.name = "h_n_leaving"
        rightGroup.addChildNode(extraHNode)

        let rightBonds = residue2.backboneBonds + residue2.sideChainBonds
        for bond in rightBonds {
            guard bond.from < rightAtoms.count && bond.to < rightAtoms.count else { continue }
            let from = SCNVector3(
                rightAtoms[bond.from].position.x + rightOffset.x,
                rightAtoms[bond.from].position.y + rightOffset.y,
                rightAtoms[bond.from].position.z + rightOffset.z
            )
            let to = SCNVector3(
                rightAtoms[bond.to].position.x + rightOffset.x,
                rightAtoms[bond.to].position.y + rightOffset.y,
                rightAtoms[bond.to].position.z + rightOffset.z
            )
            rightGroup.addChildNode(BondNode(from: from, to: to, order: bond.order))
        }
        // N-H bond
        rightGroup.addChildNode(BondNode(
            from: SCNVector3(-1.2 + rightOffset.x, rightOffset.y, rightOffset.z),
            to: extraH.position
        ))

        moleculeNode.addChildNode(rightGroup)

        // Animate appearance
        leftGroup.scale = SCNVector3(0.01, 0.01, 0.01)
        rightGroup.scale = SCNVector3(0.01, 0.01, 0.01)
        leftGroup.opacity = 0
        rightGroup.opacity = 0

        let appear = SCNAction.group([
            SCNAction.scale(to: 1.0, duration: 0.5),
            SCNAction.fadeIn(duration: 0.4)
        ])

        leftGroup.runAction(appear)
        rightGroup.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 0.1),
            appear
        ]))

        // Phase 1: Move together (condensation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let moveLeft = SCNAction.move(by: SCNVector3(1.2, 0, 0), duration: 1.2)
            moveLeft.timingMode = .easeInEaseOut
            let moveRight = SCNAction.move(by: SCNVector3(-1.2, 0, 0), duration: 1.2)
            moveRight.timingMode = .easeInEaseOut

            leftGroup.runAction(moveLeft)
            rightGroup.runAction(moveRight)

            // Phase 2: Release water + form peptide bond
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                self?.releaseWater(
                    ohNode: ohNode,
                    ohHNode: ohHNode,
                    extraHNode: extraHNode,
                    in: moleculeNode
                )

                // Add peptide bond glow
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let cPos = SCNVector3(1.2 + leftOffset.x + 1.2, 0, 0)
                    let nPos = SCNVector3(-1.2 + rightOffset.x - 1.2, 0, 0)
                    let peptideBond = BondNode(
                        from: cPos, to: nPos,
                        order: 1, isPeptideBond: true
                    )
                    peptideBond.glowAnimation()
                    peptideBond.opacity = 0
                    moleculeNode.addChildNode(peptideBond)
                    peptideBond.runAction(SCNAction.fadeIn(duration: 0.6))

                    self?.addFormationFlash(at: SCNVector3(
                        (cPos.x + nPos.x) / 2,
                        (cPos.y + nPos.y) / 2,
                        (cPos.z + nPos.z) / 2
                    ), in: moleculeNode)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.isAnimating = false
                        completion()
                    }
                }
            }
        }
    }

    private func releaseWater(
        ohNode: AtomNode,
        ohHNode: AtomNode,
        extraHNode: AtomNode,
        in moleculeNode: SCNNode
    ) {
        // Create a water molecule from the leaving groups
        let waterPos = SCNVector3(0, -2, 1)
        let waterGroup = SCNNode()
        waterGroup.name = "water_product"

        let waterO = AtomNode(atom: Atom3D(.oxygen, x: waterPos.x, y: waterPos.y, z: waterPos.z, label: "O"), scale: 0.9)
        let waterH1 = AtomNode(atom: Atom3D(.hydrogen, x: waterPos.x - 0.5, y: waterPos.y + 0.4, z: waterPos.z, label: "H"), scale: 0.9)
        let waterH2 = AtomNode(atom: Atom3D(.hydrogen, x: waterPos.x + 0.5, y: waterPos.y + 0.4, z: waterPos.z, label: "H"), scale: 0.9)

        waterGroup.addChildNode(waterO)
        waterGroup.addChildNode(waterH1)
        waterGroup.addChildNode(waterH2)
        waterGroup.addChildNode(BondNode(from: waterO.position, to: waterH1.position))
        waterGroup.addChildNode(BondNode(from: waterO.position, to: waterH2.position))

        waterGroup.opacity = 0
        waterGroup.scale = SCNVector3(0.01, 0.01, 0.01)
        moleculeNode.addChildNode(waterGroup)

        // Fade out leaving groups
        ohNode.runAction(SCNAction.fadeOut(duration: 0.4))
        ohHNode.runAction(SCNAction.fadeOut(duration: 0.4))
        extraHNode.runAction(SCNAction.fadeOut(duration: 0.4))

        // Fade in water molecule
        let appear = SCNAction.group([
            SCNAction.fadeIn(duration: 0.5),
            SCNAction.scale(to: 1.0, duration: 0.5)
        ])

        let floatAway = SCNAction.group([
            SCNAction.move(by: SCNVector3(0, -3, 2), duration: 2.5),
            SCNAction.sequence([
                SCNAction.wait(duration: 1.5),
                SCNAction.fadeOut(duration: 1.0)
            ])
        ])

        waterGroup.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 0.3),
            appear,
            SCNAction.wait(duration: 0.5),
            floatAway,
            SCNAction.removeFromParentNode()
        ]))

        // Add label
        addWaterLabel(at: waterPos, in: moleculeNode)
    }

    private func addWaterLabel(at position: SCNVector3, in parent: SCNNode) {
        let textGeometry = SCNText(string: "H₂O", extrusionDepth: 0.01)
        textGeometry.font = UIFont.systemFont(ofSize: 0.3, weight: .medium)
        textGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.8)
        textGeometry.firstMaterial?.lightingModel = .constant

        let textNode = SCNNode(geometry: textGeometry)
        let (min, max) = textGeometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(
            (max.x - min.x) / 2 + min.x,
            (max.y - min.y) / 2 + min.y,
            0
        )
        textNode.position = SCNVector3(position.x, position.y - 0.5, position.z)
        textNode.opacity = 0

        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = .all
        textNode.constraints = [constraint]

        parent.addChildNode(textNode)

        textNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 0.8),
            SCNAction.fadeIn(duration: 0.3),
            SCNAction.wait(duration: 2.0),
            SCNAction.fadeOut(duration: 0.5),
            SCNAction.removeFromParentNode()
        ]))
    }

    private func addFormationFlash(at position: SCNVector3, in parent: SCNNode) {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleSize = 0.03
        particleSystem.particleColor = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.8)
        particleSystem.birthRate = 200
        particleSystem.particleLifeSpan = 0.6
        particleSystem.spreadingAngle = 180
        particleSystem.emittingDirection = SCNVector3(0, 1, 0)
        particleSystem.particleVelocity = 1.5
        particleSystem.particleVelocityVariation = 0.8
        particleSystem.blendMode = .additive
        particleSystem.isLightingEnabled = false
        particleSystem.loops = false
        particleSystem.emissionDuration = 0.3
        particleSystem.particleColorVariation = SCNVector4(0.1, 0.2, 0.1, 0)

        let flashNode = SCNNode()
        flashNode.position = position
        flashNode.addParticleSystem(particleSystem)
        parent.addChildNode(flashNode)

        // Remove after particles die
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            flashNode.removeFromParentNode()
        }
    }
}
