//
//  STCustomCell.m
//  SimplePrints-Demo
//
//  Created by Hoang on 9/19/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#import "STCustomCell.h"

@implementation STCustomCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10,5, 40, 40);
    float imgWidth =  self.imageView.image.size.width;
    if(imgWidth > 0) {
        self.textLabel.frame = CGRectMake(60,self.textLabel.frame.origin.y,self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(60,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
}


@end
