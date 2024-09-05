import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            WidgetBrowserView()
                .navigationTitle("opus")
                .environmentObject(locationManager)
        }
    }
}
