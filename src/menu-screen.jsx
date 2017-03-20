import React from 'react'

const MenuScreen = React.createClass({
  getInitialState: function() {
    let initialState = {
      gameCode: this.props.initalGameCode
    }
    return initialState
  },

  handleGameCodeChange: function(event) {
    this.setState({gameCode: event.target.value})
  },

  startNewSolitaireGame: function() {
    this.props.startNewGame(1)
  },

  startNewTwoPlayerGame: function() {
    this.props.startNewGame(2)
  },

  joinTwoPlayerGame: function() {
    //TODO handle the case where gameCode is empty or clearly incorrect
    this.props.joinExistingGame(this.state.gameCode)
  },

  render: function(){
    return (
      <div className="MenuScreen">
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
  }
})

export default MenuScreen
