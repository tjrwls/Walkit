//
//  MainTabView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct MainTabView: View {
    @State private var selection: TabType = .HOME
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var walkViewMoel = WalkViewModel()
    @StateObject var missionManagerViewModel = MissionManagerViewModel()
    @StateObject var walkingRecordViewModel = WalkingRecordViewModel()
    @StateObject var myPageViewModel = MyPageViewModel()
    @StateObject var dressingRoomViewModel = DressingRoomViewModel()
    @StateObject var followRequestViewModel = FollowRequestViewModel()
    @State private var showTabBar = true

    var body: some View {
        VStack(spacing: 0) {
            switch(selection) {
            case .WALKRECORD:
                NavigationStack(path: $walkingRecordViewModel.path) {
                    WalkIngRecordView(vm: walkingRecordViewModel)
                        .onAppear { if(!showTabBar) { showTabBar = true } }
                        .navigationDestination(for: WalkingRecordRoute.self) { route in
                            switch route {
                            case .dayView: DayView(vm: walkingRecordViewModel)
                            case .followListView: FollowListView(vm: FollowListViewModel(), path: $walkingRecordViewModel.path)
                            case .followView: FollowView(vm: WalkingRecordViewModel())
                            case .followRequestView: FollowRequestView(vm: followRequestViewModel, path: $walkingRecordViewModel.path)
                            case .followInfoView: FollowInfoView(vm: followRequestViewModel, path: $walkingRecordViewModel.path)
                            case .notificationView: NotificationView(vm: NotificationViewModel(), path: $walkingRecordViewModel.path)
                            }
                        }
                }
            case .HOME:
                NavigationStack(path: $walkViewMoel.path) {
                    HomeView(vm: homeViewModel, path: $walkViewMoel.path, selection: $selection)
                        .onAppear { if(!showTabBar) { showTabBar = true } }
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .emotionBeforeWalkView: EmotionBeforeWalkView(vm: walkViewMoel)
                                    .onAppear { showTabBar = false }
                            case .walkingView: WalkingView(vm: walkViewMoel)
                            case .walkRecordRootView: WalkRecordRootView(vm: walkViewMoel)
                            case .missionManagerView: MissionManagerView(vm: missionManagerViewModel, path: $walkViewMoel.path)
                            case .notificationView: NotificationView(vm: NotificationViewModel(), path: $walkViewMoel.path)
                            }
                        }
                }
            case .CHARACTER:
                DressingRoomView(vm: dressingRoomViewModel, selection: $selection)
            case .MYPAGE:
                NavigationStack(path: $myPageViewModel.path) {
                    MyPageView(vm: myPageViewModel)
                        .onAppear { if(!showTabBar) { showTabBar = true } }
                        .navigationDestination(for: MyPageRoute.self) { route in
                            switch route {
                            case .alimManagerView: AlimManagerView(vm: AlimManagerViewModel(), path: $myPageViewModel.path)
                            case .editUserInfoView: EditUserInfoView(vm: EditUserInfoViewModel(), path: $myPageViewModel.path)
                            case .goalsManagerView: GoalsManagerView(vm: GoalsManagerViewModel(), path: $myPageViewModel.path)
                            case .missionManagerView: MissionManagerView(vm: MissionManagerViewModel(), path: $myPageViewModel.path)
                            }
                        }
                }
            }
         
            VStack(spacing: 0) {
                if(showTabBar) {
                    Divider()
                    HStack(spacing: 0) {
                        TabBarButton(iconName: "Home", title: "홈", isSelected: selection == .HOME) {
                            if(selection == .HOME) {
                                walkViewMoel.goHome()
                            } else {
                                selection = .HOME
                            }
                        }
                        
                        TabBarButton(iconName: "Record", title: "산책 기록", isSelected: selection == .WALKRECORD) {
                            if(selection == .WALKRECORD) {
                                walkingRecordViewModel.goHome()
                            } else {
                                selection = .WALKRECORD
                            }
                        }
                        
                        TabBarButton(iconName: "CharacterTab", title: "캐릭터샵", isSelected: selection == .CHARACTER) {
                            if(selection == .CHARACTER) {
                                walkingRecordViewModel.goHome()
                            } else {
                                selection = .CHARACTER
                            }
                        }
                        
                        
                        TabBarButton(iconName: "MyPage", title: "마이 페이지", isSelected: selection == .MYPAGE) {
                            if(selection == .MYPAGE) {
                                myPageViewModel.goHome()
                            } else {
                                selection = .MYPAGE
                            }
                        }
                    }
                }
            }
            .background(.white)
        }
        .onAppear {
            homeViewModel.loadView()
        }
    }
}

#Preview {
    MainTabView()
}
