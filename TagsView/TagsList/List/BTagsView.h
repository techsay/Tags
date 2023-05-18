//
//  BTagsView.h
//  TagsList
//
//  Created by 聂小波 on 2023/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTagCollectionViewCell : UICollectionViewCell

@end

@interface BTagsView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datas;

@end

NS_ASSUME_NONNULL_END
