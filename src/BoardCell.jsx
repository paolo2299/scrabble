import React from 'react';

const BoardCell = React.createClass({
  handleClick: function() {
    this.props.onCellClicked(this.props.colIndex, this.props.rowIndex);
  },

  render: function() {
    return (
      <td className="BoardCell" onClick={this.handleClick}>
        { this.props.children }
      </td>
    )
  }
});

export default BoardCell;
