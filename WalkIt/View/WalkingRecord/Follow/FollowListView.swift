//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher

struct FollowListView: View {
    @StateObject var vm: FollowListViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: FollowListViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
        ZStack {
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
                    
                    Text("친구 목록")
                        .figmaText(fontSize: 20, weight: .semibold)
                    
                    Spacer()
                    
                    Button {
                        path.append(WalkingRecordRoute.followRequestView)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color("CustomBlack"))
                            .frame(width: 18, height: 18)
                    }
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 19)
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
                            .stroke(isTextFieldFocused ? Color("CustomBlack") : Color("CustomLightGray"), lineWidth: 1)                  }
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

                HStack {
                    Text("\(vm.follows.count)")
                        .figmaText(fontSize: 14, weight: .medium)
                        .foregroundStyle(Color("CustomGreen"))
                    Text("명")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                if(vm.follows.filter{ $0.nickname.contains(vm.followNickname) }.isEmpty && !vm.followNickname.isEmpty) {
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
                        .padding(20)

                    } else {
                        ScrollView {
                            let followUsers = vm.follows.filter{ $0.nickname.contains(vm.followNickname) || vm.followNickname.isEmpty }
                            ForEach(followUsers, id: \.self) { users in
                                FollowCard(users: users) {
                                    Task { @MainActor in
                                        vm.selectedNickname = users.nickname
                                    }
                                }
                                .background(vm.selectedNickname == users.nickname ? Color("CustomLightGray") : Color(.white))
                                .overlay(alignment: .trailing) {
                                    if(vm.selectedNickname == users.nickname) {
                                        Button {
                                            vm.isShowDeleteAlert = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "xmark")
                                                    .foregroundStyle(vm.isShowDeleteAlert ? Color("CustomGreen2") : Color("CustomBlack"))
                                                Text("차단하기")
                                                    .foregroundStyle(vm.isShowDeleteAlert ? Color("CustomGreen2") : Color("CustomBlack"))
                                            }
                                            .padding(7)
                                            .padding(.horizontal, 5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(vm.isShowDeleteAlert ? Color("CustomMint") : Color(.white))
                                                    .shadow(radius: 1)
                                            )
                                            .padding(.trailing, 40)
                                        }
                                    }
                                }
                                Divider()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
            }
            if(vm.isShowDeleteAlert) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.isShowDeleteAlert = false
                    }
                VStack {
                    Text("친구 차단하기")
                        .font(.title2).bold()
                        .foregroundStyle(Color("CustomBlack"))

                    Text("\(vm.selectedNickname)을(를) 정말 차단하시겠습니까?")
                    
                    HStack {
                        Button {
                            vm.isShowDeleteAlert = false
                        } label: {
                            Text("아니요")
                                .foregroundStyle(Color("CustomBlack"))
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.white))
                                        .stroke(Color("CustomBlack"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                await vm.deleteFollows(nickname: vm.selectedNickname)
                                await vm.getFollows()
                                vm.isShowDeleteAlert = false
                            }
                        } label: {
                            Text("예")
                                .foregroundStyle(Color(.white))
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomBlack"))
                                )
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.white))
                )
                .padding(20)
            }
        }
        .onAppear {
            vm.loadView()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)

    }
}

struct FollowCard: View {
    let users: Follow
    let action: () -> Void
    var body: some View {
        HStack {
            KFImage(URL(string: users.imageName))
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 26)
                .clipShape(Circle())
            
            Text(users.nickname)
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: action, label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color("CustomGray"))
            })
            .padding(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.white))
    }
}


#Preview {
    FollowListView(vm: FollowListViewModel(), path: .constant(NavigationPath()))
}
