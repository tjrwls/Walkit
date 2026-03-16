import Foundation
import Combine

class GoalsManagerViewModel: ObservableObject {
    private let serverManager = ServerManager.shared
    
    @Published var targetWalkCount: Int = 1
    @Published var targetStepCount: Int = 1_000
    @Published var isEditEanble: Bool = true
    @Published var showSaveAlert: Bool = false
    @Published var isSavingProgress: Bool = false
    
    var walkCount: Int = 1
    var stepCount: Int = 1_000
    
    let weeklyRange = 1...7
    let stepsRange = 1_000...30_000
    
    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()
    
    func getGoals() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let goals = try await serverManager.getGoals(token: accessToken)
            targetStepCount = goals.targetStepCount
            stepCount = goals.targetStepCount
            targetWalkCount = goals.targetWalkCount
            walkCount = goals.targetWalkCount
            isEditEanble = goals.enableUpdateGoal ?? true
        } catch {
            debugPrint("getGoals Error")
        }
    }
    
    func putGoals() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.putGoals(token: accessToken, goals: Goals(targetStepCount: targetStepCount, targetWalkCount: targetWalkCount))
            UserManager.shared.targetStepCount = targetStepCount
            UserManager.shared.targetWalkCount = targetWalkCount
        } catch {
            isEditEanble = false
            debugPrint("putGoals Error")
        }
    }
    
    func isChangedData() -> Bool {
        if(targetWalkCount != walkCount) { return true }
        if(targetStepCount != stepCount) { return true }
        return false
    }
}
