//
//  FKFlickrTagsGetRelated.h
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrAPIMethod.h"

typedef NS_ENUM(NSInteger, FKFlickrTagsGetRelatedError) {
	FKFlickrTagsGetRelatedError_TagNotFound = 1,		 /* The tag argument was missing. */
	FKFlickrTagsGetRelatedError_InvalidAPIKey = 100,		 /* The API key passed was not valid or has expired. */
	FKFlickrTagsGetRelatedError_ServiceCurrentlyUnavailable = 105,		 /* The requested service is temporarily unavailable. */
	FKFlickrTagsGetRelatedError_WriteOperationFailed = 106,		 /* The requested operation failed due to a temporary issue. */
	FKFlickrTagsGetRelatedError_FormatXXXNotFound = 111,		 /* The requested response format was not found. */
	FKFlickrTagsGetRelatedError_MethodXXXNotFound = 112,		 /* The requested method was not found. */
	FKFlickrTagsGetRelatedError_InvalidSOAPEnvelope = 114,		 /* The SOAP envelope send in the request could not be parsed. */
	FKFlickrTagsGetRelatedError_InvalidXMLRPCMethodCall = 115,		 /* The XML-RPC request document could not be parsed. */
	FKFlickrTagsGetRelatedError_BadURLFound = 116,		 /* One or more arguments contained a URL that has been used for abuse on Flickr. */

};

/*

Returns a list of tags 'related' to the given tag, based on clustered usage analysis.


Response:

<tags source="london">
	<tag>england</tag>
	<tag>thames</tag>
	<tag>tube</tag>
	<tag>bigben</tag>
	<tag>uk</tag>
</tags>


*/
@interface FKFlickrTagsGetRelated : NSObject <FKFlickrAPIMethod>

/* The tag to fetch related tags for. */
@property (nonatomic, copy) NSString *tag; /* (Required) */


@end