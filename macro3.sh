#!/usr/bin/envns swift -I /mnt/shared0/source/SwiftHelloGtk/.build/x86_64-unknown-linux/release -lGtk


import Foundation
import Gtk

let myTestFile = "/home/mag/dev2/hspa7/GTK3test.html"

let fm = FileManager.default

let file = "GTK3test.html" //this is the file. we will write to and read from it

print(fm.fileExists(atPath: "/home/mag/dev2/hspa7/GTK3test.html"))

let text = "some text" //just a text

if let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first 
{

    let fileURL = dir.appendingPathComponent(file)

    //writing
    do 
    {
        try text.write(to: fileURL, atomically: false, encoding: .utf8)
        print(fm.currentDirectoryPath)
    }
    catch {/* error handling here */}

    //reading
    do 
    {
        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
        print(text2)
    }
    catch {/* error handling here */}
}


print( try String(contentsOfFile: myTestFile ) as Any )

#/System/swift/usr/bin/swift
