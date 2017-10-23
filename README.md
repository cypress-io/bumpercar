# cypress-bumpercar

Make it easy to bump versions and re-run CI builds across many projects and CI providers.

[![CircleCI](https://circleci.com/gh/cypress-io/bumpercar.svg?style=svg)](https://circleci.com/gh/cypress-io/bumpercar)
[![semantic-release][semantic-image] ][semantic-url]

[semantic-image]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
[semantic-url]: https://github.com/semantic-release/semantic-release

```coffeescript
bumpercar = require("cypress-bumpercar")

# configure a new Bumpercar
car = bumpercar.create({
  providers: {
    travis: {
      # find/create one here: https://github.com/settings/tokens
      githubToken: "github-token-for-user-with-repo-privileges"
    }
    circle: {
      # find/create one here: https://circleci.com/account/api
      circleToken: "circle-token-for-user-with-project-privileges"
    }
  }
})

# bump your ENV vars with ease
car.updateProjectEnv("cypress-io/cypress-download", "circle", {
  VAR_1: "lo"
  VAR_2: "and"
  VAR_3: "behold"
})

.then ->
  # kick off a new build/run with your new vars
  car.runProject("cypress-io/cypress-download", "circle")
```

## API

This module supports

* Travis
  - [x] setting environment variables
  - [x] fetch last build by id
  - [x] restart build by id
* CircleCI
  - [x] setting environment variables
  - [x] starting a build
* AppVeyor
  - [x] setting environment variables
  - [ ] starting a build
* Buildkite
  - [x] setting environment variables
  - [ ] starting a build

## Testing

- `npm test` runs the unit tests once
- `npm run watch` keeps watching for file changes and reruns the tests

## Debugging

Run commands with `DEBUG=bumper` environment variable

## Changelog

#### 1.0.6 - *(04/20/17)*
- bump cypress coffee script and releaser dep

#### 1.0.5 - *(03/10/17)*
- add cypress-core-releaser to the mix and do a release
