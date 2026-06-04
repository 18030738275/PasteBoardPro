import SwiftUI

enum FilterType: String, CaseIterable {
    case all = "全部"
    case text = "文字"
    case image = "图片"
}

struct FilterBar: View {
    @Binding var selected: FilterType

    var body: some View {
        HStack(spacing: 6) {
            ForEach(FilterType.allCases, id: \.self) { type in
                let isSelected = selected == type
                Text(type.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.accentColor : Color.clear)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
                    .foregroundColor(isSelected ? .white : .secondary)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = type
                        }
                    }
            }
            Spacer()
        }
    }
}
