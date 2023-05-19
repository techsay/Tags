//
//  TagListViewController.m
//  TagsList
//
//  Created by 聂小波 on 2023/5/18.
//

#import "TagListViewController.h"
#import <Masonry/Masonry.h>
#import "UICollectionViewLeftAlignedLayout.h"

@interface BTagCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *tagLabel;

@end

@implementation BTagCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 6;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.tagLabel];
    }
    return self;
}

- (void)setupData:(NSString *)text {
    self.tagLabel.text = text;
    [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

+ (CGSize)getItemSizeWothText:(NSString *)text {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    return CGSizeMake(MIN(rect.size.width + 10, Screen_Width - 50), rect.size.height + 10);
}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    CGRect rect = [self.tagLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
//    rect.size.width +=10;
//    rect.size.height+=10;
//    attributes.frame = rect;
//    return attributes;
//
//}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.font = [UIFont systemFontOfSize:16];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

@end


@interface BTagsView : UIView <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation BTagsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTagCollectionViewCell" forIndexPath:indexPath];
    [cell setupData:self.datas[indexPath.row]];
    [cell.contentView sizeToFit];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.datas[indexPath.row];
    return [BTagCollectionViewCell getItemSizeWothText:text];
}

#pragma mark - Get

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // 设置列表信息居左显示
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumInteritemSpacing = 6.0;
        layout.minimumLineSpacing = 6.0;
        // ⚠️ 测试下来 estimatedItemSize + preferredLayoutAttributesFittingAttributes 存在各种机型和版本兼容问题，而且对子视图的布局约束很严格，稍有失误可能会出现各种异常
        // 暂用 sizeForItemAtIndexPath + systemLayoutSizeFittingSize
//        layout.estimatedItemSize = CGSizeMake(40.0, 30.0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.userInteractionEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[BTagCollectionViewCell class] forCellWithReuseIdentifier:@"BTagCollectionViewCell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    [self.collectionView reloadData];
}

@end


@interface BTagsUITableViewCell: UITableViewCell

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) BTagsView *tagsView;

@end

@implementation BTagsUITableViewCell

/// 此方法用于更新cell中嵌入collectionView等scrollView变化高度的计算
/// CGSize size = [super systemLayoutSizeFittingSize 返回的是默认布局可确定的高度
/// 由于collectionView高度是变化的，因此需要手动获取。并添加到size中返回，如果有分多个变化的view，需要累加
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize size = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    // 刷新子布局约束
    [self.tagsView.collectionView setNeedsLayout];
    [self.tagsView.collectionView layoutIfNeeded];
    // 获取scrollView高度
    CGFloat height = self.tagsView.collectionView.collectionViewLayout.collectionViewContentSize.height;
    return CGSizeMake(size.width, height + size.height);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubViews];
    }
    return  self;
}

- (void)setupSubViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.tagsView];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    self.tagsView.datas = datas;
}

#pragma mark - Get

- (BTagsView *)tagsView {
    if (!_tagsView) {
        _tagsView = [BTagsView new];
    }
    return _tagsView;
}

@end

@interface TagListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation TagListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithUI];
}

- (void)initWithUI {
    self.title = @"列表";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
    titleLabel.text = [NSString stringWithFormat:@"Section %lld", (long long)section];
    titleLabel.backgroundColor = [UIColor lightGrayColor];
    return titleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BTagsUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BTagsUITableViewCell.class)];
    cell.datas = self.dataSource[indexPath.section];
    return  cell;
}

#pragma mark - Get

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 30.0f;
        _tableView.sectionHeaderHeight = 30.0f;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        } else {
            // Fallback on earlier versions
        }
        [_tableView registerClass:[BTagsUITableViewCell class] forCellReuseIdentifier:NSStringFromClass(BTagsUITableViewCell.class)];
    }
    return _tableView;
}

- (NSArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = @[@[@"北京北京北京",@"上海上海上海",@"广州",@"深圳深",@"杭州",@"成都",@"天津"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"北京北京北京",@"上海上海上海",@"广州",@"深圳深",@"杭州",@"成都",@"天津"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"绵阳",@"绵阳",@"绵阳阳贵阳贵",@"绵阳",@"绵阳",@"绵阳",@"绵阳"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"北京北京北京",@"上海上海上海",@"广州",@"深圳深",@"杭州",@"成都",@"天津"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"绵阳",@"绵阳",@"绵阳阳贵阳贵",@"绵阳",@"绵阳",@"绵阳",@"绵阳"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"北京北京北京",@"上海上海上海",@"广州",@"深圳深",@"杭州",@"成都",@"天津"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"绵阳",@"绵阳",@"绵阳阳贵阳贵",@"绵阳",@"绵阳",@"绵阳",@"绵阳"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"北京北京北京",@"上海上海上海",@"广州",@"深圳深",@"杭州",@"成都",@"天津"],
                        @[@"重庆",@"武汉",@"贵阳贵阳贵阳贵阳",@"郑州",@"济南",@"西安",@"合肥",@"南京",@"南宁",@"太原",@"昆明",@"福州"],
                        @[@"宁波",@"青岛",@"众所周知，iOS设备已良好的用户体验赢得了广大的用户群。iOS系统在用户点击屏幕会立即做出响应。而且很大一部分的操作是来自于用户的滑动操作。所以滑动的顺滑是使用户沉浸在app中享受的必要条件。接下来我们就谈谈iOS 10 中增加了那些新特性。",@"珠海",@"厦门",@"上海",@"烟台"],
                        @[@"金堂",@"金牛",@"内江",@"高新阳贵阳贵",@"合肥",@"合肥",@"合肥"],
                        @[@"合肥",@"合肥",@"合肥阳贵阳贵阳贵阳贵",@"昆明阳贵阳贵",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明",@"昆明"],
                        @[@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"珠海",@"阳贵阳贵珠海"],
                        @[@"绵阳",@"绵阳",@"绵阳阳贵阳贵",@"绵阳",@"绵阳",@"绵阳",@"绵阳"]
                       ];
    }
    return _dataSource;
}


@end
