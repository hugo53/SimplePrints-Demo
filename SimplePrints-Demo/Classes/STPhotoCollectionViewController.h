//
//  STPhotoCollectionViewController.h
//  SimplePrints-Demo
//
//  Created by Hoang on 9/18/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@class STPhotoSourceViewController;

@interface STPhotoCollectionViewController : UIViewController <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@property (nonatomic) STPhotoSourceViewController *photoSourceVC;
@property (nonatomic) MWPhotoBrowser *browser;

@end
