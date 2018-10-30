module.exports.cassettes =
  '/repos-atmos-hubot-deploy-deployment-production-create-bad-auth':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 401
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: 'Bad credentials'
      documentation_url: 'https://developer.github.com/v3'
  '/repos-atmos-hubot-deploy-deployment-production-create-required-status-missing':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 409
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: 'Conflict: Commit status checks failed for master'
      errors: [
        {
          contexts: [
            {
              context: "continuous-integration/travis-ci/push"
              state: "failure"
            },
            {
              context: "code-climate"
              state: "success"
            }
          ]
        }
      ]
  '/repos-atmos-hubot-deploy-deployment-production-create-required-status-failing':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 409
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: "Conflict: Commit status checks failed for master"
      errors: [
        {
          contexts: [
            {
              context: "continuous-integration/travis-ci/push"
              state: "failure"
            },
            {
              context: "code-climate"
              state: "failure"
            }
          ]
        }
      ]
  '/repos-atmos-hubot-deploy-deployment-production-create-required-status-pending':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 409
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: "Conflict: Commit status checks failed for master"
      errors: [
        {
          contexts: [
            {
              context: "continuous-integration/travis-ci/push"
              state: "pending"
            },
            {
              context: "code-climate"
              state: "success"
            }
          ]
        }
      ]
  '/repos-atmos-hubot-deploy-deployment-production-create-auto-merged-failed':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 409
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: "Conflict merging master into topic."
  '/repos-atmos-hubot-deploy-deployment-production-create-auto-merged':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 202
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      message: "Auto-merged master into topic on deployment."
  '/repos-atmos-hubot-deploy-deployment-production-create-success':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 201
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      deployment:
        url: "https://api.github.com/repos/atmos/hubot-deploy/deployments/1875476"
        id: 1875476
        sha: "3c9f42c76ce057eaabc3762e3ec46dd830976963"
        ref: "heroku"
        task: "deploy"
        environment: "production"
        description: "Deploying from hubot-deploy-v0.6.53"
        payload:
          name: "hubot-deploy"
          hosts: ""
          notify:
            room: "ops",
            user: "atmos",
            adapter: "slack",
          config:
            provider: "heroku",
            auto_merge: true,
            repository: "atmos/hubot-deploy",
            environments: [ "production", "staging" ]
            allowed_rooms: []
            heroku_name: "zero-fucks-hubot"
        creator:
          id: 6626297,
          login: "atmos",
          avatar_url: "https://avatars.githubusercontent.com/u/6626297?v=3"
      repository:
        id: 42524818
        name: "hubot-deploy"
        private: true
        full_name: "atmos/hubot-deploy"
        owner:
          login: "atmos",
          type: "User",
          site_admin: false
      sender:
        id: 6626297
        login: "atmos"
        avatar_url: "https://avatars.githubusercontent.com/u/6626297?v=3"

  '/repos-atmos-hubot-deploy-deployment-staging-create-success':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/deployments'
    method: 'post'
    code: 201
    path: '/repos/atmos/hubot-deploy/deployments'
    body:
      deployment:
        url: "https://api.github.com/repos/atmos/hubot-deploy/deployments/1875476"
        id: 1875476
        sha: "3c9f42c76ce057eaabc3762e3ec46dd830976963"
        ref: "heroku"
        task: "deploy"
        environment: "staging"
        description: "Deploying from hubot-deploy-v0.6.53"
        payload:
          name: "hubot-deploy"
          hosts: ""
          notify:
            room: "ops",
            user: "atmos",
            adapter: "slack",
          config:
            provider: "heroku",
            auto_merge: true,
            repository: "atmos/hubot-deploy",
            environments: [ "production", "staging" ]
            allowed_rooms: []
            heroku_name: "zero-fucks-hubot"
        creator:
          id: 6626297,
          login: "atmos",
          avatar_url: "https://avatars.githubusercontent.com/u/6626297?v=3"
      repository:
        id: 42524818
        name: "hubot-deploy"
        private: true
        full_name: "atmos/hubot-deploy"
        owner:
          login: "atmos",
          type: "User",
          site_admin: false
      sender:
        id: 6626297
        login: "atmos"
        avatar_url: "https://avatars.githubusercontent.com/u/6626297?v=3"
  '/repos-atmos-hubot-deploy-deployment-production-query-statuses-pending':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/commit/master/status'
    method: 'get'
    code: 200
    body:
      state: "pending",
      statuses: [
        {
          context: "continuous-integration/travis-ci/push"
          state: "pending"
          target_url: "https://travis-ci:443/hubot-deploy/master"
        },
        {
          context: "code-climate"
          state: "success"
          target_url: "https://code-climate:443/hubot-deploy/master"
        }
      ]
  '/repos-atmos-hubot-deploy-deployment-production-query-statuses-failing':
    host: 'https://api.github.com:443'
    path: '/repos/atmos/hubot-deploy/commit/master/status'
    method: 'get'
    code: 200
    body:
      state: "failure",
      statuses: [
        {
          context: "continuous-integration/travis-ci/push"
          state: "failure"
          target_url: "https://travis-ci:443/hubot-deploy/master"
        },
        {
          context: "code-climate"
          state: "failure"
          target_url: "https://code-climate:443/hubot-deploy/master"
        }
      ]
