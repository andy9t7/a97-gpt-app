//
//  ContentView.swift
//  ChatGPT
//
//  Created by Andy Huynh on 13/12/2022.
//

import SwiftUI
import OpenAISwift
import FirebaseFirestore
import FirebaseFirestoreSwift

let path = Bundle.main.path(forResource: "api-token", ofType: "txt") // file path for file "data.txt"
let token = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)

let openAPI = OpenAISwift(authToken: token)
let db = Firestore.firestore()

struct ContentView: View {
    @State private var messageText = ""
    @State private var showSheet = false
    
    @State var messageLog: [Message] = [
        Message(sender: "gpt", text: "Hello, how can I help you?"),
    ]
    
    func sendMessage() {
        messageLog.append(Message(sender: "you", text: messageText))
        let messageLogString = convertMessagesToString(messageLog: messageLog)
        getGptResult(input: messageLogString)
        messageText = ""
    }
    
    func getGptResult(input: String) {
        print(input)
        openAPI.sendCompletion(with: input, model: .gpt3(.davinci), maxTokens: 256, completionHandler: { result in
            switch result {
            case .success(let model):
                print(String(describing: model.choices))
                let output = model.choices.first?.text ?? ""
                let message = output.components(separatedBy: "gpt: ")[1]
                messageLog.append(Message(sender: "gpt", text: message))

            case .failure(let error):
                print("error @ getGptResult()")
                let output = String(describing: error.localizedDescription)
                messageLog.append(Message(sender: "gpt", text: output))

            }
            
        })
        
        
    }
    
    func convertMessagesToString(messageLog: [Message]) -> String {
        var messageLogString = ""
        messageLog.forEach { message in
            messageLogString += "\(message.sender): \(message.text)\n"
        }
        
        return messageLogString
        
    }
    
    func clearHistory() {
        addMessageLog(messageLog: self.messageLog)
        self.messageLog = [
            Message(sender: "gpt", text: "Hello, how can I help you?"),
        ]
    }
    
    func addMessageLog(messageLog: [Message]) {
        
        let data = MessageLog(messageLog: messageLog)
        // Add a new document with a generated ID
        let collectionRef = db.collection("messageHistory")
          do {
            let newDocReference = try collectionRef.addDocument(from: data)
            print("Message log stored with new document reference: \(newDocReference)")
          }
          catch {
            print(error)
          }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ScrollViewReader{ value in
                        VStack {
                            ForEach(messageLog, id: \.self) { message in
                                ChatBubble(text: message.text, sender: message.sender)
                                    .padding(.horizontal).padding(.top)
                            }
                            
                            HStack (spacing: 0){Spacer()}
                                .id(1)
                            
                        }.onChange(of: messageLog.count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                value.scrollTo(1, anchor: .bottom)
                            }
                            
                        }
                    }
                    
                }
                
                HStack {
                    TextField("Enter your message", text: $messageText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.horizontal, 10)
                    
                    
                    
                    Button(action: {
                        self.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding(.bottom, 10).padding(.horizontal)
            }
            .navigationTitle("A97-GPT")
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button ("About") {
                        self.showSheet = true
                    }
                    
                }
                
                ToolbarItem(placement:.navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Text("History")
                    }
                }
                
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button ("Clear") {
                        clearHistory()
                    }
                    
                }
                
            }
            .sheet(isPresented: $showSheet) {
                VStack(alignment: .center, spacing: 20) {
                    Image("app-logo")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                    Text("A97-GPT")
                        .font(.title)
                        .bold()
                    Text("This app uses OpenAI's GPT-3 API to power its conversations and provide intelligent responses to user input.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    Divider()
                    
                    Text("App developed by\n Andy Huynh\n [ahuynh.io](https://ahuynh.io)")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                }
                .padding()
            }
        }
    }
    
}


struct ChatBubble: View {
    var text: String
    var sender: String
    
    var body: some View {
        VStack {
            HStack {
                if sender == "you" {
                    Spacer()
                }
                
                if sender == "gpt" {
                    Image(systemName: "triangle.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title)
                }
                
                Text(text)
                    .padding()
                    .background(sender == "gpt" ? Color(.systemGray6) : Color.blue)
                    .foregroundColor(sender == "gpt" ? .black : .white)
                    .cornerRadius(10)
                
                if sender == "gpt" {
                    Spacer()
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
