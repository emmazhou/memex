//
//  MemexView.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import SwiftUI

struct MemexView: View {
    @ObservedObject var memex = Memex.shared
    
    @State var typingMessage = ""
    @State private var didLongPress = false
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                ScrollView {
                    ForEach(memex.messages, id: \.time) { message in
                        HStack(alignment: .top) {
                            VStack {
                                Text(memex.dateFromDate(date: message.time))
                                    .font(.system(size: 10.0, weight: .regular, design: .default))
                                    .foregroundColor(Color(UIColor.lightGray))
                                Text(memex.timeFromDate(date: message.time))
                                    .font(.system(size: 10.0, weight: .regular, design: .default))
                                    .foregroundColor(Color(UIColor.lightGray))
                            }
                            .padding(.top, 8)

                            Spacer(minLength: 20)

                            Button(action: {
                                typingMessage = message.text
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(message.text)
                                            .font(.system(size: 16.0, weight: .semibold, design: .default))
                                        if message.comment != nil {
                                            Text(message.comment!)
                                                .font(.system(size: 16.0, weight: .regular, design: .default))
                                                .foregroundColor(Color(UIColor.init(white: 1, alpha: 0.6)))
                                        }
                                    }
                                    Spacer(minLength: 20)
                                    Image(systemName: "repeat")
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)

                        }
                        .id(message.time)
                        .padding(.top, 1)
                    }
                    .onAppear {
                        scrollProxy.scrollTo(memex.messages.last?.time, anchor: .bottom)
                    }
                }
                .onChange(of: typingMessage) { id in
                    withAnimation {
                        scrollProxy.scrollTo(memex.messages.last?.time, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $typingMessage, onEditingChanged: { changed in
                    if changed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                scrollProxy.scrollTo(memex.messages.last?.time, anchor: .bottom)
                            }
                        }
                    }
                })
                .keyboardType(.twitter)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minHeight: CGFloat(30))

                Button(action: {
                    memex.addMessage(message: typingMessage)
                    typingMessage = ""
                }) {
                    Image(systemName: "arrow.right")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }.frame(minHeight: CGFloat(50))
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.windows.forEach { $0.endEditing(false) }
        })
        .padding()
    }
    
    func scrollToEnd(scrollProxy: ScrollViewProxy) {
        withAnimation {
            scrollProxy.scrollTo(memex.messages.last?.time, anchor: .bottom)
        }
    }
}
