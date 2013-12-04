//
//  AlertController.m
//  Just-Gist-It
//
//  Created by Lee Hanxue on 12/4/13.
//  Copyright (c) 2013 Lee Hanxue. All rights reserved.
//

#import "AlertController.h"
#import "AppDelegate.h"

@implementation AlertController

- (void)uploadGist:(NSData *)text;
{
    NSString *urlString = @"https://api.github.com/gists";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // upload text content
    [body appendData:[@"{"
                       "\"description\": \"the description for this gist\","
                       "\"public\": true,"
                       "\"files\": {"
                       "    \"file1.txt\": {"
                       "        \"content\": \"String file contents\""
                       "    }"
                       "}\r\n}" dataUsingEncoding:NSUTF8StringEncoding]];

    // content end
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSArray *decodedResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSString *gistUrlString = [[[decodedResponse valueForKey:@"upload"] valueForKey:@"links"] valueForKey:@"imgur_page"];
        NSURL *gistUrl = [NSURL URLWithString:gistUrlString];
        
        // copy to clipboard
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
        [pasteBoard setString:gistUrlString forType:NSStringPboardType];
        
        BOOL finished = [[NSWorkspace sharedWorkspace] openURL:gistUrl];
        
        if(finished){
            NSString *alertText = [NSString stringWithFormat:@"%@/%@/", gistUrlString, @" copied to clipboard."];
            [[NSApp delegate] flashAlert:alertText];
        }
}
@end
