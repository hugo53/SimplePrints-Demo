//
//  STPhotoSourceViewController.h
//  SimplePrints-Demo
//
//  Created by Hoang on 9/18/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class STPhotoCollectionViewController;

@interface STPhotoSourceViewController : UIViewController <MWPhotoBrowserDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_selections;
    NSMutableArray *_selectedPhotos; // MWPhoto objects
    UITableView *_listPhotoSourceTbl;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic, strong) NSMutableArray *assetOfGroups; // List of NSMutable Array, which contains assets of each group

@property (nonatomic, strong) STPhotoCollectionViewController *photoCollectionVC;

@end
