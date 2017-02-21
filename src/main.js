import React from 'react'
import Pusher from 'pusher-js';
import ReactDOM from 'react-dom'
import GameContainer from './GameContainer.jsx'

let pusher = new Pusher("MY_TEST_KEY",{"wsHost":"127.0.0.1","wsPort":62873})
let scrabbleServerChannel = pusher.subscribe('scrabbleChannel');
scrabbleServerChannel.bind('testEvent', function (data) {
  console.log(data);
});

ReactDOM.render(
  <GameContainer />,
  document.getElementById('content')
)
