//
//  ContentView.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-23.
//


import SwiftUI
import BottomSheet

enum BottomSheetPosition: CGFloat, CaseIterable {
    case top = 0.83 // 702/844
    case middle = 0.385 // 325/844
}

struct ContentView: View {
    @EnvironmentObject var viewModel: TrickViewModel  // Access the shared instance
    @State var bottomSheetPosition: BottomSheetPosition = .middle
    @State var bottomSheetTranslation: CGFloat = BottomSheetPosition.middle.rawValue
    @State var hasDragged: Bool = false
    
    var bottomSheetTranslationProrated: CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.middle.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.middle.rawValue)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                let buttonOffset = screenHeight + 36
                
                ZStack {
                    // Background
                    Color.background.ignoresSafeArea()
                    
                    // Background Image
                    Image("Background").resizable().ignoresSafeArea()
                    
                    // Main Content
                    VStack {
                        Text(" ").font(.largeTitle).padding(.top, 51)
                        Text(viewModel.displayTrickName) // Display generated trick name
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        Button(action: {
                            viewModel.generateTrick() // Generate trick
                        }) {
                            Text("Generate Trick")
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 157)
                        .offset(y: -bottomSheetTranslationProrated * buttonOffset)
                        
                        Spacer()
                    }
                    
                    // Bottom Sheet
                    BottomSheetView(position: $bottomSheetPosition) {
//                        Text(bottomSheetTranslationProrated.formatted())
                    } content: {
                        SettingsView(bottomSheetTranslationProrated: bottomSheetTranslationProrated)
                            .frame(height: 700)  // Set the frame height to full screen height
                    }
                    .onBottomSheetDrag { translation in
                        bottomSheetTranslation = translation / screenHeight
                        withAnimation(.easeInOut) {
                            hasDragged = bottomSheetPosition == .top
                        }
                    }
                    
                    // Tab Bar
                    TabBar(action: {
                        bottomSheetPosition = .top
                    })
                    .offset(y: calculateTabBarOffset())
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func calculateTabBarOffset() -> CGFloat {
        let baseOffset = 115  // Base offset to hide the tab bar
        let translationThreshold: CGFloat = 0.5  // Threshold to start hiding tab bar

        // Easing the transition as the bottom sheet moves
        if bottomSheetTranslationProrated > translationThreshold {
            let adjustedTranslation = (bottomSheetTranslationProrated - translationThreshold) / (1 - translationThreshold)
            return adjustedTranslation * CGFloat(baseOffset)
        }
        return 0
    }
    
    private var attributedString: AttributedString {
        var string = AttributedString("19°" + (hasDragged ? " | " : "\n ") + "Mostly Clear")
        if let temp = string.range(of: "19°") {
            string[temp].font = .system(size: (96 - (bottomSheetTranslationProrated * (96 - 20))), weight: hasDragged ? .semibold : .thin)
            string[temp].foregroundColor = hasDragged ? .secondary : .primary
        }
        if let pipe = string.range(of: " | ") {
            string[pipe].font = .title3.weight(.semibold)
            string[pipe].foregroundColor = .secondary.opacity(bottomSheetTranslationProrated)
        }
        if let weather = string.range(of: "Mostly Clear") {
            string[weather].font = .title3.weight(.semibold)
            string[weather].foregroundColor = .secondary
        }
        return string
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TrickViewModel())
            .preferredColorScheme(.dark)
    }
}
