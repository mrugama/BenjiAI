import SwiftUI
import MarkdownUI

struct MarkdownA: View {
    var output = """
    ## This is a title
    You can tell a `Markdown` view to load images using a 3rd party library
    by configuring an `ImageProvider`. This example uses
    [**SDWebImage/SDWebImageSwiftUI**](https://github.com/SDWebImage/SDWebImageSwiftUI)
    to enable animated GIF rendering.

    ![](https://t3.ftcdn.net/jpg/02/36/99/22/360_F_236992283_sNOxCVQeFLd5pdqaKGh8DRGMZy7P4XKm.jpg)

    This is more text after the image.

    ## This is a Swift section
    ``` swift
    import SwiftUI

    struct MyView: View {
        var body: some View {
            Text('Hello, World!')
        }
    }
    ```
    """
    var body: some View {
        ScrollView {
            Markdown {
                output
            }
            .padding()
        }
    }
}

#Preview {
    MarkdownA()
}
