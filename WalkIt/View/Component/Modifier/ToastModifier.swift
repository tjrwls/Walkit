//
//  ToastModifier.swift
//  WalkIt
//
//  Created by 조석진 on 1/14/26.
//

import SwiftUI


struct ToastModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let duration: TimeInterval
    let toastContent: () -> ToastContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    toastContent()
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CustomGray2"))
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 100)
                }
                .animation(.easeOut(duration: 0.25), value: isPresented)
                .task(id: isPresented) {
                    guard isPresented else { return }
                    
                    try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    
                    await MainActor.run {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
