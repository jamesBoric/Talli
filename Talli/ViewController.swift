//
//  ViewController.swift
//  Talli
//
//  Created by James Boric on 24/12/2015.
//  Copyright © 2015 Ode To Code. All rights reserved.
//
import CoreData
import UIKit

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var allTallies: UIScrollView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var newTally : NSManagedObject?
    
    var selectedTally : NSManagedObject?
    
    var currentDisplayedIndex = 0
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchController: NSFetchedResultsController = NSFetchedResultsController()
    
    func generateFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Tally")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func fetch() -> NSFetchedResultsController {
        
        fetchController = NSFetchedResultsController(fetchRequest: generateFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchController
    
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
    
        super.viewDidAppear(animated)
        
        fetchController = fetch()
        
        fetchController.delegate = self
        
        do {
        
            try fetchController.performFetch()
        
        }
        
        catch {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        
        }
        
        let numberOfTallies = fetchController.sections![0].numberOfObjects
        
        pageControl.numberOfPages = numberOfTallies + 1
        
        allTallies.contentSize.width = allTallies.frame.size.width * CGFloat(numberOfTallies + 1)
    
        for i in 0..<numberOfTallies + 1 {
            
            let inset: CGFloat = 10
            
            let containerView = UIView(frame: CGRectMake(allTallies.frame.size.width * CGFloat(i), 0, allTallies.frame.size.width, allTallies.frame.size.height))
            containerView.tag = i
            
            let tallyNameButton = UIButton(
        
                frame: generateMiddleRect(containerView, inset: inset)
            
            )
            
            tallyNameButton.backgroundColor = UIColor.blackColor()
            
            tallyNameButton.layer.cornerRadius = tallyNameButton.frame.size.height / 2
            
            tallyNameButton.addTarget(self, action: "didSelectBubble:", forControlEvents: UIControlEvents.TouchDown)
            
            tallyNameButton.addTarget(self, action: "didTouchUpInsideButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
            tallyNameButton.addTarget(self, action: "dragOutsideButton:", forControlEvents: .TouchDragExit)
            
            if i == 0 {
            
                tallyNameButton.setTitle("+1", forState: UIControlState.Normal)
            
            }
            
            else {
            
                let myValues = fetchController.objectAtIndexPath(NSIndexPath(forItem: i - 1, inSection: 0)).valueForKey("values") as! [Int]
                
                var total = 0
                
                for i in myValues {
                
                    total += i
                
                }
                
                tallyNameButton.setTitle("\(total)", forState: UIControlState.Normal)
                
                let longPressToDelete = UILongPressGestureRecognizer(target: self, action: "wouldLikeToDelete:")
                
                tallyNameButton.addGestureRecognizer(longPressToDelete)
            
            }
            
            tallyNameButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            tallyNameButton.titleLabel?.font = UIFont.systemFontOfSize(100)
            
            let newTallyLabel = UILabel(
            
                frame: CGRectMake(
                
                    0,
                    
                    tallyNameButton.frame.origin.y + tallyNameButton.frame.size.height * 1.8 / 3 + 20,
                    
                    allTallies.frame.size.width,
                    
                    30
                
                )
            
            )
            
            newTallyLabel.textColor = UIColor.whiteColor()
            
            if i == 0 {
            
                newTallyLabel.text = "Add a new Tally"
            
            }
            
            else {
            
                let myString = fetchController.objectAtIndexPath(NSIndexPath(forItem: i - 1, inSection: 0)).valueForKey("name")!
                
                newTallyLabel.text = "\(myString)"
            
            }
            
            newTallyLabel.font = UIFont.systemFontOfSize(25)
            
            newTallyLabel.textAlignment = .Center
            
            newTallyLabel.layer.zPosition = 9
            
            containerView.addSubview(newTallyLabel)
            
            containerView.addSubview(tallyNameButton)
            
            allTallies.addSubview(containerView)
            
        }
        
    }
    
    func wouldLikeToDelete(sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete Tally",
            
            message: "Would you like to delete this tally?",
            
            preferredStyle: .Alert
        
        )
        
        let cancelAction = UIAlertAction(title: "Cancel",
        
            style: .Cancel) { (action: UIAlertAction) -> Void in
        
        }
        
        let saveAction = UIAlertAction(title: "Delete",
        
            style: .Default,
            
            handler: { (action:UIAlertAction) -> Void in
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.allTallies.viewWithTag(self.currentDisplayedIndex)?.alpha = 0
                    
                    for n in 0..<self.fetchController.sections![0].numberOfObjects + 1 {
                    
                        if n > self.currentDisplayedIndex {
                        
                            self.allTallies.viewWithTag(n)?.frame.origin.x -= self.allTallies.frame.size.width
                            
                            
                        }
                    }
                    
                    self.allTallies.contentSize.width -= self.allTallies.frame.size.width
                    
                    self.pageControl.numberOfPages -= 1
                    }, completion: { (Bool) in
                        self.allTallies.viewWithTag(self.currentDisplayedIndex)?.removeFromSuperview()
                        
                        for l in 0..<self.fetchController.sections![0].numberOfObjects + 1 {
                            if l > self.currentDisplayedIndex {
                                self.allTallies.viewWithTag(l)?.tag -= 1
                            }
                        }
                        
                        self.context.deleteObject(self.fetchController.objectAtIndexPath(NSIndexPath(forItem: self.currentDisplayedIndex - 1, inSection: 0)) as! NSManagedObject)
                        
                        self.currentDisplayedIndex = Int(self.allTallies.contentOffset.x / self.allTallies.frame.size.width)
                        
                        self.fetchController = self.fetch()
                        
                        self.fetchController.delegate = self
                        
                        do {
                            
                            try self.fetchController.performFetch()
                        }
                            
                        catch {
                            
                            print("ERROR")
                        }
                        
                        self.scrollViewDidEndDecelerating(self.allTallies)
                })
                
                
                
                
                
                
                
        })
        
        alert.addAction(saveAction)
        
        alert.addAction(cancelAction)
        
        presentViewController(alert,
        
            animated: true,
            
            completion: nil
        )

    }
    
    func dragOutsideButton(sender: UIButton) {
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            
            sender.frame = self.generateMiddleRect(sender.superview!, inset: 10)
            
        }, completion: nil)
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        
        cornerRadiusAnimation.duration = 0.2
        
        cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        cornerRadiusAnimation.toValue = sender.frame.size.width / 2
        
        cornerRadiusAnimation.fillMode = kCAFillModeForwards
        
        cornerRadiusAnimation.removedOnCompletion = false
        
        sender.layer.addAnimation(cornerRadiusAnimation, forKey: "cornerRadius")
    
    }
    
    func didTouchUpInsideButton(sender: UIButton) {
        
        let substituteView = sender
        
        substituteView.frame = generateMiddleRect(view, inset: 25)
        
        view.addSubview(substituteView)
        
        let newTallyLabelTemp = UILabel(
            
            frame: CGRectMake(
            
                (view.frame.size.width - 174) / 2,
                
                substituteView.frame.origin.y + substituteView.frame.size.height * 1.8 / 3 + 20,
                
                174,
                
                30
            )
        )
        
        newTallyLabelTemp.textColor = UIColor.whiteColor()
        
        if currentDisplayedIndex == 0 {
        
            newTallyLabelTemp.text = "Add a new Tally"
        
        }
            
        else {
            
            let myString = fetchController.objectAtIndexPath(NSIndexPath(forItem: currentDisplayedIndex - 1, inSection: 0)).valueForKey("name")!
            
            newTallyLabelTemp.text = "\(myString)"

        }
        
        newTallyLabelTemp.font = UIFont.systemFontOfSize(25)
        
        newTallyLabelTemp.textAlignment = .Center
        
        view.addSubview(newTallyLabelTemp)

        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
        
            let radius = sqrt(pow(self.view.frame.size.width, 2) + pow(self.view.frame.size.height, 2)) / 2
            
            substituteView.frame = CGRectMake(
            
                self.view.frame.size.width / 2 - radius,
                
                self.view.frame.size.height / 2 - radius,
                
                radius * 2,
                
                radius * 2
            
            )
            
            substituteView.backgroundColor = UIColor(red: 85 / 255, green: 203 / 255, blue: 119 / 255, alpha: 1)
            
            }, completion: { (Bool) in
                
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: {
            
                    newTallyLabelTemp.frame.origin = CGPointMake(20, 20)
                    
                    }, completion: { (Bool) in
                    
                        if self.currentDisplayedIndex == 0 {
                        
                            self.performSegueWithIdentifier("newTallySegue", sender: self)
                        
                        }
                            
                        else {
                        
                            self.performSegueWithIdentifier("createdTally", sender: self)
                        
                        }
                        
                })
                
            })
        
        
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        
        cornerRadiusAnimation.duration = 0.2
        
        cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        cornerRadiusAnimation.toValue = sender.frame.size.width / 2
        
        cornerRadiusAnimation.fillMode = kCAFillModeForwards
        
        cornerRadiusAnimation.removedOnCompletion = false
        
        sender.layer.addAnimation(cornerRadiusAnimation, forKey: "cornerRadius")
        
    }
    
    func didSelectBubble(sender: UIButton) {
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            
            sender.frame = self.generateMiddleRect(self.allTallies, inset: 25)
        
            sender.frame.origin.x = 25
            
        }, completion: nil)
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        
        cornerRadiusAnimation.duration = 0.2
        
        cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        cornerRadiusAnimation.toValue = sender.frame.size.width / 2
        
        cornerRadiusAnimation.fillMode = kCAFillModeForwards
        
        cornerRadiusAnimation.removedOnCompletion = false
        
        sender.layer.addAnimation(cornerRadiusAnimation, forKey: "cornerRadius")
        
    }
    
    func generateMiddleRect(container: UIView, inset: CGFloat) -> CGRect {
        
        return CGRectMake(
        
            inset,
            
            (container.frame.size.height - container.frame.size.width) / 2 + inset,
            
            container.frame.size.width - 2 * inset,
            
            container.frame.size.width - 2 * inset
        )
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        currentDisplayedIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        pageControl.currentPage = currentDisplayedIndex
        
        if currentDisplayedIndex > 0 {
        
            UIView.animateWithDuration(0.1, animations: {
            
                self.nameLabel.alpha = 0
                
                }, completion: { (Bool) in
                    
                    let num = self.fetchController.objectAtIndexPath(NSIndexPath(forItem: self.currentDisplayedIndex - 1, inSection: 0)).valueForKey("values")! as! [Int]
                    
                    if num.count == 1 {
                    
                        self.nameLabel.text = "\(num.count) tally"
                    
                    }
                    
                    else {
                    
                        self.nameLabel.text = "\(num.count) tallies"
                    
                    }
                    
                    UIView.animateWithDuration(0.1, animations: {
                    
                        self.nameLabel.alpha = 1
                    
                    })
                    
            })
            
        }
        
        else {
        
            UIView.animateWithDuration(0.1, animations: {
            
                self.nameLabel.alpha = 0
                
                }, completion: { (Bool) in
                    
                    self.nameLabel.text = ""
                    
            })
        
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newTallySegue" {
        
            let dest = segue.destinationViewController as! TallyViewController
            
            dest.tallyObject = newTally
            
            dest.isBrandNew = true
            
        }
        
        else if segue.identifier == "createdTally" {
        
            let dest = segue.destinationViewController as! TallyViewController
            
            let object = fetchController.objectAtIndexPath(NSIndexPath(forItem: currentDisplayedIndex - 1, inSection: 0)) as! NSManagedObject
            
            dest.tallyObject = object
            
            dest.isBrandNew = false
           
        }
    
    }

}

