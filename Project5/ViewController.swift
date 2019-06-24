//
//  ViewController.swift
//  Project5
//
//  Created by Miloslav G. Milenkov on 24/06/2019.
//  Copyright © 2019 Miloslav G. Milenkov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startNewGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            
            }
            
            if allWords.isEmpty {
                allWords = ["silkworm"]
            }
        }
        
        startGame()
    }
    
    @objc func startNewGame() {
    startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer: ", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if(isNotTooShort(word: lowerAnswer)) {
            if(isPossible(word: lowerAnswer)) {
                if(isOriginal(word: lowerAnswer)) {
                    if(isReal(word: lowerAnswer)) {
                        if(isNotSameWord(word: lowerAnswer)) {
                            usedWords.insert(lowerAnswer, at: 0)
                            
                            let indexPath = IndexPath(row:0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            return
                        }
                    }
                }
            }
        }
        showErrorMessage(word: lowerAnswer)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal (word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isNotTooShort (word: String) -> Bool {
        return word.count >= 3
    }
    
    func isNotSameWord(word:String) -> Bool {
        return !title!.elementsEqual(word)
    }
    
    func showErrorMessage(word: String) {
        var errorMessage: String = ""
        var errorTitle: String = ""
        
        if (!isReal(word: word)) {
            errorTitle = "Does not exist"
            errorMessage = "That word does not exist within the English dictionary"
        }
        
        if(!isOriginal(word: word)) {
            errorTitle = "Word already used"
            errorMessage = "That word already exists. Use another"
        }
        
        if(!isPossible(word: word)) {
            guard let title = title else { return }
            errorTitle = "Not Possible"
            errorMessage = "That word cannot be made from \(title.lowercased())"
        }
        
        if(!isNotTooShort(word: word)) {
            errorTitle = "Too Short"
            errorMessage = "The length of the word you have entered is too short"
        }
        
        if(!isNotSameWord(word: word)) {
            errorTitle = "The Same"
            errorMessage = "The same word as the original cannot be used"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(ac, animated: true)
    }

}

