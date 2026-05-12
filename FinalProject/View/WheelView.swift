import SwiftUI

struct WheelView: View {

    @Environment(\.dismiss) private var dismiss

    let restaurants = [
        "一蘭拉麵",
        "藏壽司",
        "鼎泰豐",
        "五桐號",
        "麥當勞",
        "八方雲集"
    ]

    @State private var rotation: Double = 0

    @State private var selectedRestaurant = ""

    @State private var isSpinning = false

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.orange.opacity(0.2),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {

                Text("美食轉盤")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ZStack {

                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    .orange,
                                    .yellow,
                                    .red,
                                    .orange
                                ]),
                                center: .center
                            )
                        )
                        .frame(width: 320, height: 320)
                        .rotationEffect(.degrees(rotation))
                        .animation(
                            .easeOut(duration: 4),
                            value: rotation
                        )

                    ZStack {

                        ForEach(restaurants.indices, id: \.self) { index in

                            let angle = Double(index)
                            / Double(restaurants.count) * 360

                            VStack {

                                Text(restaurants[index])
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(-angle))

                                Spacer()
                            }
                            .padding(.top, 30)
                            .rotationEffect(.degrees(angle))
                        }
                    }
                    .frame(width: 260, height: 260)
                }

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)

                if !selectedRestaurant.isEmpty {

                    VStack(spacing: 10) {

                        Text("今天吃")
                            .font(.headline)
                            .foregroundStyle(.gray)

                        Text(selectedRestaurant)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }

                Button {

                    spinWheel()

                } label: {

                    Text(
                        isSpinning
                        ? "轉盤旋轉中..."
                        : "開始旋轉"
                    )
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isSpinning
                        ? Color.gray
                        : Color.orange
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                }
                .disabled(isSpinning)
                .padding(.horizontal)

                Button("返回") {

                    dismiss()
                }
                .foregroundStyle(.gray)
            }
            .padding()
        }
    }

    func spinWheel() {

        isSpinning = true

        let randomIndex = Int.random(
            in: 0..<restaurants.count
        )

        let extraRotation = Double.random(
            in: 720...1440
        )

        rotation += extraRotation

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {

            selectedRestaurant = restaurants[randomIndex]

            isSpinning = false
        }
    }
}

#Preview {
    WheelView()
}
