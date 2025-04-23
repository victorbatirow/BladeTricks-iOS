//
//  DifficultyCard.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-28.
//

import SwiftUI
import BottomSheet

struct DifficultyCard: View {
    var difficulty: Difficulty
    var isActive: Bool
    
    var body: some View {
        ZStack {
            // MARK: Card
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.difficultyCardBackground.opacity(isActive ? 1 : 0.4))
                .frame(width: 60, height: 100)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 4)
                .overlay {
                    // MARK: Card Border
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.white.opacity(isActive ? 0.5 : 0.2))
                        .blendMode(.overlay)
                }
                .innerShadow(shape: RoundedRectangle(cornerRadius: 15), color: .white.opacity(0.25), lineWidth: 1, offsetX: 1, offsetY: 1, blur: 0, blendMode: .overlay)
            
            // MARK: Content
            VStack(spacing: 15) {
                // Conditional gradient text
                Text(difficulty.level)
                    .font(.headline)
                    .frame(width: 60, height: 20, alignment: .center)
                    .foregroundColor(isActive ? .clear : .white.opacity(0.6)) // Use opacity for inactive text
                    .background(
                        LinearGradient(gradient: Gradient(colors: isActive ? [.yellow, .white] : [.clear, .clear]), startPoint: .bottom, endPoint: .top)
                            .mask(
                                Text(difficulty.level)
                                    .font(.headline)
                            )
                    )
                
                VStack(spacing: -10) {
                    // MARK: Difficulty Level Icon - Use the active/inactive versions
                    Image(getIconName(for: difficulty))
                        .resizable()
                        .frame(width: 70, height: 70)
                        .colorMultiply(isActive ? .white : .gray) // Apply gray tint when inactive
                        .opacity(isActive ? 1.0 : 0.6) // Reduce opacity when inactive
                    
                    // MARK: Forecast Probability
                    Text("")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color.probabilityText)
                }
                .frame(height: 42)
                
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .frame(width: 60, height: 100)
        }
    }
    
    // Use this function to get the appropriate icon name
    private func getIconName(for difficulty: Difficulty) -> String {
        isActive ? "\(difficulty.icon)_active" : difficulty.icon
    }
}
