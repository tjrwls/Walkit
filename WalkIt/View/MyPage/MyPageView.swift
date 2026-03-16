
//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct MyPageView: View {
    @ObservedObject var vm: MyPageViewModel
    let userManager = UserManager.shared
    let authManager = AuthManager.shared
    
    init(vm: MyPageViewModel) { self.vm = vm }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text("마이 페이지")
                            .figmaText(fontSize: 20, weight: .semibold)
                            .padding(.vertical, 12)
                        
                        Divider()
                            .foregroundStyle(Color("#EBEBEE"))
                            .padding(.bottom, 16)
                        
                        VStack {
                            HStack(spacing: 0) {
                                Text("\(userManager.nickname)")
                                    .figmaText(fontSize: 24, weight: .semibold)
                                    .foregroundStyle(Color("CustomBlack"))
                                    .padding(.trailing, 4)
                                
                                Text("님")
                                    .figmaText(fontSize: 24, weight: .semibold)
                                    .foregroundStyle(Color("CustomGray"))
                                    .padding(.trailing, 8)
                                
                                Text("Lv.\(userManager.level) \(userManager.getGrade())")
                                    .figmaText(fontSize: 14, weight: .semibold)
                                    .foregroundStyle(Color("CustomBlue"))
                                    .modifier(CapsuleBackground(backgroundColor: Color("CustomLightBlue")))
                                Spacer()
                            }
                            .padding(.bottom, 4)
                            
                            HStack(spacing: 0) {
                                Text("지금까지")
                                    .figmaText(fontSize: 14, weight: .regular)
                                
                                Text(" \(userManager.continuousAttendance)일 ")
                                    .figmaText(fontSize: 14, weight: .semibold)
                                    .foregroundStyle(Color("CustomGreen2"))
                                
                                Text("연속 출석 중!")
                                    .figmaText(fontSize: 14, weight: .regular)
                                Spacer()
                            }
                            .padding(.bottom, 32)
                            
                            if let profileImage = userManager.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image("DefaultImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            }
                            
                            Button {
                            } label: {
                                Text("내 캐릭터 수정")
                                    .figmaText(fontSize: 16, weight: .semibold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 11)
                                    .frame(width: 244)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color("CustomGreen2"))
                                    }
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 16)
                        
                        Rectangle()
                            .frame(height: 10)
                            .foregroundStyle(Color("CustomLightGray"))
                        
                        VStack(spacing: 0) {
                            WalkItCountView(leftTitle: "누적 걸음 수", rightTitle: "함께 걸은 시간", avgSteps: $vm.toalSteps, walkTime: $vm.totalWalkHours)
                                .padding(.vertical, 32)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("설정")
                                    .figmaText(fontSize: 18, weight: .semibold)
                                    .foregroundStyle(Color("CustomBlack"))
                                
                                Button {
                                    vm.goNext(.alimManagerView)
                                } label: {
                                    HStack {
                                        Text("알림 설정")
                                            .figmaText(fontSize: 14, weight: .regular)
                                            .foregroundStyle(Color("CustomBlack"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color("CustomGray"))
                                            .frame(width: 6.55)
                                    }
                                    .padding(.vertical, 9.5)
                                }
                                
                                Button {
                                    vm.goNext(.editUserInfoView)
                                } label: {
                                    HStack {
                                        Text("내 정보 관리")
                                            .figmaText(fontSize: 14, weight: .regular)
                                            .foregroundStyle(Color("CustomBlack"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color("CustomGray"))
                                            .frame(width: 6.55)
                                    }
                                    .padding(.vertical, 9.5)
                                }

                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color("CustomLightGray3"))
                            }
                            .padding(.bottom, 8)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("산책 관리")
                                    .figmaText(fontSize: 18, weight: .semibold)
                                    .foregroundStyle(Color("CustomBlack"))
                                
                                Button {
                                    vm.goNext(.goalsManagerView)
                                } label: {
                                    HStack {
                                        Text("목표 관리")
                                            .figmaText(fontSize: 14, weight: .regular)
                                            .foregroundStyle(Color("CustomBlack"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color("CustomGray"))
                                            .frame(width: 6.55)
                                    }
                                    .padding(.vertical, 9.5)
                                }
                                
                                Button {
                                    vm.goNext(.missionManagerView)
                                } label: {
                                    HStack {
                                        Text("미션")
                                            .figmaText(fontSize: 14, weight: .regular)
                                            .foregroundStyle(Color("CustomBlack"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color("CustomGray"))
                                            .frame(width: 6.55)
                                    }
                                    .padding(.vertical, 9.5)
                                }
                                
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color("CustomLightGray3"))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Button {
                                Task {
                                    await userManager.logOut()
                                }
                            } label: {
                                Text("로그아웃")
                                    .figmaText(fontSize: 14, weight: .regular)
                                    .foregroundStyle(Color("CustomGray"))
                            }
                            .padding(.top, 32)
                            .padding(.bottom, 27)
                            
                            Text("|")
                                .foregroundStyle(Color("CustomGray"))
                            
                            Button {
                                Task {
                                    vm.deleteUserAlert = true
                                }
                            } label: {
                                Text("탈퇴하기")
                                    .figmaText(fontSize: 14, weight: .regular)
                                    .foregroundStyle(Color("CustomGray"))
                            }
                            .padding(.vertical, 20)
                        }
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Link("서비스 이용 약관", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b98027b91ccde7032ce622?pvs=74")!)
                                    .foregroundColor(Color("CustomGray"))
                                    .font(.system(size: 12, weight: .medium))

                                Divider()
                                
                                Link("개인정보처리 방침 보기", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b9805f9f4df589697a27c5")!)
                                    .foregroundColor(Color("CustomGray"))
                                    .font(.system(size: 12, weight: .medium))
                                
                                Divider()
                                
                                Link("마케팅 수신 동의", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b9802cb0e2c7f58ec65ec1?pvs=74")!)
                                    .foregroundColor(Color("CustomGray"))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            
                            HStack(spacing: 8) {
                                Button{
                                    let email = "walk0it2025@gmail.com"
                                    let subject = "앱 문의"
                                    let body = "안녕하세요, 앱 관련 문의드립니다."
                                    
                                    let emailString = "mailto:\(email)?subject=\(subject)&body=\(body)"
                                    if let urlString = emailString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                       let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Text("문의하기")
                                            .foregroundColor(Color("CustomGray"))
                                            .font(.system(size: 12, weight: .medium))
                                        Text("  CS 채널 안내")
                                            .foregroundStyle(Color("CustomLightGray2"))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color("CustomLightGray3"))
                    }
                }
                
                if(vm.deleteUserAlert) {
                    Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                        .onTapGesture { vm.deleteUserAlert = false }
                    VStack {
                        HStack(spacing: 0) {
                            Text("정말 ")
                                .figmaText(fontSize: 18, weight: .semibold)
                                .foregroundStyle(Color("CustomBlack"))
                            Text("탈퇴")
                                .figmaText(fontSize: 18, weight: .semibold)
                                .foregroundStyle(Color("CustomRed"))
                            Text("하시겠습니까?")
                                .figmaText(fontSize: 18, weight: .semibold)
                                .foregroundStyle(Color("CustomBlack"))
                        }
                        .padding(.bottom, 4)
                        
                        Text("탈퇴 시 모든 정보는 6개월 간 보관됩니다\n탈퇴한 계정은 다시 복구되지 않습니다")
                            .figmaText(fontSize: 14, weight: .regular)
                            .foregroundStyle(Color("CustomGray"))
                            .padding(.bottom, 20)
                        
                        HStack(spacing: 8) {
                            Button {
                                vm.deleteUserAlert = false
                            } label: {
                                Text("아니요")
                                    .figmaText(fontSize: 16, weight: .semibold)
                                    .foregroundStyle(Color("CustomBlack"))
                                    .padding(.vertical, 11.5)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("CustomBlack"), lineWidth: 1)
                                    )
                                
                            }
                            
                            Button {
                                Task {
                                    await userManager.cancelMembership()
                                }
                            } label: {
                                Text("예")
                                    .figmaText(fontSize: 16, weight: .semibold)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 11.5)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("CustomBlack"))
                                    )
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.white))
                    )
                    .padding(32)
                }
            }
            .background(Color.white)
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                vm.getWalkSummary()
            }
        }
    }
}

#Preview {
    MyPageView(vm: MyPageViewModel())
}

