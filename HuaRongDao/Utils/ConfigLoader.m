//
//  ConfigLoader.m
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/6.
//

#import "ConfigLoader.h"

@implementation ConfigLoader

+ (NSDictionary*)loadConfig:(NSString*)name {
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:path];
    NSError* error;
    NSDictionary* res = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return res;
}

@end
