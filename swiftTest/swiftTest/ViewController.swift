//
//  ViewController.swift
//  swiftTest
//
//  Created by gaozhimin on 14-12-23.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("hello,world")
        let doubleNumber:Float = 4
        println("test = \(doubleNumber)")
        
        let label = "The width is "
        let width = 94
        let widthLabel = label + String(width)
        println("widthLabel = \(widthLabel)")
        
        var shoppingList = ["catfish","water","tulips","bluepaint"]
        sort(&shoppingList){s1,s2 in return s1>s2}
        println("\(shoppingList)")
        
        let digitNames = [
            0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
        ]
        let numbers1 = [16, 58, 510]
        
        let strings1 = numbers1.map{
            (var number) -> String in
            var output = ""
            while number > 0 {
            output = digitNames[number % 10]! + output
            number /= 10
            }
            return output
        }
        println("\(strings1)")
        var occupations = [
        "Malcolm": "Captain",
        "Kaylee": "Mechanic",]
        NSLog("\(occupations)")
        
        let individulScores = [75 , 43, 103, 87, 12]
        for temp in individulScores
        {
            if temp > 50
            {
            println("\(temp)");
            }
        }
        
        var optionalName: String? = nil
        var greeting = "Hello!"
        if let name = optionalName {
            greeting = "Hello, \(name)"
        }
        else
        {
            greeting = "gzm";
        }
        NSLog("\(greeting)")
        
        let vegetable = "red pepper"
        var vegetableComment :String? = nil
        switch vegetable {
        
        case "celery":
            vegetableComment = "Add some raisins and make ants on a log."
            
        case "cucumber", "watercress":
            
            vegetableComment = "That would make a good tea sandwich."
        case let x where x.hasSuffix("pepper"):
                vegetableComment = "Is it a spicy \(x)?"
        default :
            vegetableComment = "Everything tastes good in soup.";
        
        }
        println("\(vegetableComment!)")
        
        let interestingNumbers = [
        "Prime": [2, 3, 5, 7, 11, 13],
        "Fibonacci": [1, 1, 2, 3, 5, 8],
        "Square": [1, 4, 9, 16, 25],
        ]
        var largest = 0
        for (kind, numbers) in interestingNumbers {
            for number in numbers
            {
                println("\(kind)")
                if number > largest
                {
                    largest = number
                }
            
            }
        }
        println("\(largest)")
        
        var numbers  = 0
        for i in 1...2
        {
            numbers += i;
        }
        println("\(numbers)")
        
        var a = getaverage(1,21,1);
        println("\(a)")
        
        var increment = makeIncrementer ()
        println("\(increment(7,2))")
        
        bibao([1,5,3,12,2])
        
        var test1111 : String = "gzm"
        var test2222 : String = "1989"
        var test = MyClass(test1: test1111,test2: test2222)
        var str = test.testfunc("asdf")
        println("\(str) \(test.temp)")
        test.temp = 10
        println("\(str) \(test.temp)")
        
        var subclass = subClass();
        subclass.testfunc();
        
    }
    
    func hasAnyMatches(list: [Int], condition : Int -> Bool) -> Bool {
        
                    return true
    }
    func bibao(test : [Int]){

        println("\(test)")
                    
    }
    func myfunc(test : Int...) ->Int{
            for number in test
            {
                println("\(number)")
            }
            return 1;
    }
    
    func addOne(number: Int,number1: Int) -> Int {
            return 1 + number + number1
    }
    
    func makeIncrementer() -> ((Int,Int) -> Int) {
            
            return addOne
            
    }
    
    
//    ({
//        (number: Int) -> Int in
//        let result = 3 * number
//        return result
//    })
    
    
    func getaverage(numbers : Int...) ->Int{
                var count = 0
                var sum = 0
                for number in numbers{
                    sum += number
                    count += 1
                }
                return  sum/count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

