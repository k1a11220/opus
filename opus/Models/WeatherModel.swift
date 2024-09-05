import Foundation
import WeatherKit

struct WeatherModel {
    let temperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let symbolName: String
    
    init(currentWeather: CurrentWeather) {
        self.temperature = currentWeather.temperature
        self.condition = currentWeather.condition
        self.symbolName = currentWeather.symbolName
    }
}
