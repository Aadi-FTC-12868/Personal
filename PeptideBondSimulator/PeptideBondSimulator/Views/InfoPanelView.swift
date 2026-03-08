import SwiftUI

struct InfoPanelView: View {
    let aminoAcid: AminoAcid?
    @ObservedObject var viewModel: PeptideChainViewModel
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35)) {
                        isExpanded.toggle()
                    }
                }

            if let aa = aminoAcid {
                aminoAcidInfo(aa)
            } else if !viewModel.peptideChain.isEmpty {
                chainInfo
            } else {
                welcomeInfo
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 15)
        )
        .frame(maxHeight: isExpanded ? 400 : 200)
    }

    private func aminoAcidInfo(_ aa: AminoAcid) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(aa.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            codeBadge(aa.threeLetterCode, color: MolecularColorTheme.categoryColor(aa.category))
                            codeBadge(aa.singleLetterCode, color: MolecularColorTheme.categoryColor(aa.category).opacity(0.7))
                            categoryBadge(aa.category)
                        }
                    }

                    Spacer()

                    // Molecular weight
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1f", aa.molecularWeight))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(MolecularColorTheme.accentTertiary)
                        Text("Da")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Description
                Text(aa.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(3)

                if isExpanded {
                    Divider().background(Color.white.opacity(0.1))

                    // Properties grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 10) {
                        propertyCard(title: "pKa (α-COOH)", value: String(format: "%.2f", aa.pKa), icon: "drop.fill")
                        propertyCard(title: "Category", value: aa.category.rawValue, icon: aa.category.icon)
                        propertyCard(title: "Backbone Atoms", value: "\(aa.backboneAtoms.count)", icon: "atom")
                        propertyCard(title: "Side Chain Atoms", value: "\(aa.sideChainAtoms.count)", icon: "point.3.connected.trianglepath.dotted")
                    }
                }
            }
            .padding(16)
        }
    }

    private var chainInfo: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Peptide Chain")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(viewModel.peptideChain.count) residues")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(MolecularColorTheme.accentPrimary)
                }

                // Sequence display
                HStack(spacing: 2) {
                    ForEach(Array(viewModel.peptideChain.enumerated()), id: \.offset) { index, aa in
                        Text(aa.singleLetterCode)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(MolecularColorTheme.categoryColor(aa.category))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                )

                if isExpanded {
                    Divider().background(Color.white.opacity(0.1))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 10) {
                        propertyCard(
                            title: "Molecular Weight",
                            value: String(format: "%.1f Da", viewModel.chainMolecularWeight),
                            icon: "scalemass.fill"
                        )
                        propertyCard(
                            title: "Peptide Bonds",
                            value: "\(max(0, viewModel.peptideChain.count - 1))",
                            icon: "link"
                        )
                        propertyCard(
                            title: "Formula",
                            value: viewModel.chainFormula,
                            icon: "textformat.subscript"
                        )
                        propertyCard(
                            title: "Water Released",
                            value: "\(max(0, viewModel.peptideChain.count - 1)) H₂O",
                            icon: "drop.fill"
                        )
                    }
                }
            }
            .padding(16)
        }
    }

    private var welcomeInfo: some View {
        VStack(spacing: 12) {
            Image(systemName: "atom")
                .font(.system(size: 32))
                .foregroundColor(MolecularColorTheme.accentPrimary)
                .symbolEffect(.pulse)

            Text("Peptide Bond Simulator")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("Select an amino acid below to explore its 3D structure, or switch to Build mode to create peptide chains.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(16)
    }

    private func codeBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(color.opacity(0.3))
            )
    }

    private func categoryBadge(_ category: AminoAcidCategory) -> some View {
        HStack(spacing: 3) {
            Image(systemName: category.icon)
                .font(.system(size: 8))
            Text(category.rawValue)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(MolecularColorTheme.categoryColor(category))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(MolecularColorTheme.categoryColor(category).opacity(0.15))
        )
    }

    private func propertyCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(MolecularColorTheme.accentPrimary)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}
