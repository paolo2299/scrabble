import React from 'react';

const ResetButton = React.createClass({
  handleClick: function() {
    this.props.onClick();
  },

  render: function() {
    return (
      <button className="ResetButton action-button" onClick={this.handleClick}>
        Reset Tiles
      </button>
    )
  }
});

export default ResetButton;
