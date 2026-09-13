//
//  SnapshotView.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//


import SwiftUI
import Supabase

struct SnapshotView: View {
    @State private var capturedImage: UIImage?
    @State private var captureRequest = 0
    @State private var isUploading = false
    @State private var uploadError: String?

    let padding: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let cameraSize = geometry.size.width - padding * 2

            ZStack {
                Color.clear
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    if let capturedImage {

                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: cameraSize,
                                height: cameraSize
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 50,
                                    style: .continuous
                                )
                            )

                        HStack(spacing: 20) {

                            Button {
                                self.capturedImage = nil
                                self.uploadError = nil
                            } label: {
                                Text("Retake")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(.gray.opacity(0.3))
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 26,
                                            style: .continuous
                                        )
                                    )
                            }

                            Button {
                                Task {
                                    await upload(capturedImage)
                                }
                            } label: {
                                Group {
                                    if isUploading {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Text("Post")
                                            .font(.headline)
                                    }
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(.white)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 26,
                                        style: .continuous
                                    )
                                )
                            }
                            .disabled(isUploading)
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, 30)

                    } else {

                        SnapshotCamera(
                            capturedImage: $capturedImage,
                            captureRequest: $captureRequest
                        )
                        .frame(
                            width: cameraSize,
                            height: cameraSize
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 50,
                                style: .continuous
                            )
                        )

                        Button {
                            captureRequest += 1
                        } label: {
                            Circle()
                                .fill(.white)
                                .frame(width: 78, height: 78)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            .gray.opacity(0.4),
                                            lineWidth: 3
                                        )
                                }
                        }
                        .padding(.top, 30)
                    }

                    if let uploadError {
                        Text(uploadError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
            }
        }
    }

    private func upload(_ image: UIImage) async {
        isUploading = true
        uploadError = nil

        do {
            try await SnapshotUploader.upload(image)

            await MainActor.run {
                capturedImage = nil
                isUploading = false
            }
        } catch {
            await MainActor.run {
                uploadError = error.localizedDescription
                isUploading = false
            }
        }
    }
}

#Preview {
    SnapshotView()
}
