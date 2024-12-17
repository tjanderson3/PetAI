//
//  ScanView.swift
//  pets
//
//  Created by Teddy Anderson on 6/7/24.
//
import SwiftUI

struct ScanView: View {
    @State private var selectedImage: UIImage?
    @State private var isPhotoLibraryPickerPresented = false
    @State private var isCameraPickerPresented = false
    @State private var isLoading = false
    @State private var scanResult: Pet?
    @State private var navigateToConfirmInfo = false
    let petName: String
    let userId: String
    let petId: String

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                ZStack {
                    Image("Group 40")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                    
                    Image(uiImage: selectedImage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.50, height: 225)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    Button(action: {
                        isPhotoLibraryPickerPresented = true
                        print("Retake button pressed - opening photo library")
                    }) {
                        Text("Retake")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                    .fullScreenCover(isPresented: $isPhotoLibraryPickerPresented) {
                        ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                            .edgesIgnoringSafeArea(.all)
                            .onDisappear {
                                // Ensure that the selected image is preserved on dismiss
                                if selectedImage == nil {
                                    print("Image picker dismissed without selecting an image")
                                }
                            }
                    }
                    
                    if isLoading {
                        ProgressView("Scanning...")
                            .padding()
                    } else {
                        if let _ = scanResult {
                            NavigationLink(destination: ConfirmPetInfoView(pet: scanResult!), isActive: $navigateToConfirmInfo) {
                                EmptyView()
                            }
                            
                            Button(action: {
                                navigateToConfirmInfo = true
                            }) {
                                Text("View Details")
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.8)
                                    .background(Color.yellow)
                                    .cornerRadius(30)
                            }
                        } else {
                            Button(action: {
                                isLoading = true
                                OpenAIAPI.shared.getPresignedURL(userId: userId, petId: petId) { result in
                                    switch result {
                                    case .success(let (preSignedUrl, imageKey)):
                                        print("Received presigned URL and image key: \(preSignedUrl), \(imageKey)")
                                        OpenAIAPI.shared.uploadImageToS3(image: selectedImage, preSignedUrl: preSignedUrl) { uploadResult in
                                            switch uploadResult {
                                            case .success():
                                                print("Image successfully uploaded to S3")
                                                OpenAIAPI.shared.notifyBackend(userId: userId, petId: petId, imageKey: imageKey, petImage: selectedImage) { notifyResult in
                                                    DispatchQueue.main.async {
                                                        isLoading = false
                                                        switch notifyResult {
                                                        case .success(let pet):
                                                            var updatedPet = pet
                                                            updatedPet.name = petName
                                                            updatedPet.userId = userId
                                                            updatedPet.petId = petId
                                                            self.scanResult = updatedPet
                                                        case .failure(let error):
                                                            print("Error during notify backend: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                            case .failure(let error):
                                                DispatchQueue.main.async {
                                                    isLoading = false
                                                    print("Error during image upload: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        DispatchQueue.main.async {
                                            isLoading = false
                                            print("Error getting presigned URL: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Scan")
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.8)
                                    .background(Color.yellow)
                                    .cornerRadius(30)
                            }
                        }
                    }
                }
                .padding(.top, 40)
            } else {
                VStack(spacing: 0) {
                    Image("dogBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.65)
                        .offset(y: 100)
                    ZStack {
                        Image("bottom")
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
                            .clipped()
                            .cornerRadius(25)
                        
                        VStack {
                            Text("Begin uploading your pet's photo")
                                .font(.custom("Nunito", size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            Text("We'll use this photo to scan for your pet's information like breed, size, and fur type.")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            
                            Button(action: {
                                isPhotoLibraryPickerPresented = true
                                print("Upload from library button pressed")
                            }) {
                                Text("Upload from your library")
                                    .font(.custom("Nunito", size: 20))
                                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 30)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(50)
                                    .padding(.bottom, 10)
                            }
                            .fullScreenCover(isPresented: $isPhotoLibraryPickerPresented) {
                                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                                    .edgesIgnoringSafeArea(.all)
                                    .onAppear {
                                        print("Image picker presented with source type: .photoLibrary")
                                    }
                                    .onDisappear {
                                        if selectedImage == nil {
                                            print("Image picker dismissed without selecting an image")
                                        }
                                    }
                            }
                            
                            Button(action: {
                                isCameraPickerPresented = true
                                print("Take using camera button pressed")
                            }) {
                                Text("Take using camera")
                                    .font(.custom("Nunito", size: 20))
                                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 30)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.yellow)
                                    .cornerRadius(50)
                            }
                            .fullScreenCover(isPresented: $isCameraPickerPresented) {
                                ImagePicker(image: $selectedImage, sourceType: .camera)
                                    .edgesIgnoringSafeArea(.all)
                                    .onAppear {
                                        print("Image picker presented with source type: .camera")
                                    }
                                    .onDisappear {
                                        if selectedImage == nil {
                                            print("Image picker dismissed without selecting an image")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }

    private func savePet(_ pet: Pet) {
        var pets = fetchPets()
        pets.append(pet)
        
        if let encodedData = try? JSONEncoder().encode(pets) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("pets.json")
            try? encodedData.write(to: fileURL)
        }
    }
    
    private func fetchPets() -> [Pet] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("pets.json")
        
        if let data = try? Data(contentsOf: fileURL),
           let pets = try? JSONDecoder().decode([Pet].self, from: data) {
            return pets
        }
        
        return []
    }
}



struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = sourceType
        picker.modalPresentationStyle = .fullScreen // Ensure full-screen presentation
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
//struct ScanView_Previews: PreviewProvider {
    //static var previews: some View {
    //    ScanView()
  //  }
//}
