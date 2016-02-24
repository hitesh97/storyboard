React             = require 'react'
Login             = require './010-login'
LargeMessage      = require './900-largeMessage'

require './app.sass'

Root = React.createClass
  displayName: 'Root'

  #-----------------------------------------------------
  propTypes:
    msgSubscribe:           React.PropTypes.func.isRequired
    msgSend:                React.PropTypes.func.isRequired
  getInitialState: ->
    rootStory:              []
    fEstablishedE2E:        false
    fWarnEstablishmentE2E:  false
    loginStatus:            'LOGGED_OUT'
    fLoginRequired:         false

  #-----------------------------------------------------
  componentDidMount: -> 
    @props.msgSubscribe @_rxMsg
    @_txMsg 'INIT_E2E_REQUEST'
    setTimeout =>
      if not @state.fEstablishedE2E
        @setState {fWarnEstablishmentE2E: true}
    , 2000

  #-----------------------------------------------------
  render: -> <div style={_style.outer}>{@_renderContents()}</div>

  _renderContents: ->
    if not @state.fEstablishedE2E then return @_renderConnecting()
    <div>
      <Login 
        fLoginRequired={@state.fLoginRequired}
        loginStatus={@state.loginStatus}
        submit={@_handleSubmitLogin}
      />
      <button onClick={=> @_txMsg 'CLICK', data: {t: new Date().toISOString()}}>Click me!</button>
      <div>Records:</div>
      <ol>
        {@state.rootStory.map (o, idx) -> <li key={idx}>{o.msg}</li>}
      </ol>
    </div>

  _renderConnecting: ->
    <LargeMessage>
      Connecting to Storyboard...
      {@_renderConnecting2()}
    </LargeMessage>

  _renderConnecting2: ->
    return if not @state.fWarnEstablishmentE2E 
    <div>If this seems to be taking a long time, please verify your URL</div>

  #-----------------------------------------------------
  _txMsg: (type, data) ->
    @props.msgSend {src: 'DT', type, data}

  _rxMsg: (msg) ->
    {src, type, data} = msg
    console.log "[DT] RX #{src}/#{type}", data
    switch type
      when 'INIT_E2E_RESPONSE' then @setState {fEstablishedE2E: true}
      when 'LOGIN_REQUIRED' then @setState {fLoginRequired: true}
      when 'LOGIN_SUCCEEDED' then @setState {loginStatus: 'LOGGED_IN'}
      when 'RECORDS' then @_rxRecords data
    return

  _rxRecords: (records) ->
    {rootStory} = @state
    rootStory = rootStory.concat records
    @setState {rootStory}

  _handleSubmitLogin: (credentials) ->
    return if @state.loginStatus isnt 'LOGGED_OUT'
    @_txMsg 'LOGIN_REQUEST', credentials
    @setState {loginStatus: 'LOGGING_IN'}

#-----------------------------------------------------
_style = 
  outer: 
    backgroundColor: 'white'
    height: '100%'
    padding: 4

module.exports = Root
