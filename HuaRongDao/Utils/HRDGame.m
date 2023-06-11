//
//  HRDGame.m
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/7.
//

#import <Foundation/Foundation.h>
#import "HRDGame.h"


@implementation HRDTile

- (BOOL)totallyTopTo:(HRDTile*)another {
    return self.topIndex + self.height <= another.topIndex;
}

- (BOOL)totallyLeftTo:(HRDTile*)another {
    return self.leftIndex + self.width <= another.leftIndex;
}
 
@end



@implementation DragState

- (instancetype)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)clear {
    self.tile = nil;
    self.i = self.j = -1;
    self.dir = NotSet;
}

@end






@implementation HRDGame

- (instancetype)init {
    if (self = [super init]) {
        self.tiles = [[NSMutableArray alloc] init];
        self.drag = [[DragState alloc] init];
        _width = 4;
        _height = 5;
    }
    return self;
}

- (void)addTileAtRow:(int)row andCol:(int)col andWidth:(int)width andHeight:(int)height andView:(UIView*)view {
    HRDTile* tile = [self tileAtRow:row andCol:col];
    if (nil != tile) {
        return;
    }
    tile = [[HRDTile alloc] init];
    tile.view = view;
    tile.width = width;
    tile.height = height;
    tile.leftIndex = col;
    tile.topIndex = row;
    tile.initialLeft = col;
    tile.initialTop = row;
    
    [self.tiles addObject:tile];
}

- (void)setDraggedTileAtRow:(int)row andCol:(int)col {
    HRDTile* draggedTile = [self tileAtRow:row andCol:col];
    if (nil == draggedTile) {
        return;
    }
    self.drag.tile = draggedTile;
    self.drag.i = row;
    self.drag.j = col;
    self.drag.range = [self tileMovableRange:draggedTile];
}

- (void)clearDragState {
    [self.drag clear];
}

- (BOOL)win {
    for (HRDTile* tile in self.tiles) {
        if (tile.width == 2 && tile.height == 2 && tile.leftIndex == 1 && tile.topIndex == 3) {
            return YES;
        }
    }
    return NO;
}

- (HRDTile*)tileAtRow:(int)row andCol:(int)col {
    for (HRDTile* tile in self.tiles) {
        if (tile.leftIndex <= col && col < tile.leftIndex + tile.width
            && tile.topIndex <= row && row < tile.topIndex + tile.height) {
            return tile;
        }
    }
    return nil;
}

- (TileRange)tileMovableRange:(HRDTile*)tile {
    TileRange res = {
        0, _width - tile.width, 0, _height - tile.height
    };
    for (HRDTile* t in _tiles) {
        //
        if (t == tile) continue;
        if ([t totallyLeftTo:tile] && ![t totallyTopTo:tile] && ![tile totallyTopTo:t]) {
            // t 在 tile 的左边
            res.minLeft = MAX(res.minLeft, t.leftIndex + t.width);
        }
        if ([tile totallyLeftTo:t] && ![t totallyTopTo:tile] && ![tile totallyTopTo:t]) {
            // t 在 tile 的左边
            res.maxLeft = MIN(res.maxLeft, t.leftIndex - tile.width);
        }
        if ([t totallyTopTo:tile] && ![t totallyLeftTo:tile] && ![tile totallyLeftTo:t]) {
            res.minTop = MAX(res.minTop, t.topIndex + t.height);
        }
        if ([tile totallyTopTo:t] && ![t totallyLeftTo:tile] && ![tile totallyLeftTo:t]) {
            res.maxTop = MIN(res.maxTop, t.topIndex - tile.height);
        }
    }
    return res;
}

- (void)reset {
    [self clearDragState];
    for (HRDTile* tile in self.tiles) {
        tile.leftIndex = tile.initialLeft;
        tile.topIndex = tile.initialTop;
    }
}

@end
