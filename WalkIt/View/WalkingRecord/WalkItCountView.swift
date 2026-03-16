//
//  WalkCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/14/25.
//

import SwiftUI
import CoreLocation

struct WalkItCountView: View {
    var leftTitle: String
    var rightTitle: String
    @Binding var avgSteps: Int
    @Binding var walkTime: Int
    var walkHours: String { String(walkTime / 3_600_000) }
    var walkMinute: String { String((walkTime % 3_600_000) / 60_000) }
    var body: some View {
        HStack(spacing: 0) {
            StatTile(title: leftTitle, value: "\(avgSteps.formatted())", unit: "걸음")
            
            Divider()
                .frame(width: 1, height: 56)
            
            TimeTile(title: rightTitle, time: walkHours, minute: walkMinute)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private struct StatTile: View {
        let title: String
        let value: String
        let unit: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .figmaText(fontSize: 14, weight: .regular)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 2)
                HStack {
                    Text(walkCount)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                    
                    Spacer()
                    Text("걸음")
                        .figmaText(fontSize: 16, weight: .regular)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        var walkCount: AttributedString {
            var h = AttributedString(value)
            h.font = .system(size: 22, weight: .medium)
            h.tracking = -0.22

            return h
        }
    }
    
    private struct TimeTile: View {
        let title: String
        let time: String
        let minute: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .figmaText(fontSize: 14, weight: .regular)
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 2)
                
                Text(timeText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        var timeText: AttributedString {
            var result = AttributedString()

            var h = AttributedString(time)
            h.font = .system(size: 22, weight: .medium)
            h.tracking = -0.22
            
            var t = AttributedString("시간")
            t.font = .system(size: 16, weight: .regular)
            t.tracking = -0.16

            var m = AttributedString(minute)
            m.font = .system(size: 22, weight: .medium)
            m.tracking = -0.22

            var min = AttributedString("분")
            min.font = .system(size: 16)
            min.tracking = -0.16
            
            var space = AttributedString(" ")
            space.tracking = 4
            
            result += (h + space)
            result += (t + space + space)
            result += (m + space)
            result += min

            return result
        }
    }
    
    
}

#Preview {
    WalkItCountView(leftTitle: "", rightTitle: "", avgSteps: .constant(8000), walkTime: .constant(123124214123123))
}
