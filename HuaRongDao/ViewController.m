//
//  ViewController.m
//  HuaRongDao
//
//  Created by 薛元洲 on 2023/6/2.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ConfigLoader.h"
#import "HRDGame.h"

#define CLIP(a, min, max) MAX(min, MIN(a, max))


@interface ViewController ()

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) UILabel *movesLabel, *stepsLabel;
@property (nonatomic, strong) HRDGame* game;
@property (nonatomic) CGFloat unit;
@property (nonatomic) int numMoves, numSteps;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.game = [[HRDGame alloc] init];
    [self initViews];
}

- (void)initViews {
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
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    
    UIView* titleBar = [[UIView alloc] initWithFrame:CGRectZero];
    [screen addArrangedSubview:titleBar];
    
    UIImageView* title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"huarongdao"]];
    UIImageView* help = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help"]];
    [titleBar addSubview:title];
    [titleBar addSubview:help];
    [titleBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(screen);
        make.height.mas_equalTo(title.mas_height);
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(titleBar);
    }];
    [help mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(title.mas_right);
        make.bottom.equalTo(titleBar);
    }];
    help.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpClicked:)];
    [help addGestureRecognizer:tapRecog];
    
    // 绘制棋盘
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = [UIColor brownColor];
    self.containerView.layer.borderColor = [UIColor brownColor].CGColor;
//    self.containerView.layer.borderWidth = 5;
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

    // 加载棋盘中各个方块
    NSDictionary* config = [ConfigLoader loadConfig:@"TileLocations"];
    NSArray* scenarios = config[@"scenarios"];
    NSDictionary* bgColors = config[@"bgColor"];
    NSDictionary* textColors = config[@"textColor"];
    for (NSDictionary* tile in scenarios[0][@"pos"]) {
        NSString* tilename = tile[@"name"];
        int x = [(NSNumber*)tile[@"x"] intValue];
        int y = [(NSNumber*)tile[@"y"] intValue];
        int width = [(NSNumber*)tile[@"width"] intValue];
        int height = [(NSNumber*)tile[@"height"] intValue];
        NSDictionary* bgColor = bgColors[tilename];
        NSDictionary* textColor = textColors[tilename];
        
        UIView* tileij = [[UIView alloc] initWithFrame:CGRectZero];
        tileij.backgroundColor = [UIColor colorWithRed:[(NSNumber*)bgColor[@"red"] doubleValue] green:[(NSNumber*)bgColor[@"green"] doubleValue] blue:[(NSNumber*)bgColor[@"blue"] doubleValue] alpha:1.0];
        tileij.layer.borderWidth = 1.5;
        tileij.layer.borderColor = [UIColor blackColor].CGColor;
        tileij.layer.cornerRadius = 5;
        tileij.translatesAutoresizingMaskIntoConstraints = NO;
        UILabel* tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.unit * width, self.unit * height)];
        tileLabel.text = [NSString stringWithFormat:@"%@", tilename];
        tileLabel.font = [UIFont systemFontOfSize:36];
        tileLabel.textColor = [UIColor colorWithRed:[(NSNumber*)textColor[@"red"] doubleValue] green:[(NSNumber*)textColor[@"green"] doubleValue] blue:[(NSNumber*)textColor[@"blue"] doubleValue] alpha:1.0];
        tileLabel.textAlignment = NSTextAlignmentCenter;
        [tileij addSubview:tileLabel];
        [self.containerView addSubview:tileij];
        [tileij mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).with.offset(y * self.unit);
            make.top.equalTo(self.containerView).with.offset(x * self.unit);
            make.height.mas_equalTo(height * self.unit);
            make.width.mas_equalTo(width * self.unit);
        }];

        [self.game addTileAtRow:x andCol:y andWidth:width andHeight:height andView:tileij];
    }
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [self.containerView addGestureRecognizer:pan];

    UIStackView* scoreBoard = [[UIStackView alloc] init];
    scoreBoard.axis = UILayoutConstraintAxisHorizontal;
    scoreBoard.distribution = UIStackViewDistributionFill;
    scoreBoard.alignment = UIStackViewAlignmentCenter;
    scoreBoard.spacing = 10.0;
    UILabel* levelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    levelNameLabel.text = [NSString stringWithFormat:@"%@", scenarios[0][@"name"]];
    [scoreBoard addArrangedSubview:levelNameLabel];
    
    self.movesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [scoreBoard addArrangedSubview:self.movesLabel];
    self.stepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [scoreBoard addArrangedSubview:self.stepsLabel];
    
    [screen addArrangedSubview:scoreBoard];
    [scoreBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(screen);
        make.right.equalTo(screen);
    }];
    
    // add observers to auto-update view
    [self addObservers];
    self.numSteps = self.numMoves = 0;
}

-(void)helpClicked:(UITapGestureRecognizer*)gesture {
    UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"help_vc"];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:controller animated:true completion:nil];
}

- (void)onPanned:(UIPanGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        // 拖拽开始
        // 记录拖拽的方块、起始坐标，计算并记录方块可左右移动的范围
        CGPoint startPoint = [recognizer locationInView:recognizer.view];
        int i = (int)(startPoint.y / self.unit);
        int j = (int)(startPoint.x / self.unit);
        [self.game setDraggedTileAtRow:i andCol:j];
        
    } else if (UIGestureRecognizerStateEnded == recognizer.state || UIGestureRecognizerStateCancelled == recognizer.state) {
        // 拖拽完毕
        // 将刚才拖拽的控件放到格子中
        CGFloat endLeft = [self leftConstraintToParent:self.game.drag.tile.view];
        CGFloat endTop = [self topConstraintToParent:self.game.drag.tile.view];
        int endI = CLIP((int)(endTop / self.unit + 0.5), self.game.drag.range.minTop, self.game.drag.range.maxTop);
        int endJ = CLIP((int)(endLeft / self.unit + 0.5), self.game.drag.range.minLeft, self.game.drag.range.maxLeft);
        int diffI = ABS(self.game.drag.tile.topIndex - endI);
        int diffJ = ABS(self.game.drag.tile.leftIndex - endJ);
        if (diffI > 0 || diffJ > 0) {
            self.numMoves += 1;
            self.numSteps += diffI + diffJ;
        }
        CGFloat newTop = endI * self.unit;
        CGFloat newLeft = endJ * self.unit;
        self.game.drag.tile.topIndex = endI;
        self.game.drag.tile.leftIndex = endJ;
        
        [UIView animateWithDuration:0.005 * (ABS(endLeft - newLeft) + ABS(endTop - newTop)) animations:^{
            [self.game.drag.tile.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).with.offset(newLeft);
                make.top.equalTo(self.containerView).with.offset(newTop);
            }];
            [self.game.drag.tile.view.superview layoutIfNeeded];
        }];
        if ([self.game win]) {
            NSLog(@"游戏结束，恭喜您！");
            [self gameFinish];
        }
        
        [self.game clearDragState];
    } else if (UIGestureRecognizerStateChanged == recognizer.state) {
        // 拖拽并移动，更新控件位置
        CGPoint translation = [recognizer translationInView:recognizer.view];
        if (NotSet == self.game.drag.dir) {
            BOOL isHorizontalDrag = ABS(translation.x) > ABS(translation.y);
            if (isHorizontalDrag) {
                // 判断横向的移动空间进行移动
                self.game.drag.dir = DragHorizontal;
            } else {
                // 判断纵向的移动空间
                self.game.drag.dir = DragVerticel;
            }
        }
        CGFloat newLeft = [self leftConstraintToParent:self.game.drag.tile.view];
        CGFloat newTop = [self topConstraintToParent:self.game.drag.tile.view];
        if (DragHorizontal == self.game.drag.dir) {
            newLeft = CLIP(newLeft + translation.x, self.game.drag.range.minLeft * self.unit, self.game.drag.range.maxLeft * self.unit);
        } else {
            newTop = CLIP(newTop + translation.y, self.game.drag.range.minTop * self.unit, self.game.drag.range.maxTop * self.unit);
        }
        
        [self.game.drag.tile.view mas_updateConstraints:^(MASConstraintMaker *make) {
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

- (CGFloat)topConstraintToParent:(UIView*)view {
    NSArray* verticals = [view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    for (NSLayoutConstraint* constraint in verticals) {
        if (constraint.firstAttribute == NSLayoutAttributeTop) {
            return constraint.constant;
        }
    }
    return 0.0;
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"numMoves" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"numSteps" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"numMoves"];
    [self removeObserver:self forKeyPath:@"numSteps"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"numMoves"]) {
        self.movesLabel.text = [NSString stringWithFormat:@"移动次数：%d", self.numMoves];
    } else if ([keyPath isEqualToString:@"numSteps"]) {
        self.stepsLabel.text = [NSString stringWithFormat:@"移动距离：%d", self.numSteps];
    }
}

- (void)gameFinish {
    NSString* msg = [NSString stringWithFormat:@"曹操成功逃出华容道！\n移动方块次数：%d\n移动方块距离：%d", self.numMoves, self.numSteps];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恭喜"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击确定按钮后的处理逻辑
        [self reset];
    }];

    [alertController addAction:okAction];
    // 在视图控制器中弹出警告框
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reset {
    [self.game reset];
    [UIView animateWithDuration:0.5 animations:^{
        for (HRDTile* tile in self.game.tiles) {
            [tile.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).with.offset(tile.leftIndex * self.unit);
                make.top.equalTo(self.containerView).with.offset(tile.topIndex * self.unit);
            }];
        }
        [self.containerView layoutIfNeeded];
    }];
    self.numSteps = self.numMoves = 0;
}

@end
