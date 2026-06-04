import SwiftUI

struct SettingsView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var selectedDays: Int
    @State private var imageFolderPath: String

    init(monitor: ClipboardMonitor) {
        self.monitor = monitor
        let days = UserDefaults.standard.integer(forKey: "expiresInDays")
        _selectedDays = State(initialValue: days > 0 ? days : 3)
        _imageFolderPath = State(initialValue: UserDefaults.standard.string(forKey: "imageFolderPath") ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("设置")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("存储时长")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("", selection: $selectedDays) {
                    Text("1 天").tag(1)
                    Text("3 天").tag(3)
                    Text("5 天").tag(5)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedDays) { _, newValue in
                    monitor.updateSettings(expiresInDays: newValue, imageFolder: nil)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("图片存放位置")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text(imageFolderPath.isEmpty ? "默认路径" : imageFolderPath)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("选择...") {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.allowsMultipleSelection = false
                        if panel.runModal() == .OK, let url = panel.url {
                            imageFolderPath = url.path
                            monitor.updateSettings(expiresInDays: selectedDays, imageFolder: url)
                        }
                    }
                    .font(.caption)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }

            Divider()

            HStack {
                Spacer()
                Text("数据仅存储在本地")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}
