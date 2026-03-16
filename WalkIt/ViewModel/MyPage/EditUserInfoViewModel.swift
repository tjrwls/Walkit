import SwiftUI
import PhotosUI
import Combine

class EditUserInfoViewModel: ObservableObject {
    private let authManager = AuthManager.shared
    private let userManager = UserManager.shared
    private let serverManager = ServerManager.shared
    
    @Published var name: String = ""
    @Published var birthYear: Int = 0
    @Published var birthMonth: Int = 0
    @Published var birthDay: Int = 0
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var authType: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var showUploadSheet = false
    @Published var showPhotoPicker = false
    @Published var showCamera = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var isSavingProgress = false
    
    @Published var birthDateEnable: Bool = true
    @Published var isDuplicate: Bool = false
    @Published var isDuplicateString: String = ""
    
    @Published var showSaveAlert = false
    
    var saveBirthYear: Int = 0
    var saveBirthMonth: Int = 0
    var saveBirthDay: Int = 0
    var saveNickname: String = ""
    var saveSelectedImage: UIImage? = nil
    
    func loadView() async {
        nickname = userManager.nickname
        
        if(userManager.birthYear == "9999") {
            birthYear = 0
        } else {
            birthYear = Int(userManager.birthYear) ?? 0
        }
        
        if(userManager.birthMonth == "09") {
            birthMonth = 0
        } else {
            birthMonth = Int(userManager.birthMonth) ?? 0
        }
        
        if(userManager.birthDay == "09") {
            birthDay = 0
        } else {
            birthDay = Int(userManager.birthDay) ?? 0
        }
        
        selectedImage = userManager.profileImage
        authType = authManager.loginType
        if(!authManager.name.isEmpty) {
            name = authManager.name
        } else {
            name = authManager.nickname
        }
        email = authManager.email
        
        saveBirthYear = birthYear
        saveBirthMonth = birthMonth
        saveBirthDay = birthDay
        saveNickname = nickname
        saveSelectedImage = selectedImage
    }
    
    
    func isChangedData() -> Bool {
        if(saveNickname != nickname) { return true }
        if(saveSelectedImage != selectedImage) { return true }
        return false
    }
    
    func saveUserInfo() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        var year = String(birthYear)
        var month = String(format: "%02d", birthMonth)
        var day = String(format: "%02d", birthDay)
        
        if(birthYear == 0 || birthMonth == 0 || birthDay == 0) {
            year = "9999"
            month = "09"
            day = "09"
        }
        
        let birthDate = year + "-" + month + "-" + day
        
        do {
            try await serverManager.putUsers(token: accessToken, nickname: nickname, birthDate: birthDate)
            userManager.nickname = nickname
            userManager.birthYear = String(birthYear)
            userManager.birthMonth = String(birthMonth)
            userManager.birthDay = String(birthDay)
        } catch {
            isDuplicateString = "중복된 닉네임 입니다"
            isDuplicate = true
            debugPrint("putUsers 실패")
        }
        
        if let image = selectedImage {
            do {
                try await serverManager.putUsersImage(token: accessToken, image: resizeImage(image))
                userManager.profileImage = image
            } catch {
                debugPrint("putUsersImage 실패")
            }
        } else {
            do {
                try await serverManager.getDeleteUserImage(token: accessToken)
                userManager.profileImage = nil
            } catch {
                debugPrint("delete 실패")
            }
        }
        saveNickname = nickname
        saveSelectedImage = selectedImage
    }
    
    func resizeImage(_ image: UIImage, maxWidth: CGFloat = 1024) -> UIImage {
        let size = image.size
        let ratio = maxWidth / size.width
        
        if ratio >= 1 { return image }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized ?? image
    }
    
    
    
    func isValidText(_ text: String) -> Bool {
        for char in text {
            // 첫 번째 스칼라 값
            let value = char.unicodeScalars.first!.value
            
            // 1) 한글 완성형 (가 ~ 힣)
            if (0xAC00...0xD7A3).contains(value) {
                continue
            }
            
            // 2) 한글 자모 (자음/모음) U+1100 ~ U+11FF
            if (0x1100...0x11FF).contains(value) {
                continue
            }
            
            // 3) 한글 호환 자모 (ㄱ ㄴ ㅏ 등) U+3130 ~ U+318F
            if (0x3130...0x318F).contains(value) {
                continue
            }
            
            // 4) 영어 (대소문자)
            if (char >= "a" && char <= "z") || (char >= "A" && char <= "Z") {
                continue
            }
            
            // 나머지 문자는 허용하지 않음
            return false
        }
        return true
    }
    
    
    func isVaildBirthDate() -> Bool {
        if(birthYear == 0 || birthMonth == 0 || birthDay == 0) { return true }
        var month = String(birthMonth)
        var day = String(birthDay)
        if(month.count < 2) {
            month = "0" + month
        }
        if(day.count < 2) {
            day = "0" + day
        }
        
        let dateString = String(birthYear) + "-" + String(birthMonth) + "-" + String(birthDay)
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
        birthDateEnable = !(birthYear == 0 || birthMonth == 0 || birthDay == 0)
    }
    
    func imageDelete() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.getDeleteUserImage(token: accessToken)
        } catch {
            
        }
    }
    
    func canSave() -> Bool {
        if(nickname.isEmpty || isDuplicate) { return false }
        if(saveNickname != nickname) { return true }
        if(saveSelectedImage != selectedImage) { return true }
        return false
    }
}
