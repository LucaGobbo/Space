//
//  HeroImage.swift
//  Space
//
//  Created by Luca Gobbo on 19/10/2026.
//

import SpaceDomain
import SwiftUI

public struct HeroImage: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    private var imageURL: URL?

    // MARK: - init
    public init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    // MARK: - Body
    public var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay {
                if let imageURL {
                    if #available(anyAppleOS 27.0, *) {
                        AsyncImage(
                            request: URLRequest(url: imageURL, cachePolicy: .returnCacheDataElseLoad)
                        ) { phase in
                            switch phase {
                            case .success(let image): image.resizable().scaledToFill()
                            case .empty: ProgressView()
                            default: Placeholder()
                            }
                        }
                    } else {
                        AsyncImage(
                            url: imageURL,
                            transaction: .init(animation: .smooth)
                        ) { phase in
                            switch phase {
                            case .success(let image): image.resizable().scaledToFill()
                            case .empty: ProgressView()
                            default: Placeholder()
                            }
                        }
                    }

                } else {
                    Placeholder()
                }
            }
            .clipShape(
                ConcentricRectangle(
                    corners: .concentric(minimum: .init(floatLiteral: Float(dimensions.spaceM)))
                )
            )
    }

    private struct Placeholder: View {
        var body: some View {
            Color.secondary.opacity(0.15)
                .overlay {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .accessibilityHidden(true)
        }
    }

}

// MARK: - Previews
@available(anyAppleOS, introduced: 27)
#Preview(arguments: Rocket.samples) { rocket in
    HeroImage(imageURL: rocket.imageURL)
        .padding()
}

#Preview("No image") {
    HeroImage(imageURL: nil)
        .padding()
}
