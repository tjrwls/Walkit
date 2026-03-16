
import SwiftUI
import CoreLocation

struct CheckRecordingView: View {
    @ObservedObject var vm: WalkViewModel
    @FocusState private var isTextFieldFocused: Bool
    init(vm: WalkViewModel) { self.vm = vm }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                WalkItCountView(leftTitle: "걸음 수", rightTitle: "산책 시간", avgSteps: $vm.steps, walkTime: $vm.elapsedTime)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("목표 진행률")
                        .figmaText(fontSize: 18, weight: .semibold)
                        .padding(.bottom, 4)
                    
                    if(vm.updateGoalsPercent > 0) {
                        Text("오늘 산책으로 목표에 \(vm.updateGoalsPercent)% 가까워졌어요!")
                            .figmaText(fontSize: 14, weight: .medium)
                            .foregroundStyle(Color("CustomBlue2"))
                            .padding(.bottom, 12)
                    }
                    
                    GradientLinearSpinner(
                        progress: vm.goalCountPercent,
                        height: 15,
                        firstColor: Color("CustomGreen2"),
                        lastColor: Color("CustomGreen3"),
                        backgroundColor: Color("CustomLightGray3")
                    )
                }
                .padding(16)
                .background { Color(.white) }
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .padding(.bottom, 16)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("감정 기록")
                            .figmaText(fontSize: 14, weight: .medium)
                        
                        Spacer()
                        
                        Button {
                            vm.showingEditMenu.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.black)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .padding(.bottom, 12)
                    
                    HStack(spacing: 8) {
                        Image("\(vm.emotionBeforeWalk)Circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Image("\(vm.emotionAfterWalk)Circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.bottom, 12)
                    
                    if(!vm.note.isEmpty || vm.isTextEditor) {
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
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
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
                                        .frame(width: 15, height: 15)
                                    
                                    Text("수정하기")
                                        .figmaText(fontSize: 14, weight: .regular)
                                        .foregroundStyle(Color("CustomGreen2"))
                                }
                                .padding(10)
                                .padding(.trailing, 40)
                                .background(Color("CustomMint"))
                            }
                            
                            Button {
                                vm.note = ""
                                vm.isTextEditor = false
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
                .padding(.bottom, 16)
                
                Spacer()
                
                VStack {
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            OutlineActionButton(title: "이전으로") {
                                vm.walkRecordGoPrev()
                            }
                            .frame(width: geo.size.width / 3.5)
                            .padding(.trailing, 9)
                            
                            Button(action: {
                                Task {
                                    vm.showSavingProgress = true
                                    if(vm.savedImage == nil) {
                                        vm.captureMapImage()
                                    } else {
                                        let result = await vm.saveWalk()
                                        if(result) { vm.showSavingSuccess = true }
                                        vm.showSavingProgress = false
                                    }
                                }
                            }, label: {
                                HStack {
                                    Text("저장하기")
                                        .figmaText(fontSize: 16, weight: .semibold)
                                        .foregroundStyle(Color(.white))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background { Color("CustomGreen2") }
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            })
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.top, 20)
            .padding(.horizontal, 16)
            .background(Color("CustomLightGray4"))
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    CheckRecordingView(vm: WalkViewModel())
}

