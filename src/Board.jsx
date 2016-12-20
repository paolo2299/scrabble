import React from 'react'
import Util from './Util.js'
import * as _ from 'lodash'
import BoardCell from './BoardCell.jsx'
import Tile from './Tile.jsx'

const Board = React.createClass({
  findByPosition(tiles, position) {
    return Util.findByAttribute(tiles, 'position', position)
  },

  doNothing: function() {
    return
  },

  findPlayedTile: function(colIndex, rowIndex) {
    let tile = null
    let tileData = this.findByPosition(
      this.props.playedTiles,
      [colIndex, rowIndex]
    )
    if (tileData) {
      tile = <Tile
        key={tileData.id}
        letter={tileData.letter}
        score={tileData.score}
        onTileClicked={this.doNothing}
      />
    }
    return tile
  },

  findTentativelyPlayedTile: function(colIndex, rowIndex) {
    let tile = null
    let tileData = null
    let tileId = null
    let tileIndexData = this.findByPosition(
      this.props.tentativelyPlayedTiles,
      [colIndex, rowIndex]
    )
    if (tileIndexData) {
      tileId = tileIndexData.id
      tileData = _.find(this.props.playerTiles, {'id': tileId})
      tile = <Tile
        letter={tileData.letter}
        score={tileData.score}
        tentative={true}
        onTileClicked={this.doNothing}
      />
    }
    return tile
  },

  handleCellClick: function(colIndex, rowIndex) {
    this.props.onBoardCellClicked(colIndex, rowIndex)
  },

  render: function() {
    let self = this
    let boardRows = _.range(15).map(function(rowIndex) {
      let squares = _.range(15).map(function(colIndex) {
        let square
        let tile = self.findPlayedTile(colIndex, rowIndex) ||
                   self.findTentativelyPlayedTile(colIndex, rowIndex)
        let multiplierTiles = self.props.multiplierTiles
        let tripleWordScore = Util.findByValue(
          multiplierTiles.tripleWord,
          [colIndex, rowIndex]
        )
        let tripleLetterScore = Util.findByValue(
          multiplierTiles.tripleLetter,
          [colIndex, rowIndex]
        )
        let doubleWordScore = Util.findByValue(
          multiplierTiles.doubleWord,
          [colIndex, rowIndex]
        )
        let doubleLetterScore = Util.findByValue(
          multiplierTiles.doubleLetter,
          [colIndex, rowIndex]
        )
        return (
          <BoardCell
            key={colIndex}
            colIndex={colIndex}
            rowIndex={rowIndex}
            onCellClicked={self.handleCellClick}
            tripleWordScore={tripleWordScore}
            tripleLetterScore={tripleLetterScore}
            doubleWordScore={doubleWordScore}
            doubleLetterScore={doubleLetterScore}
          >
            { tile }
          </BoardCell>
        )
        return square
      })
      return (
        <tr className="BoardRow" key={rowIndex}>
          { squares }
        </tr>
      )
    })
    return (
      <table className="Board">
        <tbody>
          { boardRows }
        </tbody>
      </table>
    )
  },
})

export default Board
