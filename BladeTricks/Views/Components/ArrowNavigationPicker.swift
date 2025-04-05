//
//  ArrowNavigationPicker.swift
//  BladeTricks
//
//  Created on 2025-03-10.
//

import SwiftUI

struct ArrowNavigationPicker: View {
    @Binding var selection: Int
    let options = ["Single Trick", "Double Switch-up", "Triple Switch-up"]
    
    var body: some View {
        HStack(spacing: 20) {
            // Left arrow button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selection > 0 {
                        selection -= 1
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selection > 0 ? .white : .gray)
            }
            .disabled(selection <= 0)
            
            // Current selection text
            Text(options[selection])
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 150)
                .transition(.opacity)
                .id(selection) // Add id to trigger animation when text changes
            
            // Right arrow button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selection < options.count - 1 {
                        selection += 1
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selection < options.count - 1 ? .white : .gray)
            }
            .disabled(selection >= options.count - 1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // No background - completely transparent
    }
}

// Optional: Preview provider
struct ArrowNavigationPicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Add background to preview so we can see the transparent effect
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            ArrowNavigationPicker(selection: .constant(1))
                .padding()
        }
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
