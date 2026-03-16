import SwiftUI
import Kingfisher

struct HomeView: View {
    private let userManager = UserManager.shared
    @ObservedObject var vm: HomeViewModel
    @Binding var path: NavigationPath
    @Binding var selection: TabType
    @State private var isFirst: Bool = true
    
    private let colorChip = [Color.orange, Color.pink, .green, .cyan, .blue,  .purple, .yellow]
    
    init(vm: HomeViewModel, path: Binding<NavigationPath>, selection: Binding<TabType>) {
        self.vm = vm
        self._path = path
        self._selection = selection
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        navigationBar // 네비게이션 바
                        
                        Divider()
                            .foregroundStyle(Color("CustomLightGray"))
                            .padding(0)
                        
                        mascotArea  //마스코트 영역
                            .padding(.bottom, 32)
                        
                        missionSection // 추천 미션
                            .padding(.bottom, 32)

                        weeklyWalkSection // 이번주 산책 기록(가로 스크롤)
                            .padding(.bottom, 32)
                        
                        emotionSection // 나의 감정 기록
                    }
                }
                .background(Color(.white))
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            stepsArea // 산책하기 버튼
            if(!vm.isAgreeLocationService) {
                Color("CustomBlack2").opacity(0.5)
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 0) {
                        Text("위치 서비스 사용 동의")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 4)
                        
                        Text("산책 중인 위치를 바탕으로 날씨 정보를\n알려주고 나만의 산책 경로를 기록해요")
                            .foregroundStyle(Color("CustomGray"))
                            .font(.system(size: 14, weight: .regular))
                            .padding(.bottom, 20)
                        
                        Button {
                            vm.openAppSettings()
                            vm.isAgreeLocationService = true
                        } label: {
                            Text("동의하고 시작하기")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(.white))
                                .padding(.vertical, 11)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color("CustomGreen2"))
                        )
                        .padding(.bottom, 12)
                        
                        Button("나중에 할게요") {
                            vm.isAgreeLocationService = true
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("CustomGray"))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.white))
                    )
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear {
            vm.loadView()
            vm.loadViewWalkData()
            if(!path.isEmpty) { path = NavigationPath() }
        }
    }
    
    // MARK: - NavigationBar
    private var navigationBar: some View {
        HStack(alignment: .center) {
            Image("HomeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 61)
            
            Spacer()
            
            Button {
                path.append(HomeRoute.notificationView)
            } label: {
                Image("Bell")
                    .frame(width: 16)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.trailing, 8)
            }
            
            if let img = userManager.profileImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .onTapGesture {
                        selection = .MYPAGE
                    }
            } else {
                Image("DefaultImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .onTapGesture {
                        selection = .MYPAGE
                    }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
    
    private var mascotArea: some View {
        VStack {
            ZStack {
                if(vm.useDefaultImage) {
                    Image("BackGround")
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
                } else {
                    KFImage(URL(string: vm.backgroundImageName))
                        .retry(maxCount: 3)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
                }
                
                VStack {
                    Spacer()
                    
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#191919", alpha: 0.6), location: 0.2),
                            .init(color: Color(hex: "#FFFFFF", alpha: 0), location: 1.0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.58)
                }
                
                if(!vm.lottieJson.isEmpty) {
                    LottieCharacterView(json: vm.lottieJson)
                        .frame(width: UIScreen.main.bounds.width * 0.48)
                        .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
                        .onTapGesture {
                            selection = .CHARACTER
                        }
                } else {
                    ProgressView()
                }
                
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(vm.todaySteps))
                                .font(.system(size: 36, weight: .semibold))

                            Text("걸음")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(vm.sky)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                            
                            Text(String(vm.tempC))
                                .font(.system(size: 20, weight: .medium))
                        }
                        .padding(0)
                        .foregroundStyle(.white)
                        .modifier(CapsuleBackground(backgroundColor: Color(hex: "#000000", alpha: 0.1)))
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(userManager.nickname)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("Lv.\(vm.level) \(vm.getGrade(grade: vm.grade))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color("CustomGreen"))
                            .modifier(CapsuleBackground(backgroundColor: Color("CustomGreen5")))
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    GradientLinearSpinner(progress: ((Double(vm.walkProgressPercentage) ?? 0) / 100), height: 16, firstColor: Color("CustomGreen2"), lastColor: Color("CustomGreen3"), backgroundColor: Color(.white))
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("\(userManager.targetWalkCount)일 / \(userManager.targetStepCount)걸음")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("\(Int((Double(vm.walkProgressPercentage) ?? 0).rounded()))%")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
    }

    private var stepsArea: some View {
        HStack(alignment: .center) {
            Spacer()
            Button(action: {
                guard let locationStatus = LocationService.shared.checkLocationPermission()
                else { return }
                
                let pedometerStatus = PedometerManager.shared.checkMotionPermission()
                
                if(pedometerStatus && locationStatus) {
                    path.append(HomeRoute.emotionBeforeWalkView)
                }  else {
                    vm.isAgreeLocationService = false
                }
            }, label: {
                Image("WalkingImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            })
            .buttonStyle(.plain)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
        }
        
    }
//
    
    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("오늘의 추천 미션")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Button {
                    path.append(HomeRoute.missionManagerView)
                } label: {
                    Text("더보기")
                        .font(.system(size: 16, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(Color("CustomGray"))
            }
            .padding(.bottom, 12)
            
            if let mission = vm.mission {
                MissionCard(mission: mission, borderGray: true) {
                    Task {
                        let reuslt = await vm.postVerifyMission(missionId: mission.userWeeklyMissionId ?? 0)
                        if(reuslt) { vm.loadView() }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var weeklyWalkSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("나의 산책 기록")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Button {
                    selection = .WALKRECORD
                } label: {
                    Text("더보기")
                        .font(.system(size: 16, weight: .medium))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(Color("CustomGray"))
            }
            .padding(.bottom, 12)
            
            if(vm.recentlyWalk.isEmpty) {
                VStack(alignment: .center, spacing: 0) {
                    Image("EmptyWalk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(.bottom, 20)
                    
                    Text("아직 산책 기록이 없어요")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.bottom, 4)
                    Text("워킷과 함께 산책하고 나만의 산책 기록을 남겨보세요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("CustomGray"))
                        .padding(.bottom, 20)
                    
                    Button {
                        guard let locationStatus = LocationService.shared.checkLocationPermission() else {
                            LocationService.shared.requestLocation()
                            return
                        }
                        
                        let pedometerStatus = PedometerManager.shared.checkMotionPermission()
                        
                        if(pedometerStatus && locationStatus) {
                            path.append(HomeRoute.emotionBeforeWalkView)
                        }  else {
                            vm.isAgreeLocationService = false
                        }
                    } label: {
                        Text("산책하러 가기")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.white))
                            .padding(.vertical, 9.5)
                            .padding(.horizontal, 16)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("CustomBlack"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CustomLightGray"))
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(vm.recentlyWalk, id: \.self) { walkId in
                            WalkCard(walk: RealmManager.shared.getWalk(by: walkId) ?? WalkRecordEntity())
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 감정 기록")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 12)
            
            EmotionCardView(emotion: $vm.maxEmotion, count: $vm.emotionCount, day: "이번 주")
                .padding(.bottom, 8)
            
            HStack(spacing: 3.5) {
                ForEach(vm.weekEmotion, id: \.self) { emotion in
                    Image("\(emotion)Rectangle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 49)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 72)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(), path: .constant(NavigationPath()), selection: .constant(TabType.HOME))
}
