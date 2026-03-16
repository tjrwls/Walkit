
import SwiftUI
import Kingfisher

struct FollowInfoView: View {
    @ObservedObject var vm: FollowRequestViewModel
    @Binding var path: NavigationPath
    let frameWidth = UIScreen.main.bounds.width
    
    init(vm: FollowRequestViewModel, path: Binding<NavigationPath>) {
        self.vm = vm
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .center) {
                if let imageURL = vm.followWalkSummary?.responseCharacterDto.backgroundImageName {
                    KFImage(URL(string: imageURL))
                        .placeholder { ProgressView() }
                        .retry(maxCount: 3)
                        .resizable()
                        .scaledToFill()
                        .frame(height: frameWidth * vm.calcImageheghit)
                        .overlay(alignment: .bottom) {
                            LinearGradient(
                                colors: [Color(hex: "#191919", alpha: 0.6), Color(hex: "#FFFFFF", alpha: 0)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 280)
                        }
                } else {
                    Image("BackGround")

                }
                
                if(!vm.lottieJson.isEmpty) {
                    LottieCharacterView(json: vm.lottieJson)
                        .frame(width: UIScreen.main.bounds.width * 0.40)
                        .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
                } else {
                    ProgressView()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            if(!path.isEmpty) {
                                path.removeLast()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("CustomBlack"))
                                .frame(width: 9, height: 16)
                        }
                        .padding(.top, 40)
                        
                        Spacer()
                    }
                    Spacer()
                    
                    HStack {
                        Text("Lv.\(vm.followWalkSummary?.responseCharacterDto.level ?? 0)\(vm.getGrade(grade: vm.followWalkSummary?.responseCharacterDto.grade ?? ""))")
                            .font(.system(size: 14)).bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(Color("CustomBlue"))
                            .background(
                                Capsule()
                                    .fill(Color("CustomLightBlue"))
                            )
                        
                        Text(vm.followWalkSummary?.responseCharacterDto.nickName ?? "닉네임")
                            .font(.system(size: 24)).bold()
                        
                        Spacer()
                        
                        Button {
                            Task { @MainActor in
//                                await vm.postFollowing(nickname: vm..nickName)
                            }
                        } label: {
                            Text("팔로우")
                                .foregroundStyle(Color(.white))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomGreen2"))
                                )
                        }
                        
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: frameWidth - 40, height: frameWidth * vm.calcImageheghit)
            }
            .frame(height: frameWidth * vm.calcImageheghit)
            
            
            
            WalkItCountView(leftTitle: "산책 횟수", rightTitle: "산책 시간", avgSteps: .constant(vm.followWalkSummary?.walkTotalSummaryResponseDto.totalWalkCount ?? 0), walkTime: .constant(vm.followWalkSummary?.walkTotalSummaryResponseDto.totalWalkTimeMillis ?? 0))
            
            Spacer()
        }
        .background(Color(hex: "F5F5F5"))
        .ignoresSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}


#Preview {
    FollowInfoView(vm: FollowRequestViewModel(), path: .constant(NavigationPath()))
}
