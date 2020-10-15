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
    
    private var roundedShape = RoundedRectangle(cornerRadius: 10, style: .continuous)
    
    private var salmon = Color(UIColor(red: 0.99, green: 0.42, blue: 0.5, alpha: 1))
    private var sky = Color(UIColor(red: 0.2, green: 0.6, blue: 0.84, alpha: 1))
    private var peri = Color(UIColor(red: 0.5, green: 0.46, blue: 0.87, alpha: 1))
    private var lavender = Color(UIColor(red: 0.58, green: 0.35, blue: 0.82, alpha: 1))
    private var magenta = Color(UIColor(red: 1, green: 0.28, blue: 0.72, alpha: 1))
    private var offwhite = Color(UIColor.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
    
    var body: some View {
        let warmGradient = LinearGradient(
            gradient: Gradient(colors: [salmon, magenta]),
            startPoint: .leading, endPoint: .trailing
        )
        let midGradient = LinearGradient(
            gradient: Gradient(colors: [lavender, peri]),
            startPoint: .leading, endPoint: .trailing
        )
        let coolGradient = LinearGradient(
            gradient: Gradient(colors: [peri, sky]),
            startPoint: .leading, endPoint: .trailing
        )

        Group {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    ForEach(memex.messagesByDate) { messageList in
                        Text(Util.formatDate(date: messageList.date))
                            .font(.system(size: 12.0, weight: .semibold, design: .default))
                            .foregroundColor(Color(UIColor.lightGray))
                        
                        ForEach(messageList.messages) { message in
                            HStack(alignment: .top) {
                                Text(Util.formatTime(date: message.time))
                                    .font(.system(size: 16.0, weight: .semibold, design: .default))
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .background(warmGradient)
                                    .cornerRadius(10)
                                    .contentShape(roundedShape)
                                    .contextMenu {
                                        Button(action: {
                                            editingMessage = message
                                            editingText = nil
                                            editingTime = message.time
                                        }) {
                                            Text("Edit time")
                                            Spacer()
                                            Image(systemName: "square.and.pencil")
                                                .imageScale(.large)
                                        }
                                    }

                                Spacer(minLength: 10)

                                MessageView(message: message)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .background(coolGradient)
                                    .cornerRadius(10)
                                    .contentShape(roundedShape)
                                    .onTapGesture() {
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                        typingMessage = message.text
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            editingMessage = message
                                            editingTime = nil
                                            editingText = memex.getTextAndComment(message)
                                        }) {
                                            Text("Edit")
                                            Spacer()
                                            Image(systemName: "square.and.pencil")
                                                .imageScale(.large)
                                        }
                                        
                                        Button(action: {
                                            editingMessage = nil
                                            editingTime = nil
                                            editingText = nil
                                            messageToDelete = message
                                            showDeleteConfirmation = true
                                        }) {
                                            Text("Delete")
                                            Spacer()
                                            Image(systemName: "trash")
                                                .imageScale(.large)
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
                            }
                            .id(message.id)
                            .padding(.top, 1)
                            .padding([.leading, .trailing], 10)
                        }
                    }
                    .onAppear {
                        scrollToEnd(scrollProxy)
                    }
                }
                .onChange(of: typingMessage) { id in
                    withAnimation {
                        scrollToEnd(scrollProxy)
                    }
                }
                .padding(.top, 2)
                
                HStack {
                    if editingMessage != nil {
                        if editingTime != nil {
                            DatePicker(
                                "",
                                selection: Binding<Date>(
                                    get: { editingTime ?? Date() },
                                    set: { editingTime = $0 }
                                )
                            )
                            .labelsHidden()
                            .accentColor(sky)
                        } else {
                            TextField(
                                "",
                                text: Binding<String>(
                                    get: { editingText ?? "" },
                                    set: { editingText = $0 }
                                )
                            )
                            .keyboardType(.twitter)
                            .autocapitalization(.none)
                            .padding(8)
                            .background(offwhite)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            editingMessage = nil
                            editingTime = nil
                            editingText = nil
                        }) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .foregroundColor(.white)
                        .background(midGradient)
                        .cornerRadius(10)
                        
                        Button(action: {
                            if editingTime != nil {
                                editingMessage!.time = editingTime!
                            } else {
                                let (text, comment) = memex.extractComment(editingText!)
                                if text != "" {
                                    editingMessage!.text = text
                                    editingMessage!.comment = comment
                                }
                            }
                            memex.editMessage(edited: editingMessage!)
                            
                            editingMessage = nil
                            editingTime = nil
                            editingText = nil
                        }) {
                            Image(systemName: "checkmark")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .foregroundColor(.white)
                        .background(midGradient)
                        .cornerRadius(10)

                    } else {
                        TextField("Message...", text: $typingMessage, onEditingChanged: { changed in
                            if changed {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    withAnimation {
                                        scrollToEnd(scrollProxy)
                                    }
                                }
                            }
                        })
                        .keyboardType(.twitter)
                        .autocapitalization(.none)
                        .padding(8)
                        .background(offwhite)
                        .cornerRadius(10)

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
                        .background(midGradient)
                        .cornerRadius(10)
                    }
                }
                .frame(minHeight: CGFloat(50))
                .padding(.leading, 15)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
            .gesture(DragGesture().onChanged { _ in
                dismissKeyboard()
            })
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.windows.forEach { $0.endEditing(false) }
    }
    
    func scrollToEnd(_ scrollProxy: ScrollViewProxy) {
        scrollProxy.scrollTo(memex.messagesByDate.last?.messages.last?.id, anchor: .bottom)
    }
}

struct MessageView: View {
    @State var message: MemexMessage

    var body: some View {
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
            Spacer()
        }
    }
}
