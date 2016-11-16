//
//  ViewController.m
//  imageSave
//
//  Created by April Lee on 2016/11/14.
//  Copyright © 2016年 april. All rights reserved.
//

#import "ViewController.h"
#import "EditViewController.h"
#import "ImageCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (strong, nonatomic) NSMutableArray *imageData;

@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic) BOOL isLoading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
    
    [self registerCollectionCell];
    [self addLoadingAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startLoadingAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getImageDataFormFolder];
    [_imageCollectionView reloadData];
    
    if (_imageData.count == 0) {
        [self stopLoadingAnimation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addButtonPressed:(id)sender {
    
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditViewController *editViewController = [mainStory instantiateViewControllerWithIdentifier:@"EditViewController"];
    
    [self.navigationController pushViewController:editViewController animated:YES];
}

#pragma mark - imageAnimation

- (void)addLoadingAnimation
{
    NSArray *images = @[[UIImage imageNamed:@"Loading_1.png"], [UIImage imageNamed:@"Loading_2.png"],
                        [UIImage imageNamed:@"Loading_3.png"],[UIImage imageNamed:@"Loading_4.png"]];
    
    _loadingImage.animationImages = images;
    _loadingImage.animationDuration = 1.0;
}

- (void)startLoadingAnimation
{
    [_loadingView setHidden:NO];
    [_loadingImage startAnimating];
    _isLoading = YES;
}

- (void)stopLoadingAnimation
{
    [_loadingView setHidden:YES];
    [_loadingImage stopAnimating];
    _isLoading = NO;
}

#pragma mark - register

- (void)registerCollectionCell
{
    UINib *cellNib = [UINib nibWithNibName:@"ImageCell" bundle:nil];
    [_imageCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"ImageViewCell"];
}

#pragma mark - get

- (void)getImageDataFormFolder
{
    NSError *error;
    
    NSString *folderPath = [self documentsPathForFileName:@"/Image"];
    
    _imageData = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]];
}

- (UIImage *)getImageFormFolder:(NSString *)imageName
{
    NSString *folderPath = [self documentsPathForFileName:@"/Image/"];
    NSString *imagePath = [folderPath stringByAppendingString:imageName];
    
    NSData *pngData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:pngData];
    
    return image;
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *folderPath = [documentsPath stringByAppendingString:name];
    
    return folderPath;
}

#pragma mark - collection data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imageData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = _imageData[indexPath.row];
    UIImage *image = [self getImageFormFolder:imageName];
    
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageViewCell" forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    cell.photoImageView.image = image;
    cell.imageName = imageName;
    
    if (_isLoading) {
        [self stopLoadingAnimation];
    }
    
    return cell;
}

#pragma mark - colletion delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = (ImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self deleteAlertView:cell.imageName deleteIndexPath:indexPath];
}

#pragma mark - alert 

- (void)deleteAlertView:(NSString *)imageName deleteIndexPath:(NSIndexPath *)deleteItemPath
{
    UIAlertController *deleteAlertView = [UIAlertController alertControllerWithTitle:@"Delete" message:@"Do you want to delete the image?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteImageFile:imageName deleteItemPath:deleteItemPath];
    }];
    
    UIAlertAction *cencelAction = [UIAlertAction actionWithTitle:@"Cencel" style:UIAlertActionStyleCancel handler:nil];
    
    [deleteAlertView addAction:okAction];
    [deleteAlertView addAction:cencelAction];
    
    [self presentViewController:deleteAlertView animated:YES completion:nil];
}

- (void)deleteImageFile:(NSString *)imageName deleteItemPath:(NSIndexPath *)deleteItemPath
{
    NSString *paths = [self documentsPathForFileName:[NSString stringWithFormat:@"/Image/%@", imageName]];
    NSError *error;
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:paths error:&error];
    if (success) {
        NSInteger index = [_imageData indexOfObject:imageName];
        [_imageData removeObjectAtIndex:index];
        
        [_imageCollectionView performBatchUpdates:^{
            [_imageCollectionView deleteItemsAtIndexPaths:@[deleteItemPath]];
        } completion:nil];
        
    } else {
        NSLog(@"Delete fail.");
    }
}


@end
