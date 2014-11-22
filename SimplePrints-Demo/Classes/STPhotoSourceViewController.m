//
//  STPhotoSourceViewController.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/18/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STPhotoSourceViewController.h"
#import "STPhotoCollectionViewController.h"
#import "SDImageCache.h"
#import "MWCommon.h"
#import "STAlbumListViewController.h"
#import "STCustomCell.h"

@implementation STPhotoSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"Albums List", nil);
    self.navigationItem.hidesBackButton = YES;
    float shiftRightOffset = 10.0;
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44.0f, 30.0f)];
    [backButton setImage:[UIImage imageNamed:@"back"]  forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didPressOnBackBtn) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -shiftRightOffset, 0, shiftRightOffset);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _assetGroups = [[NSMutableArray alloc] init];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Load local photo albums
    [self loadAlbumAssetsWithAssetType:ALAssetsGroupSavedPhotos];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadAlbumAssetsWithAssetType:ALAssetsGroupAlbum];
    });
    
    _assetOfGroups = [[NSMutableArray alloc] init];
    
    delayInSeconds = .5;
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (ALAssetsGroup *group in _assetGroups) {
            NSMutableArray *assetList = [[NSMutableArray alloc] init];
            [_assetOfGroups addObject:assetList];
            [self getListPhotoOfGroup:group insertInto:assetList];
        }
    });
    
    _listPhotoSourceTbl = [[UITableView alloc] initWithFrame:self.view.bounds
                                                       style:UITableViewStylePlain];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    _listPhotoSourceTbl.delegate = self;
    _listPhotoSourceTbl.dataSource = self;
    _listPhotoSourceTbl.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _listPhotoSourceTbl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_listPhotoSourceTbl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_selectedPhotos) {
        [_selectedPhotos removeAllObjects];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1;
    @synchronized(_assetGroups) {
        if (_assetGroups.count)
            rows += _assetGroups.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        // Camera roll
        if (_assetGroups && _assetGroups.count > 0) {
            ALAssetsGroup *assetGroup = [_assetGroups objectAtIndex:0];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [assetGroup valueForProperty:ALAssetsGroupPropertyName], [assetGroup numberOfAssets]];
            cell.imageView.image = [UIImage imageWithCGImage:[assetGroup posterImage]];
        }else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Camera Roll", nil), 0];
        }
    }else if (indexPath.row == 1) {
        // Facebook Images
        cell.textLabel.text = NSLocalizedString(@"Facebook Photos", nil);
        cell.imageView.image = [UIImage imageNamed:@"facebook-icon"];
    }else if (indexPath.row > 1) {
        // Other local album
        if (_assetGroups && _assetGroups.count >= indexPath.row) {
            ALAssetsGroup *assetGroup = [_assetGroups objectAtIndex:indexPath.row-1];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [assetGroup valueForProperty:ALAssetsGroupPropertyName], [assetGroup numberOfAssets]];
            cell.imageView.image = [UIImage imageWithCGImage:[assetGroup posterImage]];
        }
    }
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSMutableArray *photos = [[NSMutableArray alloc] init];
	NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    
    if (indexPath.row == 0 || (indexPath.row > 1)) {
        // Camera roll
        @synchronized(_assetOfGroups) {
            int index = 0;
            
            if (indexPath.row == 0) {
                index = 0;
            }else {
                index = indexPath.row - 1;
            }

            NSMutableArray *copy = [[_assetOfGroups objectAtIndex:index] copy];
            
            if (copy.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Something went wrong", nil) message:NSLocalizedString(@"Maybe permission to access photos is not granted. Please check in Settings->Privacy->Photos", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    [alert show];
                });
                [_listPhotoSourceTbl deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            
            for (ALAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
                [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
            }
            
            self.photos = photos;
            self.thumbs = thumbs;
            
            // Create browser
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = NO;
            browser.displayNavArrows = YES;
            browser.displaySelectionButtons = YES;
            browser.alwaysShowControls = YES;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = NO;
            browser.startOnGrid = YES;
            browser.enableSwipeToDismiss = YES;
            [browser setCurrentPhotoIndex:0];
            
            browser.allowLeftBtnOnNavigation = YES;
            
            // Reset selections
            if (browser.displaySelectionButtons) {
                _selections = [NSMutableArray new];
                for (int i = 0; i < photos.count; i++) {
                    [_selections addObject:[NSNumber numberWithBool:NO]];
                }
            }
            [self.navigationController pushViewController:browser animated:YES];
        }
    }else if (indexPath.row == 1) {
        // Facebook Images
        STAlbumListViewController *fbAlbumList = [[STAlbumListViewController alloc] init];
        fbAlbumList.photoCollectionVC = _photoCollectionVC;
        [self.navigationController pushViewController:fbAlbumList animated:YES];
    }
	
	[_listPhotoSourceTbl deselectRowAtIndexPath:indexPath animated:YES];
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

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    
    if (selected) {
        if (!_selectedPhotos) {
            _selectedPhotos = [[NSMutableArray alloc] init];
        }
        [_selectedPhotos addObject:[self photoBrowser:photoBrowser photoAtIndex:index]];
    }else {
        [_selectedPhotos removeObject:[self photoBrowser:photoBrowser photoAtIndex:index]];
    }
    
    [photoBrowser enableAddSelectedPhotoBtn:(_selectedPhotos.count > 0)];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets
- (void)loadAlbumAssetsWithAssetType:(ALAssetsGroupType) assetGroupType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [_assetGroups addObject:group];
                dispatch_semaphore_signal(sema);
                NSLog(@"Album name: %@ has %d photos", [group valueForProperty:ALAssetsGroupPropertyName], [group numberOfAssets]);
                
                [_listPhotoSourceTbl performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:assetGroupType
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                           dispatch_semaphore_signal(sema);
                                       }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

- (void) getListPhotoOfGroup:(ALAssetsGroup *) group insertInto:(NSMutableArray *) resultList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(resultList) {
                                               
                                               [resultList addObject:asset];
                                               dispatch_semaphore_signal(sema);
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      dispatch_semaphore_signal(sema);
                                  }];
                }
            }
        };
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark Logic functions
- (void) addSelectedPhotoFromPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    _photos = [_selectedPhotos copy];
    _thumbs = [_photos copy];
    
    [_photoCollectionVC.photos addObjectsFromArray:_photos];
    _photoCollectionVC.thumbs = [_photoCollectionVC.photos copy];
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:_photoCollectionVC];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    browser.allowRightBtnOnNavigation = YES;
    browser.showAddSelectedPhotoBtn = NO;
    
    NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    [viewControllers replaceObjectAtIndex:1 withObject:browser];
    [self.navigationController setViewControllers:viewControllers];
    
    [self.navigationController popToViewController:browser animated:YES];
}

#pragma mark Navigation handling
- (void) didPressOnBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
