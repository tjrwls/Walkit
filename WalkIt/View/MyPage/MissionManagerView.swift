//
//  MissionManagerView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct MissionManagerView: View {
    @ObservedObject var vm: MissionManagerViewModel
    @Binding var path: NavigationPath
    init(vm: MissionManagerViewModel, path: Binding<NavigationPath>) {
        self.vm = vm
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    banner
                        .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 8.5) {
                        Text("오늘의 미션")
                            .figmaText(fontSize: 20, weight: .semibold)
                            .foregroundStyle(Color("CustomBlack"))
                        
                        Text("미션은 한 주에 최대 1개씩 수행할 수 있어요")
                            .figmaText(fontSize: 14, weight: .regular)
                            .foregroundStyle(Color("CustomGray"))
                            .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 16)
                    
                    categoryChips
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    
                    VStack(spacing: 8) {
                        if let weeklyMission = vm.weeklyMission {
                            if(weeklyMission.active.type == vm.selected.rawValue) {
                                MissionCard(mission: weeklyMission.active, borderGray: false, action: {
                                    Task {
                                        let result = await vm.postVerifyMission(missionId: weeklyMission.active.userWeeklyMissionId ?? 0)
                                        if(result) { await vm.getWeeklyMission() }
                                    }
                                })
                                .padding(.horizontal, 20)
                            }
                            
                            ForEach(weeklyMission.others, id: \.self.missionId) { mission in
                                if(mission.type == vm.selected.rawValue) {
                                    MissionCard(mission: mission, borderGray: false, action: {})
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .onAppear {
            vm.loadView()
        }
    }
}

// MARK: - Subviews
private extension MissionManagerView {
    var topBar: some View {
        HStack {
            Button {
                path = NavigationPath()
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
            
            Text("미션")
                .figmaText(fontSize: 20, weight: .semibold)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
                .padding(.trailing, 19)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    var banner: some View {
        VStack {
            Image("MissionBanner")
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity)
    }
    
    var categoryChips: some View {
        HStack(spacing: 4) {
            ForEach(MissionType.allCases) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        vm.selected = type
                    }
                } label: {
                    Text(getTypeKOR(type))
                        .figmaText(fontSize: 14, weight: .medium)
                        .foregroundStyle(vm.selected == type ? Color("CustomGreen") : Color("CustomLightGray2"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background (
                            Capsule()
                                .stroke(vm.selected == type ? Color("CustomGreen") : Color("CustomLightGray2"), lineWidth: 1)
                                .background {
                                    if(vm.selected == type) {
                                        Capsule()
                                            .fill(Color("CustomGreen7"))
                                    }
                                })
                }
            }
            Spacer()
        }
    }
    func getTypeKOR(_ categoty: MissionType) -> String {
        switch(categoty) {
        case .steps: "걸음 수"
        case .attendance: "연속 출석"
        }
    }
}

#Preview {
    MissionManagerView(vm: MissionManagerViewModel(), path: .constant(NavigationPath()))
}
