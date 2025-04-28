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
        VStack(spacing: 8) {
            // Header with title and percentage
            HStack {
                // Icon and title
                HStack(spacing: 4) {
                    Image(systemName: iconForType())
                        .foregroundColor(color)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Percentage pill with minus/plus buttons on sides
                HStack(spacing: 4) {
                    // Minus button
                    Button(action: { decrementValue() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(color)
                            )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    // Percentage pill
                    Text("\(Int(value * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                        .frame(minWidth: 46)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.15))
                        )
                    
                    // Plus button
                    Button(action: { incrementValue() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(color)
                            )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            // Simple to use slider with visual step markers
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background with tap handling
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // Convert tap location to a percentage value
                            let percentage = min(max(0, location.x / geometry.size.width), 1.0)
                            let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(percentage)
                            let steppedValue = round(newValue / step) * step
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                value = max(range.lowerBound, min(range.upperBound, steppedValue))
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    
                    // Progress bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: calculateWidth(geometry: geometry), height: 8)
                    
                    // Step markers
                    HStack(spacing: 0) {
                        ForEach(0..<21) { i in
                            if i % 5 == 0 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 1, height: 12)
                                    .offset(y: isDragging ? -8 : -6)
                            } else {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 1, height: 6)
                                    .offset(y: isDragging ? -6 : -4)
                            }
                        }
                        .frame(maxWidth: .infinity)
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
                        .position(x: calculateThumbPosition(geometry: geometry), y: 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    isDragging = true
                                    
                                    // Convert drag location to a percentage value
                                    let percentage = min(max(0, gesture.location.x / geometry.size.width), 1.0)
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
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    // Helper functions
    private func calculateWidth(geometry: GeometryProxy) -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(percentage) * geometry.size.width
    }
    
    private func calculateThumbPosition(geometry: GeometryProxy) -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(percentage) * geometry.size.width
    }
    
    private func updateValueFromDrag(dragLocation: CGPoint, geometry: GeometryProxy) {
        let percentage = min(max(0, dragLocation.x / geometry.size.width), 1.0)
        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(percentage)
        let steppedValue = round(newValue / step) * step
        
        if abs(value - steppedValue) >= step / 2 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                value = max(range.lowerBound, min(range.upperBound, steppedValue))
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
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

struct ReliablePercentageControl_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                PercentageSlider(
                    value: .constant(0.55),
                    title: "Fakie Chance",
                    type: .fakie
                )
                
                PercentageSlider(
                    value: .constant(0.5),
                    title: "Topside Chance",
                    type: .topside
                )
                
                PercentageSlider(
                    value: .constant(0.0),
                    title: "Negative Chance",
                    type: .negative
                )
                
                PercentageSlider(
                    value: .constant(0.75),
                    title: "Rewind Spin Out Chance",
                    type: .rewind
                )
            }
            .padding(24)
        }
    }
}
