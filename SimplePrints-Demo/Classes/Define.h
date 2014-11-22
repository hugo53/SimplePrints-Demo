//
//  Define.h
//  SimplePrints-Demo
//
//  Created by Hoang on 11/22/14.
//  Copyright (c) 2014 StoryTree. All rights reserved.
//

#ifndef SimplePrints_Demo_Define_h
#define SimplePrints_Demo_Define_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define FACEBOOK_APP_KEY @"803742409678093"
#define FACEBOOK_GET_ALBUMS_PATH @"https://graph.facebook.com/me/albums"
#define FACEBOOK_GET_FORMAT @"https://graph.facebook.com/%@"
#define FACEBOOK_GET_PHOTOS_FORMAT @"https://graph.facebook.com/%@/photos"

#endif
