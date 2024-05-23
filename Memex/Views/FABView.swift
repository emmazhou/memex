//
//  FABView.swift
//  Memex
//
//  Created by Emma Zhou on 5/22/24.
//

import SwiftUI

struct FABView: View {
    @ObservedObject var memex = Memex.shared

    @State var isExpanded = false
    @State var counter: Int = 0
    @State var timer: Timer?
    @State var isLongPressing = false

    var body: some View {
        VStack(alignment: .trailing) {
            if isExpanded {
                if (counter > 0) {
                    Text("\(counter)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(5)
                }

                Button(action: {
                    if (self.isLongPressing) {
                        memex.addMessage(message: "over \(counter)")
                        self.isLongPressing.toggle()
                        self.timer?.invalidate()
                        self.counter = 0
                    } else {
                        memex.addMessage(message: "over 1")
                    }
                }) {
                    HStack {
                        Text("is so over")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Styles.midGradient)
                        Text("🫠")
                            .font(.system(size: 28))
                            .padding()
                            .background(Styles.warmGradient)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 5)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    self.isLongPressing = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        self.counter += 1
                    })
                })

                
                Button(action: {
                    if (self.isLongPressing) {
                        memex.addMessage(message: "back \(counter)")
                        self.isLongPressing.toggle()
                        self.timer?.invalidate()
                        self.counter = 0
                    } else {
                        memex.addMessage(message: "back 1")
                    }
                }) {
                    HStack {
                        Text("we're so back")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Styles.midGradient)
                        Text("🥳")
                            .font(.system(size: 28))
                            .padding()
                            .background(Styles.warmGradient)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 10)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    self.isLongPressing = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        self.counter += 1
                    })
                })
            }
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .padding()
                    .background(Styles.warmGradient)
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}
