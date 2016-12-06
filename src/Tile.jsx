import React from 'react';

const Tile = React.createClass({
  handleClick: function(e) {
    this.props.onTileClicked(this.props.tileId);
  },

  render: function() {
    let className = "Tile";
    if (this.props.tentative) {
      className += " tentative";
    }
    if (this.props.selected) {
      className += " selected";
    }
    return (
      <div className={className} onClick={this.handleClick}>
        <span className="Letter">
          {this.props.letter}
        </span><span className="Score">
          {this.props.score}
        </span>
      </div>
    )
  }
});

export default Tile;
