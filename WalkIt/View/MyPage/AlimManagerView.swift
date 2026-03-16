//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI

struct AlimManagerView: View {
    @Binding var path: NavigationPath
    @StateObject var vm: AlimManagerViewModel
    
    init(vm: AlimManagerViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button{
                    path = NavigationPath()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color("CustomBlack"))
                        .frame(width: 9, height: 16)
                }
                .frame(width: 24, height: 24)
                .padding(.leading, 14)
                .padding(.trailing, 5)
                
                Spacer()
                
                Text("알림 설정")
                    .figmaText(fontSize: 20, weight: .semibold)
                
                Spacer()
                Color.clear
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 19)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.bottom, 16)
            
            HStack {
                Text("전체 알림")
                    .figmaText(fontSize: 18, weight: .semibold)
                
                Spacer()
                Button {
                    if(!vm.notificationEnabled) {
                        vm.notificationEnabled = true
                        vm.goalNotificationEnabled = true
                        vm.missionNotificationEnabled = true
                        vm.friendNotificationEnabled = true
                        vm.marketingPushEnabled = true
                        NotificationManager.shared.requestAuthorizationIfNeeded()
                    } else {
                        vm.notificationEnabled = false
                        vm.goalNotificationEnabled = false
                        vm.missionNotificationEnabled = false
                        vm.friendNotificationEnabled = false
                        vm.marketingPushEnabled = false
                    }
                } label: {
                    Toggle("", isOn: .constant(vm.notificationEnabled))
                        .labelsHidden()
                        .allowsHitTesting(false)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color("CustomLightGray3"))
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 0) {
                Text("앱 정보 알림")
                    .figmaText(fontSize: 18, weight: .semibold)
                    .padding(.bottom, 16)
                
                Toggle("목표 알림", isOn: $vm.goalNotificationEnabled)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.bottom, 8)
                    .onChange(of: vm.goalNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
                Toggle("새로운 미션 오픈 알림 알림", isOn: $vm.missionNotificationEnabled)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.bottom, 8)
                    .onChange(of: vm.missionNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
                Toggle("친구 요청 알림", isOn: $vm.friendNotificationEnabled)
                    .font(.system(size: 14, weight: .regular))
                    .onChange(of: vm.friendNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color("CustomLightGray3"))
            }

            VStack(alignment: .leading) {
                Toggle("마케팅 푸시 동의", isOn: $vm.marketingPushEnabled)
                    .font(.system(size: 14, weight: .regular))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color("CustomLightGray3"))
            }
            .onChange(of: vm.marketingPushEnabled) { _, newValue in
                if(!newValue) { vm.notificationEnabled = false }
                if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
            }
            
            Spacer()
            
            infoBanner
            
            
            HStack {
                OutlineActionButton(title: "뒤로가기", action: {
                    path = NavigationPath()
                })
                
                FilledActionButton(title: "저장하기", isEnable: .constant(true), isRightChevron: false) {
                    Task {
                        await vm.patchNotificationSetting()
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            Task { @MainActor in
                await vm.loadView()
            }
        }
    }
    
    var infoBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(Color("CustomBlue2"))
                .frame(width: 20)
                .padding(.top, 14)
                .padding(.leading, 14)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("기기 알림을 켜주세요.")
                    .figmaText(fontSize: 14, weight: .semibold)
                    .foregroundStyle(Color("CustomBlue2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("정보 알림을 받기 위해 기기 알림을 켜주세요")
                    .figmaText(fontSize: 14, weight: .regular)
                    .foregroundStyle(Color("CustomBlue2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 12)
            .padding(.trailing, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBlue).opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemBlue).opacity(0.35), lineWidth: 1)
        )
        .padding(.bottom, 20)
    }
}

#Preview {
    AlimManagerView(vm: AlimManagerViewModel(), path: .constant(NavigationPath()))
}
