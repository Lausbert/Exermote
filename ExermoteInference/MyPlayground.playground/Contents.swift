import Darwin

var simpleArr : [Int] = []

for i in 2...100 {
    simpleArr.append(i)
}


func arrayEcludingDivingByP (p: Int, arrToCheck : [Int]) -> Array<Int>{
    
    var  tmp : [Int] = []
    
    for (index, element) in arrToCheck.enumerated() {
        
        if element <= p {
            tmp.append(element)
            continue
        }
        
        let isDividible : Bool = element % p == 0 ? true : false
        
        if (!isDividible){
            tmp.append(element)
        }
    }
    
    return tmp
}

var p : Int = 2


func getSimpleNumbersArrayFromArray (p : Int, arrPassed : [Int]) -> Array <Int>{
    
    var tmp : [Int] = []
    
    let newArr = arrayEcludingDivingByP(p: p, arrToCheck: arrPassed)
    
    if (Double(p)>sqrt(Double(newArr.max()!))){
        tmp = newArr
        
    }   else {
        let newP = p + 1
        tmp = getSimpleNumbersArrayFromArray(p: newP, arrPassed: newArr)
        print("tmp array? \(tmp)")
        
    }
    
    return tmp
    
    
}

getSimpleNumbersArrayFromArray(p: p, arrPassed: simpleArr)
