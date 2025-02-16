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
            settingsCardView
            settingsTitle
            VStack(spacing : 20) {
                fakieChanceSlider
                topsideChanceSlider
                negativeChanceSlider
                rewindChanceSlider
            }
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
    
    private var settingsCardView: some View {
            VStack {
//                DashboardCardView(icon: "flame.fill", title: "Current streak", mainText: "1 Days", color: Color.blue)
//                DashboardCardView(icon: "rocket.fill", title: "Longest streak", mainText: "2 Days", color: Color.red)
//                DashboardCardView(icon: "star.fill", title: "Best month", mainText: "January", color: Color.purple)
//                DashboardCardView(icon: "percent", title: "Completion rate", mainText: "52%", color: Color.orange)
            }
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
        DashboardCardView(icon: "flame.fill", title: "Fakie odds", value: $viewModel.customSettings.fakieChance, color: Color.blue, applyCustomSettings: viewModel.applyCustomSettings)
    }

    private var topsideChanceSlider: some View {
        DashboardCardView(icon: "flame.fill", title: "Topside odds", value: $viewModel.customSettings.topsideChance, color: Color.blue, applyCustomSettings: viewModel.applyCustomSettings)
    }

    private var negativeChanceSlider: some View {
        DashboardCardView(icon: "flame.fill", title: "Negative odds", value: $viewModel.customSettings.negativeChance, color: Color.blue, applyCustomSettings: viewModel.applyCustomSettings)
    }

    private var rewindChanceSlider: some View {
        DashboardCardView(icon: "flame.fill", title: "Rewind odds", value: $viewModel.customSettings.rewindChance, color: Color.blue, applyCustomSettings: viewModel.applyCustomSettings)
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

struct DashboardCardView: View {
    var icon: String
    var title: String
    @Binding var value: Double  // This binds to the slider value
    var color: Color
    @State private var lastDragValue: CGFloat = 0  // To track the last drag position for direction changes
    var applyCustomSettings: () -> Void  // Callback to apply custom settings

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
                Text("\(Int(value * 100))%")  // Display the percentage value
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .padding(.top, 5)
            Spacer()
        }
        .background(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))  // Less intense color for unfilled part
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value))  // Dynamic width based on value
                }
            }
        )
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        .gesture(
            DragGesture()
                .onChanged { drag in
                    let currentDragValue = drag.translation.width
                    let direction = currentDragValue - lastDragValue
                    let adjustment = Double(direction / 300)  // Adjust sensitivity by increasing denominator
                    let proposedValue = max(0, min(1, self.value + adjustment))
                    if self.value != proposedValue {
                        self.value = proposedValue
                        applyCustomSettings()  // Apply settings when value changes
                    }
                    lastDragValue = currentDragValue  // Update last drag value for continuous adjustment
                }
                .onEnded { _ in
                    lastDragValue = 0  // Reset on gesture end
                }
        )
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
