//
//  Translate_MeApp.swift
//  Translate Me
//
//  Created by Fiyinfoluwa Afolayan on 3/24/25.
//

import SwiftUI
import FirebaseCore

@main
struct Translate_MeApp: App {
    
    init() { // <-- Add an init
           FirebaseApp.configure() // <-- Configure Firebase app
       }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
