//
//  ContentView.swift
//  CoronaCharts
//
//  Created by Carlos Henrique on 8/23/20.
//

import SwiftUI

struct TimeSeries: Decodable {
    let Brazil: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}

class ChartViewModel: ObservableObject {
    
    @Published var dataSet = [DayData]()
    var max = 0
    
    init() {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, resp, error) in
            
            guard let data = data else { return }
            
            do {
                let timeSeries = try JSONDecoder().decode(TimeSeries.self, from: data)
                
                DispatchQueue.main.async {
                    self.dataSet = timeSeries.Brazil.filter { $0.deaths > 0 }

                    self.max = self.dataSet.max(by: { (day1, day2) -> Bool in
                                                    return day2.deaths > day1.deaths
                    })?.deaths ?? 0
                }
                
                
            } catch {
                print("JSON Decoder failed: ", error)
            }
        }.resume()
    }
}
struct ContentView: View {
    
    @ObservedObject var vm = ChartViewModel()
    
    var body: some View {
        VStack {
            Text("Corona")
                .font(.system(size: 34, weight: .bold, design: .default))
            Text("Total de Mortes: \(vm.max)")
            
            if !vm.dataSet.isEmpty {
                ScrollView(.horizontal, showsIndicators: true, content: {
                    HStack (alignment: .bottom, spacing: 8, content: {
                        ForEach(vm.dataSet, id: \.self) { day in
                            HStack {
                                Spacer()
                            }.frame(width: 8, height: (CGFloat(day.deaths) / CGFloat(vm.max)) * 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .background(Color.red)
                        }
                    })
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
