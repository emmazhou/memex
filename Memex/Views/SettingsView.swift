//
//  SettingsView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var memex = Memex.shared
    
    var body: some View {
        Button(action: {
            if memex.fileUrl == nil {
                return
            }
            let viewController = UIActivityViewController(
                activityItems: [memex.fileUrl!], applicationActivities: nil
            )
            UIApplication.shared.windows.first?.rootViewController?.present(
                viewController, animated: true, completion: nil
            )
        }) {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .foregroundColor(.white)
        }
        .padding([.top, .bottom], 7)
        .padding([.leading, .trailing], 10)
        .foregroundColor(.white)
        .background(Styles.midGradient)
        .cornerRadius(10)
    }
}
