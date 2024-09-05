import Foundation
import WeatherKit
import CoreLocation

class WeatherService {
    private let weatherService = WeatherService.shared
    
    func fetchWeather(for location: CLLocation) async throws -> WeatherModel {
        let weather = try await weatherService.weather(for: location)
        return WeatherModel(currentWeather: weather.currentWeather)
    }
}
