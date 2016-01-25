TxtreeAtomView = require './txtree-atom-view'
RequestWrap = require './http-request'
{CompositeDisposable} = require 'atom'
Notify = require 'atom-notify'

module.exports = TxtreeAtom =
  txtreeAtomView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @txtreeAtomView = new TxtreeAtomView(state.txtreeAtomViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @txtreeAtomView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'txtree:publish': => @publish()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @txtreeAtomView.destroy()

  serialize: ->
    txtreeAtomViewState: @txtreeAtomView.serialize()

  publish: ->
    @modalPanel.show()

    host = "https://haroocloud.com/api/tree"
    editor = atom.workspace.getActiveTextEditor()
    fetch = RequestWrap.init()

    fetch(host + '/doc', {
      method: 'post',
      mode: 'cors',
      headers: {
        'Accept': 'application/json', 'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        text: editor.getText()
      })
    }).then((res) ->
      notifier = Notify "Txtree"
      # console.log(res.ok)
      if res.ok
        notifier.addSuccess "That was a blast!", timeOut: 2000
      else
        notifier.addError "That was a bummer!", dismissable: false
      # notifier.addInfo "There is air outside."
    )
    result = 'ok'
    # @txtreeAtomView.setResult(result)

    @modalPanel.hide()
