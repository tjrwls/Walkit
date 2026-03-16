//
//  CharacterItemsView.swift
//  WalkIt
//
//  Created by 조석진 on 1/14/26.
//
import SwiftUI
import Kingfisher

struct CharacterItemsView: View {
    @ObservedObject var vm: DressingRoomViewModel
    @Binding var selection: TabType
    let moveToMedium: () -> Void
    
    init(vm: DressingRoomViewModel, selection: Binding<TabType>, moveToMedium: @escaping () -> Void) {
        self.vm = vm
        self._selection = selection
        self.moveToMedium = moveToMedium
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text("아이템 목록")
                        .figmaText(fontSize: 20, weight: .semibold)
                        .foregroundStyle(Color("CustomBlack"))
                    
                    Spacer()
                    
                    Text("보유한 아이템만 보기")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                    
                    Toggle("", isOn: $vm.isShowOwnedItem)
                        .labelsHidden()
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { vm.selectedItemPart = nil }
                        } label: {
                            HStack(spacing: 8) {
                                Text("전체")
                                    .font(.headline)
                                    .foregroundStyle(vm.selectedItemPart == nil ? Color(.systemGreen) : .primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(vm.selectedItemPart == nil ? Color("CustoMint") : Color(.white))
                                    .stroke(vm.selectedItemPart == nil ? Color("CustomGreen") : Color("CustomLightGray2"), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(ItemPart.allCases) { item in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    vm.selectedItemPart = item
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(vm.getItemPart(itemPart: item))
                                        .font(.headline)
                                        .foregroundStyle(vm.selectedItemPart == item ? Color(.systemGreen) : .primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(vm.selectedItemPart == item ? Color("CustoMint") : Color(.white))
                                        .stroke(vm.selectedItemPart == item ? Color("CustomGreen") : Color("CustomLightGray2"), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
            ScrollView {
                if(vm.isShowOwnedItem) {
                    let ownedItems = vm.items.filter{ $0.owned == true && (vm.selectedItemPart == nil || vm.selectedItemPart?.rawValue == $0.position.rawValue) }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                        ForEach(ownedItems.indices, id: \.self) { idx in
                            itemCard(item: ownedItems[idx])
                                .onTapGesture {
                                    debugPrint("selecItem")
                                    vm.selecItem(item: ownedItems[idx])
                                    moveToMedium()
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                } else {
                    let items = vm.items.filter{ vm.selectedItemPart == nil || vm.selectedItemPart?.rawValue == $0.position.rawValue }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                        ForEach(items.indices, id: \.self) { idx in
                            itemCard(item: items[idx])
                                .onTapGesture {
                                    debugPrint("selecItem")
                                    vm.selecItem(item: items[idx])
                                    moveToMedium()
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                Color.clear.frame(height: 350)
            }
        }
        .background(content: {
            TopRoundedShape(radius: 28)
                .fill(Color(.systemBackground))
        })
        .clipShape(TopRoundedShape(radius: 28))
        .toast(isPresented: $vm.showBuyToast) {
            HStack(alignment: .top) {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color(.white))
                VStack {
                    Text("아이템 구매가 완료되었습니다")
                        .font(.system(size: 16)).bold()
                        .foregroundStyle(Color(.white))

                    Text("보유한 아이템만 보기에서 확인하실 수 있습니다")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.white))
                }
            }
        }
        .toast(isPresented: $vm.showSaveToast) {
            HStack(alignment: .top) {
                Image(systemName: "checkmark")
                    .font(.body).bold()
                    .foregroundStyle(Color(.white))
                VStack {
                    Text("저장되었습니다")
                        .font(.body).bold()
                        .foregroundStyle(Color(.white))
                }
                Spacer()
            }
        }
    }
    
    func itemCard(item: CosmeticItem) -> some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(.white))
                    .stroke(Color("CustomLightGray"))
                KFImage(URL(string: item.imageName))
                    .placeholder { ProgressView() }
                    .retry(maxCount: 3)
                    .resizable()
                    .cacheOriginalImage()
                    .scaledToFit()
                    .padding(10)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
            
            let style = vm.categoryStyle(for: item.position)
            Text(style.text)
                .foregroundStyle(style.foreground)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(style.background))
            
            HStack {
                Text("P")
                    .font(.body)
                    .foregroundStyle(Color("CustomDarkYellow"))
                    .padding(5)
                    .background(
                        Circle()
                            .fill(Color("CustomLightYellow"))
                    )
                Text("\(item.point)")
                    .font(.body)
                    .foregroundStyle(Color("CustomBlack"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(vm.isWearingItem(item: item) ? Color("CustoMint") : Color(.white))
                    .stroke(vm.isWearingItem(item: item) ? Color("CustomGreen2") : Color("CustomLightGray"), lineWidth: 1)
                if(item.owned) {
                    MyCardShape()
                        .fill(vm.isWearingItem(item: item) ? Color("CustomGreen2") : Color("CustomLightGray3"))
                        .frame(width: 30, height: 40)
                    
                    Text("MY")
                        .font(.system(size: 12))
                        .foregroundStyle(vm.isWearingItem(item: item) ? Color(.white) : Color("CustomLightGray2"))
                        .frame(width: 30, height: 40)
                }
            }
        )
    }
}
