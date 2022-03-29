//
//  OfflinePage.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 29.03.22.
//

import SwiftUI

struct OfflinePage: View {
        
    @Binding var isRetrying: Bool
    var onRetry: () -> Void
    
    var body: some View {
        VStack {
            Text("No connection")
                .font(.system(size: 25))
            Text("No or bad internet connection. Please make sure you are connected to a network.")
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
            if (!isRetrying) {
                Button("Retry") {
                    isRetrying = true
                    onRetry()
                }
            } else {
                ProgressView()
            }
        }
    }
}

//struct OfflinePage_Previews: PreviewProvider {
//    static var previews: some View {
//        OfflinePage() {
//
//        }
//    }
//}
