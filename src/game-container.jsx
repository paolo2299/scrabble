import * as _ from 'lodash'
import * as $ from 'jquery'
import React from 'react'
import Util from './util.js'
import TileRack from './tile-rack.jsx'
import ErrorContainer from './error-container.jsx'
import ScoreDisplay from './score-display.jsx'
import Board from './board.jsx'

const GameContainer = React.createClass({
  getInitialState: function() {
    let initialState = {
      gameId: null,
      playerId: null,
      playedTiles: [],
      playerTiles: [],
      playerScore: 0,
      selectedTileId: null,
      tentativelyPlayedTiles: [],
      multiplierTiles: {},
      error: null,
    }
    return initialState
  },

  componentDidMount: function() {
    let self = this
    $.post('/games', {}, function(response) {
      self.setState({
        gameId: response.id,
        playerId: response.player.id,
        playedTiles: response.board.playedTiles,
        playerTiles: response.player.tileRack.tiles,
        playerScore: response.player.score,
        selectedTileId: null,
        tentativelyPlayedTiles: [],
        multiplierTiles: response.board.multiplierTiles,
        error: null,
      })
    })
  },

  findByPosition: function(tiles, position) {
    return Util.findByAttribute(tiles, 'position', position)
  },

  handleTileRackTileClicked: function(tileId) {
    if (_.find(this.state.tentativelyPlayedTiles, {id: tileId})) {
      return
    }
    this.setState({selectedTileId: tileId})
  },

  handleBoardCellClicked: function(colIndex, rowIndex) {
    let tentativelyPlayedTiles = this.state.tentativelyPlayedTiles
    let allTiles = tentativelyPlayedTiles.concat(this.state.playedTiles)
    if (this.findByPosition(allTiles, [colIndex, rowIndex])) {
      return
    }
    if (this.state.selectedTileId === null) {
      return
    }
    let selectedTile = _.find(
      this.state.playerTiles,
      {id: this.state.selectedTileId}
    )
    selectedTile.position = [colIndex, rowIndex]
    this.setState(
      {tentativelyPlayedTiles: tentativelyPlayedTiles.concat([selectedTile])}
    )
    this.setState({selectedTileId: null})
  },

  errorMessageFromError: function(error) {
    let errMessage = 'Invalid move.'
    let errType = error.error_data.type
    switch (errType) {
      case 'FirstMoveNotOnCenterError':
        errMessage = 'The first word placed on the board ' +
                       'needs to cross the center square.'
        break
      case 'InvalidWordError':
        let invalidWord = error.error_data.invalid_words[0]
        errMessage = invalidWord + ' is not a real word.'
        break
      case 'NotInSameRowOrSameColumnError':
        errMessage = 'Tiles must all be placed on the same ' +
                       'row or the same column.'
        break
      case 'GapError':
        errMessage = 'You left a gap in a place that\'s not allowed.'
        break
      case 'DidNotBuildOnExistingWordsError':
        errMessage = 'You must build on the words already placed on the board.'
        break
    }
    return errMessage
  },

  reset: function() {
    this.setState({
      tentativelyPlayedTiles: [],
      selectedTileId: null,
      error: null,
    })
  },

  playTiles: function() {
    let self = this
    let postData = {
      playedTiles: this.state.tentativelyPlayedTiles,
    }
    $.ajax({
      url: '/games/' + this.state.gameId + '/play',
      method: 'POST',
      data: JSON.stringify(postData),
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      success: function(data) {
        self.setState({
          playedTiles: data.board.playedTiles,
          playerTiles: data.player.tileRack.tiles,
          playerScore: data.player.score,
          selectedTileId: null,
          tentativelyPlayedTiles: [],
          error: null,
        })
      },
      error: function(data) {
        // TODO handle unexpected error too
        let errorData = data.responseJSON
        let errorMessage = self.errorMessageFromError(errorData)
        self.setState({
          error: errorMessage,
        })
      },
    })
  },

  render: function() {
    return (
      <div className="GameContainer">
        <Board
          playedTiles={this.state.playedTiles}
          playerTiles={this.state.playerTiles}
          tentativelyPlayedTiles={this.state.tentativelyPlayedTiles}
          onBoardCellClicked={this.handleBoardCellClicked}
          multiplierTiles={this.state.multiplierTiles}
        />
        <ErrorContainer error={this.state.error} />
        <ScoreDisplay score={this.state.playerScore} />
        <TileRack
          selectedTileId={this.state.selectedTileId}
          playerTiles={this.state.playerTiles}
          tentativelyPlayedTiles={this.state.tentativelyPlayedTiles}
          onTileClicked={this.handleTileRackTileClicked}
        />
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

export default GameContainer
