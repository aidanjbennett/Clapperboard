//
//  AddClapperboardView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/07/2026.
//

import SwiftUI
import ClapperboardCore
import PhotosUI
import PostHog

struct AddClapperboardView: View {

    @State private var viewModel = AddClapperboardViewModel()
    @FocusState private var focusedField: ClapperboardField?
    @State private var showActivitySheet = false

    var body: some View {
          ScrollView {
              VStack(spacing: 28) {
                  CollapsibleAdBannerView(
                      adUnitID: AdUnitID.addClapperboardBanner
                  )
                  .frame(height: 60)
   
                  VideoPickerView(
                      selectedItem: $viewModel.selectedItem,
                      previewImage: viewModel.previewImage
                  )
   
                  DetailsSectionView(
                      configuration: $viewModel.configuration,
                      focusedField: $focusedField
                  )
                  
                  HStack {
                      ChangeVideoButtonView(
                          focusedField: $focusedField,
                          viewModel: $viewModel
                      )
          
                      ExportButtonView(
                          focusedField: $focusedField,
                          viewModel: $viewModel
                      )
                  }
              }
              .padding(.horizontal, 20)
              .padding(.top, 12)
              .padding(.bottom, 32)
          }
          .background(Color(.systemGroupedBackground))
          .navigationTitle("New Clapperboard")
          .navigationBarTitleDisplayMode(.inline)
          .onAppear {
              viewModel.refreshDefaultsIfNeeded()
          }
          .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
              viewModel.refreshDefaultsIfNeeded()
          }
          .task(id: viewModel.selectedItem) {
              await viewModel.loadSelectedVideo()
   
              if let url = viewModel.selectedVideoURL {
                  let size = await VideoUtilities.videoSize(for: url)
                  await viewModel.renderPreview(size: size)
              }
          }
          .task(id: viewModel.configuration) {
              guard let url = viewModel.selectedVideoURL else { return }
   
              let size = await VideoUtilities.videoSize(for: url)
              await viewModel.renderPreview(size: size)
          }
          .alert("Export Failed", isPresented: .constant(viewModel.error != nil)) {
              Button("OK") {
                  viewModel.error = nil
              }
          } message: {
              Text(viewModel.error?.localizedDescription ?? "Unknown error")
          }
          .sheet(
              isPresented: Binding(
                  get: { viewModel.exportedVideoURL != nil },
                  set: {
                      if !$0 {
                          viewModel.dismissShareSheet()
                      }
                  }
              )
          ) {
              if let url = viewModel.exportedVideoURL {
                  VStack(spacing: 20) {
                      Capsule()
                          .fill(.tertiary)
                          .frame(width: 36, height: 5)
                          .padding(.top, 8)
   
                      Image(systemName: "checkmark.circle.fill")
                          .font(.system(size: 44))
                          .foregroundStyle(.green)
   
                      Text("Export Complete")
                          .font(.title3.bold())
   
                      Button {
                          showActivitySheet = true
                      } label: {
                          Label("Share Video", systemImage: "square.and.arrow.up")
                              .frame(maxWidth: .infinity)
                      }
                      .buttonStyle(.borderedProminent)
                      .controlSize(.large)
                      .padding(.horizontal)
                      .sheet(isPresented: $showActivitySheet) {
                          ActivityShareView(
                              url: url,
                              excludedActivityTypes: viewModel.isSaveToPhotosEnabled ? [.saveToCameraRoll] : [],
                              onShare: { PostHogSDK.shared.capture("video_shared") }
                          )
                      }
   
                      Spacer()
                  }
                  .presentationDetents([.height(240)])
                  .presentationDragIndicator(.hidden)
              }
          }
      }
}

struct ActivityShareView: UIViewControllerRepresentable {
    let url: URL
    let excludedActivityTypes: [UIActivity.ActivityType]
    var onShare: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = { activityType, completed, _, _ in
            if completed {
                onShare?()
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        AddClapperboardView()
    }
}
