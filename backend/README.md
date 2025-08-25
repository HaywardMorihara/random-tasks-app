# Backend

## How to
### Deploy the backend
Auth: you'll be asked to configure AWS. You'll find those in your LastPass account.

```bash
./scripts/deploy
```
 
The deployment configuration and local development scripts make use of [AWS SAM (Serverless Application Mode)](https://aws.amazon.com/serverless/sam/) which is essentially a CLI and a framework on top of CloudFormation templates that makes development & deployment with Lambdas easier.

Other SAM Commands:
```bash
[*] Validate SAM template: sam validate
[*] Test Function in the Cloud: sam sync --stack-name {{stack-name}} --watch
```

### Make backend requests
See the scripts under `backend/scripts/req/`

For example, invoke:
```bash
export REMOTE=true
./scripts/req/get-random
```

### Run the backend locally
To test locally, start up the local service with:
```bash
./scripts/start-local
```
and then make requests with `LOCAL=true`. For example:
```bash
./scripts/req/get-random
```
(Note: Requests are made to the remote DynamoDB instance)


### Run unit tests
```bash
./scripts/test
```

## Architecture

AWS stack (API Gateway + Lamba + DynamoDB) because I want v0 ASAP & I am already familiar with those components
    - Tradeoff: I’m not sure this is really best for the application
    - Tradeoff: Learning a new cloud provider / technology

That said, where possible, make components (AWS, Godot) replaceable!

### Lambda

~~Many vs One because: (a) best practice; easier separation of logic (b) easier observability (c) learn; see if it is expensive (d) I don’t think it will be too much more expensive, because it’s mostly just [time used](https://aws.amazon.com/lambda/pricing/) as far as I can tell, and I’d expect the startup time to be minimal comparatively. Discussion [here](https://www.reddit.com/r/aws/comments/uctb3g/separate_lambdas_or_one_lambda/?share_id=7m-9LEMMq4l_pJ3_T88AV&utm_content=1&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1)~~

Single Lambda, because that’s the easiest & fastest. Change when there's a problem

### DynamoDB Table Schema:

Tasks:
```json
{
	"pk": "USER_ID#<USER_ID>", // Partition Key
	"sk": "TASK_CREATED_AT#<CREATED_AT>", // Sort Key
	"id": "<USER_ID>-<CREATED_AT>",
	"label": "Title",
	"description": "more text",
	"status": "TODO|COMPLETED", 
	// v0.2+
	"number_of_skips": 0,
	"weight": 1.0
}
```

Users:
```json
{
	"pk": "USER_ID#<USER_ID>", // Partition Key
	"sk": "USER_ID#<USER_ID>", // Sort Key
	"id": "<USER_ID>", // UUID
	"username": "Nathaniel Morihara"
}
```
Note: In retrospect, should consider making a `PK: USERS, SK: USER#<USER_ID>` -- that way, wouldn't need a `UsernameIndex` GSI 

### APIs

| API | Route | Request | Response |
| --- | --- | --- | --- |
| POST Create Task | /tasks?user_id=<USER_ID> | user_id, label, other properties optional | - |
| GET Random Task | /tasks/random?user_id=<USER_ID> | user_id | Task Object |
| GET Tasks | /tasks?user_id=<USER_ID> | user_id (Later: Page, Sort, Filters) | [] { task_id, label, status }, paged |
| GET Task | /tasks/<TASK_ID>?user_id=<USER_ID> | task_id, user_id | Task Object |
| PATCH Task | /tasks/<TASK_ID>?user_id=<USER_ID> | user_id, task_id, other patchable properties optional | - |
| POST Sign In | /users/signin | username | { username, user_id } |

### Random Algorithm

**Calculation on READs rather than WRITEs**

Because it's simpler -- you don't have to calculate denormalized data and do READ _and_ WRITE on WRITEs. Simplicity is very important (for velocity & maintenance).

The extra slowness on READs is minimal and a tradeoff we can afford to make.

**Float probabilities rather than integer**

1.0 is the default, and a low probability task is 0.5 or 0.25 and a high probability task is 2.0 or 4.0. 

NOT 1 for low probability task, 3 for default, and 5 for high probability.

Because flots are a lot more flexible & future-proof -- it's easy to allow for new values in the future.

The tradeoff is the random selection algorithm might have to be a little more complicated. Which leads to...

**CDF array rather than entries multiplied by probability**

Algorithm:
1. Fetch ALL tasks.
2. Iterate through all tasks. For each task, add it to a new array; include a "cumulative density function" values (sum of all the weights so far)
3. Get a random value between 0.0 and the CDF value of the last entry.
4. Do a binary search through the CDF array, finding the entry that has a CDF value less than the random value and the entry to the right is greater than the random value (or it's the last value in the array).

Tradeoff: Some complexity.

More info: https://stackoverflow.com/questions/4463561/weighted-random-selection-from-array

Alternative Algorithm:
1. Fetch ALL tasks.
2. Iterate through all tasks. For each task, add it to X times to a array time, where X is the weight of the task.
3. Get a random value between 1 and the length of the new array.
4. Get the task at the index of the random value.

Tradeoffs: While it's _maybe_ slightly faster, it also (a) has a bigger memory footprint, but more importantly (b) works with floating values for weights (this algorithm wouldn't work with floating values unless you know the smallest possible weight and they're all multiples of each other. In which case, you kinda might as well use integers, and you lost the flexibility)

### User Login
See Notion for details