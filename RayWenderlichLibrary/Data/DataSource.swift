//
//  DataSource.swift
//  RayWenderlichLibrary
//
//  Created by Жанадил on 5/12/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation

// Извлекли данные из plist-a и присвоили эти данные массиву Tutorials
class DataSource {
    static let shared = DataSource()
    
    var tutorials: [TutorialCollection]
    private let decoder = PropertyListDecoder()
    
    private init() {
        guard let url = Bundle.main.url(forResource: "Tutorials", withExtension: "plist"),
        let data = try? Data(contentsOf: url),
        let tutorials = try? decoder.decode([TutorialCollection].self, from: data) else{
            self.tutorials = []
            return
        }
        
        self.tutorials = tutorials
    }
}
