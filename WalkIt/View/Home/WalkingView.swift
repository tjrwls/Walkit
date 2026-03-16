

import SwiftUI
import Kingfisher

struct WalkingView: View {
    @ObservedObject var vm: WalkViewModel
    @State private var endWalk = false
    init(vm: WalkViewModel) { self.vm = vm }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    if(vm.useDefaultImage) {
                        Image("WalkBackGround")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height)
                    } else {
                        KFImage(URL(string: vm.backgroundImageName))
                            .retry(maxCount: 3)
                            .cacheOriginalImage()
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height)
                    }
                    
                    if(!vm.lottieJson.isEmpty) {
                        LottieCharacterView(json: vm.lottieJson)
                            .frame(width: UIScreen.main.bounds.width * 0.48)
                            .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.01)
                    } else {
                        ProgressView()
                    }

                    if(endWalk) {
                        VStack(spacing: 0) {
                            Spacer()
                            Spacer()
                            
                            Text("산책 종료")
                                .figmaText(fontSize: 28, weight: .semibold)
                                .padding(.bottom, 4)
                            
                            Text("산책후 감정을 기록하시겠습니까?")
                                .figmaText(fontSize: 16, weight: .regular)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            Button(action: {
                                vm.goNext(.walkRecordRootView)
                            }, label: {
                                Text("감정 기록하기")
                                    .figmaText(fontSize: 18, weight: .semibold)
                                    .foregroundStyle(Color(.white))
                                    .padding(.vertical, 12.5)
                                    .frame(maxWidth: .infinity)
                                    .background { Color("CustomGreen2") }
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            })
                            .padding(.horizontal, 16)
                            .padding(.bottom, 56)
                            
                        }
                    } else {
                        if(vm.weekGoalCount <= UserManager.shared.targetWalkCount) {
                            ZStack {
                                Capsule()
                                    .fill(Color("CustomLightYellow"))
                                    .frame(width: 131, height: 36)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                                
                                Triangle()
                                    .fill(Color("CustomLightYellow"))
                                    .frame(width: 14, height: 8)
                                    .offset(y: -22)
                                
                                Text("\(vm.weekGoalCount)번째 목표 진행중")
                                    .figmaText(fontSize: 14, weight: .semibold)
                                    .foregroundColor(Color("CustomDarkYellow"))
                                    .padding(.horizontal, 16)
                            }
                            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.68)
                        }
                        
                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Image("Time")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 8)
                                
                                Text(vm.timeString(from: vm.elapsedTime))
                                    .figmaText(fontSize: 20, weight: .medium)
                                    .foregroundColor(Color(.white))
                                    .monospacedDigit()
                                    .onReceive(vm.timer) { _ in
                                        guard vm.isRunning else { return }
                                        vm.elapsedTime += 1
                                    }
                            }
                            .modifier(CapsuleBackground(backgroundColor: Color(hex: "#0000001A", alpha: 0.1)))
                            .padding(.top, 66)
                            .padding(.bottom, 52)
                            
                            Text("현재 걸음 수")
                                .figmaText(fontSize: 16, weight: .medium)
                                .foregroundStyle(Color("CustomGray"))
                            
                            Text(vm.steps.formatted(.number))
                                .figmaText(fontSize: 52, weight: .bold, lineHeightPercent: 1.3)
                                .foregroundColor(Color("CustomGreen6"))
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Button {
                                    vm.isRunning.toggle()
                                    if(vm.isRunning) {
                                        vm.reStartWalk()
                                    } else {
                                        vm.stopWalk()
                                    }
                                } label: {
                                    Image(vm.isRunning ? "StopWalk" : "ReStartWalk")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                }

                                Spacer()
                                
                                Button {
                                    vm.endTime = Int(Date().timeIntervalSince1970 * 1000)
                                    vm.elapsedTime = vm.endTime - vm.startTime
                                    vm.stopWalk()
                                    endWalk = true
                                } label: {
                                    Image("FinishWalk")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { vm.loadWalkingView() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            vm.startBackroundTime = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            vm.endBackroundTime = Date()
            vm.refreshStepHistory()
        }
    }
}
#Preview {
    WalkingView(vm: WalkViewModel())
}
