//
//  SettingsView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    var body: some View {
        ScrollViewReader { scrollProxy in
            SettingsViewInner(scrollProxy: scrollProxy)
        }
    }
}

struct SettingsViewInner: View {
    @ObservedObject var memex = Memex.shared
    @ObservedObject var database = Database.shared
    
    @AppStorage("showRelativeTime") var showRelativeTime = false
    
    @State var scrollProxy: ScrollViewProxy
    @State var newVerb: String = ""
    @State var showAlert = false
    @State var keyboardHeight: CGFloat = 0
    
    var verbTextFieldId = "verbTextFieldId"
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Appearance")
                        .font(.system(size: 20.0, weight: .semibold, design: .default))
                    Spacer()
                }
                .padding(.bottom, 5)
                
                Toggle(isOn: $showRelativeTime) {
                    Text("Show relative times")
                        .foregroundColor(Styles.textForeground)
                }
                .tint(Styles.sky)
                .padding(.bottom, 20)
                    
                HStack {
                    Text("Vocabulary")
                        .font(.system(size: 20.0, weight: .semibold, design: .default))
                    Spacer()
                }
                .padding(.bottom, 5)
                
                MessageTypesView()
                
                HStack {
                    TextField("Add new verb...", text: $newVerb)
                        .autocapitalization(.none)
                        .padding(8)
                        .background(Styles.textFieldBackground)
                        .cornerRadius(10)
                        .onChange(of: newVerb) { id in
                            withAnimation {
                                scrollProxy.scrollTo(verbTextFieldId, anchor: .bottom)
                            }
                        }

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
                .id(verbTextFieldId)
                .padding(.top, 5)
                .padding(.bottom, 20)
                
                PollsView()
                
                NotificationsView()

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
                    .background(Styles.coolGradient)
                    .cornerRadius(10)
                                        
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding(20)
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.windows.forEach { $0.endEditing(false) }
        })
        .onAppear {
            listenForKeyboardNotifications()
        }
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
            let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return
            }
            keyboardHeight = keyboardRect.height
            withAnimation {
                scrollProxy.scrollTo(verbTextFieldId, anchor: .bottom)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            keyboardHeight = 0
        }
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
                    Text(messageType.verb!)
                        .font(.system(size: 16.0, weight: .semibold, design: .default))
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Styles.warmGradient)
                        .cornerRadius(10)
                        .contentShape(Styles.roundedShape)
                        .contextMenu {
                            Button(action: {
                                database.addIntervalNotification(verb: messageType.verb!, interval: 600)
                            }) {
                                Text("Start timer")
                                Spacer()
                                Image(systemName: "timer")
                                    .imageScale(.large)
                            }
                            
                            Button(action: {
                                database.addCalendarNotification(verb: messageType.verb!, hour: 10, minute: 0)
                            }) {
                                Text("Schedule notification")
                                Spacer()
                                Image(systemName: "clock")
                                    .imageScale(.large)
                            }
                            
                            Button(action: {
                                let typeToDelete = messageTypes[index]
                                database.deleteMessageType(messageType: typeToDelete)
                            }) {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                                    .imageScale(.large)
                            }
                        }
                }
                .padding([.trailing, .bottom], 8)
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

struct PollsView: View {
    @FetchRequest(
        entity: IntervalNotification.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \IntervalNotification.verb, ascending: true)
        ]
    ) var notifications: FetchedResults<IntervalNotification>

    @ObservedObject var database = Database.shared
    
    @State var editingUuid: String? = nil
    @State var editingValue = ""
    
    var body: some View {
        if notifications.count > 0 {
            VStack {
                HStack {
                    Text("Poll Timers")
                        .font(.system(size: 20.0, weight: .semibold, design: .default))
                    Spacer()
                }
                .padding(.bottom, 5)
                
                ForEach(notifications.indices, id: \.self) { index in
                    let notification = notifications[index]
                    let isEditing = editingUuid != nil && editingUuid == notification.uuid
                    let stringValue = String(format: "%.0f", notification.interval / 60)
                    
                    HStack {
                        Text(notification.verb!)
                            .font(.system(size: 16.0, weight: .semibold, design: .default))
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Styles.midGradient)
                            .cornerRadius(10)
                        
                        if isEditing {
                            TextField("Minutes", text: $editingValue)
                                .keyboardType(.numberPad)
                            
                        } else {
                            Text("\(stringValue) min")
                                .font(.system(size: 16.0, weight: .semibold, design: .default))
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Styles.coolGradient)
                                .cornerRadius(10)
                        }
                        
                        if !notification.active {
                            Button(action: {
                                if isEditing {
                                    if let newInterval = Double(editingValue) {
                                        if newInterval >= 1 {
                                            database.updateIntervalNotification(notification: notification, interval: newInterval * 60)
                                        }
                                    }
                                    editingUuid = nil
                                    editingValue = ""
                                } else {
                                    editingUuid = notification.uuid
                                    editingValue = stringValue
                                }
                            }) {
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 32.0, weight: .bold, design: .default))
                            }
                        }
                                                
                        Button(action: {
                            if notification.active {
                                database.stopIntervalNotification(notification: notification)
                            } else {
                                database.startIntervalNotification(notification: notification)
                            }
                        }) {
                            Image(systemName: notification.active ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32.0, weight: .bold, design: .default))
                        }

                        Spacer()
                        
                        Button(action: {
                            database.deleteIntervalNotification(notification: notification)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32.0, weight: .bold, design: .default))
                        }
                    }
                    .padding(.bottom, 2)
                }
            }
        }
    }
}

struct NotificationsView: View {
    @FetchRequest(
        entity: CalendarNotification.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CalendarNotification.verb, ascending: true)
        ]
    ) var notifications: FetchedResults<CalendarNotification>

    @ObservedObject var database = Database.shared
    
    @State var editingUuid: String? = nil
    @State var editingTime: Date? = nil

    var body: some View {
        if notifications.count > 0 {
            VStack {
                HStack {
                    Text("Daily Notifications")
                        .font(.system(size: 20.0, weight: .semibold, design: .default))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 5)
                
                ForEach(notifications.indices, id: \.self) { index in
                    let notification = notifications[index]
                    let isEditing = editingUuid != nil && editingUuid == notification.uuid
                    let dateTime = Util.timeToDate(
                        hour: Int(notification.hour),
                        minute: Int(notification.minute)
                    ) ?? Date()
                    
                    HStack {
                        Text(notification.verb!)
                            .font(.system(size: 16.0, weight: .semibold, design: .default))
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Styles.midGradient)
                            .cornerRadius(10)
                        
                        if isEditing {
                            DatePicker(
                                "",
                                selection: Binding<Date>(
                                    get: { editingTime ?? Date() },
                                    set: { editingTime = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                        } else {
                            Text(Util.formatTime(date: dateTime))
                                .font(.system(size: 16.0, weight: .semibold, design: .default))
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Styles.coolGradient)
                                .cornerRadius(10)
                        }
                        
                        if !notification.active {
                            Button(action: {
                                if isEditing {
                                    if editingTime != nil {
                                        database.updateCalendarNotification(notification: notification, time: editingTime!)
                                    }
                                    editingUuid = nil
                                    editingTime = nil
                                } else {
                                    editingUuid = notification.uuid
                                    editingTime = dateTime
                                }
                            }) {
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 32.0, weight: .bold, design: .default))
                            }
                        }
                        
                        Button(action: {
                            if notification.active {
                                database.stopCalendarNotification(notification: notification)
                            } else {
                                database.startCalendarNotification(notification: notification)
                            }
                        }) {
                            Image(systemName: notification.active ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32.0, weight: .bold, design: .default))
                        }

                        Spacer()
                        
                        Button(action: {
                            database.deleteCalendarNotification(notification: notification)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32.0, weight: .bold, design: .default))
                        }
                    }
                    .padding(.bottom, 2)
                }
            }
        }
    }
}

