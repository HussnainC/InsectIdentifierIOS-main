//
//  HomeView.swift
//  InsectIdentifier
//
//  Created by Hussnain on 12/03/2025.
//

import SwiftUI

struct TabModel: Identifiable {
    let id: Int
    let title: String
    let planId: String = ""
}

struct PremiumView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 1
    
    private let tabs: [TabModel] = [
        TabModel(id: 1, title: "weekly"),
        TabModel(id: 2, title: "monthly"),
        TabModel(id: 3, title: "yearly")
    ]
    
    var body: some View {
        VStack {
            topBar
            Spacer()
            Image("premium_img")
                .resizable()
                .scaledToFit()
                .frame(height: 140).frame(maxWidth: .infinity)
            
            ImageLabel(icon: "ads_stop", label: "afe")
            
            tabSelectionView
            
            PremiumBoard(price: "$34.99", title: "per_month")
            
            Text("per_des")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            bottomBar
        }
        .padding(.horizontal,15).navigationBarBackButtonHidden()
    }
    
    private var topBar: some View {
        
        HStack {
            Image("ic_diamond")
                .resizable()
                .frame(width: 24, height: 24)
            
            Text("getp")
                .font(.title3).bold()
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("ic_close")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
       
    }
    
    private var tabSelectionView: some View {
        HStack {
            ForEach(tabs) { tab in
                TabIndicator(title: tab.title, isSelected: selectedTab == tab.id) {
                    selectedTab = tab.id
                }
            }
        }
        .padding(.horizontal,10).padding(.vertical,10)
        .background(Color.blue.opacity(0.1))
        .clipShape(Capsule())
    }
    
    private var bottomBar: some View {
        Button(action: {}) {
            Text("pu")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding(.bottom, 12)
    }
}

struct TabIndicator: View {
    let title: String
    let isSelected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(isSelected ? .black : .gray)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
            .clipShape(Capsule())
            .onTapGesture { onClick() }
    }
}

struct ImageLabel: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(icon)
                .resizable()
                .frame(width: 30, height: 30)
            Text(NSLocalizedString(label, comment: ""))
                .font(.headline)
            Spacer()
        }
    }
}

struct PremiumBoard: View {
    let price: String
    let title: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.blue)
            .frame(height: 150)
            .overlay(
                HStack(spacing: 12) {
                    Image("pro_indicator")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading) {
                        Text(price)
                            .font(.title).foregroundStyle(Color.white).bold()
                        Text(NSLocalizedString(title,comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    Image("ic_box").resizable().frame(width: 90, height: 90)
                }
                .padding()
            )
    }
}

#Preview {
    PremiumView()
}
