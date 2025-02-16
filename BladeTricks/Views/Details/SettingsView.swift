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
    @EnvironmentObject var viewModel: TrickViewModel  // Use the shared view model
    
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
                                DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty.id == difficulty.id)
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
                    
                    if viewModel.currentDifficulty.isCustom {
                        customSettingsView
                    }
                }
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
    
    private var customSettingsView: some View {
        Group {
            settingsTitle
            fakieChanceSlider
            topsideChanceSlider
            negativeChanceSlider
            rewindChanceSlider
            tricksCAPSlider
            soulplateForwardInSpinsCAPSlider
            soulplateFakieInSpinsCAPSlider
            soulplateForwardOutSpinsCAPSlider
            soulplateFakieOutSpinsCAPSlider
            grooveForwardInSpinsCAPSlider
            grooveFakieInSpinsCAPSlider
            grooveSidewaysOutSpinsCAPSlider
        }
        .opacity(Double(bottomSheetTranslationProrated))
    }

    private var settingsTitle: some View {
        Text("Customize Your Difficulty")
            .font(.headline)
            .padding()
    }

    private func sliderView(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack {
            Text("\(title): \(Int(value.wrappedValue * 100))%")
                .fontWeight(.semibold)
            Slider(value: value, in: range, step: step)
                .onChange(of: value.wrappedValue) {
                    viewModel.applyCustomSettings()
                }
        }.padding()
    }

    private var fakieChanceSlider: some View {
        sliderView(title: "Fakie Chance", value: $viewModel.customSettings.fakieChance, range: 0...1, step: 0.05)
    }

    private var topsideChanceSlider: some View {
        sliderView(title: "Topside Chance", value: $viewModel.customSettings.topsideChance, range: 0...1, step: 0.05)
    }

    private var negativeChanceSlider: some View {
        sliderView(title: "Negative Chance", value: $viewModel.customSettings.negativeChance, range: 0...1, step: 0.05)
    }

    private var rewindChanceSlider: some View {
        sliderView(title: "Rewind Chance", value: $viewModel.customSettings.rewindChance, range: 0...1, step: 0.05)
    }

    private var tricksCAPSlider: some View {
        VStack {
            Text("Bag of Tricks: \(viewModel.customSettings.tricksCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.tricksCAP) },
                set: { viewModel.customSettings.tricksCAP = Int($0) }
            ), in: 5...Double(viewModel.allTricks.count), step: 1)
            .onChange(of: viewModel.customSettings.tricksCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.allTricks.prefix(viewModel.customSettings.tricksCAP), id: \.self) { trick in
                        Text(trick).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }
    
    private var soulplateForwardInSpinsCAPSlider: some View {
        VStack {
            Text("Soulplate Forward In Spins CAP: \(viewModel.customSettings.soulplateForwardInSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.soulplateForwardInSpinsCAP) },
                set: { viewModel.customSettings.soulplateForwardInSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.soulplateForwardInSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.soulplateForwardInSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.soulplateForwardInSpins.prefix(viewModel.customSettings.soulplateForwardInSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }
    
    private var soulplateFakieInSpinsCAPSlider: some View {
        VStack {
            Text("Soulplate Fakie In Spins CAP: \(viewModel.customSettings.soulplateFakieInSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.soulplateFakieInSpinsCAP) },
                set: { viewModel.customSettings.soulplateFakieInSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.soulplateFakieInSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.soulplateFakieInSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.soulplateFakieInSpins.prefix(viewModel.customSettings.soulplateFakieInSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }

    private var soulplateForwardOutSpinsCAPSlider: some View {
        VStack {
            Text("Soulplate Forward Out Spins CAP: \(viewModel.customSettings.soulplateForwardOutSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.soulplateForwardOutSpinsCAP) },
                set: { viewModel.customSettings.soulplateForwardOutSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.soulplateForwardOutSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.soulplateForwardOutSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.soulplateForwardOutSpins.prefix(viewModel.customSettings.soulplateForwardOutSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }

    private var soulplateFakieOutSpinsCAPSlider: some View {
        VStack {
            Text("Soulplate Fakie Out Spins CAP: \(viewModel.customSettings.soulplateFakieOutSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.soulplateFakieOutSpinsCAP) },
                set: { viewModel.customSettings.soulplateFakieOutSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.soulplateFakieOutSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.soulplateFakieOutSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.soulplateFakieOutSpins.prefix(viewModel.customSettings.soulplateFakieOutSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }

    private var grooveForwardInSpinsCAPSlider: some View {
        VStack {
            Text("Groove Forward In Spins CAP: \(viewModel.customSettings.grooveForwardInSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.grooveForwardInSpinsCAP) },
                set: { viewModel.customSettings.grooveForwardInSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.grooveForwardInSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.grooveForwardInSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.grooveForwardInSpins.prefix(viewModel.customSettings.grooveForwardInSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }

    private var grooveFakieInSpinsCAPSlider: some View {
        VStack {
            Text("Groove Fakie In Spins CAP: \(viewModel.customSettings.grooveFakieInSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.grooveFakieInSpinsCAP) },
                set: { viewModel.customSettings.grooveFakieInSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.grooveFakieInSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.grooveFakieInSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.grooveFakieInSpins.prefix(viewModel.customSettings.grooveFakieInSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }

    private var grooveSidewaysOutSpinsCAPSlider: some View {
        VStack {
            Text("Groove Sideways Out Spins CAP: \(viewModel.customSettings.grooveSidewaysOutSpinsCAP)")
                .fontWeight(.semibold)
            Slider(value: Binding(
                get: { Double(viewModel.customSettings.grooveSidewaysOutSpinsCAP) },
                set: { viewModel.customSettings.grooveSidewaysOutSpinsCAP = Int($0) }
            ), in: 0...Double(viewModel.grooveSidewaysOutSpins.count), step: 1)
            .onChange(of: viewModel.customSettings.grooveSidewaysOutSpinsCAP) {
                viewModel.applyCustomSettings()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.grooveSidewaysOutSpins.prefix(viewModel.customSettings.grooveSidewaysOutSpinsCAP), id: \.self) { spin in
                        Text(spin).font(.caption)
                    }
                }
            }.frame(height: 20)
        }.padding()
    }


}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(bottomSheetTranslationProrated: 1)
            .environmentObject(TrickViewModel())  // Providing the environment object here
            .background(Color.background)
            .preferredColorScheme(.dark)
    }
}
