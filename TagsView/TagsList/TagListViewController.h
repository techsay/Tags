//
//  TagListViewController.h
//  TagsList
//
//  Created by 聂小波 on 2023/5/18.
//

#import <UIKit/UIKit.h>

/// 引用
#define WEAK_SELF __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF  __strong __typeof(&*weakSelf) strongSelf = weakSelf;
#define CHECK_WEAK_SELF if (weakSelf == nil) { return; }

#define Screen_Height [UIScreen mainScreen].bounds.size.height //当前屏幕高度
#define Screen_Width [UIScreen mainScreen].bounds.size.width  //当前屏幕宽度
#define Screen_Scale (MIN(Screen_Height, Screen_Width) / 375.0)  // 37屏幕比例

NS_ASSUME_NONNULL_BEGIN

@interface TagListViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
