## Running the tests

Requires Docker.

### Against local BigBoat instance (http://localhost:3000)

```sh
npm run art
```

### Against remote instance (replace the URL)

```sh
npm run art -- --baseUrl=http://www.remote.bigboat.com
```

### Test coverage

Test coverage results are only available when running the tests locally. To enable instrumentation run BigBoat with:

```sh
COVERAGE=1 COVERAGE_APP_FOLDER=$(pwd)/ meteor
```

Coverage results are available at http://localhost:3000/coverage while BigBoat is running. They are also downloaded to the tests/.coverage folder at the end of the test run.
