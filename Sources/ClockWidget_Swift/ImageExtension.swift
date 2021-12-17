//
//  View+Image.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/22.
//

import Foundation
import SwiftUI

extension NSImage {
    /// <#Description#>
    /// - Returns: a base64 string convert from a NSImage
    func base64String() -> String? {
        let cgImgRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let bmpImgRef = NSBitmapImageRep(cgImage: cgImgRef!)
        guard
            let data = bmpImgRef.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey.compressionFactor:1.0])
        
        else {
            return nil
        }

        return "data:image/png;base64,\(data.base64EncodedString())"
    }
}

extension String {
    /// <#Description#>
    /// - Returns: a NSImage convert from a base64 string
    func convertBase64StringToImage () -> NSImage {
        let imageData = Data.init(base64Encoded: self, options: .init(rawValue: 0))
        let image = NSImage(data: imageData!)
        return image!
    }
}

extension NSImage {
    /// <#Description#>
    /// - Parameter text: time text
    /// - Returns: time image
    func addTextToImage(drawText text: String) -> NSImage {

        let targetImage = NSImage(size: self.size, flipped: false) { (dstRect: CGRect) -> Bool in

            self.draw(in: dstRect)
            let textColor = NSColor.black
            let textFont = NSFont(name: "Arial Rounded MT Bold", size: 60)! //Helvetica Bold
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center

            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor
                ] as [NSAttributedString.Key : Any]

            let textOrigin = CGPoint(x: 25, y: -15)
            let rect = CGRect(origin: textOrigin, size: self.size)
            text.draw(in: rect, withAttributes: textFontAttributes)
            return true
        }
        return targetImage
    }
}

extension View {
    /// <#Description#>
    /// - Returns: view convert to a image
    func renderAsImage() -> NSImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        return view.bitmapImage()
    }
}

class NoInsetHostingView<V>: NSHostingView<V> where V: View {
    override var safeAreaInsets: NSEdgeInsets {
        return .init()
    }
}

public extension NSView {
    func bitmapImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        guard let cgImage = rep.cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
}
