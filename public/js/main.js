window.topz = 42;

// Get random ordinal - don't use this for srs bsns or Moxie Marspinkle will kick your ass
function randomness() {
  return (Math.round(Math.random()) - 0.5);
}

function randomCoords() {
  var max_x = $(document).width();
  var max_y = $(document).height();

  var rand_x = Math.random() * max_x;
  var rand_y = Math.random() * max_y % 768;

  rand_x = Math.round(rand_x);
  rand_y = Math.round(rand_y);
  
  return [rand_x, rand_y];
}

function renderRandomRect(width, height, color) {
  var coords = randomCoords();

  var zombie_ad = document.createElement('div');
  zombie_ad.className = 'zombie_block';
  zombie_ad.style.background = 'rgba('+color[0]+','+color[1]+','+color[2]+',0.5)';
  zombie_ad.style.top = coords[1] + 'px';
  zombie_ad.style.left = coords[0] + 'px';
  zombie_ad.style.width = width + 'px';
  zombie_ad.style.height = height + 'px';
  zombie_ad.style.zIndex = window.topz;
  zombie_ad.id = 'ad_block_' + window.topz;

  document.body.appendChild(zombie_ad);

  window.topz++;
}

$(document).ready(function() {
  var socket = io.connect('http://localhost');
  socket.on("HI!", function (data) {
    console.log(data);
    var ip = data[0].dns.address.split('.');
    renderRandomRect(+ip[0], +ip[3], ip);

  });
  $(document).click(function() {
    renderRandomRect(80, 180);
  });
});