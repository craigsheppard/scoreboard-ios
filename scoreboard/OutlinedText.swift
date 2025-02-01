import SwiftUI

struct OutlinedText: UIViewRepresentable {
    let text: String
    let fontName: String
    let fontSize: CGFloat
    let textColor: UIColor
    let strokeColor: UIColor
    /// A negative stroke width means the text is drawn with fill and stroke.
    let strokeWidth: CGFloat
    let textAlignment: NSTextAlignment

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = textAlignment
        label.backgroundColor = .clear
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        // Create a UIFont instance with your custom font.
        guard let font = UIFont(name: fontName, size: fontSize) else {
            print("Error: Could not load font: \(fontName)")
            return
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .strokeColor: strokeColor,
            .strokeWidth: strokeWidth  // e.g. -4.0 for fill + stroke
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        uiView.attributedText = attributedString
    }
}