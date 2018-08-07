//
//  TallyViewController.swift
//  Talli
//
//  Created by James Boric on 30/12/2015.
//  Copyright © 2015 Ode To Code. All rights reserved.
//
import CoreData
import UIKit

class TallyViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tallyNameField: UITextField!
    
    @IBOutlet weak var tallyView: UIView!
    
    @IBOutlet weak var incrementField: UITextField!
    
    var tallyObject : NSManagedObject?
    
    var isBrandNew : Bool = true
    
    var numberOfTallies = 0
    
    var values : [Int]!
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchController: NSFetchedResultsController = NSFetchedResultsController()
    
    var increment = 1
    
    func generateFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Tally")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func fetch() -> NSFetchedResultsController {
        fetchController = NSFetchedResultsController(fetchRequest: generateFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchController
    }

    @IBAction func removeKeyboard(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 30, 30)).CGPath
        circle.strokeColor = UIColor(red: 199 / 255, green: 199 / 255, blue: 205 / 255, alpha: 1).CGColor
        circle.fillColor = UIColor.clearColor().CGColor
        circle.lineWidth = 1
        incrementField.layer.addSublayer(circle)
        
        incrementField.layer.cornerRadius = 15
        
        if isBrandNew {
            
            values = [0]
        }
        
        else {
            
            increment = tallyObject?.valueForKey("increment") as! Int
            
            incrementField.text = "\(increment)"
            
            tallyNameField.text = tallyObject?.valueForKey("name") as? String
            
            values = tallyObject?.valueForKey("values") as! [Int]
            
        }
        
        numberOfTallies = values.count
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        fetchController = fetch()
        fetchController.delegate = self
        
        do {
            try fetchController.performFetch()
        }
        catch {
            print("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        }

        
        layoutTallySquares(numberOfTallies)
    }
    
    func layoutTallySquares(numberOfSquares: Int) {
        isPrimeAbove = false
        
        
        
        for x in tallyView.subviews {
            x.removeFromSuperview()
        }
        var xy = findTwoClosestFactors(factors(numberOfSquares), number: numberOfSquares)
        var xtra = [0, 0]
        
        if isPrimeAbove {
            xy[0] -= 1
            xtra = [1, xy[1] + 1]
            
            
            
        }
        
        let buttonWidth = tallyView.frame.size.width / CGFloat(xy[0] + xtra[0])
        let buttonHeight = tallyView.frame.size.height / CGFloat(xy[1])
        
        for n in 0..<xy[0] {
            for i in 0..<xy[1] {
                
                
                let myButton = UIButton(frame: CGRectMake(buttonWidth * CGFloat(n), buttonHeight * CGFloat(i), buttonWidth, buttonHeight))
                if isPrimeAbove {
                    myButton.tag = (i * (xy[0] + 1)) + n
                }
                else {
                    myButton.tag = i * xy[0] + n
                }
                
                if (i + n) % 2 == 0 {
                    
                    myButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                }
                else {
                    myButton.backgroundColor = UIColor.blackColor()
                    myButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
                
                myButton.setTitle("\(values[myButton.tag])", forState: .Normal)
                myButton.titleLabel?.font = UIFont.systemFontOfSize(70)
                
                myButton.addTarget(self, action: "increment:", forControlEvents: .TouchUpInside)
                
                let panRec = UIPanGestureRecognizer(target: self, action: "incrementByPan:")
                myButton.addGestureRecognizer(panRec)
                
                tallyView.addSubview(myButton)
            }
            
        }
        
        if isPrimeAbove {
            var previousTag = 0
            for l in 0..<xtra[1] {
                let xtraButtonHeight = tallyView.frame.size.height / CGFloat(xtra[1])
                let xtraButton = UIButton(frame: CGRectMake(view.frame.size.width - buttonWidth, CGFloat(l) * xtraButtonHeight, buttonWidth, xtraButtonHeight))
                if l < xtra[1] - 1 {
                    xtraButton.tag = l * (xy[0] + 1) + xy[0]
                    previousTag = l * (xy[0] + 1) + xy[0]
                }
                else {
                    xtraButton.tag = previousTag + 1
                }
                
                if (l + xy[0]) % 2 == 0 {
                    
                    xtraButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    
                }
                else {
                    xtraButton.backgroundColor = UIColor.blackColor()
                    xtraButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
                
                xtraButton.setTitle("\(values[xtraButton.tag])", forState: .Normal)
                xtraButton.titleLabel?.font = UIFont.systemFontOfSize(70)
                xtraButton.addTarget(self, action: "increment:", forControlEvents: .TouchUpInside)
            
                let panRec = UIPanGestureRecognizer(target: self, action: "incrementByPan:")
                xtraButton.addGestureRecognizer(panRec)
                
                tallyView.addSubview(xtraButton)
            }
        }
    }
    
    var originalValue = 0
    
    func incrementByPan(sender: UIPanGestureRecognizer) {
        
        if sender.state == .Began {
           
            originalValue = Int((sender.view as! UIButton).titleForState(.Normal)!)!
            
        }
        
        let trans : Int = Int(-sender.translationInView(sender.view).y) / 5
        
        (sender.view as! UIButton).setTitle("\(originalValue + trans)", forState: .Normal)
        
        values[(sender.view?.tag)!] = originalValue + trans
        
    }
    
    func increment(sender: UIButton) {
        
        incrementField.resignFirstResponder()
        
        increment = Int(incrementField.text!)!
        
        let currentNumber = Int(sender.titleForState(.Normal)!)!
        
        sender.setTitle("\(currentNumber + increment)", forState: .Normal)
        
        values[sender.tag] += increment
    
    }
    
    func findTwoClosestFactors(factors: [[Int]], number: Int) -> [Int] {
        var closestFactors: [Int] = []
        var smallestDifference = number + 1
        
        for i in factors {
            let diff = abs(i[0] - i[1])
            if diff < smallestDifference {
                smallestDifference = diff
                closestFactors = [i[0], i[1]]
            }
        }
        return closestFactors
    }
    
    var isPrimeAbove = false
    func factors(number: Int) -> [[Int]] {
        var factorsArray : [[Int]] = []
        if isPrime(number) == true {
            
            isPrimeAbove = true
            return factors(number - 1)
            
        }
        if number > 0 && isPrime(number) == false {
            for i in 1...Int(ceil(Double(number / 2))) + 1 {
                if number % i == 0 {
                    factorsArray.append([i, number / i])
                }
            }
        }
        return factorsArray
    }
    
    func isPrime(number: Int) -> Bool {
        var factors = 0
        
        if number == 1 || number == 2 || number == 3 {
            return false
        }
        
        for i in 1...number {
            if number % i == 0 {
                
                factors++
            }
        }
        if factors == 2 {
            return true
        }
        return false
    }
    
    @IBAction func addOneTally(sender: UIButton) {
        numberOfTallies += 1
        values.append(0)
        layoutTallySquares(numberOfTallies)
    }
    
    @IBAction func removeOneTally(sender: UIButton) {
        if numberOfTallies > 1 {
            numberOfTallies -= 1
            values.removeLast()
            layoutTallySquares(numberOfTallies)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveToCoreData()
        
    }

    @IBAction func finished(sender: UITextField) {
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func saveToCoreData() {
        
        if isBrandNew {
            
            let newTally = NSEntityDescription.insertNewObjectForEntityForName("Tally", inManagedObjectContext: context)
            
            newTally.setValue(tallyNameField.text!, forKey: "name")
            newTally.setValue(values, forKey: "values")
            newTally.setValue(Int(incrementField.text!)!, forKey: "increment")
            
        }
            
        else {
            let currentTally = fetchController.objectAtIndexPath(fetchController.indexPathForObject(tallyObject!)!)
            currentTally.setValue(values, forKey: "values")
            currentTally.setValue(tallyNameField.text, forKey: "name")
            currentTally.setValue(Int(incrementField.text!)!, forKey: "increment")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
