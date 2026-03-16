

import SwiftUI
import CoreLocation

struct CoordinatePathView: View {
    let coords: [CLLocationCoordinate2D]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                guard coords.count > 1 else { return }
                
                // 1) 경계값 계산
                let lats  = coords.map { $0.latitude }
                let lons  = coords.map { $0.longitude }
                guard let minLat = lats.min(),
                      let maxLat = lats.max(),
                      let minLon = lons.min(),
                      let maxLon = lons.max(),
                      minLat != maxLat,
                      minLon != maxLon else { return }

                let latSpan = maxLat - minLat
                let lonSpan = maxLon - minLon

                let inset: CGFloat = 8
                let drawRect = CGRect(x: inset,
                                      y: inset,
                                      width: max(0, size.width  - inset * 2),
                                      height: max(0, size.height - inset * 2))

                // 2) 경로 그리기
                var path = Path()
                for (index, coord) in coords.enumerated() {
                    let xNorm = (coord.longitude - minLon) / lonSpan
                    let yNorm = (coord.latitude  - minLat) / latSpan

                    let x = drawRect.minX + xNorm * drawRect.width
                    let y = drawRect.minY + (1 - yNorm) * drawRect.height

                    let point = CGPoint(x: x, y: y)

                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }

                context.stroke(path, with: .color(Color.white), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // 3) 출발점/도착점 표시
                if let start = coords.first {
                    let xNorm = (start.longitude - minLon) / lonSpan
                    let yNorm = (start.latitude - minLat) / latSpan
                    let x = drawRect.minX + xNorm * drawRect.width
                    let y = drawRect.minY + (1 - yNorm) * drawRect.height
                    let startRect = CGRect(x: x-5, y: y-5, width: 10, height: 10)
                    context.fill(Path(ellipseIn: startRect), with: .color(.white))
                }

                if let end = coords.last {
                    let xNorm = (end.longitude - minLon) / lonSpan
                    let yNorm = (end.latitude - minLat) / latSpan
                    let x = drawRect.minX + xNorm * drawRect.width
                    let y = drawRect.minY + (1 - yNorm) * drawRect.height
                    let endRect = CGRect(x: x-5, y: y-5, width: 10, height: 10)
                    context.fill(Path(ellipseIn: endRect), with: .color(.white))
                }
            }
        }
    }
}



struct CoordinatePathMockView: View {
    let sampleCoords: [CLLocationCoordinate2D] = [
        .init(latitude: 37.39609431430418, longitude: 127.11268484727265),
        .init(latitude: 37.39624116584835,   longitude: 127.10982784998536),
        .init(latitude: 37.39368230951782,   longitude: 127.10977894462356),
        .init(latitude: 37.39382371052619,   longitude: 127.11271532711427)
    ]
    
    var body: some View {
        CoordinatePathView(coords: sampleCoords)
            .padding()
    }
}

#Preview {
    CoordinatePathView(coords: [CLLocationCoordinate2DMake(37.39609490196374, 127.11267921410605)])
}
