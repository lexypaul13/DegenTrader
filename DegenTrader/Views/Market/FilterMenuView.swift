import SwiftUI

struct FilterMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSortOption: SortOption
    @Binding var selectedTimeFrame: TimeFrame
    @Binding var isFilterActive: Bool
    
    enum SortOption: String, CaseIterable {
        case rank = "Rank"
        case volume = "Volume"
        case price = "Price"
        case priceChange = "Price Change"
        case marketCap = "Market Cap"
    }
    
    enum TimeFrame: String, CaseIterable {
        case hour1 = "1h"
        case hour24 = "24h"
        case day7 = "7d"
        case day30 = "30d"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Sort By Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sort By")
                        .font(.title2)
                        .foregroundColor(AppTheme.colors.textPrimary)
                    
                    VStack(spacing: 0) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            FilterOptionRow(
                                title: option.rawValue,
                                isSelected: selectedSortOption == option
                            ) {
                                selectedSortOption = option
                            }
                            
                            if option != SortOption.allCases.last {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                
                // Time Frame Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Time Frame")
                        .font(.title2)
                        .foregroundColor(AppTheme.colors.textPrimary)
                    
                    VStack(spacing: 0) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            FilterOptionRow(
                                title: timeFrame.rawValue,
                                isSelected: selectedTimeFrame == timeFrame
                            ) {
                                selectedTimeFrame = timeFrame
                            }
                            
                            if timeFrame != TimeFrame.allCases.last {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Apply Button
                Button(action: {
                    isFilterActive = true
                    dismiss()
                }) {
                    Text("Apply")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1C1C1E"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.colors.accent)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(AppTheme.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Filter")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.colors.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedSortOption = .rank
                        selectedTimeFrame = .hour24
                        isFilterActive = false
                    }) {
                        Text("Reset")
                            .foregroundColor(AppTheme.colors.accent)
                    }
                }
            }
        }
    }
}

struct FilterOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppTheme.colors.accent)
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    FilterMenuView(
        selectedSortOption: .constant(.priceChange),
        selectedTimeFrame: .constant(.hour1),
        isFilterActive: .constant(false)
    )
} 