//
//  WalkCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/14/25.
//

import SwiftUI
import CoreLocation
import KakaoMapsSDK
import Kingfisher

struct WalkCard: View {
    let walk: WalkRecordEntity
    var dateText: String {
        let date = Date(timeIntervalSince1970: Double(walk.startTime / 1000))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    var walkHours: String { String(walk.totalTime / 3_600_000) }
    var walkMinute: String { String((walk.totalTime % 3_600_000) / 60_000) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if(walk.imageUrl != "") {
                    if let imageURL = walk.imageUrl {
                        KFImage(URL(string: imageURL))
                            .placeholder { ProgressView() }
                            .retry(maxCount: 3)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 229, height: 229)
                            .padding(.top, 1)
                    }
                } else {
                    Color.clear.frame(width: 229, height: 229)
                }
                
                Divider()
                    .foregroundStyle(Color("CustomLightGray"))
                
                VStack(spacing: 0) {
                    HStack {
                        Text(dateText)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color("CustomGray"))
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        HStack(alignment: .firstTextBaseline) {
                            (
                            Text(walk.stepCount.formatted())
                                .font(.system(size: 18, weight: .medium))
                            + Text("걸음")
                                .font(.system(size: 14, weight: .regular))
                            )
                            .lineLimit(1)
                            .layoutPriority(1)
                            .minimumScaleFactor(0.9)
                            .foregroundStyle(Color("CustomBlack"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                            .padding(.vertical, 4.5)
                            .foregroundStyle(Color("CustomLightGray5"))
                        
                        HStack(alignment: .firstTextBaseline) {
                            if(walkHours != "0") {
                                (
                                    Text(walkHours)
                                        .font(.system(size: 18, weight: .medium))
                                    + Text("시간 ")
                                        .font(.system(size: 14, weight: .regular))
                                    + Text(walkMinute)
                                        .font(.system(size: 18, weight: .medium))
                                    + Text("분")
                                        .font(.system(size: 14, weight: .regular))
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                .layoutPriority(1)
                                .foregroundStyle(Color("CustomBlack"))
                                
                            } else {
                                (
                                    Text(walkMinute)
                                        .font(.system(size: 20))
                                    + Text("분")
                                        .font(.system(size: 14))
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 17)
                .padding(.horizontal, 16)
                .background(Color(.white))
            }
            Image("\(walk.postWalkEmotion ?? "")Circle")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .padding(.bottom, 55)
                .padding(.trailing, 10)
        }
        .frame(width: 230, height: 290)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("CustomLightGray5"), lineWidth: 1)   
        }
    }
}

#Preview {
    WalkCard(walk: WalkRecordEntity())
}
