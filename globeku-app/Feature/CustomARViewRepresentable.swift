//
//  CustomARViewRepresentable.swift
//  ProtoGlobeKu
//
//  Created by I Gede Arisudana Samanjaya on 15/10/24.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable {
    @Binding var activeContinent: String? // Binding untuk benua aktif
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView()
        context.coordinator.setupARView(arView: arView)
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        context.coordinator.updatePins(for: activeContinent)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        private var arView: CustomARView?

        func setupARView(arView: CustomARView) {
            self.arView = arView
            // Tambahkan model AR atau setup lainnya di sini
        }

        func updatePins(for continent: String?) {
            guard let arView = arView else { return }

            if let continent = continent {
                arView.toggleContinentPins(continent: continent)
            } else {
                arView.toggleContinentPins(continent: "Semua") // Default semua ditampilkan
            }
        }
    }
}


