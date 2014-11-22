//
//  STAlbumListViewController.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STAlbumListViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "STAlbum.h"
#import "STPhoto.h"
#import "UIImageView+WebCache.h"
#import "NSObject+Helper.h"
#import "UIImage+Resize.h"
#import "STCustomCell.h"
#import "MBProgressHUD.h"

@interface STAlbumListViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSOperationQueue *fetchDataQueue;
@property (nonatomic, strong) NSInvocationOperation *loadAlbumListOp;

@property (nonatomic) NSMutableArray *albums; // Array of STAlbum objects
@property (nonatomic) ACAccount *fbAccount;

@end

@implementation STAlbumListViewController

- (void) loadView {
    [super loadView];
    
    _fetchDataQueue = [NSOperationQueue new];
    
    self.title = NSLocalizedString(@"Facebook", nil);
    self.navigationItem.hidesBackButton = YES;
    float shiftRightOffset = 10.0;
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44.0f, 30.0f)];
    [backButton setImage:[UIImage imageNamed:@"back"]  forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didPressOnBackBtn) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -shiftRightOffset, 0, shiftRightOffset);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    _albumListTbl = [[UITableView alloc] initWithFrame:self.view.bounds
                                                 style:UITableViewStylePlain];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    _albumListTbl.delegate = self;
    _albumListTbl.dataSource = self;
    _albumListTbl.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _albumListTbl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_albumListTbl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_selectedPhotos) {
        [_selectedPhotos removeAllObjects];
    }
    
    if (_photos) {
        [_photos removeAllObjects];
    }
    
    if (_thumbs) {
        [_thumbs removeAllObjects];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // If _albums is not created, load album list from facebook
    if (!_albums) {
        _loadAlbumListOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                selector:@selector(loadAlbumList)
                                                                  object:nil];
        [_fetchDataQueue addOperation:_loadAlbumListOp];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_albums) {
        return [_albums count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (_albums && indexPath.row < _albums.count) {
        STAlbum *currentAlbum = [_albums objectAtIndex:indexPath.row];
        
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:currentAlbum.coverPhoto.photoSource] placeholderImage:[UIImage imageNamed:@"placeHolder"]];

        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 5.0;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", currentAlbum.albumName, currentAlbum.numberOfPhotos];
        
        cell.detailTextLabel.text = [NSObject getDateInStringFormat:currentAlbum.createdDate];
    }
    
    return cell;
}

#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_albums && indexPath.row < _albums.count) {
        
        STAlbum *currentAlbum = [_albums objectAtIndex:indexPath.row];
        
        [_photos removeAllObjects];
        [_thumbs removeAllObjects];
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.view.tag = indexPath.row;
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
        
        [self.navigationController pushViewController:browser animated:YES];
        
        NSString *requestStr = [NSString stringWithFormat:FACEBOOK_GET_PHOTOS_FORMAT, currentAlbum.albumId];
        [self getListPhotoIdOfAlbum:currentAlbum withRequest:requestStr completion:^(NSData *responseData, NSError *error) {
            
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!browser.pressedBack) {
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
                        
                        // Reset selections
                        if (browser.displaySelectionButtons) {
                            _selections = [NSMutableArray new];
                            for (int i = 0; i < _photos.count; i++) {
                                [_selections addObject:[NSNumber numberWithBool:NO]];
                            }
                        }
                        
                        browser.allowLeftBtnOnNavigation = YES;
                        
                        NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                        int index = [self.navigationController viewControllers].count -1;
                        [viewControllers replaceObjectAtIndex:index  withObject:browser];
                        [self.navigationController setViewControllers:viewControllers];                        
                    }else{
                        browser.pressedBack = NO;
                    }
                });
            }
        }];
    }
	
	[_albumListTbl deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (_photos) {
        return _photos.count;
    }
    return 0;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count) {
        return [_photos objectAtIndex:index];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count) {
        return [_thumbs objectAtIndex:index];
    }
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
}


- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Handle Facebook data request
- (void) loadAlbumList {
    // Facebook
    ACAccountStore *fbAccountStore = [[ACAccountStore alloc] init];
    ACAccountType *fbAccountType = [fbAccountStore accountTypeWithAccountTypeIdentifier:
                                    ACAccountTypeIdentifierFacebook];
    
    NSDictionary *optionDict = @{ACFacebookAppIdKey : FACEBOOK_APP_KEY,
                                 ACFacebookPermissionsKey : @[@"user_photos"],
                                 ACFacebookAudienceKey: ACFacebookAudienceFriends};
    
    [fbAccountStore requestAccessToAccountsWithType:fbAccountType options:optionDict completion:^(BOOL granted, NSError *error) {}];
    
    if (fbAccountType.accessGranted) {
        // Fetch albums from fb
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = NSLocalizedString(@"Loading", nil);
        });

        
        SLRequest *albumListRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                           requestMethod:SLRequestMethodGET
                                                                     URL:[NSURL URLWithString:FACEBOOK_GET_ALBUMS_PATH]
                                                              parameters:nil];
        
        _fbAccount = [[fbAccountStore accountsWithAccountType:fbAccountType] lastObject];
        albumListRequest.account = _fbAccount;
        [albumListRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (responseData) {
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                    NSError *jsonError = nil;
                    NSDictionary *photoAlbumData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                    options:NSJSONReadingAllowFragments
                                                                                      error:&jsonError];
                    if (jsonError) {
                        DLog(@"Error parsing album list: %@", jsonError);
                    } else {
                        DLog(@"Data is: %@", photoAlbumData[@"data"]);
                        NSArray *tmpPhotoAlbums = photoAlbumData[@"data"];
                        for (NSDictionary *albumDict in tmpPhotoAlbums) {
                            
                            NSDateFormatter* dateFormarter = [[NSDateFormatter alloc]init];
                            [dateFormarter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                            NSDate *createdDate = [dateFormarter dateFromString:albumDict[@"created_time"]];
                            
                            STAlbum *album = [[STAlbum alloc] initWithAlbumId:albumDict[@"id"] albumName:albumDict[@"name"] numberOfPhotos:[albumDict[@"count"] integerValue] createdDate:createdDate];
                            if (!_albums) {
                                _albums = [[NSMutableArray alloc] init];
                            }
                            
                            [_albums addObject:album];
                            [_albumListTbl reloadData];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                            
                            
                            [self getCoverPhotoForAlbum:album withCoverPhotoId:albumDict[@"cover_photo"]];
                        }
                    }
                } else {
                    DLog(@"HTTP %ld returned", (long)urlResponse.statusCode);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                    
                    [fbAccountStore renewCredentialsForAccount:_fbAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                    }];
                }
            } else {
                DLog(@"ERROR Connecting");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }];
    }else {
        // Show alert let user enable
        UIAlertView *notGrantedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Access Facebook", nil) message:NSLocalizedString(@"Permission is not granted. Please turn on at Settings -> Facebook -> SimplePrints-Demo", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [notGrantedAlert show];
    }
}

-(void) getCoverPhotoForAlbum:(STAlbum *) album withCoverPhotoId:(NSString *) coverPhotoId {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *requestStr = [NSString stringWithFormat:FACEBOOK_GET_FORMAT, coverPhotoId];
    SLRequest *photoRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:[NSURL URLWithString:requestStr]
                                                          parameters:nil];
    photoRequest.account = _fbAccount;
    
    [photoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError = nil;
                NSDictionary *photoData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                               options:NSJSONReadingAllowFragments
                                                                                 error:&jsonError];
                if (jsonError) {
                    DLog(@"Error parsing photo data: %@", jsonError);
                } else {
                    STPhoto *coverPhoto = [[STPhoto alloc] initWithPhotoId:coverPhotoId
                                                               photoSource:photoData[@"picture"]];
                    album.coverPhoto = coverPhoto;
                    
                    DLog(@"Did add cover for album: %@", album.albumName);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_albumListTbl reloadData];
                    });
                }
            } else {
                DLog(@"HTTP %ld returned", (long)urlResponse.statusCode);
            }
        } else {
            DLog(@"ERROR Connecting");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }];
}

- (void) getListPhotoIdOfAlbum:(STAlbum *) album withRequest:(NSString *)requestStr completion:(void(^)(NSData*, NSError*)) completion {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *requestURL = [NSURL URLWithString:requestStr];
    SLRequest *photosRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                 requestMethod:SLRequestMethodGET
                                                            URL:requestURL
                                                    parameters:nil];
    photosRequest.account = _fbAccount;
    
    [photosRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError = nil;
                NSDictionary *photosData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                          options:NSJSONReadingAllowFragments
                                                                            error:&jsonError];
                if (jsonError) {
                    DLog(@"Error parsing photo data: %@", jsonError);
                } else {
                    NSArray *photosList = photosData[@"data"];
                    
                    if(!_photos) {
                        _photos = [[NSMutableArray alloc] init];
                    }
                    
                    if(!_thumbs) {
                        _thumbs = [[NSMutableArray alloc] init];
                    }
                    
                    for (NSDictionary *photoDict in photosList) {
                        NSString *photoLink = photoDict[@"source"];
                        NSString *thumbLink = photoDict[@"picture"];
                        
                        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:photoLink]];
                        MWPhoto *thumb = [MWPhoto photoWithURL:[NSURL URLWithString:thumbLink]];
                        
                        [_photos addObject:photo];
                        [_thumbs addObject:thumb];
                    }
                    
                    completion(responseData, error);
                }
            } else {
                DLog(@"HTTP %ld returned", (long)urlResponse.statusCode);
                
            }
        } else {
            DLog(@"ERROR Connecting");
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }];
}

#pragma mark Logic functions
- (void) addSelectedPhotoFromPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    [_photoCollectionVC.photos addObjectsFromArray:[_selectedPhotos copy]];
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
    [_fetchDataQueue cancelAllOperations];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

