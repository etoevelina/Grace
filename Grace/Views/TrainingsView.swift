//
//  TrainingsView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 27.04.2024.
import SwiftUI
import Firebase

struct ReviewView: View {
    var review: Review
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            StarRatingView(rating: Double(review.rating))
                .font(.system(size: 20))
                .opacity(0.7)
            Text(review.text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(3)
            HStack{
                Spacer()
                Text(dateFormatter.string(from: review.date))
                    .font(.system(size: 11, weight: .bold))
                    .italic()
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            
        }
        .padding(.leading, 10)
        .frame(width: 282, height: 78) // Устанавливаем фиксированные размеры для карточек
        .background(Color("ColorViolet"))
        .cornerRadius(12)
    }
}


struct StarRatingView: View {
    var rating: Double
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= Int(rating.rounded()) ? "star.fill" : "star")
                    .foregroundColor(index <= Int(rating.rounded()) ? .yellow : .gray)
            }
        }
    }
}

    struct TrainingDetailView: View {
        var training: Trains
        @State private var averageRating: Double
        @State private var reviews: [Review]
        @State private var showFullReviews: Bool = false
        @State private var cardOffset: CGFloat = 0
        @State private var currentIndex: Int = 0
        @State private var showSchedule = false
            
            var body: some View {
                ZStack {
                    Color(.black)
                        .ignoresSafeArea()
                    
                    Image("backSch")
                        .resizable()
                        .frame(width: 413, height: 902)
                        .ignoresSafeArea()
                        .opacity(0.6)
                    
                    VStack {
                        
                        HStack{
                            Spacer()
                            StarRatingView(rating: averageRating)
                                .font(.system(size: 24))
                                .onAppear {
                                    fetchAverageRating(for: training) { rating in
                                        averageRating = rating
                                    }
                                }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 80)
                        
                        VStack(alignment: .leading, spacing: 30) {
                            Text(training.title)
                                .font(.system(size: 53).weight(.bold))
                                .italic()
                                .foregroundColor(Color("ColorForTime"))
                                
                            
                            Text(training.description)
                                .font(.system(size: 19).weight(.bold))
                                .foregroundColor(.white)
                                
                            
                        }
                        .padding()
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                                            ScrollViewReader { scrollViewProxy in
                                                HStack(spacing: 20) {
                                                    ForEach(filteredReviews.indices, id: \.self) { index in
                                                        ReviewView(review: filteredReviews[index])
                                                            .frame(width: UIScreen.main.bounds.width - 40, height: 80)
                                                            .id(index)
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                                .onChange(of: currentIndex) { newValue in
                                                    withAnimation {
                                                        scrollViewProxy.scrollTo(newValue, anchor: .center)
                                                    }
                                                }
                                            }
                                        }




                              Button("Посмотреть все отзывы") {
                                  showFullReviews.toggle()
                              }
                              .fullScreenCover(isPresented: $showFullReviews) {
                                          FullReviewsView(reviews: reviews)
                                      }
                        
                        Button(action: {
                            showSchedule.toggle()
                        }) {
                            HStack {
                                Spacer()
                                Text("Прийти на тренировку")
                                    .foregroundColor(.black)
                                    .padding(.vertical, 20)
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                            }
                            .background(Color(red: 0.92, green: 0.6, blue: 1))
                            .clipShape(
                                RoundedCornerShape(
                                    radius: 20,
                                    corners: [.bottomLeft, .bottomRight, .topRight]
                                )
                            )
                            .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                        }
                        .frame(width: 281, height: 75)
                        .padding(.top, 50)
                        .sheet(isPresented: $showSchedule) {
                            ZStack {
                                Color.black.opacity(0.5).ignoresSafeArea()
                                ScheduleView()
                            }
                        }
                        Spacer()
                          }
                          .onAppear {
                                      fetchReviews(for: training)
                                      //startTimer()
                      }
                }
                  }
        
        private var filteredReviews: [Review] {
                reviews.filter { $0.rating == 5 }
            }

        private func startTimer() {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % reviews.count
                    }
                }
            }

        func fetchAverageRating(for training: Trains, completion: @escaping (Double) -> Void) {
            let db = Firestore.firestore()
            let reviewsRef = db.collection("reviews")
            let query = reviewsRef.whereField("trainingName", isEqualTo: training.title)
            
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Ошибка при получении отзывов: \(error.localizedDescription)")
                    completion(0)
                } else {
                    var totalRating = 0
                    var numberOfReviews = 0
                    
                    for document in snapshot!.documents {
                        if let rating = document.data()["rating"] as? Int {
                            totalRating += rating
                            numberOfReviews += 1
                        }
                    }
                    
                    let averageRating = numberOfReviews > 0 ? Double(totalRating) / Double(numberOfReviews) : 0
                    completion(averageRating)
                }
            }
        }
        
        func fetchReviews(for training: Trains) {
            let db = Firestore.firestore()
            let reviewsRef = db.collection("reviews")
            let query = reviewsRef.whereField("trainingName", isEqualTo: training.title)
            
            query.getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    reviews = snapshot.documents.compactMap { doc -> Review? in
                        let data = doc.data()
                        let id = doc.documentID
                        let text = data["reviewText"] as? String ?? ""
                        let rating = data["rating"] as? Int ?? 0
                        let date = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let trainerName = (data ["trainerName"]) as? String ?? ""
                        let trainerSurname = (data ["trainerSurame"]) as? String ?? ""
                        let userFullName = (data ["userFullName"]) as? String ?? ""
                        return Review(id: id, text: text, rating: rating, date: date, trainerName: trainerName, trainerSurname: trainerSurname, userFullName: userFullName  )
                    }
                }
            }
        }
        init(training: Trains, reviews: [Review], averageRating: Double) {
                self.training = training
                self.reviews = reviews
                self.averageRating = averageRating
            }
    }

    struct FullReviewsView: View {
        var reviews: [Review]
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter
        }
        @Environment(\.presentationMode) var presentationMode
        var body: some View {
            NavigationView {
                List(reviews, id: \.id) { review in
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack{
                                Text("\(review.userFullName)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                Spacer()
                                StarRatingView(rating: Double(review.rating))
                            }
                            Text(review.text).padding()
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            HStack{
                                Text("Тренер: \(review.trainerName) \(review.trainerSurname)")
                                    .font(.system(size: 11, weight: .bold))
                                    .italic()
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(dateFormatter.string(from: review.date))
                                    .font(.system(size: 11, weight: .bold))
                                    .italic()
                                    .foregroundColor(.gray)
                                    .padding(.trailing)
                            }
                        }
                    }.preferredColorScheme(.dark)
                }
                .navigationBarTitle("Отзывы", displayMode: .inline)
                .toolbar {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()  // Правильный способ закрыть представление
                    
                
                    }
                }
            }
        }
    }
struct TrainingsCarousel: View {
    
    let trainings: [Trains] = Trains.allCases

    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            Image("backSch")
                .resizable()
                .frame(width: 413, height: 902)
                .ignoresSafeArea()
                .opacity(0.6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(trainings, id: \.self) { training in
                        GeometryReader { geometry in
                            NavigationLink(destination: TrainingDetailView(training: training, reviews: [], averageRating: 0.0)) {
                                VStack {
                                    ZStack{
                                        Image(training.imageName)
                                            .resizable()
                                            .frame(width: 269, height: 269)
                                            .cornerRadius(128)
                                        HStack{
                                            if training.title == "Круговая тренировка" {
                                                Text(training.title)
                                                    .font(.system(size: 30, weight: .bold))
                                                    .foregroundColor(.white)
                                                .frame(width: 215, height: 98)
                                            }  else {
                                                Text(training.title)
                                                    .font(.system(size: 31, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 165, height: 65)
                                            }
                                            
                                        }
                                        .background(Color(Color.black))
                                        .cornerRadius(20)
                                        .padding(.top, 230)
                                        .padding(.trailing, 90)
                                    }
                                }
                                .padding()
                                .background(Color("ColorCardTraining"))
                                .cornerRadius(12)
                                .shadow(radius: 3)
                                .scaleEffect(self.scaleEffect(for: geometry))
                                .animation(.easeOut(duration: 0.5))
                            }
                            .buttonStyle(PlainButtonStyle()) // Убирает стиль кнопки по умолчанию
                            .frame(width: 250, height: 450)
                        }
                        .frame(width: 350, height: 450)
                    }
                }
                .padding(.horizontal, (UIScreen.main.bounds.width - 300) / 2)
            }.padding()
        }
    }

    private func scaleEffect(for geometry: GeometryProxy) -> CGFloat {
        var scale: CGFloat = 1.0
        let offset = geometry.frame(in: .global).midX - UIScreen.main.bounds.width / 2
        let absOffset = abs(offset)
        if absOffset < UIScreen.main.bounds.width / 2 {
            scale = 1 + (1 - absOffset / (UIScreen.main.bounds.width / 2)) * 0.2
        }
        return scale
    }
}

struct TrainingsCarousel_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainingsCarousel()
        }
    }
}

extension Trains {
    var description: String {
        switch self {
        case .stretching: return Descriptions.stretching.fullText
        case .yoga: return Descriptions.yoga.fullText
        case .trx: return Descriptions.trx.fullText
        case .functionalTrain: return Descriptions.functionalTrain.fullText
        case .silovaya: return Descriptions.silovaya.fullText
        }
    }
}


