import Pusher from 'pusher-js'

// TODO make into an ES6 class?
const GameEventListener = {
  API_KEY: 'MY_TEST_KEY',
  WEB_SOCKET_HOST: '127.0.0.1',
  WEB_SOCKET_PORT: 62873,
  CHANNEL_NAME: 'scrabbleChannel',

  instance: function() {
    // TODO lookup how to do singleton
    if (typeof _instance !== 'undefined') {
      return _instance
    }
    const pusher = new Pusher(
      this.API_KEY,
      {'wsHost': this.WEB_SOCKET_HOST, 'wsPort': this.WEB_SOCKET_PORT}
    )
    const _instance = pusher.subscribe(this.CHANNEL_NAME)
    return _instance
  },

  // example usage: GameEventListener.listen("someEvent", function(data) {
  //   console.log(data)
  // })
  listen: function(eventName, callback) {
    this.instance().bind(eventName, callback)
  },
}

export default GameEventListener
