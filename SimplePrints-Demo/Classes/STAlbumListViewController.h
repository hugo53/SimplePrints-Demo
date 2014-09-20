//
//  STAlbumListViewController.h
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "STPhotoCollectionViewController.h"

@interface STAlbumListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate> {
    NSMutableArray *_selectedPhotos; // MWPhoto objects
    NSMutableArray *_selections;
}

@property (nonatomic) UITableView *albumListTbl;
@property (nonatomic, strong) STPhotoCollectionViewController *photoCollectionVC;

@end
