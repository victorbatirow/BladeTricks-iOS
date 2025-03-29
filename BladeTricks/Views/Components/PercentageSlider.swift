import SwiftUI

struct PercentageSlider: View {
    @Binding var value: Double
    var title: String
    var type: ControlType = .custom
    var range: ClosedRange<Double> = 0...1
    var step: Double = 0.05
    
    @State private var isDragging = false
    
    var color: Color {
        switch type {
        case .fakie:    return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .topside:  return Color(red: 0.3, green: 0.85, blue: 0.4)
        case .negative: return Color(red: 1.0, green: 0.4, blue: 0.3)
        case .rewind:   return Color(red: 0.8, green: 0.4, blue: 0.9)
        case .custom:   return Color.blue
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Title and icon
            HStack(spacing: 4) {
                Image(systemName: iconForType())
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Percentage controls - centered
            HStack(spacing: 8) {
                Spacer()
                
                // Minus button - more subtle design
                Button(action: { decrementValue() }) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(color.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Percentage pill - made more prominent
                Text("\(Int(value * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                    .frame(minWidth: 42)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .strokeBorder(color.opacity(0.4), lineWidth: 1)
                            )
                    )
                
                // Plus button - more subtle design
                Button(action: { incrementValue() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(color.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
            }
            
            // Simple to use slider with visual step markers
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background with tap handling
                    // Reduce width by slider thumb radius at both ends
                    let sliderInset: CGFloat = 14  // Increased inset from edge
                    let usableWidth = geometry.size.width - (sliderInset * 2)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: usableWidth, height: 8)
                        .position(x: geometry.size.width/2, y: 12)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // Adjust for the inset when calculating value
                            let adjustedX = max(sliderInset, min(location.x, geometry.size.width - sliderInset))
                            let percentage = (adjustedX - sliderInset) / usableWidth
                            let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(percentage)
                            let steppedValue = round(newValue / step) * step
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                value = max(range.lowerBound, min(range.upperBound, steppedValue))
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    
                    // Progress bar
                    Rectangle()
                        .fill(color)
                        .frame(width: calculateWidth(geometry: geometry, inset: sliderInset, usableWidth: usableWidth), height: 8)
                        .position(x: sliderInset + calculateWidth(geometry: geometry, inset: sliderInset, usableWidth: usableWidth)/2, y: 12)
                    
                    // Step markers - positioned to align with the slider track
                    ZStack {
                        ForEach(0..<21) { i in
                            let markerX = sliderInset + (usableWidth / 20 * CGFloat(i))
                            if i % 5 == 0 {
                                // Major markers (0%, 25%, 50%, 75%, 100%)
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 1, height: 12)
                                    .position(x: markerX, y: 10)
                            } else {
                                // Minor markers
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 1, height: 6)
                                    .position(x: markerX, y: 11)
                            }
                        }
                    }
                    
                    // Draggable thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: color.opacity(0.5), radius: isDragging ? 4 : 2, x: 0, y: 0)
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: 2)
                        )
                        .position(x: calculateThumbPosition(geometry: geometry, inset: sliderInset, usableWidth: usableWidth), y: 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    isDragging = true
                                    
                                    // Adjust for the inset when calculating value
                                    let adjustedX = max(sliderInset, min(gesture.location.x, geometry.size.width - sliderInset))
                                    let percentage = (adjustedX - sliderInset) / usableWidth
                                    let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(percentage)
                                    let steppedValue = round(newValue / step) * step
                                    
                                    if abs(value - steppedValue) >= step / 2 {
                                        value = max(range.lowerBound, min(range.upperBound, steppedValue))
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                        )
                }
                .frame(height: 24)
            }
            .frame(height: 30)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // Helper functions - updated to account for inset
    private func calculateWidth(geometry: GeometryProxy, inset: CGFloat, usableWidth: CGFloat) -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(percentage) * usableWidth
    }
    
    private func calculateThumbPosition(geometry: GeometryProxy, inset: CGFloat, usableWidth: CGFloat) -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return inset + (CGFloat(percentage) * usableWidth)
    }
    
    private func incrementValue() {
        let newValue = min(range.upperBound, value + step)
        if newValue != value {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                value = newValue
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func decrementValue() {
        let newValue = max(range.lowerBound, value - step)
        if newValue != value {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                value = newValue
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func isCloseToValue(_ preset: Double) -> Bool {
        return abs(value - preset) < 0.001
    }
    
    private func iconForType() -> String {
        switch type {
        case .fakie:    return "arrow.left.arrow.right"
        case .topside:  return "arrow.up"
        case .negative: return "minus.circle"
        case .rewind:   return "arrow.clockwise"
        case .custom:   return "slider.horizontal.3"
        }
    }
}

extension PercentageSlider {
    enum ControlType {
        case fakie, topside, negative, rewind, custom
    }
}
