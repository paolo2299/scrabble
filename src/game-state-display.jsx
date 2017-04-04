import React from 'react'
import Util from './util.js'

const GameStateDisplay = React.createClass({
  playerFromPosition: function(position) {
    return Util.findByAttribute(this.props.allPlayers, 'position', position)
  },

  playerActionClassName: function(player) {
    if (this.props.playerToActPosition === player.position) {
      if (this.props.playerPosition === player.position) {
        return 'you-to-act'
      }
      return 'waiting-to-act'
    }
    return ''
  },

  render: function() {
    let statusMessage = null
    let self = this
    if (this.props.gameStatus === 'waiting_for_players') {
      statusMessage = 'Waiting for players to join.'
      statusMessage += ' Game ID: ' + this.props.gameId
    }
    let tableHeaders = this.props.allPlayers.map(function(player) {
      return (
        <th
          key={player.id}
          className={'player-name ' + self.playerActionClassName(player)}
        >
          { player.name }
        </th>
      )
    })
    let tableScoreRow = this.props.allPlayers.map(function(player) {
      return (
        <td
          key={player.id}
          className={'player-score ' + self.playerActionClassName(player)}>
          { player.score }
        </td>
      )
    })
    return (
      <div>
        <p className="status-message">
          { statusMessage }
        </p>
        <table className="players-display">
          <thead>
            <tr>
              { tableHeaders }
            </tr>
          </thead>
          <tbody>
            <tr>
              { tableScoreRow }
            </tr>
          </tbody>
        </table>
      </div>
    )
  },
})

export default GameStateDisplay
