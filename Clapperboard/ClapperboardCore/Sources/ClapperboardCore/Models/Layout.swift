//
//  Layout.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 14/07/2026.
//

import Foundation

public struct Layout {
    public let isLandscape: Bool
    public let scale: CGFloat
    public let stripeHeight: CGFloat
    public let infoHeight: CGFloat
    public let overlayHeight: CGFloat
    public let verticalOffset: CGFloat
    public let sideInset: CGFloat
    public let overlayWidth: CGFloat
    public let titleFontSize: CGFloat
    public let bodyFontSize: CGFloat
    public let labelFontSize: CGFloat
    public let padding: CGFloat
    public let lineSpacing: CGFloat

    public init(size: CGSize) {
        isLandscape  = size.width > size.height
        scale        = (isLandscape ? size.height : size.width) / 1080.0
        stripeHeight = 80.0 * scale
        infoHeight   = isLandscape ? size.height * 0.45 : 400.0 * scale
        overlayHeight = stripeHeight + infoHeight
        verticalOffset = (size.height - overlayHeight) / 2
        sideInset    = size.width * 0.05
        overlayWidth = size.width - sideInset * 2
        titleFontSize = (isLandscape ? 60.0 : 90.0) * scale
        bodyFontSize  = (isLandscape ? 40.0 : 58.0) * scale
        labelFontSize = bodyFontSize * 0.65
        padding       = (isLandscape ? 18.0 : 28.0) * scale
        lineSpacing   = (isLandscape ? 6.0 : 10.0) * scale
    }
}

