//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI

struct EditUserInfoView: View {
    @StateObject var vm: EditUserInfoViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var path: NavigationPath
    init(vm: EditUserInfoViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: EditUserInfoViewModel())
        self._path = path
    }
    
    private let years = Array(1900...Calendar.current.component(.year, from: .now)).reversed()
    private let months = Array(1...12)
    private var daysInSelectedMonth: [Int] {
        var comps = DateComponents()
        comps.year = vm.birthYear
        comps.month = vm.birthMonth
        let cal = Calendar.current
        let date = cal.date(from: comps) ?? .now
        let range = cal.range(of: .day, in: .month, for: date) ?? (1..<31)
        return Array(range)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        if(vm.isChangedData()) {
                            vm.showSaveAlert = true
                        } else {
                            path = NavigationPath()
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
                    
                    Text("내 정보 관리")
                        .figmaText(fontSize: 20, weight: .semibold)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 19)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 20) {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                            if let img = vm.selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera")
                                    .foregroundStyle(.white)
                                    .frame(width: 25)
                            }
                        }
                        
                        VStack(alignment: .leading ,spacing: 0) {
                            Button {
                                vm.showUploadSheet.toggle()
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "plus")
                                        .frame(width: 15)
                                        .padding(.vertical, 10.5)
                                    
                                    Text("이미지 편집")
                                        .figmaText(fontSize: 14, weight: .bold)
                                }
                                .foregroundStyle(Color("CustomGreen2"))
                                .padding(.leading, 12)
                                .padding(.trailing, 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color(.systemGreen), lineWidth: 1)
                                )
                            }
                            .padding(.bottom, 8)
                            
                            Text("10MB 이내의 파일만 업로드 가능합니다.")
                                .figmaText(fontSize: 12, weight: .regular)
                                .foregroundStyle(Color("CustomGray"))
                        }
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 34)
                    
                    // Nickname
                    VStack(alignment: .leading, spacing: 8) {
                        requiredLabel("닉네임")
                        
                        TextField("입력해주세요", text: $vm.nickname)
                            .font(.system(size: 16, weight: .regular))
                            .focused($isTextFieldFocused)
                            .foregroundStyle(Color("CustomBlack"))
                            .padding(.vertical, 8)
                            .padding(.leading, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color("CustomLightGray"), lineWidth: 1)
                            )
                            .overlay {
                                Text("\(vm.nickname.count)/20자")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color("CustomGray"))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal, 20)
                            }
                            .onChange(of: vm.nickname) { oldValue, newValue in
                                if(newValue.count > 20) { vm.nickname = oldValue }
                                if(!vm.isValidText(vm.nickname)) {
                                    vm.isDuplicateString = "숫자와 특수문자는 사용 불가합니다"
                                    vm.isDuplicate = true
                                } else {
                                    vm.isDuplicate = false
                                }
                            }
                        
                        if(vm.isDuplicate) {
                            HStack {
                                Text(vm.isDuplicateString)
                                    .figmaText(fontSize: 12, weight: .medium)
                                    .foregroundStyle(Color("CustomPink3"))
                                Spacer()
                            }
                        }
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        requiredLabel("생년월일")
                        HStack(spacing: 16) {
                            // Year
                            Menu {
                                Picker("", selection: $vm.birthYear) {
                                    ForEach(years, id: \.self) { y in
                                        Text("\(y)")
                                            .figmaText(fontSize: 14, weight: .medium)
                                            .tag(y)
                                    }
                                }
                            } label: {
                                dropdownField("\(vm.birthYear)")
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(vm.birthDateEnable ? Color("CustomLightGray") : Color("CustomRed"), lineWidth: 1)
                                    )
                            }
                            .onChange(of: vm.birthYear) { vm.birthDateEnable = vm.isVaildBirthDate() }
                            
                            // Month
                            Menu {
                                Picker("", selection: $vm.birthMonth) {
                                    ForEach(months, id: \.self) { m in
                                        Text("\(m)")
                                            .figmaText(fontSize: 14, weight: .medium)
                                            .tag(m)
                                    }
                                }
                            } label: {
                                dropdownField("\(vm.birthMonth)")
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(vm.birthDateEnable ? Color("CustomLightGray") : Color("CustomRed"), lineWidth: 1)
                                    )
                            }
                            .onChange(of: vm.birthMonth) { vm.birthDateEnable = vm.isVaildBirthDate() }
                            
                            // Day
                            Menu {
                                Picker("", selection: $vm.birthDay) {
                                    ForEach(daysInSelectedMonth, id: \.self) { d in
                                        Text("\(d)")
                                            .figmaText(fontSize: 14, weight: .medium)
                                            .tag(d)
                                    }
                                }
                            } label: {
                                dropdownField("\(vm.birthDay)")
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(vm.birthDateEnable ? Color("CustomLightGray") : Color("CustomRed"), lineWidth: 1)
                                    )
                            }
                            .onChange(of: vm.birthDay) { vm.birthDateEnable = vm.isVaildBirthDate() }
                        }
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("이메일")
                            .figmaText(fontSize: 14, weight: .medium)
                            .foregroundStyle(Color("CustomGray"))
                        
                        Text(vm.email)
                            .figmaText(fontSize: 16, weight: .regular)
                            .foregroundStyle(Color("CustomLightGray2"))
                            .padding(.vertical, 8)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("CustomLightGray3"))
                            )
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("연동된 계정")
                            .figmaText(fontSize: 14, weight: .medium)
                            .foregroundStyle(Color("CustomGray"))
                        
                        Text(vm.authType)
                            .figmaText(fontSize: 16, weight: .regular)
                            .foregroundStyle(Color("CustomLightGray2"))
                            .padding(.vertical, 8)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("CustomLightGray3"))
                            )
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            vm.isSavingProgress = true
                            await vm.saveUserInfo()
                            vm.isSavingProgress = false
                        }
                    } label: {
                        Text("저장하기")
                            .figmaText(fontSize: 16, weight: .semibold)
                            .foregroundStyle(vm.canSave() ? Color(.white) : Color("CustomGray"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11.5)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(vm.canSave() ? Color("CustomGreen2") : Color("CustomLightGray"))
                            )
                    }
                    .disabled(!vm.canSave())
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
                .overlay(alignment: .topLeading) {
                    if(vm.showUploadSheet) {
                        VStack(spacing: 0) {
                            Button {
                                vm.showCamera = true
                                vm.showUploadSheet = false
                            } label: {
                                HStack {
                                    Image(systemName: "camera")
                                        .foregroundStyle(Color("CustomBlack"))
                                        .frame(width: 16.67)
                                        .padding(.vertical, 2.5)
                                        .padding(.horizontal, 1.67)
                                    
                                    Text("사진 촬영하기")
                                        .figmaText(fontSize: 14, weight: .regular)
                                        .foregroundStyle(Color("CustomBlack"))
                                }
                                .padding(.vertical, 6)
                                .padding(.leading, 12)
                                .frame(width: 142, alignment: .leading)
                                .background(Color(.white))
                            }
                            
                            Button {
                                vm.showPhotoPicker = true
                                vm.showUploadSheet = false
                            } label: {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .foregroundStyle(Color("CustomBlack"))
                                        .frame(width: 15)
                                        .padding(2.5)
                                    
                                    Text("갤러리에서 선택")
                                        .figmaText(fontSize: 14, weight: .regular)
                                        .foregroundStyle(Color("CustomBlack"))
                                }
                                .padding(.vertical, 6)
                                .padding(.leading, 12)
                                .frame(width: 142, alignment: .leading)
                                .background(Color(.white))
                            }
                            
                            Button {
                                vm.selectedImage = nil
                                vm.showUploadSheet = false
                            } label: {
                                HStack {
                                    Image(systemName: "minus")
                                        .foregroundStyle(Color("CustomGreen2"))
                                        .frame(width: 11.67)
                                        .padding(.vertical, 9.17)
                                        .padding(.horizontal, 4.17)
                                    
                                    Text("이미지 삭제")
                                        .figmaText(fontSize: 14, weight: .regular)
                                        .foregroundStyle(Color("CustomGreen2"))
                                }
                                .padding(.vertical, 6)
                                .padding(.leading, 12)
                                .frame(width: 142, alignment: .leading)
                                .background(Color("CustomMint"))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("CustomLightGray"), lineWidth: 1)
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 1)
                        }
                        .padding(.leading, 116)
                        .padding(.top, 78)
                    }
                }
            }
            
            if(vm.isSavingProgress) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                ProgressView()
            }
            
            if(vm.showSaveAlert) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showSaveAlert = false
                    }
                VStack(spacing: 10) {
                    Text("변경된 사항이 있습니다")
                        .figmaText(fontSize: 18, weight: .semibold)
                        .padding(.bottom, 4)

                    Text("저장하시겠습니까?")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                        .padding(.bottom, 20)

                    HStack(spacing: 8) {
                        Button {
                            path = NavigationPath()
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
                                vm.isSavingProgress = true
                                await vm.saveUserInfo()
                                vm.isSavingProgress = false
                                path = NavigationPath()
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
        }
        .background(Color(.white))
        .navigationTitle("")
        .navigationBarHidden(true)
        .onTapGesture { isTextFieldFocused = false }
        .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.selectedItem)
        .onChange(of: vm.selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { vm.selectedImage = image }
                }
            }
        }
        .sheet(isPresented: $vm.showCamera) {
            CameraPicker(image: $vm.selectedImage)
        }
        .onAppear {
            Task { @MainActor in
                await vm.loadView()
            }
        }
    }
}

// MARK: - Small UI helpers
private extension EditUserInfoView {
    @ViewBuilder
    func requiredLabel(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
                .figmaText(fontSize: 14, weight: .medium)
            
            Text("*")
                .foregroundStyle(Color("CustomRed"))
        }
    }
    
    @ViewBuilder
    func dropdownField(_ text: String) -> some View {
        HStack(alignment: .center) {
            Text(text)
                .figmaText(fontSize: 14, weight: .medium)
                .foregroundStyle(Color("CustomBlack"))
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .foregroundStyle(Color("CustomGray"))
                .frame(width: 11.15)
        }
        .padding(.vertical, 9.5)
        .padding(.leading, 12)
        .padding(.trailing, 18.90)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EditUserInfoView(vm: EditUserInfoViewModel(), path: .constant(NavigationPath()))
}
