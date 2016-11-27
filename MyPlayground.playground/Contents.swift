//: Playground - noun: a place where people can play

import Cocoa

struct Container {
    var value = ""
}
var c = Container()
c.value = "1"

class Test {
    var c: Container
    init(cont: inout Container) {
        self.c = cont
    }
    func change(val: String) {
        self.c.value = val
    }
}

var t = Test(cont: &c)
print(c.value)
print(t.c.value)

t.change(val: "3")
print(c.value)
print(t.c.value)

