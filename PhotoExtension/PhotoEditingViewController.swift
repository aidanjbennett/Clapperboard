import UIKit
import SwiftUI
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {
    
    private var hostingController: UIHostingController<ClapperboardEditingView>?
    private var clapperboardEditingView: ClapperboardEditingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Clapperboard Extension loaded!")
        
        // Create the SwiftUI view
        clapperboardEditingView = ClapperboardEditingView()
        
        // Wrap it in a hosting controller
        hostingController = UIHostingController(rootView: clapperboardEditingView)
        
        guard let hostingController = hostingController else { return }
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set up constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
        
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // We can handle our own clapperboard adjustments
        return adjustmentData.formatIdentifier == "com.clapperboard.video-edit"
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        print("🎬 startContentEditing called")

        // If the input already contains a video asset or an image URL, use it
        if contentEditingInput.audiovisualAsset != nil || contentEditingInput.fullSizeImageURL != nil {
            print("📀 Using provided PHContentEditingInput directly")
            clapperboardEditingView.loadContent(contentEditingInput: contentEditingInput,
                                                placeholderImage: placeholderImage)
            return
        }

        // No useful media found in the provided input: handle gracefully
        print("contentEditingInput has no audiovisualAsset and no fullSizeImageURL.")
        clapperboardEditingView.loadContent(contentEditingInput: contentEditingInput,
                                            placeholderImage: placeholderImage)
    }

    
    func finishContentEditing(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {
        print("🎬 finishContentEditing called")
        clapperboardEditingView.exportVideo(completionHandler: completionHandler)
    }
    
    var shouldShowCancelConfirmation: Bool {
        return true // Show confirmation since video processing takes time
    }
    
    func cancelContentEditing() {
        print("🎬 cancelContentEditing called")
    }
}
