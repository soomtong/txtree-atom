TxtreeAtomView = require './txtree-atom-view'
RequestWrap = require './http-request'
Notify = require 'atom-notify'
{CompositeDisposable} = require 'atom'

module.exports = TxtreeAtom =
  txtreeAtomView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @txtreeAtomView = TxtreeAtomView.activate()
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor', 'txtree:publish', =>
      @txtreeAtomView.toggle()
      false

    @subscriptions.add @txtreeAtomView.closePanel.on 'click', => @txtreeAtomView.close()
    @subscriptions.add @txtreeAtomView.submitForm.on 'click', => @publish()

    @subscriptions.add atom.commands.add @txtreeAtomView.miniEditor.element, 'core:confirm', => @publish()
    @subscriptions.add atom.commands.add @txtreeAtomView.miniEditor.element, 'core:close', => @txtreeAtomView.close()
    @subscriptions.add atom.commands.add @txtreeAtomView.miniEditor.element, 'core:cancel', => @txtreeAtomView.close()

    # for global exit
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel', => @txtreeAtomView.close()

  deactivate: ->
    console.log "deinit"
    @subscriptions?.dispose()
    @subscriptions = null

  publish: ->
    host = "https://haroocloud.com/api/tree"
    # host = "http://localhost:3030/api/tree"
    [title, options] = @txtreeAtomView.confirm()
    editor = atom.workspace.getActiveTextEditor()
    request = RequestWrap.init()

    # console.log title, options

    request(host + '/doc',
      method: 'post',
      mode: 'cors',
      headers:
        'Accept': 'application/json', 'Content-Type': 'application/json'
      ,
      body: JSON.stringify(
        text: editor.getText()
        title: title,
        theme: if options.useMarkdown then 'markdown/atom' else 'text/atom'
      )
    ).then((res) ->
      notifier = Notify "Txtree"
      # console.log(res.ok)
      if res.ok
        notifier.addSuccess "Save to Txtree operation Succeed", timeOut: 2000
      else
        notifier.addError "Save to Txtree operation Failed", dismissable: false
      # notifier.addInfo "There is air outside."
    )
