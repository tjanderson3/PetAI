//
//  ChatView.swift
//  pets
//
//  Created by Teddy Anderson on 6/14/24.
//

import SwiftUI

struct ChatView: View {
    let userId: String
    let petId: String
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                    Image("dogprev") // Replace with your expert profile image name
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    Text("Pet Expert Agent")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 15)
                }
                
                Spacer()
            }
            .background(Color.darkBackground)
            .padding(.top, -35) // Adjust the top padding as needed to move the content up
            
            ScrollView {
                ForEach(messages) { message in
                    MessageView(message: message)
                }
            }
            .background(Color.black)
            
            HStack {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image("plus") // Replace with your plus button image name
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker1(images: $selectedImages, limit: 2)
                }
                
                TextField("I guess....", text: $messageText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .onTapGesture {
                        self.hideKeyboard()
                    }
                
                Button(action: {
                    sendMessage()
                    hideKeyboard()
                }) {
                    Image("uparrow") // Replace with your up arrow button image name
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                }
            }
            .padding()
            .background(Color.darkBackground)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func sendMessage() {
        if selectedImages.isEmpty {
            sendTextMessage()
        } else {
            uploadImagesAndSendMessage()
        }
    }
    
    private func sendTextMessage() {
        let newMessage = Message(text: messageText, sender: .user, timestamp: getCurrentTimestamp(), image: nil)
        messages.append(newMessage)
        messageText = ""
        
        OpenAIAPIChat.shared.sendTextMessage(userId: userId, petId: petId, message: newMessage.text) { result in
            switch result {
            case .success(let response):
                let botMessage = Message(text: response, sender: .expert, timestamp: self.getCurrentTimestamp())
                DispatchQueue.main.async {
                    self.messages.append(botMessage)
                }
            case .failure(let error):
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadImagesAndSendMessage() {
        let dispatchGroup = DispatchGroup()
        var uploadedImageKeys: [String] = []

        for image in selectedImages {
            dispatchGroup.enter()
            OpenAIAPIChat.shared.getPresignedURL(userId: userId, petId: petId) { result in
                switch result {
                case .success(let (preSignedUrl, imageKey)):
                    OpenAIAPIChat.shared.uploadImageToS3(image: image, preSignedUrl: preSignedUrl) { uploadResult in
                        switch uploadResult {
                        case .success():
                            uploadedImageKeys.append(imageKey)
                            dispatchGroup.leave()
                        case .failure(let error):
                            print("Error uploading image: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                case .failure(let error):
                    print("Error getting presigned URL: \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.processUploadedImagesAndSendMessage(imageKeys: uploadedImageKeys)
        }
    }
    
    private func processUploadedImagesAndSendMessage(imageKeys: [String]) {
        let dispatchGroup = DispatchGroup()
        var processedImageKeys: [String] = []

        for imageKey in imageKeys {
            dispatchGroup.enter()
            OpenAIAPIChat.shared.processChatImage(userId: userId, petId: petId, imageKey: imageKey) { result in
                switch result {
                case .success():
                    processedImageKeys.append(imageKey)
                case .failure(let error):
                    print("Error processing uploaded images: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.sendTextMessageWithImages(imageKeys: processedImageKeys)
        }
    }
    
    private func sendTextMessageWithImages(imageKeys: [String]) {
        let newMessage = Message(text: messageText, sender: .user, timestamp: getCurrentTimestamp(), image: nil)
        messages.append(newMessage)
        messageText = ""
        selectedImages = []
        
        OpenAIAPIChat.shared.sendMessageWithImages(userId: userId, petId: petId, message: newMessage.text, imageKeys: imageKeys) { result in
            switch result {
            case .success(let response):
                let botMessage = Message(text: response, sender: .expert, timestamp: self.getCurrentTimestamp())
                DispatchQueue.main.async {
                    self.messages.append(botMessage)
                }
            case .failure(let error):
                print("Error sending message with images: \(error.localizedDescription)")
            }
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        return formatter.string(from: Date())
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .expert {
                VStack(alignment: .leading) {
                    Text(message.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Text(message.text)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Spacer()
                    }
                }
                .padding()
            } else {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        if let image = message.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                        Text(message.text)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let sender: MessageSender
    let timestamp: String
    let image: UIImage?
    
    init(text: String, sender: MessageSender, timestamp: String, image: UIImage? = nil) {
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.image = image
    }
}

enum MessageSender {
    case expert
    case user
}


//struct ChatView_Previews: PreviewProvider {
  //  static var previews: some View {
    //    ChatView()
    //}
//}

//
import Foundation
import UIKit

class OpenAIAPIChat {
    static let shared = OpenAIAPIChat()
    
    private let getPresignedURLEndpoint = "removed for security purposes"
    private let processChatImageEndpoint = "removed for security purposese"
    private let handleTextMessageEndpoint = "removed for security purposes"
    
    private init() {}
    
    func getPresignedURL(userId: String, petId: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        let url = URL(string: getPresignedURLEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId, "pet_id": petId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let preSignedUrl = jsonResponse["url"] as? String,
                   let imageKey = jsonResponse["key"] as? String {
                    print("Successfully received presigned URL: \(preSignedUrl)")
                    completion(.success((preSignedUrl, imageKey)))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func uploadImageToS3(image: UIImage, preSignedUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])))
            return
        }
        
        var request = URLRequest(url: URL(string: preSignedUrl)!)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("Error: HTTP \(response.statusCode)")
                completion(.failure(NSError(domain: "HTTPError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error code \(response.statusCode)"])))
                return
            }
            print("Image uploaded successfully")
            completion(.success(()))
        }.resume()
    }
    
    func processChatImage(userId: String, petId: String, imageKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: processChatImageEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId, "pet_id": petId, "image_key": imageKey]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        //print(imageKey)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error processing chat image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = jsonResponse["message"] as? String,
                   message == "Image processed" {
                    print("Image processed successfully")
                    completion(.success(()))
                } else {
                    print("Failed to process image: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendTextMessage(userId: String, petId: String, message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: handleTextMessageEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId, "pet_id": petId, "message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending text message: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Print the raw data received from the server
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response data: \(rawResponse)")
            } else {
                print("Failed to convert response data to string.")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let botResponse = jsonResponse["response"] as? String {
                    completion(.success(botResponse))
                } else {
                    print("JSON Response: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendMessageWithImages(userId: String, petId: String, message: String, imageKeys: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var errors: [Error] = []

        for imageKey in imageKeys {
            dispatchGroup.enter()
            processChatImage(userId: userId, petId: petId, imageKey: imageKey) { result in
                if case .failure(let error) = result {
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = errors.first {
                completion(.failure(error))
            } else {
                self.sendTextMessage(userId: userId, petId: petId, message: message) { result in
                    completion(result)
                }
            }
        }
    }
}
import SwiftUI

struct ImagePicker1: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    var limit: Int

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker1

        init(_ parent: ImagePicker1) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                if parent.images.count < parent.limit {
                    parent.images.append(image)
                }
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
