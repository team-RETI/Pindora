//
//  ReviewContentView.swift
//  Pindora
//
//  Created by eunchanKim on 10/27/25.
//

import SwiftUI

struct ReviewContentView: View {
    @State private var value: Double = 0.0
    var onContinue: (() -> Void)?
    var onClose: (() -> Void)?
    
    private var mood: Mood { Mood(progress: value)}
    var body: some View {
        NavigationStack {
            ZStack {
                mood.background
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("How was your day?")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.black)
                    
                    Text(mood.subtitle)
                        .font(.largeTitle)
                        .bold()
                    
                    FaceView(progress: value)
                        .frame(width: 160, height: 160)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
                    
                    Spacer()
                        .frame(height: 48)
                    
                    Slider(value: $value, in: 0...1, step: 0.25)
                        .tint(mood.accent)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose?()
                    } label: {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Track Mood").font(.title).bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onContinue?()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension Color {
    /// Linear-interpolate two Colors (sRGB)
    static func lerp(from: Color, to: Color, t: Double) -> Color {
        let (r1, g1, b1, a1) = from.components
        let (r2, g2, b2, a2) = to.components
        
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            opacity: a1 + (a2 - a1) * t
        )
    }
    
    var components: (Double, Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

struct FaceView: View {
    let progress: Double
    private var smile: Double { progress * 2 - 1 }
    var body: some View {
        ZStack {
            // Eye
            HStack(spacing: 52) {
                EyeView(pupilOffet: eyePupilOffset)
                EyeView(pupilOffet: eyePupilOffset)
            }
            .offset(y: -20)
            
            // Eyebrow
            HStack(spacing: 60) {
                EyebrowView(angle: eyebrowAngle, mirrored: true)
                EyebrowView(angle: eyebrowAngle, mirrored: false)
            }
            .offset(y: -70)
            
            // Mouth
            MouthShape(smileAmount: smile)
                .stroke(lineWidth: 10)
                .foregroundStyle(.black)
                .frame(width: 120, height: 80)
                .offset(y: 40)
                .shadow(radius: 2, y: 2)
        }
    }
    
    private var eyePupilOffset: CGSize {
        // map 0...1 -> -6...6 horizontally: small vertical jiggle
        let x = (progress - 0.5) * 12
        let y = (0.5 - abs(progress - 0.5)) * 4
        return CGSize(width: x, height: y)
    }
    
    private var eyebrowAngle: Angle {
        Angle(degrees: 25 - 50 * progress)
    }
}

struct EyeView: View {
    var pupilOffet: CGSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 46, height: 46)
                .shadow(radius: 3, y: 2)
            
            Circle()
                .fill(.black)
                .frame(width: 18, height: 18)
                .offset(pupilOffet)
        }
    }
}

struct EyebrowView: View {
    var angle: Angle
    var mirrored: Bool
    
    var body: some View {
        Capsule()
            .fill(.black)
            .frame(width: 54, height: 12)
            .rotationEffect(mirrored ? angle * -1 : angle)
            .shadow(radius: 2, y: 2)
        
    }
}

struct MouthShape: Shape, Sendable {
    var smileAmount: Double
    
    // 1. Animation requirement - mark it non-isolated
    nonisolated var animatableData: Double {
        get { smileAmount }
        set { smileAmount = newValue }
    }
    
    // 2. Shape requirement - mark it non-isolated
    nonisolated func path(in rect: CGRect) -> Path {
        var p = Path()
        let midX = rect.midX
        let y = rect.midY
        let curve = CGFloat(smileAmount) * rect.height * 0.6
        
        p.move(to: CGPoint(x: rect.minX, y: y))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: y), control: CGPoint(x: midX, y: y - curve))
        
        return p
    }
}

struct Mood {
    let progress: Double
    
    var subtitle: String {
        switch progress {
        case 0..<0.25: return "Awesome"
        case 0.25..<0.5: return "Great"
        case 0.5..<0.75: return "Okay"
        default: return "Not so good"
        }
    }
    
    var background: Color {
        switch progress {
        case 0..<0.25: return Color(red: 1.00, green: 0.65, blue: 0.30)
        case 0.25..<0.5: return Color(red: 0.40, green: 0.25, blue: 0.85)
        case 0.5..<0.75: return Color(red: 0.45, green: 0.65, blue: 0.85)
        default: return Color(red: 0.85, green: 0.27, blue: 0.27)
        }
    }
    
    var accent: Color { .white.opacity(0.9) }
}
