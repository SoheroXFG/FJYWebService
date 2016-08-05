//
//  DataManager.m
//  新能源汽车基础知识测评系统
//
//  Created by 冯佳玉 on 16/7/5.
//  Copyright © 2016年 方磊. All rights reserved.
//

#import "DataManager.h"
@interface DataManager()<NSXMLParserDelegate>
@property (nonatomic,strong) NSMutableString  *myString;
@property (nonatomic,strong) NSString         *myKey;
@property (nonatomic,strong) NSString         *bodyString;

// 传过来的参数及方法名
@property (nonatomic,strong) NSString         *methodName;
@property (nonatomic,strong) NSDictionary     *paraDict;
@property (nonatomic,strong) NSArray          *keyArray;
@property (nonatomic,copy)   DataBlock        myblock;
@end

@implementation DataManager
- (NSMutableString *)myString {
    if (!_myString) {
        _myString = [NSMutableString string];
    }
    return _myString;
}
- (void)getDataFromWebserviceWithMethod:(NSString *)method andParameter:(NSDictionary *)dict andKeyArr:(NSArray *)array handle:(DataBlock)block {
    self.methodName = method;
    self.paraDict = dict;
    self.keyArray = array;
    self.myblock = block;
    [self pieceBodyString];
    [self getCourseDataFromServer];
}

- (void)pieceBodyString {
    NSMutableString *mutableString = [NSMutableString string];
    for (int i=0; i<_keyArray.count; i++) {
        NSString *paraString = _keyArray[i];
        NSString *str = [NSString stringWithFormat:@"<%@ xmlns=\"\">%@</%@>\n",paraString,_paraDict[paraString],paraString];
        [mutableString appendString:str];
    }
    self.bodyString = [mutableString copy];
}

- (void)getCourseDataFromServer {
    NSString *webServiceStr = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "<%@ xmlns=\"http://biz.newenergyz.sohero.com/\">\n"
                               "%@"
                               "</%@>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>\n"
                               ,_methodName,_bodyString,_methodName];
    //  命名空间  根据自己的命名空间修改
    NSString *SOAPActionStr = [NSString stringWithFormat:@"http://biz.newenergyz.sohero.com/%@",self.methodName];
    
    //  url 地址 也需要根据自身的服务器更改
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.0.20:8080/newEnergyZ/webservice/webServiceClient"]];
    
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%ld", webServiceStr.length];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-type"];
    [theRequest addValue:SOAPActionStr forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[webServiceStr dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:10];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //  说明下：我们公司的服务器是Java端写的，返回的数据xml格式，在里面有一个return块为有效数据，这里要做判断就是因为，只有连接不上服务器的时候才会有error，即使数据有问题，也不会有error返回，只是返回的数据中没有return这个数据块，可以根据自己公司服务器返回的数据进行分析替换
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:theRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            _myblock(nil,error);
        }else{
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"下载任务返回DAta:%@",str);
            if ([str containsString:@"return"]) {
                NSLog(@"有返回东西");
                NSXMLParser *par = [[NSXMLParser alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
                [par setDelegate:self];//设置NSXMLParser对象的解析方法代理
                [par parse];//调用代理解析NSXMLParser对象，看解析是否成功
            }else{
                NSLog(@"没有返回的东西");
                _myblock(nil,nil);
                return;
            }
        }
    }];
    [dataTask resume];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"return"]) {
        self.myKey = elementName;
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"return"]) {
        [self parserString:self.myString];
    }
    if ([elementName isEqualToString:@"soap:Envelope"]) {
        return;
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.myKey isEqualToString:@"return"]) {
        if (string.length >0) {
            [self.myString appendString:string];
        }
    }
}
- (void)parserString:(NSString *)str {
    //    NSLog(@"全部课程解析：%@",str);
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
    }else{
        NSLog(@"解析完成的字典:%@",dic);
    }
    
    _myblock(dic,nil);
    
    _myKey = nil;
    _myString = nil;
    
//    _myKey = @"";
//    [_myString replaceCharactersInRange:NSMakeRange(0, _myString.length) withString:@""];
}

@end
