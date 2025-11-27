import SwiftUI

/// Cyberpunk neon color palette
public struct CyberpunkTheme {
    // Primary neon colors
    public static let neonPink = Color(red: 1.0, green: 0.2, blue: 0.6)
    public static let neonBlue = Color(red: 0.0, green: 0.8, blue: 1.0)
    public static let neonPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
    public static let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    public static let neonOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    public static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.2)
    
    // Background colors
    public static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    public static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    public static let glassBackground = Color.white.opacity(0.05)
    
    // Text colors
    public static let primaryText = Color.white
    public static let secondaryText = Color.white.opacity(0.7)
    public static let tertiaryText = Color.white.opacity(0.5)
    
    // Gradients
    public static let neonGradient = LinearGradient(
        colors: [neonPink, neonPurple, neonBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.15),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.02, blue: 0.15),
            Color(red: 0.02, green: 0.02, blue: 0.08),
            Color(red: 0.05, green: 0.05, blue: 0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Glassmorphic card modifier
public struct GlassmorphicCard: ViewModifier {
    let cornerRadius: CGFloat
    let glowColor: Color
    
    public init(cornerRadius: CGFloat = 20, glowColor: Color = CyberpunkTheme.neonBlue) {
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Glass effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(CyberpunkTheme.glassBackground)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(CyberpunkTheme.glassGradient)
                        )
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    glowColor.opacity(0.6),
                                    glowColor.opacity(0.2),
                                    glowColor.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: glowColor.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

/// 3D skeuomorphic button style
public struct NeonButtonStyle: ButtonStyle {
    let color: Color
    let isDestructive: Bool
    
    public init(color: Color = CyberpunkTheme.neonBlue, isDestructive: Bool = false) {
        self.color = isDestructive ? CyberpunkTheme.neonPink : color
        self.isDestructive = isDestructive
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // 3D effect layers
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.3))
                        .offset(y: configuration.isPressed ? 0 : 4)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(y: configuration.isPressed ? 2 : 0)
                    
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .offset(y: configuration.isPressed ? 2 : 0)
                }
            )
            .shadow(color: color.opacity(configuration.isPressed ? 0.3 : 0.5), radius: configuration.isPressed ? 5 : 15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Bento box container
public struct BentoBox<Content: View>: View {
    let columns: Int
    let content: Content
    
    public init(columns: Int = 2, @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.content = content()
    }
    
    public var body: some View {
        content
    }
}

/// Neon glow text modifier
public struct NeonGlowText: ViewModifier {
    let color: Color
    let intensity: Double
    
    public init(color: Color = CyberpunkTheme.neonBlue, intensity: Double = 1.0) {
        self.color = color
        self.intensity = intensity
    }
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .shadow(color: color.opacity(0.8 * intensity), radius: 10)
            .shadow(color: color.opacity(0.5 * intensity), radius: 20)
            .shadow(color: color.opacity(0.3 * intensity), radius: 30)
    }
}

/// Animated neon border
public struct AnimatedNeonBorder: ViewModifier {
    let color: Color
    @State private var animationPhase: CGFloat = 0
    
    public init(color: Color = CyberpunkTheme.neonBlue) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        AngularGradient(
                            colors: [
                                color.opacity(0.8),
                                color.opacity(0.2),
                                color.opacity(0.8),
                                color.opacity(0.2),
                                color.opacity(0.8)
                            ],
                            center: .center,
                            startAngle: .degrees(animationPhase),
                            endAngle: .degrees(animationPhase + 360)
                        ),
                        lineWidth: 2
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    animationPhase = 360
                }
            }
    }
}

// MARK: - View Extensions

public extension View {
    func glassmorphic(cornerRadius: CGFloat = 20, glowColor: Color = CyberpunkTheme.neonBlue) -> some View {
        modifier(GlassmorphicCard(cornerRadius: cornerRadius, glowColor: glowColor))
    }
    
    func neonGlow(color: Color = CyberpunkTheme.neonBlue, intensity: Double = 1.0) -> some View {
        modifier(NeonGlowText(color: color, intensity: intensity))
    }
    
    func animatedNeonBorder(color: Color = CyberpunkTheme.neonBlue) -> some View {
        modifier(AnimatedNeonBorder(color: color))
    }
}
