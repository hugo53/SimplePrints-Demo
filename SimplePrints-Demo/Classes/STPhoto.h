//
//  STPhoto.h
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STPhoto : NSObject

@property (nonatomic) NSString *photoId;
@property (nonatomic) NSString *photoSource;
@property (nonatomic) NSString *thumbSource;        // Optional

- (instancetype)initWithPhotoId:(NSString *) photoId;
- (instancetype)initWithPhotoId:(NSString *) photoId photoSource:(NSString *) photoSource;
- (instancetype)initWithPhotoId:(NSString *) photoId photoSource:(NSString *) photoSource thumbSource:(NSString *) thumbSource;

@end
