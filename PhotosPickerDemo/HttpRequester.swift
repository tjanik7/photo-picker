//
//  HttpRequester.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 4/27/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import SwiftUI

struct JokeView: View {
    @State var joke: Joke?
    
    var body: some View {
        VStack {
            Text("Random Joke")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(Color.gray)
                .padding(.bottom, 8)
            Text(joke?.joke ?? "Loading joke...")
                .padding(.horizontal, 8)
        }.onAppear() {
//            JokesApi().getRandomJoke { (joke) in
//                self.joke = joke
            JokesApi().getJoke { (jokeString) in
                print(jokeString)
            }
        }
    }
}

struct Joke: Codable, Identifiable {
    let id: Int
    let error: Bool
    let category: String
    let type: String
    let joke: String
}

class JokesApi {
    let jokeUrl = URL(string: "https://v2.jokeapi.dev/joke/Programming")!
    
    func getJoke(completion:@escaping (String) -> ()) {
        URLSession.shared.dataTask(with:jokeUrl) { (data, response, error) in
              if error != nil {
                  print("ERROR")
                print(error!)
                completion("")
              } else {
                  print("no error to be found")
                if let returnData = String(data: data!, encoding: .utf8) {
                  completion(returnData)
                } else {
                  completion("")
                }
              }
            }.resume()
    }
    
    func getRandomJoke(completion:@escaping (Joke) -> ()) {
        print("getting random joke")
        URLSession.shared.dataTask(with: jokeUrl) { data,_,_  in
            if let data {
                print("data is NOT null")
                print(type(of: data))
            } else {
                print("data is null")
            }
            
            let joke = try! JSONDecoder().decode(Joke.self, from: data!)
            
            DispatchQueue.main.async {
                completion(joke)
            }
        }
        .resume()
    }
}

//class HttpRequester {
//    func makeRequest() {
//        let url = URL(string: "http://www.google.com")!
//        var request = URLRequest(url: url)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        
//        URLSession.shared.dataTask(with: url) { data,_,_  in
//                    let joke = try! JSONDecoder().decode(Joke.self, from: data!)
//                    
//                    DispatchQueue.main.async {
//                        completion(joke)
//                    }
//                }
//                .resume()
//    }
//}
