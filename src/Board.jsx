import React from 'react';
import Util from './Util.js';
import * as _ from 'lodash';
import BoardCell from './BoardCell.jsx';

const Board = React.createClass({
  findByPosition(tiles, position) {
    return Util.findByAttribute(tiles, 'position', position)
  },

  doNothing: function() {
    return;
  },

  findPlayedTile: function(colIndex, rowIndex) {
    var tile = null;
    var tileData = this.findByPosition(this.props.playedTiles, [colIndex, rowIndex]);
    if (tileData) {
      tile = <Tile
        key={tileData.id}
        letter={tileData.letter}
        score={tileData.score}
        onTileClicked={this.doNothing}
      />;
    }
    return tile;
  },

  findTentativelyPlayedTile: function(colIndex, rowIndex) {
    var tile = null;
    var tileData = null;
    var tileId = null;
    var tileIndexData = this.findByPosition(this.props.tentativelyPlayedTiles, [colIndex, rowIndex]);
    if (tileIndexData) {
      tileId = tileIndexData.id;
      tileData = _.find(this.props.playerTiles, { 'id': tileId });
      tile = <Tile
        letter={tileData.letter}
        score={tileData.score}
        tentative={true}
        onTileClicked={this.doNothing}
      />;
    }
    return tile;
  },

  handleCellClick: function(colIndex, rowIndex) {
    this.props.onBoardCellClicked(colIndex, rowIndex);
  },

  render: function() {
    var self = this;
    var boardRows = _.range(15).map(function(rowIndex){
      var squares = _.range(15).map(function(colIndex){
        var square;
        var tile = self.findPlayedTile(colIndex, rowIndex) ||
                   self.findTentativelyPlayedTile(colIndex, rowIndex);
        return (
          <BoardCell key={colIndex} colIndex={colIndex} rowIndex={rowIndex} onCellClicked={self.handleCellClick}>
            { tile }
          </BoardCell>
        );
        return square;
      });
      return (
        <tr className="BoardRow" key={rowIndex}>
          { squares }
        </tr>
      );
    });
    return (
      <table className="Board">
        <tbody>
          { boardRows }
        </tbody>
      </table>
    )
  }
});

export default Board;
