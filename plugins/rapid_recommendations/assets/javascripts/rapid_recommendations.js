/* recommendations */
Event.addBehavior({
  '.recommend-this a:click': function(event) {
		Effect.BlindDown($(event.target.up('.section').down('form')), {direction: 'top-left'});
		Event.stop(event);
	}
});