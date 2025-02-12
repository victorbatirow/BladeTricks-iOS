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
                let imageOffset = screenHeight + 36
                
                ZStack {
                    // MARK: Background Color
                    Color.background
                        .ignoresSafeArea()
                    
                    // MARK: Background Image
                    Image("Background")
                        .resizable()
                        .ignoresSafeArea()
//                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    // MARK: House Image
                    Image("House")
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 257)
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    // MARK: Current Weather
                    VStack(spacing: -10 * (1 - bottomSheetTranslationProrated)) {
                        Text("Montreal")
                            .font(.largeTitle)
                        
                        VStack {
                            Text(attributedString)
                            
                            Text("H:24°   L:18°")
                                .font(.title3.weight(.semibold))
                                .opacity(1 - bottomSheetTranslationProrated)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 51)
                    .offset(y: -bottomSheetTranslationProrated * 46)
                    
                    // MARK: Bottom Sheet
                    BottomSheetView(position: $bottomSheetPosition) {
                        Text(bottomSheetTranslationProrated.formatted())
                    } content: {
                        SettingsView(bottomSheetTranslationProrated: bottomSheetTranslationProrated)
                    }
                    .onBottomSheetDrag { translation in
                        bottomSheetTranslation = translation / screenHeight
                        
                        withAnimation(.easeInOut) {
                            if bottomSheetPosition == BottomSheetPosition.top {
                                hasDragged = true 
                            } else {
                                hasDragged = false
                            }
                        }
                    }
                    
                    // MARK: Tab Bar
                    TabBar(action: {
                        bottomSheetPosition = .top
                    })
                    .offset(y: bottomSheetTranslationProrated * 115)
                }
            }
            .navigationBarHidden(true)
        }
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
            .preferredColorScheme(.dark)
    }
}

//import SwiftUI
//
//struct ContentView: View {
//    @ObservedObject var viewModel = TrickViewModel()
//    
//    var body: some View {
//        VStack {
//            Spacer(minLength: 10)
//            
//            // MARK: Forecast Small Icon
//            Image("GeneratorTitle2")
//                .resizable()
//                .frame(width: 300, height: 100)
//            
//            Spacer(minLength: 100)
//            
//            // Trick name displayed at the top-center
//            Text(viewModel.displayTrickName)
//                .frame(maxWidth: 300, maxHeight: 100,  alignment: .center)
//                .font(
//                    .title
//                    .weight(.bold)
//                )
//                .lineLimit(nil)  // Ensures the text is not truncated
//                .multilineTextAlignment(.center)  // Centers the text for multi-line
//                .minimumScaleFactor(0.5)
//                
//            
//            Spacer(minLength: 80)  // Provides space between elements
//            
//            // Difficulty selection at the bottom
//            Text("Difficulty: \(viewModel.currentDifficulty.difficultyLevel.rawValue)")
//                .font(.headline)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(Difficulty.levels, id: \.id) { difficulty in
//                        DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty == difficulty)
//                            .onTapGesture {
//                                viewModel.setDifficulty(difficulty)
//                            }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//            }
//            
//            // Generate button at the bottom-center
//            Button(action: {
//                            viewModel.generateTrick()
//                        }) {
//                            Text("Generate Trick")
//                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white)
//                                .frame(minWidth:300, minHeight: 150)
//                            
//                        }
//                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
//                        .cornerRadius(25)
//                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
//                        .padding(.bottom, 20)
//            
//            Spacer()  // Pushes everything above to the center and bottom part of the view
//        }
//        .background(
//                    Image("Background") // Replace "YourBackgroundImageName" with the actual name of your image asset
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .edgesIgnoringSafeArea(.all) // This makes the image extend into the safe area
//                )
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
