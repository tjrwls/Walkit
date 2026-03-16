
import SwiftUI
import Kingfisher

struct FollowView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    let backGroundImageHeight = 480.0
    let backGroundImageWidth = 375.0
    let frameWidth = UIScreen.main.bounds.width - 40
    var calcImageheghit : Double {
        return backGroundImageHeight / backGroundImageWidth
    }
    
    init(vm: WalkingRecordViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .center) {
                if let imageURL = vm.followerWalk?.characterDto.backgroundImageName {
                    KFImage(URL(string: imageURL))
                        .placeholder { ProgressView() }
                        .retry(maxCount: 3)
                        .resizable()
                        .scaledToFill()
                        .frame(height: frameWidth * calcImageheghit)
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
                        .resizable()
                        .scaledToFill()
                        .frame(width: frameWidth)
                        .overlay(alignment: .bottom) {
                            LinearGradient(
                                colors: [Color(hex: "#191919", alpha: 0.2), Color(hex: "#FFFFFF", alpha: 0)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 280)
                        }
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
                        Text("Lv.\(vm.followerWalk?.characterDto.level ?? 0)\(vm.getGrade(grade: vm.followerWalk?.characterDto.grade ?? ""))")
                            .font(.system(size: 14)).bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(Color("CustomBlue"))
                            .background(
                                Capsule()
                                    .fill(Color("CustomLightBlue"))
                            )
                        
                        Text(vm.followerWalk?.characterDto.nickName ?? "닉네임")
                            .font(.system(size: 24)).bold()
                        
                        Spacer()
                        
                        Button {
                            vm.isShowingDelete.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(Color("CustomBlack"))
                        }
                    }
                    .padding(.bottom, 5)
                    
                    HStack(spacing: 0) {
                        Text("누적 목표 달성")
                        Text(" \(vm.followerWalk?.characterDto.currentGoalSequence ?? 0)")
                            .foregroundStyle(Color("CustomGreen2"))
                        Text("일")
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("목표 달성률")
                            .foregroundStyle(Color(.white))
                        Spacer()
                        Text("\(Int((Double(vm.followerWalk?.walkProgressPercentage ?? "0") ?? 0).rounded()))%")
                            .foregroundStyle(Color(.white))
                    }
                    
                    GradientLinearSpinner(progress: (Double(vm.followerWalk?.walkProgressPercentage ?? "0") ?? 0) / 100, height: 15, firstColor: Color("CustomGreen2"), lastColor: Color("CustomGreen3"), backgroundColor: Color(.white))
                }
                .padding(20)
                .frame(height: frameWidth * calcImageheghit)
                .overlay(alignment: .topTrailing) {
                    if(vm.isShowingDelete) {
                        Button {
                            Task {
                                await vm.deleteFollows(nickname: vm.followerWalk?.characterDto.nickName ?? "")
                                vm.selectedIndex = 0
                            }
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color("CustomBlack"))
                                Text("차단하기")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color("CustomBlack"))
                            }
                            .padding()
                            .background (
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.white))
                                    .stroke(Color(hex: "EBEBEE"), lineWidth: 1)
                            )
                        }
                        .padding(.top,50)
                        .padding(.trailing, 20)
                    }
                }
            }
            .frame(height: frameWidth * calcImageheghit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            WalkItCountView(leftTitle: "걸음 수", rightTitle: "산책 시간", avgSteps: .constant(vm.followerWalk?.stepCount ?? 0), walkTime: .constant(vm.followerWalk?.totalTime ?? 0))
            
            if(vm.followerWalk?.likeCount ?? 0 == 0) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(Color("CustomBlack"))
                        .padding(4)
                        .background(
                            Circle()
                                .fill(Color(.white))
                                .stroke(Color("CustomLightGray"), lineWidth: 1)

                        )
                    Spacer()
                }
                .onTapGesture {
                    vm.followerWalk?.likeCount += 1
                    vm.followerWalk?.liked = true
                    Task { @MainActor in
                        await vm.postWalkLikes(walkId: vm.followerWalk?.walkId ?? -1)
                    }
                }
            } else {
                HStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color("CustomBlack"))
                        Text(vm.followerWalk?.liked ?? false ? String(vm.followerWalk?.likeCount ?? 0) : String(vm.followerWalk?.likeCount ?? 0 + 1))
                            .foregroundStyle(Color("CustomBlack"))
                    }
                    .padding(4)
                    .background(
                        Capsule()
                            .fill(vm.followerWalk?.liked ?? false ? Color("CustomLightYellow") : Color(.white))
                            .stroke(Color("CustomLightGray"), lineWidth: vm.followerWalk?.liked ?? false ? 0 : 1)
                    )
                    .onTapGesture {
                        if(vm.followerWalk != nil) {
                            if(vm.followerWalk!.liked) {
                                vm.followerWalk?.likeCount -= 1
                                Task { @MainActor in
                                    await vm.deleteWalkLikes(walkId: vm.followerWalk?.walkId ?? -1)
                                }
                            } else {
                                vm.followerWalk?.likeCount += 1
                                Task { @MainActor in
                                    await vm.postWalkLikes(walkId: vm.followerWalk?.walkId ?? -1)
                                }
                            }
                            vm.followerWalk?.liked.toggle()
                        }
                    }
                    Spacer()
                }
            }
        }
        .background(Color(hex: "F5F5F5"))
        .padding(.horizontal, 20)
    }
}


#Preview {
    FollowView(vm: WalkingRecordViewModel())
}
