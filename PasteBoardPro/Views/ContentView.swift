import SwiftUI

struct ContentView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var filter: FilterType = .all
    @State private var showSettings = false

    private var filteredItems: [ClipboardItem] {
        monitor.items.filter { item in
            let matchesFilter: Bool = {
                switch filter {
                case .all: return true
                case .text: return item.type == .text
                case .image: return item.type == .image
                }
            }()
            let matchesSearch: Bool = {
                if searchText.isEmpty { return true }
                return item.content?.localizedCaseInsensitiveContains(searchText) ?? false
            }()
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("剪贴板历史", systemImage: "clipboard.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(monitor.items.count) 条")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showSettings) {
                    SettingsView(monitor: monitor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Search
            SearchBar(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            // Filter
            FilterBar(selected: $filter)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            // Divider
            Divider()
                .padding(.horizontal, 16)

            // Items list
            if filteredItems.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: filter == .image ? "photo.on.rectangle" : "doc.on.clipboard")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(searchText.isEmpty ? "暂无记录" : "未找到匹配内容")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredItems) { item in
                            ClipCardView(
                                item: item,
                                onCopy: { monitor.copyToClipboard(item) },
                                onPin: { monitor.togglePin(id: item.id) },
                                onDelete: { monitor.deleteItem(id: item.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(width: 380, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
