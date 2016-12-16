import React from 'react'

const PlayTilesButton = React.createClass({
  handleClick: function() {
    this.props.onClick()
  },

  render: function() {
    return (
      <button className="PlayTilesButton action-button" onClick={this.handleClick}>
        Play
      </button>
    )
  },
})

export default PlayTilesButton
