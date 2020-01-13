import 'package:flutter/material.dart' show Path, Rect;

Path createDashedPath(Rect rect, double dash) {
  var perim = rect.width * 2 + rect.height * 2;

  Path path = Path();

  var dx = rect.right;
  var dy = rect.bottom;
  path.moveTo(dx, dy);
  var extra = -(perim - (perim / dash).floor() * dash);
  bool isDash = false;

  // Starts at bottom right and draws clockwise

  // Draw bottom line
  while (dx >= rect.left) {
    isDash = !isDash;
    if (!isDash) {
      path.moveTo(dx, dy);
    } else {
      path.lineTo(dx, dy);
    }
    dx -= dash + extra;
    extra = 0;
  }
  isDash = !isDash;
  // Draw bottom left corner
  extra = rect.left - dx;
  dx = rect.left;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }
  dy -= extra;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }

  // Draw left line
  dy -= dash;
  while (dy >= rect.top) {
    isDash = !isDash;
    if (!isDash) {
      path.moveTo(dx, dy);
    } else {
      path.lineTo(dx, dy);
    }
    dy -= dash;
  }
  isDash = !isDash;
  // Draw top left corner
  extra = rect.top - dy;
  dy = rect.top;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }
  dx += extra;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }

  // Draw top line
  dx += dash;
  while (dx <= rect.right) {
    isDash = !isDash;
    if (!isDash) {
      path.moveTo(dx, dy);
    } else {
      path.lineTo(dx, dy);
    }
    dx += dash;
  }
  isDash = !isDash;

  // Draw top right corner
  extra = dx - rect.right;
  dx = rect.right;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }
  dy += extra;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }

  // Draw right line
  dy += dash;
  while (dy <= rect.bottom) {
    isDash = !isDash;
    if (!isDash) {
      path.moveTo(dx, dy);
    } else {
      path.lineTo(dx, dy);
    }
    dy += dash;
  }

  isDash = !isDash;
  extra = dy - rect.bottom;
  dy = rect.bottom;
  if (!isDash) {
    path.moveTo(dx, dy);
  } else {
    path.lineTo(dx, dy);
  }

  return path;
}
