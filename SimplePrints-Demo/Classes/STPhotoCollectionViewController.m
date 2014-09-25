//
//  STPhotoCollectionViewController.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/18/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STPhotoCollectionViewController.h"
#import "STPhotoSourceViewController.h"

@interface STPhotoCollectionViewController ()

@end

@implementation STPhotoCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _photos = [[NSMutableArray alloc] init];
    _thumbs = [[NSMutableArray alloc] init];
    
    _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _browser.displayActionButton = NO;
    _browser.displayNavArrows = YES;
    _browser.displaySelectionButtons = NO;
    _browser.alwaysShowControls = NO;
    _browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    _browser.wantsFullScreenLayout = YES;
#endif
    _browser.enableGrid = NO;
    _browser.startOnGrid = YES;
    _browser.enableSwipeToDismiss = YES;
    [_browser setCurrentPhotoIndex:0];
    
    _browser.allowRightBtnOnNavigation = YES;
    _browser.showAddSelectedPhotoBtn = NO;
    
    _browser.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:_browser animated:NO];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
}


- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) addMoreImageIntoPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (!_photoSourceVC) {
        _photoSourceVC = [[STPhotoSourceViewController alloc] init];
    }
    
    _photoSourceVC.photoCollectionVC = self;
    
    [self.navigationController pushViewController:_photoSourceVC animated:YES];
}


@end
