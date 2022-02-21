//
//  NSManageObject+Bindings.h
//  ItemFinder
//
//  
//  Copyright (c) 2014 Mangasaur Games. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface NSManagedObject (SafeSetValuesKeysWithDictionary)

-(void)safeSetValuesForKeysWithDictionary:(NSDictionary*)keyedValues;
-(void)safeSetValuesForKeysWithDictionary:(NSDictionary*)keyedValues dateFormatter:(NSDateFormatter*)dateFormatter;

@end
