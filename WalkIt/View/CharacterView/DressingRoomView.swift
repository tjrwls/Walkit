//
//  CharacterView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI
import Kingfisher

struct DressingRoomView: View {
    @ObservedObject var vm: DressingRoomViewModel
    @Binding var selection: TabType
    @State var detent: PresentationDetent = .medium
    @State private var currentY: CGFloat? = nil
    @GestureState private var dragOffset: CGFloat = 0
    
    init(vm: DressingRoomViewModel, selection: Binding<TabType>) {
        self.vm = vm
        self._selection = selection
    }
    
    var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height
            let largeY: CGFloat = 80
            let mediumY: CGFloat = screenHeight * 0.52
            
            ZStack(alignment: .top) {
                VStack {
                    characterCard
                    Spacer()
                }
                
                CharacterItemsView(
                    vm: vm,
                    selection: $selection,
                    moveToMedium: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            currentY = mediumY
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight - largeY)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.background)
                        .shadow(radius: 8)
                )
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color("CustomLightGray5"))
                        .frame(width: 60, height: 4)
                        .padding(.top, 16)
                }
                .offset(y: displayedY(mediumY: mediumY, largeY: largeY))
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: currentY)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            let base = currentY ?? mediumY
                            let next = base + value.translation.height
                            state = clamped(next, min: largeY, max: mediumY) - base
                        }
                        .onEnded { value in
                            let base = currentY ?? mediumY
                            let endY = clamped(base + value.translation.height, min: largeY, max: mediumY)
                            
                            let target: CGFloat
                            let mid = (mediumY + largeY) / 2
                            
                            if endY < mid {
                                target = largeY
                            } else {
                                target = mediumY
                            }
                            
                            currentY = target
                        }
                )
                
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            Task { @MainActor in
                                vm.lottieJson = await vm.removeAllItem(json: vm.lottieJson)
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("CustomGreen2"))
                                .frame(width: 24, height: 24)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 11)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomGreen2"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task { @MainActor in
                                await vm.saveItem()
                            }
                        } label: {
                            Text("저장하기")
                                .font(.headline)
                                .foregroundStyle(vm.isChangedItem() ? Color(.white) : Color("CustomGray"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(vm.isChangedItem() ? Color("CustomGreen2") : Color("CustomLightGray"))
                                )
                        }
                        .disabled(!vm.isChangedItem())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Color(.white)
                            .shadow(color:Color(hex: "#000000", alpha: 0.05), radius: 2, y: -10)
                    )
                }
                
                if(vm.isShowBuy) {
                    ZStack {
                        Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                            .onTapGesture {
                                vm.isShowBuy = false
                            }
                        VStack {
                            Spacer()
                            VStack {
                                HStack {
                                    Text("구매할 아이템을 확인해주세요!")
                                        .font(.title2)
                                        .foregroundStyle(Color("CustomBlack"))
                                    
                                    Spacer()
                                    
                                    Button {
                                        vm.isShowBuy = false
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.title2).bold()
                                            .foregroundStyle(Color("CustomBlack"))
                                    }
                                }
                                
                                HStack {
                                    Text("보유 포인트")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color("CustomGray"))
                                    Spacer()
                                    Text("\(vm.point)P")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color("CustomGray"))
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomLightGray"))
                                )
                                .padding(.vertical)
                                
                                ForEach(vm.getBuyItems, id: \.self) { item in
                                    let style = vm.categoryStyle(for: item.position)
                                    HStack {
                                        Image(systemName: vm.buyItems.contains(item) ? "checkmark.square.fill" : "rectangle")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(vm.buyItems.contains(item) ? .green : .gray)
                                            .onTapGesture {
                                                if let index = vm.buyItems.firstIndex(of: item) {
                                                    vm.buyItems.remove(at: index)
                                                } else {
                                                    vm.buyItems.append(item)
                                                }
                                            }
                                        Text(style.text)
                                            .foregroundStyle(style.foreground)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(style.background))
                                        Text(item.name)
                                        Spacer()
                                        Text(String(item.point) + "P").font(.body).bold()
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 20)
                                
                                HStack {
                                    Text("총 사용 포인트")
                                    Spacer()
                                    Text(String(-vm.sumPoints))
                                        .font(.title2).bold()
                                        .foregroundStyle(Color("CustomRed"))
                                }
                                .padding(.bottom, 20)
                                
                                if(!vm.canBuy) {
                                    HStack {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(Color("CustomRed"))
                                        Text(vm.buyItems.isEmpty ? "구매할 아이템이 없습니다.." : "보유 포인트를 초과해 구매가 어렵습니다.")
                                            .foregroundStyle(Color("CustomRed"))
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("CustomLightPink"))
                                            .stroke(Color("CustomPink"), lineWidth: 1)
                                    )
                                }
                                
                                Button {
                                    Task { @MainActor in
                                        await vm.buyItems()
                                        await vm.getPoint()
                                    }
                                } label: {
                                    HStack {
                                        Text("구매하기")
                                            .foregroundStyle(vm.canBuy && (!vm.buyItems.isEmpty) ? Color(.white) : Color("CustomGray"))
                                            .font(.system(size: 18))
                                        if(vm.canBuy) {
                                            Text(String(vm.buyItems.count))
                                                .font(.system(size: 12))
                                                .padding(6)
                                                .foregroundStyle(Color("CustomGreen3"))
                                                .background(Circle().fill(Color(.white)))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(vm.canBuy && (!vm.buyItems.isEmpty) ? Color("CustomGreen2") : Color("CustomLightGray"))
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(!vm.canBuy || vm.buyItems.isEmpty)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.white))
                            )
                            .padding(20)
                        }
                    }
                }
                
                if(vm.isShowInfo) {
                    ZStack {
                        Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                            .onTapGesture {
                                vm.isShowInfo = false
                            }
                        VStack(spacing: 20) {
                            HStack {
                                Text("캐릭터 레벨")
                                    .font(.title).bold()
                                Spacer()
                                
                                Button {
                                    vm.isShowInfo = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.title).bold()
                                        .foregroundStyle(Color("CustomBlack"))
                                }
                            }
                            HStack {
                                VStack {
                                    Image("SeedInfo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                    Text("씨앗")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color("CustomBlue"))
                                        .capsuleTagStyle(backgroundColor: Color("CustomLightBlue"))
                                        .frame(height: 30)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomLightGray"), lineWidth: 1)
                                )
                                .frame(width: 100, height: 140)
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Lv.01").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 1주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.02").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 4주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.02").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 6주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Spacer()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomLightGray3"))
                                )
                            }
                            .frame(maxHeight: 140)
                            
                            HStack {
                                VStack {
                                    Image("SproutInfo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                    
                                    Text("새싹")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color("CustomBlue"))
                                        .capsuleTagStyle(backgroundColor: Color("CustomLightBlue"))
                                        .frame(height: 30)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomLightGray"), lineWidth: 1)
                                )
                                .frame(width: 100, height: 140)
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Lv.04").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 8주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.05").bold().font(.system(size: 14))
                                        Text("누적 주간 목표 10주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.06").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 2주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.07").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 4주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Spacer()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomLightGray3"))
                                )
                                
                            }
                            .frame(maxHeight: 140)
                            Text("* 새싹 Lv.06부터 레벨업 달성 시 이전 기록이 초기화 됩니다")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("CustomLightGray2"))
                                .padding(.top, 0)
                            
                            HStack {
                                VStack {
                                    Image("TreeInfo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                    Text("나무")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color("CustomBlue"))
                                        .capsuleTagStyle(backgroundColor: Color("CustomLightBlue"))
                                        .frame(height: 30)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomLightGray"), lineWidth: 1)
                                )
                                .frame(width: 100, height: 140)
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Lv.08").font(.system(size: 14)).bold()
                                        Text("누적 주간 목표 6주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.09").bold().font(.system(size: 14))
                                        Text("누적 주간 목표 8주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Divider()
                                    HStack {
                                        Text("Lv.10").bold().font(.system(size: 14))
                                        Text("누적 주간 목표 10주 달성").font(.system(size: 12))
                                    }
                                    .frame(maxHeight: .infinity)
                                    Spacer()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomLightGray3"))
                                )
                            }
                            .frame(maxHeight: 140)
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.white))
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            if !vm.didLoad {
                vm.loadView()
            }
        }
        .ignoresSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private func displayedY(mediumY: CGFloat, largeY: CGFloat) -> CGFloat {
        let base = currentY ?? mediumY
        return clamped(base + dragOffset, min: largeY, max: mediumY)
    }
    
    private func clamped(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }
    
    private func currentDetent(currentY: CGFloat, mediumY: CGFloat, largeY: CGFloat) -> PresentationDetent {
        let mid = (mediumY + largeY) / 2
        return currentY < mid ? .large : .medium
    }
}

// MARK: - Subviews
private extension DressingRoomView {
    var characterCard: some View {
        ZStack(alignment: .center) {
            if let backgroundImage = vm.character.backgroundImageName {
                KFImage(URL(string: backgroundImage))
                    .retry(maxCount: 3)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
            } else {
                Image("BackGround")
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
            }
            
            if(!vm.lottieJson.isEmpty) {
                LottieCharacterView(json: vm.lottieJson)
                    .frame(width: UIScreen.main.bounds.width * 0.48)
                    .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
            }
            
            VStack {
                HStack(spacing: 12) {
                    HStack {
                        Text("P")
                            .font(.body)
                            .foregroundStyle(Color("CustomDarkYellow"))
                            .padding(5)
                            .background(Circle().fill(Color("CustomLightYellow"))
                            )
                        Text("\(vm.point)")
                            .font(.body)
                            .foregroundStyle(Color("CustomBlack"))
                    }
                    
                    Spacer()
                    Text("Lv.\(vm.character.level) \(vm.getGrade(grade: vm.character.grade))")
                        .font(.system(size: 14)).bold()
                        .foregroundStyle(Color("CustomBlue"))
                        .capsuleTagStyle(backgroundColor: Color("CustomLightBlue"))
                    
                    Spacer()
                    
                    Button {
                        vm.isShowInfo = true
                    } label : {
                        Image(systemName: "questionmark")
                            .foregroundStyle(Color(.white))
                            .padding(5)
                            .background(Circle().fill(Color("CustomBlack")))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
    }
}


#Preview {
    DressingRoomView(vm: DressingRoomViewModel(), selection: .constant(.CHARACTER))
}
