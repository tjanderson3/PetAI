//
//  ApiCall.swift
//  pets
//
//  Created by Teddy Anderson on 6/7/24.
//
import Foundation
import UIKit

extension FileManager {
    static let petImagesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("PetImages")
    
    func saveImage(_ image: UIImage, withName name: String) -> String? {
        if !FileManager.default.fileExists(atPath: FileManager.petImagesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: FileManager.petImagesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                return nil
            }
        }
        
        let imageUrl = FileManager.petImagesDirectory.appendingPathComponent("\(name).jpg")
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: imageUrl)
                return imageUrl.lastPathComponent
            } catch {
                print("Failed to save image: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    func loadImage(fromPath path: String) -> UIImage? {
        let imageUrl = FileManager.petImagesDirectory.appendingPathComponent(path)
        if let imageData = try? Data(contentsOf: imageUrl) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func saveGalleryImage(image: UIImage, withName name: String, forPetId petId: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let petDirectory = getPetGalleryDirectory(for: petId)
        let fileURL = petDirectory.appendingPathComponent("\(name).jpg") // Ensure the image has a .jpg extension
        do {
            try createDirectory(at: petDirectory, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving gallery image: \(error)")
            return nil
        }
    }
    
    func loadGalleryImages(forPetId petId: String) -> [GalleryImage] {
        let petDirectory = getPetGalleryDirectory(for: petId)
        do {
            let fileURLs = try contentsOfDirectory(at: petDirectory, includingPropertiesForKeys: nil)
            return fileURLs.map { GalleryImage(imagePath: $0.path) }
        } catch {
            print("Error loading gallery images: \(error)")
            return []
        }
    }
    
    private func getPetGalleryDirectory(for petId: String) -> URL {
        let documentsDirectory = urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("PetGallery").appendingPathComponent(petId)
    }
}
struct Pet: Codable, Identifiable {
    let id: UUID
    var name: String
    var primaryBreed: String
    var secondaryBreed: String?
    var height: Double
    var weight: Double
    var length: Double
    var gender: String
    var coatLength: String
    var coatType: String
    var coatColor: String
    var age: Int
    var fitnessLevel: String
    var animalType: String
    var imagePath: String
    var personality: String?
    var birthday: Date?
    var zodiacSign: String?
    // New properties
    var descriptionAdjectives: String?
    var hypoallergenic: Int?
    var averageWeight: Double?
    var averageHeight: Double?
    var dogYearsMultiplier: Double?
    var biteForce: Double?
    var breedDescription: String?
    var userId: String
    var petId: String
}

import Foundation
import UIKit


class OpenAIAPI {
    static let shared = OpenAIAPI()
    
    private let s3PresignedUrlEndpoint = "removed for security purposes"
    private let processScanEndpoint = "removed for security purposes"
    private let updateScanEndpoint = "removed for security purposes"
    
    func getPresignedURL(userId: String, petId: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        let url = URL(string: s3PresignedUrlEndpoint)!
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
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func notifyBackend(userId: String, petId: String, imageKey: String, petImage: UIImage, completion: @escaping (Result<Pet, Error>) -> Void) {
        let url = URL(string: processScanEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId, "pet_id": petId, "image_key": "\(imageKey)"]
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
                // Log the raw response data
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response data: \(rawResponse)")
                } else {
                    print("Failed to convert response data to string.")
                }

                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let scanResults = jsonResponse["scan_results"] as? [String: Any],
                   var pet = self.parsePetData(scanResults, imageKey: imageKey) {
                    // Save the image locally using the previous method
                    if let imagePath = FileManager.default.saveImage(petImage, withName: UUID().uuidString) {
                        pet.imagePath = imagePath
                    } else {
                        print("Failed to save image locally")
                    }
                    completion(.success(pet))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updatePetInfo(userId: String, petId: String, pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: updateScanEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let petData = try JSONEncoder().encode(pet)
            let petJson = String(data: petData, encoding: .utf8)
            let body: [String: Any] = ["user_id": userId, "pet_id": petId, "scan_results": petJson ?? ""]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
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
                   let message = jsonResponse["message"] as? String,
                   message == "Update successful" {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func parsePetData(_ data: [String: Any], imageKey: String) -> Pet? {
        guard let breedIdentification = data["breed_identification"] as? [String: Any],
              let primaryBreed = breedIdentification["primary_breed"] as? String,
              let height = (data["size"] as? [String: Any])?["height"] as? Double,
              let weight = (data["size"] as? [String: Any])?["weight"] as? Double,
              let length = (data["size"] as? [String: Any])?["length"] as? Double,
              let gender = data["gender"] as? String,
              let coat = data["coat"] as? [String: Any],
              let coatLength = coat["length"] as? String,
              let coatType = coat["type"] as? String,
              let coatColorFull = coat["color"] as? String,
              let age = data["age"] as? Int,
              let fitnessLevel = data["fitness_level"] as? String,
              let animalType = data["animal_type"] as? String,
              let breedProperties = data["breed_properties"] as? [String: Any] else {
            return nil
        }
        
        let secondaryBreed = breedIdentification["secondary_breed"] as? String
        
        let descriptionAdjectives = breedProperties["description_adjectives"] as? String
        let hypoallergenic = breedProperties["hypoallergenic"] as? Int
        let averageWeight = breedProperties["average_weight"] as? Double
        let averageHeight = breedProperties["average_height"] as? Double
        let dogYearsMultiplier = breedProperties["dog_years_multiplier"] as? Double
        let biteForce = breedProperties["bite_force"] as? Double
        let breedDescription = breedProperties["breed_description"] as? String
        
        // Extracting the first word of the coat color
        let coatColor = coatColorFull.components(separatedBy: " ").first ?? coatColorFull

        return Pet(
            id: UUID(),
            name: "", // Name will be set later
            primaryBreed: primaryBreed,
            secondaryBreed: secondaryBreed,
            height: height,
            weight: weight,
            length: length,
            gender: gender,
            coatLength: coatLength,
            coatType: coatType,
            coatColor: coatColor,
            age: age,
            fitnessLevel: fitnessLevel,
            animalType: animalType,
            imagePath: "", // Path will be set later
            descriptionAdjectives: descriptionAdjectives,
            hypoallergenic: hypoallergenic,
            averageWeight: averageWeight,
            averageHeight: averageHeight,
            dogYearsMultiplier: dogYearsMultiplier,
            biteForce: biteForce,
            breedDescription: breedDescription,
            userId: "",
            petId: ""
        )
    }
}

