//
//  BTagsUITableViewCell.m
//  TagsList
//
//  Created by 聂小波 on 2023/5/17.
//

#import "BTagsUITableViewCell.h"
#import "BTagsView.h"
#import <Masonry/Masonry.h>

@interface BTagsUITableViewCell()

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
