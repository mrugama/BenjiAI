import SwiftUI

struct ConvertToByteView: View {
    
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Input your text here...", text: $inputText)
            let tokens = convertToTokens(inputText)
            let text = convertToBits(inputText)
            let numberOfCharacters = inputText.count
            Text(
                """
                **Number of characters:** \(numberOfCharacters)
                **Number of tokens:** \(tokens)
                """
            )
            Divider()
            Text("**Input in bits:**\n\(text)")
            Spacer()
        }
        .padding()
    }
    
    func convertToBits(_ input: String) -> String {
        let inputData = input.data(using: .utf8)!
        return inputData.map{ String($0, radix: 2) }.joined(separator: " ")
    }
    
    func convertToTokens(_ input: String) -> Int {
        let inputData = input.data(using: .utf8)!
        return inputData.count
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ConvertToByteView()
}
