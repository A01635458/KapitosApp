//
//  ImageSourcePicker.swift
//  KapitosApp
//

import SwiftUI
import UIKit

struct ImageSourcePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImageSourcePicker
        
        init(_ parent: ImageSourcePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct ImageSourceSelector: View {
    @Binding var image: UIImage?
    @Binding var showActionSheet: Bool
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        EmptyView()
            .confirmationDialog("Seleccionar foto", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Tomar foto") {
                    sourceType = .camera
                    showImagePicker = true
                }
                
                Button("Elegir de galería") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                
                Button("Cancelar", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImageSourcePicker(image: $image, sourceType: $sourceType)
                    .ignoresSafeArea()
            }
    }
}
