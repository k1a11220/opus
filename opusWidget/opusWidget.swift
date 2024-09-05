import WidgetKit
import SwiftUI
import WeatherKit

struct Provider: TimelineProvider {
    let weatherService = WeatherService()
    let locationManager = LocationManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weather: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weather: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                guard let location = locationManager.location else {
                    let entries = [SimpleEntry(date: Date(), weather: nil)]
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                    return
                }
                
                let weather = try await weatherService.fetchWeather(for: location)
                let entry = SimpleEntry(date: Date(), weather: weather)
                let nextUpdate = Date().addingTimeInterval(30 * 60) // Update every 30 minutes
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("Error fetching weather: \(error)")
                let entries = [SimpleEntry(date: Date(), weather: nil)]
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weather: WeatherModel?
}

struct opusWidgetEntryView : View {
    var entry: Provider.Entry
    var style: WidgetStyle
    
    var body: some View {
        if let weather = entry.weather {
            WidgetView(weather: weather, style: style)
        } else {
            Text("Unable to load weather")
        }
    }
}

struct WidgetView: View {
    let weather: WeatherModel
    let style: WidgetStyle
    
    var body: some View {
        switch style {
        case .minimal:
            MinimalWidgetView(weather: weather)
        case .elegant:
            ElegantWidgetView(weather: weather)
        case .colorful:
            ColorfulWidgetView(weather: weather)
        }
    }
}

struct MinimalWidgetView: View {
    let weather: WeatherModel
    
    var body: some View {
        VStack {
            Image(systemName: weather.symbolName)
                .font(.largeTitle)
            Text("\(Int(weather.temperature.value))°")
                .font(.title)
        }
    }
}

struct ElegantWidgetView: View {
    let weather: WeatherModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(Int(weather.temperature.value))°")
                    .font(.largeTitle)
                Text(weather.condition.description)
                    .font(.caption)
            }
            Spacer()
            Image(systemName: weather.symbolName)
                .font(.largeTitle)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

struct ColorfulWidgetView: View {
    let weather: WeatherModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack {
                Image(systemName: weather.symbolName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("\(Int(weather.temperature.value))°")
                    .font(.title)
                    .foregroundColor(.white)
                Text(weather.condition.description)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}

@main
struct opusWidget: Widget {
    let kind: String = "opusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            opusWidgetEntryView(entry: entry, style: .minimal)
        }
        .configurationDisplayName("Weather Widget")
        .description("Display current weather in a beautiful design.")
        .supportedFamilies([.systemSmall])
    }
}
