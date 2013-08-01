//
//  FVFileValidator.m
//  FileValidator
//
//  Created by Samir Hadi on 25/02/13.
//  Copyright (c) 2013 Samir Hadi. All rights reserved.
//

#import "FVFileValidator.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const fingerprintFile = @"fingerprints";

@interface FVFileValidator()

@property (nonatomic, copy) NSString *secret;

@end

@implementation FVFileValidator


+ (FVFileValidator *)validator
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString*)unObfuscateSecret:(NSString *)obfuscatedSecret
{
    NSString *theSecret = nil;

    int len = [obfuscatedSecret length];
    char *obfuscatedSecretArr = [obfuscatedSecret UTF8String];
    char unobfuscatedSecret[64];

    int ptr = 0;

    // get the first 32 prime numbered characters from the obfuscated Secret :)
    for (int i = 2; i < len; i++)
    {
        BOOL isPrime = YES;
        for (int j = 2; j < i; j++)
        {
            if ( i % j == 0 )
                isPrime = NO;
        }

        if ( isPrime && ptr < 32 )
        {
            unobfuscatedSecret[ptr++] = obfuscatedSecretArr[i];
            unobfuscatedSecret[ptr] = 0;
            if ( ptr == 32 )
                break;
        }
    }

    theSecret = [NSString stringWithCString:unobfuscatedSecret encoding:NSASCIIStringEncoding];
    return theSecret;
}

+ (void)setObfuscatedSecret:(NSString *)obfuscatedSecret
{
    [FVFileValidator setSecret:[FVFileValidator unObfuscateSecret:obfuscatedSecret]];
}

+ (void)setSecret:(NSString *)secret
{
    [FVFileValidator validator].secret = secret;
}

+ (BOOL)validateFile:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fingerprintFile ofType:@"plist"];
    NSDictionary *fingerDic = [NSDictionary dictionaryWithContentsOfFile:path];

    if(!fingerDic)
    {
        [NSException raise:NSObjectNotAvailableException format:@"file %@.plist not found", fingerprintFile];
    }
    
    NSString *expectedHash = [fingerDic objectForKey:fileName];
    if(!expectedHash)
    {
       [NSException raise:NSInternalInconsistencyException format:@"file %@ not present in %@", fileName, fingerprintFile];
    }
    
    if( [self validateFile:fileName expectedHash:expectedHash] )
    {
        NSLog(@"file is valid!");
        return YES;
    }
    else
    {
        NSLog(@"invalid");
        return NO;
    }
}

#pragma mark - private interface

+ (BOOL)validateFile:(NSString *)fileName expectedHash:(NSString *)expectedHash
{
    NSString *hash = [self SHA2ofFile:fileName];
    
    NSLog(@"%@", hash);
    
    if([hash caseInsensitiveCompare:expectedHash] == NSOrderedSame)
        return YES;
    return NO;
}

+ (NSString *)SHA2ofFile:(NSString *)fileName
{
    NSString *fileNameWithoutExt = [[fileName lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [fileName pathExtension];
    NSString *fileToCheck = [[NSBundle mainBundle] pathForResource:fileNameWithoutExt ofType:extension];
    
    NSMutableData *fileData = [NSMutableData dataWithContentsOfFile:fileToCheck];
    
    NSString *secret = [FVFileValidator validator].secret;
    if(!secret)
    {
        [NSException raise:NSGenericException format:@"you need to provide a secret using setSecret:"];
    }
    
    [fileData appendData:[secret dataUsingEncoding:NSUTF8StringEncoding]];
     
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if( CC_SHA256([fileData bytes], [fileData length], hash) )
    {
        NSString *result = [NSString stringWithFormat:
                            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                            hash[0],hash[1],hash[2],hash[3],
                            hash[4],hash[5],hash[6],hash[7],
                            hash[8],hash[9],hash[10],hash[11],
                            hash[12],hash[13],hash[14],hash[15],
                            hash[16],hash[17],hash[18],hash[19],
                            hash[20],hash[21],hash[22],hash[23],
                            hash[24],hash[25],hash[26],hash[27],
                            hash[28],hash[29],hash[30],hash[31]
                            ];
        return result;
    }
    
    return nil;
}
@end
