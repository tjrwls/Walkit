//
import SwiftUI

struct EmotionAfterWalkView: View {
    @ObservedObject var vm: WalkViewModel
    @State private var isEnableNext = false
    let width = UIScreen.main.bounds.width - 40
    
    init(vm: WalkViewModel) { self.vm = vm }
    
    @State private var emotionGrade: CGFloat = 1
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Text("산책 후 나의 마음은 어떤가요?")
                                .font(.system(size: 22, weight: .semibold))
                                .padding(.bottom, 4)
                            
                            Text("산책 후 감정이 어떻게 변했는지 기록해주세요")
                                .font(.system(size: 14, weight: .regular))
                                .lineLimit(1)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CustomLightGray3"))
                                .stroke(Color("CustomLightGray"), lineWidth: 1)
                        }
                        
                        EmotionSlelectView(emotion: $vm.emotionAfterWalk, value: $vm.valueAfterWalk, isEnableNext: $isEnableNext, emosionsBadge: vm.emosionsBadge)
                        
                        HStack(spacing: 0) {
                            OutlineActionButton(title: "닫기") {
                                vm.showingAlertExit = true
                            }
                            .frame(width: geo.size.width / 3.5)
                            .padding(.trailing, 9)
                            
                            Button {
                                vm.walkRecordGoNext()
                            } label: {
                                HStack {
                                    Text("다음으로")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(vm.emotionAfterWalk != "" ? Color(.white) : Color("CustomGray"))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(vm.emotionAfterWalk != "" ? Color(.white) : Color("CustomGray"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(vm.emotionAfterWalk != "" ? Color("CustomGreen2") : Color("CustomLightGray4"))
                                }
                            }
                            .disabled(vm.emotionAfterWalk == "")
                        }
                    }
                }
            }
        }
        .padding(.top, 52)
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
#Preview {
    EmotionAfterWalkView(vm: WalkViewModel())
}
