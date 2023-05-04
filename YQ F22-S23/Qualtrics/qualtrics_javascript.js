Qualtrics.SurveyEngine.addOnload(function()
{
	var video = document.getElementById("vid1"); // for next blocks, replace “vid1” with “vid2”, “vid3”, etc, that corresponds to the block’s tag id we gave
	var recTime = 0;
	var timesPlayed = 0;
	
	// prevents users from seeking the video
	video.addEventListener('timeupdate', function() {
  		if (!video.seeking) {
			recTime = video.currentTime;
  		}
	});
	
	video.addEventListener('seeking', function() {
	  var delta = video.currentTime - recTime;
	  if (delta > 0.01) {
		video.currentTime = recTime;
	  }
	});
	
	video.onended = function() {
    	$('NextButton').show();
		recTime = 0;
		timesPlayed++;
		Qualtrics.SurveyEngine.setEmbeddedData("count_vid1", timesPlayed); // for more blocks, replace “count_vid1” with “count_vid2”, etc
	};
});

Qualtrics.SurveyEngine.addOnReady(function()
{
	// hides next button until users finish the video
    $('NextButton').hide();
});

Qualtrics.SurveyEngine.addOnUnload(function() {});
