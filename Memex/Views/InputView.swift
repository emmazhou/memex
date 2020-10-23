//
//  InputView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI
import Introspect

struct InputView: View {
    @ObservedObject var memex = Memex.shared

    @State var scrollProxy: ScrollViewProxy
    @Binding var focus: Bool
    @Binding var typingMessage: String
    
    @FetchRequest(
        entity: MessageType.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MessageType.verb, ascending: true)
        ]
    ) var messageTypes: FetchedResults<MessageType>

    var body: some View {
        VStack {
            if messageTypes.count > 0 {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(messageTypes.indices, id: \.self) { index in
                            let messageType = messageTypes[index]
                            Button(action: {
                                typingMessage = messageType.verb ?? ""
                                focus = true
                            }) {
                                Text(messageType.verb ?? "unknown")
                                    .font(.system(size: 16.0, weight: .semibold, design: .default))
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Styles.warmGradient)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top, 10)
            }
            
            HStack {
                TextField("Message...", text: $typingMessage, onEditingChanged: { changed in
                    if changed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                .introspectTextField { field in
                    if focus {
                        field.becomeFirstResponder()
                        focus = false
                    }
                }

                Button(action: {
                    memex.addMessage(message: typingMessage)
                    typingMessage = ""
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32.0, weight: .bold, design: .default))
                }
            }
        }
    }
}
