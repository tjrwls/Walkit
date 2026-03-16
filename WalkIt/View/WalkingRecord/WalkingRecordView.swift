//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation
import Kingfisher

struct WalkIngRecordView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
                .foregroundStyle(Color("CustomLightGray"))
                .padding(0)
            
            ScrollView {
                profileRow
                    .padding(.bottom, 24)
                
                VStack(spacing: 0) {
                    if(vm.selectedProfile == 0) {
                        VStack(spacing: 0) {
                            segmented
                                .padding(.bottom, 12)
                            
                            switch vm.period {
                            case .month:
                                MonthView(vm: vm)
                            case .week:
                                WeekView(vm: vm)
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        FollowView(vm: vm)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color("CustomLightGray3"))
            .padding(0)
        }
        
        .onAppear {
            Task { @MainActor in
                vm.setMothView()
                vm.setWeekView()
                await vm.setFollow()
            }
        }
    }
}

// MARK: - Sections
private extension WalkIngRecordView {
    var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("HomeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 61)
            
            Spacer()
            
            Button {
                vm.goNext(.notificationView)
            } label: {
                Image("Bell")
                    .frame(width: 16)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color(.white))
    }
    
    var profileRow: some View {
        VStack(spacing: 0) {
            HStack {
                Text("친구 목록")
                    .foregroundStyle(Color("CustomBlack"))
                    .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        if let uiImage = UserManager.shared.profileImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == 0) {
                                        Circle().stroke(Color("CustomGreen2"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        vm.selectedProfile = 0
                                        vm.followerWalk = nil
                                    }
                                }
                        } else {
                            Image("DefaultImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 46, height: 46)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == 0) {
                                        Circle().stroke(Color("CustomGreen2"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        vm.selectedProfile = 0
                                        vm.followerWalk = nil
                                    }
                                }
                        }
                        
                        Divider()
                            .foregroundStyle(Color("CustomLightGray5"))
                            .frame(width: 1, height: 32)
                        
                        ForEach(
                            Array(vm.follows.enumerated()),
                            id: \.offset
                        ) { item in
                            let idx = item.offset
                            let follow = item.element
                            
                            KFImage(URL(string: follow.imageName))
                                .retry(maxCount: 3)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == idx + 1) {
                                        Circle().stroke(Color("CustomGreen2"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        let result = await vm.getFollowWalk(nickname: vm.follows[idx].nickname)
                                        if (result) { vm.selectedProfile = idx + 1 }
                                    }
                                }
                        }
                    }
                }
                
                Button {
                    vm.goNext(.followListView)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 9, height: 16)
                        .foregroundStyle(Color("CustomGray"))
                        .background { Color(.white) }

                }
            }
        }
        .padding(.bottom, 14)
        .padding(.horizontal, 20)
        .background(
            Color(.white)
        )
    }
    
    var segmented: some View {
        HStack(spacing: 8) {
            ForEach(WalkingRecordViewModel.Period.allCases, id: \.self) { p in
                Button {
                    vm.period = p
                } label: {
                    Text(p.rawValue)
                        .figmaText(fontSize: 14, weight: .semibold)
                        .foregroundStyle(vm.period == p ? .white : Color("CustomGray"))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(vm.period == p ? Color("CustomBlue5") : Color(.white))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 7.5)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("CustomLightGray"), lineWidth: 1)
            }
        )
    }
}

#Preview {
    WalkIngRecordView(vm: WalkingRecordViewModel())
}
