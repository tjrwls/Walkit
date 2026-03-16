

import SwiftUI


struct EmotionCardView: View {
    @Binding var emotion: String
    @Binding var count: String
    let day: String
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("이번주 나의 주요 감정은?")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(getTextColor(emotion: emotion))
                    
                    Text(emotionKOR(emotion: emotion))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color(.black))
                        .padding(.vertical, 7)
                    
                    
                    Text(getText(emotion: emotion))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(getTextColor(emotion: emotion))
                }
                Spacer()
            }
            
            HStack(alignment: .top) {
                Spacer()
                if(emotion == "") {
                    Image("EMPTYCard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: getEmotionCardWidth(emotion: emotion))
                } else {
                    Image("\(emotion)Card")
                        .resizable()
                        .scaledToFit()
                        .frame(width: getEmotionCardWidth(emotion: emotion))
                }
            }
        }
        .padding(.vertical, 17.5)
        .padding(.leading, 20)
        .padding(.trailing, getEmotionTrailingPadding(emotion: emotion))
        .background { getBackgroundColor(emotion: emotion) }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    func emotionKOR(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁨"
        case "JOYFUL": return "즐거움"
        case "HAPPY": return "행복"
        case "DEPRESSED": return "우울"
        case "TIRED": return  "지침"
        case "IRRITATED": return "짜증남"
        default : return "기록이 없어요"
        }
    }
    
    func getText(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁜 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "JOYFUL": return "즐거운 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "HAPPY": return "행복한 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "DEPRESSED": return "우울한 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "TIRED": return "지친 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "IRRITATED": return "짜증난 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        default: return "아직 산책 기록이 없어요!\n남은 일상을 워킷과 함께 보내볼까요?"

        }
    }
    
    func getTextColor(emotion: String) -> Color {
        switch(emotion) {
        case "DELIGHTED": return Color("CustomBrown")
        case "JOYFUL": return Color("CustomGreen")
        case "HAPPY": return Color("CustomPink2")
        case "DEPRESSED": return Color("CustomBlue2")
        case "TIRED": return Color("CustomPurple")
        case "IRRITATED": return Color("CustomLightPink")
        default: return Color("CustomGray")
        }
    }
    
    func getBackgroundColor(emotion: String) -> Color {
        switch(emotion) {
        case "DELIGHTED": return Color("CustomYellow")
        case "JOYFUL": return Color("CustomGreen4")
        case "HAPPY": return Color("CustomLightPink2")
        case "DEPRESSED": return Color("CustomBlue3")
        case "TIRED": return Color("CustomPurple2")
        case "IRRITATED": return Color("CustomPink3")
        default: return Color("CustomLightGray")
        }
    }
    
    func getEmotionCardWidth(emotion: String) -> CGFloat {
        switch(emotion) {
        case "DELIGHTED": return 84
        case "JOYFUL": return 90
        case "HAPPY": return 90
        case "DEPRESSED": return 60
        case "TIRED": return 60
        case "IRRITATED": return 60
        default: return 57.21
        }
    }
    
    func getEmotionTrailingPadding(emotion: String) -> CGFloat {
        switch(emotion) {
        case "DELIGHTED": return 23
        case "JOYFUL": return 20
        case "HAPPY": return 20
        case "DEPRESSED": return 36
        case "TIRED": return 36
        case "IRRITATED": return 36
        default: return 36
        }
    }
}
