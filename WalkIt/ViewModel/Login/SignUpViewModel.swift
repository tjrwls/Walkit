import Combine
import Foundation
import SwiftUI

enum PickerType {
    case time
    case count
}

class SignUpViewModel: ObservableObject {
    private let authManager = AuthManager.shared
    private let userManager = UserManager.shared
    
    @Published var path = NavigationPath()

    // MARK: SignUpView
    @Published var agreeAll = false
    @Published var termsAgreed = false
    @Published var privacyAgreed = false
    @Published var locationAgreed = false
    @Published var marketingConsent = false
    
    var isAllRequiredAgreed: Bool {
        termsAgreed && privacyAgreed && locationAgreed
    }
    @Published var isShowingProgress = false
    // MARK: nickName
    @Published var nickname: String = ""
    @Published var isDuplicate: Bool = false
    @Published var isDuplicateString: String = ""
    var postNickName: String = ""
    
    // MARK: birthDate
    @Published var isInvalidTextField: Int = 0
    @Published var year: String = ""
    @Published var month: String = ""
    @Published var day: String = ""
    @Published var age: Int = 0
    @Published var birthDateEnable: Bool = false
    @Published var isInvalidBirthDateText: Bool = true
    @Published var isInvalidString: String = ""

    
    // MARK: 목표
    @Published var targetWalkCount: Int = 1
    @Published var targetStepCount: Int = 1000
    
    let weeklyRange = 1...7
    let stepsRange = 1_000...30_000
    
    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()
    
    func goNext(_ route: LoginRoute) {
        path.append(route)
    }

    func dismiss() {
        if(!path.isEmpty) {
            path.removeLast()
        }
    }
    
    func goHome() {
        path = NavigationPath()
    }
    
    func getAge(birthDay: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let age = calendar.dateComponents([.year], from: birthDay, to: now).year!
        return age
    }

    func syncAgreeAll() {
        agreeAll = termsAgreed && privacyAgreed && locationAgreed && marketingConsent
    }
    
    func signUp() {
        authManager.authSate = .LogIn
    }
    
    func moveLoginView() {
        authManager.authSate = .LogOut
    }
    
    func postUsersPolicy() async {
        let result = await userManager.postUsersPolicy(termsAgreed: termsAgreed, privacyAgreed: privacyAgreed, locationAgreed: locationAgreed, marketingConsent: marketingConsent)
        if(result) {
            goNext(.CreateCharacterView)
        }
    }
    
    func postUsersNickname() async {
        if(postNickName != nickname) {
            userManager.nickname = nickname
            let result = await userManager.postUsersNickname()
            if(result) {
                postNickName = nickname
                goNext(.BirthYearView)
            } else {
                isDuplicateString = "중복된 닉네임 입니다"
                isDuplicate = true
            }
        } else {
            goNext(.GoalSettingView)
        }
    }
    
    func postUsersBirthDate() async {
        if(month.count == 1) {
            month = "0" + month
        }
        if(day.count == 1) {
            day = "0" + day
        }
        
        userManager.birthYear = year
        userManager.birthMonth = month
        userManager.birthDay = day
        let result = await userManager.postUsersBirthDate()
        if(result) { goNext(.GoalSettingView) }
    }
    
    func checkBirthDate() -> Bool {
        if(Int(year) ?? 0 < 1900 || year.count < 4) {
            isInvalidTextField = 1
            return false
        } else if(month.count < 1) {
            isInvalidTextField = 2
            return false
        } else if(day.count < 1) {
            isInvalidTextField = 3
            return false
        } else {
            isInvalidTextField = 0
        }
        return true
    }
    
    
    func postGoals() async {
        let goals = Goals(targetStepCount: targetStepCount, targetWalkCount: targetWalkCount)
        let result = await userManager.postGoals(goals: goals)
        if(result) {
            authManager.authSate = .LogIn
            path = NavigationPath()
        }
    }
    
    func isValidText(_ text: String) -> Bool {
        for char in text {
            let scalar = char.unicodeScalars.first!.value
            // 완성형 한글
            if ("\u{AC00}"..."\u{D7A3}").contains(Character(UnicodeScalar(scalar)!)) {
                continue
            }
            // 영어(대소문자)
            if (char >= "a" && char <= "z") || (char >= "A" && char <= "Z") {
                continue
            }
            return false
        }
        return true
    }
    
    func isVaildBirthDate() -> Bool {
        let  dateString = year + "-" + month + "-" + day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        guard let date = formatter.date(from: dateString) else {
            return false // 날짜 형식 자체가 잘못됨
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        guard let minDate = calendar.date( byAdding: .year, value: -150, to: today) else { return false }
        
        if((minDate < targetDate) && (targetDate < today)) { return true }
        return false
    }

    func setBirthDateEnable() {
        birthDateEnable = !(year.isEmpty || month.isEmpty || day.isEmpty)
    }
    
}
