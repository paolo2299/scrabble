import React from 'react';

const ErrorContainer = React.createClass({
  render: function(){
    return (
      <div className="ErrorContainer">
        { this.props.error }
      </div>
    );
  }
});

export default ErrorContainer;
