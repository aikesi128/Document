**Handle User Credentials**



使用场景:  点击apple登录, 成功后, 使用user等信息传给服务器验证

```
sign in with Apple  
#import <AuthenticationServices/AuthenticationServices.h>

// 处理登录按钮点击事件
- (void)test:(id)sender
{
    if (@available(iOS 13.0, *)){
        ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc]init];
        ASAuthorizationAppleIDRequest *request = provider.createRequest;
        [request setRequestedScopes:@[ASAuthorizationScopeFullName,ASAuthorizationScopeEmail]];
        ASAuthorizationController *controller = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[request]];
        controller.delegate = self;
        controller.presentationContextProvider = self;
        [controller performRequests];
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
//    NSLog(@"aikesi--%@",authorization.credential);
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]])
    {
        ASAuthorizationAppleIDCredential * res = (ASAuthorizationAppleIDCredential *)authorization.credential;
        NSLog(@"aikesi--%@",res.user); 000166.f4be4f25d50b4b409a794163a7b96e23.0322
        NSLog(@"aikesi--%@",res.fullName);
        NSLog(@"aikesi--%@",res.email);
        NSLog(@"aikesi--%@",res.identityToken);
//        NSLog(@"aikesi--%@",res.user);
    }
    
    if ([authorization.credential isKindOfClass:[ASPasswordCredential class]])
    {
        ASPasswordCredential * res = (ASPasswordCredential *)authorization.credential;
        NSLog(@"aikesi--%@",res.user);
        NSLog(@"aikesi--%@",res.password);
    }
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  {
    NSLog(@"aikesi--");
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller
{
    NSLog(@"aikesi--");
    return self.view.window;
}
```

```
经测试, 登陆成功凭证中的user字段是不会发生变化的
```



**Request Existing Credentials**

使用场景:  检测到用户未登录的时候. 检查本地是否有可用的凭证

```
检查本地谁都已经存在凭证

    ASAuthorizationAppleIDProvider *idProvide = [[ASAuthorizationAppleIDProvider alloc]init];
    ASAuthorizationPasswordProvider *passwordProvide = [[ASAuthorizationPasswordProvider alloc]init];
    NSArray *requests = @[[idProvide createRequest],[passwordProvide createRequest]];
    ASAuthorizationController *con = [[ASAuthorizationController alloc]initWithAuthorizationRequests:requests];
    con.delegate = self;
    con.presentationContextProvider = self;
    [con performRequests];
   
    
    
    return YES;
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization
{
    NSLog(@"aikesi--");
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error
{
    NSLog(@"aikesi--");
}

```



**Check User Credentials at Launch**

使用场景:  检查用户凭证是否有效


```
    // 检查授权状态
    ASAuthorizationAppleIDProvider *idProvide = [[ASAuthorizationAppleIDProvider alloc]init];
//    SAMKeychain;
//    SAMKeyc头
    [idProvide getCredentialStateForUserID:@"000166.f4be4f25d50b4b409a794163a7b96e23.0322" completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
        if (credentialState == ASAuthorizationAppleIDProviderCredentialRevoked) {
            NSLog(@"aikesi->>>-已经移除了");
        }
        if (credentialState == ASAuthorizationAppleIDProviderCredentialNotFound) {
            NSLog(@"aikesi->>>-未找到");
        }
        if (credentialState == ASAuthorizationAppleIDProviderCredentialAuthorized) {
            NSLog(@"aikesi->>>-已经授权");
        }
    }];
    
    
```