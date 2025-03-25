//
//  Translation.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/24/25.
//

import Foundation
import FirebaseFirestore

struct Translation: Identifiable, Codable {
    @DocumentID var id: String?
    let originalText: String
    let translatedText: String
}
