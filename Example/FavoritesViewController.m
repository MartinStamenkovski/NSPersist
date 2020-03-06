//
//  FavoritesViewController.m
//  Example
//
//  Created by Martin Stamenkovski on 3/6/20.
//

#import "FavoritesViewController.h"

#if TARGET_OS_IPHONE
#import "NSPersist/NSPersist-Swift.h"
#endif

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSArray *favorites = [[[NSPersist shared] requestWithEntityName:@"NSExampleNote" completion:^(NSFetchRequest<NSManagedObject *> * _Nonnull request) {
        request.predicate = [NSPredicate predicateWithFormat:@"favorite = true"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:false]];
    }] get];
    
    self.favorites = [favorites mutableCopy];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoriteTableViewCell" forIndexPath:indexPath];
    NSManagedObject *note = self.favorites[indexPath.row];
    
    cell.textLabel.text = [note valueForKey:@"title"];
    return cell;
}
@end
