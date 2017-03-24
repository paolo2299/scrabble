import * as _ from 'lodash'
import * as $ from 'jquery'
import React from 'react'
import Util from './util.js'
import MenuScreen from './menu-screen.jsx'
import TileRack from './tile-rack.jsx'
import ErrorContainer from './error-container.jsx'
import ScoreDisplay from './score-display.jsx'
import Board from './board.jsx'
import GameStateDisplay from './game-state-display.jsx'

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

  startNewGame: function(numPlayers) {
    let self = this
    // TODO error handling
    $.post('/games', {numPlayers: numPlayers}, function(response) {
      self.setStateFromServerResponse(response, true)
      self.pollServerForUpdates()
    })
  },

  setStateFromServerResponse: function(response, resetPlayerTiles) {
    this.setState({
      gameId: response.id,
      gameStatus: response.status,
      playerId: response.player.id,
      playedTiles: response.board.playedTiles,
      playerTiles: response.player.tileRack.tiles,
      playerScore: response.player.score,
      playerPosition: response.player.position,
      playerToActPosition: response.playerToAct,
      multiplierTiles: response.board.multiplierTiles,
    })
    if (resetPlayerTiles) {
      this.setState({
        selectedTileId: null,
        tentativelyPlayedTiles: [],
      })
    }
  },

  joinExistingGame: function(gameId) {
    let self = this
    // TODO error handling
    $.post('/games/' + gameId + '/players', {}, function(response) {
      self.setStateFromServerResponse(response, true)
      self.pollServerForUpdates()
    })
  },

  pollServerForUpdates: function() {
    // TODO handle polling in separate class, and ensure
    // only one poller is running at a time
    setInterval(this.refreshGameState, 10000)
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
    let errMessage = 'Something went wrong. Please try again.'
    let errType = error.errorType
    if (errType !== 'InvalidMoveError') {
      return errMessage
    }
    let errSubType = error.errorSubType
    switch (errSubType) {
      case 'FirstMoveNotOnCenterError':
        errMessage = 'The first word placed on the board ' +
                       'needs to cross the center square.'
        break
      case 'InvalidWordError':
        let invalidWord = error.errorData.invalid_words[0]
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

  refreshGameState: function() {
    if (!this.state.gameId) {
      return
    }
    let self = this
    // TODO error handling
    $.get(
      '/games/' + self.state.gameId,
      {playerId: self.state.playerId},
      function(response) {
      self.setStateFromServerResponse(response, false)
    })
  },

  playTiles: function() {
    let self = this
    let postData = {
      playerId: this.state.playerId,
      playedTiles: this.state.tentativelyPlayedTiles,
    }
    $.ajax({
      url: '/games/' + this.state.gameId + '/play',
      method: 'POST',
      data: JSON.stringify(postData),
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      success: function(response) {
        self.setStateFromServerResponse(response, true)
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
    if (this.state.gameId) {
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
          <GameStateDisplay
            gameId={this.state.gameId}
            gameStatus={this.state.gameStatus}
            playerPosition={this.state.playerPosition}
            playerToActPosition={this.state.playerToActPosition}
          />
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
    } else {
      return (
        <MenuScreen
          startNewGame={this.startNewGame}
          joinExistingGame={this.joinExistingGame}
        />
      )
    }
  },
})

export default GameContainer
