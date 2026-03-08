import SwiftUI
import SceneKit

struct MoleculeSceneView: UIViewRepresentable {
    let scene: SCNScene
    let renderer: MolecularRenderer

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.defaultCameraController.inertiaEnabled = true
        scnView.defaultCameraController.maximumVerticalAngle = 80
        scnView.antialiasingMode = .multisampling4X
        scnView.isJitteringEnabled = true
        scnView.isTemporalAntialiasingEnabled = true

        let cameraNode = renderer.setupCamera()
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode

        // Add tap gesture for atom selection
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        scnView.addGestureRecognizer(tapGesture)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Scene updates happen through the renderer
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: renderer)
    }

    class Coordinator: NSObject {
        let renderer: MolecularRenderer
        private var highlightedAtom: AtomNode?

        init(renderer: MolecularRenderer) {
            self.renderer = renderer
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let location = gesture.location(in: scnView)

            let hitResults = scnView.hitTest(location, options: [
                .searchMode: SCNHitTestSearchMode.closest.rawValue
            ])

            highlightedAtom?.highlight(on: false)
            highlightedAtom = nil

            for result in hitResults {
                var node: SCNNode? = result.node
                while node != nil {
                    if let atomNode = node as? AtomNode {
                        atomNode.highlight(on: true)
                        highlightedAtom = atomNode
                        HapticManager.shared.tap()
                        return
                    }
                    node = node?.parent
                }
            }
        }
    }
}
