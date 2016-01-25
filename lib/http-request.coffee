module.exports = Request =
  init: () ->
    return window.fetch
  post: (params) ->
    console.log(params.url + '/doc', params.text)
