import Foundation
import SwiftUI
import StoreKit
import UIKit

func clearUserDefaults() {
    if let bundleID = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    }
}
@main
struct PetAIApp: App {
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("userId") var userId: String = ""
    init() {
        onboardingComplete = false
            configureNotificationDelegate()
        generateUserIdIfNeeded()
        }
    
    var body: some Scene {
        WindowGroup {
            HomeView(userId: userId)
        }
    }
    
    func configureNotificationDelegate() {
            let center = UNUserNotificationCenter.current()
            center.delegate = NotificationDelegate() // Set the delegate
        }
    func generateUserIdIfNeeded() {
            if userId.isEmpty {
                userId = UUID().uuidString
            }
        }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct OnboardingView: View{
    let steps = [
            GuideStep(imageName: "welcomeBackground", titleText: "Welcome!", descriptionText: "We'll briefly walk through how you can use Pet AI.", reviewRequest: false),
            GuideStep(imageName: "ratingsBackground", titleText: "Rate us 5 stars", descriptionText: "Trusted by over 100,000 users!", reviewRequest: true),
            GuideStep(imageName: "scandogBackground", titleText: "Upload an image", descriptionText: "This will serve as your pet’s profile picture.", reviewRequest: false),
            GuideStep(imageName: "outputBackground", titleText: "Get an analysis", descriptionText: "Confirm that our information is correct!", reviewRequest: false),
            GuideStep(imageName: "groomingBackground", titleText: "Food & Grooming", descriptionText: "Get customized food and grooming tips based on your pet.", reviewRequest: false),
            GuideStep(imageName: "petexpertBackground", titleText: "Chat with Pet Experts", descriptionText: "Ask our experts anything! We’ve got you covered 24/7.", reviewRequest: false),
            GuideStep(imageName: "astronautBackground", titleText: "Imagine your Pet", descriptionText: "Wonder what your pet would look like as an astronaut? Try it now.", reviewRequest: false)
        ]
    
    var body: some View {
            NavigationView {
                createViewChain(for: steps)
            }
        }
        
        func createViewChain(for steps: [GuideStep]) -> AnyView {
            guard let firstStep = steps.first else {
                return AnyView(Text("No steps available"))
            }
            
            let nextSteps = Array(steps.dropFirst())
            
            return AnyView(
                PetAIGuideView(step: firstStep, nextStep: nextSteps.isEmpty ? nil : createViewChain(for: nextSteps))
            )
        }
}

struct GuideStep: Identifiable {
    let id = UUID()
    let imageName: String
    let titleText: String
    let descriptionText: String
    let reviewRequest: Bool
}

struct PetAIGuideView: View{
    var step: GuideStep
    var nextStep: AnyView?
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    
    var body: some View{
        ZStack{
            VStack(spacing: 0){
                Image(step.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height - 253)
                
                Spacer()
                    .frame(height: 253)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 30){
                    Text(step.titleText)
                        .modifier(OnboardingTitles())
                        .padding(.top, 30)
                        .padding(.leading, 8)
                    
                    Text(step.descriptionText)
                        .modifier(OnboardingInfo())
                        .padding(.horizontal, 12)
                        .frame(height: 48, alignment: .top)
                    
                    if let nextStep = nextStep {
                        NavigationLink(destination: nextStep) {
                            ContinueButton()
                        }
                        .padding(.bottom, 60)
                    }
                    else{
                        Button(action:{
                            onboardingComplete = true
                        }){
                            ContinueButton()
                        }
                        .padding(.bottom, 60)
                    }
                }
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.darkBackground)
                .cornerRadius(25)
                .shadow(radius: 10)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onAppear {
            handleReviewRequest()
        }
    }
    
    func handleReviewRequest() {
        if step.reviewRequest {
            // Trigger the default review request dialog
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

#Preview {
    ContentView()
}
