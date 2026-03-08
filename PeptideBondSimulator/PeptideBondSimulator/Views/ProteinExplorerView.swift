import SwiftUI

struct ProteinExplorerView: View {
    @ObservedObject var viewModel: PeptideChainViewModel
    @State private var selectedCategory: ProteinCategory = .enzyme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        MolecularColorTheme.backgroundTop,
                        MolecularColorTheme.backgroundBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category selector
                    categorySelector
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Protein list
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(ProteinLibrary.byCategory(selectedCategory)) { protein in
                                proteinCard(protein)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Protein Explorer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(MolecularColorTheme.accentPrimary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ProteinCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                        HapticManager.shared.select()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14))
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category
                                    ? MolecularColorTheme.accentPrimary
                                    : Color.white.opacity(0.08))
                        )
                        .foregroundColor(selectedCategory == category
                            ? .white
                            : .white.opacity(0.6))
                    }
                }
            }
        }
    }

    private func proteinCard(_ protein: ProteinTemplate) -> some View {
        Button {
            viewModel.loadProtein(protein)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(protein.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(protein.description)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }

                    Spacer()

                    // Residue count
                    VStack {
                        Text("\(protein.sequence.count)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(MolecularColorTheme.accentTertiary)
                        Text("residues")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                // Sequence preview
                HStack(spacing: 3) {
                    ForEach(Array(protein.sequence.enumerated()), id: \.offset) { _, code in
                        if let aa = AminoAcidLibrary.find(code) {
                            Text(aa.threeLetterCode)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(MolecularColorTheme.categoryColor(aa.category).opacity(0.3))
                                )
                        }
                    }
                }

                // Function
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(MolecularColorTheme.accentPrimary)
                    Text(protein.function)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }

                // PDB info
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 10))
                        .foregroundColor(MolecularColorTheme.accentSecondary)
                    Text(protein.pdbInfo)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}
