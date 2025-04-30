//
//  ktrecipeappApp.swift
//  ktrecipeapp
//
//  Created by csuftitan on 4/27/25.
//

import SwiftUI

@main
struct ktrecipeappApp: App {
    @AppStorage("isGuestMode") private var isGuestMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isGuestMode {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}
