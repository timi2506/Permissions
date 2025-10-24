import SwiftUI

public extension View {
    func permissionsSheet(isPresented: Binding<Bool>, skipGranted: Bool, permissions: Set<PermissionType>) -> some View {
        self.modifier(PermissionsSheet(isPresented: isPresented, skipGranted: skipGranted, perms: permissions.map { $0 }))
    }
}

private struct PermissionsSheet: ViewModifier {
    @StateObject var manager = PermissionsManager.shared
    @Binding var isPresented: Bool
    var skipGranted: Bool
    let perms: Array<PermissionType>
    @State var currentIndex: Int = 0
    @State var hasFinished = false
    @State var isRefreshing = false
    private var currentPermission: PermissionType? {
        guard perms.indices.contains(currentIndex) else { return nil }
        return perms[currentIndex]
    }
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                if isRefreshing {
                    ProgressView()
                } else {
                    sheetView
                }
            }
    }
    var sheetView: some View {
        NavigationView {
            VStack {
                if let permission = currentPermission {
                    PermissionView(permission: permission, skipGranted: skipGranted) {
                        withAnimation {
                            isRefreshing = true
                            if currentIndex + 1 < perms.count {
                                currentIndex += 1
                            } else if currentIndex + 1 == perms.count {
                                // ALL PERMS FINISHED
                                hasFinished = true
                                currentIndex += 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation {
                                    isRefreshing = false
                                }
                            }
                        }
                    }
                    .animation(.default, value: currentIndex)
                } else {
                    if hasFinished {
                        finishedView
                    } else {
                        Text("An Error occured")
                        Button("Dismiss") {
                            isPresented = false
                        }
                    }
                }
            }
            .animation(.default, value: currentIndex)
            .navigationTitle(manager.localizationProvider.permissionsTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    var finishedView: some View {
        VStack {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 75))
                    .frame(height: 100)
                    .padding()
                Text(manager.localizationProvider.allSetTitle)
                    .font(.title)
                    .bold()
                Text(manager.localizationProvider.allSetDescription)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, 50)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                HStack {
                    Spacer()
                    Text(manager.localizationProvider.doneButtonTitle)
                        .bold()
                    Spacer()
                }
                .padding(10)
            }
            .borderedProminent()
            .padding()
            .padding(.horizontal)
        }
    }
}

private struct PermissionView: View {
    @StateObject var manager = PermissionsManager.shared
    @State var isGranted = false
    @State var isProcessing = false
    @State var isAnimating = false
    @State var showSkip = false
    @State var showHelp = false
    var permission: PermissionType
    var skipGranted: Bool
    var next: () -> Void
    var body: some View {
        VStack {
            header()
                .onTapGesture {
                    showHelp.toggle()
                }
            Spacer()
                if !isGranted {
                    VStack {
                        Button(manager.localizationProvider.needHelpButtonTitle) {
                            showHelp.toggle()
                        }
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                        Text(manager.localizationProvider.skipNoticeText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button(manager.localizationProvider.tapHereToSkipButtonTitle) {
                            next()
                        }
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    }
                    .offset(y: !showSkip ? 100 : 0)
                    .opacity(showSkip ? 1 : 0)
                    .padding(.horizontal, 50)
                }
                Button(action: {
                    Task {
                        if !isGranted {
                            await request()
                        } else {
                            next()
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        }
                        Text(isProcessing ? manager.localizationProvider.waitingTitle : isGranted ? manager.localizationProvider.continueButtonTitle : manager.localizationProvider.grantButtonTitle)
                            .bold()
                            .contentTransition()
                        Spacer()
                    }
                    .padding(10)
                }
                .borderedProminent()
                .disabled(isProcessing)
                .padding()
                .padding(.horizontal)
        }
        .helpOverlayView(isPresented: $showHelp) {
            NavigationView {
                Form {
                    header(false)
                    Section(manager.localizationProvider.whatDoesThisPermissionDoSectionTitle) {
                        Text(permission.localizedDescription)
                    }
                    Section(manager.localizationProvider.cantGrantSectionTitle) {
                        Text(manager.localizationProvider.cantGrantHelpText)
                            .onTapGesture {
                                if let url = URL(string: UIApplication.openSettingsURLString),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                }
                .navigationTitle(manager.localizationProvider.helpNavigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if #available(iOS 26, *) {
                            Button("Close", systemImage: "xmark") {
                                showHelp = false
                            }
                        } else {
                            Button(action: {
                                showHelp = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(7.5)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.tertiary)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
        .task {
            isGranted = await permission.isAuthorized()
            if skipGranted && isGranted {
                next()
            }
        }
    }
    func changeProcessing(to newState: Bool) async {
        withAnimation {
            isAnimating = true
        }
        await wait(for: 0.25)
        withAnimation {
            isProcessing = newState
        }
        await wait(for: 0.25)
        withAnimation {
            isAnimating = false
        }
    }
    func checkGranted(disableRepeatedAnimation: Bool = false) async {
        if !disableRepeatedAnimation {
            await changeProcessing(to: true)
        }
        isGranted = await permission.isAuthorized()
        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.25)) {
            showSkip = true
        }
        if !disableRepeatedAnimation {
            await changeProcessing(to: false)
        }
    }
    func request() async {
        await changeProcessing(to: true)
        await permission.request()
        await checkGranted(disableRepeatedAnimation: true)
        await changeProcessing(to: false)
    }
    func header(_ showGranted: Bool = true) -> some View {
        VStack(spacing: 10) {
            Image(systemName: permission.sfSymbol)
                .font(.system(size: 75))
                .frame(height: 100)
                .padding()
            Text(manager.localizationProvider.sheetHeader)
                .foregroundStyle(.secondary)
            Text(permission.localizedTitle)
                .font(.title)
                .bold()
            if showGranted {
                HStack {
                    Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 17.5))
                    
                    Text(isGranted ? manager.localizationProvider.grantedTitle : manager.localizationProvider.notGrantedTitle)
                        .bold()
                        .font(.system(size: 20))
                }
                .foregroundStyle(isGranted ? .green : .red)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 50)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }
}

fileprivate func wait(for seconds: TimeInterval) async {
    try? await Task.sleep(nanoseconds: .seconds(seconds))
}

fileprivate extension UInt64 {
    static func seconds(_ value: TimeInterval) -> UInt64 {
        return UInt64(value * 1_000_000_000)
    }
}

fileprivate extension View {
    func borderedProminent() -> some View {
        if #available(iOS 26.0, *) {
            return self
                .buttonStyle(.glassProminent)
        } else {
            return self
                .buttonStyle(.borderedProminent)
        }
    }
    func contentTransition() -> some View {
        if #available(iOS 16.0, *) {
            return self                       .contentTransition(.numericText(countsDown: false))
        } else {
            return self
        }
    }
    func helpOverlayView<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        if #available(iOS 16.0, *) {
            return self
                .sheet(isPresented: isPresented) {
                    content()
                        .presentationDetents([.large, .medium])
                }
        } else {
            return self
                .fullScreenCover(isPresented: isPresented) {
                    content()
                }
        }
    }
}

#Preview {
    Text("Hello World!")
        .permissionsSheet(isPresented: .constant(true), skipGranted: false, permissions: [.camera, .microphone, .bluetooth])
}
