//
//  MainView.swift
//  ktrecipeapp
//
//  Created by Keith Bui on 4/30/25.
//

import SwiftUI

struct MainView: View {
    @AppStorage("isGuestMode") private var isGuestMode: Bool = true

    var body: some View {
        NavigationView() {
            NavigationLink{
                MainView().navigationBarBackButtonHidden(true).onAppear() {
                    isGuestMode = false
                }
            } label: {
                Text("Exit Guest").font(.footnote)
            }
        }
    }
}

#Preview {
    MainView()
}
