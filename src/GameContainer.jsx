import * as _ from 'lodash';
import * as $ from 'jquery';
import React from 'react';
import Util from './Util.js';
import PlayTilesButton from './PlayTilesButton.jsx';
import ResetButton from './ResetButton.jsx';
import TileRack from './TileRack.jsx';
import ErrorContainer from './ErrorContainer.jsx';
import Board from './Board.jsx';

const GameContainer = React.createClass({
  componentDidMount: function() {
    let self = this;
    $.post("/games", {}, function(response){
      self.setState({
        gameId: response.id,
        playedTiles: response.board.playedTiles,
        playerTiles: response.player.tileRack.tiles,
        selectedTileId: null,
        tentativelyPlayedTiles: [],
        error: null
      });
    });
  },

  findByPosition: function(tiles, position) {
    return Util.findByAttribute(tiles, 'position', position)
  },

  getInitialState: function() {
    var initialState = {
      playedTiles: [],
      playerTiles: [],
      selectedTileId: null,
      tentativelyPlayedTiles: []
    };
    return initialState;
  },

  handleTileRackTileClicked: function(tileId) {
    if (_.find(this.state.tentativelyPlayedTiles, { id: tileId })) {
      return;
    }
    this.setState({selectedTileId: tileId});
  },

  handleBoardCellClicked: function(colIndex, rowIndex) {
    let allTiles = this.state.tentativelyPlayedTiles + this.state.playedTiles;
    if (this.findByPosition(allTiles, [colIndex, rowIndex])) {
      return;
    }
    if (!this.state.selectedTileId) {
      return;
    }
    let selectedTile = _.find(this.state.playerTiles, {id: this.state.selectedTileId});
    selectedTile.position = [colIndex, rowIndex];
    this.setState({tentativelyPlayedTiles: this.state.tentativelyPlayedTiles.concat([selectedTile])});
    this.setState({selectedTileId: null});
  },

  errorMessageFromError: function(error) {
    let errorMessage = 'Invalid move.';
    let errorType = error.error_data.type;
    //TODO case statement?
    if (errorType === 'FirstMoveNotOnCenterError') {
      errorMessage = 'The first word placed on the board needs to cross the center square.';
    } else if (errorType === 'InvalidWordError') {
      let invalidWord = error.error_data.invalid_words[0];
      errorMessage = invalidWord + ' is not a real word.';
    } else if (errorType === 'NotInSameRowOrSameColumnError') {
      errorMessage = 'Tiles must all be placed on the same row or the same column.';
    } else if (errorType === 'GapError') {
      errorMessage = "You left a gap in a place that's not allowed.";
    } else if (errorType === 'DidNotBuildOnExistingWordsError') {
      errorMessage = 'You must build on the words already placed on the board.';
    }
    return errorMessage;
  },

  reset: function() {
    this.setState({
      tentativelyPlayedTiles: [],
      selectedTileId: null,
      error: null
    });
  },

  playTiles: function() {
    let self = this;
    let postData = {
      playedTiles: this.state.tentativelyPlayedTiles
    };
    $.ajax({
      url: '/games/' + this.state.gameId + '/play',
      method: 'POST',
      data: JSON.stringify(postData),
      contentType:'application/json; charset=utf-8',
      dataType: 'json',
      success: function(data) {
        self.setState({
          playedTiles: data.board.playedTiles,
          playerTiles: data.player.tileRack.tiles,
          selectedTileId: null,
          tentativelyPlayedTiles: [],
          error: null
        });
      },
      error: function(data) {
        //TODO handle unexpected error too
        let errorData = data.responseJSON;
        let errorMessage = self.errorMessageFromError(errorData);
        self.setState({
          error: errorMessage
        });
      }
    });
  },

  render: function() {
    return (
      <div className="GameContainer">
        <Board
          playedTiles={this.state.playedTiles}
          playerTiles={this.state.playerTiles}
          tentativelyPlayedTiles={this.state.tentativelyPlayedTiles}
          onBoardCellClicked={this.handleBoardCellClicked}
        />
        <ErrorContainer error={this.state.error} />
        <TileRack
          selectedTileId={this.state.selectedTileId}
          playerTiles={this.state.playerTiles}
          tentativelyPlayedTiles={this.state.tentativelyPlayedTiles}
          onTileClicked={this.handleTileRackTileClicked}
        />
        <ResetButton onClick={this.reset}>
          reset
        </ResetButton>
        <PlayTilesButton onClick={this.playTiles}>
          play
        </PlayTilesButton>
      </div>
    );
  }
});

export default GameContainer;
