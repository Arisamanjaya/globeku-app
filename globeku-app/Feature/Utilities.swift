//
//  Utilities.swift
//  globeku-app
//
//  Created by I Gede Arisudana Samanjaya on 17/12/24.
//

// Utilities.swift
import Foundation

func loadTriviaData() -> [String: ContinentTrivia]? {
    guard let url = Bundle.main.url(forResource: "continentTrivia", withExtension: "json") else {
        print("File JSON tidak ditemukan.")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let triviaData = try decoder.decode([String: ContinentTrivia].self, from: data)
        return triviaData
    } catch {
        print("Gagal memuat dan mengonversi file JSON: \(error)")
        return nil
    }
}
