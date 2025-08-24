//
//  Preview.swift
//  Pindora
//
//  Created by 김동현 on 8/13/25.
//

import SwiftUI

#if DEBUG
extension UIView {
    private struct ViewRepresentable: UIViewRepresentable {
        let uiView: UIView
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            
        }
        
        func makeUIView(context: Context) -> some UIView {
            return uiView
        }
    }
    
    func getPreview() -> some View {
        ViewRepresentable(uiView: self)
    }
}
#endif
