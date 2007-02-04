/*
 *	FanControl
 *
 *	Copyright (c) 2006 Hendrik Holtmann
*
 *	KeyChain.h - MacBook(Pro) FanControl application
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#import "KeyChain.h"
#import <Security/Security.h> 


@implementation KeyChain

+(NSDictionary *)accessToKeyChain:(NSString *)mode user:(NSString*)user pw:(NSString*)pw {
	
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list,xlist;
    OSStatus status;
	NSMutableDictionary *returndata;
	attributes[0].tag = kSecAccountItemAttr;
	NSString *login;
	SecKeychainItemRef item;

	
	login=user;
	const char* clogin;
	int clength=[login length];
	clogin=[login UTF8String];
	attributes[0].data =(void*)clogin;
	attributes[0].length = clength;
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = "application password";
    attributes[1].length = strlen(attributes[1].data);

    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = "PandoraBoy";
    attributes[2].length = strlen(attributes[2].data);
	
	list.count = 3;
    list.attr = attributes;
	
	returndata=[[NSMutableDictionary alloc] init];

	if ([mode isEqualToString:@"Save"]){
	
		NSString *password=pw;
		const char* cpassw;
		cpassw=[password UTF8String];
		status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list,
													strlen(cpassw), cpassw, NULL,NULL,&item);
		if (status == errSecDuplicateItem) { //item exits, update it
			SecKeychainSearchRef search;
			SecKeychainItemRef olditem;
			status = SecKeychainSearchCreateFromAttributes (NULL, kSecGenericPasswordItemClass,&list, &search);
			SecKeychainSearchCopyNext (search, &olditem);
			//NSLog(@"Error during keychain access %d",status);
			status=SecKeychainItemModifyContent (olditem,&list,strlen(cpassw),cpassw);
			CFRelease(olditem);

		}
	} else {
	  //load from keychain and set attributes
		void* outData = nil;
		UInt32 len;
		SecKeychainSearchRef search;
		SecKeychainItemRef founditem;
		SecKeychainAttribute outList[] =
		{
		{kSecAccountItemAttr,},
		{kSecDescriptionItemAttr,},
		{kSecLabelItemAttr}
		};
		xlist.count = sizeof(outList)/sizeof(outList[0]);
		xlist.attr = outList;
		status = SecKeychainSearchCreateFromAttributes (NULL, kSecGenericPasswordItemClass,&list, &search);
		NSLog(@"Tell me: %d",status);
		status=SecKeychainSearchCopyNext (search, &founditem);
		if (status!=errSecItemNotFound) {
			status = SecKeychainItemCopyContent (founditem, NULL, &xlist, &len, &outData);
			NSString *password;
			password = [[NSString alloc]  initWithBytes:outData length:len encoding:NSUTF8StringEncoding];
			[returndata setObject:password forKey:@"Password"];
			[password release];
			CFRelease(founditem);
		}	
	}
	return returndata;
}

@end
