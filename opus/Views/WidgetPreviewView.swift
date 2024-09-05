import SwiftUI
import WidgetKit

struct WidgetPreviewView: View {
    let widget: WidgetModel
    @State private var weather: WeatherModel?
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        VStack {
            Text(widget.name)
                .font(.title)
            
            if let weather = weather {
                WidgetView(weather: weather, style: widget.style)
                    .frame(width: 169, height: 169)
                    .cornerRadius(38.5)
                    .shadow(radius: 5)
            } else {
                ProgressView()
            }
            
            Button("Add to Home Screen") {
                addWidgetToHomeScreen()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            fetchWeather()
        }
    }
    
    private func fetchWeather() {
        Task {
            do {
                let weatherService = WeatherService()
                if let location = locationManager.location {
                    let fetchedWeather = try await weatherService.fetchWeather(for: location)
                    await MainActor.run {
                        weather = fetchedWeather
                    }
                }
            } catch {
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    private func addWidgetToHomeScreen() {
        // This is just a placeholder. In reality, you would guide the user to add the widget manually.
        print("Guide user to add widget to home screen")
    }
}
