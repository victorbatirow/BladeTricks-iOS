//
//  ContentView.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TrickViewModel()
    
    var body: some View {
        VStack {
            Spacer(minLength: 10)
            
            // MARK: Forecast Small Icon
            Image("GeneratorTitle2")
                .resizable()
                .frame(width: 300, height: 100)
            
            Spacer(minLength: 100)
            
            // Trick name displayed at the top-center
            Text(viewModel.displayTrickName)
                .frame(maxWidth: 300, maxHeight: 100,  alignment: .center)
                .font(
                    .title
                    .weight(.bold)
                )
                .lineLimit(nil)  // Ensures the text is not truncated
                .multilineTextAlignment(.center)  // Centers the text for multi-line
                .minimumScaleFactor(0.5)
                
            
            Spacer(minLength: 80)  // Provides space between elements
            
            // Difficulty selection at the bottom
            Text("Difficulty: \(viewModel.currentDifficulty.difficultyLevel.rawValue)")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Difficulty.levels, id: \.id) { difficulty in
                        DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty == difficulty)
                            .onTapGesture {
                                viewModel.setDifficulty(difficulty)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            // Generate button at the bottom-center
            Button(action: {
                            viewModel.generateTrick()
                        }) {
                            Text("Generate Trick")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth:300, minHeight: 150)
                            
                        }
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 20)
            
            Spacer()  // Pushes everything above to the center and bottom part of the view
        }
        .background(
                    Image("Background") // Replace "YourBackgroundImageName" with the actual name of your image asset
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all) // This makes the image extend into the safe area
                )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
