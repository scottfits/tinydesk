//
//  Utilities.swift
//  OpenDesk
//
//  Created by Scott Fitsimones on 5/18/24.
//

import Foundation
import SwiftUI

func getImageBase64(image: NSImage) -> String {
    let tiffData = image.tiffRepresentation
    let bitmap = NSBitmapImageRep(data: tiffData!)
    let pngData = bitmap!.representation(using: .png, properties: [:])
    return pngData!.base64EncodedString(options: .lineLength64Characters)
}
