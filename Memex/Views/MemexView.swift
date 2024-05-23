//
//  MemexView.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import SwiftUI

struct MemexView: View {
    @ObservedObject var memex = Memex.shared

    @State private var lastMessageID = UUID()

    @State var inputFieldFocused = false
    @State var editFieldFocused = false

    @State var typingMessage = ""
    @State var editingMessage: MemexMessage? = nil
    @State var editingTime: Date? = nil
    @State var editingText: String? = nil
    
    @State var messageToDelete: MemexMessage? = nil
    @State var showDeleteConfirmation = false
    @State var isDeletingAllPrevious = false
    
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
                                .padding(.top, 5)
                            
                            ForEach(messageList.messages) { message in
                                MessageView(
                                    message: message,
                                    inputFieldFocused: $inputFieldFocused,
                                    editFieldFocused: $editFieldFocused,
                                    typingMessage: $typingMessage,
                                    editingMessage: $editingMessage,
                                    editingTime: $editingTime,
                                    editingText: $editingText,
                                    messageToDelete: $messageToDelete,
                                    showDeleteConfirmation: $showDeleteConfirmation,
                                    isDeletingAllPrevious: $isDeletingAllPrevious
                                )
                                .padding(.bottom, 5)
                            }
                        }
                    }
                    .onChange(of: lastMessageID) { newValue in
                        withAnimation {
                            scrollProxy.scrollTo(newValue, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: typingMessage) { id in
                    withAnimation {
                        scrollProxy.scrollTo(memex.lastMessageId(), anchor: .bottom)
                    }
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    if isDeletingAllPrevious {
                        return Alert(
                            title: Text("Delete all previous messages?"),
                            message: Text("This will delete \(memex.countPreviousMessages(messageToDelete!)) messages."),
                            primaryButton: .default(Text("Cancel"), action: {
                                showDeleteConfirmation = false
                            }),
                            secondaryButton: .default(Text("Delete"), action: {
                                memex.deletePreviousMessages(messageToDelete!)
                                showDeleteConfirmation = false
                            })
                        )
                    } else {
                        return Alert(
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
                }
                
                HStack {
                    if editingMessage != nil {
                        EditView(
                            focus: $editFieldFocused,
                            editingMessage: $editingMessage,
                            editingTime: $editingTime,
                            editingText: $editingText
                        )
                    } else {
                        InputView(
                            scrollProxy: scrollProxy,
                            focus: $inputFieldFocused,
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
            .navigationBarItems(
                trailing: NavigationLink(destination: SettingsView().onAppear {
                    dismissKeyboard()
                }) {
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 20.0, weight: .semibold, design: .default))
                }
            )
            .onReceive(memex.$messagesByDate) { _ in
                if let lastMessage = memex.messagesByDate.last?.messages.last {
                    lastMessageID = lastMessage.id
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FABView()
                            .padding(.bottom, 120)
                            .padding(.trailing, 10)
                    }
                }
            )
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.windows.forEach { $0.endEditing(false) }
    }
}
