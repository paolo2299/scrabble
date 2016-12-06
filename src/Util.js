import * as _ from 'lodash';

const Util = {
  findByAttribute: function(collection, attribute, value) {
    return _.find(
      collection,
      function(x){ return _.isEqual(x[attribute], value); }
    );
  }
};

export default Util;
