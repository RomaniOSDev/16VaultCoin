import SwiftUI

// MARK: - Color System
struct AppColors {
    static let primary = Color.yellow
    static let secondary = Color.yellow.opacity(0.8)
    static let accent = Color.yellow.opacity(0.6)
    static let success = Color.yellow
    static let warning = Color.yellow
    static let error = Color.yellow
    
    static let background = Color.black
    static let secondaryBackground = Color.black.opacity(0.8)
    static let cardBackground = Color.black.opacity(0.9)
    
    static let textPrimary = Color.yellow
    static let textSecondary = Color.yellow.opacity(0.8)
    static let textTertiary = Color.yellow.opacity(0.6)
    
    // Modern gradient colors
    static let gradientStart = Color.yellow
    static let gradientEnd = Color.orange
    static let glowColor = Color.yellow.opacity(0.3)
}

// MARK: - Gradients
struct AppGradients {
    static let primary = LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondary = LinearGradient(
        colors: [AppColors.secondary, AppColors.accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let success = LinearGradient(
        colors: [AppColors.success, Color.yellow.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let error = LinearGradient(
        colors: [AppColors.error, Color.yellow.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let card = LinearGradient(
        colors: [AppColors.cardBackground, AppColors.secondaryBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Modern glass effect gradient
    static let glass = LinearGradient(
        colors: [
            Color.yellow.opacity(0.1),
            Color.yellow.opacity(0.05),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .medium, design: .rounded)
    static let caption1 = Font.system(size: 12, weight: .medium, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .medium, design: .rounded)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Shadows
struct AppShadows {
    static let small = Shadow(color: AppColors.glowColor, radius: 8, x: 0, y: 4)
    static let medium = Shadow(color: AppColors.glowColor, radius: 16, x: 0, y: 8)
    static let large = Shadow(color: AppColors.glowColor, radius: 24, x: 0, y: 12)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Modern Glass Card
struct ModernGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .fill(AppColors.cardBackground)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .fill(AppGradients.glass)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary.opacity(0.5), AppColors.primary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(
                color: AppShadows.medium.color,
                radius: AppShadows.medium.radius,
                x: AppShadows.medium.x,
                y: AppShadows.medium.y
            )
    }
}

// MARK: - Modern Gradient Button
struct ModernGradientButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    let gradient: LinearGradient
    @State private var isPressed = false
    
    init(
        gradient: LinearGradient = AppGradients.primary,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            content
                .foregroundColor(.black)
                .fontWeight(.bold)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .fill(gradient)
                        
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.2), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: AppShadows.large.color,
                    radius: AppShadows.large.radius,
                    x: AppShadows.large.x,
                    y: AppShadows.large.y
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Icon Button
struct ModernIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    @State private var isPressed = false
    
    init(
        icon: String,
        color: Color = AppColors.primary,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.5), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(color)
            }
            .frame(width: size, height: size)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Animated Number with Glow
struct AnimatedNumber: View {
    let value: Double
    let format: String
    let prefix: String
    let suffix: String
    @State private var animatedValue: Double = 0
    
    init(
        value: Double,
        format: String = "%.2f",
        prefix: String = "",
        suffix: String = ""
    ) {
        self.value = value
        self.format = format
        self.prefix = prefix
        self.suffix = suffix
    }
    
    var body: some View {
        Text("\(prefix)\(String(format: format, animatedValue))\(suffix)")
            .font(AppTypography.title1)
            .fontWeight(.bold)
            .foregroundColor(AppColors.textPrimary)
            .shadow(color: AppColors.glowColor, radius: 8, x: 0, y: 0)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animatedValue = value
                }
            }
            .onChange(of: value) { newValue in
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedValue = newValue
                }
            }
    }
}

// MARK: - Pulse Animation
struct PulseAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.primary)
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .opacity(isAnimating ? 0.3 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Circle()
                .fill(AppColors.primary)
                .scaleEffect(isAnimating ? 1.6 : 1.0)
                .opacity(isAnimating ? 0.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(0.5),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Modern Loading View
struct ModernLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(
                        AppGradients.primary,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.2)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 12, height: 12)
                    .offset(y: -30)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.2)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Text("Loading...")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .opacity(isAnimating ? 0.7 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Modern Empty State
struct ModernEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var isAnimating = false
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            ModernIconButton(
                icon: icon,
                color: AppColors.primary,
                size: 100
            ) {
                // No action for display
            }
            .disabled(true)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            VStack(spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .shadow(color: AppColors.glowColor, radius: 4, x: 0, y: 0)
                
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            if let actionTitle = actionTitle, let action = action {
                ModernGradientButton(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.headline)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.xl)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Extensions
extension View {
    func modernGlassCard() -> some View {
        self.modifier(ModernGlassCardModifier())
    }
    
    func appShadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
    
    func glowEffect() -> some View {
        self.shadow(color: AppColors.glowColor, radius: 8, x: 0, y: 0)
    }
}

struct ModernGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.lg)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .fill(AppColors.cardBackground)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .fill(AppGradients.glass)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary.opacity(0.5), AppColors.primary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .appShadow(AppShadows.medium)
    }
} 