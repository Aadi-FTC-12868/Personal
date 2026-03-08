import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var viewModel = PeptideChainViewModel()
    @State private var showProteinExplorer = false
    @State private var showControls = true
    @Namespace private var modeAnimation

    var body: some View {
        ZStack {
            // Full-screen 3D scene
            MoleculeSceneView(scene: viewModel.renderer.scene, renderer: viewModel.renderer)
                .ignoresSafeArea()
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3)) {
                        showControls.toggle()
                    }
                }

            // Gradient overlay at top
            VStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .ignoresSafeArea()

                Spacer()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                .ignoresSafeArea()
            }

            if showControls {
                // UI Overlay
                VStack(spacing: 0) {
                    // Top bar
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    Spacer()

                    // Build mode chain controls
                    if viewModel.currentMode == .build && !viewModel.peptideChain.isEmpty {
                        chainControlBar
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }

                    // Info panel
                    InfoPanelView(
                        aminoAcid: viewModel.currentMode == .explore ? viewModel.selectedAminoAcid : nil,
                        viewModel: viewModel
                    )
                    .padding(.horizontal, 12)

                    // Amino acid picker
                    AminoAcidPickerView(viewModel: viewModel)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showProteinExplorer) {
            ProteinExplorerView(viewModel: viewModel)
        }
        .statusBarHidden(!showControls)
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                // App title
                HStack(spacing: 8) {
                    Image(systemName: "atom")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(MolecularColorTheme.accentPrimary)
                        .symbolEffect(.variableColor.iterative)

                    Text("Peptide Lab")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Right controls
                HStack(spacing: 12) {
                    controlButton(icon: "arrow.triangle.2.circlepath", isActive: viewModel.autoRotate) {
                        viewModel.toggleRotation()
                    }

                    controlButton(icon: "sparkles", isActive: viewModel.showBondFormation) {
                        viewModel.showBondFormation.toggle()
                    }

                    controlButton(icon: "book.fill", isActive: false) {
                        showProteinExplorer = true
                    }
                }
            }

            // Mode selector
            modeSelector
        }
    }

    private var modeSelector: some View {
        HStack(spacing: 4) {
            ForEach(SimulatorMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.currentMode = mode
                    }
                    HapticManager.shared.select()
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(viewModel.currentMode == mode ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if viewModel.currentMode == mode {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    MolecularColorTheme.accentPrimary,
                                                    MolecularColorTheme.accentSecondary
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .matchedGeometryEffect(id: "modeBG", in: modeAnimation)
                                }
                            }
                        )
                }
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
        )
    }

    private var chainControlBar: some View {
        HStack(spacing: 12) {
            // Sequence display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(viewModel.peptideChain.enumerated()), id: \.offset) { index, aa in
                        Text(aa.threeLetterCode)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(MolecularColorTheme.categoryColor(aa.category))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(MolecularColorTheme.categoryColor(aa.category).opacity(0.15))
                            )

                        if index < viewModel.peptideChain.count - 1 {
                            Image(systemName: "minus")
                                .font(.system(size: 8))
                                .foregroundColor(MolecularColorTheme.accentTertiary)
                        }
                    }
                }
            }

            Spacer()

            // Chain actions
            HStack(spacing: 8) {
                Button {
                    viewModel.removeLastFromChain()
                } label: {
                    Image(systemName: "delete.backward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Circle().fill(Color.orange.opacity(0.15)))
                }

                Button {
                    viewModel.clearChain()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.red.opacity(0.15)))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
    }

    private func controlButton(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isActive ? MolecularColorTheme.accentPrimary : .white.opacity(0.6))
                .padding(9)
                .background(
                    Circle()
                        .fill(isActive
                            ? MolecularColorTheme.accentPrimary.opacity(0.15)
                            : Color.white.opacity(0.08)
                        )
                )
        }
    }
}

#Preview {
    ContentView()
}
