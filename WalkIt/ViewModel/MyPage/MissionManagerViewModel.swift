import Foundation
import Combine

class MissionManagerViewModel: ObservableObject {
    let serverManager = ServerManager.shared
    @Published var selected: MissionType  = .steps
    @Published var weeklyMission: WeeklyMission?
    var isFirst = true
    
    func loadView() {
        if(isFirst) {
            Task { @MainActor in
                await getWeeklyMission()
            }
            isFirst = false
        }
    }
    
    func getWeeklyMission() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            weeklyMission = try await serverManager.getWeeklyMission(token: accessToken)
            if(weeklyMission?.active.type == MissionType.steps.rawValue) {
                selected = .steps
            } else if(weeklyMission?.active.type == MissionType.attendance.rawValue) {
                selected = .attendance
            }
            debugPrint("getWeeklyMission: weeklyMission)")
        } catch {
            debugPrint("getWeeklyMission 실패")
        }
    }
    
    func postVerifyMission(missionId: Int) async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            let result = try await serverManager.postVerifyMission(token: accessToken, userwmId: missionId)
            self.weeklyMission?.active = result
            return true
        } catch {
            return false
        }
    }
}
