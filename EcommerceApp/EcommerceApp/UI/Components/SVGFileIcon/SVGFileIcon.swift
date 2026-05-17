import SwiftUI

struct SVGFileIcon: View {
    private let icon: SVGIconDefinition
    let size: CGFloat
    let tintColor: Color

    init(_ name: String, size: CGFloat = 24, tintColor: Color = .primary,
         colorMap: [String: Color] = [:]) {
        self.icon = SVGFileLoader.load(named: name, colorMap: colorMap)
        self.size = size
        self.tintColor = tintColor
    }

    var body: some View {
        SVGIcon(icon, size: size, tintColor: tintColor)
    }
}

final class SVGFileLoader: NSObject, XMLParserDelegate {

    private static var cache: [String: SVGIconDefinition] = [:]

    static func load(named name: String, colorMap: [String: Color] = [:]) -> SVGIconDefinition {
        if colorMap.isEmpty, let cached = cache[name] { return cached }

        guard let url = Bundle.main.url(forResource: name, withExtension: "svg"),
              let data = try? Data(contentsOf: url) else {
            return SVGIconDefinition(layers: [])   // empty — file not found
        }

        let loader = SVGFileLoader(colorMap: colorMap)
        let parser = XMLParser(data: data)
        parser.delegate = loader
        parser.parse()

        let def = SVGIconDefinition(viewBox: loader.viewBox, layers: loader.layers)
        if colorMap.isEmpty { cache[name] = def }
        return def
    }

    private let colorMap: [String: Color]
    private var viewBox = CGSize(width: 24, height: 24)
    private var layers: [SVGIconLayer] = []
    private var attrStack: [[String: String]] = [[:]]   // attribute inheritance for <g> groups
    private var insideDefs = false                       // skip <defs> content

    private init(colorMap: [String: Color]) { self.colorMap = colorMap }

    func parser(_ parser: XMLParser, didStartElement element: String,
                namespaceURI: String?, qualifiedName _: String?,
                attributes attrs: [String: String]) {
        let el = element.lowercased()

        if el == "defs" { insideDefs = true; return }
        if insideDefs { return }

        if el == "svg" {
            parseViewBox(attrs["viewBox"] ?? attrs["viewbox"])
            return
        }

        if el == "g" {
            var merged = attrStack.last ?? [:]
            for (k, v) in attrs { merged[k] = v }
            attrStack.append(merged)
            return
        }

        var eff = attrStack.last ?? [:]
        for (k, v) in attrs { eff[k] = v }

        let fill      = eff["fill"] ?? "currentColor"
        let fillRule  = eff["fill-rule"] ?? eff["fillRule"] ?? "nonzero"
        let opacity   = Double(eff["fill-opacity"] ?? eff["opacity"] ?? "1") ?? 1.0
        let evenOdd   = fillRule == "evenodd"
        let stroke    = eff["stroke"]
        let strokeW   = cgf(eff["stroke-width"] ?? "1")

        let resolvedFillColor: Color? = resolveColor(fill, opacity: opacity)
        let resolvedStrokeColor: Color? = stroke.flatMap { resolveColor($0, opacity: 1) }

        switch el {
        case "path":
            guard let d = eff["d"] else { break }
            if fill == "none" {
                if let sc = resolvedStrokeColor {
                    let raw = Path(svgPathData: d)
                    layers.append(SVGIconLayer(path: raw.strokedPath(.init(lineWidth: strokeW)), color: sc))
                }
            } else {
                layers.append(SVGIconLayer(pathData: d, color: resolvedFillColor, evenOddFill: evenOdd))
            }

        case "rect":
            layers.append(.rect(
                x: cgf(eff["x"]), y: cgf(eff["y"]),
                width: cgf(eff["width"]), height: cgf(eff["height"]),
                rx: cgf(eff["rx"]), ry: cgf(eff["ry"]),
                evenOddFill: evenOdd, color: resolvedFillColor
            ))

        case "circle":
            layers.append(.circle(
                cx: cgf(eff["cx"]), cy: cgf(eff["cy"]), r: cgf(eff["r"]),
                evenOddFill: evenOdd, color: resolvedFillColor
            ))

        case "ellipse":
            layers.append(.ellipse(
                cx: cgf(eff["cx"]), cy: cgf(eff["cy"]),
                rx: cgf(eff["rx"]), ry: cgf(eff["ry"]),
                evenOddFill: evenOdd, color: resolvedFillColor
            ))

        case "line":
            layers.append(.line(
                x1: cgf(eff["x1"]), y1: cgf(eff["y1"]),
                x2: cgf(eff["x2"]), y2: cgf(eff["y2"]),
                strokeWidth: strokeW, color: resolvedStrokeColor ?? resolvedFillColor
            ))

        case "polyline":
            let pts = parsePoints(eff["points"])
            if !pts.isEmpty {
                layers.append(.polyline(points: pts, strokeWidth: strokeW,
                                        color: resolvedStrokeColor ?? resolvedFillColor))
            }

        case "polygon":
            let pts = parsePoints(eff["points"])
            if !pts.isEmpty {
                layers.append(.polygon(points: pts, evenOddFill: evenOdd, color: resolvedFillColor))
            }

        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement element: String,
                namespaceURI: String?, qualifiedName _: String?) {
        switch element.lowercased() {
        case "defs": insideDefs = false
        case "g":    if attrStack.count > 1 { attrStack.removeLast() }
        default:     break
        }
    }

    private func resolveColor(_ svgValue: String, opacity: Double) -> Color? {
        if let override = colorMap[svgValue] { return opacity < 1 ? override.opacity(opacity) : override }
        if svgValue == "currentColor" || svgValue.isEmpty { return nil }   // nil → inherits tintColor
        if svgValue == "none" { return nil }
        guard let c = Color(svgHex: svgValue) ?? Color(svgRGB: svgValue) else { return nil }
        return opacity < 1 ? c.opacity(opacity) : c
    }

    private func parseViewBox(_ s: String?) {
        guard let s else { return }
        let parts = s.split { $0.isWhitespace || $0 == "," }.compactMap { Double($0) }
        if parts.count == 4 { viewBox = CGSize(width: parts[2], height: parts[3]) }
    }

    private func cgf(_ s: String?) -> CGFloat { CGFloat(Double(s ?? "0") ?? 0) }

    private func parsePoints(_ s: String?) -> [CGPoint] {
        guard let s else { return [] }
        let nums = s.split { $0.isWhitespace || $0 == "," }.compactMap { Double($0) }
        return stride(from: 0, to: nums.count - 1, by: 2).map { CGPoint(x: nums[$0], y: nums[$0 + 1]) }
    }
}

extension Color {
    init?(svgHex s: String) {
        var hex = s.hasPrefix("#") ? String(s.dropFirst()) : s
        if hex.count == 3 { hex = hex.flatMap { ["\($0)", "\($0)"] }.joined() }
        guard hex.count == 6, let rgb = UInt32(hex, radix: 16) else { return nil }
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }

    init?(svgRGB s: String) {
        guard s.hasPrefix("rgb") else { return nil }
        let nums = s.filter { $0.isNumber || $0 == "," || $0 == " " || $0 == "." }
            .split { $0 == "," || $0 == " " }
            .compactMap { Double($0) }
        guard nums.count >= 3 else { return nil }
        self.init(red: nums[0] / 255, green: nums[1] / 255, blue: nums[2] / 255)
    }
}
