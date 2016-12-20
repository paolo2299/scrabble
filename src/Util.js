import * as _ from 'lodash'

const Util = {
  findByAttribute: function(collection, attribute, value) {
    return _.find(
      collection,
      function(x) {
        return _.isEqual(x[attribute], value)
      }
    )
  },

  findByValue: function(collection, value) {
    let item = _.find(
      collection,
      function(x) {
        return _.isEqual(x, value)
      }
    )
    if (typeof(item) !== 'undefined') {
      return true
    }
    return false
  },
}

export default Util
