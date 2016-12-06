import React from 'react';
import * as _ from 'lodash';
import Tile from './Tile.jsx';

const TileRack = React.createClass({
  onTileClicked: function(tileId) {
    this.props.onTileClicked(tileId);
  },

  render: function() {
    let self = this;
    var tiles = this.props.playerTiles.map(function(tile) {
      if (!tile) {
        //TODO actually render something so that the TileRack can be correct size
        return null;
      }
      let selected = false;
      if (tile.id === self.props.selectedTileId) {
        selected = true;
      }
      let tentative = false;
      if (_.find(self.props.tentativelyPlayedTiles, { id: tile.id })) {
        tentative = true;
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
      );
    });
    return (
      <div className="TileRack">
        { tiles }
      </div>
    )
  }
});

export default TileRack;
