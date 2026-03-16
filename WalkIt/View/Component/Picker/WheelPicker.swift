//
//  PickerBottomSheet.swift
//  WalkIt
//
//  Created by 조석진 on 12/14/25.
//

import SwiftUI

struct WheelPicker: View {
    @Binding var selectedItem: String
    @Binding var showSheet: Bool
    let items: Array<String>
    
    var body: some View {
        VStack {
            HStack {
                Button("취소") {
                    showSheet = false
                }
                Spacer()
                Button("완료") {
                    showSheet = false
                }
            }
            .padding()
            
            Picker("", selection: $selectedItem) {
                ForEach(items, id: \.self) { value in
                    Text(value)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}


#Preview {
    WheelPicker(selectedItem: .constant(""), showSheet: .constant(true), items: ["달", "주"])
}
