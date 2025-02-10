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
            Text(viewModel.displayTrickName)
                .padding()
            
            Button("Generate Trick") {
                // This is where your text generation function is called
                viewModel.generateTrick()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Difficulty: \(viewModel.currentDifficulty.difficultyLevel.rawValue)")
                .font(.headline)
                .padding()
            
            ScrollView(.vertical, showsIndicators: true) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Difficulty.levels) { difficulty in
                            DifficultyCard(difficulty: difficulty, isActive: viewModel.currentDifficulty == difficulty)
                                .onTapGesture {
                                    viewModel.setDifficulty(difficulty)
                                }
                                .transition(.offset(x: -430))
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
