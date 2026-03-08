import SceneKit

class AtomNode: SCNNode {
    let element: Element
    let atomLabel: String
    private var glowNode: SCNNode?

    init(atom: Atom3D, scale: Float = 1.0) {
        self.element = atom.element
        self.atomLabel = atom.label
        super.init()

        let radius = MolecularColorTheme.radius(for: atom.element) * CGFloat(scale)
        let sphere = SCNSphere(radius: radius)
        sphere.segmentCount = 48

        let material = SCNMaterial()
        material.diffuse.contents = MolecularColorTheme.color(for: atom.element)
        material.specular.contents = UIColor.white
        material.shininess = 0.7
        material.roughness.contents = 0.3
        material.metalness.contents = 0.1
        material.fresnelExponent = 2.0
        material.lightingModel = .physicallyBased
        sphere.materials = [material]

        self.geometry = sphere
        self.position = atom.position

        addSubtleGlow()
        self.name = atom.label
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubtleGlow() {
        let glowSphere = SCNSphere(radius: MolecularColorTheme.radius(for: element) * 1.3)
        glowSphere.segmentCount = 24

        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = MolecularColorTheme.color(for: element).withAlphaComponent(0.15)
        glowMaterial.emission.contents = MolecularColorTheme.color(for: element).withAlphaComponent(0.1)
        glowMaterial.transparent.contents = UIColor(white: 1.0, alpha: 0.15)
        glowMaterial.isDoubleSided = true
        glowMaterial.lightingModel = .constant
        glowSphere.materials = [glowMaterial]

        let glow = SCNNode(geometry: glowSphere)
        self.addChildNode(glow)
        self.glowNode = glow
    }

    func highlight(on: Bool) {
        let targetScale: Float = on ? 1.3 : 1.0
        let scaleAction = SCNAction.scale(to: CGFloat(targetScale), duration: 0.3)
        scaleAction.timingMode = .easeInEaseOut
        self.runAction(scaleAction)

        if on {
            glowNode?.geometry?.firstMaterial?.diffuse.contents =
                MolecularColorTheme.color(for: element).withAlphaComponent(0.4)
            glowNode?.geometry?.firstMaterial?.emission.contents =
                MolecularColorTheme.color(for: element).withAlphaComponent(0.3)
        } else {
            glowNode?.geometry?.firstMaterial?.diffuse.contents =
                MolecularColorTheme.color(for: element).withAlphaComponent(0.15)
            glowNode?.geometry?.firstMaterial?.emission.contents =
                MolecularColorTheme.color(for: element).withAlphaComponent(0.1)
        }
    }

    func pulseAnimation() {
        let pulseUp = SCNAction.scale(to: 1.15, duration: 0.4)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SCNAction.scale(to: 1.0, duration: 0.4)
        pulseDown.timingMode = .easeInEaseOut
        let sequence = SCNAction.sequence([pulseUp, pulseDown])
        self.runAction(SCNAction.repeatForever(sequence))
    }

    func stopPulse() {
        self.removeAllActions()
        self.scale = SCNVector3(1, 1, 1)
    }
}
