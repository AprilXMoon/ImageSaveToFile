//
//  EditViewController.m
//  imageSave
//
//  Created by April Lee on 2016/11/14.
//  Copyright © 2016年 april. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController () <UIImagePickerControllerDelegate , UINavigationControllerDelegate>

@property (strong, nonatomic)UIImage *selectedImage;
@property (nonatomic) NSUInteger imageCounts;
@property (strong, nonatomic) IBOutlet UIImageView *photoImage;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imageCounts = [self getImageCounts];
    [self setImageViewSkin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectImageButtonPressed:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self saveImageToFile];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - skin

- (void)setImageViewSkin
{
    _photoImage.layer.borderWidth = 1;
    _photoImage.layer.borderColor = [[UIColor grayColor] CGColor];
}

#pragma mark - imagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    _selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _photoImage.image = _selectedImage;

    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - saveImage

- (void)checkImageFolderExisted
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *folderPath = [documentsPath stringByAppendingString:@"/Image"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

- (void)saveImageToFile
{
    NSData *imgData = UIImagePNGRepresentation(_selectedImage);
    
    [self checkImageFolderExisted];
    
    NSString *imageFileName = [NSString stringWithFormat:@"/Image/image_%lu.png",(unsigned long)_imageCounts];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageFileName];
    
    [imgData writeToFile:filePath atomically:YES];
    
    [self saveImageCounts];
}

#pragma mark - getImageCounts

- (NSInteger)getImageCounts
{
    _imageCounts = [[NSUserDefaults standardUserDefaults] integerForKey:@"ImageCounts"];
    return _imageCounts;
}

- (void)saveImageCounts
{
    _imageCounts = _imageCounts + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:_imageCounts forKey:@"ImageCounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
