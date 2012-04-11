#import "Kiwi.h"
#import "CoreData+MagicalRecord.h"
#import "Post.h"
#import "SyncStorageManager.h"

SPEC_BEGIN(SyncObjectSpec)
describe(@"SyncObject", ^{
 	__block SyncStorageManager *mgr = nil;
	beforeEach(^{
		mgr = [[SyncStorageManager alloc] initWithBaseURL:@"http://localhost"];
	});
	afterEach(^{
		[mgr cleanup];
		mgr = nil;
	});
	
	it(@"should return 1 attribute diff", ^{
		Post * postA = [Post MR_createEntity];
		NSString *postABody = @"This is the body for post A";
		postA.body = postABody;
		
		Post *postB = [Post MR_createEntity];
		NSString *postBBody = @"This is the body for post B";
		postB.body = postBBody;
		
		NSDictionary *diff = [postA diff:postB];
		
		NSDictionary *postBodyDiff = [diff objectForKey:kBodyKey];
		[[postBodyDiff should] beNonNil];
		
		NSString * receiverValue = [postBodyDiff objectForKey:kReceiverKey];
		[[receiverValue should] beNonNil];
		[[receiverValue should] equal:postABody];
		
		NSString *otherValue = [postBodyDiff objectForKey:kOtherKey];
		[[otherValue should] beNonNil];
		[[otherValue should] equal:postBBody];
		
	});
});
SPEC_END