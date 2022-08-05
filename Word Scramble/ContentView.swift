//
//  ContentView.swift
//  Word Scramble
//
//  Created by Maciej on 04/08/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Score: \(score)")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        reset()
                    } label: {
                        Image(systemName: "gobackward")
                    }
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isTooShort(word: answer) else {
            wordError(title: "Word is too short", message: "It should be at least 3 characters long")
            newWord = ""
            return
        }
        
        guard isTheSame(word: answer) else {
            wordError(title: "Word is the same as starter word", message: "Don't be afraid of new words :)")
            newWord = ""
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            newWord = ""
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that from word '\(rootWord)'")
            newWord = ""
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognied", message: "You can't make them up")
            newWord = ""
            return
        }
        
        withAnimation { usedWords.insert(answer, at: 0) }
        calculateScore(word: answer)
        newWord = ""
    }
    
    func startGame() {
        // Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                // Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        // If we are here, then there was a probem - trigger crash and report the error
        fatalError("Could not load words file from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word.lowercased() {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isTooShort(word: String) -> Bool {
        word.count > 2
    }
    
    func isTheSame(word: String) -> Bool {
        word != rootWord
    }
    
    func calculateScore(word: String) {
        score += word.count
    }
    
    func reset() {
        withAnimation {
            score = 0
            usedWords = []
            startGame()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
