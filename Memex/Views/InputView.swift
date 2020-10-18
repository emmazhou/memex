//
//  InputView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI

struct InputView: View {
    @ObservedObject var memex = Memex.shared

    @State var scrollProxy: ScrollViewProxy
    @Binding var typingMessage: String

    var body: some View {
        TextField("Message...", text: $typingMessage, onEditingChanged: { changed in
            if changed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation {
                        scrollProxy.scrollTo(memex.lastMessageId(), anchor: .bottom)
                    }
                }
            }
        })
        .keyboardType(.twitter)
        .autocapitalization(.none)
        .padding(8)
        .background(Styles.textFieldBackground)
        .cornerRadius(10)

        Button(action: {
            memex.addMessage(message: typingMessage)
            typingMessage = ""
        }) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 32.0, weight: .bold, design: .default))
        }
    }
}
