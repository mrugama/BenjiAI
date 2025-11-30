import SwiftUI

struct ToolSpecView: View {
    @State private var myTools: [String]? = []
    var body: some View {
        NavigationStack {
            List {
                if let myTools, myTools.count > 0 {
                    Section("My tools") {
                        ForEach(myTools, id: \.self) { tool in
                            Text(tool)
                        }
                    }
                }

                Section("Available tools") {
                    Label("getTodayDate", systemImage: "calendar")
                        .onTapGesture {
                            myTools?.append("getTodayDate")
                        }
                    Label("searchDuckduckgo", systemImage: "network")
                        .onTapGesture {
                            myTools?.append("searchDuckduckgo")
                        }
                    Label("bitcoin", systemImage: "bitcoinsign")
                        .onTapGesture {
                            myTools?.append("bitcoin")
                        }
                }
            }
            .navigationTitle("Tool specs")
        }
    }
}

#Preview {
    ToolSpecView()
}
