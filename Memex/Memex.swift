//
//  Memex.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import Foundation

struct MemexMessage: Identifiable {
    var id = UUID()
    var time: Date
    var text: String
    var comment: String?
}

struct MemexMessageList: Identifiable {
    var id = UUID()
    var date: Date
    var messages: [MemexMessage]
}

class Memex: NSObject, ObservableObject {
    static let shared = Memex()
    
    @Published var messagesByDate: [MemexMessageList] = []

    var fileUrl: URL?
    var fileHandle: FileHandle?
    var isoFormatter: DateFormatter?

    override init() {
        super.init()

        isoFormatter = DateFormatter()
        isoFormatter!.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        initializeFile()
        loadMessages()
    }
            
    // MARK: File I/O
    
    func initializeFile() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let documentsUrl = NSURL(fileURLWithPath: documentsPath)
        fileUrl = documentsUrl.appendingPathComponent("memex.txt")

        // create file if it doesn't exist
        let filePath = fileUrl!.path
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            FileManager.default.createFile(
                atPath: filePath,
                contents: nil,
                attributes: nil)
        }
        fileHandle = FileHandle(forWritingAtPath: filePath)
    }
    
    func loadMessages() {
        var messages: [MemexMessage] = []
        
        do {
            let fileContents = try String(contentsOf: fileUrl!, encoding: .utf8)
            for line in fileContents.split(separator: "\n") {
                let trimmed = Util.strip(String(line))
                if trimmed != "" {
                    let (text, comment) = extractComment(trimmed)
                    let (message, time) = extractTime(text)
                    messages.append(
                        MemexMessage(time: time, text: message, comment: comment)
                    )
                }
            }
        } catch {
            print("Error reading from file")
            return
        }
        
        messagesByDate = groupMessagesByDate(messages: messages)
    }
    
    func writeMessages(messages: [MemexMessage]) {
        fileHandle?.truncateFile(atOffset: 0)
        
        for message in messages {
            let line = "\(serialize(message.text, message.time, message.comment))\n"
            fileHandle!.seekToEndOfFile()
            fileHandle!.write(line.data(using: .utf8)!)
        }
        loadMessages()
    }
    
    // MARK: Grouping / Ungrouping
    
    func groupMessagesByDate(messages: [MemexMessage]) -> [MemexMessageList] {
        let calendar = Calendar(identifier: .gregorian)
        var byDate: [MemexMessageList] = []

        let groupedMessages = Dictionary.init(grouping: messages) { (message) -> Date in
            return calendar.startOfDay(for: message.time)
        }
        groupedMessages.keys.sorted().forEach { (key) in
            byDate.append(
                MemexMessageList(date: key, messages: groupedMessages[key] ?? [])
            )
        }
        return byDate
    }
    
    func flattenMessages() -> [MemexMessage] {
        return Array(messagesByDate.map { $0.messages }.joined()).sorted {
            $1.time > $0.time
        }
    }
        
    // MARK: Message manipulation
    
    func addMessage(message: String) {
        let (text, comment) = extractComment(message)
        if text == "" {
            return
        }
        
        var flatMessages = flattenMessages()
        flatMessages.append(
            MemexMessage(time: Date(), text: text, comment: comment)
        )
        writeMessages(messages: flatMessages)
    }
    
    func editMessage(edited: MemexMessage) {
        var flatMessages = flattenMessages()
        for (index, message) in flatMessages.enumerated() {
            if message.id == edited.id {
                flatMessages[index] = edited
            }
        }
        writeMessages(messages: flatMessages)
    }
    
    func deleteMessage(uuid: UUID) {
        var flatMessages = flattenMessages()
        flatMessages.removeAll { (message) -> Bool in
            message.id == uuid
        }
        writeMessages(messages: flatMessages)
    }
        
    // MARK: Serialize / Deserialize

    func serialize(_ text: String, _ time: Date, _ comment: String?) -> String {
        var line = "\(text) on \(isoFormatter!.string(from: time))"
        if (comment != nil) {
            line.append(" # \(comment!)")
        }
        return line
    }
    
    func getTextAndComment(_ message: MemexMessage) -> String {
        var messageString = "\(message.text)"
        if (message.comment != nil) {
            messageString.append(" # \(message.comment!)")
        }
        return messageString
    }
    
    func extractComment(_ message: String) -> (String, String?) {
        var text = message
        var comment: String? = nil
        
        var components = text.components(separatedBy: "#")
        if components.count > 1 {
            comment = Util.strip(components.removeLast())
            text = components.joined(separator: "#")
        }
        text = Util.strip(text)
        
        return (text, comment)
    }
    
    func extractTime(_ text: String) -> (String, Date) {
        var components = text.components(separatedBy: " on ")
        let timeString = components.removeLast()
        let time = isoFormatter!.date(from: timeString)!
        
        return (components.joined(separator: " on "), time)
    }
}
