//
//  CustomToggle.swift
//  BladeTricks
//
//  Created by Victor on 2025-03-18.
//

import Foundation
import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    var onColor: Color = Color(red: 0.55, green: 0.85, blue: 0.35) // Light green color similar to the image
    var offColor: Color = Color(red: 0.95, green: 0.4, blue: 0.5) // Light pink/red color similar to the image
    var toggleSize: CGSize = CGSize(width: 80, height: 30) // Smaller default size
    
    var body: some View {
        ZStack {
            // Background capsule
            Capsule()
                .fill(Color.black)
                .frame(width: toggleSize.width, height: toggleSize.height)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Yes/No text positioned to ensure visibility with knob position
            HStack(spacing: 0) {
                Text("YES")
                    .foregroundColor(isOn ? onColor : .gray.opacity(0.4))
                    .font(.system(size: toggleSize.height * 0.4, weight: .bold))
                    .frame(width: toggleSize.width * 0.5, alignment: .center)
                
                Text("NO")
                    .foregroundColor(!isOn ? offColor : .gray.opacity(0.4))
                    .font(.system(size: toggleSize.height * 0.4, weight: .bold))
                    .frame(width: toggleSize.width * 0.5, alignment: .center)
            }
            
            // Toggle knob
            Circle()
                .fill(Color(white: 0.3))
                .frame(width: toggleSize.height - 4, height: toggleSize.height - 4)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                .overlay(
                    Circle()
                        .fill(isOn ? onColor : offColor)
                        .frame(width: toggleSize.height - 10, height: toggleSize.height - 10)
                )
                .offset(x: isOn ? toggleSize.width * 0.25 : -toggleSize.width * 0.25)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation {
                isOn.toggle()
            }
        }
    }
}

// Preview provider
struct CustomToggle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Text("Enable feature:")
                        .foregroundColor(.white)
                    CustomToggle(isOn: .constant(true))
                }
                
                HStack {
                    Text("Another option:")
                        .foregroundColor(.white)
                    CustomToggle(isOn: .constant(false))
                }
            }
            .padding()
        }
    }
}
