// TODO make into an ES6 class?
const GameEventListener = {
  // TODO look up how to do singleton so we can do state properly

  poll: function(pollFunction, callback) {
    setInterval(pollFunction, 1000)
  },
}

export default GameEventListener
