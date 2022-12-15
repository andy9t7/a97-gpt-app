//
//  HistoryView.swift
//  ChatGPT
//
//  Created by Andy Huynh on 15/12/2022.
//

import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    
    @State var messageHistory: [MessageLog] = []

    private func fetchMessageHistory() {
        let docRef = db.collection("messageHistory")
                
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    do {
                        
                        self.messageHistory.append(try document.data(as: MessageLog.self))
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }

    }
    
    var body: some View {
        VStack {
            List(messageHistory, id: \.id) { messages in
                NavigationLink(destination: ChatView(messages: messages.messageLog)) {
                    Text("1")
                }
            }.onAppear() {
                fetchMessageHistory()
            }
            .onDisappear() {
                messageHistory = []
            }
        }.navigationTitle("History")
        
    }
}

struct ChatView: View {
    var messages: [Message]
    
    var body: some View {
        List(messages, id: \.id) { message in
            HStack {
                Text(message.sender)
                Text(message.text)
            }
        }.navigationTitle("1")
    }
}

