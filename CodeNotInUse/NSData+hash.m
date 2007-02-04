/****************************************************************************
 *  Copyright 2006 Aaron Rolett                                             *
 *  arolett@mail.rochester.edu                                              *
 *                                                                          *
 *  This file is part of PandoraBoy.                                        *
 *                                                                          *
 *  PandoraBoy is free software; you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by    * 
 *  the Free Software Foundation; either version 2 of the License, or       *
 *  (at your option) any later version.                                     *
 *                                                                          *
 *  PandoraBoy is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           * 
 *  GNU General Public License for more details.                            *
 *                                                                          *
 *  You should have received a copy of the GNU General Public License       * 
 *  along with PandoraBoy; if not, write to the Free Software Foundation,   *
 *  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA          *
 ***************************************************************************/

// Some of this code is based on code found at http://www.cocoadev.com/index.pl?NSDataCategory
// and released under a BSD License. That code remains copyright the original authors

#import "NSData+hash.h"

#include <openssl/md5.h>

@implementation NSData_hash

// Returns range [start, null byte), or (NSNotFound, 0).
- (NSRange) rangeOfNullTerminatedBytesFrom:(int)start
{
	const Byte *pdata = [self bytes];
	int len = [self length];
	if (start < len)
	{
		const Byte *end = memchr (pdata + start, 0x00, len - start);
		if (end != NULL) return NSMakeRange (start, end - (pdata + start));
	}
	return NSMakeRange (NSNotFound, 0);
}

// Hash functions 
#define HEComputeDigest(method)				        \
	method##_CTX ctx;					\
	unsigned char digest[method##_DIGEST_LENGTH];		\
	method##_Init(&ctx);					\
	method##_Update(&ctx, [self bytes], [self length]);	\
	method##_Final(digest, &ctx);

#define HEComputeDigestNSData(method)				              \
	HEComputeDigest(method)					              \
	return [NSData dataWithBytes:digest length:method##_DIGEST_LENGTH];

#define HEComputeDigestNSString(method)				              \
	static char __HEHexDigits[] = "0123456789abcdef";		      \
	unsigned char digestString[2*method##_DIGEST_LENGTH];                 \
	unsigned int i;							      \
	HEComputeDigest(method)						      \
	for(i=0; i<method##_DIGEST_LENGTH; i++) {			      \
		digestString[2*i]   = __HEHexDigits[digest[i] >> 4];	      \
		digestString[2*i+1] = __HEHexDigits[digest[i] & 0x0f];        \
	}								      \
	return [NSString stringWithCString:(char *)digestString length:2*method##_DIGEST_LENGTH];

- (NSData*) md5Digest
{
	HEComputeDigestNSData(MD5);
}

- (NSString*) md5DigestString
{
	HEComputeDigestNSString(MD5);
}
@end
