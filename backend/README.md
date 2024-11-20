# Backend

## How to
### Deploy the backend
```bash
./scripts/deploy
```

### Test the backend
See the scripts under `backend/scripts/req/`

For example, invoke:
```bash
./scripts/req/get
```

To test locally, start up the local service with:
```bash
./scripts/start-local
```
and then make requests with `LOCAL=true`. For example:
```bash
LOCAL=true ./scripts/req/get-random
```

### Other SAM Commands
```bash
[*] Validate SAM template: sam validate
[*] Test Function in the Cloud: sam sync --stack-name {{stack-name}} --watch
```


## Architecture

### Technology Choices:

- AWS stack (Lamba, DDB) because I want v1 ASAP & I am familiar with those components
    - Tradeoff: I’m not sure this is really best for the application
    - Tradeoff: Learning a new cloud provider / technology
- Godot because it is the most familiar way for building a UI
    - Tradeoff: I’m guessing I’m missing out on standard mobile functionality (e.g. notifications)

That said, where possible, make components (AWS, Godot) replaceable!

### Lambda

~~Many vs One because: (a) best practice; easier separation of logic (b) easier observability (c) learn; see if it is expensive (d) I don’t think it will be too much more expensive, because it’s mostly just [time used](https://aws.amazon.com/lambda/pricing/) as far as I can tell, and I’d expect the startup time to be minimal comparatively. Discussion [here](https://www.reddit.com/r/aws/comments/uctb3g/separate_lambdas_or_one_lambda/?share_id=7m-9LEMMq4l_pJ3_T88AV&utm_content=1&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1)~~

Single Lambda, because that’s the easiest & fastest. Change when there's a problem

### DynamoDB Table Schema:

```json
{
	"pk": "USER_ID#<USER_ID>", // Partition Key
	"sk": "TASK_CREATED_AT#<CREATED_AT>", // Sort Key
	"id": "<USER_ID>#<CREATED_AT>",
	"label": "Title",
	"description": "more text",
	"status": "TODO|COMPLETED", 
	// v0.2+
	"number_of_skips": 0,
	"weight": 1.0
}
```

### APIs

| API | Route | Request | Response |
| --- | --- | --- | --- |
| POST Create Task | /tasks?user_ID=<USER_ID> | user_id, label
other properties optional | - |
| GET Random Task | /tasks/random?user_ID=<USER_ID> | user_id | Task Object |
| GET Tasks | /tasks?user_ID=<USER_ID> | user_id
Later: Page, Sort, Filters | [] task_id, label, status
page |
| GET Task | /tasks/<TASK_ID>?user_ID=<USER_ID> | task_id, user_id | Task Object |
| PATCH Task | /tasks/<TASK_ID>?user_ID=<USER_ID> | user_id, task_id
anything else | - |

### Random Algorithm

WEighting - don’t try to optimize the DB for it — have server side logic handle it

Algo: iterate through all tasks, calculate weights, then random # in between

Example: Task-1: 1, Task-2: 0.5, Task-3: 2

Key | Task

1

1.5

3.5

(?)