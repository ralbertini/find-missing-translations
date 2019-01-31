//
//  StringManipulation.swift
//  DiffTranslations
//
//  Created by Ronaldo Albertini on 09/01/19.
//  Copyright © 2019 Ronaldo Albertini. All rights reserved.
//

import Cocoa

class StringFilesManager: NSObject {
    
    private var stringFiles:[File] = [File]()
    private var sameFiles:Dictionary<String,[File]> = Dictionary<String,[File]>()
    private var firstfileKeys: Dictionary<String,String> = Dictionary<String,String>()
    private var secondFileKeys: Dictionary<String,String> = Dictionary<String,String>()
    private var missingLines: Dictionary<String,String> = Dictionary<String,String>()
    
    private func getAllStringFiles() {
        
        let folder:Folder = Folder.current
        print(folder.description)
        folder.makeFileSequence(recursive: true, includeHidden: false).forEach { file in
            if let ext = file.extension, ext == "strings" {
                stringFiles.append(file)
            }
        }
    }
    
    private func findSameFiles() {
        
        for f in self.stringFiles {
            
            if sameFiles[f.name] == nil {
                sameFiles[f.name] = [f]
            } else {
                sameFiles[f.name]?.append(f)
            }
        }
    }
    
    private func stringKeys(file: FileReader) -> Dictionary<String,String> {
        
        var lineTuple:Dictionary<String,String> = Dictionary<String,String>()
        
        for line in file {
            
            let l:String = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if l.contains("=") {
                if let key:String = l.components(separatedBy: "=").first, let value = l.components(separatedBy: "=").last {
                    
                    lineTuple[key] = value       
                }
            }
        }
        return lineTuple
    }
    
    private func rodarPorNomesArquivos(arquivos: [File]) {
        
        let folder = Folder.current
        
        try! folder.createSubfolderIfNeeded(withName: "missingTranslations")
        
        for f1 in arquivos {
            
            for f2 in arquivos {
                
                if f2.path != f1.path {
                    
                    guard let file1 = FileReader(path: f1.path), let file2 = FileReader(path: f2.path) else {
                        return
                    }
                    
                    firstfileKeys = stringKeys(file: file1)
                    secondFileKeys = stringKeys(file: file2)
                
                    let fil:File?
                    
                    if let parent1 = f1.parent?.name.components(separatedBy: "/").first, let parent2 = f2.parent?.name.components(separatedBy: "/").first {
                        print("\(parent1) to \(parent2)")
                        
                        fil = try! folder.createFile(named: "\(parent1) to \(parent2).txt")
                        
                        for line in self.getMissingLines(firstFileKeys: firstfileKeys, secondFileKeys: secondFileKeys) {
                            try! fil?.append(string: "\(line.key) = \(line.value)")
                            print("\(line.key) = \(line.value)")
                        }
                    }
                }
            }
        }
    }
    
    private func getMissingLines(firstFileKeys: Dictionary<String,String>, secondFileKeys: Dictionary<String,String>) -> Dictionary<String,String> {
        
        let missingKeys:[String] = firstfileKeys.keys.filter { !secondFileKeys.keys.contains($0)}
        
        var missingTranslations: Dictionary<String, String> = Dictionary<String, String>()
        
        for key in missingKeys {
            missingTranslations[key] = firstFileKeys[key]
            
        }
        return missingTranslations
    }
    
    
    public func teste() {
        
        self.getAllStringFiles()
        self.findSameFiles()
        
        for files in self.sameFiles {
            self.rodarPorNomesArquivos(arquivos: files.value)
        }
    }
}