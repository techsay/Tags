//
//  BTagsView.m
//  TagsList
//
//  Created by 聂小波 on 2023/5/17.
//

#import "BTagsView.h"
#import "PublicHeader.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import <Masonry/Masonry.h>
#import <objc/runtime.h>

@interface BTagCollectionViewCell()

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


@interface BTagsView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

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

/**/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.datas[indexPath.row];
    return [BTagCollectionViewCell getItemSizeWothText:text];
}
//
//- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout colorForSectionAtIndex:(NSInteger)section {
//    return [UIColor whiteColor];
//}


#pragma mark - UICollectionViewDelegateFlowLayout

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 6;
//}

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
