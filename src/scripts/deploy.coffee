# Description
#   Cut GitHub deployments from chat that deploy via hooks - https://github.com/atmos/hubot-deploy
#
# Commands:
#   hubot where can I deploy <app> - see what environments you can deploy app
#   hubot deploy:version - show the script version and node/environment info
#   hubot deploy <app>/<branch> to <env>/<roles> - deploys <app>'s <branch> to the <env> environment's <roles> servers
#   hubot deploys <app>/<branch> in <env> - Displays recent deployments for <app>'s <branch> in the <env> environment
#
supported_tasks = [ DeployPrefix ]

Path          = require("path")
Version       = require(Path.join(__dirname, "..", "version")).Version
Patterns      = require(Path.join(__dirname, "..", "models", "patterns"))
Formatters    = require(Path.join(__dirname, "..", "models", "formatters"))
Deployment    = require(Path.join(__dirname, "..", "github", "api")).Deployment

DeployPrefix   = Patterns.DeployPrefix
DeployPattern  = Patterns.DeployPattern
DeploysPattern = Patterns.DeploysPattern

Verifiers     = require(Path.join(__dirname, "..", "models", "verifiers"))
TokenForBrain = Verifiers.VaultKey

defaultDeploymentEnvironment = () ->
  process.env.HUBOT_DEPLOY_DEFAULT_ENVIRONMENT || 'production'

buildDeployment = (robot, msg, task, force, name, ref, env, hosts, yubikey) ->
  deployment = new Deployment(name, ref, task, env, force, hosts)

  unless deployment.isValidApp()
    msg.reply "#{name}? Never heard of it."
    return
  unless deployment.isValidEnv()
    msg.reply "#{name} doesn't seem to have an #{env} environment."
    return
  unless deployment.isAllowedRoom(msg.message.user.room)
    msg.reply "#{name} is not allowed to be deployed from this room."
    return

  user = robot.brain.userForId msg.envelope.user.id
  token = robot.vault.forUser(user).get(TokenForBrain)
  if token?
    deployment.setUserToken(token)

  deployment.user = user.name
  deployment.room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById(msg.message.user.room).name

  deployment.yubikey   = yubikey
  deployment.adapter   = robot.adapterName
  deployment.userName  = user.name
  deployment.robotName = robot.name

  return deployment

###########################################################################
module.exports = (robot) ->
  ###########################################################################
  # where can i deploy <app>
  #
  # Displays the available environments for an application
  robot.respond ///where\s+can\s+i\s+#{DeployPrefix}\s+([-_\.0-9a-z]+)///i, id: "hubot-deploy.wcid", (msg) ->
    name = msg.match[1]

    try
      if !msg.message.thread_ts
        msg.message.thread_ts = msg.message.rawMessage.ts

      deployment = new Deployment(name)
      formatter  = new Formatters.WhereFormatter(deployment)

      robot.emit "hubot_deploy_available_environments", msg, deployment

    catch err
      robot.logger.info "Exploded looking for deployment locations: #{err}"

  ###########################################################################
  # deploys <app> in <env>
  #
  # Displays the recent deployments for an application in an environment
  robot.respond DeploysPattern, id: "hubot-deploy.recent", hubotDeployAuthenticate: true, (msg) ->
    name        = msg.match[2]
    environment = msg.match[4] || ""

    try
      if !msg.message.thread_ts
        msg.message.thread_ts = msg.message.rawMessage.ts

      deployment = new Deployment(name, null, null, environment)
      unless deployment.isValidApp()
        msg.reply "#{name}? Never heard of it."
        return
      unless deployment.isValidEnv()
        if environment.length > 0
          msg.reply "#{name} doesn't seem to have an #{environment} environment."
          return

      user = robot.brain.userForId msg.envelope.user.id
      token = robot.vault.forUser(user).get(TokenForBrain)
      if token?
        deployment.setUserToken(token)

      deployment.user = user.name
      deployment.room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById(msg.message.user.room).name

      deployment.adapter   = robot.adapterName
      deployment.robotName = robot.name

      deployment.latest (err, deployments) ->
        formatter = new Formatters.LatestFormatter(deployment, deployments)
        robot.emit "hubot_deploy_recent_deployments", msg, deployment, deployments, formatter

    catch err
      robot.logger.info "Exploded looking for recent deployments: #{err}"

  ###########################################################################
  # deploy hubot/topic-branch to staging
  #
  # Actually dispatch deployment requests to GitHub
  robot.respond DeployPattern, id: "hubot-deploy.create", hubotDeployAuthenticate: true, (msg) ->
    task  = msg.match[1].replace(DeployPrefix, "deploy")
    force = msg.match[2] == '!'
    name  = msg.match[3]
    ref   = (msg.match[4]||'master')
    env   = (msg.match[5]||defaultDeploymentEnvironment())
    hosts = (msg.match[6]||'')
    yubikey = msg.match[7]

    if !msg.message.thread_ts
      msg.message.thread_ts = msg.message.rawMessage.ts

    if name is "v1"
      deployment = buildDeployment(robot, msg, task, force, "webapp", ref, env, hosts, yubikey)
      deploymentPhpWorkers = buildDeployment(robot, msg, task, force, "phpworkers", ref, env, hosts, yubikey)
      deploymentTag = buildDeployment(robot, msg, task, force, "tag", ref, env, hosts, yubikey)
      deploymentImgapi = buildDeployment(robot, msg, task, force, "imgapi", ref, env, hosts, yubikey)

      if process.env.HUBOT_DEPLOY_EMIT_GITHUB_DEPLOYMENTS
        robot.emit "github_deployment", msg, deployment
        robot.emit "github_deployment", msg, deploymentPhpWorkers
        robot.emit "github_deployment", msg, deploymentTag
        robot.emit "github_deployment", msg, deploymentImgapi
      else
        deployment.post (err, status, body, headers, responseMessage) ->
          msg.reply responseMessage if responseMessage?

        deploymentPhpWorkers.post (err, status, body, headers, responseMessage) ->
          msg.reply responseMessage if responseMessage?

        deploymentTag.post (err, status, body, headers, responseMessage) ->
          msg.reply responseMessage if responseMessage?

        deploymentImgapi.post (err, status, body, headers, responseMessage) ->
          msg.reply responseMessage if responseMessage?
    else
      deployment = buildDeployment(robot, msg, task, force, name, ref, env, hosts, yubikey)
      if deployment?
        if process.env.HUBOT_DEPLOY_EMIT_GITHUB_DEPLOYMENTS
          robot.emit "github_deployment", msg, deployment
        else
          deployment.post (err, status, body, headers, responseMessage) ->
            msg.reply responseMessage if responseMessage?

  ###########################################################################
  # deploy:version
  #
  # Useful for debugging
  robot.respond ///#{DeployPrefix}\:version$///i, id: "hubot-deploy.version", (msg) ->
    if !msg.message.thread_ts
        msg.message.thread_ts = msg.message.rawMessage.ts
    msg.send "hubot-deploy v#{Version}/hubot v#{robot.version}/node #{process.version}"
