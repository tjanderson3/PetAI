//
//  ImagineViews.swift
//  pets
//
//  Created by Teddy Anderson on 9/12/24.
//

import SwiftUI

struct UploadPhotosView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var inputImage: UIImage? // For temporarily holding the picked image
    @State private var isUploading = false // State to show upload status
    @State private var uploadStatusMessage = "" // Status message to show upload progress
    @State private var navigateToLoraTraining = false // State to navigate to LoraTrainingView

    var body: some View {
        VStack {
            Text("Upload or Take 5 Photos")
                .font(.headline)
                .padding()

            // Show image placeholders or selected images
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(0..<5, id: \.self) { index in
                    if index < selectedImages.count {
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .border(Color.gray, width: 1)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("Add").foregroundColor(.black))
                            .onTapGesture {
                                // Open image picker
                                showingImagePicker = true
                            }
                    }
                }
            }
            .padding()

            Spacer()

            // Button to upload or take photos
            Button(action: {
                if selectedImages.count < 5 {
                    showingImagePicker = true
                } else {
                    uploadImages() // Trigger the image upload process
                }
            }) {
                Text(selectedImages.count < 5 ? "Add More Photos" : "Submit Photos")
                    .bold()
                    .font(.custom("Nunito", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedImages.count < 5 ? Color.blue : Color.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding()
            .disabled(isUploading) // Disable button during upload

            if isUploading {
                ProgressView(uploadStatusMessage)
                    .padding()
            }

            Spacer()

            // Navigation link to LoraTrainingView
            NavigationLink(
                destination: LoraTrainingView(), // Replace with your actual LoraTrainingView
                isActive: $navigateToLoraTraining
            ) {
                EmptyView()
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: addImage) {
            ImagePicker(image: $inputImage, sourceType: imageSourceType) // Use single image selection
        }
    }

    private func addImage() {
        // If an image was picked, append it to the array
        guard let inputImage = inputImage else { return }
        selectedImages.append(inputImage) // Add the image to the list
        self.inputImage = nil // Reset the inputImage
        print("DEBUG: Image added. Total images: \(selectedImages.count)")
    }

    // Function to upload images
    private func uploadImages() {
        guard selectedImages.count == 5 else {
            uploadStatusMessage = "Please upload exactly 5 images."
            print("DEBUG: Incorrect number of images selected: \(selectedImages.count)")
            return
        }

        isUploading = true
        uploadStatusMessage = "Fetching upload URLs..."
        print("DEBUG: Starting upload process. Fetching URLs...")
        // Step 1: Fetch pre-signed URLs from the Lambda function
        guard let url = URL(string: "removed for security purposes") else {
            uploadStatusMessage = "Invalid URL"
            isUploading = false
            print("DEBUG: Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["folder_name": "tjatest2/"] // Request body
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.uploadStatusMessage = "Error fetching URLs: \(error.localizedDescription)"
                    self.isUploading = false
                    print("DEBUG: Error fetching URLs - \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.uploadStatusMessage = "No data received"
                    self.isUploading = false
                    print("DEBUG: No data received from the API")
                }
                return
            }

            // Print the raw output to debug the response
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("DEBUG: Raw response from API: \(rawResponse)")

            // Parse response to get presigned URLs
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let folderName = json["folder_name"] as? String,
                   let urls = json["presigned_urls"] as? [String] {

                    print("DEBUG: Presigned URLs fetched successfully: \(urls)")
                    self.uploadStatusMessage = "Uploading images..."
                    self.uploadImagesToURLs(urls: urls)
                } else {
                    DispatchQueue.main.async {
                        self.uploadStatusMessage = "Failed to parse URLs"
                        self.isUploading = false
                        print("DEBUG: Failed to parse presigned URLs")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.uploadStatusMessage = "Error parsing response"
                    self.isUploading = false
                    print("DEBUG: Error parsing API response - \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    // Step 2: Upload each image to its respective presigned URL
    private func uploadImagesToURLs(urls: [String]) {
        guard urls.count == selectedImages.count else {
            self.uploadStatusMessage = "URL count mismatch."
            self.isUploading = false
            print("DEBUG: URL count does not match the number of images")
            return
        }

        let dispatchGroup = DispatchGroup()

        for (index, url) in urls.enumerated() {
            guard let imageData = selectedImages[index].jpegData(compressionQuality: 0.8),
                  let uploadURL = URL(string: url) else {
                self.uploadStatusMessage = "Invalid image data or URL"
                self.isUploading = false
                print("DEBUG: Invalid image data or URL at index \(index)")
                return
            }

            var uploadRequest = URLRequest(url: uploadURL)
            uploadRequest.httpMethod = "PUT"
            uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

            dispatchGroup.enter()
            print("DEBUG: Uploading image \(index + 1) to \(url)")

            URLSession.shared.uploadTask(with: uploadRequest, from: imageData) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
                        print("DEBUG: Upload failed for image \(index + 1) - \(error.localizedDescription)")
                    }
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("DEBUG: Upload successful for image \(index + 1), Status Code: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("DEBUG: Upload failed with status code: \(httpResponse.statusCode)")
                    }
                }
                dispatchGroup.leave()
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            self.isUploading = false
            self.uploadStatusMessage = "All images uploaded successfully."
            self.navigateToLoraTraining = true // Navigate to the LoraTrainingView after successful upload
            print("DEBUG: All images uploaded successfully. Navigating to LoRA Training.")
        }
    }
}


struct LoraTrainingView: View {
    @State private var isTraining = false // State to indicate training in progress
    @State private var trainingStatusMessage = "" // Status message to show progress
    @State private var gender = "dog" // Replace with actual data or user input
    @State private var trainID = UUID().uuidString // Replace with actual train ID
    @State private var folderName = "dog2/" // Replace with the folder name used during image upload

    var body: some View {
        VStack {
            Text("LoRA Training")
                .font(.largeTitle)
                .padding()

            // Show the current training parameters
            VStack(alignment: .leading, spacing: 10) {
                Text("Gender: \(gender)")
                Text("Train ID: \(trainID)")
                Text("Folder Name: \(folderName)")
            }
            .padding()

            // Button to start the LoRA training
            Button(action: {
                startLoraTraining() // Trigger the training process
            }) {
                Text("Start LoRA Training")
                    .bold()
                    .font(.custom("Nunito", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .disabled(isTraining) // Disable button while training is in progress
            .padding()

            if isTraining {
                ProgressView(trainingStatusMessage)
                    .padding()
            }
        }
        .padding()
    }

    // Function to start the LoRA training by calling the backend API
    private func startLoraTraining() {
        isTraining = true
        trainingStatusMessage = "Starting training..."

        guard let url = URL(string: "removed for security purposes") else {
            trainingStatusMessage = "Invalid training URL"
            isTraining = false
            print("DEBUG: Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set up the JSON body with necessary parameters
        let requestBody: [String: Any] = [
            "gender": gender,
            "train_id": trainID,
            "folder_name": "dog2/"
        ]

        // Convert the request body to JSON data
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.trainingStatusMessage = "Error starting training: \(error.localizedDescription)"
                    self.isTraining = false
                    print("DEBUG: Error starting training - \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.trainingStatusMessage = "No response received"
                    self.isTraining = false
                    print("DEBUG: No response from API")
                }
                return
            }

            // Print the raw response for debugging
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("DEBUG: Raw response from training API: \(rawResponse)")

            // Attempt to parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let body = json["body"] as? String {
                    DispatchQueue.main.async {
                        self.trainingStatusMessage = "Training started successfully with job ID: \(body)"
                        self.isTraining = false
                        print("DEBUG: Training started successfully - Job ID: \(body)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.trainingStatusMessage = "Failed to parse training response"
                        self.isTraining = false
                        print("DEBUG: Failed to parse training response")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.trainingStatusMessage = "Error parsing response"
                    self.isTraining = false
                    print("DEBUG: Error parsing API response - \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

