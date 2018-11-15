# Fire::Jenkins::Builder

jenkins job 触发工具

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fire-jenkins-builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fire-jenkins-builder

## Usage

cli :

```sh
jb -p PATH -b BRANCH -l LOG_LEVEL
```

添加如下配置文件至目标根目录下：

```yml
# jenkins job 配置文件
# 可以通过在 commit 中添加 prefix ，使 CI 出发 jenkins job 的创建/构建行为
# 提交 commit 信息
# [jb] XXXXXX 执行 jenkins job ，如果不存在 job ，则会在对应 job_view 下创建并执行
#
########################
#         选填
########################
# job 参数
# 添加自己的钉钉消息等健值对
# 需要注意的是，这里面的配置，模版必须已经存在了，这里只是修改对应的值
parameters:
  REPORTER_ACCESS_TOKEN: XXXXXX
  DEBUG: true

########################
#         必填
########################
# 打包 job 名称 / 前缀名
# 如果 job_name 为空，则采用 job_name_prefix + 分支名称
# job_name: XXXX
job_name_prefix: ZGiOS_
# jenkins 上的分组，对应 view
job_view: 掌柜iOS

# jenkins 用户名密码
username: qingmu
password: xxx

# 各业务线采用不同的模版，配置这里
# 模版工程名称（需要唯一）
template_job_name: ZGiOS_develop

# 这里不动
server_url: 'http://jenkins-shopkeeper-client.2dfire.net'
server_port: 80
```

配置 `.gitlab-ci.yml` :

```sh
stages:
...
  - build
...

...
jenkins_build:
	before_script:
		- gem install fire-jenkins-builder -v 0.1.1 --no-ri --no-rdoc --conservative
  stage: build
  only:
    variables:
      - $CI_COMMIT_MESSAGE =~ /^\[jb\]/
  script: 
    - jb -p .fire-jenkins.yml -b $CI_COMMIT_REF_NAME
  tags:
    - iOSCI
  allow_failure: true
...
```

提交如下 commit 就会触发 jenkins 打包：

```
git commit -m "[jb] XXXXXX"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fire-jenkins-builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fire::Jenkins::Builder project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fire-jenkins-builder/blob/master/CODE_OF_CONDUCT.md).
