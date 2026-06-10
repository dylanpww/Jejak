//
//  CloudinaryService.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//


import UIKit

class CloudinaryService {
    private var cloudName: String {
        Config.value(for: "CloudinaryCloudName")
    }
    private var uploadPreset: String {
        Config.value(for: "CloudinaryUploadPreset")
    }

    func uploadPhoto(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CloudinaryError.invalidImage
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = makeBody(imageData: imageData, boundary: boundary)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CloudinaryError.uploadFailed
        }

        let result = try JSONDecoder().decode(CloudinaryResponse.self, from: data)
        return result.secureUrl
    }

    private func makeBody(imageData: Data, boundary: String) -> Data {
        var body = Data()

        func append(_ string: String) {
            body.append(Data(string.utf8))
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        append("\(uploadPreset)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        append("\r\n")
        append("--\(boundary)--\r\n")

        return body
    }
}

private struct CloudinaryResponse: Decodable {
    let secureUrl: String
    enum CodingKeys: String, CodingKey {
        case secureUrl = "secure_url"
    }
}

enum CloudinaryError: LocalizedError {
    case invalidImage
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process image"
        case .uploadFailed: return "Upload to Cloudinary failed"
        }
    }
}
