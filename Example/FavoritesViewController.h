//
//  FavoritesViewController.h
//  Example
//
//  Created by Martin Stamenkovski on 3/6/20.
//

#import <UIKit/UIKit.h>
#if TARGET_OS_IPHONE
#import "NSPersist/NSPersist-Swift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FavoritesViewController : UITableViewController

@property NSMutableArray *favorites;

@end

NS_ASSUME_NONNULL_END
