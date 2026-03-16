

import RealmSwift
import Foundation

class WalkPointEntity: Object {
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    @Persisted var timestamp: Int = 0
}

class WalkRecordEntity: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var walkId: Int = 0
    @Persisted var userId: Int = 0
    @Persisted var isSaving: Bool = false
    @Persisted var preWalkEmotion: String? = nil
    @Persisted var postWalkEmotion: String? = nil
    @Persisted var note: String? = nil
    @Persisted var imageUrl: String? = nil
    @Persisted var startTime: Int = 0
    @Persisted var endTime: Int = 0
    @Persisted var totalTime: Int = 0
    @Persisted var stepCount: Int = 0
    @Persisted var totalDistance: Int = 0
    @Persisted var createdDate: String? = nil
    @Persisted var points = List<WalkPointEntity>()
}
