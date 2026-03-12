//
//  ViewController.swift
//  Milestone3
//
//  Created by Macedo on 09/03/26.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Types
    struct LetterButton {
        var isGuessed: Bool = false
        var isCorrectGuess: Bool = false
    }
    
    // MARK: - UI Components
    private var heartImageViews = [UIImageView]()
    private let wordLabel = UILabel()
    private var letterButtons = [UIButton]()
    
    // MARK: - Private Properties
    private var solution = ""
    private var maskedSolution = ""
    private var lives = 7 {
        didSet {
            if lives >= 0 && lives < heartImageViews.count {
                heartImageViews[lives].isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBrown
        
        loadWords()
        setupLivesLabel()
        setupWordLabel()
        setupAlphabetKeyboard()
    }
    
    func loadWords() {
        guard let wordsFile = Bundle.main.url(
            forResource: "words",
            withExtension: "txt"
        ) else { return }
        
        if let wordsFileContents = try? String(contentsOf: wordsFile, encoding: .utf8) {
            let words = wordsFileContents.split(separator: "\n").map { String($0) }
            
            solution = words.randomElement()?.uppercased() ?? "ERROR"
            maskedSolution = getMaskedWord(from: solution)
        }
    }
    
    func setupLivesLabel() {
        let livesView = UIStackView()
        livesView.axis = .horizontal
        livesView.spacing = 8
        livesView.distribution = .equalCentering
        
        livesView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(livesView)
        
        NSLayoutConstraint.activate([
            livesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            livesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        for i in 0..<7 {
            let heartImage = UIImage(systemName: "heart.fill")
            let imageView = UIImageView(image: heartImage)
            imageView.tintColor = .systemRed
        
            livesView.addArrangedSubview(imageView)
            heartImageViews.append(imageView)
        }
    }
    
    func setupWordLabel() {
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.text = maskedSolution
        wordLabel.textAlignment = .left
        wordLabel.font = .preferredFont(forTextStyle: .title1)
        
        view.addSubview(wordLabel)
        
        NSLayoutConstraint.activate([
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func getMaskedWord(from word: String) -> String {
        return word.map { letter in
            if letter == "-" { return String(letter) }
            return "?"
        }.joined()
    }
    
    func setupAlphabetKeyboard() {
        let buttonsView = UIStackView()
        buttonsView.axis = .vertical
        buttonsView.spacing = 16
        buttonsView.distribution = .fillEqually
        
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let buttonsPerRow = 7
        
        for i in stride(from: 0, to: alphabet.count, by: buttonsPerRow) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            
            let endIndex = min(i + buttonsPerRow, alphabet.count)
            let chunk = alphabet[i..<endIndex]
            
            for char in chunk {
                let button = UIButton(type: .system)
                button.setTitle(String(char), for: .normal)
                button.backgroundColor = .white
                button.layer.cornerRadius = 8
                
                let onPress = UIAction { [weak self] action in
                    guard let button = action.sender as? UIButton,
                          let letter = button.titleLabel?.text,
                          let self = self
                    else { return }
                    
                    button.isEnabled = false
                    
                    if !self.solution.contains(letter) {
                        button.setTitleColor(.systemRed, for: .disabled)
                        
                        self.lives -= 1
                        
                        if self.lives == 0 {
                            self.showGameOverAlert()
                            return
                        }
                    } else {
                        button.setTitleColor(.systemGreen, for: .disabled)
                        
                        var maskedArray = Array(self.maskedSolution)
                        for (index, char) in self.solution.enumerated() {
                            if String(char) == letter {
                                maskedArray[index] = Character(letter)
                            }
                        }
                        
                        self.maskedSolution = String(maskedArray)
                        self.wordLabel.text = self.maskedSolution
                        
                        if !self.maskedSolution.contains("?") {
                            self.showYouWonAlert()
                        }
                    }
                }
                
                button.addAction(onPress, for: .touchUpInside)
                
                rowStack.addArrangedSubview(button)
                letterButtons.append(button)
            }
            
            buttonsView.addArrangedSubview(rowStack)
        }
    }
    
    func showGameOverAlert() {
        let ac = UIAlertController(title: "Game Over!", message: "You lost!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func showYouWonAlert() {
        let ac = UIAlertController(title: "You won!", message: "You correctly guessed the word!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
}
