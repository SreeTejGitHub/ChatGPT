//
//  ContentView.swift
//  Chat
//
//  Created by Sree Tej Peddaiahgari on 12/20/22.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, Completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                Completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ResponseModel: Hashable{
    var text: String = ""
    var sender: Sender = .me
}

enum Sender {
    case me
    case ai
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [ResponseModel]()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(self.models, id: \.self) { model in
                        if model.sender == .me {
                            Text(model.text)
                                .padding(.leading, 16)
                                .background(.blue)
                                .foregroundColor(.white)
                        } else {
                            Text(model.text)
                                .padding(.trailing, 16)
                                .background(.green)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                }
            }
            HStack {
                TextEditor(text: $text)
                    .frame(height: 40)
                    .background(.gray)
                Button("Send") {
                    send()
                }
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
            }
        }
        .onAppear{
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        models.append(ResponseModel(text: text, sender: .me))
        viewModel.send(text: text) { response in
            self.models.append(ResponseModel(text: response, sender: .ai))
            self.text = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
