//
//  SettingsView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @ObservedObject var memex = Memex.shared
    @ObservedObject var database = Database.shared
        
    @State var newVerb: String = ""
    @State var showAlert = false

    var body: some View {
        ScrollView {
            HStack {
                Text("Vocabulary")
                    .font(.system(size: 20.0, weight: .semibold, design: .default))
                Spacer()
            }
            
            MessageTypesView()
            
            HStack {
                TextField("Add new verb...", text: $newVerb)
                    .autocapitalization(.none)
                    .padding(8)
                    .background(Styles.textFieldBackground)
                    .cornerRadius(10)

                Button(action: {
                    if newVerb == "" {
                        return
                    }

                    database.addMessageType(verb: newVerb)
                    newVerb = ""
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32.0, weight: .bold, design: .default))
                }
            }
            .padding(.top, 5)
            
            HStack {
                Text("Data")
                    .font(.system(size: 20.0, weight: .semibold, design: .default))
                Spacer()
            }
            .padding(.top, 20)
            
            HStack(spacing: 10) {
                Button(action: {
                    if memex.fileUrl == nil {
                        return
                    }
                    let viewController = UIActivityViewController(
                        activityItems: [memex.fileUrl!], applicationActivities: nil
                    )
                    viewController.excludedActivityTypes = [
                        UIActivity.ActivityType.message
                    ]
                    UIApplication.shared.windows.first?.rootViewController?.present(
                        viewController, animated: true, completion: nil
                    )
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                    Text("Export data file")
                        .font(.system(size: 16.0, weight: .semibold, design: .default))
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Styles.midGradient)
                .cornerRadius(10)
                
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                    Text("Delete older")
                        .font(.system(size: 16.0, weight: .semibold, design: .default))
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Styles.coolGradient)
                .cornerRadius(10)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Delete older messages?"),
                        message: Text("This will delete all messages older than 1 week"),
                        primaryButton: .default(Text("Cancel"), action: {
                            showAlert = false
                        }),
                        secondaryButton: .default(Text("Delete"), action: {
                            memex.deleteOldMessages()
                            showAlert = false
                        })
                    )
                }
                
                Spacer()
            }
            .padding(.top, 5)
            
            Spacer()
        }
        .padding(20)
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.windows.forEach { $0.endEditing(false) }
        })
    }
}

struct MessageTypesView: View {
    @FetchRequest(
        entity: MessageType.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MessageType.verb, ascending: true)
        ]
    ) var messageTypes: FetchedResults<MessageType>

    @ObservedObject var database = Database.shared

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        if messageTypes.count > 0 {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(in: geometry)
                }
            }
            .frame(height: totalHeight)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(messageTypes.indices, id: \.self) { index in
                let messageType = messageTypes[index]
                HStack {
                    Text(messageType.verb ?? "unknown")
                        .font(.system(size: 16.0, weight: .semibold, design: .default))
                    
                    Button(action: {
                        let typeToDelete = messageTypes[index]
                        database.deleteMessageType(messageType: typeToDelete)
                    }) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Styles.warmGradient)
                .cornerRadius(10)
                .padding([.trailing, .bottom], 10)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > g.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if messageType.verb == messageTypes.last!.verb {
                        width = 0
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: { d in
                    let result = height
                    if messageType.verb == messageTypes.last!.verb {
                        height = 0
                    }
                    return result
                })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
