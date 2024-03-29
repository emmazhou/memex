//
//  MessageView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject var memex = Memex.shared

    @AppStorage("showRelativeTime") var showRelativeTime = false
    
    @State var message: MemexMessage
    @State var relDateText = ""

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var relDate: Date {
        let comps = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: message.time)
        return Calendar.current.date(from: comps)!
    }
    let rFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    @Binding var inputFieldFocused: Bool
    @Binding var editFieldFocused: Bool
    
    @Binding var typingMessage: String
    @Binding var editingMessage: MemexMessage?
    @Binding var editingTime: Date?
    @Binding var editingText: String?
    
    @Binding var messageToDelete: MemexMessage?
    @Binding var showDeleteConfirmation: Bool
    @Binding var isDeletingAllPrevious: Bool

    var body: some View {
        HStack {
            if showRelativeTime {
                HStack {
                    Spacer()
                    Text(relDateText)
                        .onReceive(timer) { _ in
                            self.relDateText = rFormatter.string(for: relDate)!
                        }
                        .font(.system(size: 12.0, weight: .semibold, design: .default))
                        .foregroundColor(Color(UIColor.lightGray))
                        .multilineTextAlignment(.trailing)
                }.frame(width: 80)
            } else {
                HStack {
                    Spacer()
                        Text(Util.formatTime(date: message.time))
                            .font(.system(size: 12.0, weight: .semibold, design: .default))
                            .foregroundColor(Color(UIColor.lightGray))
                }.frame(width: 65)
            }

            Spacer(minLength: 10)
            
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
            .padding(10)
            .foregroundColor(.white)
            .background(Styles.coolGradient)
            .cornerRadius(10)
            .contentShape(Styles.roundedShape)
            .onTapGesture() {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                typingMessage = message.text
                inputFieldFocused = true
            }
            .contextMenu {
                Button(action: {
                    editingMessage = message
                    editingTime = nil
                    editingText = memex.getTextAndComment(message)
                    editFieldFocused = true
                }) {
                    Text("Edit text")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                }
                
                Button(action: {
                    editingMessage = message
                    editingText = nil
                    editingTime = message.time
                }) {
                    Text("Edit time")
                    Spacer()
                    Image(systemName: "clock")
                        .imageScale(.large)
                }
                
                Button(action: {
                    editingMessage = nil
                    editingTime = nil
                    editingText = nil
                    messageToDelete = message
                    showDeleteConfirmation = true
                    isDeletingAllPrevious = false
                }) {
                    Text("Delete message")
                    Spacer()
                    Image(systemName: "trash")
                        .imageScale(.large)
                }
                
                Button(action: {
                    editingMessage = nil
                    editingTime = nil
                    editingText = nil
                    messageToDelete = message
                    showDeleteConfirmation = true
                    isDeletingAllPrevious = true
                }) {
                    Text("Delete all previous")
                    Spacer()
                    Image(systemName: "arrow.up.bin")
                        .imageScale(.large)
                }
            }
        }
        .id(message.id)
        .padding(.top, 1)
        .padding([.leading, .trailing], 10)
    }
}
