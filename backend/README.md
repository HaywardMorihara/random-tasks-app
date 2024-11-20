# Backend

# How to
## Deploy the backend
```bash
./scripts/deploy
```

## Test the backend
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

## Other SAM Commands
```bash
[*] Validate SAM template: sam validate
[*] Test Function in the Cloud: sam sync --stack-name {{stack-name}} --watch
```
