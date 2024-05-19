//
//  APIClient.swift
//  OpenDesk
//
//  Created by Scott Fitsimones on 5/18/24.
//

import Foundation

let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
let openRouterAPIKey = "PLACEHOLDER"

func buildImageRequestPayload(prompt: String, base64Image: String, model: String) -> [String: Any] {
    let modelMap = [
        "llama": "liuhaotian/llava-yi-34b",
        "gpt": "openai/gpt-4o",
        "gemini": "google/gemini-pro-vision"
    ]
    print(modelMap[model]!)
    return [
        "model": modelMap[model]!,
        "messages": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Do not mention you are looking at a computer screen or desktop app, I'm aware. Also be concise and direct with no niceties or disclaimers / qualifications in your answers. \(prompt)"
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/png;base64,\(base64Image)"
                        ]
                    ]
                ]
            ]
        ]
    ]
}

func getAnswerFromImageAndPrompt(prompt: String, image: String, model: String, completion: @escaping (String?) -> Void) {
    let payload = buildImageRequestPayload(prompt: prompt, base64Image: image, model: model)
    let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: [])
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(openRouterAPIKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Response Code: \(httpResponse.statusCode)")
        }

        let responseString = String(data: data, encoding: .utf8)
        print("Response: \(responseString ?? "")")
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
             let choices = json["choices"] as? [[String: Any]],
             let message = choices.first?["message"] as? [String: Any],
             let content = message["content"] as? String {
              completion(content)
          } else {
              completion(nil)
          }
    }

    task.resume()
}

func parseMessage(response: String) -> String? {
    // Assuming the response is a JSON string
    guard let data = response.data(using: .utf8) else { return nil }
    do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let message = json["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
    } catch {
        print("Error parsing JSON: \(error)")
    }
    return nil
}


