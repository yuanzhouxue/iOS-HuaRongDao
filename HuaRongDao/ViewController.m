//
//  ViewController.m
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/2.
//

#import "ViewController.h"
#import "Masonry.h"


#define CLIP(a, min, max) MAX(min, MIN(a, max))


typedef struct TileRange {
    int minLeft;
    int maxLeft;
    int minTop;
    int maxTop;
} TileRange;

typedef enum {
    DragHorizontal, DragVerticel, NotSet
} DragDirection;


@interface HRDTile : NSObject

@property (nonatomic, strong) UIView* view;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int leftIndex;
@property (nonatomic) int topIndex;

@end

@implementation HRDTile

- (BOOL)totallyTopTo:(HRDTile*)another {
    return self.topIndex + self.height <= another.topIndex;
}

- (BOOL)totallyLeftTo:(HRDTile*)another {
    return self.leftIndex + self.width <= another.leftIndex;
}
 
@end

@interface DragState : NSObject

@property (nonatomic, weak) HRDTile* tile;
@property (nonatomic) int i;
@property (nonatomic) int j;
@property (nonatomic) DragDirection dir;
@property (nonatomic) TileRange range;

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




@interface HRDGame : NSObject

@property (nonatomic, strong) NSMutableArray* tiles;

@end

@implementation HRDGame

- (instancetype)init {
    if (self = [super init]) {
        self.tiles = [[NSMutableArray alloc] init];
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
    [self.tiles addObject:tile];
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
        0, 4 - tile.width, 0, 4 - tile.height
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

@end





@interface ViewController ()

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) HRDGame* game;
@property (nonatomic, strong) DragState* dragState;
@property (nonatomic) CGFloat unit;

@end

@implementation ViewController

//UIView* containerView;
NSMutableArray* board;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dragState = [[DragState alloc] init];
    board = [[NSMutableArray alloc] initWithCapacity:4];
//    [board addObject:[[NSMutableArray alloc] initWithCapacity:4]];
    
    board = [@[
        @[@0, @0, @0, @1],
        @[@0, @0, @2, @0],
        @[@0, @0, @0, @0],
        @[@0, @0, @0, @0]
    ] mutableCopy];
    
    self.game = [[HRDGame alloc] init];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = [UIColor grayColor];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(16);
        make.right.equalTo(self.view).with.offset(-16);
//        [self.view layoutIfNeeded];
        make.height.mas_equalTo(self.containerView.mas_width);
        make.centerY.mas_equalTo(0);
        [self.view layoutIfNeeded];
    }];
    [self.containerView layoutIfNeeded];
    self.unit = self.containerView.bounds.size.width / 4;
    
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            if (0 == [board[i][j] intValue]) {
                continue;
            }
            UIView* tileij = [[UIView alloc] initWithFrame:CGRectZero];
            tileij.backgroundColor = [UIColor blueColor];
            tileij.translatesAutoresizingMaskIntoConstraints = NO;
            UILabel* tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.unit, self.unit * 2)];
            tileLabel.text = [NSString stringWithFormat:@"%d", [board[i][j] intValue]];
            tileLabel.textColor = [UIColor whiteColor];
            tileLabel.textAlignment = NSTextAlignmentCenter;
            [tileij addSubview:tileLabel];
            [self.containerView addSubview:tileij];
            [tileij mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).with.offset(j * self.unit);
                make.top.equalTo(self.containerView).with.offset(i * self.unit);
                make.height.mas_equalTo(2 * self.unit);
                make.width.mas_equalTo(self.containerView.mas_width).multipliedBy(0.25);
            }];
            
            [self.game addTileAtRow:i andCol:j andWidth:1 andHeight:2 andView:tileij];
            
        }
    }

    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [self.containerView addGestureRecognizer:pan];
}

- (void)onPanned:(UIPanGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        // 拖拽开始
        // 记录拖拽的方块、起始坐标，计算并记录方块可左右移动的范围
        
        CGPoint startPoint = [recognizer locationInView:recognizer.view];
        int i = (int)(startPoint.y / self.unit);
        int j = (int)(startPoint.x / self.unit);
        
        HRDTile* draggedTile = [self.game tileAtRow:i andCol:j];
        if (nil == draggedTile) {
            return;
        }
        self.dragState.tile = draggedTile;
        self.dragState.i = i;
        self.dragState.j = j;
        self.dragState.range = [self.game tileMovableRange:draggedTile];
    } else if (UIGestureRecognizerStateEnded == recognizer.state || UIGestureRecognizerStateCancelled == recognizer.state) {
        // 拖拽完毕
        // 将刚才拖拽的控件放到格子中
        CGFloat endLeft = [self leftConstraintToParent:self.dragState.tile.view];
        CGFloat endTop = [self topConstraintToParent:self.dragState.tile.view];
        int endI = CLIP((int)(endTop / self.unit + 0.5), self.dragState.range.minTop, self.dragState.range.maxTop);
        int endJ = CLIP((int)(endLeft / self.unit + 0.5), self.dragState.range.minLeft, self.dragState.range.maxLeft);
        CGFloat newTop = endI * self.unit;
        CGFloat newLeft = endJ * self.unit;
        self.dragState.tile.topIndex = endI;
        self.dragState.tile.leftIndex = endJ;
        
        [UIView animateWithDuration:0.005 * (ABS(endLeft - newLeft) + ABS(endTop - newTop)) animations:^{
            [self.dragState.tile.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).with.offset(newLeft);
                make.top.equalTo(self.containerView).with.offset(newTop);
            }];
            [self.dragState.tile.view.superview layoutIfNeeded];
        }];
        
        [self.dragState clear];
    } else if (UIGestureRecognizerStateChanged == recognizer.state) {
        // 拖拽并移动，更新控件位置
        CGPoint translation = [recognizer translationInView:recognizer.view];
        if (self.dragState.dir == NotSet) {
            BOOL isHorizontalDrag = ABS(translation.x) > ABS(translation.y);
            if (isHorizontalDrag) {
                // 判断横向的移动空间进行移动
                self.dragState.dir = DragHorizontal;
            } else {
                // 判断纵向的移动空间
                self.dragState.dir = DragVerticel;
            }
        }
        CGFloat newLeft = [self leftConstraintToParent:self.dragState.tile.view];
        CGFloat newTop = [self topConstraintToParent:self.dragState.tile.view];
        if (DragHorizontal == self.dragState.dir) {
            newLeft = CLIP(newLeft + translation.x, self.dragState.range.minLeft * self.unit, self.dragState.range.maxLeft * self.unit);
        } else {
            newTop = CLIP(newTop + translation.y, self.dragState.range.minTop * self.unit, self.dragState.range.maxTop * self.unit);
        }
        
        [self.dragState.tile.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).with.offset(newLeft);
            make.top.equalTo(self.containerView).with.offset(newTop);
        }];
        // 3. 每次平移手势识别完毕后, 让平移的值不要累加
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

- (CGFloat)leftConstraintToParent:(UIView*)view {
    NSArray* horizontals = [view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal];
    for (NSLayoutConstraint* constraint in horizontals) {
        if (constraint.firstAttribute == NSLayoutAttributeLeft) {
            return constraint.constant;
        }
    }
    return 0.0;
}

- (void)changeConstraintConstant:(UIView*)view andAttr:(NSLayoutAttribute)attr andConstant:(CGFloat)newConstant {
    NSArray* verticals = [view constraints];
    for (NSLayoutConstraint* constraint in verticals) {
        if (attr == constraint.firstAttribute) {
            constraint.constant = newConstant;
        }
    }
}

- (CGFloat)topConstraintToParent:(UIView*)view {
    NSArray* verticals = [view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    for (NSLayoutConstraint* constraint in verticals) {
        if (constraint.firstAttribute == NSLayoutAttributeTop) {
            return constraint.constant;
        }
    }
    return 0.0;
}

@end
