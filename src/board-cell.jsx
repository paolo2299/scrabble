import React from 'react'

const BoardCell = React.createClass({
  handleClick: function() {
    this.props.onCellClicked(this.props.colIndex, this.props.rowIndex)
  },

  render: function() {
    let className='BoardCell'
    if (this.props.tripleWordScore) {
      className += ' tripleWordScore'
    }
    if (this.props.doubleWordScore) {
      className += ' doubleWordScore'
    }
    if (this.props.tripleLetterScore) {
      className += ' tripleLetterScore'
    }
    if (this.props.doubleLetterScore) {
      className += ' doubleLetterScore'
    }
    return (
      <td className={className} onClick={this.handleClick}>
        { this.props.children }
      </td>
    )
  },
})

export default BoardCell
