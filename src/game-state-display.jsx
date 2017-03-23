import React from 'react'

const GameStateDisplay = React.createClass({
  render: function() {
    let statusMessage = ''
    if (this.props.gameStatus === 'waiting_for_players') {
      statusMessage = 'Waiting for second player to join.'
      statusMessage += 'Game ID: ' + this.props.gameId
    } else if (this.props.playerPosition === this.props.playerToActPosition) {
      statusMessage = 'Your turn!'
    } else {
      statusMessage = 'Waiting for the other player to act'
    }
    return (
      <div className="GameStateDisplay">
        { statusMessage }
      </div>
    )
  },
})

export default GameStateDisplay
