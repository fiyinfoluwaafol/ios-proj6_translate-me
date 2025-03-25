//
//  ContentView.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranslationViewModel()
    
    @State private var textToTranslate: String = ""
    @State private var translatedText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // TextField for user input
                TextField("Enter text to translate", text: $textToTranslate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Button to perform translation
                Button("Translate Me") {
                    Task {
                        if let result = await viewModel.translateText(textToTranslate) {
                            translatedText = result
                            // Save to Firestore
                            viewModel.addTranslation(
                                originalText: textToTranslate,
                                translatedText: result
                            )
                        }
                    }
                }
                .padding()
                
                // Show the translated text
                Text(translatedText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // Navigation to HistoryView
                NavigationLink(destination: HistoryView(viewModel: viewModel)) {
                    Text("View Saved Translations")
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Translate Me")
        }
    }
}


#Preview {
    ContentView()
}
