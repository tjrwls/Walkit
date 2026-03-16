

import SwiftUI
import PhotosUI

struct WalkRecordView: View {
    @ObservedObject var vm: WalkViewModel
    init(vm: WalkViewModel) { self.vm = vm }
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("산책 기록하기")
                .font(.system(size: 24, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            
            Text("오늘의 산책을 사진과 함께 기록해보세요")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 4) {
                Text("산책 사진")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("(최대 1장)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray)
            }
            .padding(.bottom, 9.5)
            
            Text("선택한 사진과 함께 산책 코스가 기록됩니다")
                .font(.system(size: 14, weight: .regular))
                .padding(.bottom, 12)
            
            Button(action: {
                vm.showUploadSheet.toggle()
            }, label: {
                if let selectedImage = vm.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 92, height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 32)
                } else {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 92, height: 92)
                            .foregroundColor(Color(.systemGray4))
                            .overlay(alignment: .center) {
                                Image("Camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                    }
                    .padding(.bottom, 32)
                }
            })
            
            
            VStack(alignment: .leading, spacing: 0) {
                Text("산책 일기 작성하기")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 12)
                
                TextEditor(text: $vm.note)
                    .font(.system(size: 14, weight: .regular))
                    .focused($isTextFieldFocused)
                    .scrollContentBackground(.hidden)
                    .onChange(of: vm.note) { oldValue, newValue in
                        if(newValue.count > 500) { vm.note = oldValue }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                    .background { Color("CustomLightGray3") }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("CustomLightGray2"), lineWidth: 1)
                            if(vm.note == "" && isTextFieldFocused == false) {
                                Text("작성한 산책 일기의 내용은 나만 볼 수 있어요")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color("CustomGray"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                
                HStack {
                    Spacer()
                    Text("\(vm.note.count)/500자")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color("CustomGray"))
                }
            }
            
            VStack {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer()
                        if(vm.isWalkInImageAlert) {
                            HStack(alignment: .top) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("CustomRed"))
                                
                                Text("산책 중 촬영한 사진을 업로드 해주세요")
                                
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("CustomRed"))
                                Spacer()
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("CustomLightPink"))
                                    .stroke(Color("CustomPink"), lineWidth: 1)
                            }
                            .padding(.bottom, 16)
                        }
                        
                        HStack(spacing: 0) {
                            OutlineActionButton(title: "이전으로") {
                                vm.walkRecordGoPrev()
                            }
                            .frame(width: geo.size.width / 3.5)
                            .padding(.trailing, 9)
                            
                            Button(action: {
                                Task {
                                    vm.saveImage()
                                    vm.walkRecordGoNext()
                                }
                            }, label: {
                                HStack {
                                    Text("다음으로")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color(.white))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color(.white))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background { Color("CustomGreen2") }
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            })
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .padding(.top, 38)
        .padding(.horizontal, 16)
        .background(Color(.white))
        .overlay(alignment: .topTrailing) {
            if(vm.showUploadSheet) {
                VStack(spacing: 0) {
                    Button {
                        vm.showCamera = true
                        vm.showUploadSheet = false
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundStyle(Color("CustomBlack"))
                            Text("사진 촬영하기")
                                .foregroundStyle(Color("CustomBlack"))
                        }
                        .padding(10)
                        .padding(.trailing, 40)
                        .frame(width: 200, alignment: .leading)
                        .background(Color(.white))
                    }
                    
                    Button {
                        vm.showPhotoPicker = true
                        vm.showUploadSheet = false
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundStyle(Color("CustomBlack"))
                            Text("갤러리에서 선택")
                                .foregroundStyle(Color("CustomBlack"))
                        }
                        .padding(10)
                        .padding(.trailing, 40)
                        .frame(width: 200, alignment: .leading)
                        .background(Color(.white))
                    }
                    
                    Button {
                        vm.selectedImage = nil
                        vm.savedImage = nil
                        vm.showUploadSheet = false
                    } label: {
                        HStack {
                            Image(systemName: "minus")
                                .foregroundStyle(Color("CustomGreen2"))
                            Text("이미지 삭제")
                                .foregroundStyle(Color("CustomGreen2"))
                        }
                        .padding(10)
                        .padding(.trailing, 40)
                        .frame(width: 200, alignment: .leading)
                        .background(Color("CustomMint"))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("CustomLightGray"), lineWidth: 1)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 1)
                }
                .offset(x: -120, y: 280)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.selectedItem)
        .sheet(isPresented: $vm.showCamera) { CameraPicker(image: $vm.selectedImage) }
        .onChange(of: vm.selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        if let date = vm.extractExifDate(from: data) {
                            if(vm.isWithinWalk(date)) {
                                vm.isWalkInImageAlert = false
                                if let image = UIImage(data: data) {
                                    vm.selectedImage = image
                                }
                            } else {
                                vm.isWalkInImageAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture { isTextFieldFocused = false }
    }
}
#Preview {
    WalkRecordView(vm: WalkViewModel())
}
