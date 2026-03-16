//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation
import Kingfisher

struct DayView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    @FocusState private var isTextFieldFocused: Bool
    init(vm: WalkingRecordViewModel) { self.vm = vm }

    private var title: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월 d일"
        return fmt.string(from: vm.currentDay)
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        HStack {
                            Button {
                                if(vm.isChangedData()) {
                                    vm.isDismissAlert = true
                                    vm.showSaveAlert = true
                                } else {
                                    vm.dismiss()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(Color("CustomBlack"))
                                    .frame(width: 9, height: 16)
                            }
                            .frame(width: 24, height: 24)
                            .padding(.leading, 14)
                            .padding(.trailing, 5)
                            
                            Spacer()
                            Text("일일 산책 기록")
                                .figmaText(fontSize: 18, weight: .medium)
                            
                            Spacer()
                            Color.clear
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 19)
                        }
                        .padding(.vertical, 16)
                        .background(Color(.white))
                        
                        VStack(spacing: 0) {
                            ScrollView(.horizontal) {
                                HStack(spacing: -7) {
                                    ForEach(0..<vm.dayWalks.count, id: \.self) { idx in
                                        Button {
                                            if(vm.isChangedData()) {
                                                vm.isDismissAlert = false
                                                vm.showSaveAlert = true
                                            } else {
                                                vm.selectedIndex = idx
                                                vm.dayWalk = vm.dayWalks[idx]
                                                vm.note = vm.dayWalk.note ?? ""
                                                vm.savedNote = vm.note
                                                vm.isTextEditor = false
                                            }
                                        } label: {
                                            Text(vm.koreanOrdinalWord(index: idx))
                                                .figmaText(fontSize: 14, weight: .semibold)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                        }
                                        .foregroundStyle(vm.selectedIndex == idx ? Color("CustomGray") : Color("CustomLightGray2") )
                                        .background(FolderTabShape().fill(vm.selectedIndex == idx ? Color(.white) : Color("CustomGray2") ) )
                                        .zIndex(vm.selectedIndex == idx ? 1 : 0)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text(title)
                                        .figmaText(fontSize: 18, weight: .medium)
                                    Spacer()
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 12)
                                
                                if(vm.dayWalks.count > 0) {
                                    ZStack(alignment: .bottomTrailing) {
                                        DayDiaryCard(walk: vm.dayWalk)
                                        
                                        Text(vm.unixMsToHourMinute(walk: vm.dayWalk))
                                            .figmaText(fontSize: 14, weight: .semibold)
                                            .foregroundStyle( Color(.white) )
                                            .padding()
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            vm.isShowSavingView = true
                                        } label : {
                                            Image("SHARE")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                                .padding(15)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .background(Color(.white))
                            .clipShape(RoundedCorners())
                            .padding(.bottom, 8)
                            
                            WalkItCountView(leftTitle: "걸음 수", rightTitle: "산책 시간", avgSteps: $vm.dayWalk.stepCount, walkTime: $vm.dayWalk.totalTime)
                                .padding(.bottom, 8)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(spacing: 0) {
                                    HStack(alignment: .center) {
                                        Text("감정 기록")
                                            .figmaText(fontSize: 14, weight: .medium)
                                        Spacer()
                                        
                                        Button {
                                            vm.showingEditMenu.toggle()
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundStyle(.black)
                                                .frame(width: 16, height: 4)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 10)
                                        }
                                    }
                                    .padding(.top, 16)
                                    .padding(.bottom, 12)
                                    
                                    HStack(spacing: 8) {
                                        Image("\(vm.dayWalk.preWalkEmotion ?? "")Circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 52, height: 52)
                                            .clipShape(Circle())
                                        Image("\(vm.dayWalk.postWalkEmotion ?? "")Circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 52, height: 52)
                                            .clipShape(Circle())
                                        Spacer()
                                    }
                                }
                                .padding(.bottom, 12)
                                
                                if(!vm.note.isEmpty || vm.isTextEditor) {
                                    Divider()
                                        .foregroundStyle(Color("CustomLightGray"))
                                        .padding(.bottom, 12)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        TextEditor(text: $vm.note)
                                            .focused($isTextFieldFocused)
                                            .padding(10)
                                            .background{ Color("CustomLightGray4") }
                                            .frame(height: 140)
                                            .scrollContentBackground(.hidden)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .disabled(!vm.isTextEditor)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Button {
                                        if(vm.isChangedData()) {
                                            vm.isDismissAlert = true
                                            vm.showSaveAlert = true
                                        } else {
                                            vm.dismiss()
                                        }
                                    } label: {
                                        Text("뒤로가기")
                                            .figmaText(fontSize: 14, weight: .semibold)
                                            .foregroundStyle(Color("CustomGreen2"))
                                            .padding(.vertical, 9.5)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color("CustomGreen2"), lineWidth: 1)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                            .fill(Color(.white))
                                                    )
                                            )
                                    }
                                    
                                    Button {
                                        Task {
                                            await vm.fetchWalk()
                                        }
                                    } label: {
                                        HStack {
                                            Text("저장하기")
                                                .figmaText(fontSize: 14, weight: .semibold)
                                                .foregroundStyle(Color(.white))
                                        }
                                        .padding(.vertical, 9.5)
                                        .frame(maxWidth: .infinity)
                                        .background { Color("CustomGreen2") }
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.white))
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .overlay(alignment: .topTrailing) {
                                if(vm.showingEditMenu) {
                                    VStack(spacing: 5) {
                                        Button {
                                            vm.editNote()
                                            vm.showingEditMenu = false
                                        } label: {
                                            HStack {
                                                Image(systemName: "pencil")
                                                    .foregroundStyle(Color("CustomGreen2"))
                                                Text("수정하기")
                                                    .foregroundStyle(Color("CustomGreen2"))
                                            }
                                            .padding(10)
                                            .padding(.trailing, 40)
                                            .background(Color("CustomMint"))
                                        }
                                        
                                        Button {
                                            vm.deleteNote()
                                            vm.showingEditMenu = false
                                        } label: {
                                            HStack {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(Color("CustomBlack"))
                                                Text("삭제하기")
                                                    .foregroundStyle(Color("CustomBlack"))
                                            }
                                            
                                        }
                                        .padding(10)
                                        .padding(.trailing, 40)
                                    }
                                    .background{Color(.white)}
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("CustomLightGray"), lineWidth: 1)
                                            .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 1)
                                    }
                                    .offset(y: 45)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(Color("CustomLightGray3"))
            }
            if(vm.showSaveAlert) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showSaveAlert = false
                    }
                VStack(spacing: 0) {
                    Text("변경된 사항이 있습니다")
                        .figmaText(fontSize: 18, weight: .semibold)
                        .padding(.bottom, 4)
                    
                    Text("저장하시겠습니까?")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 8) {
                        Button {
                            if(vm.isDismissAlert) {
                                vm.showSaveAlert = false
                                vm.dismiss()
                            } else {
                                vm.showSaveAlert = false
                            }
                        } label: {
                            Text("아니요")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color("CustomGreen2"))
                                .padding(.vertical, 14.5)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomGreen2"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                if(vm.isDismissAlert) {
                                    _ = await vm.fetchWalk()
                                    vm.showSaveAlert = false
                                    vm.dismiss()
                                } else {
                                    _ = await vm.fetchWalk()
                                    vm.showSaveAlert = false
                                }
                            }
                        } label: {
                            Text("예")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color(.white))
                                .padding(.vertical, 14.5)
                                .frame(maxWidth: .infinity)
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
            if(vm.isShowSavingView) {
                DaySavingView(walk: vm.dayWalk, vm: vm)
            }
            
        }
        .padding(.vertical, 12)
        .background(Color(.white))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar(.hidden)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Sections
private struct DayDiaryCard: View {
    let walk: WalkRecordEntity
    
    var body: some View {
        ZStack {
            if let imageURL = walk.imageUrl {
                KFImage(URL(string: imageURL))
                    .placeholder { ProgressView() }
                    .retry(maxCount: 3)
                    .resizable()
                    .scaledToFill()
                Color.black.opacity(0.45)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DaySavingView: View {
    let walk: WalkRecordEntity
    let vm: WalkingRecordViewModel
    @State private var isSavingProgress = false
    @State private var saveSuccess: Bool? = nil
    @State private var loadedImage: UIImage? = nil

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
                    } else {
                        if let urlString = walk.imageUrl, let url = URL(string: urlString) {
                            KFImage(url)
                                .retry(maxCount: 3)
                                .onSuccess { result in
                                    loadedImage = result.image
                                }
                                .resizable()
                                .scaledToFit()
                                .frame(width: width, height: width)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
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

#Preview {
    DayView(vm: WalkingRecordViewModel())
}
