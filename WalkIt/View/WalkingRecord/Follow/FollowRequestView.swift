//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher
internal import _LocationEssentials

struct FollowRequestView: View {
    @ObservedObject var vm: FollowRequestViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: FollowRequestViewModel, path: Binding<NavigationPath>) {
        self.vm = vm
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
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
                
                Spacer()
                
                Text("친구 추가")
                    .figmaText(fontSize: 20, weight: .semibold)
                
                Spacer()
                
                VStack {}
                .frame(width: 24, height: 24)
                .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
            
            Divider()
                .foregroundStyle(Color("CustomLightGray"))
                .padding(.bottom, 22)
            
            TextField("친구의 닉네임을 검색해보세요", text: $vm.followNickname)
                .font(.system(size: 16, weight: .regular))
                .focused($isTextFieldFocused)
                .foregroundStyle(Color("CustomBlack"))
                .padding(.vertical, 8)
                .padding(.leading, 16)
                .padding(.trailing, 34)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(.white)
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTextFieldFocused ? Color("CustomBlack") : Color("CustomLightGray"), lineWidth: 1)
                    }
                )
                .overlay(alignment: .trailing) {
                    if(isTextFieldFocused) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color("CustomBlack"))
                            .padding(.trailing, 8)
                            .onTapGesture {
                                isTextFieldFocused = false
                            }
                    } else {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19.6, height: 19.6)
                            .foregroundStyle(Color("CustomBlack"))
                            .padding(.trailing, 8)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 22)
                .onChange(of: vm.followNickname) { oldValue, newValue in
                    Task { @MainActor in
                        if(vm.isValidText(newValue)) {
                            await vm.searchUsers(nickname: vm.followNickname)
                        }
                    }
                }
            
            HStack {
                Text("\(vm.searchUsers.filter{ ($0.followStatus != .ACCEPTED) && ($0.followStatus != .MYSELF) }.count)")
                    .figmaText(fontSize: 14, weight: .medium)
                    .foregroundStyle(Color("CustomGreen"))
                Text("명")
                    .figmaText(fontSize: 14, weight: .regular)
                    .foregroundStyle(Color("CustomGray"))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            
            if(vm.searchUsers.isEmpty) {
                VStack(spacing: 0) {
                    Spacer()
                    Image("NotSearch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 97.2)
                        .padding(.bottom, 20)
                    
                    Text("검색 결과가 없어요")
                        .figmaText(fontSize: 20, weight: .semibold)
                        .foregroundStyle(Color("CustomBlack"))
                        .padding(.bottom,  4)
                    
                    Text("다른 검색어를 입력하세요")
                        .figmaText(fontSize: 14, weight: .medium)
                        .foregroundStyle(Color("CustomGray"))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CustomLightGray3"))
                )
                .padding(.bottom, 30)
                .padding(.horizontal, 16)

            } else {
                ScrollView {
                    let followUsers = vm.searchUsers.filter {
                        $0.followStatus == .EMPTY || $0.followStatus == .REJECTED
                    }
                    ForEach(followUsers, id: \.self) { user in
                        FriendCard(users: user) {
                            Task { @MainActor in
                                await vm.postFollowing(nickname: user.nickName)
                                await vm.searchUsers(nickname: vm.followNickname)
                            }
                        }
                        .onTapGesture(perform: {
                            Task { @MainActor in
                                print("tap")
                                let lat = LocationService.shared.currentLocation?.latitude ?? 0
                                let lon = LocationService.shared.currentLocation?.longitude ?? 0
                                await vm.getUserSummary(nickname: user.nickName, lat: lat, lon: lon)
                                path.append(WalkingRecordRoute.followInfoView)
                            }
                        })
                        Divider()
                    }
                    
                    let pendingUsers = vm.searchUsers.filter { $0.followStatus == .PENDING }
                    ForEach(pendingUsers, id: \.self) { users in
                        FriendCard(users: users) {}
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        
    }
}
struct FriendCard: View {
    let users: SearchUsers
    let action: () -> Void
    var body: some View {
        HStack {
            KFImage(URL(string: users.imageName))
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 26)
                .clipShape(Circle())
            
            Text(users.nickName)
                .figmaText(fontSize: 16, weight: .medium)
            
            Spacer()
            
            if(users.followStatus == .ACCEPTED) {
                Button(action: action, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color("CustomGray"))
                })
            } else if(users.followStatus == .PENDING) {
                Button(action: action, label: {
                    Text("요청중")
                        .figmaText(fontSize: 12, weight: .semibold, lineHeightPercent: 1.3)
                        .foregroundStyle(Color(.white))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CustomGray"))
                        )
                })
                .disabled(true)
            } else if(users.followStatus != .MYSELF) {
                Button(action: action, label: {
                    Text("팔로우")
                        .figmaText(fontSize: 12, weight: .semibold, lineHeightPercent: 1.3)
                        .foregroundStyle(Color(.white))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CustomGreen2"))
                        )
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.white))
    }
}

#Preview {
    FollowRequestView(vm: FollowRequestViewModel(), path: .constant(NavigationPath()))
}
