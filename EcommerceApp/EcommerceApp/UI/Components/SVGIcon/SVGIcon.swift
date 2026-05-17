import SwiftUI

struct SVGIconLayer {
    let path: Path
    let color: Color?
    let fillStyle: FillStyle

    init(pathData: String, color: Color? = nil, evenOddFill: Bool = false) {
        self.path = Path(svgPathData: pathData)
        self.color = color
        self.fillStyle = FillStyle(eoFill: evenOddFill)
    }

    init(path: Path, color: Color? = nil, evenOddFill: Bool = false) {
        self.path = path
        self.color = color
        self.fillStyle = FillStyle(eoFill: evenOddFill)
    }

    static func rect(
        x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat,
        rx: CGFloat = 0, ry: CGFloat = 0,
        evenOddFill: Bool = false, color: Color? = nil
    ) -> SVGIconLayer {
        let r = rx > 0 ? rx : ry
        return SVGIconLayer(
            path: Path(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: r),
            color: color, evenOddFill: evenOddFill
        )
    }

    static func circle(cx: CGFloat, cy: CGFloat, r: CGFloat,
                       evenOddFill: Bool = false, color: Color? = nil) -> SVGIconLayer {
        SVGIconLayer(
            path: Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
            color: color, evenOddFill: evenOddFill
        )
    }

    static func ellipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat,
                        evenOddFill: Bool = false, color: Color? = nil) -> SVGIconLayer {
        SVGIconLayer(
            path: Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2)),
            color: color, evenOddFill: evenOddFill
        )
    }

    static func line(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat,
                     strokeWidth: CGFloat = 1, color: Color? = nil) -> SVGIconLayer {
        var p = Path()
        p.move(to: CGPoint(x: x1, y: y1))
        p.addLine(to: CGPoint(x: x2, y: y2))
        return SVGIconLayer(path: p.strokedPath(.init(lineWidth: strokeWidth)), color: color)
    }

    static func polyline(points: [CGPoint], strokeWidth: CGFloat = 1, color: Color? = nil) -> SVGIconLayer {
        var p = Path()
        guard let first = points.first else { return SVGIconLayer(path: p, color: color) }
        p.move(to: first)
        points.dropFirst().forEach { p.addLine(to: $0) }
        return SVGIconLayer(path: p.strokedPath(.init(lineWidth: strokeWidth)), color: color)
    }

    static func polygon(points: [CGPoint], evenOddFill: Bool = false, color: Color? = nil) -> SVGIconLayer {
        var p = Path()
        guard let first = points.first else { return SVGIconLayer(path: p, color: color) }
        p.move(to: first)
        points.dropFirst().forEach { p.addLine(to: $0) }
        p.closeSubpath()
        return SVGIconLayer(path: p, color: color, evenOddFill: evenOddFill)
    }
}

struct SVGIconDefinition {
    let viewBox: CGSize
    let layers: [SVGIconLayer]

    init(viewBox: CGSize = CGSize(width: 24, height: 24), layers: [SVGIconLayer]) {
        self.viewBox = viewBox
        self.layers = layers
    }
}


struct SVGIcon: View {
    let icon: SVGIconDefinition
    let size: CGFloat
    let tintColor: Color

    init(_ icon: SVGIconDefinition, size: CGFloat = 24, tintColor: Color = .primary) {
        self.icon = icon
        self.size = size
        self.tintColor = tintColor
    }

    var body: some View {
        Canvas { ctx, canvasSize in
            let scale = min(
                canvasSize.width / icon.viewBox.width,
                canvasSize.height / icon.viewBox.height
            )
            let tx = (canvasSize.width - icon.viewBox.width * scale) / 2
            let ty = (canvasSize.height - icon.viewBox.height * scale) / 2
            let transform = CGAffineTransform(translationX: tx, y: ty)
                .scaledBy(x: scale, y: scale)

            for layer in icon.layers {
                let scaledPath = layer.path.applying(transform)
                ctx.fill(scaledPath, with: .color(layer.color ?? tintColor), style: layer.fillStyle)
            }
        }
        .frame(width: size, height: size)
    }
}


extension Path {
    init(svgPathData string: String) {
        self.init()
        var parser = SVGPathParser(string: string)
        parser.apply(to: &self)
    }
}

private struct SVGPathParser {
    private let chars: [Character]
    private var i = 0
    private var cx: Double = 0
    private var cy: Double = 0
    private var subpathStartX: Double = 0
    private var subpathStartY: Double = 0
    private var lastCtrlX: Double = 0
    private var lastCtrlY: Double = 0
    private var lastCmd: Character = " "

    init(string: String) { chars = Array(string) }

    mutating func apply(to path: inout Path) {
        while i < chars.count {
            skipSeparators()
            guard i < chars.count, chars[i].isLetter else { break }
            let cmd = chars[i]; i += 1
            processCommand(cmd, into: &path)
        }
    }

    mutating private func processCommand(_ cmd: Character, into path: inout Path) {
        let rel = cmd.isLowercase
        let up = Character(cmd.uppercased())
        lastCmd = up

        switch up {
        case "M":
            let x = num(); let y = num()
            cx = rel ? cx + x : x; cy = rel ? cy + y : y
            path.move(to: pt(cx, cy))
            subpathStartX = cx; subpathStartY = cy
            while hasNum() {
                let lx = num(); let ly = num()
                cx = rel ? cx + lx : lx; cy = rel ? cy + ly : ly
                path.addLine(to: pt(cx, cy))
                lastCmd = "L"
            }

        case "L":
            repeat {
                let x = num(); let y = num()
                cx = rel ? cx + x : x; cy = rel ? cy + y : y
                path.addLine(to: pt(cx, cy))
            } while hasNum()

        case "H":
            repeat {
                let x = num()
                cx = rel ? cx + x : x
                path.addLine(to: pt(cx, cy))
            } while hasNum()

        case "V":
            repeat {
                let y = num()
                cy = rel ? cy + y : y
                path.addLine(to: pt(cx, cy))
            } while hasNum()

        case "C":
            repeat {
                let c1x = num(); let c1y = num()
                let c2x = num(); let c2y = num()
                let ex  = num(); let ey  = num()
                let ac1x = rel ? cx + c1x : c1x; let ac1y = rel ? cy + c1y : c1y
                let ac2x = rel ? cx + c2x : c2x; let ac2y = rel ? cy + c2y : c2y
                let aex  = rel ? cx + ex  : ex;  let aey  = rel ? cy + ey  : ey
                path.addCurve(to: pt(aex, aey), control1: pt(ac1x, ac1y), control2: pt(ac2x, ac2y))
                lastCtrlX = ac2x; lastCtrlY = ac2y; cx = aex; cy = aey
            } while hasNum()

        case "S":
            repeat {
                let c2x = num(); let c2y = num()
                let ex  = num(); let ey  = num()
                let ac2x = rel ? cx + c2x : c2x; let ac2y = rel ? cy + c2y : c2y
                let aex  = rel ? cx + ex  : ex;  let aey  = rel ? cy + ey  : ey
                let ac1x = (lastCmd == "C" || lastCmd == "S") ? 2 * cx - lastCtrlX : cx
                let ac1y = (lastCmd == "C" || lastCmd == "S") ? 2 * cy - lastCtrlY : cy
                path.addCurve(to: pt(aex, aey), control1: pt(ac1x, ac1y), control2: pt(ac2x, ac2y))
                lastCtrlX = ac2x; lastCtrlY = ac2y; cx = aex; cy = aey
            } while hasNum()

        case "Q":
            repeat {
                let qcx = num(); let qcy = num()
                let ex  = num(); let ey  = num()
                let acx = rel ? cx + qcx : qcx; let acy = rel ? cy + qcy : qcy
                let aex = rel ? cx + ex  : ex;  let aey = rel ? cy + ey  : ey
                path.addQuadCurve(to: pt(aex, aey), control: pt(acx, acy))
                lastCtrlX = acx; lastCtrlY = acy; cx = aex; cy = aey
            } while hasNum()

        case "T":
            repeat {
                let ex = num(); let ey = num()
                let aex = rel ? cx + ex : ex; let aey = rel ? cy + ey : ey
                let acx = (lastCmd == "Q" || lastCmd == "T") ? 2 * cx - lastCtrlX : cx
                let acy = (lastCmd == "Q" || lastCmd == "T") ? 2 * cy - lastCtrlY : cy
                path.addQuadCurve(to: pt(aex, aey), control: pt(acx, acy))
                lastCtrlX = acx; lastCtrlY = acy; cx = aex; cy = aey
            } while hasNum()

        case "A":
            repeat {
                let rx = num(); let ry = num(); let xRot = num()
                let la = flag(); let sw = flag()
                let ex = num(); let ey = num()
                let aex = rel ? cx + ex : ex; let aey = rel ? cy + ey : ey
                arcToBezier(into: &path, x1: cx, y1: cy, x2: aex, y2: aey,
                            rx: rx, ry: ry, xRot: xRot, largeArc: la, sweep: sw)
                cx = aex; cy = aey
            } while hasNum()

        case "Z":
            path.closeSubpath()
            cx = subpathStartX; cy = subpathStartY

        default: break
        }
    }

    mutating private func skipSeparators() {
        while i < chars.count && (chars[i].isWhitespace || chars[i] == ",") { i += 1 }
    }

    mutating private func num() -> Double {
        skipSeparators()
        var s = ""
        if i < chars.count && (chars[i] == "+" || chars[i] == "-") { s.append(chars[i]); i += 1 }
        var hasDot = false
        while i < chars.count {
            let c = chars[i]
            if c.isNumber { s.append(c); i += 1 }
            else if c == "." && !hasDot { hasDot = true; s.append(c); i += 1 }
            else if (c == "e" || c == "E") && !s.isEmpty {
                s.append(c); i += 1
                if i < chars.count && (chars[i] == "+" || chars[i] == "-") { s.append(chars[i]); i += 1 }
                while i < chars.count && chars[i].isNumber { s.append(chars[i]); i += 1 }
                break
            } else { break }
        }
        return Double(s) ?? 0
    }

    mutating private func flag() -> Bool {
        skipSeparators()
        guard i < chars.count else { return false }
        let f = chars[i]; i += 1; return f == "1"
    }

    private func hasNum() -> Bool {
        var j = i
        while j < chars.count && (chars[j].isWhitespace || chars[j] == ",") { j += 1 }
        guard j < chars.count else { return false }
        let c = chars[j]
        if c.isNumber || c == "." { return true }
        if (c == "+" || c == "-") && j + 1 < chars.count && (chars[j + 1].isNumber || chars[j + 1] == ".") { return true }
        return false
    }

    private func pt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x, y: y) }

    private func arcToBezier(into path: inout Path,
                              x1: Double, y1: Double, x2: Double, y2: Double,
                              rx: Double, ry: Double, xRot: Double,
                              largeArc: Bool, sweep: Bool) {
        guard rx > 0, ry > 0, !(x1 == x2 && y1 == y2) else {
            path.addLine(to: CGPoint(x: x2, y: y2)); return
        }
        let phi = xRot * .pi / 180
        let cosPhi = cos(phi), sinPhi = sin(phi)
        let dx = (x1 - x2) / 2, dy = (y1 - y2) / 2
        let x1p =  cosPhi * dx + sinPhi * dy
        let y1p = -sinPhi * dx + cosPhi * dy

        var rxA = abs(rx), ryA = abs(ry)
        let x1p2 = x1p * x1p, y1p2 = y1p * y1p
        let lambda = x1p2 / (rxA * rxA) + y1p2 / (ryA * ryA)
        if lambda > 1 { let s = sqrt(lambda); rxA *= s; ryA *= s }

        let rx2 = rxA * rxA, ry2 = ryA * ryA
        let num = max(0, rx2 * ry2 - rx2 * y1p2 - ry2 * x1p2)
        let den = rx2 * y1p2 + ry2 * x1p2
        let sq = sqrt(num / max(den, 1e-10)) * (largeArc == sweep ? -1 : 1)
        let cxp =  sq * rxA * y1p / ryA
        let cyp = -sq * ryA * x1p / rxA
        let cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2

        let startAngle = svgAngle(ux: 1, uy: 0, vx: (x1p - cxp) / rxA, vy: (y1p - cyp) / ryA)
        var dAngle   = svgAngle(ux: (x1p - cxp) / rxA, uy: (y1p - cyp) / ryA,
                                vx: (-x1p - cxp) / rxA, vy: (-y1p - cyp) / ryA)
        if !sweep && dAngle > 0 { dAngle -= 2 * .pi }
        else if sweep && dAngle < 0 { dAngle += 2 * .pi }

        let segs = max(1, Int(ceil(abs(dAngle) / (.pi / 2))))
        let segA = dAngle / Double(segs)
        for k in 0..<segs {
            arcSegment(into: &path, cx: cx, cy: cy, rx: rxA, ry: ryA,
                       phi: phi, t1: startAngle + Double(k) * segA, t2: startAngle + Double(k + 1) * segA)
        }
    }

    private func svgAngle(ux: Double, uy: Double, vx: Double, vy: Double) -> Double {
        let dot = ux * vx + uy * vy
        let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
        let a = acos(max(-1, min(1, dot / max(len, 1e-10))))
        return (ux * vy - uy * vx < 0) ? -a : a
    }

    private func arcSegment(into path: inout Path,
                             cx: Double, cy: Double, rx: Double, ry: Double,
                             phi: Double, t1: Double, t2: Double) {
        let alpha = sin(t2 - t1) * (sqrt(4 + 3 * pow(tan((t2 - t1) / 2), 2)) - 1) / 3
        let cosPhi = cos(phi), sinPhi = sin(phi)
        let c1 = cos(t1), s1 = sin(t1), c2 = cos(t2), s2 = sin(t2)

        let px1 = cx + cosPhi * rx * c1 - sinPhi * ry * s1
        let py1 = cy + sinPhi * rx * c1 + cosPhi * ry * s1
        let dx1 = -cosPhi * rx * s1 - sinPhi * ry * c1
        let dy1 = -sinPhi * rx * s1 + cosPhi * ry * c1

        let px2 = cx + cosPhi * rx * c2 - sinPhi * ry * s2
        let py2 = cy + sinPhi * rx * c2 + cosPhi * ry * s2
        let dx2 = -cosPhi * rx * s2 - sinPhi * ry * c2
        let dy2 = -sinPhi * rx * s2 + cosPhi * ry * c2

        path.addCurve(
            to:       CGPoint(x: px2, y: py2),
            control1: CGPoint(x: px1 + alpha * dx1, y: py1 + alpha * dy1),
            control2: CGPoint(x: px2 - alpha * dx2, y: py2 - alpha * dy2)
        )
    }
}
