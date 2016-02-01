TxtreeAtomView = require './txtree-atom-view'
RequestWrap = require './http-request'
Notify = require 'atom-notify'

module.exports = TxtreeAtom =
  txtreeAtomView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @txtreeAtomView = TxtreeAtomView.activate()

    atom.commands.add 'atom-text-editor', 'txtree:publish', =>
      @txtreeAtomView.toggle()
      false

    atom.commands.add @txtreeAtomView.miniEditor.element, 'core:confirm', => @publish()
    atom.commands.add @txtreeAtomView.miniEditor.element, 'core:cancel', => @txtreeAtomView.close()

  deactivate: ->
    console.log "deinit"

  publish: ->
    host = "https://haroocloud.com/api/tree"
    # host = "http://localhost:3030/api/tree"
    title = @txtreeAtomView.confirm()
    editor = atom.workspace.getActiveTextEditor()
    request = RequestWrap.init()

    request(host + '/doc', {
      method: 'post',
      mode: 'cors',
      headers: {
        'Accept': 'application/json', 'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        text: editor.getText()
        title: title,
        theme: 'text/atom'
      })
    }).then((res) ->
      notifier = Notify "Txtree"
      # console.log(res.ok)
      if res.ok
        notifier.addSuccess "Save to Txtree operation Successed", timeOut: 2000
      else
        notifier.addError "Save to Txtree operation Failed", dismissable: false
      # notifier.addInfo "There is air outside."
    )
