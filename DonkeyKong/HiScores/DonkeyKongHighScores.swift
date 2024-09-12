//
//  DonkeyKongHighScores.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import Foundation
import CoreData

var coreDataStack = CoreDataStack(modelName: "HighScores")

public class DonkeyKongHighScores:ObservableObject {
    lazy var managedObjectContext: NSManagedObjectContext = {
        var coreDataStack = CoreDataStack(modelName: "HighScores")
        return CoreDataStack.moc
    }()
    
    var highScoreLetters:[Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var hiScores:[HighScores] = []
    var highScore = 9999
    var newScore = 0
    
    ///New High Score Handling
    @Published
    public var letterIndex = 0
    @Published
    public var letterArray:[Character] = ["A","A","A"]
    @Published
    var selectedLetter = 0
    
    
    public init(){
        resetInput()
        getScores()
    }
    public func resetInput() {
        letterIndex = 0
        selectedLetter = 0
        letterArray = ["A","A","A"]
    }
    
    public func getScores(){
        let fetchRequest: NSFetchRequest<HighScores> = HighScores.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: HighScores.sortByScoreKey,
                                                         ascending: false)]
        fetchRequest.fetchLimit = 10
        do {
            hiScores = try managedObjectContext.fetch(fetchRequest)
            highScore = Int(hiScores[0].score)
        } catch {
            fatalError("Data Fetch Error")
        }
    }
    
    public func addScores(score:Int,initials:String){
        
        let newHighScore:HighScores = HighScores.init(entity: NSEntityDescription.entity(forEntityName: "HighScores", in:managedObjectContext)!, insertInto: managedObjectContext)
        newHighScore.initials = initials
        newHighScore.score = Int32(score)
        self.managedObjectContext.insert(newHighScore)
        do {
            try self.managedObjectContext.save()
        }
        catch {
            print("Error saving new score")
        }
    }
    
    public func removeScores(){
        
    }
    
    public func isNewHiScore(score:Int) -> Bool {
        self.newScore = score
        for s in hiScores {
            if s.score < Int16(score) {
                return true
            }
        }
        return false
    }
    
    public func addLetter(){
        self.letterArray[self.letterIndex] = highScoreLetters[self.selectedLetter]
    }
    
    public func letterUp() {
        self.selectedLetter += 1
        if self.selectedLetter == 26 {
            self.selectedLetter = 0
        }
        letterArray[self.letterIndex] = highScoreLetters[self.selectedLetter]
    }
    
    public func letterDown() {
        self.selectedLetter -= 1
        if self.selectedLetter == -1 {
            self.selectedLetter = 25
        }
        letterArray[self.letterIndex] = highScoreLetters[self.selectedLetter]
    }
    
    public func nextLetter() {
        self.letterIndex += 1
        self.selectedLetter = 0
        /// Final letter and store it
        if self.letterIndex == 3 {
            addScores(score: newScore, initials: String(self.letterArray))
            getScores()
            NotificationCenter.default.post(name: .notificationNewGame, object: nil)
        }
    }
}
