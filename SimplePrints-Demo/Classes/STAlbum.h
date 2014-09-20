//
//  STAlbum.h
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPhoto.h"

@interface STAlbum : NSObject

@property (nonatomic) NSString *albumId;
@property (nonatomic) STPhoto *coverPhoto;
@property (nonatomic) NSString *albumName;
@property (nonatomic) NSInteger numberOfPhotos;
@property (nonatomic) NSDate *createdDate;
@property (nonatomic, strong) NSMutableArray *photos; // List of STPhoto objects

- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName;
- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName numberOfPhotos:(NSInteger) numberOfPhotos;
- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName numberOfPhotos:(NSInteger) numberOfPhotos createdDate:(NSDate*) createdDate;

@end
