import React from 'react'
import * as _ from 'lodash'
import Tile from './tile.jsx'

const TileDisplay = React.createClass({
  onTileClicked: function(tileId) {
    this.props.onTileClicked(tileId)
  },

  playTiles: function() {
    this.props.playTiles()
  },

  reset: function() {
    this.props.reset()
  },

  render: function() {
    if (this.props.gameStatus === 'waiting_for_players') {
      return null
    }
    let self = this
    let tiles = this.props.playerTiles.map(function(tile) {
      if (!tile) {
        // TODO actually render something so that the TileRack
        // can be correct size
        return null
      }
      let selected = false
      if (tile.id === self.props.selectedTileId) {
        selected = true
      }
      let tentative = false
      if (_.find(self.props.tentativelyPlayedTiles, {id: tile.id})) {
        tentative = true
      }
      return (
        <Tile
          key={tile.id}
          tileId={tile.id}
          letter={tile.letter}
          score={tile.score}
          selected={selected}
          tentative={tentative}
          onTileClicked={self.onTileClicked}
        />
      )
    })
    return (
      <div className="tile-display">
        <div className="TileRack">
          { tiles }
        </div>
        <button className="action-button" onClick={this.playTiles}>
          play
        </button>
        <button className="action-button" onClick={this.reset}>
          reset
        </button>
      </div>
    )
  },
})

export default TileDisplay
