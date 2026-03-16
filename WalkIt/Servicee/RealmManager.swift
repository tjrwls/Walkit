
import RealmSwift
import Foundation

class RealmManager {
    static let shared = RealmManager()
    let userManager = UserManager.shared
    private init() {}
    
    private let realm = try! Realm()
    
    // Create
    func addObject<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    // Read
    func fetchObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    // Update (단순 write 블록 사용)
    func updateObject(_ block: () -> Void) {
        try! realm.write {
            block()
        }
    }
    
    // Delete
    func deleteObject<T: Object>(_ object: T) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func getWalk(by id: String) -> WalkRecordEntity? {
        let realm = try! Realm()
        return realm.object(ofType: WalkRecordEntity.self, forPrimaryKey: id)
    }

    
    func getWalkAll() -> [WalkRecordEntity] {
        let allWalk = realm.objects(WalkRecordEntity.self)
            .filter("userId == %@", userManager.userId ?? 0)
        return Array(allWalk)
    }
    
    func getRecently7days() -> [String] {
        // createdDate 기준 내림차순 정렬
        let recent7WalksSlice = realm.objects(WalkRecordEntity.self)
            .filter("userId == %@", userManager.userId ?? 0)
            .sorted(byKeyPath: "createdDate", ascending: false)
            .prefix(7)
        
        return Array(recent7WalksSlice).sorted{ $0.startTime > $1.startTime }.map{$0.id}
    }
    
    // 기존: 특정 월(Int) 기준 조회
    func getWalksMonth(for month: Int) -> [WalkRecordEntity] {
        let calendar = Calendar.current
        let now = Date()

        // 올해 기준
        let year = calendar.component(.year, from: now)

        // 월의 시작일
        let startComponents = DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)
        let startDate = calendar.date(from: startComponents)!

        // 다음 달의 시작일 - 1초 = 이번 달 마지막 시간
        var endComponents = DateComponents(year: year, month: month + 1, day: 1, hour: 0, minute: 0, second: 0)
        if month == 12 {
            endComponents = DateComponents(year: year + 1, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        }
        let endDate = calendar.date(from: endComponents)!.addingTimeInterval(-1)

        // 밀리초 변환
        let startTimestamp = Int64(startDate.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endDate.timeIntervalSince1970 * 1000)

        let realm = RealmManager.shared.realm
        let walks = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime <= %@ AND userId == %@", startTimestamp, endTimestamp, userManager.userId ?? 0)
            .sorted(byKeyPath: "startTime", ascending: true)

        return Array(walks)
    }
    
    // 새로 추가: anchor(Date) 기준 해당 달의 데이터 조회
    func getWalksMonth(anchor: Date) -> [WalkRecordEntity] {
        let calendar = Calendar.current
        
        // anchor가 속한 달의 시작(00:00:00)
        guard let monthInterval = calendar.dateInterval(of: .month, for: anchor) else {
            return []
        }
        let startOfMonth = monthInterval.start
        // 다음 달 시작 직전(한 초 전)까지 포함
        let endOfMonth = monthInterval.end.addingTimeInterval(-1)
        
        // 밀리초 변환(Int64)
        let startTimestamp = Int64(startOfMonth.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endOfMonth.timeIntervalSince1970 * 1000)
        
        let realm = RealmManager.shared.realm
        let walks = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime <= %@ AND userId == %@", startTimestamp, endTimestamp, userManager.userId ?? 0)
            .sorted(byKeyPath: "startTime", ascending: true)

        return Array(walks)
    }

    func getWalkForToday(today: Date) -> [WalkRecordEntity] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
        
        let startTimestamp = Int64(startOfDay.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endOfDay.timeIntervalSince1970 * 1000)
        
        let realm = RealmManager.shared.realm
        let walk = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime <= %@ AND userId == %@", startTimestamp, endTimestamp, userManager.userId ?? 0)
            .sorted(byKeyPath: "startTime", ascending: true)
        
        return Array(walk)
    }

    func getWalksInWeek(containing date: Date) -> [WalkRecordEntity] {
        let calendar = Calendar(identifier: .gregorian)
        var calendarWithSundayStart = calendar
        calendarWithSundayStart.firstWeekday = 1 // Sunday

        let startOfWeek = calendarWithSundayStart.date(from: calendarWithSundayStart.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendarWithSundayStart.date(byAdding: DateComponents(day: 6, hour: 23, minute: 59, second: 59), to: startOfWeek)!
        
        let startTimestamp = Int64(startOfWeek.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endOfWeek.timeIntervalSince1970 * 1000)
        
        let realm = RealmManager.shared.realm
        let walks = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime <= %@ AND userId == %@", startTimestamp, endTimestamp, userManager.userId ?? 0)
            .sorted(byKeyPath: "startTime", ascending: true)
        
        return Array(walks)
    }
    
    func getWalksInWeek(containing date: Date, minSteps: Int = 2000) -> [WalkRecordEntity] {
        let calendar = Calendar(identifier: .gregorian)
        var calendarWithSundayStart = calendar
        calendarWithSundayStart.firstWeekday = 1 // Sunday

        let startOfWeek = calendarWithSundayStart.date(from: calendarWithSundayStart.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendarWithSundayStart.date(byAdding: DateComponents(day: 6, hour: 23, minute: 59, second: 59), to: startOfWeek)!
        
        let startTimestamp = Int64(startOfWeek.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endOfWeek.timeIntervalSince1970 * 1000)
        
        let realm = RealmManager.shared.realm
        let walks = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime <= %@ AND stepCount >= %@ AND userId == %@", startTimestamp, endTimestamp, minSteps, userManager.userId ?? 0)
            .sorted(byKeyPath: "startTime", ascending: true)

        return Array(walks)
    }
    
    func getCharacterInfo(userId: Int) -> CharacterInfoEntity? {
            return realm.objects(CharacterInfoEntity.self)
                .where { $0.userId == userId }
                .first
        }

    
    func saveOrUpdateCharacterInfo(
            userId: Int,
            headImageName: String?,
            bodyImageName: String?,
            feetImageName: String?,
            characterImageName: String?,
            backgroundImageName: String?,
            level: Int,
            grade: String,
            nickName: String
        ) {
            let realm = realm

            let character = getCharacterInfo(userId: userId) ?? CharacterInfoEntity()

            try? realm.write {
                character.userId = userId
                character.headImageName = headImageName
                character.bodyImageName = bodyImageName
                character.feetImageName = feetImageName
                character.characterImageName = characterImageName
                character.backgroundImageName = backgroundImageName
                character.level = level
                character.grade = grade
                character.nickName = nickName

                realm.add(character, update: .modified)
            }
        }
    

    func hasContinuousAttendanceThisWeek(requiredDays: Int) -> Bool {
        let realm = realm

        let calendar = Calendar.current
        let now = Date()

        // 이번 주 시작 (월요일 기준)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return false
        }

        let weekStart = weekInterval.start
        let weekEnd = weekInterval.end

        // 이번 주 산책 기록만 가져오기
        let records = realm.objects(WalkRecordEntity.self)
            .filter("startTime >= %@ AND startTime < %@",
                    Int(weekStart.timeIntervalSince1970 * 1000),
                    Int(weekEnd.timeIntervalSince1970 * 1000))

        // startTime → 날짜(Set으로 중복 제거)
        let walkedDates: Set<Date> = Set(
            records.compactMap { record in
                let date = Date(timeIntervalSince1970: TimeInterval(record.startTime) / 1000)
                return calendar.startOfDay(for: date)
            }
        )

        // 날짜 정렬
        let sortedDates = walkedDates.sorted()

        guard sortedDates.count >= requiredDays else {
            return false
        }

        // 연속 날짜 검사
        var consecutiveCount = 1

        for i in 1..<sortedDates.count {
            let prev = sortedDates[i - 1]
            let current = sortedDates[i]

            if let diff = calendar.dateComponents([.day], from: prev, to: current).day,
               diff == 1 {
                consecutiveCount += 1
                if consecutiveCount >= requiredDays {
                    return true
                }
            } else {
                consecutiveCount = 1
            }
        }

        return false
    }
    
    func hasExceededWeeklySteps(targetSteps: Int) -> Bool {
        let records = getWalksInWeek(containing: Date())

        let calendar = Calendar.current
        let now = Date()

        // 1️⃣ 이번 주 일요일 시작
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 1 // 1 = Sunday

        guard let startOfWeek = calendar.date(from: components) else {
            return false
        }

        // 2️⃣ 이번 주 토요일 끝
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)?
            .addingTimeInterval(86399.999) else {
            return false
        }

        let startMillis = Int(startOfWeek.timeIntervalSince1970 * 1000)
        let endMillis = Int(endOfWeek.timeIntervalSince1970 * 1000)

        // 3️⃣ 이번 주 데이터 필터
        let weeklyRecords = records.filter {
            $0.startTime >= startMillis && $0.startTime <= endMillis
        }

        // 4️⃣ 걸음 수 합산
        let totalSteps = weeklyRecords.reduce(0) {
            $0 + $1.stepCount
        }

        // 5️⃣ 목표 초과 여부
        return totalSteps >= targetSteps
    }


}
