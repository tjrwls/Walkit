import CoreLocation
import Foundation

enum CoordinatePathSmoother {
    struct LocationSample {
        let coordinate: CLLocationCoordinate2D
        let timestampMillis: Int?
        let accuracyMeters: Double?
    }

    static func smoothPath(
        _ coordinates: [CLLocationCoordinate2D],
        simplifyToleranceMeters: Double = 5.0,
        interpolationSegments: Int = 8
    ) -> [CLLocationCoordinate2D] {
        let samples = coordinates.map {
            LocationSample(
                coordinate: $0,
                timestampMillis: nil,
                accuracyMeters: nil
            )
        }

        return smoothPath(
            samples,
            simplifyToleranceMeters: simplifyToleranceMeters,
            interpolationSegments: interpolationSegments
        )
    }

    static func smoothPath(
        _ samples: [LocationSample],
        simplifyToleranceMeters: Double = 5.0,
        interpolationSegments: Int = 8,
        maxAccuracyMeters: Double = 50.0,
        maxSpeedMetersPerSecond: Double = 30.0,
        processNoise: Double = 3.0
    ) -> [CLLocationCoordinate2D] {
        let validSamples = samples.filter { CLLocationCoordinate2DIsValid($0.coordinate) }
        guard validSamples.count >= 2 else { return validSamples.map(\.coordinate) }

        let accuracyFiltered = applyAccuracyFilter(
            to: validSamples,
            maxAccuracyMeters: maxAccuracyMeters
        )
        guard accuracyFiltered.count >= 2 else { return accuracyFiltered.map(\.coordinate) }

        let kalmanFiltered = applyKalmanFilter(
            to: accuracyFiltered,
            processNoise: processNoise
        )
        guard kalmanFiltered.count >= 2 else { return kalmanFiltered.map(\.coordinate) }

        let speedFiltered = applySpeedFilter(
            to: kalmanFiltered,
            maxSpeedMetersPerSecond: maxSpeedMetersPerSecond
        )
        guard speedFiltered.count >= 3 else { return speedFiltered.map(\.coordinate) }

        let validCoordinates = speedFiltered.map(\.coordinate)

        let normalizedCoordinates = normalizeLongitudes(validCoordinates)
        let simplifiedCoordinates = douglasPeucker(
            normalizedCoordinates,
            epsilonMeters: simplifyToleranceMeters
        )

        guard simplifiedCoordinates.count >= 3 else {
            return denormalizeLongitudes(
                simplifiedCoordinates,
                referenceLongitude: validCoordinates[0].longitude
            )
        }

        let interpolatedCoordinates = catmullRomInterpolate(
            simplifiedCoordinates,
            segments: interpolationSegments
        )

        return denormalizeLongitudes(
            interpolatedCoordinates,
            referenceLongitude: validCoordinates[0].longitude
        )
    }

    private static func applyAccuracyFilter(
        to samples: [LocationSample],
        maxAccuracyMeters: Double
    ) -> [LocationSample] {
        samples.filter { sample in
            guard let accuracyMeters = sample.accuracyMeters else { return true }
            return accuracyMeters > 0 && accuracyMeters <= maxAccuracyMeters
        }
    }

    private static func applyKalmanFilter(
        to samples: [LocationSample],
        processNoise: Double
    ) -> [LocationSample] {
        guard let first = samples.first else { return [] }

        var filteredSamples: [LocationSample] = [first]
        var estimatedLatitude = first.coordinate.latitude
        var estimatedLongitude = first.coordinate.longitude
        var latitudeVariance = max(pow(first.accuracyMeters ?? processNoise, 2), 1)
        var longitudeVariance = latitudeVariance

        for sample in samples.dropFirst() {
            latitudeVariance += processNoise
            longitudeVariance += processNoise

            let measurementNoise = max(pow(sample.accuracyMeters ?? processNoise, 2), 1)
            let latitudeGain = latitudeVariance / (latitudeVariance + measurementNoise)
            let longitudeGain = longitudeVariance / (longitudeVariance + measurementNoise)

            estimatedLatitude += latitudeGain * (sample.coordinate.latitude - estimatedLatitude)
            estimatedLongitude += longitudeGain * (sample.coordinate.longitude - estimatedLongitude)

            latitudeVariance *= (1 - latitudeGain)
            longitudeVariance *= (1 - longitudeGain)

            filteredSamples.append(
                LocationSample(
                    coordinate: CLLocationCoordinate2D(
                        latitude: estimatedLatitude,
                        longitude: estimatedLongitude
                    ),
                    timestampMillis: sample.timestampMillis,
                    accuracyMeters: sample.accuracyMeters
                )
            )
        }

        return filteredSamples
    }

    private static func applySpeedFilter(
        to samples: [LocationSample],
        maxSpeedMetersPerSecond: Double
    ) -> [LocationSample] {
        guard let first = samples.first else { return [] }

        var filteredSamples: [LocationSample] = [first]

        for sample in samples.dropFirst() {
            guard let previous = filteredSamples.last else { continue }

            guard let previousTimestamp = previous.timestampMillis,
                  let currentTimestamp = sample.timestampMillis else {
                filteredSamples.append(sample)
                continue
            }

            let elapsedSeconds = Double(currentTimestamp - previousTimestamp) / 1000
            guard elapsedSeconds > 0 else { continue }

            let distanceMeters = CLLocation(
                latitude: previous.coordinate.latitude,
                longitude: previous.coordinate.longitude
            ).distance(
                from: CLLocation(
                    latitude: sample.coordinate.latitude,
                    longitude: sample.coordinate.longitude
                )
            )

            let speed = distanceMeters / elapsedSeconds

            if speed <= maxSpeedMetersPerSecond {
                filteredSamples.append(sample)
            }
        }

        return filteredSamples
    }

    private static func normalizeLongitudes(
        _ coordinates: [CLLocationCoordinate2D]
    ) -> [CLLocationCoordinate2D] {
        guard let firstLongitude = coordinates.first?.longitude else { return coordinates }

        return coordinates.map { coordinate in
            CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: normalizeLongitudeDifference(
                    coordinate.longitude,
                    referenceLongitude: firstLongitude
                )
            )
        }
    }

    private static func denormalizeLongitudes(
        _ coordinates: [CLLocationCoordinate2D],
        referenceLongitude: Double
    ) -> [CLLocationCoordinate2D] {
        coordinates.map { coordinate in
            var longitude = coordinate.longitude

            while longitude - referenceLongitude > 180 { longitude -= 360 }
            while longitude - referenceLongitude < -180 { longitude += 360 }
            while longitude > 180 { longitude -= 360 }
            while longitude < -180 { longitude += 360 }

            return CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: longitude
            )
        }
    }

    private static func normalizeLongitudeDifference(
        _ longitude: Double,
        referenceLongitude: Double
    ) -> Double {
        var result = longitude
        while result - referenceLongitude > 180 { result -= 360 }
        while result - referenceLongitude < -180 { result += 360 }
        return result
    }

    private static func douglasPeucker(
        _ coordinates: [CLLocationCoordinate2D],
        epsilonMeters: Double
    ) -> [CLLocationCoordinate2D] {
        guard coordinates.count > 2 else { return coordinates }

        let start = coordinates[0]
        let end = coordinates[coordinates.count - 1]
        var maxDistance = 0.0
        var splitIndex = 0

        for index in 1..<(coordinates.count - 1) {
            let distance = perpendicularDistanceMeters(
                from: coordinates[index],
                lineStart: start,
                lineEnd: end
            )

            if distance > maxDistance {
                maxDistance = distance
                splitIndex = index
            }
        }

        guard maxDistance > epsilonMeters else {
            return [start, end]
        }

        let left = douglasPeucker(
            Array(coordinates[...splitIndex]),
            epsilonMeters: epsilonMeters
        )
        let right = douglasPeucker(
            Array(coordinates[splitIndex...]),
            epsilonMeters: epsilonMeters
        )

        return Array(left.dropLast()) + right
    }

    private static func catmullRomInterpolate(
        _ coordinates: [CLLocationCoordinate2D],
        segments: Int
    ) -> [CLLocationCoordinate2D] {
        guard coordinates.count > 2, segments > 0 else { return coordinates }

        var interpolated: [CLLocationCoordinate2D] = []

        for index in 0..<(coordinates.count - 1) {
            let p0 = index > 0 ? coordinates[index - 1] : coordinates[index]
            let p1 = coordinates[index]
            let p2 = coordinates[index + 1]
            let p3 = index + 2 < coordinates.count ? coordinates[index + 2] : coordinates[index + 1]

            for step in 0..<segments {
                let t = Double(step) / Double(segments)
                interpolated.append(
                    CLLocationCoordinate2D(
                        latitude: catmullRomValue(p0.latitude, p1.latitude, p2.latitude, p3.latitude, t),
                        longitude: catmullRomValue(p0.longitude, p1.longitude, p2.longitude, p3.longitude, t)
                    )
                )
            }
        }

        if let last = coordinates.last {
            interpolated.append(last)
        }

        return interpolated
    }

    private static func catmullRomValue(
        _ p0: Double,
        _ p1: Double,
        _ p2: Double,
        _ p3: Double,
        _ t: Double
    ) -> Double {
        let t2 = t * t
        let t3 = t2 * t

        return 0.5 * (
            (2 * p1) +
            (-p0 + p2) * t +
            (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
            (-p0 + 3 * p1 - 3 * p2 + p3) * t3
        )
    }

    private static func perpendicularDistanceMeters(
        from point: CLLocationCoordinate2D,
        lineStart: CLLocationCoordinate2D,
        lineEnd: CLLocationCoordinate2D
    ) -> Double {
        let referenceLatitude = (lineStart.latitude + lineEnd.latitude) / 2
        let startPoint = projectedPoint(from: lineStart, referenceLatitude: referenceLatitude)
        let endPoint = projectedPoint(from: lineEnd, referenceLatitude: referenceLatitude)
        let targetPoint = projectedPoint(from: point, referenceLatitude: referenceLatitude)

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y

        guard dx != 0 || dy != 0 else {
            return hypot(targetPoint.x - startPoint.x, targetPoint.y - startPoint.y)
        }

        let t = max(
            0,
            min(
                1,
                ((targetPoint.x - startPoint.x) * dx + (targetPoint.y - startPoint.y) * dy) / (dx * dx + dy * dy)
            )
        )

        let projectedX = startPoint.x + t * dx
        let projectedY = startPoint.y + t * dy

        return hypot(targetPoint.x - projectedX, targetPoint.y - projectedY)
    }

    private static func projectedPoint(
        from coordinate: CLLocationCoordinate2D,
        referenceLatitude: Double
    ) -> CGPoint {
        let metersPerDegreeLatitude = 111_320.0
        let metersPerDegreeLongitude = 111_320.0 * cos(referenceLatitude * .pi / 180)

        return CGPoint(
            x: coordinate.longitude * metersPerDegreeLongitude,
            y: coordinate.latitude * metersPerDegreeLatitude
        )
    }
}
