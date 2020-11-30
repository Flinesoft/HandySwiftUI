import HandySwift
import SwiftUI

/// A Text with simple formatting support for bold & italic texts. Uses Markdown-like formatting.
/// E.g. use `FormattedText("This is **bold** text, this is _italic_ and this both _**bold and italic**_.")`
public struct FormattedText: View {
  private enum Format: CaseIterable {
    case boldAndItalic
    case bold
    case italic

    func apply(on text: Text) -> Text {
      switch self {
      case .boldAndItalic:
        return text.fontWeight(.bold).italic()

      case .bold:
        return text.fontWeight(.bold)

      case .italic:
        return text.italic()
      }
    }

    var regexes: [Regex] {
      switch self {
      case .boldAndItalic:
        return try! [
          Regex("\\*\\*\\*([^*]+)\\*\\*\\*"),
          Regex("___([^_]+)___"),
          Regex("_\\*\\*([^_*]+)\\*\\*_"),
          Regex("\\*\\*_([^_*]+)_\\*\\*"),
        ]

      case .bold:
        return try! [Regex("\\*\\*([^*]+)\\*\\*"), Regex("__([^_]+)__")]

      case .italic:
        return try! [Regex("\\*([^*]+)\\*"), Regex("_([^_]+)_")]
      }
    }

    var prefix: String {
      switch self {
      case .boldAndItalic:
        return "␂<bi>"

      case .bold:
        return "␂<b>"

      case .italic:
        return "␂<i>"
      }
    }

    var suffix: String {
      switch self {
      case .boldAndItalic:
        return "</bi>␃"

      case .bold:
        return "</b>␃"

      case .italic:
        return "</i>␃"
      }
    }

    var fallback: String {
      switch self {
      case .boldAndItalic:
        return "***"

      case .bold:
        return "**"

      case .italic:
        return "_"
      }
    }
  }

  let content: String

  public init(
    _ content: String
  ) {
    self.content = content
  }

  public var body: Text {
    textViews().reduce(Text("")) { $0 + $1 }
  }

  private func textViews() -> [Text] {
    let separator: Character = "¦"
    var markedContent: String = content

    for format in Format.allCases {
      for regex in format.regexes {
        markedContent = regex.replacingMatches(
          in: markedContent,
          with: "\(separator)\(format.prefix)$1\(format.suffix)\(separator)"
        )
      }
    }

    return markedContent.split(separator: separator)
      .map { substring in
        for format in Format.allCases {
          if substring.hasPrefix(format.prefix) && substring.hasSuffix(format.suffix) {
            let text = Text(substring.dropFirst(format.prefix.count).dropLast(format.suffix.count))
            return format.apply(on: text)
          }
        }
        return Text(substring)
      }
  }
}

struct FormattedText_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      FormattedText("Normal **bold** normal __bold, bold__, normal _italic_ and *italic, italic*.")
        .background(Color.yellow)
        .font(.title)
      Spacer()
      FormattedText(
        "***Bold and italic*** also ___bold and italic___ just as _**bold and italic**_ and even another _**bold and italic**_."
      )
      .background(Color.yellow)
      .font(.subheadline)
      Spacer()
      FormattedText("_Whole italic text with **bold substring** in the middle or **end.**_")
        .background(Color.yellow)
        .font(.body)
      Spacer()
    }
    .padding()
  }
}