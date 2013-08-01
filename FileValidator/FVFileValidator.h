//
//  FVFileValidator.h
//  FVFileValidator
//
//  Created by Samir Hadi on 25/02/13.
//  Copyright (c) 2013 Samir Hadi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FVFileValidator : NSObject

+ (BOOL)validateFile:(NSString *)fileName;
+ (void)setSecret:(NSString *)secret;

+ (void)setObfuscatedSecret:(NSString *)string;
@end
