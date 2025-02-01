import SwiftUI

struct OutlinedText: UIViewRepresentable {
    let text: String
    let fontName: String
    let fontSize: CGFloat
    let textColor: UIColor
    let strokeColor: UIColor
    let strokeWidth: CGFloat
    let textAlignment: NSTextAlignment
    let kern: CGFloat?  // New optional kerning parameter

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = textAlignment
        label.backgroundColor = .clear
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        guard let font = UIFont(name: fontName, size: fontSize) else {
            print("Error: Could not load font: \(fontName)")
            return
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .strokeColor: strokeColor,
            .strokeWidth: strokeWidth
        ]
        if let kern = kern {
            attributes[.kern] = kern
        }
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        uiView.attributedText = attributedString
    }
}
