//
//  main.cpp
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>

#include "tinyxml.h"

typedef enum {
    kInputParameterProgramName = 0,
    kInputParameterInFilePathIdentifier,
    kInputParameterInFilePath,
    kInputParameterOutFilePathIdentifier,
    kInputParameterOutFilePath,
    kInputParameterCount
} kInputParameter;

int main(int argc, const char * argv[])
{
    if( argc < kInputParameterCount ) {
        std::cout << "Usage is --in <infile> --out <outfile>" << std::endl;
        std::cin.get();
        exit(0);
    }
    
    char* inFile = NULL;
    char* outFile = NULL;
    
    std::cout << argv[0] << std::endl;
    
    for(int i= 1; i < argc; i++) {
        if( i+1 != argc ) {
            if(  strcmp(argv[i], "--in") == 0 ) {
                inFile = (char*)argv[i+1];
            }
            else if( strcmp(argv[i], "--out") == 0 ) {
                outFile = (char*)argv[i+1];
            }
        }
    }
    
    if( inFile == NULL || outFile == NULL ) {
        std::cout << "Usage is --in <infile> --out <outfile>" << std::endl;
        std::cin.get();
        exit(0);
    }
    
    TiXmlDocument XMLdoc(inFile);
    bool loadOkay = XMLdoc.LoadFile();
    if( loadOkay ) {
        std::cout << "Successfully loaded file: " << inFile << std::endl;
        TiXmlElement* pRoot = XMLdoc.FirstChildElement("resources");
        if( pRoot ) {
            
            std::ofstream outFileStream;
            outFileStream.open(outFile);
            
            TiXmlElement* pString = pRoot->FirstChildElement("string");
            
            while (pString) {
                
                const char* key = pString->Attribute("name");
                const char* value = pString->GetText();
                
                outFileStream << "/* No description supplied by the engineer */\n";
                outFileStream << "\"" << key << "\" = \"" << value << "\";\n\n";
                
                pString = pString->NextSiblingElement();
            }
            
            outFileStream.close();
            
            std::cout << "Successfully wrote to: " << outFile << std::endl;
        }
        else {
            std::cout << "Could not find document root 'resources' in file: " << inFile << std::endl;
        }
        
    }
    else {
        std::cout << "Could not open: " << inFile << " confirm the file exists and is a valid android strings file" << std::endl;
    }
    
    return 0;
}

