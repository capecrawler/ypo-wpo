//
//  Macro.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/9/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#ifndef YPO_WPO_SG_Macro_h
#define YPO_WPO_SG_Macro_h

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/225.0f green:g/225.0f blue:b/225.0f alpha:1]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif
