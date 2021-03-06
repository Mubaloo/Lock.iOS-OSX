// A0PasswordManager.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0PasswordManager.h"
#import <1PasswordExtension/OnePasswordExtension.h>

@implementation A0PasswordManager

AUTH0_DYNAMIC_LOGGER_METHODS

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static A0PasswordManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[A0PasswordManager alloc] init];
    });
    return instance;
}

+ (BOOL)hasPasswordManagerInstalled {
    return [[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
}

- (void)fillLoginInformationForViewController:(UIViewController *)controller
                                       sender:(id)sender
                                   completion:(void (^)(NSString *, NSString *))completion {
    void(^onCompletion)(NSDictionary *, NSError *) = ^(NSDictionary *loginDict, NSError *error) {
        if (completion) {
            if (!loginDict) {
                if (error.code != AppExtensionErrorCodeCancelledByUser) {
                    A0LogWarn(@"Error invoking 1Password App Extension for find login: %@", error);
                }
                return;
            } else {
                completion(loginDict[AppExtensionUsernameKey], loginDict[AppExtensionPasswordKey]);
            }
        }
    };
    [[OnePasswordExtension sharedExtension] findLoginForURLString:[self loginInfoURLString]
                                                forViewController:controller
                                                           sender:sender
                                                       completion:onCompletion];
}

- (void)saveLoginInformationForUsername:(NSString *)username
                               password:(NSString *)password
                              loginInfo:(NSDictionary *)loginInfo
                             controller:(UIViewController *)controller
                                 sender:(id)sender
                             completion:(A0LoginInfoBlock)completion {
    void(^onCompletion)(NSDictionary *, NSError *) = ^(NSDictionary *loginDict, NSError *error) {
        if (completion) {
            if (!loginDict) {
                if (error.code != AppExtensionErrorCodeCancelledByUser) {
                    A0LogWarn(@"Error invoking 1Password App Extension for find login: %@", error);
                }
                return;
            } else {
                completion(loginDict[AppExtensionUsernameKey], loginDict[AppExtensionPasswordKey]);
            }
        }
    };
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSDictionary *loginDetails = @{
                                   AppExtensionTitleKey: appName,
                                   AppExtensionUsernameKey: username ?: @"",
                                   AppExtensionPasswordKey: password ?: @"",
                                   AppExtensionNotesKey: [NSString stringWithFormat:@"Saved with %@", appName],
                                   AppExtensionTitleKey: appName,
                                   AppExtensionFieldsKey: loginInfo ?: @{},
                                   };
    NSDictionary *passwordGeneration = @{
                                         AppExtensionGeneratedPasswordMinLengthKey: @8,
                                         AppExtensionGeneratedPasswordMaxLengthKey: @50,
                                         };
    [[OnePasswordExtension sharedExtension] changePasswordForLoginForURLString:[self loginInfoURLString]
                                                      loginDetails:loginDetails
                                         passwordGenerationOptions:passwordGeneration
                                                 forViewController:controller
                                                            sender:sender
                                                        completion:onCompletion];
}

+ (UIImage *)iconImage {
    return [UIImage imageNamed:@"onepassword-button" inBundle:[NSBundle bundleForClass:[OnePasswordExtension class]] compatibleWithTraitCollection:nil];
}

#pragma mark - Utility methods

- (NSString *)loginInfoURLString {
    return self.loginURLString ?: [@"app://" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
}

@end
