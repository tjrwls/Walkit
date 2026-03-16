//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher

struct NotificationView: View {
    @StateObject var vm: NotificationViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: NotificationViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
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
                .frame(width: 24, height: 24)
                .padding(.leading, 14)
                .padding(.trailing, 5)
                
                Spacer()
                
                Text("알림")
                    .figmaText(fontSize: 20, weight: .semibold)
                
                Spacer()
                
                Color.clear
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 19)
            }
            .padding(.vertical, 12)
            
            ScrollView {
                ForEach(vm.notificationItems, id: \.self) { item in
                    NotificationItemView(vm: vm, notificationItem: item)
                        .padding(20)
                    Divider()
                        .foregroundStyle(Color("CustomLightGray"))
                }
            }
        }
        .onAppear {
            vm.loadView()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NotificationView(vm: NotificationViewModel(), path: .constant(NavigationPath()))
}

struct NotificationItemView: View {
    let vm: NotificationViewModel
    let notificationItem: NotificationItem
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(notificationItem.type)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(notificationItem.body)
                    .figmaText(fontSize: 12, weight: .medium, lineHeightPercent: 1.3)
                    .lineLimit(1)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 4)
                
                Text(getTime(time: notificationItem.createdAt))
                    .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                    .foregroundStyle(Color("CustomGray"))
            }
            
            Spacer()
                .foregroundStyle(Color("CustomLightGray"))
            
            if( notificationItem.type == "FOLLOW" ) {
                HStack(spacing: 4) {
                    Button {
                        if(notificationItem.title.contains("팔로워")) {
                            Task { @MainActor in
                                await vm.patchFollow(nserNickname: notificationItem.senderNickname ?? "")
                                await vm.getNotificationList()
                            }
                        } else {
                            Task { @MainActor in
                                await vm.deleteNotificationList(notiId: notificationItem.notificationId)
                                await vm.getNotificationList()
                            }
                        }
                    } label: {
                        Text("확인")
                            .figmaText(fontSize: 12, weight: .semibold)
                            .foregroundStyle(Color(.white))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16.5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("CustomGreen2"))
                            )
                    }
                    
                    if(notificationItem.title.contains("팔로워")) {
                        Button {
                            Task { @MainActor in
                                await vm.deleteFollower(nickName: notificationItem.senderNickname ?? "")
                                await vm.getNotificationList()
                            }
                        } label: {
                            Text("삭제")
                                .figmaText(fontSize: 12, weight: .semibold)
                                .foregroundStyle(Color("CustomGray"))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomLightGray"))
                                )
                        }
                    }
                }
            }
        }
    }
    
    func getTime(time: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"  // 마이크로초 6자리
        
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
        return ""
    }
}
