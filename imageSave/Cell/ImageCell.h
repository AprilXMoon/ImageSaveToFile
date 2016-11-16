//
//  ImageCell.h
//  imageSave
//
//  Created by April Lee on 2016/11/15.
//  Copyright © 2016年 april. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) NSString *imageName;

@end
