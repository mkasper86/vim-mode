_ = require 'underscore-plus'
{Operator} = require './general-operators'

module.exports =
#
# It pastes everything contained within the specifed register
#
class Put extends Operator
  register: '"'

  constructor: (@editor, @vimState, {@location, @selectOptions}={}) ->
    @location ?= 'after'
    @complete = true

  # Public: Pastes the text in the given register.
  #
  # count - The number of times to execute.
  #
  # Returns nothing.
  execute: (count=1) ->
    {text, type} = @vimState.getRegister(@register) || {}
    return unless text

    if @location == 'after'
      if type == 'linewise'
        if @onLastRow()
          @editor.moveCursorToEndOfLine()

          originalPosition = @editor.getCursorScreenPosition()
          originalPosition.row += 1
        else
          @editor.moveCursorDown()
      else
        unless @onLastColumn()
          @editor.moveCursorRight()

    if type == 'linewise' and !originalPosition?
      @editor.moveCursorToBeginningOfLine()
      originalPosition = @editor.getCursorScreenPosition()

    textToInsert = _.times(count, -> text).join('')
    if @location == 'after' and type == 'linewise' and @onLastRow()
      textToInsert = "\n#{textToInsert}"
    @editor.insertText(textToInsert)

    if originalPosition?
      @editor.setCursorScreenPosition(originalPosition)
      @editor.moveCursorToFirstCharacterOfLine()

    @vimState.activateCommandMode()

  # Private: Helper to determine if the editor is currently on the last row.
  #
  # Returns true on the last row and false otherwise.
  onLastRow: ->
    {row, column} = @editor.getCursorBufferPosition()
    row == @editor.getBuffer().getLastRow()

  onLastColumn: ->
    @editor.getCursor().isAtEndOfLine()
