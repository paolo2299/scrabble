import React from 'react'
import Util from './util.js'

const GameStateDisplay = React.createClass({
  playerFromPosition: function(position) {
    return Util.findByAttribute(this.props.allPlayers, 'position', position)
  },

  render: function() {
    let statusMessage = ''
    if (this.props.gameStatus === 'waiting_for_players') {
      statusMessage = 'Waiting for second player to join.'
      statusMessage += 'Game ID: ' + this.props.gameId
    } else if (this.props.playerPosition === this.props.playerToActPosition) {
      statusMessage = 'Your turn!'
    } else {
      let playerToAct = this.playerFromPosition(this.props.playerToActPosition)
      statusMessage = playerToAct.name + " to act."
    }
    return (
      <div className="GameStateDisplay">
        { statusMessage }
      </div>
    )
  },
})

export default GameStateDisplay
