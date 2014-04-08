//
//  JHViewController.m
//  TestPhotoLibrary
//
//  Created by Hoo Jubal on 3/4/14.
//  Copyright (c) 2014 Hoo Jubal. All rights reserved.
//

#import "JHViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface JHViewController ()

@property (nonatomic, strong) UIImageView * imageView;

- (void)showImagePickerController;
- (void)logPhotoLibraryInfo;
- (void)choosePhoto:(id)sender;

@end

@implementation JHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    //
    // add selected image view
    self.imageView = [[UIImageView alloc] init];
    CGRect aRect = self.view.frame;
    aRect.origin = CGPointZero;
    self.imageView.frame = aRect;
    [self.view addSubview:self.imageView];
    
    //
    // add photo button
    UIButton * photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    photoButton.frame = CGRectMake(0.0f, 0.0f, 88.0f, 44.0f);
    photoButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [photoButton setTitle:@"Photo" forState:UIControlStateNormal];
    [self.view addSubview:photoButton];
    [photoButton addTarget:self
                    action:@selector(choosePhoto:)
          forControlEvents:UIControlEventTouchUpInside];
}// viewDidLoad

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)showImagePickerController
{
    NSLog(@"Go to choos a pic.");
    UIImagePickerController * pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
//    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerController animated:YES completion:^{
        [self logPhotoLibraryInfo];
    }];
}

- (void)logPhotoLibraryInfo
{
    ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                                     NSLog(@"-------------------");
                                     NSLog(@"Number of assets = %d", group.numberOfAssets);
                                     UIImage * posterImage = [UIImage imageWithCGImage:[group posterImage]];
                                     NSLog(@"PosterImage: %@", posterImage);
                                     NSLog(@"Name: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
                                     NSLog(@"Type: %@", [group valueForProperty:ALAssetsGroupPropertyType]);
                                     NSLog(@"URL: %@", [group valueForProperty:ALAssetsGroupPropertyURL]);
                                     NSLog(@"PersistentID: %@", [group valueForProperty:ALAssetsGroupPropertyPersistentID]);
                                     NSLog(@"-------------------");
                                     if (posterImage)
                                     {
                                         //
                                         // just for test
                                         UIImageView * posterView = [[UIImageView alloc] initWithImage:posterImage];
                                         [self.view addSubview:posterView];
                                     }
                                 }failureBlock:^(NSError * error){
                                     
                                 }];
}// logPhotoLibraryInfo

- (void)choosePhoto:(id)sender
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    BOOL isAuthorized = NO;
    switch (author)
    {
        case ALAuthorizationStatusNotDetermined:
        {
            NSLog(@"Not determined");
            ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset)
            {
                NSLog(@"Asset = %@", asset);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showImagePickerController];
                });
            };
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
            {
                NSLog(@"User not allow our app to access her app. Error = %@", error);
            };
            ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary assetForURL:nil
                           resultBlock:resultsBlock
                          failureBlock:failureBlock];
            break;
        }
        case ALAuthorizationStatusDenied:
            NSLog(@"Denied");
            break;
        case ALAuthorizationStatusAuthorized:
            NSLog(@"Authorized");
            isAuthorized = YES;
            break;
        case ALAuthorizationStatusRestricted:
            NSLog(@"Restricted");
            break;
        default:
            NSLog(@"Not existed state before");
            break;
    }
    if (isAuthorized)
    {
        [self showImagePickerController];
    }
}// choosePhoto:

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s", __FUNCTION__);
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismiss image picker");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"%s", __FUNCTION__);
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismiss image picker");
    }];
}

@end
