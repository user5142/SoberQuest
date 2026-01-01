import SwiftUI

struct AddictionSelectorView: View {
    @Binding var isPresented: Bool
    @StateObject private var appState = AppState.shared
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.loadAddictions()) { addiction in
                    Button(action: {
                        appState.setCurrentAddiction(addiction)
                        isPresented = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(addiction.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(addiction.daysSober) days sober")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if addiction.isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Addiction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

