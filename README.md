This is a simple library allowing multiple iOS devices to sync data with one another. It also allows data which was created offline to be synced to the server at a later date and handles conflicts made by 2 clients modifying the same data.
See here for more details: http://sfsoftwareist.com/2013/03/30/bringing-your-mobile-user-experience-to-the-next-level/

How it works

The model

There is a one to one correlation between ActiveRecord server models and Coredata managed object models (the sync_status property is the only exception). Each object in their respective databases has the following fields:

sync_status - This field is only found in the Coredata model, not on the server. It has 3 states; Synced, NeedsSync and Conflicted. If it is in the Synced state, all of its modifications have been pushed to the server. The server may have newer modification which the client will receive during the next sync, but the client object has no local modification that the server doesn’t know about.
If the object is in the NeedsSync state, it means that the client has made local modifications to the object which have not been pushed to the server yet (or that the object is new and has never been synced to the server). Once the client syncs with the server the status will be updated to either Synced or Conflicted.
During a sync, if the server discovers that an object being synced has been modified by another client, it will send down the conflicting version of the object to the client which the client will mark as being Conflicted. Once the Conflict is resolved by the client, the resolution will be pushed to the server and the object will be marked as Synced.

is_deleted - This flag is found on both the client and the server models. Since the server  does not keep track of which clients have synced and has no knowledge of the number of clients it is supporting, it must keep a record of which objects have been deleted indefinitely. For this reason, objects are never removed from the database, even if a user ‘deletes’ the content. It is the client’s responsibility to never display objects with an is_deleted flag set.

last_modified - This field is used by the server to determine if an object was modified since the last time a client pulled the data down. This field is only ever updated on the server. If the client attempts to push modifications to an object, and that object has a modification date which is earlier than the server’s version, the server rejects the client’s version and sends back the conflicting version which the client must then resolve.

guid - When the client creates a new object, it is assigned a globally unique identifier. This number is used as the primary key to differentiate between 2 objects. GUIDs are essentially long random hex numbers. These numbers are so large and sufficiently random that the likelihood of 2 being identical is astronomically low; even if they are generated on 2 different devices. This is beneficial because it means 2 different devices can create objects in the database and they can be differentiated from each other.

The sync process

When the client becomes connected to the network again, or when the user presses the ‘sync’ button, the modification date of the most recently modified object in its local database is passed  to the server, along with any objects which are in the NeedsSync state (ie. has local modifications). The server looks at all the newly modified objects, if the last_modified timestamps are different, it knows that its version has changes which the client is unaware of. If the dates are the same, it writes the object to the database, overwriting what was there. It then looks at the timestamp passed by the client. It searches the database for any objects with modification timestamps greater than the one passed up and sends those objects down to the client. It also sends any conflicted objects in a separate array.

The client then writes the new objects to its own database; using guids to update existing objects. If the client discovers any conflicts, it must present the conflict to the user and ask them to resolve the conflict. It does this by showing the user the two version of the object and asks them to manually merge them. Once the merge is complete the client pushes those updates to the server during the next sync operation.
http://stackoverflow.com/questions/5035132/how-to-sync-iphone-core-data-with-web-server-and-then-push-to-other-devices/5052208#5052208
