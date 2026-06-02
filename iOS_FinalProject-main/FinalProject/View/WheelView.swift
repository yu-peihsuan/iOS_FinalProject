import SwiftUI

// MARK: - WheelView

struct WheelView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(FavoritesStore.self) private var store

    let selectedCategories: Set<String>

    private var wheelRestaurants: [Restaurant] {
        let source = store.wantToEat.isEmpty ? Restaurant.defaults : store.wantToEat
        let filtered = source.filter { selectedCategories.contains($0.category) }

        if filtered.isEmpty {
            return Restaurant.defaults.filter { selectedCategories.contains($0.category) }
        }

        return filtered
    }

    @State private var selectedRestaurant: Restaurant? = nil
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var showCalendarSheet = false
    @State private var handleRotation: Double = 0
    @State private var machineOffset: CGFloat = 0
    @State private var capsuleXOffset: CGFloat = 54
    @State private var capsuleYOffset: CGFloat = 288
    @State private var capsuleScale: CGFloat = 0.35
    @State private var capsuleOpacity: Double = 0

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)
    private let deepRed = Color(red: 0.85, green: 0.22, blue: 0.35)
    private let gold = Color(red: 0.98, green: 0.72, blue: 0.18)
    private let teal = Color(red: 0.16, green: 0.60, blue: 0.76)
    private let bodyWidth: CGFloat = 286
    private let globeSize: CGFloat = 218

    var body: some View {

        ZStack {

            Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

            VStack(spacing: 0) {

                navBar.padding(.top, 10)

                gachaSection.padding(.top, 4)

                resultSection
                    .padding(.top, 64)
                    .padding(.horizontal, 20)

                Spacer(minLength: 12)

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

    private var gachaSection: some View {

        ZStack(alignment: .top) {
            gachaMachine
                .offset(x: machineOffset)

            if capsuleOpacity > 0, let restaurant = selectedRestaurant {
                prizeCapsule(restaurant: restaurant)
                    .scaleEffect(capsuleScale)
                    .opacity(capsuleOpacity)
                    .offset(x: capsuleXOffset, y: capsuleYOffset)
                    .zIndex(4)
            }
        }
        .offset(y: -44)
        .frame(height: 370)
        .padding(.horizontal, 20)
    }

    private var gachaMachine: some View {

        ZStack(alignment: .top) {
            glassGlobe
                .frame(width: globeSize, height: globeSize)
                .offset(y: 0)
                .zIndex(2)

            neckRing
                .frame(width: 142, height: 30)
                .offset(y: 196)
                .zIndex(3)

            machineBody
                .frame(width: bodyWidth, height: 142)
                .offset(y: 220)
                .zIndex(1)

            machineBase
                .frame(width: 318, height: 48)
                .offset(y: 336)
                .zIndex(0)
        }
        .frame(width: 330, height: 370)
    }

    private var glassGlobe: some View {

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.96), Color(red: 0.73, green: 0.93, blue: 1.0).opacity(0.62)],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: 170
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 7)
                }
                .overlay {
                    Circle()
                        .stroke(teal.opacity(0.18), lineWidth: 2)
                        .padding(10)
                }
                .shadow(color: .black.opacity(0.14), radius: 16, y: 8)

            ForEach(Array(wheelRestaurants.prefix(16).enumerated()), id: \.offset) { index, restaurant in
                miniCapsule(restaurant: restaurant, index: index)
            }

            Circle()
                .fill(Color.white.opacity(0.58))
                .frame(width: 70, height: 30)
                .blur(radius: 1.4)
                .offset(x: -50, y: -64)

            Capsule()
                .fill(Color.white.opacity(0.36))
                .frame(width: 30, height: 86)
                .rotationEffect(.degrees(28))
                .offset(x: 62, y: -18)
        }
        .clipShape(Circle())
    }

    private var neckRing: some View {

        Capsule()
            .fill(
                LinearGradient(
                    colors: [Color.white, Color(red: 0.92, green: 0.92, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 5, y: 3)
    }

    private var machineBody: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [accent, deepRed],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.14))
                        .frame(height: 44)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                }
                .shadow(color: deepRed.opacity(0.28), radius: 14, y: 8)

            HStack(spacing: 24) {
                knob
                chute
            }
            .offset(y: -6)

        }
    }

    private var knob: some View {

        ZStack {
            Circle()
                .fill(Color(red: 0.98, green: 0.98, blue: 0.94))
                .frame(width: 82, height: 82)
                .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

            Circle()
                .fill(gold)
                .frame(width: 62, height: 62)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.55), lineWidth: 3)
                }

            RoundedRectangle(cornerRadius: 7)
                .fill(.white.opacity(0.92))
                .frame(width: 50, height: 12)
                .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                .rotationEffect(.degrees(handleRotation))
        }
    }

    private var chute: some View {

        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.18))
                .frame(width: 96, height: 68)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.38), lineWidth: 2)
                        .padding(5)
                }

            RoundedRectangle(cornerRadius: 9)
                .fill(Color(red: 0.24, green: 0.18, blue: 0.18))
                .frame(width: 78, height: 30)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.16))
                        .frame(height: 8)
                }
                .padding(.bottom, 9)
        }
    }

    private var machineBase: some View {

        RoundedRectangle(cornerRadius: 17)
            .fill(Color(red: 0.34, green: 0.25, blue: 0.25))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 16)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
            }
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }

    private func miniCapsule(restaurant: Restaurant, index: Int) -> some View {
        let positions: [CGPoint] = [
            CGPoint(x: -62, y: 44), CGPoint(x: -22, y: 58), CGPoint(x: 24, y: 48),
            CGPoint(x: 62, y: 30), CGPoint(x: -66, y: 4), CGPoint(x: -18, y: 14),
            CGPoint(x: 30, y: 2), CGPoint(x: 66, y: -12), CGPoint(x: -66, y: -38),
            CGPoint(x: -24, y: -54), CGPoint(x: 20, y: -48), CGPoint(x: 58, y: -54),
            CGPoint(x: -2, y: -16), CGPoint(x: -42, y: 84), CGPoint(x: 42, y: 78),
            CGPoint(x: 0, y: 86)
        ]
        let point = positions[index % positions.count]
        let angle = Double((index * 23) % 52) - 26

        return ZStack {
            Capsule()
                .fill(capsuleColor(for: index).opacity(0.94))
                .frame(width: 48, height: 32)

            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 48, height: 15)
                .offset(y: -8)

            Text(restaurant.emoji)
                .font(.system(size: 15))
        }
        .rotationEffect(.degrees(angle))
        .offset(x: point.x, y: point.y)
    }

    private func prizeCapsule(restaurant: Restaurant) -> some View {

        ZStack {
            Capsule()
                .fill(gold)
                .frame(width: 66, height: 46)

            Capsule()
                .fill(accent.opacity(0.96))
                .frame(width: 66, height: 23)
                .offset(y: 11.5)

            Capsule()
                .stroke(.white.opacity(0.72), lineWidth: 2)
                .frame(width: 66, height: 46)

            Text(restaurant.emoji)
                .font(.system(size: 20))
                .offset(y: -2)
        }
        .frame(width: 72, height: 52)
        .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
    }

    private var resultSection: some View {

        ZStack {

            if showResult, let restaurant = selectedRestaurant {

                VStack(spacing: 12) {

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
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        Text(restaurant.category)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)

                    Button {
                        openGoogleMaps(for: restaurant)
                    } label: {
                        Label("在 Google Maps 查看", systemImage: "map.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .foregroundStyle(accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)

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

                Color.clear.frame(height: 142)
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
                    Image(systemName: "sparkles")
                        .font(.title3)
                }

                Text(isSpinning ? "抽選中..." : (showResult ? "再抽一顆" : "抽一顆扭蛋"))
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
                                colors: [accent, deepRed],
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
        .disabled(isSpinning || wheelRestaurants.isEmpty)
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private func openGoogleMaps(for restaurant: Restaurant) {
        if let url = restaurant.googleMapsSearchURL {
            openURL(url)
        }
    }

    private func spinWheel() {

        let restaurants = wheelRestaurants
        guard let result = restaurants.randomElement() else { return }

        isSpinning = true
        showResult = false
        selectedRestaurant = result
        capsuleXOffset = 54
        capsuleYOffset = 288
        capsuleScale = 0.35
        capsuleOpacity = 0

        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.1).repeatCount(8, autoreverses: true)) {
                machineOffset = 6
            }
            withAnimation(.easeInOut(duration: 0.75)) {
                handleRotation += 360
            }

            try? await Task.sleep(for: .milliseconds(760))
            machineOffset = 0

            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                capsuleOpacity = 1
                capsuleScale = 1
                capsuleYOffset = 296
            }

            try? await Task.sleep(for: .milliseconds(520))
            withAnimation(.easeOut(duration: 0.22)) {
                capsuleOpacity = 0
                capsuleScale = 0.9
            }

            try? await Task.sleep(for: .milliseconds(120))
            store.addToHistory(result)
            isSpinning = false
            withAnimation {
                showResult = true
            }
        }
    }

    private func capsuleColor(for index: Int) -> Color {
        let colors: [Color] = [
            accent,
            gold,
            deepRed,
            teal,
            Color(red: 0.34, green: 0.68, blue: 0.38),
            Color(red: 0.56, green: 0.34, blue: 0.78)
        ]
        return colors[index % colors.count]
    }
}

#Preview {
    WheelView(selectedCategories: ["日式", "台式"])
        .environment(FavoritesStore())
}
