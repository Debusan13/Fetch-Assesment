//
//  ContentView.swift
//  Fetch Assesment
//
//  Created by Devak Nanda on 2/1/23.
//

import SwiftUI

struct Item: Decodable, Identifiable {
    var id: Int
    var listId: Int
    var name: String

    enum CodingKeys: String, CodingKey {
        case id
        case listId
        case name
    }
}

extension Item {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        listId = try container.decode(Int.self, forKey: .listId)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}

struct ItemRow: View {
    var item: Item

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text(String(item.listId))
                .font(.caption)
        }
    }
}

struct ContentView: View {
    @State var items = [Item]()
    var body: some View {
        NavigationView {
            List {
                ForEach(group(), id: \.id) { item in
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationBarItems(trailing: Button(action: loadData) {
                Text("Load Data")
            })
            .onAppear(perform: loadData)
        }
    }

    func loadData() {
        let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json")
      
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Item].self, from: data) {
                    DispatchQueue.main.async {
                        self.items = decodedResponse.filter { $0.name != "" }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }

    func group() -> [Item] {
        Dictionary(grouping: items, by: { $0.listId })
            .sorted { $0.key < $1.key }
            .flatMap { $0.value.sorted { $0.id < $1.id } }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//        print("data")
//        if let data = x3.data(using: .utf8) {
//            if let decodedResponse = try? JSONDecoder().decode([Item].self, from: data) {
//                print("decoded json")
//                DispatchQueue.main.async {
//                    // Filter out any items where name is blank or null
//                    self.items = decodedResponse.filter { $0.name != "" }
//                    // The list should be sorted by listId first then name
//                    self.items.sort { $0.listId < $1.listId && $0.name < $1.name}
//                }
//                return
//            }
//        }
