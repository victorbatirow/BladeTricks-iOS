//
//  SettingsView.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-29.
//

import SwiftUI

struct SettingsView: View {
    var bottomSheetTranslationProrated: CGFloat = 1
    @State private var selection = 0
    @ObservedObject var viewModel = TrickViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: Segmented Control
//                SegmentedControl(selection: $selection)
                
                // Displaying the current difficulty
                Text("\(viewModel.currentDifficulty.difficultyLevel.rawValue)")
//                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                
                // MARK: Forecast Cards
                ScrollViewReader { value in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Difficulty.levels, id: \.id) { difficulty in
                                DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty == difficulty)
                                    .id(difficulty.id)
                                    .onTapGesture {
                                        viewModel.setDifficulty(difficulty)
                                        withAnimation {
                                            value.scrollTo(difficulty.id, anchor: .center)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .onAppear {
                        value.scrollTo(viewModel.currentDifficulty.id, anchor: .center)
                    }
                }
                
                // MARK: Forecast Widgets
//                Image("Forecast Widgets")
//                    .opacity(bottomSheetTranslationProrated)
            }
        }
        .backgroundBlur(radius: 25, opaque: true)
        .background(Color.bottomSheetBackground)
        .clipShape(RoundedRectangle(cornerRadius: 44))
        .innerShadow(shape: RoundedRectangle(cornerRadius: 44), color: Color.bottomSheetBorderMiddle, lineWidth: 1, offsetX: 0, offsetY: 1, blur: 0, blendMode: .overlay, opacity: 1 - bottomSheetTranslationProrated)
        .overlay {
            // MARK: Bottom Sheet Separator
            Divider()
                .blendMode(.overlay)
                .background(Color.bottomSheetBorderTop)
                .frame(maxHeight: .infinity, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 44))
        }
        .overlay {
            // MARK: Drag Indicator
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.3))
                .frame(width: 48, height: 5)
                .frame(height: 20)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .background(Color.background)
            .preferredColorScheme(.dark)
    }
}
