//
//  WalkRecordRootView.swift
//  WalkIt
//
//  Created by 조석진 on 1/3/26.

import SwiftUI
import Kingfisher

struct WalkRecordRootView: View {
    @ObservedObject var vm: WalkViewModel
    init(vm: WalkViewModel) { self.vm = vm }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if(vm.walkRootViewIndex != .checkRecordingView) {
                    HStack(spacing: 10) {
                        Capsule()
                            .foregroundStyle(Color("CustomGreen2"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                        Capsule()
                            .foregroundStyle(vm.walkRootViewIndex != .emotionAfterWalkView ? Color("CustomGreen2") : Color("CustomLightGray4"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                        Capsule()
                            .foregroundStyle(Color("CustomLightGray4"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                
                ZStack {
                    VStack(spacing: 0) {
                        ScrollView {
                            HStack(spacing: 10) {
                                Capsule()
                                    .foregroundStyle(Color("CustomGreen2"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                Capsule()
                                    .foregroundStyle(Color("CustomGreen2"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                Capsule()
                                    .foregroundStyle(Color("CustomGreen2"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)

                            Text("오늘도 산책 완료!")
                                .figmaText(fontSize: 22, weight: .semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 0) {
                                Text("이번주")
                                    .figmaText(fontSize: 16, weight: .regular)
                                    .foregroundColor(Color("CustomGray"))
                                Text(" \(vm.weekWalkCount)번째 ")
                                    .figmaText(fontSize: 16, weight: .regular)
                                    .foregroundColor(Color("CustomBlue5"))
                                Text("산책을 완료했어요")
                                    .figmaText(fontSize: 16, weight: .regular)
                                    .foregroundColor(Color("CustomGray"))
                                Spacer()
                                
                                Button {
                                    vm.isShowSavingView = true
                                } label : {
                                    Image("SHAREGray")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .padding(3)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            
                            ZStack {
                                KakaoMapView(walkRoutes: vm.getWalkRoutes(points: vm.points), onCoordinatorReady: { coordinator in
                                    vm.kakaoCoordinator = coordinator
                                })
                                .frame(width: vm.width, height: vm.width)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .opacity((vm.walkRootViewIndex == .checkRecordingView) && (vm.savedImage == nil) ? 1 : 0.01)
                                .padding(.bottom, 16)
                                .allowsHitTesting(false)

                                if let uiImage = vm.savedImage, vm.walkRootViewIndex == .checkRecordingView {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: vm.width, height: vm.width)
                                        .clipShape( RoundedRectangle(cornerRadius: 8))
                                        .padding(.bottom, 16)
                                }
                            }
                            
                            if vm.walkRootViewIndex == .checkRecordingView {
                                CheckRecordingView(vm: vm)
                            }
                        }
                        .opacity(vm.walkRootViewIndex == .checkRecordingView ? 1 : 0.01)
                    }
                    
                    if vm.walkRootViewIndex == .emotionAfterWalkView {
                        EmotionAfterWalkView(vm: vm)
                    }
                    
                    if vm.walkRootViewIndex == .walkRecordView {
                        WalkRecordView(vm: vm)
                    }
                    
                    if(vm.showSavingProgress) {
                        Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                        ProgressView()
                    }
                    
                    if(vm.showSavingSuccess) {
                        Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                (
                                Text("산책 감정 기록이")
                                    .foregroundStyle(Color("CustomBlack"))
                                +
                                Text(" 완료")
                                    .foregroundStyle(Color("CustomGreen"))
                                +
                                Text("되었습니다!")
                                    .foregroundStyle(Color("CustomBlack"))
                                )
                                .figmaText(fontSize: 18, weight: .semibold)
                            }
                            .padding(.bottom, 4)
                            
                            Text("완료된 산책 기록을 친구들에게 공유할 수 있어요")
                                .figmaText(fontSize: 14, weight: .regular)
                                .foregroundStyle(Color("CustomGray"))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 20)
                            
                            Button {
                                vm.emotionBeforeWalk = ""
                                vm.reset()
                                vm.goHome()
                            } label: {
                                Text("확인")
                                    .figmaText(fontSize: 16, weight: .semibold)
                                    .foregroundStyle(Color(.white))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("CustomGreen2"))
                                    )
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .background(
                            Color(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            if(vm.showingAlertExit) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showingAlertExit = false
                    }
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("산책 기록을")
                            .figmaText(fontSize: 18, weight: .semibold)
                            .foregroundStyle(Color("CustomBlack"))
                        Text(" 중단")
                            .figmaText(fontSize: 18, weight: .semibold)
                            .foregroundStyle(Color("CustomRed"))
                        Text("하시겠습니까?")
                            .figmaText(fontSize: 18, weight: .semibold)
                            .foregroundStyle(Color("CustomBlack"))
                    }
                    .padding(.bottom, 4)

                    Text("이대로 종료하시면 작성한 산책 기록이 모두 사라져요!")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 0) {
                        Button {
                            vm.emotionBeforeWalk = ""
                            vm.reset()
                            vm.goHome()
                        } label: {
                            Text("중단하기")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color("CustomBlack"))
                                .padding(.vertical, 11.5)
                                .padding(.horizontal, 36.25)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomBlack"), lineWidth: 1)
                                )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("CustomBlack"), lineWidth: 1)
                        )
                        .padding(.trailing, 8)
                        
                        Button {
                            vm.showingAlertExit = false
                        } label: {
                            Text("계속하기")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color(.white))
                                .padding(.vertical, 11.5)
                                .padding(.horizontal, 36.25)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomBlack"))
                                )
                        }
                        .background( Color("CustomBlack") )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .background(
                    Color(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .padding(.horizontal, 20)
            }
            if(vm.isShowSavingView) {
                DaySavingView(walk: vm.getWalkRecordEntity(), vm: vm, loadedImage: vm.getImage())
            }
        }
        .background(vm.walkRootViewIndex == .checkRecordingView ? Color("CustomLightGray3") : Color(.white))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    WalkRecordRootView(vm: WalkViewModel())
}

private struct DaySavingView: View {
    let walk: WalkRecordEntity
    let vm: WalkViewModel
    @State private var isSavingProgress = false
    @State private var saveSuccess: Bool? = nil
    let loadedImage: UIImage?

    var walkHours: String { String(walk.totalTime / 3_600_000) }
    var walkMinute: String { String((walk.totalTime % 3_600_000) / 60_000) }
    let width = UIScreen.main.bounds.width - 64
    
    var body: some View {
        ZStack {
            Color("CustomBlack2").opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    vm.isShowSavingView = false
                }
            VStack(spacing: 0) {
                Text("기록 공유하기")
                    .figmaText(fontSize: 18, weight: .semibold)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 4)
                
                Text("오늘의 산책 기록을 공유하시겟습니까?")
                    .figmaText(fontSize: 14, weight: .semibold)
                    .foregroundStyle(Color("CustomGray"))
                    .padding(.bottom, 20)
                
                let savingView = ZStack {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width, height: width)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CustomBlack2").opacity(0.45))
                        .frame(width: width, height: width)
                    
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 2) {
                            Image("WAL")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15.41)
                            Image("KIT")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14.85)
                            Spacer()
                        }
                        Spacer()
                        
                        HStack(spacing: 0) {
                            Image("\(walk.preWalkEmotion ?? "")Circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                                .padding(.trailing, 8)
                            
                            Image("\(walk.postWalkEmotion ?? "")Circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Spacer()
                                    (
                                        Text(String(walk.stepCount))
                                            .font(.system(size: 18, weight: .semibold))
                                        + Text("걸음")
                                            .font(.system(size: 14, weight: .medium))
                                    )
                                    .foregroundStyle(Color(.white))
                                }
                                
                                HStack(spacing: 0) {
                                    Spacer()
                                    if(walkHours != "0") {
                                        (
                                            Text(walkHours)
                                                .font(.system(size: 18, weight: .semibold))
                                            + Text("시간 ")
                                                .font(.system(size: 14, weight: .medium))
                                            + Text(walkMinute)
                                                .font(.system(size: 18, weight: .semibold))
                                            + Text("분")
                                                .font(.system(size: 14, weight: .medium))
                                        )
                                        .foregroundStyle(Color(.white))
                                    } else {
                                        (
                                            Text(walkMinute)
                                                .font(.system(size: 18, weight: .semibold))
                                            + Text("분")
                                                .font(.system(size: 14, weight: .medium))
                                        )
                                        .foregroundStyle(Color(.white))
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(height: width)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                savingView
                    .padding(.bottom, 20)

                
                if let saveSuccess = saveSuccess {
                    HStack(alignment: .center, spacing: 0) {
                        if(saveSuccess) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(.white))
                                .frame(width: 15.46)
                        } else {
                            Image(systemName: "xmark")
                                .frame(width: 13.15)
                                .foregroundStyle(Color("CustomRed"))
                        }
                        
                        Text(saveSuccess ? "이미지 저장이 완료 되었습니다." : "이미지 저장이 실패했습니다")
                            .figmaText(fontSize: 14, weight: .semibold)
                            .foregroundStyle(saveSuccess ? Color(.white) : Color("CustomRed"))
                            .padding(.leading, 14)
                        Spacer()
                    }
                    .padding(.vertical, 17.5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(saveSuccess ? Color("CustomGray2") : Color("CustomLightPink"))
                            .stroke(saveSuccess ? Color("CustomGray2") : Color("CustomPink"), lineWidth: 1)
                    )
                }
                
                HStack(spacing: 8) {
                    OutlineActionButton(title: "뒤로가기") {
                        vm.isShowSavingView = false
                    }
                    
                    FilledActionButton(title: "저장하기", isEnable: .constant(true), isRightChevron: false) {
                        isSavingProgress = true
                        vm.requestPhotoPermission { granted in
                            if granted {
                                Task { @MainActor in
                                    if let image = savingView.snapshot() {
                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                        saveSuccess = true
                                    }
                                }
                            } else {
                                saveSuccess = false
                                vm.openAppSettings()
                            }
                            isSavingProgress = false
                        }
                        
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.white))
            )
            .padding(.horizontal, 16)
            
            if(isSavingProgress) {
                Color("CustomBlack2").opacity(0.6).ignoresSafeArea()
                ProgressView()
            }
            
        }
    }
}
