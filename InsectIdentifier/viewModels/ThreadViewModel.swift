//
//  ThreadViewModel.swift
//  InsectIdentifier
//
//  Created by Hussnain on 15/03/2025.
//


import SwiftUI
import Combine
import Photos


class ThreadViewModel: ObservableObject {
    private var fileItem: FileItem?
    @Published var conversation: [ThreadItem] = []
    private let geminiKey = "AIzaSyB8Bj4s_H1dTEIRcg5iMSiWVDQc7o1HZkY"
    private var isWaitingForResponse = false
    private var cancellables = Set<AnyCancellable>()
    
    init(fileItem: FileItem?) {
        self.fileItem = fileItem
        
        sendMessage(message: "What it is?")
    }
    
    func sendMessage(message: String) {
        guard !isWaitingForResponse else { return }
        isWaitingForResponse = true
        
        let userThread = ThreadItem(
            id: conversation.count + 1,
            isUser: true,
            threadState: .success(
                ThreadState.SuccessData(prompt: message, attachedUri: fileItem?.id, choices: nil, gemini: nil)
            )
        )
        
        conversation.append(userThread)
        
        self.conversation.append(ThreadItem(id: self.conversation.count + 1, isUser: false, threadState: .loading))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            
            self.fetchGeminiResponse(for: userThread.threadState)
        }
    }
    private func fetchGeminiResponse(for threadState: ThreadState) {
        guard case .success(let threadItem) = threadState else { return }
        
        if fileItem == nil {
            
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(self.geminiKey)"
            let requestBody: [String: Any] = [
                "contents": [
                    ["parts": [["text": threadItem.prompt]]]
                ]
            ]
            sendRequest(urlString: urlString, requestBody: requestBody, threadItem: threadItem)
        } else {
            
            getBase64Image { base64Image in
                guard let base64Data = base64Image else {
                    print("Error: Unable to convert image to Base64")
                    self.processFailResponse()
                    return
                }
                
                let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(self.geminiKey)"
                let requestBody: [String: Any] = [
                    "contents": [
                        [
                            "parts": [
                                ["text": threadItem.prompt],
                                ["inlineData": ["data": base64Data, "mimeType": "image/jpeg"]]
                            ]
                        ]
                    ]
                ]
                self.sendRequest(urlString: urlString, requestBody: requestBody, threadItem: threadItem)
            }
        }
    }
    
    private func sendRequest(urlString: String, requestBody: [String: Any], threadItem: ThreadState.SuccessData) {
        guard let url = URL(string: urlString) else {
            print("Invalid API URL")
            processFailResponse()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                if let response = output.response as? HTTPURLResponse {
                    print("Response Status Code: \(response.statusCode)")
                    if !(200...299).contains(response.statusCode) {
                        throw URLError(.badServerResponse)
                    }
                }
                return output.data }
            .decode(type: GeminiModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    self.processFailResponse()
                case .finished:
                    break
                }
            }, receiveValue: { response in
                self.processAIResponse(response, originalMessage: threadItem.prompt)
            })
            .store(in: &cancellables)
    }
    
    
    private func processAIResponse(_ response: GeminiModel, originalMessage: String) {
        conversation = conversation.map { item in
            if !item.isUser, case .loading = item.threadState {
                return ThreadItem(
                    id: item.id,
                    isUser: false,
                    threadState: .success(
                        ThreadState.SuccessData(prompt: originalMessage, attachedUri: self.fileItem?.path, choices: nil, gemini: response)
                    )
                )
            }
            return item
        }
        print("Done")
        fileItem = nil
        isWaitingForResponse = false
    }
    private func processFailResponse() {
        conversation = conversation.map { item in
            if !item.isUser, case .loading = item.threadState {
                return ThreadItem(
                    id: item.id,
                    isUser: false,
                    threadState: .error
                )
            }
            return item
        }
        fileItem = nil
        isWaitingForResponse = false
    }
    
    private func getBase64Image(completion: @escaping (String?) -> Void) {
        guard let fileItem = fileItem else {
            completion(nil)
            return
        }
        
        // Check if the path is a file URL
        if FileManager.default.fileExists(atPath: fileItem.path) {
            // Handle file path directly
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let imageData = try Data(contentsOf: URL(fileURLWithPath: fileItem.path))
                    let base64String = imageData.base64EncodedString()
                    DispatchQueue.main.async {
                        completion(base64String)
                    }
                } catch {
                    print("Error loading image from file: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            return
        }
        
        // If not a file path, try to handle as Photos library asset
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [fileItem.id], options: nil)
        guard let asset = assets.firstObject else {
            print("No asset found with identifier: \(fileItem.id)")
            completion(nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.version = .current
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let imageData = data else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // Check if image is too large (optional)
                let maxSize = 4_000_000 // 4MB
                if imageData.count > maxSize {
                    guard let image = UIImage(data: imageData),
                          let compressedData = image.jpegData(compressionQuality: 0.5) else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    let base64String = compressedData.base64EncodedString()
                    DispatchQueue.main.async {
                        completion(base64String)
                    }
                } else {
                    let base64String = imageData.base64EncodedString()
                    DispatchQueue.main.async {
                        completion(base64String)
                    }
                }
            }
        }
    }
    
    
}
