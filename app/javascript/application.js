// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@fortawesome/fontawesome-free"

function updateNowUserAttendances() {
  $.ajax({
    url: '/now_user_attendances',
    dataType: 'json',
    success: function(data) {
      $('#now-user-attendances-container').html(data.html);
    }
  });
}

$(document).ready(function() {
  setInterval(updateNowUserAttendances, 10000);
});
