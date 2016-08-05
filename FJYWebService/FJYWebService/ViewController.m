//
//  ViewController.m
//  FJYWebService
//
//  Created by 冯佳玉 on 16/8/5.
//  Copyright © 2016年 冯佳玉. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)clickButtonGetData:(id)sender {
    // method 方法名，parameter 参数字典，keyArr 参数数组，这里说下，由于参数在后面的请求数据的请求体中顺序不能打乱，必须与服务器的参数顺序对应
    [[DataManager new]getDataFromWebserviceWithMethod:@"checkServerIsOpen" andParameter:nil andKeyArr:nil handle:^(NSDictionary *dict, NSError *error) {
        // 同时要注意，如果做界面更新的话，需要在主线程更新操作，这里用的block不在主线程
        // 一般使用GCD
        //  dispatch_async(dispatch_get_main_queue(), ^{
        //  });
        NSLog(@"%@",dict);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
