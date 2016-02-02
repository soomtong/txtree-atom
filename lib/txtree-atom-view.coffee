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
      @div class: 'btn-group btn-group-options', =>
        @button class: 'btn selected', outlet: 'useMarkdown', 'use Markdown'
      @div class: 'btn-group btn-group-options pull-right', =>
        @button class: 'btn submit', outlet: 'submitForm', 'Submit'
        @button class: 'btn', outlet: 'closePanel', 'Close'


  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

    # @miniEditor.on 'blur', =>
    #   console.log "lose focus in editor"
    #   console.log @useMarkdown.hasFocus()
    #   @close()

    @useMarkdown.on 'click', =>
      @setOptionButtonState(@useMarkdown, !@useMarkdown.hasClass('selected'))

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    # console.log("close", @panel.isVisible())
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    txtreeDocumentTitle = @miniEditor.getText()
    txtreeDocumentOptions = {
      useMarkdown: @useMarkdown.hasClass 'selected'
    }
    editor = atom.workspace.getActiveTextEditor()
    # console.log("submit", editor? and txtreeDocumentTitle)
    @close()

    return editor? and [txtreeDocumentTitle, txtreeDocumentOptions]

  storeFocusElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  setOptionButtonState: (optionButton, selected) ->
    if selected
      optionButton.addClass 'selected'
    else
      optionButton.removeClass 'selected'

  open: ->
    return if @panel.isVisible()

    if editor = atom.workspace.getActiveTextEditor()
      @storeFocusElement()
      @panel.show()
      @miniEditor.focus()
