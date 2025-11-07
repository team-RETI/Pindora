//
//  ReviewContentView.swift
//  Pindora
//
//  Created by eunchanKim on 10/27/25.
//

import SwiftUI

enum ReviewMode: Equatable {
    case create                          // 새 리뷰 작성
    case view(existing: ReviewPayload)   // 기존 리뷰 보기
}

struct ReviewContentView: View {
    // MARK: - Input
    let mode: ReviewMode
    
    // MARK: - State (편집 공통 상태)
    @State private var value: Double = 0.0            // 0...1
    @State private var title: String = ""
    @State private var context: String = ""
    @State private var rating: Int?
    
    // UI 상태
    @State private var showCommentField: Bool = false
    @FocusState private var isCommentFocused: Bool
    @State private var isEditingExisting: Bool = false
    
    // MARK: - Callbacks
    var onSave: ((ReviewPayload) -> Void)?     // 생성 완료 또는 수정 완료
    var onDelete: ((ReviewPayload) -> Void)?   // 기존 리뷰 삭제
    var onClose: (() -> Void)?
    
    // Mood 계산은 slider value 기반
    private var mood: Mood { Mood(progress: value)}
    // 현재 작업 중인 payload 스냅샷
    private var currentPayload: ReviewPayload {
        ReviewPayload(rating: Int(value * 10), title: title, context: context)
    }
    
    // MARK: - Initializer
    init(
        mode: ReviewMode,
        onSave: ((ReviewPayload) -> Void)? = nil,
        onDelete: ((ReviewPayload) -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
        self.onClose = onClose
        // @State는 init에서 직접 설정 불가 → _프로퍼티 래퍼 사용
        switch mode {
        case .create:
            _value = State(initialValue: 0.0)
            _title = State(initialValue: "")
            _context = State(initialValue: "")
            _showCommentField = State(initialValue: false)
        case .view(let existing):
            _value = State(initialValue: Double(existing.rating) / 10.0)
            _title = State(initialValue: existing.title)
            _context = State(initialValue: existing.context)
            _showCommentField = State(initialValue: !existing.context.isEmpty) // 내용이 있으면 기본 노출
        }
    }
    
    // 모드/편집에 따른 UI 가드
    private var isCreate: Bool {
        if case .create = mode { return true }
        return false
    }
    private var showSlider: Bool {
        // 요구사항: "리뷰가 있을 땐 슬라이더 숨김"
        // 단, 편집 버튼을 눌러 편집 중일 땐 슬라이더 노출
        return isCreate || isEditingExisting
    }
    
    // MARK: - UI
    var body: some View {
        NavigationStack {
            ZStack {
                mood.background
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("이장소를 다녀온 소감은 어떠신가요?")
                        .font(.title2)
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
                    
                    // 슬라이더: 생성이거나 편집 중일 때만 보이도록
                    if showSlider {
                        Slider(value: $value, in: 0...1, step: 0.25)
                            .tint(mood.accent)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // 코멘트 영역: 생성/보기 공통
                    if showCommentField || !context.isEmpty || !isCreate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("한줄 코멘트")
                                .font(.subheadline).bold()
                                .foregroundStyle(.black.opacity(0.8))
                            
                            if isCreate || isEditingExisting {
                                // 편집 가능
                                TextField("예) 분위기가 정말 좋아요!", text: $context, axis: .vertical)
                                    .focused($isCommentFocused)
                                    .textInputAutocapitalization(.sentences)
                                    .disableAutocorrection(false)
                                    .lineLimit(1...3)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12).fill(Color.white)
                                    )
                                    .foregroundColor(.black)
                            } else {
                                // 읽기 전용 표시
                                if context.isEmpty {
                                    Text("작성된 코멘트가 없어요.")
                                        .foregroundStyle(.black.opacity(0.4))
                                } else {
                                    Text(context)
                                        .foregroundStyle(.black)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                    
                    Spacer()
                    // 하단 버튼
                    if isCreate || isEditingExisting {
                        Button {
                            onSave?(currentPayload)
                        } label: {
                            Text(isCreate ? "확인 및 등록" : "수정 완료")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 40)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showCommentField)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isEditingExisting)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showSlider)
            }
            .toolbar {
                // 이전화면
                ToolbarItem(placement: .topBarLeading) {
                    Button { onClose?() } label: {
                        Image(systemName: "chevron.left")
                            .imageScale(.large).fontWeight(.semibold).foregroundColor(.black)
                    }
                }
                
                // 타이틀
                ToolbarItem(placement: .principal) {
                    Text("나의 장소 리뷰").font(.title2).bold()
                }
                
                // 우측: 모드별 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        if isCreate {
                            // 생성 모드: + 버튼으로 코멘트 필드 토글
                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    showCommentField.toggle()
                                }
                                if showCommentField {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        isCommentFocused = true
                                    }
                                } else {
                                    isCommentFocused = false
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large).fontWeight(.semibold).foregroundColor(.black)
                            }
                        } else {
                            Button {
                                withAnimation { isEditingExisting = true }
                                // 편집 진입 시 코멘트 필드가 보이도록
                                withAnimation { showCommentField = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    isCommentFocused = true
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .imageScale(.large).fontWeight(.semibold).foregroundColor(.black)
                            }
                            
                            Button {
                                if case .view(let existing) = mode {
                                    onDelete?(existing)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .imageScale(.large).fontWeight(.semibold).foregroundColor(.black)
                            }
                        }
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
        case 0..<0.25: return "최고예요"
        case 0.25..<0.5: return "좋아요"
        case 0.5..<0.75: return "별로예요"
        default: return "최악"
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
