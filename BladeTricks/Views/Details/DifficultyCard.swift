//
//  DifficultyCard.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-28.
//

import SwiftUI

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
                    .foregroundColor(isActive ? .clear : .white) // Clear for active to show gradient, black for inactive
                    .background(
                        LinearGradient(gradient: Gradient(colors: isActive ? [.yellow, .white] : [.black, .black]), startPoint: .bottom, endPoint: .top)
                            .mask(
                                Text(difficulty.level)
                                    .font(.headline)
                            )
                    )
                
                VStack(spacing: -10) {
                    // MARK: Forecast Small Icon
                    Image(getImageName(for: difficulty.icon, isActive: isActive))
                        .resizable()
                        .frame(width: 70, height: 70)
                    
                    // MARK: Forecast Probability
                    Text(difficulty.probability, format: .percent)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color.probabilityText)
                        .opacity(difficulty.probability > 0 ? 1 : 0)
                }
                .frame(height: 42)
                
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .frame(width: 60, height: 100)
        }
    }
    private func getImageName(for icon: String, isActive: Bool) -> String {
        isActive ? "\(icon)_active" : icon
    }
}

struct DifficultyCard_Previews: PreviewProvider {
    static var previews: some View {
        DifficultyCard(difficulty: Difficulty.levels[2], isActive: false)
    }
}
