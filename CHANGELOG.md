## [0.20.1](https://github.com/cerico/macfair/compare/v0.20.0...v0.20.1) (2023-03-15)


### Bug Fixes

* dont recreate host file if exists, replace localhost entry in host file ([f643249](https://github.com/cerico/macfair/commit/f643249294957b501232ce29486cdc873879ccc4))



# [0.20.0](https://github.com/cerico/macfair/compare/v0.19.3...v0.20.0) (2023-03-15)


### Features

* add git alias for un-adding back to main ([7e3bc29](https://github.com/cerico/macfair/commit/7e3bc29599dab2ddb40cb2a4011b8b1e7208c763))



## [0.19.3](https://github.com/cerico/macfair/compare/v0.19.2...v0.19.3) (2023-03-15)


### Bug Fixes

* rename checkhost role to afterwards and only register if defined ([0e2e0e2](https://github.com/cerico/macfair/commit/0e2e0e249d5e590c15a694e2bfae69cf4fd59e7e))



## [0.19.2](https://github.com/cerico/macfair/compare/v0.19.1...v0.19.2) (2023-03-14)


### Bug Fixes

* strip quotes from version output for macfair command ([47083a7](https://github.com/cerico/macfair/commit/47083a794158db902a62335fc34e9876cb9e310e))



## [0.19.1](https://github.com/cerico/macfair/compare/v0.19.0...v0.19.1) (2023-03-14)


### Bug Fixes

* remove checkhost role and invoke directly in main playbook instead ([a159955](https://github.com/cerico/macfair/commit/a159955926e6682ba121cfb6a831c52ef81ba7ee))
* remove unused targets from Makefile ([8ebf048](https://github.com/cerico/macfair/commit/8ebf0480d218c21f4b5b879465509d334541fbac))



# [0.19.0](https://github.com/cerico/macfair/compare/v0.18.4...v0.19.0) (2023-03-14)


### Features

* add versioning ([3a7454d](https://github.com/cerico/macfair/commit/3a7454d0810d43041630242727eb34208497cb0b))



## [0.18.4](https://github.com/cerico/macfair/compare/v0.18.3...v0.18.4) (2023-03-14)


### Bug Fixes

* simplify Makefile and setup.yml ([b088960](https://github.com/cerico/macfair/commit/b08896026d98ba0c58183d10325eb8bf8fc5b32d))
* update readme and help docs ([6d35b31](https://github.com/cerico/macfair/commit/6d35b316a2c7b355b6c7a255882d863d1a2f3844))



## [0.18.3](https://github.com/cerico/macfair/compare/v0.18.2...v0.18.3) (2023-03-14)


### Bug Fixes

* re-add example file to host_vars dir ([2e09603](https://github.com/cerico/macfair/commit/2e096037fe58dd06a5468319bf96ed1ebfba6898))



## [0.18.2](https://github.com/cerico/macfair/compare/v0.18.1...v0.18.2) (2023-03-13)


### Bug Fixes

* setup sudoers on localhost ([c22fc0b](https://github.com/cerico/macfair/commit/c22fc0b50aa30dccd793c48ad825e1a4cefc4d9d))



## [0.18.1](https://github.com/cerico/macfair/compare/v0.18.0...v0.18.1) (2023-03-13)


### Bug Fixes

* correct location of generated host_vars directory ([5d94503](https://github.com/cerico/macfair/commit/5d945037a307dc5a5018c2c9e7349080962301d7))
* update ansible collection requirements with community.general ([d4af3dd](https://github.com/cerico/macfair/commit/d4af3dddda981ba37faf1c5da58acb9f0a2dd617))



# [0.18.0](https://github.com/cerico/macfair/compare/v0.17.1...v0.18.0) (2023-03-13)


### Features

* add playbook to setup inventory and vars ([1f1b275](https://github.com/cerico/macfair/commit/1f1b2751dccbe74ad525a9dd6c5f85461c5163ff))



## [0.17.1](https://github.com/cerico/macfair/compare/v0.17.0...v0.17.1) (2023-03-13)


### Bug Fixes

* set ansible tmp dir explicitly ([45c43c3](https://github.com/cerico/macfair/commit/45c43c313b14182e8984680bb049d8f4acd856a6))



# [0.17.0](https://github.com/cerico/macfair/compare/v0.16.0...v0.17.0) (2023-03-13)


### Features

* add rule to add new targets to inventory ([1edf234](https://github.com/cerico/macfair/commit/1edf234b28ca2c0d9c203eef7ad2539960468f56))



# [0.16.0](https://github.com/cerico/macfair/compare/v0.15.3...v0.16.0) (2023-03-13)


### Features

* add newsite target ([ad1fe9f](https://github.com/cerico/macfair/commit/ad1fe9ff0c3dc542cc33e9a4d3b9562aa2be637a))



## [0.15.3](https://github.com/cerico/macfair/compare/v0.15.2...v0.15.3) (2023-03-13)


### Bug Fixes

* turn off password authentication for users with keys ([196358b](https://github.com/cerico/macfair/commit/196358b738f2239c951eb49f576a9f6da3f463b4))



## [0.15.2](https://github.com/cerico/macfair/compare/v0.15.1...v0.15.2) (2023-03-13)


### Bug Fixes

* add an error page for 403 forbidden ([9919e07](https://github.com/cerico/macfair/commit/9919e074d027c618896daa7f76a2729b00622fea))
* remove link to css in error pages ([d9fef63](https://github.com/cerico/macfair/commit/d9fef6338e1dd1072f1a9ab325833bfd67feafb8))



## [0.15.1](https://github.com/cerico/macfair/compare/v0.15.0...v0.15.1) (2023-03-13)


### Bug Fixes

* add 404 and 503 error pages and handling to webserver role ([117626a](https://github.com/cerico/macfair/commit/117626aa290b1b578e7b0bdbc1c85ad2dacbfe59))
* rename webserver role to nginx ([4f71677](https://github.com/cerico/macfair/commit/4f716770c86a2213608eee1be58522cfd7000b66))



# [0.15.0](https://github.com/cerico/macfair/compare/v0.14.1...v0.15.0) (2023-03-12)


### Features

* add godaddy api functions ([98d270c](https://github.com/cerico/macfair/commit/98d270c93e206534a23f2ec912098885b5e37c30))



## [0.14.1](https://github.com/cerico/macfair/compare/v0.14.0...v0.14.1) (2023-03-12)


### Bug Fixes

* improved handling of sudoing on remote box ([4805ca8](https://github.com/cerico/macfair/commit/4805ca8c98318fd1b58cb784271c2a6b46a5d4d9))



# [0.14.0](https://github.com/cerico/macfair/compare/v0.13.0...v0.14.0) (2023-03-12)


### Bug Fixes

* remove need to ask-become-pass, and use inventory_hostname ([7ded43e](https://github.com/cerico/macfair/commit/7ded43e9692bc8ab16e5143afc7408bb994f6108))
* update example hosts and vars ([2b64c1d](https://github.com/cerico/macfair/commit/2b64c1d572fa57c838a89b114507b427ab30f2ea))


### Features

* add roles for remote login and key transfers ([e6bcf94](https://github.com/cerico/macfair/commit/e6bcf943e0b288bddf0bc893234dcbe1deb06034))



# [0.13.0](https://github.com/cerico/macfair/compare/v0.12.0...v0.13.0) (2023-03-12)


### Features

* add webserver role with nginx ([c7984b4](https://github.com/cerico/macfair/commit/c7984b4f33ccf734e00350ad7a286c3a0b8e184d))



# [0.12.0](https://github.com/cerico/macfair/compare/v0.11.3...v0.12.0) (2023-03-12)


### Features

* update installs and roles for debian targets ([4c66543](https://github.com/cerico/macfair/commit/4c6654394a84fccf0b46d7637aef82f2661bd49e))



## [0.11.3](https://github.com/cerico/macfair/compare/v0.11.2...v0.11.3) (2023-03-12)


### Bug Fixes

* add missing passlib install ([3a79168](https://github.com/cerico/macfair/commit/3a791680d31c38f1905a63eb91ba13cc9caf182c))



## [0.11.2](https://github.com/cerico/macfair/compare/v0.11.1...v0.11.2) (2023-03-12)


### Bug Fixes

* show location info in motd only if exists ([0550f00](https://github.com/cerico/macfair/commit/0550f001c894c4e7e1214622e9b0da275f4b4e65))



## [0.11.1](https://github.com/cerico/macfair/compare/v0.11.0...v0.11.1) (2023-03-09)


### Bug Fixes

* update debugcss snippet ([ed68957](https://github.com/cerico/macfair/commit/ed68957376dd8630ad56f1cd050fd1c8ded9d400))



# [0.11.0](https://github.com/cerico/macfair/compare/v0.10.5...v0.11.0) (2023-03-09)


### Features

* add debug css snippet ([3b70106](https://github.com/cerico/macfair/commit/3b7010637c3059de7397949aeb3bbdc1b7ad99df))



## [0.10.5](https://github.com/cerico/macfair/compare/v0.10.4...v0.10.5) (2023-03-09)


### Bug Fixes

* add full path for ansible-playbook in 'make keys' ([fcff998](https://github.com/cerico/macfair/commit/fcff9989ce45c96d4af81cae5eae52743c33c777))



## [0.10.4](https://github.com/cerico/macfair/compare/v0.10.3...v0.10.4) (2023-03-05)


### Bug Fixes

* dont pin conventional-changelog-action to 3.7.1 ([b4674f3](https://github.com/cerico/macfair/commit/b4674f31f8c4cca5d24fd028424cd21c0d37fb9a))



## [0.10.3](https://github.com/cerico/macfair/compare/v0.10.2...v0.10.3) (2023-03-05)


### Bug Fixes

* script run to add newlines to files where its missing ([e2aafa0](https://github.com/cerico/macfair/commit/e2aafa0669c5f4bffeee983b64c0abb41b50464c))



## [0.10.2](https://github.com/cerico/macfair/compare/v0.10.1...v0.10.2) (2023-03-05)


### Bug Fixes

* add aliases for finding files w no newline at eof, and adding one ([124be55](https://github.com/cerico/macfair/commit/124be55bd5a7b7cb34c7984ffa42daf4ccdb85b1))
* add newline setting to vscode ([dd51135](https://github.com/cerico/macfair/commit/dd51135022d3154cb530e13a3cb5e12bd3022598))
* add vscode to gitignore ([1fa03aa](https://github.com/cerico/macfair/commit/1fa03aa0cfe1604b492a79381f3c49493d47a90d))



## [0.10.1](https://github.com/cerico/macfair/compare/v0.10.0...v0.10.1) (2023-03-03)


### Bug Fixes

* set release count to 0 in changelog action to preserve all releases ([a34623d](https://github.com/cerico/macfair/commit/a34623db9a9d98755c267af0e880421d0595e8af))



# [0.10.0](https://github.com/cerico/macfair/compare/v0.9.0...v0.10.0) (2023-03-03)


### Features

* add github copilot extension ([74f350b](https://github.com/cerico/macfair/commit/74f350b52428d9bfba5f574dbab509ae762209ae))



# [0.9.0](https://github.com/cerico/macfair/compare/v0.8.1...v0.9.0) (2023-03-03)


### Features

* add index.html snippet ([2cf3948](https://github.com/cerico/macfair/commit/2cf3948cb8c096379e48ee66c613f9cfd55787f3))
* add js snippet extension ([abe76d2](https://github.com/cerico/macfair/commit/abe76d20e3a5dbba678314120fb338defa9c6bc3))



## [0.8.1](https://github.com/cerico/macfair/compare/v0.8.0...v0.8.1) (2023-03-01)


### Bug Fixes

* Add versioning to alias file ([ae995c4](https://github.com/cerico/macfair/commit/ae995c495bb06c3b8278b6edd0d40f2b6de363e4))



# [0.8.0](https://github.com/cerico/macfair/compare/v0.7.1...v0.8.0) (2023-03-01)


### Features

* vsc function updates theme for project not globally ([2907407](https://github.com/cerico/macfair/commit/290740703d254d26366232d6cea8994641d506ca))



## [0.7.1](https://github.com/cerico/macfair/compare/v0.7.0...v0.7.1) (2023-02-22)


### Bug Fixes

* git hook for message length now working ([2d20193](https://github.com/cerico/macfair/commit/2d20193975d23dd59256fce73b14c5d944d2ecbc))



# [0.7.0](https://github.com/cerico/macfair/compare/v0.6.2...v0.7.0) (2023-02-09)


### Bug Fixes

* readd rails alias file if not present ([3a7d2d0](https://github.com/cerico/macfair/commit/3a7d2d0380a0514368d933d43be8934a3685a951))


### Features

* improve batt alias ([670420c](https://github.com/cerico/macfair/commit/670420c0ddcecb4151b253063e9ac7c02b6e1200))



## [0.6.2](https://github.com/cerico/macfair/compare/v0.6.1...v0.6.2) (2023-02-07)


### Bug Fixes

* bug in themes alias looking at incorrect path ([ee9c478](https://github.com/cerico/macfair/commit/ee9c478a0b97a28b6a59f923c7b663e29bf00def))



## [0.6.1](https://github.com/cerico/macfair/compare/v0.6.0...v0.6.1) (2023-02-07)


### Bug Fixes

* dont push on commit alias ([69db7d1](https://github.com/cerico/macfair/commit/69db7d1cde15e4cc8ad480927c3019f69c7fd6c3))



# [0.6.0](https://github.com/cerico/macfair/compare/v0.5.2...v0.6.0) (2023-02-07)


### Features

* allow commits to be prefaced with wip ([0dbbea1](https://github.com/cerico/macfair/commit/0dbbea1becf6afaa8a3635d7977326858f539d3e))



## [0.5.2](https://github.com/cerico/macfair/compare/v0.5.1...v0.5.2) (2023-02-07)


### Bug Fixes

* updated makefile to add debug target and remove git targets ([b1e7027](https://github.com/cerico/macfair/commit/b1e702793cdb0e3ebb92583f3a808fc9867fcd59))



## [0.5.1](https://github.com/cerico/macfair/compare/v0.5.0...v0.5.1) (2023-02-07)


### Bug Fixes

* update prepare step to handle keys directly ([efdf033](https://github.com/cerico/macfair/commit/efdf0338d0cde250f6189221d81bf389010e10f2))



# [0.5.0](https://github.com/cerico/macfair/compare/v0.4.0...v0.5.0) (2023-02-06)


### Features

* new git aliases for pull requests ([7937978](https://github.com/cerico/macfair/commit/79379780c5005f0f6b86e21b094ef3059a18cd02))



# [0.4.0](https://github.com/cerico/macfair/compare/v0.3.0...v0.4.0) (2023-02-06)


### Bug Fixes

* clean up commit-msg-template file ([02fa3b6](https://github.com/cerico/macfair/commit/02fa3b6378189345974577cd98c52a1aa784d316))
* remove git target from makefile ([2c624d4](https://github.com/cerico/macfair/commit/2c624d4f1b5a14fc0dc72ed51e99337fc0ec48b1))


### Features

* Added global pre-commit and commit-msg hooks ([ad631f5](https://github.com/cerico/macfair/commit/ad631f57f7790907124d52df4dde88639eb0c03e))



# [0.3.0](https://github.com/cerico/macfair/compare/v0.0.4...v0.3.0) (2023-02-06)


### Bug Fixes

* remove unused git files ([c1066dd](https://github.com/cerico/macfair/commit/c1066dd57c4654e936735e0e1d5adb4effe27dc4))
* remove unused github action file ([bbb571e](https://github.com/cerico/macfair/commit/bbb571e1e8cd85fa27851e8896d5a7dca5f0d11b))
* test bumped version ([030ac63](https://github.com/cerico/macfair/commit/030ac63f783537adf57e28e4a87d65f7af1cbcf4))
* test bumped version ([0e083f6](https://github.com/cerico/macfair/commit/0e083f6e2f70c99a7e23b78085bea6792a33ceb2))
* test for github action workflow ([0a5e3cf](https://github.com/cerico/macfair/commit/0a5e3cf772c5a85a2a89ba183d1aa17072ff7ddb))
* update todo ([03399fb](https://github.com/cerico/macfair/commit/03399fbee55330f8c45534a3ea7d2aef9ae46e37))
* update todo template ([8503d91](https://github.com/cerico/macfair/commit/8503d917812406f4cd8443a06acaf3b935f0b2c8))


### Features

* Added gitconfig to aliases role ([0e91bf3](https://github.com/cerico/macfair/commit/0e91bf304da3f3876c94190cbfe5d6992611cfad))



