import ARKit
import RealityKit
import SwiftUI
import Photos
import Foundation

class CustomARView: ARView, ARSessionDelegate {
    var wrappedModel: Entity?
    var continentPins: [String: Bool] = [
        "pinBenua": false,
        "Afrika": false,
        "Amerika": false,
        "Asia": false,
        "Australia": false,
        "Eropa": false
    ]
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.session.delegate = self
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        configureTracking()
    }
    
    func configureTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Failed to load reference images.")
        }
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        session.run(configuration)
    }
    
    //fungsi membuat marker sebagai anchor
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                print("Gambar terdeteksi: \(imageAnchor.referenceImage.name ?? "Unknown")")
                placeEntity(on: imageAnchor)
            }
        }
    }
    
    //fungsi utama untuk show model pada anchor,  gesture,
    func placeEntity(on anchor: ARImageAnchor) {
        
        //kondisi untuk running di simulator
        #if targetEnvironment(simulator)
        let dummyAnchorEntity = AnchorEntity(world: SIMD3<Float>(0, 0, -0.5))
        let dummyModelEntity = try? ModelEntity.loadModel(named: "Globe1")
        dummyModelEntity?.transform.translation = SIMD3<Float>(0, 0.1, 0)
        dummyModelEntity?.transform.scale = SIMD3<Float>(0.01, 0.01, 0.01)
        if let dummyModelEntity = dummyModelEntity {
            dummyAnchorEntity.addChild(dummyModelEntity)
            scene.addAnchor(dummyAnchorEntity)
        }
        #else
        do {
            let anchorEntity = AnchorEntity(anchor: anchor)
            let modelEntity = try! ModelEntity.load(named: "Globe")
            
//            debugEntityHierarchy(for: modelEntity)
            
            // Bungkus model dengan root
            let wrappedModel = Entity()
            wrappedModel.name = "wrappedModel"
            wrappedModel.addChild(modelEntity)
            
            initializePins()
            
            // Simpan wrappedModel untuk gesture
            self.wrappedModel = wrappedModel
            
            // Tambahkan wrappedModel ke anchor
            anchorEntity.addChild(wrappedModel)
            self.scene.anchors.append(anchorEntity)

            // Tambahkan gesture ke wrappedModel
            addGesture(on: wrappedModel)
        }
        #endif
    }
    
    //fungsi hide semua pin ketika app startup
        func initializePins() {
            for continent in continentPins.keys {
                print("Continent Key: \(continent)") // Debugging
                if continent != "pinBenua" {
                    if let entity = wrappedModel?.findEntity(named: continent) {
                        entity.isEnabled = false
                        print("\(continent) pin hidden.")
                    }
                }
            }
            print("All continent pins initialized to hidden.")
        }


    
    //fungsi untuk fitur hide dan show benua
    func toggleContinentPins(continent: String) {
            if continent == "Semua" {
                if let pinBenua = self.scene.findEntity(named: "pinBenua") {
                    pinBenua.children.forEach { $0.isEnabled = true }
                }
            } else if let pinBenua = self.scene.findEntity(named: "pinBenua"),
                      let specificContinent = pinBenua.findEntity(named: continent) {
                pinBenua.children.forEach { $0.isEnabled = false }
                specificContinent.isEnabled = true
            }
        }

    
    func wrapEntityInRoot(entity: Entity) -> ModelEntity {
        let rootModel = ModelEntity()
        rootModel.addChild(entity)
        return rootModel
    }
    
    func debugEntityHierarchy(for entity: Entity, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)Entity: \(entity.name.isEmpty ? "Unnamed" : entity.name)")
        print("\(indent)  Children Count: \(entity.children.count)")
        for child in entity.children {
            debugEntityHierarchy(for: child, depth: depth + 1)
        }
    }
    
    func addGesture(on wrappedModel: Entity) {
        // Tambahkan gesture recognizer ke ARView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(pinchGesture)
        
        // Pastikan collision shape untuk interaksi
        wrappedModel.generateCollisionShapes(recursive: true)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let wrappedModel = self.wrappedModel else {
            print("Wrapped model is not available")
            return
        }

        let translation = gesture.translation(in: self)
        let horizontalRotationAngle = Float(translation.x) * 0.01

        // Rotasi model di sekitar sumbu Y
        wrappedModel.transform.rotation *= simd_quatf(angle: horizontalRotationAngle, axis: [0, 1, 0])

        // Reset nilai gesture
        gesture.setTranslation(.zero, in: self)
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let wrappedModel = self.wrappedModel else {
            print("Wrapped model is not available")
            return
        }
        
        // Batasi skala minimal dan maksimal
        let minScale: Float = 0.1
        let maxScale: Float = 5.0

        let scaleFactor = Float(gesture.scale)
        var newScale = wrappedModel.scale * SIMD3<Float>(repeating: scaleFactor)

        // Pastikan skala dalam batas
        newScale.x = min(max(newScale.x, minScale), maxScale)
        newScale.y = min(max(newScale.y, minScale), maxScale)
        newScale.z = min(max(newScale.z, minScale), maxScale)

        wrappedModel.scale = newScale

        // Reset nilai gesture
        gesture.scale = 1.0
    }
}
