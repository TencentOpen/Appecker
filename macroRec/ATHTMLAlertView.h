///////////////////////////////////////////////////////////////////////////////////////////////////////
// Tencent is pleased to support the open source community by making Appecker available.
// 
// Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface ATHTMLAlertView : UIView
{
    UIWindow* m_window;
    UIWebView* m_webView;
    UIButton* m_title;
    id m_dismissTarget;
    SEL m_dismissAction;
}

-(id) initWithTitle:(NSString*) title message:(NSString*) htmlMessage;
-(void) show;
-(void) dismiss;
-(void) setDismissAction:(SEL) selector withTarget:(id) target;
@end
