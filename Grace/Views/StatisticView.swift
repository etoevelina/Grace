//
//  StatisticView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.05.2024.
//
import SwiftUI
import Charts
import FirebaseFirestore
import PDFKit
import FirebaseStorage

struct CustomProgressBar: View {
    var value: Double
    var total: Double
    var barHeight: CGFloat = 10
    var filledColor: Color = Color.cyan
    var backgroundColor: Color = Color.gray.opacity(0.2)
    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: barHeight)
                    .foregroundColor(backgroundColor)

                Capsule()
                    .frame(width: geometry.size.width * CGFloat(value / total), height: barHeight)
                    .foregroundColor(filledColor)
            }
        }
    }
}

struct StatisticView: View {
    @State private var selectedTraining: Trains? = Trains.stretching
    @State private var ratingData: [RatingData] = []
    let allTrainings: [Trains] = Trains.allCases
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var pdfURL: URL?
    @State private var totalReviews: Int = 0
    @State private var ratingPercentages: [Int: Double] = [:]
    @State private var fiveStarPercentage: Double = 0.0
    @ObservedObject var vm = MainPageViewViewModel()
    
    // Форматирование даты для оси X
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    private var dateFormatter1: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(alignment: .leading){
                        HStack{
                            Text("Выберите тренировку")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.white)
                            Picker("Выберите тренировку", selection: $selectedTraining) {
                                ForEach(allTrainings, id: \.self) { training in
                                    Text(training.title).tag(training as Trains?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                        }
                        
                        Group{
                            DatePicker("Дата начала", selection: $startDate, in: ...endDate, displayedComponents: .date)
                            
                            DatePicker("Дата конца", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                        }.font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                            
                    }.padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        Chart {
                            ForEach(filteredRatingData) { data in
                                LineMark(
                                    x: .value("Дата", data.date, unit: .day),
                                    y: .value("Рейтинг", data.rating)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color.blue)
                                
                                PointMark(
                                    x: .value("Дата", data.date, unit: .day),
                                    y: .value("Рейтинг", data.rating)
                                )
                                .symbolSize(10)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(preset: .aligned, position: .bottom) {
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.day().month())
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) {
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartYScale(domain: 1...5)
                        .frame(width: 350, height: 300)
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 18) {
                        
                        HStack{
                            Text("\(String(format: "%.0f", fiveStarPercentage))%")
                                .font(.system(size: 62, weight: .bold))
                                .italic()
                                .foregroundColor(Color("ColorPink"))
                            Text("отзывов с 5 звездами")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 149, height: 58)
                        }
                        
                       
                        
                        ForEach(1...5, id: \.self) { rating in
                            HStack {
                                HStack{
                                    Text("\(rating)")
                                        .font(.system(size: 26, weight: .bold))
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.yellow)
                                }
                                CustomProgressBar(
                                               value: ratingPercentages[rating] ?? 0.0,
                                               total: 100.0,
                                               barHeight: 10,
                                               filledColor: Color("ColorForTime"),
                                               backgroundColor: Color.white
                                           )
                                           .frame(width: 220, height: 10)
                                           .padding(.horizontal)
                                
                                Text("\(String(format: "%.0f", ratingPercentages[rating] ?? 0.0))%")
     
                            }
                        }
                        Text("Всего отзывов: \(totalReviews)")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding()
                    
                    Button("Создать PDF и загрузить") {
                        createAndUploadPDF()
                    }
                    .padding()
                    
                    if let pdfURL = pdfURL {
                        Link("Скачать PDF", destination: pdfURL)
                            .padding()
                    }
                }
                .navigationTitle("Статистика работы")
                .onChange(of: selectedTraining) { newValue in
                    if let training = newValue {
                        fetchReviews(for: training)
                    } else {
                        ratingData = []
                        totalReviews = 0
                        ratingPercentages = [:]
                        fiveStarPercentage = 0.0
                    }
                }
                .onAppear {
                    if let training = selectedTraining {
                        fetchReviews(for: training)
                    }
                }
            }
        }.preferredColorScheme(.dark)
    }
    
    var filteredRatingData: [RatingData] {
        ratingData.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    func fetchReviews(for training: Trains) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("reviews")
        let query = reviewsRef.whereField("trainingName", isEqualTo: training.title)
        
        query.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let reviews = snapshot.documents.compactMap { doc -> RatingData? in
                    let data = doc.data()
                    let rating = data["rating"] as? Int ?? 0
                    let date = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return RatingData(rating: rating, date: date)
                }
                DispatchQueue.main.async {
                    self.ratingData = reviews.sorted(by: { $0.date < $1.date })
                    calculateReviewStatistics()
                }
            } else {
                DispatchQueue.main.async {
                    self.ratingData = []
                    totalReviews = 0
                    ratingPercentages = [:]
                    fiveStarPercentage = 0.0
                }
            }
        }
    }
    
    func calculateReviewStatistics() {
        totalReviews = ratingData.count
        
        var ratingCounts: [Int: Int] = [:]
        for rating in 1...5 {
            ratingCounts[rating] = ratingData.filter { $0.rating == rating }.count
        }
        
        ratingPercentages = ratingCounts.mapValues { count in
            return Double(count) / Double(totalReviews) * 100.0
        }
        
        fiveStarPercentage = ratingPercentages[5] ?? 0.0
    }
    
    func createAndUploadPDF() {
        let pdfURL = createPDF()
        uploadPDFToFirebase(pdfURL: pdfURL) { url in
            self.pdfURL = url
        }
    }

    func createPDF() -> URL {
        // Создаем PDF-документ
        let pdfMetaData = [
            kCGPDFContextCreator: "Grace",
            kCGPDFContextAuthor: "\(vm.user?.name ?? "") \(vm.user?.surname ?? "")",
            kCGPDFContextTitle: "Отчет о тренировке"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595
        let pageHeight = 842
        let pageSize = CGSize(width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("TrainingReport.pdf")

        try? renderer.writePDF(to: url) { context in
            context.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let title = "Отчет о тренировке"
            title.draw(at: CGPoint(x: 72, y: 72), withAttributes: titleAttributes)
            
            if let vStackImage1 = getVStackImage1() {
                vStackImage1.draw(in: CGRect(x: 320, y: 0, width: vStackImage1.size.width, height: vStackImage1.size.height))
            }
            // Подраздел с основной информацией
            let infoFont = UIFont.systemFont(ofSize: 14)
            let infoAttributes: [NSAttributedString.Key: Any] = [.font: infoFont]
            let trainingInfo = """
            Дата: \(dateFormatter1.string(from: Date()))
            """
            trainingInfo.draw(at: CGPoint(x: 72, y: 100), withAttributes: infoAttributes)

            // Добавляем график
            if let chartImage = getChartImage() {
                chartImage.draw(in: CGRect(x: 72, y: 160, width: 451, height: 300))
            }

            // Добавляем карточку с процентами


            // Добавляем карточку с процентами по рейтингам
            if let vStackImage = getVStackImage() {
                vStackImage.draw(in: CGRect(x: 72, y: 410, width: vStackImage.size.width, height: vStackImage.size.height))
            }
        }

        return url
    }

    func getChartImage() -> UIImage? {
        let hostingController = UIHostingController(rootView:
            Chart {
                ForEach(filteredRatingData) { data in
                    LineMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Рейтинг", data.rating)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue)

                    PointMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Рейтинг", data.rating)
                    )
                    .symbolSize(10)
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: 1...5)
            .frame(width: 380, height: 300)
        )

        let targetSize = CGSize(width: 451, height: 300)
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }

    func getVStackImage1() -> UIImage? {
        let hostingController = UIHostingController(rootView: ZStack {
            Rectangle()
                .stroke(Color(.black), lineWidth: 1)
                .frame(width: 235, height: 64)
            VStack(alignment: .leading, spacing: 3) {
                Group {
                    Text("Тренировка: \(selectedTraining?.title ?? "N/A")")
                    Text("Период отчета: \(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
                    Text("Отчет создал: \(vm.user?.name ?? "") \(vm.user?.surname ?? "")")
                }
                .font(.system(size: 13, weight: .medium))
                .italic()
            }
            
        })

        let targetSize = CGSize(width: 235, height: 150)
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }

    func getVStackImage() -> UIImage? {
        let hostingController = UIHostingController(rootView: VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("\(String(format: "%.0f", fiveStarPercentage))%")
                    .font(.system(size: 62, weight: .bold))
                    .italic()
                    .foregroundColor(Color("ColorPink"))
                Text("отзывов с рейтингом 5")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 149, height: 58)
            }
            ForEach(1...5, id: \.self) { rating in
                HStack {
                    HStack {
                        Text("\(rating)")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                    }
                    CustomProgressBar(
                        value: ratingPercentages[rating] ?? 0.0,
                        total: 100.0,
                        barHeight: 10,
                        filledColor: Color("ColorForTime"),
                        backgroundColor: Color.gray
                    )
                    .frame(width: 220, height: 10)
                    .padding(.horizontal)

                    Text("\(String(format: "%.0f", ratingPercentages[rating] ?? 0.0))%")
                }
            }
            Text("Всего отзывов: \(totalReviews)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
        })

        let targetSize = CGSize(width: 400, height: 400)
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }

    func uploadPDFToFirebase(pdfURL: URL, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("TrainingReports/\(pdfURL.lastPathComponent)")

        storageRef.putFile(from: pdfURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Ошибка загрузки PDF")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Ошибка получения URL PDF")
                    completion(nil)
                    return
                }

                completion(url)
            }
        }
    }
}
#Preview {
    StatisticView()
}
