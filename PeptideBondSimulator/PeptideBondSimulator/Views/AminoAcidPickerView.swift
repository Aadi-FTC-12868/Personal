import SwiftUI

struct AminoAcidPickerView: View {
    @ObservedObject var viewModel: PeptideChainViewModel
    @State private var selectedCategory: AminoAcidCategory = .nonpolar
    @State private var searchText = ""
    @Namespace private var animation

    var filteredAminoAcids: [AminoAcid] {
        let categoryFiltered = AminoAcidLibrary.byCategory(selectedCategory)
        if searchText.isEmpty {
            return categoryFiltered
        }
        return categoryFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.threeLetterCode.localizedCaseInsensitiveContains(searchText) ||
            $0.singleLetterCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category tabs
            categoryTabs
                .padding(.horizontal, 12)
                .padding(.top, 8)

            // Amino acid grid
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(filteredAminoAcids) { aa in
                        aminoAcidCard(aa)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 15, y: -5)
        )
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AminoAcidCategory.allCases) { category in
                    categoryTab(category)
                }
            }
        }
    }

    private func categoryTab(_ category: AminoAcidCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedCategory = category
            }
            HapticManager.shared.select()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.system(size: 11))
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Group {
                    if selectedCategory == category {
                        Capsule()
                            .fill(MolecularColorTheme.categoryColor(category))
                            .matchedGeometryEffect(id: "categoryBG", in: animation)
                    } else {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    }
                }
            )
            .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.6))
        }
    }

    private func aminoAcidCard(_ aa: AminoAcid) -> some View {
        Button {
            if viewModel.currentMode == .build {
                viewModel.addToChain(aa)
            } else {
                viewModel.selectAminoAcid(aa)
            }
        } label: {
            VStack(spacing: 6) {
                // Three-letter code in circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    MolecularColorTheme.categoryColor(aa.category),
                                    MolecularColorTheme.categoryColor(aa.category).opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: MolecularColorTheme.categoryGlow(aa.category), radius: 6)

                    Text(aa.threeLetterCode)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                Text(aa.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)

                Text(aa.singleLetterCode)
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 72, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                viewModel.selectedAminoAcid == aa
                                    ? MolecularColorTheme.categoryColor(aa.category)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .scaleEffect(viewModel.selectedAminoAcid == aa ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: viewModel.selectedAminoAcid)
    }
}
