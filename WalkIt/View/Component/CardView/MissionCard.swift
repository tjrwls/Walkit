//
//  MissionCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let borderGray: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundColor)
                .shadow(
                    color: Color.black.opacity(0.06), radius: 10, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text(categoryText)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Capsule().fill(categoryBackgroundColor))
                            .foregroundStyle(categoryColor)
                        
                        if(mission.status == .inProgress || mission.status == .completed) {
                            Text(monthWeekString(from: Int(mission.weekStart) ?? 0))
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color("CustomPurple3")))
                                .foregroundStyle(Color("CustomPurple"))
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Text(mission.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(titleColor)
                        .padding(.bottom, 4)
                    
                    Text("\(mission.rewardPoints) P")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(expColor)
                }
                
                Spacer()
                
                rightButton
                    .disabled(mission.status != .inProgress)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var rightButton: some View {
        let missions = [0, 3, 5, 7, 5000, 20000, 30000, 50000, 100000]
        var status = false
        switch mission.status {
        case .inProgress:
            if(mission.type == MissionType.steps.rawValue) {
                if(missions.count < mission.missionId) {
                    status = RealmManager.shared.hasContinuousAttendanceThisWeek(requiredDays: missions[mission.missionId])
                }
            } else {
                if(missions.count < mission.missionId) {
                    status = RealmManager.shared.hasExceededWeeklySteps(targetSteps: missions[mission.missionId])
                }
            }
            if(status) {
                return Button(action: action, label: {
                    Text("보상받기")
                        .font(.headline)
                        .foregroundStyle(buttonTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                        )
                })
            } else {
                return Button(action: action, label: {
                    Text("도전하기")
                        .font(.headline)
                        .foregroundStyle(buttonTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                        )
                })
            }
        case .completed:
            return Button(action: action, label: {
                Text("완료")
                    .font(.headline)
                    .foregroundStyle(buttonTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                    )
            })
        default:
            return Button(action: action, label: {
                Text("도전하기")
                    .font(.headline)
                    .foregroundStyle(buttonTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                    )
            })

        }
    }
    
    private var backgroundColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(.white)
        case .completed:
            return Color(.white)
        default:
            return Color("CustomLightGray3")
        }
    }
    
    private var buttonTextColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(.white)
        case .completed:
            return Color("CustomGray")
        default:
            return Color("CustomGray")
        }
    }
    
    private var borderColor: Color {
        if(borderGray) { return Color("CustomLightGray") }
        switch mission.status {
        case .inProgress:
            return Color("CustomBlack")
        case .completed:
            return Color("CustomBlack")
        default:
            return Color("CustomLightGray")
        }
    }
    
    private var titleColor: Color {
        switch mission.status {
        case .inProgress:
            return Color("CustomBlack")
        case .completed:
            return Color("CustomBlack")
        default:
            return Color("CustomGray")
        }
    }
    
    private var expColor: Color {
        switch mission.status {
        case .inProgress:
            return Color("CustomGreen")
        case .completed:
            return Color("CustomGreen")
        default:
            return Color("CustomLightGray2")
        }
    }
    
    private var buttonColor: Color {
        switch mission.status {
        case .inProgress:
            return Color("CustomBlack")
        case .completed:
            return Color("CustomLightGray")
        default:
            return Color("CustomLightGray")
        }
    }
    
    private var categoryText: String {
        switch mission.type {
        case "CHALLENGE_STEPS": "걸음 수"
        case "CHALLENGE_ATTENDANCE": "연속 출석"
        default: "걸음 수"
        }
    }
    
    private var categoryColor: Color {
        switch mission.status {
        case .inProgress:
            return Color("CustomBlue2")
        case .completed:
            return Color("CustomBlue2")
        default:
            return Color("CustomGray")
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch mission.status {
        case .inProgress:
            return Color("CustomBlue4")
        case .completed:
            return Color("CustomBlue4")
        default:
            return Color("CustomLightGray")
        }
    }
    
    func monthWeekString(from unixTimeMillis: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimeMillis) / 1000)

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1

        let month = calendar.component(.month, from: date)
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

        let weekOfYearForDate = calendar.component(.weekOfYear, from: date)
        let weekOfYearForFirstDay = calendar.component(.weekOfYear, from: firstDayOfMonth)

        let weekOfMonth = weekOfYearForDate - weekOfYearForFirstDay + 1

        return String(format: "%d월 %d주차", month, weekOfMonth)
    }

}

