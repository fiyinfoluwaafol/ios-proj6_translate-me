//
//  Translate_MeApp.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/24/25.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
      signInAnonymously()
    return true
  }
}

@main
struct Translate_MeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}

private func signInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Failed to sign in anonymously: \(error.localizedDescription)")
            } else {
                print("Signed in anonymously with user ID: \(authResult?.user.uid ?? "")")
            }
        }
    }
