//
//  AppDelegate.h
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/2.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

