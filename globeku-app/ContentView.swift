//
//  ContentView.swift
//  globeku-app
//
//  Created by I Gede Arisudana Samanjaya on 30/11/24.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var activeContinent: String? = nil // Nil artinya tidak ada benua aktif
    @State private var showTrivia: Bool = false
    @State private var triviaData: [String: ContinentTrivia]? = nil // Data trivia
    @State private var showAlert: Bool = false // Untuk alert download marker


    
    var body: some View {
        ZStack {
            CustomARViewRepresentable(activeContinent: $activeContinent)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        downloadMarker{
                            self.showAlert = true // Tampilkan alert setelah berhasil
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                    
                    Button(action: {
                        activeContinent = nil // Tampilkan semua label
                    }) {
                        Text("Semua")
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        activeContinent = "Location_Asia" // Tampilkan label Asia
                    }) {
                        Text("Asia")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        activeContinent = "Location_Afrika" // Tampilkan label Afrika
                    }) {
                        Text("Afrika")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        activeContinent = "Location_Amerika" // Tampilkan label Amerika
                    }) {
                        Text("Amerika")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        activeContinent = "Location_Australia" // Tampilkan label Australia
                    }) {
                        Text("Australia")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        activeContinent = "Location_Eropa" // Tampilkan label Eropa
                    }) {
                        Text("Eropa")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Tombol Reset
                    Button(action: resetAllFeatures) {
                        Text("Reset")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            Spacer()
                HStack{
                    Spacer()
                    // Tombol Trivia
                    Button(action: {
                        if let activeContinent = activeContinent, activeContinent != "Semua" {
                            showTrivia.toggle()
                        }
                    }) {
                        Text("Trivia")
                            .padding()
                            .background(activeContinent == nil || activeContinent == "Semua" ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(activeContinent == nil || activeContinent == "Semua")
                    }

                    // Window Trivia
                    if showTrivia, let activeContinent = activeContinent, let trivia = triviaData?[activeContinent] {
                        VStack(alignment: .leading) {
                            Text(trivia.title).font(.title).padding(.bottom, 5)
                            Text("Luas: \(trivia.luas)").padding(.bottom, 3)
                            Text("Iklim: \(trivia.iklim)").padding(.bottom, 3)
                            Text("Boundaries: \(trivia.boundaries)").padding(.bottom, 3)
                            Text("Jumlah Negara: \(trivia.jumlah_negara)").padding(.bottom, 3)
                            Text("Flora Khas: \(trivia.flora_khas)").padding(.bottom, 3)
                            Text("Fauna Khas: \(trivia.fauna_khas)").padding(.bottom, 3)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .transition(.slide)
                        .foregroundColor(.black)
                        .animation(.easeInOut)
                    }
                }
                .onAppear {
                    self.triviaData = loadTriviaData() // Load data saat view muncul
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unduh Berhasil"),
                message: Text("Marker telah disimpan ke galeri."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func resetAllFeatures() {
            activeContinent = nil // Reset benua aktif
            showTrivia = false    // Sembunyikan window trivia
            showAlert = false     // Sembunyikan alert
            triviaData = loadTriviaData() // Muat ulang data trivia
            print("Semua fitur telah direset ke posisi awal.")
        }
    
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
    
    func downloadMarker(completion: @escaping () -> Void) {
        // Pastikan file marker ada di bundle
        guard let markerURL = Bundle.main.url(forResource: "marker", withExtension: "jpg") else {
            print("File marker.jpg tidak ditemukan di bundle.")
            return
        }
        print("File marker ditemukan di path: \(markerURL)")

        // Meminta izin akses ke Photo Library
        PHPhotoLibrary.requestAuthorization { status in
            print("Status izin Photo Library: \(status.rawValue)")
            if status == .authorized {
                do {
                    let markerData = try Data(contentsOf: markerURL)
                    print("Data marker berhasil dibaca")
                    if let image = UIImage(data: markerData) {
                        // Menyimpan gambar ke galeri
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        print("Marker berhasil disimpan ke Photo Library.")
                        // Memanggil closure setelah berhasil
                        DispatchQueue.main.async {
                            completion() // Menampilkan alert
                        }
                    }
                } catch {
                    print("Gagal membaca file marker: \(error)")
                }
            } else {
                print("Akses ke Photo Library tidak diizinkan.")
            }
        }
    }
}

#Preview {
    ContentView()
}


