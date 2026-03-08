import SceneKit

class BondNode: SCNNode {
    let bondOrder: Int
    let isPeptideBond: Bool

    init(from: SCNVector3, to: SCNVector3, order: Int = 1, isPeptideBond: Bool = false) {
        self.bondOrder = order
        self.isPeptideBond = isPeptideBond
        super.init()

        if order == 1 {
            addCylinder(from: from, to: to, radius: 0.06, offset: SCNVector3Zero)
        } else if order == 2 {
            let perpendicular = calculatePerpendicular(from: from, to: to)
            let offsetDist: Float = 0.08
            let offset1 = SCNVector3(
                perpendicular.x * offsetDist,
                perpendicular.y * offsetDist,
                perpendicular.z * offsetDist
            )
            let offset2 = SCNVector3(
                -perpendicular.x * offsetDist,
                -perpendicular.y * offsetDist,
                -perpendicular.z * offsetDist
            )
            addCylinder(from: from, to: to, radius: 0.045, offset: offset1)
            addCylinder(from: from, to: to, radius: 0.045, offset: offset2)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCylinder(from: SCNVector3, to: SCNVector3, radius: CGFloat, offset: SCNVector3) {
        let adjustedFrom = SCNVector3(from.x + offset.x, from.y + offset.y, from.z + offset.z)
        let adjustedTo = SCNVector3(to.x + offset.x, to.y + offset.y, to.z + offset.z)

        let dx = adjustedTo.x - adjustedFrom.x
        let dy = adjustedTo.y - adjustedFrom.y
        let dz = adjustedTo.z - adjustedFrom.z
        let distance = sqrt(dx*dx + dy*dy + dz*dz)

        let cylinder = SCNCylinder(radius: radius, height: CGFloat(distance))
        cylinder.radialSegmentCount = 16

        let material = SCNMaterial()
        if isPeptideBond {
            material.diffuse.contents = MolecularColorTheme.peptideBond
            material.emission.contents = MolecularColorTheme.peptideBond.withAlphaComponent(0.3)
        } else if bondOrder == 2 {
            material.diffuse.contents = MolecularColorTheme.doubleBond
        } else {
            material.diffuse.contents = MolecularColorTheme.singleBond
        }
        material.specular.contents = UIColor.white
        material.shininess = 0.5
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.4
        material.metalness.contents = 0.2
        cylinder.materials = [material]

        let cylinderNode = SCNNode(geometry: cylinder)

        let midX = (adjustedFrom.x + adjustedTo.x) / 2
        let midY = (adjustedFrom.y + adjustedTo.y) / 2
        let midZ = (adjustedFrom.z + adjustedTo.z) / 2
        cylinderNode.position = SCNVector3(midX, midY, midZ)

        let direction = SCNVector3(dx, dy, dz)
        let up = SCNVector3(0, 1, 0)
        let cross = crossProduct(up, direction)
        let dot = dotProduct(up, normalize(direction))
        let angle = acos(min(max(dot, -1.0), 1.0))

        if cross.x != 0 || cross.y != 0 || cross.z != 0 {
            cylinderNode.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)
        }

        self.addChildNode(cylinderNode)
    }

    private func calculatePerpendicular(from: SCNVector3, to: SCNVector3) -> SCNVector3 {
        let direction = SCNVector3(to.x - from.x, to.y - from.y, to.z - from.z)
        let reference = abs(direction.y) < 0.9
            ? SCNVector3(0, 1, 0)
            : SCNVector3(1, 0, 0)
        let perp = crossProduct(direction, reference)
        return normalize(perp)
    }

    private func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        SCNVector3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    }

    private func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        a.x * b.x + a.y * b.y + a.z * b.z
    }

    private func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        guard len > 0 else { return v }
        return SCNVector3(v.x/len, v.y/len, v.z/len)
    }

    func glowAnimation() {
        guard isPeptideBond else { return }
        let fadeIn = SCNAction.customAction(duration: 0.8) { node, elapsed in
            let t = Float(elapsed / 0.8)
            let intensity = 0.3 + 0.4 * sin(t * .pi)
            node.enumerateChildNodes { child, _ in
                child.geometry?.firstMaterial?.emission.contents =
                    MolecularColorTheme.peptideBond.withAlphaComponent(CGFloat(intensity))
            }
        }
        let fadeOut = SCNAction.customAction(duration: 0.8) { node, elapsed in
            let t = Float(elapsed / 0.8)
            let intensity = 0.7 - 0.4 * sin(t * .pi)
            node.enumerateChildNodes { child, _ in
                child.geometry?.firstMaterial?.emission.contents =
                    MolecularColorTheme.peptideBond.withAlphaComponent(CGFloat(intensity))
            }
        }
        let sequence = SCNAction.sequence([fadeIn, fadeOut])
        self.runAction(SCNAction.repeatForever(sequence))
    }
}
