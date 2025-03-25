//
//  HistoryView.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/25/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack {
            // List of translations
            List(viewModel.translations) { translation in
                VStack(alignment: .leading, spacing: 4) {
                    Text(translation.originalText)
                        .font(.headline)
                    Text(translation.translatedText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Button to clear all translations
            Button(action: {
                viewModel.clearAllTranslations()
            }) {
                Text("Clear All Translations")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationTitle("Saved Translations")
    }
}

