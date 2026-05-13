//
//  ClapperboardRenderer.swift
//  PhotoExtension
//
//  Created by Aidan Bennett on 13/05/2026.
//

import Foundation
import UIKit
import Sentry

/// Responsible solely for drawing the clapperboard overlay `CGImage`.
/// Has no knowledge of AVFoundation or Photos – pure UIKit/CoreGraphics.
struct ClapperboardRenderer {

    let configuration: ClapperboardConfiguration

    // MARK: - Public

    func render(size: CGSize) async -> CGImage {
        await withCheckedContinuation { continuation in
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                draw(in: context.cgContext, size: size)
            }

            guard let cgImage = image.cgImage else {
                SentrySDK.capture(error: VideoProcessingError.clapperboardRenderFailed)
                let fallback = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                    .image { _ in }
                continuation.resume(returning: fallback.cgImage!)
                return
            }
            continuation.resume(returning: cgImage)
        }
    }

    // MARK: - Layout helpers

    private struct Layout {
        let isLandscape: Bool
        let scale: CGFloat
        let stripeHeight: CGFloat
        let infoHeight: CGFloat
        let overlayHeight: CGFloat
        let verticalOffset: CGFloat
        let sideInset: CGFloat
        let overlayWidth: CGFloat
        let titleFontSize: CGFloat
        let bodyFontSize: CGFloat
        let labelFontSize: CGFloat
        let padding: CGFloat
        let lineSpacing: CGFloat

        init(size: CGSize) {
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

    // MARK: - Drawing

    private func draw(in ctx: CGContext, size: CGSize) {
        let layout = Layout(size: size)

        drawBackground(ctx, layout: layout)
        drawGradientOverlay(ctx, layout: layout, totalHeight: size.height)
        drawStripes(ctx, layout: layout)
        drawSeparator(ctx, layout: layout)
        drawTextContent(ctx, size: size, layout: layout)
    }

    private func drawBackground(_ ctx: CGContext, layout: Layout) {
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.45).cgColor)
        ctx.fill(CGRect(
            x: layout.sideInset,
            y: layout.verticalOffset,
            width: layout.overlayWidth,
            height: layout.overlayHeight
        ))
    }

    private func drawGradientOverlay(_ ctx: CGContext, layout: Layout, totalHeight: CGFloat) {
        let colors = [
            UIColor.white.withAlphaComponent(0.08).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor
        ] as CFArray

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: [0.0, 1.0]
        ) else { return }

        ctx.saveGState()
        ctx.clip(to: CGRect(
            x: layout.sideInset,
            y: layout.verticalOffset,
            width: layout.overlayWidth,
            height: layout.overlayHeight
        ))
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: layout.verticalOffset),
            end: CGPoint(x: 0, y: layout.verticalOffset + layout.overlayHeight),
            options: []
        )
        ctx.restoreGState()
    }

    private func drawStripes(_ ctx: CGContext, layout: Layout) {
        let stripeWidth = layout.overlayWidth / 10
        for i in 0..<10 {
            let color = i % 2 == 0 ? UIColor.white : UIColor.black
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(
                x: layout.sideInset + CGFloat(i) * stripeWidth,
                y: layout.verticalOffset,
                width: stripeWidth,
                height: layout.stripeHeight
            ))
        }
    }

    private func drawSeparator(_ ctx: CGContext, layout: Layout) {
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
        ctx.setLineWidth(1.5 * layout.scale)
        let y = layout.verticalOffset + layout.stripeHeight
        ctx.move(to: CGPoint(x: layout.sideInset, y: y))
        ctx.addLine(to: CGPoint(x: layout.sideInset + layout.overlayWidth, y: y))
        ctx.strokePath()
    }

    private func drawTextContent(_ ctx: CGContext, size: CGSize, layout: Layout) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: layout.titleFontSize),
            .foregroundColor: UIColor.white.withAlphaComponent(0.85)
        ]
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: layout.bodyFontSize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.75)
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: layout.labelFontSize, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.45)
        ]

        let centerX = size.width / 2
        var yPos = layout.verticalOffset + layout.stripeHeight + layout.padding

        // Title block
        drawCentred("TITLE", attributes: labelAttrs, centerX: centerX, y: yPos)
        yPos += layout.labelFontSize + 6 * layout.scale

        drawCentred(configuration.title.uppercased(), attributes: titleAttrs, centerX: centerX, y: yPos)
        yPos += layout.titleFontSize + layout.lineSpacing * 2

        // Horizontal rule
        drawHorizontalRule(ctx, size: size, y: yPos, scale: layout.scale)
        yPos += layout.lineSpacing * 1.5

        // Metadata columns
        drawMetadataRow(
            bodyAttrs: bodyAttrs,
            labelAttrs: labelAttrs,
            layout: layout,
            yPos: yPos
        )
    }

    private func drawHorizontalRule(_ ctx: CGContext, size: CGSize, y: CGFloat, scale: CGFloat) {
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.15).cgColor)
        ctx.setLineWidth(1.0 * scale)
        let inset = size.width * 0.1
        ctx.move(to: CGPoint(x: inset, y: y))
        ctx.addLine(to: CGPoint(x: size.width - inset, y: y))
        ctx.strokePath()
    }

    private func drawMetadataRow(
        bodyAttrs: [NSAttributedString.Key: Any],
        labelAttrs: [NSAttributedString.Key: Any],
        layout: Layout,
        yPos: CGFloat
    ) {
        let items: [(label: String, value: String)] = [
            ("DIRECTOR", configuration.director.uppercased()),
            ("SCENE",    configuration.scene),
            ("TAKE",     configuration.take),
            ("DATE",     configuration.date)
        ]

        let columnWidth = layout.overlayWidth / CGFloat(items.count)

        for (index, item) in items.enumerated() {
            let colCenterX = layout.sideInset + columnWidth * CGFloat(index) + columnWidth / 2
            drawCentred(item.label, attributes: labelAttrs, centerX: colCenterX, y: yPos)
            drawCentred(item.value, attributes: bodyAttrs, centerX: colCenterX, y: yPos + layout.labelFontSize + 4 * layout.scale)
        }
    }

    // MARK: - Utility

    private func drawCentred(
        _ string: String,
        attributes: [NSAttributedString.Key: Any],
        centerX: CGFloat,
        y: CGFloat
    ) {
        let nsString = string as NSString
        let textSize = nsString.size(withAttributes: attributes)
        nsString.draw(at: CGPoint(x: centerX - textSize.width / 2, y: y), withAttributes: attributes)
    }
}
