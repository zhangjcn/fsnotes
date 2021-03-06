//
//  NSTextStorage+.swift
//  FSNotesCore macOS
//
//  Created by Oleksandr Glushchenko on 7/20/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Foundation

import Cocoa

extension NSTextStorage {
    public func updateFont() {
        beginEditing()
        enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let font = value as? NSFont, let familyName = UserDefaultsManagement.noteFont.familyName {
                let newFontDescriptor = font.fontDescriptor
                    .withFamily(familyName)
                    .withSymbolicTraits(font.fontDescriptor.symbolicTraits)

                if let newFont = NSFont(descriptor: newFontDescriptor, size: CGFloat(UserDefaultsManagement.fontSize)) {
                    removeAttribute(.font, range: range)
                    addAttribute(.font, value: newFont, range: range)
                    fixAttributes(in: range)
                }
            }
        }
        endEditing()
    }

    public func updateParagraphStyle() {
        beginEditing()

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = CGFloat(UserDefaultsManagement.editorLineSpacing)

        let attachmentParagraph = NSMutableParagraphStyle()
        attachmentParagraph.lineSpacing = CGFloat(UserDefaultsManagement.editorLineSpacing)
        attachmentParagraph.alignment = .center

        addAttribute(.paragraphStyle, value: paragraph, range: NSRange(0..<length))

        enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in

            if value as? NSTextAttachment != nil,
                self.attribute(.todo, at: range.location, effectiveRange: nil) == nil {
                addAttribute(.paragraphStyle, value: attachmentParagraph, range: range)
            }
        }

        endEditing()
    }

    public func sizeAttachmentImages() {
        enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment,
                attribute(.todo, at: range.location, effectiveRange: nil) == nil {

                if let imageData = attachment.fileWrapper?.regularFileContents, var image = NSImage(data: imageData) {
                    if let rep = image.representations.first {
                        image = image.resize(to: CGSize(width: rep.pixelsWide, height: rep.pixelsHigh))!

                        let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
                        let cell = NSTextAttachmentCell(imageCell: NSImage(size: size))
                        cell.image = image
                        attachment.attachmentCell = cell

                        addAttribute(.link, value: String(), range: range)
                    }
                }
            }
        }
    }
}
