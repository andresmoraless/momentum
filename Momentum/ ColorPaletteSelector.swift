// ColorPaletteSelector.swift
import SwiftUI

struct ColorPaletteSelector: View {
    @Binding var selectedColor: Color

    var body: some View {
        HStack {
            ForEach(Color.momentumPalette, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.4),
                                    lineWidth: selectedColor == color ? 3 : 0)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
                    .padding(.trailing, 4)
            }
        }
    }
}

