import SwiftUI

struct WidgetBrowserView: View {
    @StateObject private var viewModel = WidgetBrowserViewModel()
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        List(viewModel.widgets) { widget in
            NavigationLink(destination: WidgetPreviewView(widget: widget)) {
                HStack {
                    widget.previewImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    Text(widget.name)
                    
                    Spacer()
                    
                    if widget.isPremium && !viewModel.isSubscribed {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .disabled(widget.isPremium && !viewModel.isSubscribed)
        }
        .navigationBarItems(trailing: subscriptionButton)
    }
    
    private var subscriptionButton: some View {
        NavigationLink(destination: SubscriptionView()) {
            Text(viewModel.isSubscribed ? "Subscribed" : "Subscribe")
        }
    }
}
