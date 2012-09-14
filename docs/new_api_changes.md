## New API Details

### Build Facebook User

**POST /users/build** - Create a bootstrapped user with most of their details filled out by passing only their `facebook_id` and `facebook_access_token`.

	{ "user" : { "facebook_id" : "XXXX", "facebook_access_token": "ZZZZ" } }

**Response**

User object (i'm doing this on the subway so I have no connection to test w/ fb)

### Query Locations by lat/lng

**GET /locations/search?latitude=(latitude)&longitude=(longitude)** - Fetch locations near the passed lat/lng point. Response contains a `distance` parameter to sort results by proximity to the query.

**Response** 

Location object response (subway… boo no 3G)

### Query Interests by Keyword

**GET /interests/?q=(keyword)** - I should probably align this with locations by putting it under the `/search` sub-path, but if I do that I will tell you in an absolute email so that you are aware of the change.

**Response**

An array of interests.

## Updating the User

### Setting User Interests

**PUT /me** - Any time you want to update user data, perform a `PUT` to `/me`. The user you are modifying is determined by the access token you are passing in the `Authorize` header once a user is logged-in.

You can put almost anything in this request and it will update the user. Let me demonstrate the new methods to update **interests** and **location**.

### Setting Interests

**PUT /me** - There are two ways to do this, by setting `interest_names` or `interest_ids`. Each is an array, the first, `interest_names` being an array of strings for the interests. For example:

	# an example request to set by interest_names
	{ "user": { "interest_names": [ "Running", "Dancing", "Partying" ] } }

The alternative is to pass an array of `id`'s for the interest you are setting. This is probably a method that you won't use, since it will not automatically create the interest if it does not exist. But I wanted to provide you the access just in case.

	# an example request to set by interest_ids
	{ "user": { "interest_ids": [ 10, 349, 2, 99 ] } }

When performing this during a normal PUT request, you'll see a `204` resposne when successful.

### Setting Location

**PUT /me** - Location is set similarly to other parameters, but you define it as `location_id`. After performing query, displaying the locations to the user, and allowing them to choose one … you'll ultimately have an `id` from the location object you can use for this call. Set the `user:location_id` to this value:

	{ "user": { "location_id": 3 } }

This will set the user's location to the location with the id of 3.


