'use strict';

define([
  'report/views/class/lists'
], function(ListsView) {

  var SectorssListView = ListsView.extend({

    el: '#sectorsListView',

    defaults: {
      slug: 'sectors',
      limit: 10
    }

  });

  return SectorssListView;

});
