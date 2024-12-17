//
//  PetTipsView.swift
//  pets
//
//  Created by Teddy Anderson on 6/19/24.
//

import SwiftUI

// Define the structs for decoding JSON
struct PetTipsResponse: Codable {
    let response: String
}

struct Recommendations: Codable {
    let recommendationBullets: RecommendationBullets
    let recommendationImportance: RecommendationImportance
    
    enum CodingKeys: String, CodingKey {
        case recommendationBullets = "recommendation_bullets"
        case recommendationImportance = "recommendation_importance"
    }
}

struct RecommendationBullets: Codable, Identifiable {
    let id = UUID()
    let healthIssues: String
    let nutrition: String
    let exerciseNeeds: String
    let grooming: String
    let behavior: String
    let environment: String
    
    enum CodingKeys: String, CodingKey {
        case healthIssues = "health_issues"
        case nutrition
        case exerciseNeeds = "exercise_needs"
        case grooming
        case behavior
        case environment
    }
}

struct RecommendationImportance: Codable, Identifiable {
    let id = UUID()
    let healthIssues: Double
    let nutrition: Double
    let exerciseNeeds: Double
    let grooming: Double
    let behavior: Double
    let environment: Double
    
    enum CodingKeys: String, CodingKey {
        case healthIssues = "health_issues"
        case nutrition
        case exerciseNeeds = "exercise_needs"
        case grooming
        case behavior
        case environment
    }
}

struct PetTipsView: View {
    @State private var tips: RecommendationBullets?
    @State private var importance: RecommendationImportance?
    @State private var loading = false
    @State private var errorMessage: String?
    @State private var sortedRecommendations: [(String, Double, String)] = []
    var petId: String
    var userId: String

    var body: some View {
        VStack {
            if loading {
                ProgressView("Loading tips...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if !sortedRecommendations.isEmpty {
                VStack {
                    Text("Our recommendations for your pet")
                        .font(.custom("Outfit", size: 22))
                        .foregroundColor(.white) // Change to white color
                        .padding(.top, 16)
                        .padding(.bottom, 50)
                    
                    ForEach(0..<min(4, sortedRecommendations.count), id: \.self) { index in
                        NavigationLink(destination: RecommendationDetailView(recommendationTitle: sortedRecommendations[index].0, recommendationText: sortedRecommendations[index].2)) {
                            RecommendationCard(priority: index + 1, recommendationTitle: sortedRecommendations[index].0, imageName: getImageName(for: sortedRecommendations[index].0))
                                .padding(.horizontal)
                                .padding(.vertical, 10) // Increased vertical padding
                        }
                    }
                    
                    Spacer()
                }
                .navigationBarTitle("", displayMode: .inline)
            }
        }
        .onAppear {
            checkAndFetchRecommendations()
        }
    }

    private func checkAndFetchRecommendations() {
        let currentDate = Date()
        if let lastFetchDate = UserDefaults.standard.object(forKey: "\(petId)_lastFetchDate") as? Date,
           let data = UserDefaults.standard.data(forKey: "\(petId)_recommendations") {
            let elapsedTime = currentDate.timeIntervalSince(lastFetchDate)
            let oneWeek: TimeInterval = 7 * 24 * 60 * 60
            if elapsedTime < oneWeek {
                loadRecommendations(from: data)
                return
            }
        }
        fetchPetTips()
    }

    private func loadRecommendations(from data: Data) {
        do {
            let recommendations = try JSONDecoder().decode(Recommendations.self, from: data)
            self.tips = recommendations.recommendationBullets
            self.importance = recommendations.recommendationImportance
            sortedRecommendations = [
                ("Health Issues", recommendations.recommendationImportance.healthIssues, recommendations.recommendationBullets.healthIssues),
                ("Nutrition", recommendations.recommendationImportance.nutrition, recommendations.recommendationBullets.nutrition),
                ("Exercise Needs", recommendations.recommendationImportance.exerciseNeeds, recommendations.recommendationBullets.exerciseNeeds),
                ("Grooming", recommendations.recommendationImportance.grooming, recommendations.recommendationBullets.grooming),
                ("Behavior", recommendations.recommendationImportance.behavior, recommendations.recommendationBullets.behavior),
                ("Environment", recommendations.recommendationImportance.environment, recommendations.recommendationBullets.environment)
            ].sorted(by: { $0.1 > $1.1 })
            print("Loaded recommendations from local storage")
        } catch {
            errorMessage = "Failed to load recommendations: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        }
    }

    private func fetchPetTips() {
        guard let url = URL(string: "removed for security purposes") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let requestBody: [String: Any] = ["pet_id": petId, "user_id": userId]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        loading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print("Pet ID: \(petId)")
                print("User ID: \(userId)")
                loading = false
                if let error = error {
                    errorMessage = "Failed to fetch tips: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    print("Error: No data received")
                    return
                }
                
                print("Raw JSON response: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                
                do {
                    // First, decode the outer response to get the inner JSON string
                    let petTipsResponse = try JSONDecoder().decode(PetTipsResponse.self, from: data)
                    print(petTipsResponse)
                    
                    // Then, decode the inner JSON string
                    if let innerData = petTipsResponse.response.data(using: .utf8) {
                        let recommendations = try JSONDecoder().decode(Recommendations.self, from: innerData)
                        self.tips = recommendations.recommendationBullets
                        self.importance = recommendations.recommendationImportance
                        
                        // Sorting recommendations by importance
                        sortedRecommendations = [
                            ("Health Issues", recommendations.recommendationImportance.healthIssues, recommendations.recommendationBullets.healthIssues),
                            ("Nutrition", recommendations.recommendationImportance.nutrition, recommendations.recommendationBullets.nutrition),
                            ("Exercise Needs", recommendations.recommendationImportance.exerciseNeeds, recommendations.recommendationBullets.exerciseNeeds),
                            ("Grooming", recommendations.recommendationImportance.grooming, recommendations.recommendationBullets.grooming),
                            ("Behavior", recommendations.recommendationImportance.behavior, recommendations.recommendationBullets.behavior),
                            ("Environment", recommendations.recommendationImportance.environment, recommendations.recommendationBullets.environment)
                        ].sorted(by: { $0.1 > $1.1 })
                        
                        // Save recommendations and update last fetch date
                        UserDefaults.standard.set(Date(), forKey: "\(petId)_lastFetchDate")
                        if let encodedData = try? JSONEncoder().encode(recommendations) {
                            UserDefaults.standard.set(encodedData, forKey: "\(petId)_recommendations")
                        }
                        print("Fetched and saved new recommendations")
                        
                    } else {
                        errorMessage = "Failed to decode inner JSON string"
                        print("Error: Failed to decode inner JSON string")
                    }
                } catch {
                    errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func getImageName(for title: String) -> String {
        switch title {
        case "Health Issues":
            return "heart"
        case "Nutrition":
            return "dog"
        case "Exercise Needs":
            return "dog"
        case "Grooming":
            return "comb"
        default:
            return "dog"
        }
    }
}

struct RecommendationCard: View {
    var priority: Int
    var recommendationTitle: String
    var imageName: String
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .cornerRadius(16)
            
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Priority \(priority)")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(.yellow)
                    Text(recommendationTitle)
                        .font(.custom("Outfit", size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
            }
            .padding()
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}

struct RecommendationDetailView: View {
    var recommendationTitle: String
    var recommendationText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recommendationTitle)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.horizontal)

                ForEach(parseBulletPoints(from: recommendationText)) { bullet in
                    RecommendationBullet(index: bullet.index, text: bullet.text)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    private func parseBulletPoints(from text: String) -> [BulletPoint] {
        let dashPattern = "^\\s*-\\s*"
        let numberPattern = "^\\s*[0-9]+\\.\\s*"
        let combinedPattern = "\(dashPattern)|\(numberPattern)"
        let regex = try? NSRegularExpression(pattern: combinedPattern, options: [])

        let bullets = text.components(separatedBy: "\n").map { line -> String in
            if let regex = regex {
                return regex.stringByReplacingMatches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count), withTemplate: "")
            }
            return line
        }.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        return bullets.enumerated().map { BulletPoint(index: $0.offset + 1, text: $0.element) }.filter { !$0.text.isEmpty }
    }
}

struct RecommendationBullet: View {
    var index: Int
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendation \(index)")
                .font(.custom("Outfit", size: 18))
                .foregroundColor(.yellow)
                .fontWeight(.bold)

            Text(text)
                .font(.custom("Nunito", size: 16))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.darkBackground)
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
/*struct PetTipsView_Previews: PreviewProvider {
    static var previews: some View {
        PetTipsView(petId: "samplePetId")
    }
}
*/
struct BulletPoint: Identifiable, Hashable {
    var id = UUID()
    var index: Int
    var text: String
}
