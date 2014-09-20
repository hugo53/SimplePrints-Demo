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

@interface STPhotoSourceViewController ()

@end

@implementation STPhotoSourceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Clear cache
//        [[SDImageCache sharedImageCache] clearDisk];
//        [[SDImageCache sharedImageCache] clearMemory];
    }
    return self;
}

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
    
    [self loadPhotoAssets];

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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 2;
//    @synchronized(_assets) {
//        if (_assets.count) rows++;
//    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure
	switch (indexPath.row) {
		case 0: {
            cell.textLabel.text = @"Library Photos";
            break;
        }
		case 1: {
            cell.textLabel.text = @"Facebook Photos";
            break;
        }
		default: break;
	}
    return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Browser
	NSMutableArray *photos = [[NSMutableArray alloc] init];
	NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    
	switch (indexPath.row) {
		case 0:
            @synchronized(_assets) {
                NSMutableArray *copy = [_assets copy];
                
                if (copy.count == 0) {
                    // No image
                    break;
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
			break;
		case 1: {
            STAlbumListViewController *fbAlbumList = [[STAlbumListViewController alloc] init];
            fbAlbumList.photoCollectionVC = _photoCollectionVC;
            [self.navigationController pushViewController:fbAlbumList animated:YES];
            
			break;
        }
		default: break;
	}
	
	// Deselect
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
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
    
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
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

#pragma mark - Load Assets

- (void)loadPhotoAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   [_listPhotoSourceTbl performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

#pragma mark Navigation handling
- (void) didPressOnBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
