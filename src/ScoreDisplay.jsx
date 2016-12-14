import React from 'react';

const ScoreDisplay = React.createClass({
  render: function(){
    return (
      <div className="Score">
        <h3> Score: { this.props.score } </h3>
      </div>
    );
  }
});

export default ScoreDisplay;
