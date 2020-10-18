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
    @State var editingMessage: MemexMessage? = nil
    @State var editingTime: Date? = nil
    @State var editingText: String? = nil
    
    @State var messageToDelete: MemexMessage? = nil
    @State var showDeleteConfirmation = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    ForEach(memex.messagesByDate) { messageList in
                        VStack {
                            Text(Util.formatDate(date: messageList.date))
                                .font(.system(size: 12.0, weight: .semibold, design: .default))
                                .foregroundColor(Color(UIColor.lightGray))
                            
                            ForEach(messageList.messages) { message in
                                MessageView(
                                    message: message,
                                    typingMessage: $typingMessage,
                                    editingMessage: $editingMessage,
                                    editingTime: $editingTime,
                                    editingText: $editingText,
                                    messageToDelete: $messageToDelete,
                                    showDeleteConfirmation: $showDeleteConfirmation
                                )
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                scrollProxy.scrollTo(memex.lastMessageId(), anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: typingMessage) { id in
                    withAnimation {
                        scrollProxy.scrollTo(memex.lastMessageId(), anchor: .bottom)
                    }
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete message?"),
                        message: Text(memex.getTextAndComment(messageToDelete!)),
                        primaryButton: .default(Text("Cancel"), action: {
                            messageToDelete = nil
                            showDeleteConfirmation = false
                        }),
                        secondaryButton: .default(Text("Delete"), action: {
                            memex.deleteMessage(uuid: messageToDelete!.id)
                            messageToDelete = nil
                            showDeleteConfirmation = false
                        })
                    )
                }
                
                HStack {
                    if editingMessage != nil {
                        EditView(
                            editingMessage: $editingMessage,
                            editingTime: $editingTime,
                            editingText: $editingText
                        )
                    } else {
                        InputView(
                            scrollProxy: scrollProxy,
                            typingMessage: $typingMessage
                        )
                    }
                }
                .frame(minHeight: CGFloat(50))
                .padding(.leading, 15)
                .padding([.trailing, .bottom], 10)
            }
            .gesture(DragGesture().onChanged { _ in
                dismissKeyboard()
            })
            .navigationBarTitle("Memex")
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.system(size: 24.0, weight: .black, design: .default))
                }
            )
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.windows.forEach { $0.endEditing(false) }
    }
}