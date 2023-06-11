//
//  ConfigLoader.h
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/6.
//

#ifndef ConfigLoader_h
#define ConfigLoader_h

#import <Foundation/Foundation.h>

@interface ConfigLoader : NSObject

+ (NSDictionary*)loadConfig:(NSString*)name;

@end


#endif /* ConfigLoader_h */
