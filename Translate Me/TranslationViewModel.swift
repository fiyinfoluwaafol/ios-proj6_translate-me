//
//  TranslationViewModel.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/25/25.
//

import Foundation
import FirebaseFirestore
import Combine

class TranslationViewModel: ObservableObject {
    @Published var translations: [Translation] = []
    
    private var db = Firestore.firestore()
    
    // Fetch existing translations on initialization
    init() {
        fetchTranslations()
    }
    
    // Listen for real-time updates from Firestore
    func fetchTranslations() {
        db.collection("translations").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents in 'translations' collection.")
                return
            }
            self.translations = documents.compactMap { document -> Translation? in
                try? document.data(as: Translation.self)
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
        // Replace en|es with the appropriate language pair if desired
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
