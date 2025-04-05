//
//  SwitchUpPicker.swift
//  BladeTricks
//
//  Created on 2025-03-10.
//

import SwiftUI
import UIKit

struct SwitchUpPicker: UIViewRepresentable {
    @Binding var selection: Int
    let options = ["Single Trick", "Double Switch-up", "Triple Switch-up"]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        
        // Set initial selection
        picker.selectRow(selection, inComponent: 0, animated: false)
        
        // Center the picker
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Customize appearance
        picker.tintColor = UIColor.white
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.selectRow(selection, inComponent: 0, animated: true)
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: SwitchUpPicker
        
        init(_ parent: SwitchUpPicker) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.options.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return parent.options[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selection = row
        }
        
        // Optional: Customize the view for each row
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.text = parent.options[row]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .white
            return label
        }
        
        // Optional: Set the row height
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 36
        }
    }
}

// Create a container that clips the picker to a specific height
struct ClippedSwitchUpPicker: View {
    @Binding var selection: Int
    var height: CGFloat = 100
    
    var body: some View {
        // Container with clipping
        ZStack {
            // Background to make clipping area visible if needed
            Color.clear
            
            // The actual picker
            SwitchUpPicker(selection: $selection)
                // Make picker taller than the container to ensure it fills the space
                .frame(height: height * 1.2)
        }
        .frame(height: height)
        .clipped() // This is the key - clip anything outside the container
    }
}

// Optional: Preview provider
struct SwitchUpPicker_Previews: PreviewProvider {
    static var previews: some View {
        ClippedSwitchUpPicker(selection: .constant(1))
            .frame(height: 100)
            .background(Color.black.opacity(0.2))
            .previewLayout(.sizeThatFits)
    }
}
