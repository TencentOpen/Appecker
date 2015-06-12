///////////////////////////////////////////////////////////////////////////////////////////////////////
// Tencent is pleased to support the open source community by making Appecker available.
// 
// Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import "CaseSelectorParser.h"

@implementation SelectedCase

@synthesize caseID;
@synthesize times;

-(void)dealloc
{
    [self.caseID release];
    [super dealloc];
}

@end

@implementation SelectedClass

@synthesize testClassName;
@synthesize selectedCases;
@synthesize times;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        self.selectedCases = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [self.testClassName release];
    [self.selectedCases release];
    [super dealloc];
}

@end

@implementation CaseSelectorParser
@synthesize testClasses;
@synthesize currentProperty;
@synthesize currentClass;
@synthesize currentCase;
@synthesize currentClassAttributes;
@synthesize currentCaseAttributes;

-(void)parseCaseSelector:(NSData *)data parseError:(NSError **)err
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    self.testClasses = [[NSMutableArray alloc] init];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser parse];
    if(err && [parser parserError])
    {
        *err = [parser parserError];
    }
    [parser release];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(self.currentProperty)
    {
        [currentProperty appendString:string];
    }
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(qName)
    {
        elementName = qName;
    }

    if([elementName isEqualToString:@"TestClass"])
    {
        self.currentClass = [[[SelectedClass alloc] init] autorelease];
        self.currentClassAttributes = attributeDict;
    }
    else if([elementName isEqualToString:@"TestCase"])
    {
        self.currentCase = [[[SelectedCase alloc] init] autorelease];
        self.currentCaseAttributes = attributeDict;
        self.currentProperty = [NSMutableString string];
    }


}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qName
{
    if(qName)
    {
        elementName = qName;
    }
    if(self.currentClass)
    {
        if([elementName isEqualToString:@"TestClass"])
        {
            self.currentClass.testClassName = [self.currentClassAttributes objectForKey:@"name"];
            self.currentClass.times = [[self.currentClassAttributes objectForKey:@"times"] intValue];
            if(self.currentClass.times == 0)
            {
                self.currentClass.times = 1;
            }
            [self.testClasses addObject:self.currentClass];
            self.currentClassAttributes = nil;
            self.currentClass = nil;
        }
        else if(self.currentCase)
        {
            if([elementName isEqualToString:@"TestCase"])
            {

                self.currentCase.caseID = [NSString stringWithFormat:@"%@.%@", [self.currentClassAttributes objectForKey:@"name"], self.currentProperty];
                self.currentCase.times = [[self.currentCaseAttributes objectForKey:@"times"] intValue];
                if(self.currentCase.times == 0)
                {
                    self.currentCase.times = 1;
                }
                [self.currentClass.selectedCases addObject:self.currentCase];
                self.currentCaseAttributes = nil;
                self.currentProperty = nil;
                self.currentCase = nil;
            }
        }
    }


}

-(void)dealloc
{
    [self.currentClass release];
    [self.currentProperty release];
    [super dealloc];
}

@end
