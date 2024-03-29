//
//  NewsView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 02.04.2024.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
import Firebase


struct NewsView: View {
    //@State var vm = CarouselNewsView(size: CGSize)
    var body: some View {
        ZStack {
            Image("backSch")
                .resizable()
                .frame(width: 393, height: 895)
                .ignoresSafeArea()
                
            VStack{
               
                GeometryReader { reader in
                    CarouselNewsView(size: reader.size) // Обновлено
                }.background(Color(white: 0.15, opacity: 0.7).ignoresSafeArea())
            }
        }
    }
}

struct CarouselNewsView: View {
    let size: CGSize
    let damping: Double = 5
    let padding: CGFloat = 20
    let colors = [Color("acacac")]
    @State private var news: [New] = [] // Обновлено для хранения новостей
    
    var body: some View {
        VStack{
           
            ScrollView(.horizontal){
                LazyHStack{
                    ForEach(news.indices, id: \.self) { i in // Обновлено
                        let newsItem = news[i] // Обновлено
                        let color = colors[i % colors.count]
                        item(newsItem: newsItem, color: color) // Обновлено
                    }
                }
                .padding(.horizontal, padding)
            }
        }
        .onAppear{
            getNewsData() // Обновлено
        }
    }
    
    func item(newsItem: New, color: Color) -> some View { // Обновлено
        let itemWidth: CGFloat = size.width - padding * 2
        return GeometryReader { reader in
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(color)
                if newsItem.profileImageUrl == "" {
                    VStack {
                        
                        HStack{
                            Spacer()
                            ZStack{
                                Rectangle()
                                    .frame(width: 237, height: 98)
                                    .foregroundColor(.black)
                                    .clipShape( // 1
                                        RoundedCornerShape( // 2
                                            radius: 43,
                                            corners: [.bottomLeft, .topLeft, .bottomRight]
                                                          )
                                    )
                                
                                HStack{
                                    Text(newsItem.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 31, weight: .bold))
                                        .italic()
                                        .frame(width: 235)
                                }
                            }
                        }.padding(.top, 20)
                        
                        Text(newsItem.description)
                            .foregroundColor(.white)
                            .font(.system(size: 27, weight: .bold))
                            .padding(.top, 40)
                            .padding(.horizontal)
                        HStack{
                            Spacer()
                            Image("heartsGroupSmall")
                        }
                        .padding(.trailing)
                        Spacer()
                    }.padding(.top,10)
                }
                else {
                    VStack{
                        ZStack{
                            Rectangle()
                                
                                .frame(width: 241, height: 241)
                                .foregroundColor(.white)
                                .cornerRadius(44)
                                .blur(radius: 21.5)
                            
                            WebImage(url: URL(string: newsItem.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 240, height: 240)
                                .clipped()
                            .cornerRadius(48)
                            
                            Spacer()
                            
                            VStack {
                                HStack{
                                    Spacer()
                                    ZStack{
                                        Rectangle()
                                            .frame(width: 237, height: 98)
                                            .foregroundColor(.black)
                                            .clipShape( // 1
                                                RoundedCornerShape( // 2
                                                    radius: 43,
                                                    corners: [.bottomLeft, .topLeft, .bottomRight]
                                                                  )
                                            )
                                        
                                        HStack{
                                            Text(newsItem.name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 31, weight: .bold))
                                                .italic()
                                                .frame(width: 235)
                                        }
                                    }
                                }
                            }.padding(.top, 170)
                            
                        }
                        VStack{
                            Text(newsItem.description)
                                .foregroundColor(.white)
                                .font(.system(size: 23, weight: .bold))
                                //.padding(.top, 40)
                                .padding(.horizontal)
                        }
                    }
                }
                
            }
            .rotation3DEffect(
                getRotationAngel(reader: reader),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .frame(width: itemWidth, height: itemWidth * 1.4)
    }
    
    func getRotationAngel(reader: GeometryProxy) -> Angle {
        let midX = reader.frame(in: .global).midX
        let degrees = Double(midX - size.width / 2) / damping
        return Angle(degrees: -degrees)
    }
    
    func getNewsData() {
        FirebaseManager.shared.firestore.collection("news")
            .order(by: "creationDate", descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting news document: \(error)")
                } else {
                    var newsData: [New] = []
                    for document in querySnapshot?.documents ?? [] {
                        if let newsItemData = document.data() as? [String: Any] {
                            let id = document.documentID
                            let uid = newsItemData["uid"] as? String ?? ""
                            let name = newsItemData["name"] as? String ?? ""
                            let description = newsItemData["description"] as? String ?? ""
                            let profileImageUrl = newsItemData["profileImageUrl"] as? String ?? ""
                            let creationDate = (newsItemData["creationDate"] as? Timestamp)?.dateValue() ?? Date()
                            
                            let newsItem = New(id: id, uid: uid, name: name, description: description, profileImageUrl: profileImageUrl, creationDate: creationDate)
                            newsData.append(newsItem)
                        }
                    }
                    self.news = newsData
                }
            }
    }
}

#Preview {
    NewsView()
}
