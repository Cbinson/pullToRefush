//
//  ViewController.swift
//  pull_to_refush
//
//  Created by binsonchang on 2017/6/5.
//  Copyright © 2017年 tw.com.binson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var dataArry:NSMutableArray?

    var refushCtrl:UIRefreshControl?

    var customView:UIView!
    var labelsArray:Array<UILabel> = []


    var isAnimating = false
    var currentColorIndex = 0
    var currentLabelIndex = 0



    var timer: Timer!


    @IBOutlet weak var mainTb: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        self.dataArry = ["1","2","3","4"]

        //加入 refush 元件
        self.initialRefushCtrl()

        //自訂畫面
        self.loadCustomRefreshContents()
    }

    //initial refush ctrl
    func initialRefushCtrl() {
        self.refushCtrl = UIRefreshControl.init()
        self.refushCtrl?.backgroundColor = UIColor.darkGray
        self.refushCtrl?.tintColor = UIColor.green
        self.refushCtrl?.addTarget(self, action: #selector(ViewController.refushData), for: UIControlEvents.valueChanged)

        self.mainTb.addSubview(self.refushCtrl!)
    }

    func refushData() {
        let dataCnt:Int = (self.dataArry?.count)!
        let nData = String.init(format: "%d", dataCnt + 1)

        self.dataArry?.add(nData)

        self.refushCtrl?.endRefreshing()

        self.mainTb.reloadData()
    }

    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)

        self.customView = refreshContents?[0] as! UIView
        self.customView.frame = (self.refushCtrl?.bounds)!

        for i in 1...self.customView.subviews.count {
            labelsArray.append(customView.viewWithTag(i) as! UILabel)
        }

        self.refushCtrl?.addSubview(self.customView)

    }

    func animateRefreshStep1() {
        isAnimating = true

        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform.init(rotationAngle: CGFloat(Float.pi/4))
            self.labelsArray[self.currentLabelIndex].textColor = self.getNextColor()
        }) { (finished) in
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { 
                self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform.identity
                self.labelsArray[self.currentLabelIndex].textColor = UIColor.black
            }, completion: { (finished) in
                self.currentLabelIndex += 1

                if self.currentLabelIndex < self.labelsArray.count {
                    self.animateRefreshStep1()
                }
                else {
                    self.animateRefreshStep2()
                }
            })
        }
    }

    func animateRefreshStep2() {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { 
            for i in 1...self.customView.subviews.count {
                self.labelsArray[i].transform = CGAffineTransform.init(translationX: 1.5, y: 1.5)
            }
        }) { (finished) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                for i in 1...self.customView.subviews.count {
                    self.labelsArray[i].transform = CGAffineTransform.identity
                }
            }) { (finished) in
                if (self.refushCtrl?.isRefreshing)! {
                    self.currentLabelIndex = 0
                    self.animateRefreshStep1()
                }
                else {
                    self.isAnimating = false
                    self.currentLabelIndex = 0
                    for i in 0...self.labelsArray.count {
                        self.labelsArray[i].textColor = UIColor.black
                        self.labelsArray[i].transform = CGAffineTransform.identity
                    }
                }
            }
        }
    }


    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]

        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }

        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }

    func doSomething() {
//        timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "endOfWork", userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ViewController.endOfWork), userInfo: nil, repeats: true)
    }

    func endOfWork() {
        self.refushCtrl?.endRefreshing()

        timer.invalidate()
        timer = nil
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.refushCtrl?.isRefreshing)! {
            if !isAnimating {
                doSomething()
                animateRefreshStep1()
            }
        }
    }

    //Tb data source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataArry?.count)!
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "Cell"

        let cell = self.mainTb.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as UITableViewCell

        cell.textLabel?.text = self.dataArry?[indexPath.row] as? String

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

