
import SwiftUI

struct EmotionBeforeWalkView: View {
    @ObservedObject var vm: WalkViewModel
    @State var isEnableNext = false
    @State var isFirst: Bool = true
    
    init(vm: WalkViewModel) { self.vm = vm }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack {
                    VStack(spacing: 0) {
                        Text("산책 전 나의 마음은 어떤가요?")
                            .font(.system(size: 22, weight: .semibold))
                        
                        Text("산책하기 전 지금 어떤 감정을 느끼는지 선택해주세요")
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
                    .padding(.top, 66)
                    .padding(.horizontal, 16)
                    
                    EmotionSlelectView(emotion: $vm.emotionBeforeWalk, value: $vm.valueBeforeWalk, isEnableNext: $isEnableNext, emosionsBadge: vm.emosionsBadge)
                    
                    HStack {
                        OutlineActionButton(title: "닫기") {
                            vm.dismiss()
                        }
                        .frame(width: UIScreen.main.bounds.width / 3.5)

                        Button {
                            vm.startWalk()
                            vm.goNext(.walkingView)
                        } label: {
                            HStack {
                                Text("다음으로")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(vm.emotionBeforeWalk != "" ? Color(.white) : Color("CustomGray"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(vm.emotionBeforeWalk != "" ? Color(.white) : Color("CustomGray"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(vm.emotionBeforeWalk != "" ? Color("CustomGreen2") : Color("CustomLightGray4"))
                            }
                        }
                        .disabled(vm.emotionBeforeWalk == "")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            if(self.isFirst) {
                vm.reset()
                self.isFirst = false
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}





#Preview {
    EmotionBeforeWalkView(vm: WalkViewModel())
}
