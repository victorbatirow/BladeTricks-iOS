//
//  SettingsView.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-29.
//

import SwiftUI
import Combine

// Move these outside of SettingsView struct, at file scope level
struct CustomSliderStyle: ViewModifier {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    func body(content: Content) -> some View {
        content
            .opacity(0.001) // Almost invisible but still interactive
            .background(
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // Filled bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: fillWidth(totalWidth: geometry.size.width), height: 6)
                        
                        // Drag circle
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .position(x: fillWidth(totalWidth: geometry.size.width), y: geometry.size.height / 2)
                            .shadow(radius: 2)
                    }
                }
                .allowsHitTesting(false) // Make the overlay non-interactive
            )
    }
    
    private func fillWidth(totalWidth: CGFloat) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return max(10, min(totalWidth, totalWidth * CGFloat(percent)))
    }
}

extension View {
    func customSliderStyle(value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        self.modifier(CustomSliderStyle(value: value, range: range))
    }
}

struct SettingsView: View {
    var bottomSheetTranslationProrated: CGFloat = 1
    @State private var selection = 0
    @EnvironmentObject var viewModel: TrickViewModel  // Use the shared view model
    private var currentSettings: Difficulty.DifficultySettings {
        // Don't force a complete view refresh, but still ensure our value is reactive
        let _ = viewModel.currentDifficulty.difficultyLevel
        
        if viewModel.currentDifficulty.isCustom {
            return viewModel.customSettings
        } else {
            // Get the settings directly from the difficulty levels array to ensure we get fresh data
            if let matchingDifficulty = Difficulty.levels.first(where: { $0.difficultyLevel == viewModel.currentDifficulty.difficultyLevel }) {
                return matchingDifficulty.settings
            }
            return viewModel.currentDifficulty.settings
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Displaying the current difficulty
                Text("\(viewModel.currentDifficulty.difficultyLevel.rawValue)")
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                
                // MARK: Difficulty Cards
                ScrollViewReader { value in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Difficulty.levels, id: \.id) { difficulty in
                                DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty.id == difficulty.id)
                                    .id(difficulty.id)
                                    .onTapGesture {
                                        // First set the difficulty without animation
                                        viewModel.setDifficulty(difficulty)
                                        
                                        // Then perform the scroll with animation
                                        withAnimation(.easeInOut(duration: 0.3)) {
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
                
                // MARK: Switch-Up Picker after difficulty cards (in a separate section)
                VStack {
                    ArrowNavigationPicker(selection: $viewModel.SwitchUpMode)
                }
                .padding(.top, 20)
                .zIndex(-1) // Ensure it's below other interactive elements

                Divider()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .opacity(Double(bottomSheetTranslationProrated))

                customSettingsView
                    .disabled(!viewModel.currentDifficulty.isCustom)  // Disable if not custom settings
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
        .onChange(of: viewModel.currentDifficulty.id) { _ in
            print("Difficulty changed to: \(viewModel.currentDifficulty.difficultyLevel.rawValue)")
            print("Fakie Chance: \(viewModel.currentDifficulty.settings.fakieChance)")
            print("Topside Chance: \(viewModel.currentDifficulty.settings.topsideChance)")
            print("Current Settings Fakie Chance: \(currentSettings.fakieChance)")
        }
    }
    
    private var customSettingsView: some View {
        Group {
            // Bag of Tricks moved to top, right after title
            tricksCAPSlider
                .padding(.bottom, 12) // Add bottom padding for spacing
            
            // Probabilities in a 2-column grid layout
            VStack(spacing: 12) {
                // Row 1: Fakie and Topside
                HStack(spacing: 12) {
                    fakieChanceSlider
                        .frame(maxWidth: .infinity)
                    rewindChanceSlider
                        .frame(maxWidth: .infinity)
                }
                
                // Row 2: Negative and Rewind
                HStack(spacing: 12) {
                    topsideChanceSlider
                        .frame(maxWidth: .infinity)
                    negativeChanceSlider
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Spin Settings Views - these have been updated to work with the new approach
            // In Spins Settings
            SpinSettingsView(manager: viewModel.inSpinManager)
                .environmentObject(viewModel)
                .padding(.top, 8)

            // Out Spins Settings
            SpinSettingsView(manager: viewModel.outSpinManager)
                .environmentObject(viewModel)
                .padding(.top, 8)

            // Switch-Up Spins Settings
            SpinSettingsView(manager: viewModel.switchUpSpinManager)
                .environmentObject(viewModel)
                .padding(.top, 8)
                
            switchUpRewindToggle
            
            Spacer(minLength: 50)
            Text("Scroll to top button goes here").opacity(0.2)
            Spacer(minLength: 50)
        }
        .opacity(Double(bottomSheetTranslationProrated))
    }

    private func sliderView(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }
            
            CustomSlider(value: value, range: range, step: step)
                .onChange(of: value.wrappedValue) {
                    viewModel.applyCustomSettings()
                }
        }.padding(.horizontal)
    }
    
    // MARK: Sliders for percentages
    
    private var fakieChanceSlider: some View {
        // Use a binding that only writes to customSettings when in custom mode
        let binding = Binding<Double>(
            get: { self.currentSettings.fakieChance },
            set: { newValue in
                if viewModel.currentDifficulty.isCustom {
                    viewModel.customSettings.fakieChance = newValue
                    viewModel.applyCustomSettings()
                }
            }
        )
        return PercentageSlider(
            value: binding,
            title: "Fakie In",
            type: .fakie
        )
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
    }

    private var topsideChanceSlider: some View {
        let binding = Binding<Double>(
            get: { self.currentSettings.topsideChance },
            set: { newValue in
                if viewModel.currentDifficulty.isCustom {
                    viewModel.customSettings.topsideChance = newValue
                    viewModel.applyCustomSettings()
                }
            }
        )
        return PercentageSlider(
            value: binding,
            title: "Topside",
            type: .topside
        )
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
    }

    private var negativeChanceSlider: some View {
        let binding = Binding<Double>(
            get: { self.currentSettings.negativeChance },
            set: { newValue in
                if viewModel.currentDifficulty.isCustom {
                    viewModel.customSettings.negativeChance = newValue
                    viewModel.applyCustomSettings()
                }
            }
        )
        return PercentageSlider(
            value: binding,
            title: "Negative",
            type: .negative
        )
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
    }

    private var rewindChanceSlider: some View {
        let binding = Binding<Double>(
            get: { self.currentSettings.rewindOutChance },
            set: { newValue in
                if viewModel.currentDifficulty.isCustom {
                    viewModel.customSettings.rewindOutChance = newValue
                    viewModel.applyCustomSettings()
                }
            }
        )
        return PercentageSlider(
            value: binding,
            title: "Rewind Out",
            type: .rewind
        )
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
    }

    // MARK: Slider for tricks
    
    private var tricksCAPSlider: some View {
        CompactRangeSlider(
            value: Binding<Int>(
                get: { self.currentSettings.tricksCAP },
                set: { newValue in
                    if viewModel.currentDifficulty.isCustom {
                        viewModel.customSettings.tricksCAP = newValue
                        viewModel.applyCustomSettings()
                    }
                }
            ),
            title: "Bag of Tricks",
            range: 1...viewModel.allTricks.count,
            totalItems: viewModel.allTricks.count,
            items: viewModel.allTricks,
            showMoreButton: true
        )
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
    }
    
    // MARK: Toggle for switchUpRewind
    
    private var switchUpRewindToggle: some View {
        HStack {
            Text("Rewinds on Switch-Ups:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            CustomToggle(
                isOn: Binding<Bool>(
                    get: { self.currentSettings.switchUpRewindAllowed },
                    set: { newValue in
                        if viewModel.currentDifficulty.isCustom {
                            viewModel.customSettings.switchUpRewindAllowed = newValue
                            viewModel.applyCustomSettings()
                        }
                    }
                ),
                toggleSize: CGSize(width: 80, height: 30)
            )
            .disabled(!viewModel.currentDifficulty.isCustom)
            .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Helper View Components

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    @Environment(\.isEnabled) private var isEnabled
    
    @GestureState private var isDragging = false
    @State private var startLocation: CGFloat?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Container rectangle
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(isEnabled ? 0.3 : 0.15), lineWidth: 2)
                    .background(Color.gray.opacity(isEnabled ? 0.1 : 0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(height: 12)
                
                // Fill rectangle
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? Color.blue : Color.gray)
                    .opacity(isEnabled ? 1.0 : 0.5)
                    .frame(width: self.getWidth(width: geometry.size.width), height: 12)
            }
            .gesture(isEnabled ?
                DragGesture(minimumDistance: 8)
                    .updating($isDragging) { value, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        // Store initial location on first touch
                        if startLocation == nil {
                            startLocation = gesture.location.x
                            
                            // Check if the gesture is more vertical than horizontal
                            let verticalMovement = abs(gesture.translation.height)
                            let horizontalMovement = abs(gesture.translation.width)
                            
                            // If moving more vertically, don't handle the slider
                            if verticalMovement > horizontalMovement {
                                startLocation = nil
                                return
                            }
                        }
                        
                        guard let start = startLocation else { return }
                        
                        let width = geometry.size.width
                        let xPos = start + gesture.translation.width
                        let percent = Double(xPos / width)
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * percent
                        let steppedValue = round(newValue / step) * step
                        value = max(range.lowerBound, min(range.upperBound, steppedValue))
                    }
                    .onEnded { _ in
                        startLocation = nil
                    }
                : nil  // No gesture when disabled
            )
        }
        .frame(height: 12)
    }
    
    private func getWidth(width: CGFloat) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return max(0, min(width, width * CGFloat(percent)))
    }
}

// The remaining helper views (CAPSliderView, SpinOptionCAPSliderView) can be
// left in place as they're used for trick selection only, not spin selection

// Keep the existing CAPSliderView for string arrays (for trick names)
struct CAPSliderView: View {
    let title: String
    let currentValue: Int
    let values: [String]
    let range: ClosedRange<Double>
    let onValueChanged: (Int) -> Void
    @Environment(\.isEnabled) private var isEnabled // Get the current enabled state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isEnabled ? .secondary : .secondary.opacity(0.7))
                Spacer()
                Text("\(currentValue)")
                    .font(.subheadline.bold())
                    .foregroundColor(isEnabled ? .primary : .primary.opacity(0.7))
            }
            
            CustomSlider(
                value: Binding(
                    get: { Double(currentValue) },
                    set: { onValueChanged(Int($0)) }
                ),
                range: range,
                step: 1
            )
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(values.prefix(currentValue), id: \.self) { value in
                            Text(value)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(isEnabled ? 0.2 : 0.1))
                                .cornerRadius(4)
                                .id(value)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 4)
                    .animation(.easeInOut(duration: 0.3), value: currentValue)
                    .opacity(isEnabled ? 1.0 : 0.7) // Reduce opacity when disabled
                }
                .onChange(of: currentValue) { newValue in
                    if let lastValue = values.prefix(newValue).last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastValue, anchor: .trailing)
                            }
                        }
                    }
                }
            }
            .frame(height: 30)
        }
        .padding(.horizontal)
    }
}

// Add a new SpinOptionCAPSliderView for Spin arrays
struct SpinOptionCAPSliderView: View {
    let title: String
    let currentValue: Int
    let spinOptions: [Spin]  // Changed from [TrickViewModel.SpinOption]
    let range: ClosedRange<Double>
    let onValueChanged: (Int) -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isEnabled ? .secondary : .secondary.opacity(0.7))
                Spacer()
                Text("\(currentValue)")
                    .font(.subheadline.bold())
                    .foregroundColor(isEnabled ? .primary : .primary.opacity(0.7))
            }
            
            CustomSlider(
                value: Binding(
                    get: { Double(currentValue) },
                    set: { onValueChanged(Int($0)) }
                ),
                range: range,
                step: 1
            )
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(spinOptions.prefix(currentValue), id: \.id) { spin in
                            Text(spin.name.isEmpty ? "No Spin" : spin.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    getBackgroundColor(for: spin)
                                        .opacity(isEnabled ? 0.2 : 0.1)
                                )
                                .cornerRadius(4)
                                .id(spin.id)  // Use id instead of name for uniqueness
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 4)
                    .animation(.easeInOut(duration: 0.3), value: currentValue)
                    .opacity(isEnabled ? 1.0 : 0.7)
                }
                .onChange(of: currentValue) { newValue in
                    if let lastOption = spinOptions.prefix(newValue).last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastOption.id, anchor: .trailing)
                            }
                        }
                    }
                }
            }
            .frame(height: 30)
        }
        .padding(.horizontal)
    }
    
    // Updated to work with Spin type
    private func getBackgroundColor(for spin: Spin) -> Color {
        switch spin.direction {
        case .left:
            return .blue
        case .right:
            return .green
        case .neutral:
            return .secondary
        }
    }
}
