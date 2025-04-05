//
//  BladeTricksApp.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-23.
//

import SwiftUI

@main
struct BladeTricksApp: App {
    
//    @StateObject var viewModel = TrickViewModel()  // Use @StateObject for ownership
    @StateObject var viewModel = TrickViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
