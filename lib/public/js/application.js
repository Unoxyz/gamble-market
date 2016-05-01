var COORDINATES = false;

var canvas = document.getElementById("graph");
var ctx = canvas.getContext("2d");

canvas.width  = 800;
canvas.height = 600;
ctx.font = '10px Menlo';

var DATA1 = JSON.parse(document.getElementById("wtp").innerText);
var DATA2 = JSON.parse(document.getElementById("wta").innerText);

var MAX_DATA = {
  x: Math.floor(max(DATA1.x.concat(DATA2.x)) / 5) * 5 + 5,
  y: Math.ceil(max(DATA1.y.concat(DATA2.y)) / 10000) * 10000
};

var MAX_DATA_X = MAX_DATA.x;
var MAX_DATA_Y = MAX_DATA.y;

var MARGIN = 10;
var CHART_LENGTH_X = canvas.width - MARGIN;
var CHART_LENGTH_Y = canvas.height - MARGIN * 3;
var UNIT_X = CHART_LENGTH_X / MAX_DATA_X;
var UNIT_Y = CHART_LENGTH_Y / MAX_DATA_Y;


// 객체 정의
function StairGraph(data) {
    this.data = data;
    this.points = (function() {
        var points = [];
        for (var i = 0; i < data.x.length; i++) {
            points[i] = { x: data.x[i], y: data.y[i] };
        }
        return points;
    })();
}

StairGraph.prototype = {
    constructor: StairGraph,

    draw: function(ctx, strokeStyle) {
        var points = this.points;
        var data = this.data;

        var point_x = points[0].x * UNIT_X;
        var point_y = CHART_LENGTH_Y - points[0].y * UNIT_Y;
        ctx.beginPath();
        ctx.lineWidth = 4;
        ctx.setLineDash([]);
        ctx.strokeStyle = strokeStyle;
        ctx.moveTo(0, point_y);
        for (var i = 0; i < points.length; i++) {
            point_x = points[i].x * UNIT_X;
            point_y = CHART_LENGTH_Y - points[i].y * UNIT_Y;

            if (i !== 0) {
                var prev_point_x = points[i - 1].x * UNIT_X;
                var prev_point_y = CHART_LENGTH_Y - points[i - 1].y * UNIT_Y;
                ctx.lineTo(prev_point_x, point_y);
            }

            ctx.lineTo(point_x, point_y);

            var point_txt = i + ":" + "(" + point_x.toFixed(0) + ", " + point_y.toFixed(0) + ")";
            point_txt += " (" + points[i].x + ", " + points[i].y + ")";
            if (COORDINATES) {
              ctx.textAlign = 'start';
              ctx.fillText(point_txt, point_x, point_y);
              console.debug(point_txt);
            }
        }
        ctx.stroke();
    }
};

function draw_grid(x, y) {
  // ctx.translate(MARGIN, MARGIN);
  ctx.setLineDash([3, 5]);
  ctx.lineWidth = 0.3;
  ctx.strokeStyle = 'grey';

  for (var i = 0; i < 10; i++) {
    // draw grid X
    ctx.beginPath();
    ctx.moveTo(i * x, 0);
    ctx.lineTo(i * x, CHART_LENGTH_Y);
    ctx.closePath();
    ctx.stroke();
    // draw grid Y
    ctx.beginPath();
    ctx.moveTo(0, i * y);
    ctx.lineTo(CHART_LENGTH_X, i * y);
    ctx.closePath();
    ctx.stroke();
  }
}

function draw_axis_label(x, y) {
  // ctx.translate(MARGIN, MARGIN);
  ctx.setLineDash([3, 5]);
  ctx.lineWidth = 0.3;
  ctx.strokeStyle = 'grey';

  ctx.textBaseline = "hanging";
  ctx.textAlign = 'center';
  var range = MAX_DATA_X / 5;
  for (var i = 0; i < range; i++) {
    // draw grid X
    if (i > 0) {
      ctx.beginPath();
      ctx.moveTo(i * x + MARGIN * 3, 0);
      ctx.lineTo(i * x + MARGIN * 3, CHART_LENGTH_Y + 5);
      ctx.closePath();
      ctx.stroke();
    }
    // draw label X
    var text = i * 5;
    ctx.fillText(text, i * x + MARGIN * 3, CHART_LENGTH_Y + 5);
  }
  // draw label Y
  ctx.textBaseline = "middle";
  ctx.textAlign = 'right';
  var step = Math.pow(10, count_digit(MAX_DATA_Y) - 1);
  var range = MAX_DATA_Y / step;
  for (var i = 0; i < range; i += 1) {
    // draw grid Y
    if (i > 0) {
      ctx.beginPath();
      ctx.moveTo(0, i * y * step);
      ctx.lineTo(CHART_LENGTH_X, i * y * step);
      ctx.closePath();
      ctx.stroke();
    }
    var text = MAX_DATA_Y - i * step;
    ctx.fillText(text, 30, i * y * step);
  }
}

function draw_axis() {
  ctx.setLineDash([]);
  ctx.lineWidth = 1;
  ctx.strokeStyle = 'black';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(0, CHART_LENGTH_Y);
  ctx.moveTo(0, CHART_LENGTH_Y);
  ctx.lineTo(CHART_LENGTH_X, CHART_LENGTH_Y);
  ctx.closePath();
  ctx.stroke();
  // console.debug(CHART_LENGTH_X, CHART_LENGTH_Y);
}

function max(array) {
  var max_value = 0;
  var current_value = 0;
  for (var i = 0; i < array.length; i++) {
    current_value = array[i];
    if (max_value < current_value) {
      max_value = current_value;
    }
  }
  return max_value;
}

function draw_legend(ctx, style1, style2) {
  var width = 100;
  var height = 50;
  var left = CHART_LENGTH_X - MARGIN * 3 - width - 10;
  var upper = 10;
  // draw box
  ctx.fillStyle = "white";
  ctx.fillRect(left, upper, width, height);
  ctx.strokeStyle = "black";
  ctx.lineWidth = 1;
  ctx.strokeRect(left, upper, width, height);

  ctx.lineWidth = 3;
  // draw legend 1
  ctx.beginPath();
  ctx.strokeStyle = style1;
  ctx.moveTo(left + 5, upper + 15);
  ctx.lineTo(left + 35, upper + 15);
  ctx.stroke();
  ctx.closePath();
  ctx.fillStyle = "black";
  ctx.textAlign = "start";
  ctx.fillText("WTP", left + 45, upper + 15);
  // draw legend 2
  ctx.beginPath();
  ctx.strokeStyle = style2;
  ctx.moveTo(left + 5, upper + 35);
  ctx.lineTo(left + 35, upper + 35);
  ctx.closePath();
  ctx.stroke();
  ctx.textAlign = "start";
  ctx.fillText("WTA", left + 45, upper + 35);
}

ctx.translate(MARGIN, MARGIN);
draw_axis_label(UNIT_X * 5, UNIT_Y);

ctx.translate(35, 0);
draw_axis();
// draw_grid(UNIT_X * 5, UNIT_Y);

var wtp1 = new StairGraph(DATA1);
wtp1.draw(ctx, "green");

var wta1 = new StairGraph(DATA2);
wta1.draw(ctx, "purple");

draw_legend(ctx, 'green', 'purple');

console.info("please adjust MAX_DATA using this values for axis labels.");
console.table({max_x: max(DATA1.x.concat(DATA2.x)), max_y: max(DATA1.y.concat(DATA2.y))});

function count_digit(number) {
  var count = 0;
  var digit = 0;
  while (number >= digit) {
    digit = Math.pow(10, count);
    count++;
  }
  return count - 1;
}
