import SwiftUI
import UIKit

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    private let tabBarHeight: CGFloat = 49 // Standard TabBar height
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + tabBarHeight : 0)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    withAnimation(.easeOut(duration: 0.16)) {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation(.easeOut(duration: 0.16)) {
                        keyboardHeight = 0
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

struct MarketView: View {
    @State private var searchText = ""
    @State private var showFilterMenu = false
    @State private var isFilterActive = false
    @State private var selectedSortOption: FilterMenuView.SortOption = .rank
    @State private var selectedTimeFrame: FilterMenuView.TimeFrame = .hour24
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Search Bar
                        SearchBarView(
                            text: $searchText,
                            showFilterMenu: $showFilterMenu,
                            isFilterActive: $isFilterActive
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .padding(.top)
                        
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterPill(title: "Trending", isSelected: true)
                                FilterPill(title: "Hot", isSelected: false)
                                FilterPill(title: "New Listings", isSelected: false)
                                FilterPill(title: "Gainers", isSelected: false)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Token List
                        LazyVStack(spacing: 12) {
                            ForEach(sortedTokens) { token in
                                NavigationLink {
                                    TokenDetailView(token: token)
                                } label: {
                                    TokenListRow(token: PortfolioToken(token: token, amount: 0))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        
                        // Add extra padding at bottom for TabBar
                        Spacer()
                            .frame(height: 100)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Market")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilterMenu) {
                FilterMenuView(
                    selectedSortOption: $selectedSortOption,
                    selectedTimeFrame: $selectedTimeFrame,
                    isFilterActive: $isFilterActive
                )
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var sortedTokens: [Token] {
        var tokens = MockData.tokens
        
        if isFilterActive {
            switch selectedSortOption {
            case .rank:
                break
            case .volume:
                tokens.sort { $0.volume24h > $1.volume24h }
            case .price:
                tokens.sort { $0.price > $1.price }
            case .priceChange:
                tokens.sort { $0.priceChange24h > $1.priceChange24h }
            case .marketCap:
                break
            }
        }
        
        return tokens
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? AppTheme.colors.background : AppTheme.colors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.colors.accent : AppTheme.colors.cardBackground)
            .cornerRadius(20)
    }
}

#Preview {
    MarketView()
        .preferredColorScheme(.dark)
} 
