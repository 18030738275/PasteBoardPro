import SwiftUI

struct ClipCardView: View {
    let item: ClipboardItem
    let onCopy: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    @State private var showCopied = false

    var body: some View {
        HStack(spacing: 12) {
            // 类型图标
            ZStack {
                Circle()
                    .fill(item.type == .image ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: item.type == .image ? "photo" : "doc.text")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(item.type == .image ? .blue : .purple)
            }

            // 内容
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                    Text(item.previewText)
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .foregroundColor(item.isExpired ? .secondary.opacity(0.6) : .primary)
                }

                Text(item.createdAt, style: .relative)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }

            Spacer()

            if showCopied {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text("已复制")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.green)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(item.isPinned ? Color.orange.opacity(0.06) : Color(nsColor: .controlBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(item.isPinned ? Color.orange.opacity(0.25) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onCopy()
            withAnimation(.easeInOut(duration: 0.2)) { showCopied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.2)) { showCopied = false }
            }
        }
        .contextMenu {
            Button {
                onPin()
            } label: {
                Label(item.isPinned ? "取消置顶" : "置顶", systemImage: item.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}
