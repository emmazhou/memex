//
//  EditView.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import SwiftUI

struct EditView: View {
    @ObservedObject var memex = Memex.shared
    
    @Binding var editingMessage: MemexMessage?
    @Binding var editingTime: Date?
    @Binding var editingText: String?
    
    var body: some View {
        if editingTime != nil {
            DatePicker(
                "",
                selection: Binding<Date>(
                    get: { editingTime ?? Date() },
                    set: { editingTime = $0 }
                )
            )
            .labelsHidden()
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
            .background(Styles.textFieldBackground)
            .cornerRadius(10)
        }
        
        Spacer()
        
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
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32.0, weight: .bold, design: .default))
        }
        
        Button(action: {
            editingMessage = nil
            editingTime = nil
            editingText = nil
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 32.0, weight: .bold, design: .default))
        }
    }
}
