//
//  TranslationViewModel.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/25/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class TranslationViewModel: ObservableObject {
    @Published var translations: [Translation] = []
    
    private var db = Firestore.firestore()
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var listener: ListenerRegistration?
    
    init() {
        // Listen for auth state changes and only fetch translations once authenticated.
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                print("User is signed in: \(user.uid)")
                self?.fetchTranslations()
            } else {
                print("User is not signed in.")
                // Optionally, clear translations or handle unauthenticated state.
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        listener?.remove()
    }
    
    // Listen for real-time updates from Firestore after the user is authenticated.
    func fetchTranslations() {
        // Remove any existing listener before adding a new one.
        listener?.remove()
        
        listener = db.collection("translations").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching translations: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents in 'translations' collection.")
                return
            }
            
            // Update UI on the main thread.
            DispatchQueue.main.async {
                self.translations = documents.compactMap { document -> Translation? in
                    do {
                        let translation = try document.data(as: Translation.self)
                        return translation
                    } catch {
                        print("Error decoding translation: \(error)")
                        return nil
                    }
                }
            }
        }
    }
    
    // Add a new translation document to Firestore
    func addTranslation(originalText: String, translatedText: String) {
        let newTranslation = Translation(originalText: originalText, translatedText: translatedText)
        do {
            _ = try db.collection("translations").addDocument(from: newTranslation)
        } catch {
            print("Error adding document to Firestore: \(error)")
        }
    }
    
    // Clear all translations from Firestore
    func clearAllTranslations() {
        db.collection("translations").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            querySnapshot?.documents.forEach { $0.reference.delete() }
        }
    }
    
    // Translate text using MyMemory’s REST API (English -> Spanish example)
    func translateText(_ text: String) async -> String? {
        // Replace en|es with the appropriate language pair if desired.
        let urlString = "https://api.mymemory.translated.net/get?q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=en|es"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for MyMemory API.")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            return decodedResponse.responseData.translatedText
        } catch {
            print("Error translating text: \(error)")
            return nil
        }
    }
}

// Helper struct(s) to decode the MyMemory API response
struct MyMemoryResponse: Codable {
    let responseData: ResponseData
    
    struct ResponseData: Codable {
        let translatedText: String
    }
}
