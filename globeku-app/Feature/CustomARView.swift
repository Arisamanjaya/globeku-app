//
//  CustomARView.swift
//  ProtoGlobeKu
//
//  Created by I Gede Arisudana Samanjaya on 15/10/24.
//

import ARKit
import RealityKit
import SceneKit
import SwiftUI

class CustomARView: ARView, ARSessionDelegate{
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.session.delegate = self
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        
        configration()
        //        placeEntity()
    }
    
    //fungsi untuk mendeteksi gambar
    func configration() {
        //untuk load marker di Assets.xcassest
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Failed to load reference images.")
        }
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1 // markar yang bisa baca saat bersamaan
        
        session.run(configuration)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                print("Gambar terdeteksi: \(imageAnchor.referenceImage.name ?? "Unknown")")
                
                // Tempatkan entitas dan tambahkan gesture
                placeEntity(on: imageAnchor)
            }
        }
    }
    
    //untuk memunculkan si objek
    func placeEntity(on anchor: ARImageAnchor) {
        
        #if targetEnvironment(simulator)
        
        print("Simulator tidak mendukung ARKit. Menjalankan dummy anchor...")
            let dummyAnchorEntity = AnchorEntity(world: SIMD3<Float>(0, 0, -0.5)) // 0.5 meter di depan kamera
            let dummyModelEntity = try! ModelEntity.loadModel(named: "Globe1")
            dummyModelEntity.transform.translation = SIMD3<Float>(0, 0.1, 0) // Posisi dummy model
            dummyModelEntity.transform.scale = SIMD3<Float>(0.01, 0.01, 0.01)
            dummyAnchorEntity.addChild(dummyModelEntity)
            scene.addAnchor(dummyAnchorEntity)
        #else
            // Buat AnchorEntity berdasarkan posisi gambar terdeteksi
            let anchorEntity = AnchorEntity(anchor: anchor)
            //let anchorEntity = AnchorEntity(world: anchor.transform)
            
            let modelEntity = try! ModelEntity.loadModel(named: "Globe1")
            
            // Tentukan posisi spawn dengan mengatur translation (jika perlu)
            modelEntity.transform.translation = SIMD3<Float>(x: 0, y: 0.5, z: 0)
            
            // Mengatur ukuran model dengan scale
            modelEntity.transform.scale = SIMD3<Float>(0.01, 0.01, 0.01) // scale model ke 50% ukuran aslinya
            
            // Tambahkan entitas ke anchor
            anchorEntity.addChild(modelEntity)
            
            // Tambahkan anchorEntity ke scene
            scene.addAnchor(anchorEntity)
            
            addGesture(on: modelEntity)
        #endif
    }
    
    // Fungsi untuk menambahkan gesture
    func addGesture(on object: ModelEntity) {
        object.generateCollisionShapes(recursive: true)

        // Gesture untuk rotasi
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
        
        // Gesture untuk skala
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    // Gesture Control Rotation
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let entity = gesture.view as? ARView else { return }
        guard let modelEntity = entity.scene.anchors.first?.children.first as? ModelEntity else { return }
        
        let translation = gesture.translation(in: self)
        
        // Tentukan sudut rotasi
        let horizontalRotationAngle = Float(translation.x) * 0.01 // Rotasi horizontal (sumbu Y)
        //let verticalRotationAngle = Float(translation.y) * 0.01   // Rotasi vertikal (sumbu X)
        
        // Reset nilai gesture setelah memproses
        gesture.setTranslation(.zero, in: self)
        
        // Terapkan rotasi pada model entity
        modelEntity.transform.rotation *= simd_quatf(angle: horizontalRotationAngle, axis: [0, 1, 0]) // rotasi horizontal
        //modelEntity.transform.rotation *= simd_quatf(angle: verticalRotationAngle, axis: [1, 0, 0])   // rotasi vertikal
    }

    // Gesture Control Scale
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = gesture.view as? ARView else { return }
        guard let modelEntity = entity.scene.anchors.first?.children.first as? ModelEntity else { return }

        // Perbesar atau perkecil berdasarkan skala
        modelEntity.scale *= SIMD3<Float>(repeating: Float(gesture.scale))
        
        // Reset skala gesture
        gesture.scale = 1.0
    }
}
