//
//  Models.swift
//  globeku-app
//
//  Created by I Gede Arisudana Samanjaya on 17/12/24.
//

import Foundation

struct ContinentTrivia: Decodable {
    let title: String
    let luas: String
    let iklim: String
    let boundaries: String
    let jumlah_negara: Int
    let flora_khas: String
    let fauna_khas: String
}
