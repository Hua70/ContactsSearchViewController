//
//  WFMagCVMakeLeftViewController.h
//  WonderFie
//
//  Created by Leo on 15/2/10.
//  Copyright (c) 2015年 Heimavista. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFVCMagCBMake.h"
#import <wftools/HVSpringboardLayout.h>

@class WFDBModelMagPage;

@interface WFVCMagCBMakeLeft : GAITrackedViewController

@property (nonatomic,weak) WFVCMagCBMake * parentVC;

- (void) reset;

@end

//-------------WFMagSBViewCell------------------//

@interface WFMagSBViewCell : HVSpringboardCell

@property (nonatomic,strong) WFDBModelMagPage * pageModel;

- (void) bindPage:(WFDBModelMagPage *) pageModel;

@end
//-----------WFMagSBViewCell End----------------//
