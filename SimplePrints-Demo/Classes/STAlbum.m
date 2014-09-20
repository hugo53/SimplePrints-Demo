//
//  STAlbum.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STAlbum.h"

@implementation STAlbum

- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName {
    self = [super init];
    if (self) {
        _albumId = albumId;
        _albumName = albumName;
    }
    return self;
}

- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName numberOfPhotos:(NSInteger) numberOfPhotos {
    self = [self initWithAlbumId:albumId albumName:albumName];
    if (self) {
        _numberOfPhotos = numberOfPhotos;
    }
    return self;
}

- (instancetype) initWithAlbumId:(NSString *) albumId albumName:(NSString *) albumName numberOfPhotos:(NSInteger) numberOfPhotos createdDate:(NSDate*) createdDate {
    self = [self initWithAlbumId:albumId  albumName:albumName numberOfPhotos:numberOfPhotos];
    if (self) {
        _createdDate = createdDate;
    }
    return self;
}

@end
