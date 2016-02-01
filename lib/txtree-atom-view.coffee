# referenced from https://github.com/atom/go-to-line/
{$, TextEditorView, View}  = require 'atom-space-pen-views'

module.exports =
class TxtreeAtomView extends View
  @activate: ->
    new TxtreeAtomView

  @content: ->
    @div class: 'txtree-atom', =>
      @h4 class: 'title', "Publish to Txtree - Anonymous Text Hosting Service"
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'description', "Assign this document's title if you wants"
      # @div class: 'description', outlet: 'message'

  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @miniEditor.on 'blur', => @close()

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    txtreeDocumentTitle = @miniEditor.getText()
    editor = atom.workspace.getActiveTextEditor()
    # console.log("submit", editor? and txtreeDocumentTitle)
    @close()

    return editor? and txtreeDocumentTitle

  storeFocusElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    if editor = atom.workspace.getActiveTextEditor()
      @storeFocusElement()
      @panel.show()
      # @message.text("Assign this document's title if you wants")
      @miniEditor.focus()
