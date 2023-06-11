//
//  HRDGame.h
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/7.
//

#ifndef HRDGame_h
#define HRDGame_h

#import <UIKit/UIKit.h>


@interface HRDTile : NSObject

@property (nonatomic, strong) UIView* view;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int leftIndex;
@property (nonatomic) int topIndex;
@property (nonatomic) int initialLeft;
@property (nonatomic) int initialTop;

@end


typedef struct TileRange {
    int minLeft;
    int maxLeft;
    int minTop;
    int maxTop;
} TileRange;

typedef enum {
    DragHorizontal, DragVerticel, NotSet
} DragDirection;

@interface DragState : NSObject

@property (nonatomic, weak) HRDTile* tile;
@property (nonatomic) int i;
@property (nonatomic) int j;
@property (nonatomic) DragDirection dir;
@property (nonatomic) TileRange range;

@end



@interface HRDGame : NSObject

@property (nonatomic, strong) NSMutableArray* tiles;
@property (nonatomic, strong) DragState* drag;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (void)addTileAtRow:(int)row andCol:(int)col andWidth:(int)width andHeight:(int)height andView:(UIView*)view;
- (void)setDraggedTileAtRow:(int)row andCol:(int)col;
- (void)clearDragState;
- (void)reset;

- (BOOL)win;

@end

#endif /* HRDGame_h */
