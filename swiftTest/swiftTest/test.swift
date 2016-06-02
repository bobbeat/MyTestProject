//
//  test.swift
//  swiftTest
//
//  Created by gaozhimin on 14-12-24.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

import Foundation

enum Myenum : Int
{
    case ace = 1
    case two,Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case jack,queen,king
    func simpledes() -> String{
        switch self{
        case .ace:
            return "ace1"
        case .jack:
            return "jack1"
        case .king:
            return "king1"
        case .queen:
            return "queen1"
        default:
            return String(self.rawValue)
            
        }
    }
}
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}

struct mystruct : ExampleProtocol {
    var value1:Myenum
    var value2:Myenum
    var simpleDescription :String
    func funcstru()->String{
        return "\(value1.rawValue) = \(value2.rawValue)"
    }
   
    mutating  func adjust() {
            simpleDescription = "mystruct ....."
        }
}

enum ServerResponse {
    case Result(String, String)
    case Error(String)
}

extension Int :ExampleProtocol{
        var simpleDescription:String{
            return "extension int"
        }
        mutating func adjust() {
            self += 1
        }
}

class simpleClass:ExampleProtocol {
        var simpleDescription:String = "aaa"
        func adjust() {
             simpleDescription += " Now 100% adjus ted."
        }
    init() {
        self.simpleDescription = "gzm"
    }
}
class Sequence : NSObject {
            var GeneratorType : Int = 1
            override init() {
            
            }
}

class Equatable : NSObject{
    var GeneratorType : Int = 1
                override init() {
    
                }
}

 protocol Named {
         var name: String { get }
}
 protocol Aged{
                    var age:Int{get}
                    
}
                
struct Person: Named, Aged {
    var name: String
    var age: Int
}


class MyClass : NSObject
{
    var testnumber = 10
    var mystr1 : String
    var mystr2 : String
    
    init(test1:String,test2:String) {
        
        self.mystr1 = test1
        self.mystr2 = test2
        super.init()
        
        let possi1 : String? = "12"
        println(possi1!)
        
        let possi2 = "aa"
        let conv2 : Int? = possi2.toInt()
        
        var inte : Int = 1
        inte.adjust()
        println("adjust \(inte.simpleDescription) \(inte)")
        
        let birthday = Person(name: "gzm", age: 1989)
        wishHappyBirthday(birthday)
        
        repeat(1, times:4);
    }               
    func wishHappyBirthday(celebrator: protocol<Named, Aged>) {
        
        println("Happy birthday \(celebrator.name) - you're \(celebrator.age)!")
    }
        func someFunctionThatTakesAClosure(closure: () -> ( )) {
        
        // 函数体部分
         }
        
//        someFunctionThatTakesAClosure({
//         // 闭包主体部分 
//        })
        
//        someFunctionThatTakesAClosure(){
//        
//        }
        
    func repeat<ItemType>(item: ItemType, times: Int) -> [ItemType]
        {
            
        var result = [ItemType]()
            for i in 0...times
        {
            println("\(item)")
                    
            
        }
            return result
            
    }
    
    func testfunc(aaa:String) ->String
    {
        println("\(aaa),\(self.mystr1),\(self.mystr2)")
        return "testfunc"
    }
    
    var temp : Int{
        get{
            return testnumber*5;
        }
        set (newTmp){
            testnumber = newTmp/5
        }
        
    }
    
    
    
    deinit
    {
        println("deinit")
    }
}

class mysuperclass : NSObject {
    func testfunc()
    {
        println("super func")
    }
}

class subClass : mysuperclass {
     override func testfunc() {
        super.testfunc()
         println("sub func")
    }
}
