import SwiftUI

// MARK: - Wheel Slice Shape

struct WheelSlice: Shape {

    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - WheelView

struct WheelView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(FavoritesStore.self) private var store

    private var wheelRestaurants: [Restaurant] {
        store.wantToEat.isEmpty ? Restaurant.defaults : store.wantToEat
    }

    private let segmentColors: [Color] = [
        Color(red: 1.00, green: 0.45, blue: 0.20),
        Color(red: 0.97, green: 0.70, blue: 0.10),
        Color(red: 0.88, green: 0.28, blue: 0.35),
        Color(red: 1.00, green: 0.55, blue: 0.15),
        Color(red: 0.78, green: 0.18, blue: 0.44),
        Color(red: 0.96, green: 0.76, blue: 0.04),
    ]

    @State private var rotation: Double = 0
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var showCalendarSheet = false

    private let wheelSize: CGFloat = 290
    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    var body: some View {

        ZStack {

            Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

            VStack(spacing: 0) {

                navBar.padding(.top, 10)

                titleSection.padding(.top, 16)

                wheelSection.padding(.top, 28)

                resultSection
                    .padding(.top, 24)
                    .padding(.horizontal, 20)

                Spacer()

                spinButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCalendarSheet) {
            if let restaurant = selectedRestaurant {
                CalendarSheet(restaurant: restaurant)
            }
        }
    }

    // MARK: - Sub-views

    private var navBar: some View {

        HStack {

            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("返回")
                }
                .foregroundStyle(accent)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var titleSection: some View {

        VStack(spacing: 6) {

            Text("美食轉盤")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(store.wantToEat.isEmpty ? "轉動命運，決定今天的美食！" : "從你的想吃清單隨機選一間！")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private var wheelSection: some View {

        VStack(spacing: 0) {

            // Fixed pointer above wheel
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                .offset(y: 8)
                .zIndex(1)

            // Rotating wheel
            ZStack {

                let restaurants = wheelRestaurants

                // Segments + labels
                ForEach(restaurants.indices, id: \.self) { i in

                    let n = Double(restaurants.count)
                    let segAngle = 360.0 / n
                    let startDeg = -90.0 + Double(i) * segAngle
                    let endDeg = startDeg + segAngle
                    let midDeg = (startDeg + endDeg) / 2
                    let midRad = midDeg * .pi / 180.0
                    let textR = wheelSize / 2 * 0.63

                    // Pie slice
                    WheelSlice(
                        startAngle: .degrees(startDeg),
                        endAngle: .degrees(endDeg)
                    )
                    .fill(segmentColors[i % segmentColors.count])

                    // Segment label
                    Text(restaurants[i].name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1)
                        .lineLimit(1)
                        .rotationEffect(.degrees(midDeg + 90))
                        .offset(
                            x: textR * cos(midRad),
                            y: textR * sin(midRad)
                        )
                }

                // Divider lines between segments
                Path { path in
                    let restaurants = wheelRestaurants
                    let n = Double(restaurants.count)
                    let segAngle = 360.0 / n
                    let r = wheelSize / 2
                    let cx = wheelSize / 2
                    let cy = wheelSize / 2
                    for i in 0..<restaurants.count {
                        let angle = (-90.0 + Double(i) * segAngle) * .pi / 180.0
                        path.move(to: CGPoint(x: cx, y: cy))
                        path.addLine(to: CGPoint(
                            x: cx + r * cos(angle),
                            y: cy + r * sin(angle)
                        ))
                    }
                }
                .stroke(Color.white.opacity(0.45), lineWidth: 2)

                // Outer border ring
                Circle()
                    .stroke(Color.white, lineWidth: 3)

                // Center cap
                Circle()
                    .fill(.white)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.12), radius: 5)

                Circle()
                    .fill(accent)
                    .frame(width: 44, height: 44)

                Image(systemName: "fork.knife")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: wheelSize, height: wheelSize)
            .rotationEffect(.degrees(rotation))
            .animation(.easeOut(duration: 4), value: rotation)
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        }
    }

    private var resultSection: some View {

        ZStack {

            if showResult, let restaurant = selectedRestaurant {

                VStack(spacing: 12) {

                    // Result card
                    VStack(spacing: 8) {

                        Text("今天就吃")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            Text(restaurant.emoji)
                                .font(.title2)
                            Text(restaurant.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(accent)
                        }

                        Text("祝你用餐愉快！🎉")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)

                    // Action buttons
                    HStack(spacing: 12) {

                        let isFav = store.isFavorite(restaurant)

                        Button {
                            store.toggleFavorite(restaurant)
                        } label: {
                            Label(
                                isFav ? "已在最愛" : "加入最愛",
                                systemImage: isFav ? "heart.fill" : "heart"
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isFav ? accent.opacity(0.1) : Color.white)
                            .foregroundStyle(isFav ? accent : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)

                        Button {
                            showCalendarSheet = true
                        } label: {
                            Label("加入行事曆", systemImage: "calendar.badge.plus")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))

            } else {

                Color.clear.frame(height: 140)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showResult)
    }

    private var spinButton: some View {

        Button(action: spinWheel) {

            HStack(spacing: 10) {

                if isSpinning {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)
                }

                Text(isSpinning ? "旋轉中..." : (showResult ? "再轉一次" : "開始旋轉"))
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                if isSpinning {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accent,
                                    Color(red: 0.85, green: 0.22, blue: 0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .shadow(
                color: accent.opacity(isSpinning ? 0 : 0.4),
                radius: 10,
                y: 5
            )
        }
        .disabled(isSpinning)
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private func spinWheel() {

        isSpinning = true
        showResult = false

        let restaurants = wheelRestaurants
        let targetIndex = Int.random(in: 0..<restaurants.count)
        rotation += Double.random(in: 1440...2160)

        Task {
            try? await Task.sleep(for: .seconds(4))
            selectedRestaurant = restaurants[targetIndex]
            isSpinning = false
            withAnimation {
                showResult = true
            }
        }
    }
}

#Preview {
    WheelView()
        .environment(FavoritesStore())
}
