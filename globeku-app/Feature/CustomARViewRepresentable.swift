//
//  CustomARViewRepresentable.swift
//  ProtoGlobeKu
//
//  Created by I Gede Arisudana Samanjaya on 15/10/24.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
