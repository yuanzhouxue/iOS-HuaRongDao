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
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

@end

@implementation HRDGame

- (instancetype)init {
    if (self = [super init]) {
        self.tiles = [[NSMutableArray alloc] init];
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

@end


typedef struct InitialTile {
    int x, y;
    int w, h;
    NSString* name;
    UIColor* textColor;
    UIColor* bgColor;
} InitialTile;



@interface ViewController ()

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) UILabel *movesLabel, *stepsLabel;
@property (nonatomic, strong) HRDGame* game;
@property (nonatomic, strong) DragState* dragState;
@property (nonatomic) CGFloat unit;

@end

@implementation ViewController

//UIView* containerView;
NSMutableArray* board;
int steps = 0;
int moves = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.game = [[HRDGame alloc] init];
    [self initViews];
    
    self.dragState = [[DragState alloc] init];
    
    
    
    
    
}

- (void)initViews {
    board = [[NSMutableArray alloc] initWithCapacity:4];
    board = [@[
        @[@0, @0, @0, @1],
        @[@0, @0, @2, @0],
        @[@0, @0, @0, @0],
        @[@0, @0, @0, @0]
    ] mutableCopy];
    
    InitialTile zhangfei = {0, 0, 1, 2, @"张飞", [UIColor whiteColor], [UIColor grayColor]};
    InitialTile machao = {0, 3, 1, 2, @"马超", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.717 green:0.0 blue:0.0 alpha:1.0]};
    InitialTile zhaoyun = {2, 0, 1, 2, @"赵云", [UIColor blackColor], [[UIColor alloc] initWithRed:1.0 green:0.717 blue:0.0 alpha:1.0]};
    InitialTile huangzhong = {2, 3, 1, 2, @"黄忠", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.396 green:0.159 blue:0.592 alpha:1.0]};
    InitialTile guanyu = {2, 1, 2, 1, @"关羽", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.0 green:0.654 blue:0.278 alpha:1.0]};
    InitialTile zu1 = {4, 0, 1, 1, @"卒", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.0 green:166.0 / 255 blue:237.0 / 255 alpha:1.0]};
    InitialTile zu2 = {3, 1, 1, 1, @"卒", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.0 green:166.0 / 255 blue:237.0 / 255 alpha:1.0]};
    InitialTile zu3 = {3, 2, 1, 1, @"卒", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.0 green:166.0 / 255 blue:237.0 / 255 alpha:1.0]};
    InitialTile zu4 = {4, 3, 1, 1, @"卒", [UIColor whiteColor], [[UIColor alloc] initWithRed:0.0 green:166.0 / 255 blue:237.0 / 255 alpha:1.0]};
    InitialTile caocao = {0, 1, 2, 2, @"曹操", [UIColor blackColor], [[UIColor alloc] initWithRed:116.0 / 255 green:1.0 blue:1.0 alpha:1.0]};
    InitialTile initials[] = {zhangfei, machao, zhaoyun, huangzhong, guanyu, zu1, zu2, zu3, zu4, caocao};
    
    
    UIStackView* screen = [[UIStackView alloc] init];
    screen.axis = UILayoutConstraintAxisVertical;
    screen.distribution = UIStackViewDistributionEqualCentering;
    screen.alignment = UIStackViewAlignmentTop;
    screen.spacing = 8;
    [self.view addSubview:screen];
    [screen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
//        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = [UIColor brownColor];
    self.containerView.layer.borderColor = [UIColor brownColor].CGColor;
    self.containerView.layer.borderWidth = 5;
    self.containerView.layer.cornerRadius = 5;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:self.containerView];
    [screen addArrangedSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(screen);
        make.right.equalTo(screen);
        [screen layoutIfNeeded];
        make.height.mas_equalTo(self.containerView.mas_width).multipliedBy(1.25);
    }];
    [self.containerView layoutIfNeeded];
    self.unit = self.containerView.frame.size.width / 4;

    for (int i = 0; i < 10; ++i) {
        UIView* tileij = [[UIView alloc] initWithFrame:CGRectZero];
        tileij.backgroundColor = initials[i].bgColor;
        tileij.translatesAutoresizingMaskIntoConstraints = NO;
        UILabel* tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.unit * initials[i].w, self.unit * initials[i].h)];
        tileLabel.text = [NSString stringWithFormat:@"%@", initials[i].name];
        tileLabel.font = [UIFont systemFontOfSize:36];
        tileLabel.layer.borderWidth = 1.5;
        tileLabel.layer.borderColor = [UIColor blackColor].CGColor;
        tileLabel.layer.cornerRadius = 2.0;
        tileLabel.textColor = initials[i].textColor;
        tileLabel.textAlignment = NSTextAlignmentCenter;
        [tileij addSubview:tileLabel];
        [self.containerView addSubview:tileij];
        int x = initials[i].x, y = initials[i].y;
        int w = initials[i].w, h = initials[i].h;
        [tileij mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).with.offset(y * self.unit);
            make.top.equalTo(self.containerView).with.offset(x * self.unit);
            make.height.mas_equalTo(h * self.unit);
            make.width.mas_equalTo(w * self.unit);
        }];

        [self.game addTileAtRow:x andCol:y andWidth:initials[i].w andHeight:initials[i].h andView:tileij];
    }
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [self.containerView addGestureRecognizer:pan];

    UIStackView* scoreBoard = [[UIStackView alloc] init];
    scoreBoard.axis = UILayoutConstraintAxisHorizontal;
    scoreBoard.distribution = UIStackViewDistributionFillEqually;
    scoreBoard.alignment = UIStackViewAlignmentCenter;
    scoreBoard.spacing = 10.0;
    self.movesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.movesLabel.text = [NSString stringWithFormat:@"移动次数：%d", moves];
    [scoreBoard addArrangedSubview:self.movesLabel];
    self.stepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.stepsLabel.text = [NSString stringWithFormat:@"移动距离：%d", steps];
    [scoreBoard addArrangedSubview:self.stepsLabel];
    [screen addArrangedSubview:scoreBoard];
    [scoreBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(screen);
        make.right.equalTo(screen);
    }];
    
    
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
        int diffI = ABS(self.dragState.tile.topIndex - endI);
        int diffJ = ABS(self.dragState.tile.leftIndex - endJ);
        if (diffI > 0 || diffJ > 0) {
            moves += 1;
            steps += diffI + diffJ;
            self.movesLabel.text = [NSString stringWithFormat:@"移动次数：%d", moves];
            self.stepsLabel.text = [NSString stringWithFormat:@"移动距离：%d", steps];
        }
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
        if (self.dragState.tile.width == 2 && self.dragState.tile.height == 2 && endI == 3 && endJ == 1) {
            NSLog(@"游戏结束，恭喜您！");
        }
        
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
