import React from 'react'

const MenuScreen = React.createClass({
  getInitialState: function() {
    let initialState = {
      gameCode: this.props.initalGameCode,
      playerName: this.props.initialPlayerName,
    }
    return initialState
  },

  handleGameCodeChange: function(event) {
    this.setState({gameCode: event.target.value})
  },

  handlePlayerNameChange: function(event) {
    this.setState({playerName: event.target.value})
  },

  startNewSolitaireGame: function() {
    // TODO handle the case where playerName is empty
    this.props.startNewGame(1, this.state.playerName)
  },

  startNewTwoPlayerGame: function() {
    // TODO handle the case where playerName is empty
    this.props.startNewGame(2, this.state.playerName)
  },

  joinTwoPlayerGame: function() {
    // TODO handle the case where gameCode is empty or clearly incorrect
    // TODO handle the case where playerName is empty
    this.props.joinExistingGame(this.state.gameCode, this.state.playerName)
  },

  render: function() {
    return (
      <div className="MenuScreen">
        <input
          name="playerName"
          type="text"
          value={this.state.playerName}
          onChange={this.handlePlayerNameChange}
        />
        <div className="menu-section">
          <button
            className="menu-button"
            onClick={this.startNewSolitaireGame} >
            start solo game
          </button>
        </div>
        <div className="menu-section">
          <button
            className="menu-button"
            onClick={this.startNewTwoPlayerGame} >
            start two player game
          </button>
        </div>
        <div className="menu-section">
          <button
            className = "menu-button"
            onClick={this.joinTwoPlayerGame} >
            join two player game
          </button>
          <input
            name="gameCode"
            type="text"
            value={this.state.gameCode}
            onChange={this.handleGameCodeChange}
          />
        </div>
      </div>
    )
  },
})

export default MenuScreen
