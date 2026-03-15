import AppKit

let path = CommandLine.arguments[1]
guard let img = NSImage(contentsOfFile: path),
      let rep = img.representations.first as? NSBitmapImageRep else { exit(1) }

let w = rep.pixelsWide, h = rep.pixelsHigh

// Detect background from bottom-right corner (works for white or dark bg)
let bgc = rep.colorAt(x: w-1, y: h-1)!
let bgR = Int(bgc.redComponent * 255)
let bgG = Int(bgc.greenComponent * 255)
let bgB = Int(bgc.blueComponent * 255)

func isBg(_ x: Int, _ y: Int) -> Bool {
    let c = rep.colorAt(x: x, y: y)!
    return abs(Int(c.redComponent * 255) - bgR) <= 8
        && abs(Int(c.greenComponent * 255) - bgG) <= 8
        && abs(Int(c.blueComponent * 255) - bgB) <= 8
}

// Find top content edge (scan from top down)
var contentTop = 0
scanTop: for y in 0..<h {
    for x in stride(from: 0, to: w, by: 4) {
        if !isBg(x, y) { contentTop = y; break scanTop }
    }
}

// Find bottom content edge (scan from bottom up)
var contentBottom = h - 1
scanBottom: for y in stride(from: h-1, through: 0, by: -1) {
    for x in stride(from: 0, to: w, by: 4) {
        if !isBg(x, y) { contentBottom = y; break scanBottom }
    }
}

// Find right content edge (scan from right to left)
var contentRight = 0
scanRight: for x in stride(from: w-1, through: 0, by: -1) {
    for y in stride(from: contentTop, to: min(contentBottom+1, h), by: 4) {
        if !isBg(x, y) { contentRight = x; break scanRight }
    }
}

// Crop with padding: 40px top, 80px bottom, 60px right
let pad = (top: 40, bottom: 80, right: 60)
let cropY = max(0, contentTop - pad.top)
let cropW = min(w, contentRight + pad.right)
let cropH = min(h - cropY, contentBottom - cropY + pad.bottom)
let cropRect = NSRect(x: 0, y: cropY, width: cropW, height: cropH)
guard let cgImg = rep.cgImage?.cropping(to: cropRect) else { exit(1) }
let outRep = NSBitmapImageRep(cgImage: cgImg)
guard let png = outRep.representation(using: .png, properties: [:]) else { exit(1) }
try! png.write(to: URL(fileURLWithPath: path))
