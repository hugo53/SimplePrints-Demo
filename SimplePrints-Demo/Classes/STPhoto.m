//
//  STPhoto.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STPhoto.h"

@implementation STPhoto

- (instancetype)initWithPhotoId:(NSString *) photoId {
    self = [super init];
    if (self) {
        _photoId = photoId;
    }
    return self;
}

- (instancetype)initWithPhotoId:(NSString *) photoId photoSource:(NSString *) photoSource {
    self = [self initWithPhotoId:photoId];
    if (self) {
        _photoSource = photoSource;
    }
    return self;
}

- (instancetype)initWithPhotoId:(NSString *) photoId photoSource:(NSString *) photoSource thumbSource:(NSString *) thumbSource {
    self = [self initWithPhotoId:photoId photoSource:photoSource];
    if (self) {
        _thumbSource = thumbSource;
    }
    return self;
}


@end
