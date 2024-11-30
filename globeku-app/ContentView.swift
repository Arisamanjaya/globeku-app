//
//  ContentView.swift
//  globeku-app
//
//  Created by I Gede Arisudana Samanjaya on 30/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(){
//            Text("hello")
//                .background()
        CustomARViewRepresentable()
        .ignoresSafeArea()
        .overlay(){
            VStack(){
                Text("hello")
                    .background()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

