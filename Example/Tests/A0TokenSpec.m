//
//  A0TokenSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/28/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0Token.h"

#define kAccessToken @"ACCESS TOKEN"
#define kIdToken @"ID TOKEN"
#define kTokenType @"BEARER"
#define kRefreshToken @"REFRESH TOKEN"

NSString *A0TokenJWTCreate(NSDate *expireDate) {
    NSString *claims = [NSString stringWithFormat:@"{\"exp\": %f}", expireDate.timeIntervalSince1970]; //It has more values but not used in A0Token
    NSData *claimsData = [claims dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Claims = [claimsData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"HEADER.%@.SIGNATURE", base64Claims];
}

SpecBegin(A0Token)

describe(@"A0Token", ^{

    __block A0Token *token;

    NSDictionary *jsonDict = @{
                               @"access_token": kAccessToken,
                               @"id_token": kIdToken,
                               @"token_type": kTokenType,
                               };

    sharedExamplesFor(@"invalid token", ^(NSDictionary *data) {

        it(@"should raise exception", ^{
            expect(^{
                token = [[A0Token alloc] initWithDictionary:data];
            }).to.raise(NSInternalInconsistencyException);
        });

    });

    sharedExamplesFor(@"valid basic token", ^(NSDictionary *data) {

        beforeEach(^{
            token = data[@"token"];
        });

        specify(@"valid id token", ^{
            expect(token.idToken).to.equal(kIdToken);
        });

        specify(@"valid token type", ^{
            expect(token.tokenType).to.equal(kTokenType);
        });

    });

    sharedExamplesFor(@"valid complete token", ^(NSDictionary *data) {

        beforeEach(^{
            token = data[@"token"];
        });

        itShouldBehaveLike(@"valid basic token", data);

        specify(@"valid access token", ^{
            expect(token.accessToken).to.equal(kAccessToken);
        });

    });

    sharedExamplesFor(@"valid basic with offline token", ^(NSDictionary *data) {

        beforeEach(^{
            token = data[@"token"];
        });

        itShouldBehaveLike(@"valid basic token", data);

        specify(@"valid refresh token", ^{
            expect(token.refreshToken).to.equal(kRefreshToken);
        });
        
    });

    sharedExamplesFor(@"valid complete with offline token", ^(NSDictionary *data) {

        beforeEach(^{
            token = data[@"token"];
        });

        itShouldBehaveLike(@"valid complete token", data);

        specify(@"valid refresh token", ^{
            expect(token.refreshToken).to.equal(kRefreshToken);
        });
        
    });

    context(@"creating from JSON", ^{

        itShouldBehaveLike(@"valid complete token", @{ @"token": [[A0Token alloc] initWithDictionary:jsonDict] });

        itShouldBehaveLike(@"valid basic token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"access_token"];
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itShouldBehaveLike(@"valid basic with offline token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"access_token"];
            dict[@"refresh_token"] = kRefreshToken;
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itShouldBehaveLike(@"valid complete with offline token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            dict[@"refresh_token"] = kRefreshToken;
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itBehavesLike(@"invalid token", @{});
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken });
        itBehavesLike(@"invalid token", @{ @"refresh_token": kRefreshToken });
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken, @"token_type": kTokenType });
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken, @"id_token": kIdToken });
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken, @"refresh_token": kRefreshToken });
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken, @"token_type": kTokenType, @"refresh_token": kRefreshToken });
        itBehavesLike(@"invalid token", @{ @"access_token": kAccessToken, @"id_token": kIdToken, @"refresh_token": kRefreshToken });

    });

    describe(@"id_token expiration date", ^{

        context(@"valid id_token", ^{
            __block NSDate *expireDate;

            beforeEach(^{
                expireDate = [NSDate dateWithTimeIntervalSinceNow:2 * 60 * 60];
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"id_token"] = A0TokenJWTCreate(expireDate);
                token = [[A0Token alloc] initWithDictionary:dict];
            });

            it(@"should return expire date form id_token", ^{
                expect(token.expiresAt.timeIntervalSince1970).to.equal(expireDate.timeIntervalSince1970);
            });

        });

        sharedExamplesFor(@"invalid id_token", ^(NSDictionary *data) {

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"id_token"] = data[@"id_token"];
                token = [[A0Token alloc] initWithDictionary:dict];
            });

            specify(@"no expire date", ^{
                expect(token.expiresAt).to.beNil();
            });

        });

        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOPARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOTENOUGH.PARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"HEADER.INVALIDCLAIM.SIGNATURE" });
    });
});

SpecEnd
