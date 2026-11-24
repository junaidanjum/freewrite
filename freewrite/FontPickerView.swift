//
//  FontPickerView.swift
//  freewrite
//

import SwiftUI
import AppKit

struct FontPickerView: View {
    @Binding var selectedFont: String
    let onPick: () -> Void

    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private static let width: CGFloat = 260
    private static let listHeight: CGFloat = 320
    private static let previewSize: CGFloat = 15
    static let families = NSFontManager.shared.availableFontFamilies
        .filter { !$0.hasPrefix(".") }
        .sorted()

    private var matches: [String] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return Self.families }
        return Self.families.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search fonts", text: $query)
                .textFieldStyle(.roundedBorder)
                .focused($isSearchFocused)
                .onSubmit {
                    if let first = matches.first {
                        pick(first)
                    }
                }
                .padding(10)

            Divider()

            if matches.isEmpty {
                Text("No fonts match \u{201C}\(query)\u{201D}")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: Self.listHeight)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(matches, id: \.self) { family in
                            FontRow(family: family, isSelected: family == selectedFont, previewSize: Self.previewSize) {
                                pick(family)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: Self.listHeight)
            }

            Divider()

            Button {
                if let family = Self.families.filter({ $0 != selectedFont }).randomElement() {
                    pick(family)
                }
            } label: {
                Label("Surprise me", systemImage: "shuffle")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .frame(width: Self.width)
        .onAppear {
            isSearchFocused = true
        }
    }

    private func pick(_ family: String) {
        selectedFont = family
        onPick()
    }
}

private struct FontRow: View {
    let family: String
    let isSelected: Bool
    let previewSize: CGFloat
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(family)
                    .font(.custom(family, size: previewSize))
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(family)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onHover { isHovering = $0 }
    }
}
