import Foundation

class SavedArticlesViewModel: ObservableObject {
    @Published var savedArticles: [NewsArticle] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSavedArticles()
    }
    
    func saveArticle(_ article: NewsArticle) {
        savedArticles.append(article)
        saveToDisk()
    }
    
    func removeArticle(_ article: NewsArticle) {
        savedArticles.removeAll { $0.id == article.id }
        saveToDisk()
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedArticles) {
            userDefaults.set(encoded, forKey: "savedArticles")
        }
    }
    
    private func loadSavedArticles() {
        if let savedData = userDefaults.data(forKey: "savedArticles"),
           let decodedArticles = try? JSONDecoder().decode([NewsArticle].self, from: savedData) {
            savedArticles = decodedArticles
        }
    }
}
